classdef baselDAC < handle
    %BASELDAC Interface class for the Physics Basel LNHR DAC IIa (SP 1085).
    %
    %   Written to mirror the structure of the lab's sigDAC class, so the
    %   calling conventions should feel familiar:
    %
    %       dac = baselDAC('COM3', 24, 'dac');          % RS-232
    %       dac = baselDAC('192.168.0.5', 24, 'dac');   % TCP/IP Telnet (preferred)
    %
    %       baselDACSetVoltage(dac, [1 2 3], [0.1 -0.2 1.5]);
    %       v = baselDACQueryVoltage(dac, 5);
    %       baselDACRampVoltage(dac, [1 2], [1.0 -1.0], 200, 2e-3);
    %       baselDACSetStatus(dac, 1:24, 'ON');
    %
    %   IMPORTANT DIFFERENCES FROM THE ARDUINO sigDACs
    %   ----------------------------------------------
    %   1. All DAC channels power up switched OFF (output pulled to AGND
    %      through 1 MOhm). Writing a voltage to an OFF channel registers the
    %      value but produces no output. Call baselDACSetStatus(dac,ch,'ON').
    %   2. The device answers EVERY command with an error code / data string.
    %      That response must be read before the next command is sent
    %      (handshaking). This class always does a write/read pair.
    %   3. Voltages are sent as 24-bit HEX DAC codes, not as floats.
    %      1 LSB = 20 V / (2^24 - 1) = 1.192093 uV.
    %   4. The hardware RAMP generators (only four: RMP-A..D) update at a
    %      fixed 5 ms rate. Anything faster, or on more than four channels,
    %      has to be stepped from MATLAB - see baselDACRampVoltage (software,
    %      any number of channels) vs. baselDACRamp (hardware, one channel).
    %   5. Over RS-232 the receive buffer is 128 bytes, so multiple-SET
    %      strings are chunked to 125 characters. Over Telnet there is no such
    %      limit and updates are much faster - use Ethernet if you can.
    %
    %   Command reference: LNHR DAC IIa Programmer's Manual, Rev. 2.1a
    %                      (software release 3.5.xy)

    properties
        numChannels {mustBeNumeric}     % 12 or 24
        identifier                      % response to "IDN?"
        comPort                         % COM port name or IP address
        client                          % serialport or tcpclient object
        name                            % variable name in base workspace
        channelVoltages                 % 1 x numChannels cached voltages [V]
        channelStatus                   % 1 x numChannels cellstr 'ON'/'OFF'
        channelBW                       % 1 x numChannels cellstr 'LBW'/'HBW'
        connectionType                  % 'serial' or 'tcpip'
        verbose = false                 % echo every command to the console
    end

    properties (Constant, Access = private)
        LSBperVolt   = 838860.74        % DACval = (V + 10) * LSBperVolt
        VLIM         = 10               % +/- 10 V output range
        MAXSERIALCMD = 125              % RS-232 receive buffer safety limit
        CTRLWAIT     = 0.2              % s, settling time after CONTROL cmds
        RAMPTICK     = 5e-3             % s, hardware ramp generator period
    end

    methods
        % ================================================================
        %  CONSTRUCTOR / DESTRUCTOR
        % ================================================================
        function obj = baselDAC(port, numChannels, name, opts)
            % BASELDAC  Open a connection to an LNHR DAC IIa.
            %   port        - 'COM3' etc. for RS-232, or '192.168.0.5' for Telnet
            %   numChannels - 12 or 24 (default 24)
            %   name        - name of the variable in the base workspace
            %
            %   Name-value options:
            %     'BaudRate'   (default 115200) must match the device menu
            %     'TcpPort'    (default 23)
            %     'Timeout'    (default 5 s)
            %     'Connection' 'auto' | 'serial' | 'tcpip'
            %     'Verbose'    (default false)

            arguments
                port                (1,:) char
                numChannels         (1,1) {mustBeMember(numChannels,[12 24])} = 24
                name                (1,:) char = 'baselDAC'
                opts.BaudRate       (1,1) double = 115200
                opts.TcpPort        (1,1) double = 23
                opts.Timeout        (1,1) double = 5
                opts.Connection     (1,:) char {mustBeMember(opts.Connection,{'auto','serial','tcpip'})} = 'auto'
                opts.Verbose        (1,1) logical = false
            end

            obj.comPort     = port;
            obj.name        = name;
            obj.numChannels = numChannels;
            obj.verbose     = opts.Verbose;

            % --- decide serial vs. Ethernet -----------------------------
            isDottedQuad = ~isempty(regexp(port, '^\s*\d{1,3}(\.\d{1,3}){3}\s*$', 'once'));
            if strcmp(opts.Connection, 'auto')
                if isDottedQuad
                    obj.connectionType = 'tcpip';
                else
                    obj.connectionType = 'serial';
                end
            else
                obj.connectionType = opts.Connection;
            end

            % The device LCD shows the address zero-padded (192.168.000.005).
            % MATLAB's resolver will not parse leading-zero octets as an IP
            % address and falls through to a DNS lookup, so strip them.
            if strcmp(obj.connectionType, 'tcpip') && isDottedQuad
                octets = strsplit(strtrim(port), '.');
                octets = cellfun(@(o) sprintf('%d', str2double(o)), octets, ...
                    'UniformOutput', false);
                port = strjoin(octets, '.');
                obj.comPort = port;
            end

            % --- open the link ------------------------------------------
            switch obj.connectionType
                case 'serial'
                    % 8 data bits, 1 stop bit, no parity, XON/XOFF (manual 3.1)
                    obj.client = serialport(port, opts.BaudRate, ...
                        'DataBits', 8, 'StopBits', 1, 'Parity', 'none', ...
                        'FlowControl', 'software', 'Timeout', opts.Timeout);
                    % device expects <LF> in, answers with <CR+LF>
                    configureTerminator(obj.client, "CR/LF", "LF");
                case 'tcpip'
                    try
                        obj.client = tcpclient(port, opts.TcpPort, 'Timeout', opts.Timeout);
                    catch ME
                        error('baselDAC:noConnection', ...
                            ['Could not open a Telnet connection to %s:%d.\n' ...
                             '  - Give the address without leading zeros: 192.168.0.5\n' ...
                             '  - The host NIC must be on the same subnet, e.g. static\n' ...
                             '    IP 192.168.0.1 with mask 255.255.255.0 (not DHCP).\n' ...
                             '  - Disable IPv6 on that adapter.\n' ...
                             '  - Use the LEFT Gigabit Ethernet socket on the DAC.\n' ...
                             '  - Check the address on the LCD under "TCP/IP Settings".\n' ...
                             'Original error: %s'], port, opts.TcpPort, ME.message);
                    end
                    configureTerminator(obj.client, "CR/LF");
            end
            pause(0.5);
            flush(obj.client);

            % --- identify and read back the current state ---------------
            obj.identifier = obj.rawQuery('IDN?');
            fprintf('Connected: %s\n', obj.identifier);

            obj.channelVoltages = zeros(1, obj.numChannels);
            obj.channelStatus   = repmat({'OFF'}, 1, obj.numChannels);
            obj.channelBW       = repmat({'LBW'}, 1, obj.numChannels);
            baselDACGetConfig(obj);
        end

        function delete(obj)
            % Called automatically by clear/close - releases the port.
            try
                if ~isempty(obj.client)
                    flush(obj.client);
                end
            catch
            end
            obj.client = [];
        end

        function baselDACClose(obj)
            % BASELDACCLOSE  Explicitly release the port.
            delete(obj);
        end

        % ================================================================
        %  MAIN DAC METHODS  (voltage set / query)
        % ================================================================
        function baselDACSetVoltage(obj, channels, voltages)
            % BASELDACSETVOLTAGE  Set one or more channels immediately.
            %   channels - vector of DAC channels (1...numChannels)
            %   voltages - matching vector of voltages [V], or a scalar
            %
            %   All channels are packed into one multiple-SET string, so the
            %   time skew across 24 channels is ~3.6 ms rather than ~24 ms.
            %
            %   NOTE: this only produces an output on channels whose status
            %   is ON - see baselDACSetStatus.

            [channels, voltages] = obj.checkChannelsVoltages(channels, voltages);

            cmds = cell(1, numel(channels));
            for i = 1:numel(channels)
                cmds{i} = sprintf('%d %s', channels(i), baselDAC.volt2hex(voltages(i)));
            end
            obj.sendMultipleSet(cmds);

            obj.channelVoltages(channels) = voltages;
            obj.syncBaseWorkspace('channelVoltages');
        end

        function voltage = baselDACQueryVoltage(obj, channel)
            % BASELDACQUERYVOLTAGE  Read back the actual voltage on a channel.
            %   Uses "n V?" (value currently loaded into the DAC). For the
            %   registered-but-not-yet-applied value in synchronous mode use
            %   baselDACQueryRegisteredVoltage.

            obj.checkChannel(channel);
            resp = obj.rawQuery(sprintf('%d V?', channel));
            voltage = baselDAC.hex2volt(resp);
            obj.channelVoltages(channel) = voltage;
            obj.syncBaseWorkspace('channelVoltages');
        end

        function voltage = baselDACQueryRegisteredVoltage(obj, channel)
            % BASELDACQUERYREGISTEREDVOLTAGE  Read the registered DAC value
            %   (the one waiting for a SYNC event in synchronous mode).
            obj.checkChannel(channel);
            resp = obj.rawQuery(sprintf('%d VR?', channel));
            voltage = baselDAC.hex2volt(resp);
        end

        function baselDACSetChannels(obj, voltage)
            % BASELDACSETCHANNELS  Set every channel to the same voltage.
            %   Uses the device's "ALL" command - a single transaction.
            obj.sendSet(sprintf('ALL %s', baselDAC.volt2hex(voltage)));
            obj.channelVoltages(:) = voltage;
            obj.syncBaseWorkspace('channelVoltages');
        end

        function voltageArr = baselDACGetConfig(obj)
            % BASELDACGETCONFIG  Refresh the cached voltages, status and
            %   bandwidth for every channel (three queries total).

            % Voltages
            resp = obj.rawQuery('ALL V?');
            hexVals = baselDAC.splitList(resp);
            n = min(numel(hexVals), obj.numChannels);
            for i = 1:n
                obj.channelVoltages(i) = baselDAC.hex2volt(hexVals{i});
            end

            % Status
            resp = obj.rawQuery('ALL S?');
            vals = baselDAC.splitList(resp);
            n = min(numel(vals), obj.numChannels);
            obj.channelStatus(1:n) = upper(vals(1:n));

            % Bandwidth
            resp = obj.rawQuery('ALL BW?');
            vals = baselDAC.splitList(resp);
            n = min(numel(vals), obj.numChannels);
            obj.channelBW(1:n) = upper(vals(1:n));

            voltageArr = obj.channelVoltages;
            obj.syncBaseWorkspace('channelVoltages');
            obj.syncBaseWorkspace('channelStatus');
            obj.syncBaseWorkspace('channelBW');
        end

        function baselDACPrintConfig(obj)
            % BASELDACPRINTCONFIG  Pretty-print the cached channel state.
            baselDACGetConfig(obj);
            fprintf('\n%s (%s)\n', obj.name, obj.comPort);
            fprintf(' CH   Voltage [V]   Status   BW\n');
            fprintf('----------------------------------\n');
            for i = 1:obj.numChannels
                fprintf(' %2d   %+10.6f    %-6s   %s\n', i, ...
                    obj.channelVoltages(i), obj.channelStatus{i}, obj.channelBW{i});
            end
            fprintf('\n');
        end

        % ================================================================
        %  STATUS / BANDWIDTH / MODE
        % ================================================================
        function baselDACSetStatus(obj, channels, status)
            % BASELDACSETSTATUS  Switch channel outputs ON or OFF.
            %   OFF pulls the output to AGND via 1 MOhm || 22 nF and turns
            %   off the front-panel LED.
            %
            %   baselDACSetStatus(dac, 1:24, 'ON')

            status = upper(status);
            if ~ismember(status, {'ON','OFF'})
                error('baselDAC:badStatus', 'Status must be ''ON'' or ''OFF''.');
            end

            if ischar(channels) && strcmpi(channels, 'ALL')
                obj.sendSet(sprintf('ALL %s', status));
                obj.channelStatus(:) = {status};
            else
                obj.checkChannel(channels);
                cmds = arrayfun(@(c) sprintf('%d %s', c, status), channels, ...
                    'UniformOutput', false);
                obj.sendMultipleSet(cmds);
                obj.channelStatus(channels) = {status};
            end
            obj.syncBaseWorkspace('channelStatus');
        end

        function status = baselDACQueryStatus(obj, channel)
            % BASELDACQUERYSTATUS  Read a channel's ON/OFF status.
            obj.checkChannel(channel);
            status = upper(obj.rawQuery(sprintf('%d S?', channel)));
            obj.channelStatus{channel} = status;
        end

        function baselDACSetBandwidth(obj, channels, bw)
            % BASELDACSETBANDWIDTH  Select LBW (100 Hz) or HBW (100 kHz).
            %
            %   The manual warns that switching bandwidth on a live channel
            %   produces a glitch, so this method switches the channel OFF,
            %   changes the bandwidth, then restores the previous status.

            bw = upper(bw);
            if ~ismember(bw, {'LBW','HBW'})
                error('baselDAC:badBW', 'Bandwidth must be ''LBW'' or ''HBW''.');
            end
            obj.checkChannel(channels);

            wasOn = strcmpi(obj.channelStatus(channels), 'ON');

            % Switch off first to prevent glitch voltages
            if any(wasOn)
                baselDACSetStatus(obj, channels(wasOn), 'OFF');
            end

            cmds = arrayfun(@(c) sprintf('%d %s', c, bw), channels, ...
                'UniformOutput', false);
            obj.sendMultipleSet(cmds);
            obj.channelBW(channels) = {bw};

            if any(wasOn)
                baselDACSetStatus(obj, channels(wasOn), 'ON');
            end
            obj.syncBaseWorkspace('channelBW');
        end

        function mode = baselDACQueryMode(obj, channel)
            % BASELDACQUERYMODE  Read the channel mode.
            %   'DAC' transparent, 'SYN' synchronous, 'RMP' ramp generator
            %   running, 'AWG' AWG running, 'ERR' fault, '---' unavailable.
            %   Writing is refused (error 5) in RMP / AWG / --- modes.
            obj.checkChannel(channel);
            mode = obj.rawQuery(sprintf('%d M?', channel));
        end

        function baselDACInit(obj, opts)
            % BASELDACINIT  Bring the DAC to a known state.
            %   By default: stop all ramps and AWGs, set every channel to
            %   0 V, select low bandwidth, and switch all outputs ON.
            %
            %   baselDACInit(dac, 'Status','OFF', 'Bandwidth','HBW')

            arguments
                obj
                opts.Voltage   (1,1) double = 0
                opts.Bandwidth (1,:) char {mustBeMember(opts.Bandwidth,{'LBW','HBW'})} = 'LBW'
                opts.Status    (1,:) char {mustBeMember(opts.Status,{'ON','OFF'})} = 'ON'
            end

            obj.sendControl('RMP-ALL STOP');
            obj.sendControl('AWG-ALL STOP');

            obj.sendSet('ALL OFF');                       % safe before BW switch
            obj.sendSet(sprintf('ALL %s', opts.Bandwidth));
            obj.sendSet(sprintf('ALL %s', baselDAC.volt2hex(opts.Voltage)));
            obj.sendSet(sprintf('ALL %s', opts.Status));

            baselDACGetConfig(obj);
            fprintf('%s initialised: all channels %+.6f V, %s, %s\n', ...
                obj.name, opts.Voltage, opts.Bandwidth, opts.Status);
        end

        % ================================================================
        %  RAMPING
        % ================================================================
        function baselDACRampVoltage(obj, channels, voltages, numSteps, dwellSec)
            % BASELDACRAMPVOLTAGE  Software-stepped ramp on any set of channels.
            %
            %   Equivalent in spirit to sigDACRampVoltage. Steps are generated
            %   in MATLAB and pushed as multiple-SET strings, starting from
            %   the currently cached voltages.
            %
            %   channels  - vector of DAC channels
            %   voltages  - matching vector of target voltages [V]
            %   numSteps  - number of intermediate steps (default 100)
            %   dwellSec  - extra pause after each step (default 0)
            %
            %   Throughput is limited by the handshake: expect ~1 ms per step
            %   over Telnet and rather more over RS-232. For a smooth, jitter-
            %   free ramp on a single channel use baselDACRamp (hardware).

            if nargin < 4 || isempty(numSteps), numSteps = 100; end
            if nargin < 5 || isempty(dwellSec), dwellSec = 0;   end

            [channels, voltages] = obj.checkChannelsVoltages(channels, voltages);
            vStart = obj.channelVoltages(channels);

            for s = 1:numSteps
                vNow = vStart + (voltages(:).' - vStart) * (s / numSteps);
                cmds = cell(1, numel(channels));
                for i = 1:numel(channels)
                    cmds{i} = sprintf('%d %s', channels(i), baselDAC.volt2hex(vNow(i)));
                end
                obj.sendMultipleSet(cmds);
                if dwellSec > 0, pause(dwellSec); end
            end

            obj.channelVoltages(channels) = voltages;
            obj.syncBaseWorkspace('channelVoltages');
        end

        function baselDACRamp(obj, channel, voltage, rampTime, opts)
            % BASELDACRAMP  Hardware ramp on one channel using RMP-A...D.
            %
            %   channel  - DAC channel (1...24)
            %   voltage  - target (stop) voltage [V]
            %   rampTime - ramp duration [s], 0.05 ... 1e6, resolution 5 ms
            %
            %   Options:
            %     'Generator' 'A'|'B'|'C'|'D'   (default 'A')
            %     'StartVoltage'               (default: present voltage)
            %     'Shape'  0 = up-only (sawtooth), 1 = up-down (triangle)
            %     'Cycles' number of cycles, 0 = infinite (default 1)
            %     'Wait'   block until the generator returns to idle (default true)
            %
            %   While the ramp runs the channel reports mode 'RMP' and any
            %   SET command to it is refused with error code 5.

            arguments
                obj
                channel  (1,1) {mustBeInteger, mustBePositive}
                voltage  (1,1) double
                rampTime (1,1) double {mustBePositive}
                opts.Generator    (1,1) char {mustBeMember(opts.Generator,{'A','B','C','D'})} = 'A'
                opts.StartVoltage double = []
                opts.Shape        (1,1) double {mustBeMember(opts.Shape,[0 1])} = 0
                opts.Cycles       (1,1) double = 1
                opts.Wait         (1,1) logical = true
            end

            obj.checkChannel(channel);
            if rampTime < 0.05 || rampTime > 1e6
                error('baselDAC:rampTime', ...
                    'Ramp time must be between 0.05 s and 1e6 s (5 ms resolution).');
            end
            if abs(voltage) > obj.VLIM
                error('baselDAC:vRange', 'Voltage must be within +/-10 V.');
            end

            gen = ['RMP-' opts.Generator];

            if isempty(opts.StartVoltage)
                vStart = baselDACQueryVoltage(obj, channel);
            else
                vStart = opts.StartVoltage;
            end

            obj.sendControl(sprintf('%s CH %d',      gen, channel));

            avail = str2double(obj.rawQuery(sprintf('C %s AVA?', gen)));
            if avail ~= 1
                error('baselDAC:rampBusy', ...
                    'DAC channel %d is not available for %s (in use by another RAMP/AWG).', ...
                    channel, gen);
            end

            obj.sendControl(sprintf('%s STEP 0',     gen));            % ramp, not step
            obj.sendControl(sprintf('%s STAV %.6f',  gen, vStart));
            obj.sendControl(sprintf('%s STOV %.6f',  gen, voltage));
            obj.sendControl(sprintf('%s RS %d',      gen, opts.Shape));
            obj.sendControl(sprintf('%s CS %d',      gen, opts.Cycles));
            obj.sendControl(sprintf('%s RT %.6f',    gen, rampTime));
            obj.sendControl(sprintf('%s START',      gen));

            if opts.Wait && opts.Cycles > 0
                t0 = tic;
                timeout = rampTime * opts.Cycles * (1 + opts.Shape) + 2;
                pause(min(rampTime, 0.05));
                while toc(t0) < timeout
                    state = str2double(obj.rawQuery(sprintf('C %s S?', gen)));
                    if state == 0, break; end       % 0 = idle
                    pause(0.05);
                end
                if opts.Shape == 0
                    obj.channelVoltages(channel) = voltage;
                else
                    obj.channelVoltages(channel) = vStart;
                end
                obj.syncBaseWorkspace('channelVoltages');
            end
        end

        function baselDACStopRamps(obj, generator)
            % BASELDACSTOPRAMPS  Stop one or all ramp/step generators.
            if nargin < 2 || isempty(generator)
                obj.sendControl('RMP-ALL STOP');
            else
                obj.sendControl(sprintf('RMP-%s STOP', upper(generator)));
            end
        end

        function state = baselDACRampState(obj, generator)
            % BASELDACRAMPSTATE  0 = idle, 1 = ramp up, 2 = ramp down, 3 = hold.
            state = str2double(obj.rawQuery(sprintf('C RMP-%s S?', upper(generator))));
        end

        % ================================================================
        %  SYNCHRONOUS UPDATE
        % ================================================================
        function baselDACSetUpdateMode(obj, board, mode)
            % BASELDACSETUPDATEMODE  0 = instant (transparent), 1 = synchronous.
            %   board - 'L' (channels 1-12), 'H' (13-24)
            %
            %   In synchronous mode written values are only registered; they
            %   reach the outputs on the next baselDACSync call. Wait at least
            %   200 ms after switching before the first sync.
            board = upper(board);
            if ~ismember(board, {'L','H'})
                error('baselDAC:badBoard', 'Board must be ''L'' or ''H''.');
            end
            obj.sendControl(sprintf('UM-%s %d', board, mode));
        end

        function baselDACSync(obj, board)
            % BASELDACSYNC  Trigger a synchronous update.
            %   board - 'L', 'H' or 'LH' (default 'LH')
            if nargin < 2 || isempty(board), board = 'LH'; end
            obj.sendControl(sprintf('SYNC-%s', upper(board)));
        end

        % ================================================================
        %  TEST / DIAGNOSTICS
        % ================================================================
        function baselDACTestVolts(obj)
            % Set all 24 channels to channel_number * 0.1 V
            for i = 1:24
                targetVoltage = i * 0.01;
                baselDACSetVoltage(obj,i,targetVoltage);
            end
        end

        function pass = baselDACTest(obj, opts)
            % BASELDACTEST  Walk every channel to channel_number * 0.1 V and
            %   verify the readback, in the spirit of sigDACTest.
            %
            %   *** THIS DRIVES REAL VOLTAGES ONTO THE OUTPUTS ***
            %   Channel 24 reaches +2.4 V. Disconnect the DAC from the sample
            %   or fridge wiring before running it. The method asks for
            %   confirmation unless you pass 'Confirm', false.
            %
            %   Options:
            %     'Voltage'   per-channel step, default 0.1 V
            %     'Channels'  which channels to test, default all
            %     'Tolerance' readback tolerance [V], default 1e-5
            %     'TestRamp'  also exercise a hardware ramp, default false
            %     'Restore'   restore the pre-test state afterwards, default true
            %     'Confirm'   prompt before driving outputs, default true

            arguments
                obj
                opts.Voltage   (1,1) double = 0.1
                opts.Channels  double = []
                opts.Tolerance (1,1) double = 1e-5
                opts.TestRamp  (1,1) logical = false
                opts.Restore   (1,1) logical = true
                opts.Confirm   (1,1) logical = true
            end

            if isempty(opts.Channels)
                chans = 1:obj.numChannels;
            else
                chans = opts.Channels(:).';
                obj.checkChannel(chans);
            end

            vTargets = chans * opts.Voltage;
            if any(abs(vTargets) > obj.VLIM)
                error('baselDAC:testRange', ...
                    'Test would exceed +/-10 V on channel %d. Reduce ''Voltage''.', ...
                    chans(find(abs(vTargets) > obj.VLIM, 1)));
            end

            if opts.Confirm
                fprintf(['\nThis test will switch channels ON and drive up to %+.3f V.\n' ...
                         'Make sure the outputs are disconnected from the sample.\n'], ...
                         max(abs(vTargets)));
                go = input('Proceed? (y/n) ', 's');
                if ~strcmpi(strtrim(go), 'y')
                    fprintf('Test aborted.\n');
                    pass = false;
                    return
                end
            end

            % --- record the state we are about to disturb ----------------
            baselDACGetConfig(obj);
            v0      = obj.channelVoltages;
            status0 = obj.channelStatus;

            results = struct('name', {}, 'pass', {}, 'detail', {});
            addResult = @(n, p, d) struct('name', n, 'pass', p, 'detail', d);

            fprintf('\n=== baselDAC self-test: %s ===\n', obj.name);

            % --- 1. conversion arithmetic (no hardware involved) ---------
            [ok, detail] = baselDAC.conversionTest();
            results(end+1) = addResult('Voltage/HEX conversion', ok, detail);

            % --- 2. communication ---------------------------------------
            try
                idn = obj.rawQuery('IDN?');
                results(end+1) = addResult('IDN? handshake', true, idn);
            catch ME
                results(end+1) = addResult('IDN? handshake', false, ME.message);
                obj.reportResults(results);
                pass = false;
                return
            end

            % --- 3. device health ---------------------------------------
            try
                health = obj.rawQueryMultiline('HEALTH?');
                bad = contains(health, 'FAIL', 'IgnoreCase', true) || ...
                      contains(health, 'ERR',  'IgnoreCase', true);
                results(end+1) = addResult('HEALTH? report', ~bad, ...
                    regexprep(health, '\s*\n\s*', ' | '));
            catch ME
                results(end+1) = addResult('HEALTH? report', false, ME.message);
            end

            % --- 4. per-channel set and readback ------------------------
            fprintf('\nRamping %d channels to (channel * %.3f) V...\n', ...
                numel(chans), opts.Voltage);
            baselDACSetVoltage(obj, chans, 0);
            baselDACSetStatus(obj, chans, 'ON');

            errsV  = zeros(1, numel(chans));
            chanOK = false(1, numel(chans));
            for k = 1:numel(chans)
                ch = chans(k);
                baselDACRampVoltage(obj, ch, vTargets(k), 10);
                vRead     = baselDACQueryVoltage(obj, ch);
                errsV(k)  = vRead - vTargets(k);
                chanOK(k) = abs(errsV(k)) <= opts.Tolerance;
                if chanOK(k), tag = 'ok'; else, tag = '<-- FAIL'; end
                fprintf('  CH %2d: set %+8.6f V, read %+8.6f V, err %+9.2e V   %s\n', ...
                    ch, vTargets(k), vRead, errsV(k), tag);
            end
            results(end+1) = addResult('Per-channel set/readback', all(chanOK), ...
                sprintf('%d/%d channels within %.1e V (max err %.2e V)', ...
                sum(chanOK), numel(chans), opts.Tolerance, max(abs(errsV))));

            % --- 5. multiple-SET throughput -----------------------------
            try
                t0 = tic;
                baselDACSetVoltage(obj, chans, zeros(1, numel(chans)));
                dt = toc(t0);
                vAll  = baselDACGetConfig(obj);
                allOK = all(abs(vAll(chans)) <= opts.Tolerance);
                results(end+1) = addResult('Multiple-SET (all channels to 0 V)', allOK, ...
                    sprintf('%.1f ms for %d channels over %s', ...
                    dt*1e3, numel(chans), obj.connectionType));
            catch ME
                results(end+1) = addResult('Multiple-SET', false, ME.message);
            end

            % --- 6. optional hardware ramp ------------------------------
            if opts.TestRamp
                ch = chans(1);
                try
                    t0 = tic;
                    baselDACRamp(obj, ch, 1.0, 1.0, 'Generator', 'A');
                    dt = toc(t0);
                    vRead = baselDACQueryVoltage(obj, ch);
                    rampOK = abs(vRead - 1.0) <= 1e-3;
                    results(end+1) = addResult('Hardware ramp RMP-A', rampOK, ...
                        sprintf('CH %d to +1 V in %.2f s (requested 1.0 s), read %+.6f V', ...
                        ch, dt, vRead));
                    baselDACRamp(obj, ch, 0, 1.0, 'Generator', 'A');
                catch ME
                    results(end+1) = addResult('Hardware ramp RMP-A', false, ME.message);
                end
            end

            % --- 7. restore ---------------------------------------------
            if opts.Restore
                baselDACRampVoltage(obj, chans, v0(chans), 20);
                for k = 1:numel(chans)
                    if strcmpi(status0{chans(k)}, 'OFF')
                        baselDACSetStatus(obj, chans(k), 'OFF');
                    end
                end
                fprintf('\nPre-test voltages and channel status restored.\n');
            else
                fprintf('\nOutputs left at 0 V and switched ON.\n');
            end

            pass = obj.reportResults(results);
        end
    end

    methods (Access = private)
        function pass = reportResults(~, results)
            fprintf('\n--- summary ---------------------------------------\n');
            for i = 1:numel(results)
                if results(i).pass, tag = 'PASS'; else, tag = 'FAIL'; end
                fprintf(' [%s] %-34s %s\n', tag, results(i).name, results(i).detail);
            end
            pass = all([results.pass]);
            if pass
                fprintf('--- all checks passed -----------------------------\n\n');
            else
                fprintf('--- %d check(s) FAILED ----------------------------\n\n', ...
                    sum(~[results.pass]));
            end
        end
    end

    methods
        % ================================================================
        %  DEVICE INFORMATION
        % ================================================================
        function info = baselDACHealth(obj)
            % BASELDACHEALTH  Temperatures, CPU load and power supply status.
            info = obj.rawQueryMultiline('HEALTH?');
            if nargout == 0, disp(info); clear info; end
        end

        function info = baselDACInfo(obj, what)
            % BASELDACINFO  Query an information string.
            %   what - 'IDN' (default), 'SOFT', 'HARD', 'IP', 'SERIAL', 'CONTACT'
            if nargin < 2 || isempty(what), what = 'IDN'; end
            info = obj.rawQueryMultiline([upper(what) '?']);
            if nargout == 0, disp(info); clear info; end
        end
    end

    % ====================================================================
    %  LOW-LEVEL COMMUNICATION
    % ====================================================================
    methods (Access = public)
        function resp = rawQuery(obj, cmd)
            % RAWQUERY  Send an arbitrary command and return one response line.
            flush(obj.client);
            if obj.verbose, fprintf('>> %s\n', cmd); end
            writeline(obj.client, cmd);
            resp = readline(obj.client);
            if ismissing(resp) || strlength(resp) == 0
                error('baselDAC:timeout', ...
                    'No response to "%s". Check baud rate / cabling / terminators.', cmd);
            end
            resp = strtrim(char(resp));
            if obj.verbose, fprintf('<< %s\n', resp); end
            if strcmp(resp, '?')
                error('baselDAC:unknownCommand', 'Device did not understand "%s".', cmd);
            end
        end

        function txt = rawQueryMultiline(obj, cmd)
            % RAWQUERYMULTILINE  For HELP?/HEALTH?/HARD? etc., which answer
            %   with several lines. Reads until the device goes quiet.
            flush(obj.client);
            writeline(obj.client, cmd);
            lines = {};
            t0 = tic;
            while toc(t0) < 2
                try
                    ln = readline(obj.client);
                catch
                    break
                end
                if ismissing(ln), break; end
                lines{end+1} = strtrim(char(ln)); %#ok<AGROW>
                t0 = tic;
                if obj.client.NumBytesAvailable == 0
                    pause(0.05);
                    if obj.client.NumBytesAvailable == 0, break; end
                end
            end
            txt = strjoin(lines, newline);
        end

        function sendSet(obj, cmd)
            % SENDSET  Send a single SET command and verify the error code.
            resp = obj.rawQuery(cmd);
            obj.checkErrorCodes(resp, cmd);
        end

        function sendControl(obj, cmd)
            % SENDCONTROL  Send a CONTROL command ("C " prefix added here).
            resp = obj.rawQuery(['C ' cmd]);
            obj.checkErrorCodes(resp, cmd);
            pause(obj.CTRLWAIT);   % manual: allow ~200 ms for internal update
        end

        function sendMultipleSet(obj, cmds)
            % SENDMULTIPLESET  Join SET commands with ';' and send them,
            %   chunking to 125 characters on RS-232 (128-byte input buffer).
            if isempty(cmds), return; end

            if strcmp(obj.connectionType, 'serial')
                maxLen = obj.MAXSERIALCMD;
            else
                maxLen = Inf;
            end
            maxCmds = 1000;    % device limit on a multiple-SET string

            chunk = {};
            chunkLen = 0;
            for i = 1:numel(cmds)
                addLen = numel(cmds{i}) + ~isempty(chunk);   % +1 for ';'
                if ~isempty(chunk) && (chunkLen + addLen > maxLen || numel(chunk) >= maxCmds)
                    obj.flushChunk(chunk);
                    chunk = {}; chunkLen = 0;
                    addLen = numel(cmds{i});
                end
                chunk{end+1} = cmds{i}; %#ok<AGROW>
                chunkLen = chunkLen + addLen;
            end
            obj.flushChunk(chunk);
        end
    end

    methods (Access = private)
        function flushChunk(obj, chunk)
            if isempty(chunk), return; end
            cmd  = strjoin(chunk, ';');
            resp = obj.rawQuery(cmd);
            obj.checkErrorCodes(resp, cmd);
        end

        function checkErrorCodes(obj, resp, cmd) %#ok<INUSL>
            codes = baselDAC.splitList(resp);
            bad = find(~strcmp(codes, '0'));
            if ~isempty(bad)
                msg = sprintf('Command "%s" returned error code(s):', cmd);
                for k = bad
                    msg = sprintf('%s\n  [%d] %s -> %s', msg, k, codes{k}, ...
                        baselDAC.errorText(codes{k}));
                end
                error('baselDAC:deviceError', '%s', msg);
            end
        end

        function checkChannel(obj, channels)
            if ~isnumeric(channels) || any(channels < 1) || ...
                    any(channels > obj.numChannels) || any(mod(channels,1) ~= 0)
                error('baselDAC:badChannel', ...
                    'DAC channel must be an integer between 1 and %d.', obj.numChannels);
            end
        end

        function [channels, voltages] = checkChannelsVoltages(obj, channels, voltages)
            obj.checkChannel(channels);
            channels = channels(:).';
            if isscalar(voltages)
                voltages = repmat(voltages, 1, numel(channels));
            end
            voltages = voltages(:).';
            if numel(channels) ~= numel(voltages)
                error('baselDAC:sizeMismatch', ...
                    'Number of channels (%d) and voltages (%d) must match.', ...
                    numel(channels), numel(voltages));
            end
            if any(abs(voltages) > obj.VLIM)
                error('baselDAC:vRange', 'Voltages must be within +/-10 V.');
            end
        end

        function syncBaseWorkspace(obj, prop)
            % Keeps a copy of the object handle's property visible in the
            % base workspace, the way sigDAC does with evalin. Harmless if
            % the variable does not exist (handle objects update anyway).
            if isempty(obj.name), return; end
            try
                if evalin('base', sprintf('exist(''%s'',''var'')', obj.name)) == 0
                    return
                end
                assignin('base', 'baselDAC_tmp_', obj.(prop));
                evalin('base', sprintf('%s.%s = baselDAC_tmp_; clear baselDAC_tmp_;', ...
                    obj.name, prop));
            catch
            end
        end
    end

    % ====================================================================
    %  STATIC HELPERS
    % ====================================================================
    methods (Static)
        function h = volt2hex(v)
            % VOLT2HEX  Voltage [-10,+10] V -> 6-character 24-bit HEX string.
            %   DACval = round((V + 10) * 838860.74),   0x7FFFFF = 0 V
            v = max(min(v, baselDAC.VLIM), -baselDAC.VLIM);
            d = round((v + baselDAC.VLIM) * baselDAC.LSBperVolt);
            d = max(min(d, 16777215), 0);
            h = upper(dec2hex(d, 6));
        end

        function v = hex2volt(h)
            % HEX2VOLT  6-character 24-bit HEX string -> voltage [V].
            h = strtrim(char(h));
            if isempty(h) || any(~isstrprop(h, 'xdigit'))
                v = NaN;
                return
            end
            v = hex2dec(h) / baselDAC.LSBperVolt - baselDAC.VLIM;
        end

        function parts = splitList(resp)
            % SPLITLIST  Split a semicolon-separated device response.
            parts = strtrim(strsplit(strtrim(char(resp)), ';'));
            parts = parts(~cellfun(@isempty, parts));
        end

        function [ok, detail] = conversionTest()
            % CONVERSIONTEST  Check volt2hex/hex2volt against the table in
            %   section 9 of the manual. Needs no hardware.
            table = { '+10', 10, 'FFFFFF'; '+5', 5, 'BFFFFF'; '+1', 1, '8CCCCC'; ...
                       '0',  0, '7FFFFF'; '-1', -1, '733333'; '-5', -5, '400000'; ...
                      '-10', -10, '000000' };
            bad = {};
            for i = 1:size(table, 1)
                h = baselDAC.volt2hex(table{i,2});
                if ~strcmpi(h, table{i,3})
                    bad{end+1} = sprintf('%s V -> %s (expected %s)', ...
                        table{i,1}, h, table{i,3}); %#ok<AGROW>
                end
            end
            % round-trip a sweep through the full range
            vTest = linspace(-10, 10, 501);
            vBack = arrayfun(@(v) baselDAC.hex2volt(baselDAC.volt2hex(v)), vTest);
            maxErr = max(abs(vBack - vTest));
            if maxErr > 1.2e-6      % must be within 1 LSB (1.192093 uV)
                bad{end+1} = sprintf('round-trip error %.2e V exceeds 1 LSB', maxErr);
            end

            ok = isempty(bad);
            if ok
                detail = sprintf('manual table matches, round-trip max err %.2e V', maxErr);
            else
                detail = strjoin(bad, '; ');
            end
        end

        function txt = errorText(code)
            % ERRORTEXT  Human-readable meaning of a device error code.
            switch char(code)
                case '0', txt = 'no error';
                case '1', txt = 'invalid DAC channel / memory / polynomial';
                case '2', txt = 'missing or invalid parameter';
                case '3', txt = 'value out of range';
                case '4', txt = 'mistyped command';
                case '5', txt = 'writing not allowed (RAMP or AWG running on this channel)';
                otherwise, txt = 'unrecognised response';
            end
        end
    end
end