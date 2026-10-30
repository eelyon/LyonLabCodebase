classdef QDAC < handle
    %QDAC  Interface class for the Quantum Machines (QDevil) QDAC-II Compact.
    %
    %   Refactor of the lab's original QDAC class. All public method names of
    %   the original class are kept, so setDACVolts, rampDACVolts and the DAC
    %   GUI continue to work. New functionality follows the same naming style.
    %
    %   CONNECTING
    %       qdac = QDAC('192.168.8.197', 24, 'qdac');               % Ethernet, port 5025
    %       qdac = QDAC('192.168.8.197', 24, 'qdac', 'SlewRate', 1); % + 1 V/s DC slew limit
    %       qdac = QDAC('COM5', 24, 'qdac');                        % USB-serial, 921600 Bd
    %
    %   DC OUTPUTS
    %       QDACSetVoltage(qdac, [1 2 3], [0.1 -0.2 0.5]);  % FIXed mode, immediate
    %       v = QDACGetVoltage(qdac, 1:24);                  % numeric, caller order
    %       QDACRampVoltage(qdac, [1 2], [1 -1], 200, 1e-3, 'Wait', true);
    %       QDACSmoothRampVoltage(qdac, 3, 0.5, 2.0);        % analog ramp, 2 s
    %       QDACSetSlewRate(qdac, 1:24, 1);                  % 1 V/s hardware limit
    %
    %   CURRENT SENSING
    %       I = QDACReadCurrent(qdac, 1:8);                  % [A]
    %       R = QDACLeakageMatrix(qdac, 1:8, 0.01);          % gate-to-gate leakage [Ohm]
    %
    %   ARBITRARY WAVEFORM GENERATOR (one per channel, 1 MS/s, traces in [-1,1])
    %       QDACUploadTrace(qdac, 'pulse', y);               % defines + uploads
    %       QDACAWGSetup(qdac, [5 6], 'pulse', 'Scale', 0.2, 'Count', 10);
    %       QDACAWGStart(qdac, [5 6]);                       % synchronised start
    %       QDACAWGWait(qdac, [5 6]);
    %
    %   DIAGNOSTICS
    %       QDACSetMonitor(qdac, 7);                         % front-panel monitor SMA -> ch 7
    %       T = QDACMonitorScan(qdac, 1:24, 'Dwell', 0.5);   % step monitor through channels
    %       D = QDACDiagnostics(qdac);                       % state snapshot + error queue
    %
    %   SAFETY NOTES (QDAC-II Compact operation manual / command reference)
    %   ----------------------------------------------------------------
    %   1. With FILTer = DC (25-bit resolution enhancement) only the DC
    %      generator in FIXed mode works: no SWEep, no LIST, no waveform
    %      generators, and the slew rate is clamped to >= 40 V/s. Ramps on
    %      such channels are therefore stepped from MATLAB (software ramp).
    %   2. Do not change the voltage RANGe at non-zero output. This class
    %      refuses to, and re-writes 0 V after a range change (manual 2024-10).
    %   3. A finite DC slew rate is a safety net, not a replacement for
    %      SWEep: an ABORt stops a sweep but NOT a slew-limited transition.
    %   4. All five generators of a channel (DC, sine, square, triangle, AWG)
    %      are summed. Exceeding the range clips silently; QDACAWGSetup warns
    %      when the expected peak exceeds the range.
    %   5. *RST returns all outputs to 0 V in one step. qDACReset ramps to
    %      0 V first unless 'Force' is given.
    %
    %   References: QDAC-II Compact Command Reference v1.2 (2025),
    %               QDAC-II Compact Operation Manual (2024-10-28).

    % =====================================================================
    %  PROPERTIES
    % =====================================================================
    properties
        IPAddress                       % IP address (Ethernet) or '' for serial
        comPort                         % COM port (serial) or '' for Ethernet
        connectionType                  % 'tcpip' | 'serial'
        client                          % tcpclient or serialport object
        name                            % variable name in the base workspace (GUI)
        identifier                      % *IDN? response
        numChannels {mustBeNumeric}     % 24 on the QDAC-II Compact
        channelVoltages                 % 1 x N cached DC targets [V] (read by the GUI)
        channelRange                    % 1 x N cellstr 'LOW' (+/-2 V) | 'HIGH' (+/-10 V)
        channelFilter                   % 1 x N cellstr 'DC' | 'MED' | 'HIGH'
        channelCurrentRange             % 1 x N cellstr 'LOW' (200 nA) | 'HIGH' (10 mA)
        channelSlew                     % 1 x N cached DC slew rates [V/s] (Inf = none)
        rangeLimits                     % struct: .LOW, .HIGH = 2 x N [min; max] in V
        monitorChannel = 0              % channel routed to the monitor SMA (0 = none)
        syncTrigger    = 14             % internal trigger reserved for synchronised starts
        autoCheckErrors = true          % query SYST:ERR:ALL? after each high-level call
        verbose        = false          % echo every SCPI line to the console
        settleTolerance = 1e-4          % [V] |readback - target| accepted as settled
        batchWrites    = true           % coalesce consecutive writes into one TCP send
    end

    properties (SetAccess = private)
        scpiLog = {}                    % last SCPI_LOG_LENGTH commands (debugging)
    end

    properties (Access = private)
        pendingWrites = {}              % writes queued while batching
        batchDepth    = 0               % > 0 while inside a batch scope
        traceSizes                      % containers.Map: trace name -> points
        traceMaxAbs                     % containers.Map: trace name -> max|y|
    end

    properties (Constant)
        SAMPLE_PERIOD       = 1e-6      % [s] generator sample interval (1 MS/s)
        MIN_DWELL           = 2e-6      % [s] minimum SWEep/LIST dwell
        MAX_DWELL           = 36000     % [s]
        MIN_SLEW            = 0.01      % [V/s]
        MAX_SLEW            = 2e7       % [V/s] (= INF)
        DC_FILTER_MIN_SLEW  = 40        % [V/s] clamp when FILTer = DC
        MAX_SWEEP_POINTS    = 2097152
        MAX_TRACE_POINTS    = 6291456
        MAX_TRACES          = 24
        MAX_TRACE_NAME      = 15        % characters
        N_INTERNAL_TRIGGERS = 14
        N_TRIGGER_OUTPUTS   = 5
        SENSE_SAMPLE        = 1/3000    % [s] current-sensor ADC sample interval
        SOFT_RAMP_DWELL     = 5e-3      % [s] step period of MATLAB-stepped ramps
        SCPI_LOG_LENGTH     = 50
        SERIAL_BAUD         = 921600
    end

    % =====================================================================
    %  CONSTRUCTOR / DESTRUCTOR
    % =====================================================================
    methods
        function obj = QDAC(address, numChannels, name, opts)
            % QDAC  Open a connection to a QDAC-II Compact and read its state.
            %   address      dotted IPv4 address ('192.168.8.197') or COM port
            %   numChannels  number of channels (default 24)
            %   name         variable name in the base workspace (default 'qdac')
            %
            %   Name-value options
            %     'TcpPort'         5025 (SCPI socket)
            %     'Timeout'         10 s
            %     'Connection'      'auto' | 'tcpip' | 'serial'
            %     'SlewRate'        [] (leave as is) or V/s applied to all channels
            %     'AutoCheckErrors' true
            %     'Verbose'         false
            arguments
                address             (1,:) char
                numChannels         (1,1) double {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(numChannels, 24)} = 24
                name                (1,:) char = 'qdac'
                opts.TcpPort        (1,1) double = 5025
                opts.Timeout        (1,1) double {mustBePositive} = 10
                opts.Connection     (1,:) char {mustBeMember(opts.Connection, {'auto','tcpip','serial'})} = 'auto'
                opts.SlewRate       double = []
                opts.AutoCheckErrors (1,1) logical = true
                opts.Verbose        (1,1) logical = false
            end

            obj.name            = name;
            obj.numChannels     = numChannels;
            obj.verbose         = opts.Verbose;
            obj.autoCheckErrors = opts.AutoCheckErrors;
            obj.traceSizes      = containers.Map('KeyType', 'char', 'ValueType', 'double');
            obj.traceMaxAbs     = containers.Map('KeyType', 'char', 'ValueType', 'double');

            % --- serial vs. Ethernet -------------------------------------
            isDottedQuad = ~isempty(regexp(address, '^\s*\d{1,3}(\.\d{1,3}){3}\s*$', 'once'));
            if strcmp(opts.Connection, 'auto')
                if isDottedQuad, obj.connectionType = 'tcpip'; else, obj.connectionType = 'serial'; end
            else
                obj.connectionType = opts.Connection;
            end

            switch obj.connectionType
                case 'tcpip'
                    % Strip zero-padded octets (192.168.008.197 -> 192.168.8.197),
                    % otherwise MATLAB attempts a DNS lookup.
                    octets = strsplit(strtrim(address), '.');
                    address = strjoin(cellfun(@(o) sprintf('%d', str2double(o)), ...
                        octets, 'UniformOutput', false), '.');
                    obj.IPAddress = address;
                    obj.comPort   = '';
                    try
                        obj.client = tcpclient(address, opts.TcpPort, 'Timeout', opts.Timeout);
                    catch ME
                        error('QDAC:noConnection', ...
                            ['Could not open %s:%d.\n  - Check the address shown by ' ...
                             'SYST:COMM:LAN:IPAD? over USB.\n  - Port must be 5025.\n' ...
                             '  - Plug Ethernet in before power-up for DHCP.\n' ...
                             'Original error: %s'], address, opts.TcpPort, ME.message);
                    end
                case 'serial'
                    obj.IPAddress = '';
                    obj.comPort   = address;
                    obj.client    = serialport(address, QDAC.SERIAL_BAUD, 'Timeout', opts.Timeout);
            end
            % Commands end in LF; responses (except binary blocks) end in LF.
            configureTerminator(obj.client, "LF");
            pause(0.2);
            flush(obj.client, "input");

            % --- identify ------------------------------------------------
            obj.identifier = obj.scpiQuery('*IDN?');
            fprintf('Connected: %s\n', obj.identifier);
            if ~contains(upper(obj.identifier), 'QDAC-II')
                warning('QDAC:unexpectedModel', ...
                    'Unexpected *IDN? response "%s". Is this a QDAC-II?', obj.identifier);
            end

            % Stale errors from a previous session are reported, not thrown.
            stale = obj.scpiQuery('SYST:ERR:ALL?');
            if QDAC.errorCode(stale) ~= 0
                warning('QDAC:staleErrors', 'Error queue at connect (now cleared): %s', stale);
            end

            % --- read back state -----------------------------------------
            QDACRefresh(obj);
            if ~isempty(opts.SlewRate)
                QDACSetSlewRate(obj, 1:obj.numChannels, opts.SlewRate);
            end
            obj.finish('QDAC constructor');
        end

        function delete(obj)
            % DELETE  Release the socket / serial port (called by clear).
            try
                if ~isempty(obj.client), flush(obj.client, "input"); end
            catch
            end
            obj.client = [];
        end

        function QDACClose(obj)
            % QDACCLOSE  Explicitly release the connection.
            delete(obj);
        end

        function QDACRefresh(obj)
            % QDACREFRESH  Re-read voltages, ranges, filters, limits and
            %   monitor routing from the instrument into the cached properties.
            ch = 1:obj.numChannels;
            obj.channelVoltages     = QDACGetVoltage(obj, ch);
            obj.channelRange        = cellfun(@QDAC.normalizeRange, ...
                obj.queryList('SOUR:RANG?', ch), 'UniformOutput', false);
            obj.channelFilter       = cellfun(@QDAC.normalizeFilter, ...
                obj.queryList('SOUR:FILT?', ch), 'UniformOutput', false);
            obj.channelCurrentRange = cellfun(@QDAC.normalizeRange, ...
                obj.queryList('SENS:RANG?', ch), 'UniformOutput', false);
            obj.channelSlew = QDACGetSlewRate(obj, ch);
            % Calibrated range limits (documented "primarily for drivers").
            lim.LOW  = [obj.queryNum('SOUR:RANG:LOW:MIN?',  ch); ...
                        obj.queryNum('SOUR:RANG:LOW:MAX?',  ch)];
            lim.HIGH = [obj.queryNum('SOUR:RANG:HIGH:MIN?', ch); ...
                        obj.queryNum('SOUR:RANG:HIGH:MAX?', ch)];
            % Fall back to nominal values for anything that did not parse.
            lim.LOW(1,  isnan(lim.LOW(1,:)))  = -2;  lim.LOW(2,  isnan(lim.LOW(2,:)))  = 2;
            lim.HIGH(1, isnan(lim.HIGH(1,:))) = -10; lim.HIGH(2, isnan(lim.HIGH(2,:))) = 10;
            obj.rangeLimits = lim;
            obj.monitorChannel = QDACQueryMonitor(obj);
        end
    end

    % =====================================================================
    %  DC VOLTAGE: SET / GET / RAMP
    % =====================================================================
    methods
        function QDACSetVoltage(obj, channels, voltages)
            % QDACSETVOLTAGE  Set DC voltages in FIXed mode.
            %   Steps immediately unless a finite slew rate is set
            %   (QDACSetSlewRate), in which case the hardware ramps at that rate.
            %   voltages may be a scalar (applied to all channels).
            [ch, v] = obj.checkChannelsVoltages(channels, voltages);
            b = obj.batch();    % mode + all values in one TCP send
            obj.scpiWrite(['SOUR:DC:MODE FIX,' QDAC.chanList(ch)]);
            obj.writeGrouped('SOUR:VOLT', ch, v);
            clear b
            obj.channelVoltages(ch) = v;
            obj.finish('QDACSetVoltage');
        end

        function v = QDACGetVoltage(obj, channels)
            % QDACGETVOLTAGE  Present DC generator output [V], in the order of
            %   'channels'. Works in any DC mode; no side effects.
            ch = obj.checkChannels(channels);
            v  = obj.queryNum('SOUR:VOLT?', ch);
        end

        function QDACRampVoltage(obj, channels, voltages, numSteps, dwell, opts)
            % QDACRAMPVOLTAGE  Staircase ramp from the present voltage to target.
            %   QDACRampVoltage(qdac, ch, v)                 100 levels, 1 ms each
            %   QDACRampVoltage(qdac, ch, v, numSteps, dwell, 'Wait', true)
            %
            %   numSteps  number of voltage LEVELS including start and target
            %             (= SOUR:SWE:POIN, >= 2): numSteps - 1 increments.
            %             0 -> 1 V with numSteps = 5 gives 0, 0.25, ..., 1 V.
            %             Duration numSteps * dwell.
            %   dwell     time per level [s], 2e-6 ... 36000, rounded to 1 us
            %   'Wait'    block until all channels have settled at the target
            %   'Timeout' [s] for 'Wait' (default: estimated from the ramp)
            %   Give numSteps and dwell explicitly when using 'Wait'/'Timeout'
            %   (an optional positional argument cannot be told apart from a
            %   name in an arguments block).
            %
            %   Channels in FILTer = DC cannot run SWEeps; they are stepped from
            %   MATLAB instead (blocking, step period >= SOFT_RAMP_DWELL).
            arguments
                obj
                channels
                voltages
                numSteps    (1,1) double {mustBeInteger} = 100
                dwell       (1,1) double = 1e-3
                opts.Wait   (1,1) logical = false
                opts.Timeout (1,1) double = NaN
            end
            [ch, v] = obj.checkChannelsVoltages(channels, voltages);
            if numSteps < 2 || numSteps > QDAC.MAX_SWEEP_POINTS
                % POINts = 1 only outputs the STARt value and stops (cmd ref).
                error('QDAC:badNumSteps', 'numSteps must be 2 ... %d (got %d).', ...
                    QDAC.MAX_SWEEP_POINTS, numSteps);
            end
            numPoints = numSteps;       % SWE:POIN counts levels incl. start
            dwell = QDAC.checkDwell(dwell);

            v0   = QDACGetVoltage(obj, ch);          % the only query before the ramp
            isDC = strcmp(obj.channelFilter(ch), 'DC');
            chHW = ch(~isDC);
            if ~isempty(chHW)
                cl = QDAC.chanList(chHW);
                b = obj.batch();          % whole configuration = one TCP send
                obj.writeGrouped('SOUR:SWE:STAR', chHW, v0(~isDC));
                obj.writeGrouped('SOUR:SWE:STOP', chHW, v(~isDC));
                obj.scpiWrite(sprintf('SOUR:SWE:POIN %d,%s', numPoints, cl));
                obj.scpiWrite(sprintf('SOUR:SWE:DWEL %s,%s', QDAC.fmtNum(dwell), cl));
                obj.scpiWrite(['SOUR:SWE:COUN 1,' cl]);
                obj.scpiWrite(['SOUR:SWE:GEN STEP,' cl]);
                obj.startDCSweep(chHW);
                clear b                               % one send; the sweep starts here
            end
            tStart = tic;
            if any(isDC)
                obj.softwareRamp(ch(isDC), v0(isDC), v(isDC), numPoints - 1, ...
                    max(dwell, QDAC.SOFT_RAMP_DWELL));
            end
            obj.channelVoltages(ch) = v;

            if opts.Wait
                % Errors are checked once, at the end of the wait.
                [tExpected, tTimeout] = obj.estimateRampTime(ch, v0, v, numPoints * dwell);
                if ~isnan(opts.Timeout), tTimeout = opts.Timeout; end
                QDACWaitForDC(obj, ch, v, tTimeout, tExpected - toc(tStart));
            else
                obj.finish('QDACRampVoltage');
            end
        end

        function QDACSmoothRampVoltage(obj, channels, voltages, rampTime, opts)
            % QDACSMOOTHRAMPVOLTAGE  Linear (ANALog) ramp to target in rampTime [s].
            %   Discretised only by the 1 MS/s sample rate and DAC resolution.
            %   Channels in FILTer = DC are stepped from MATLAB instead.
            arguments
                obj
                channels
                voltages
                rampTime     (1,1) double {mustBePositive}
                opts.Wait    (1,1) logical = false
                opts.Timeout (1,1) double = NaN
            end
            [ch, v] = obj.checkChannelsVoltages(channels, voltages);
            rampTime = QDAC.checkDwell(rampTime);

            v0   = QDACGetVoltage(obj, ch);
            isDC = strcmp(obj.channelFilter(ch), 'DC');
            chHW = ch(~isDC);
            if ~isempty(chHW)
                cl = QDAC.chanList(chHW);
                b = obj.batch(); 
                obj.writeGrouped('SOUR:SWE:STAR', chHW, v0(~isDC));
                obj.writeGrouped('SOUR:SWE:STOP', chHW, v(~isDC));
                % Cmd ref: for ANALog set POINts = 1, DWELl = total ramp time.
                obj.scpiWrite(['SOUR:SWE:POIN 1,' cl]);
                obj.scpiWrite(sprintf('SOUR:SWE:DWEL %s,%s', QDAC.fmtNum(rampTime), cl));
                obj.scpiWrite(['SOUR:SWE:COUN 1,' cl]);
                obj.scpiWrite(['SOUR:SWE:GEN ANAL,' cl]);
                obj.startDCSweep(chHW);
                clear b
            end
            tStart = tic;
            if any(isDC)
                nSoft = max(1, ceil(rampTime / QDAC.SOFT_RAMP_DWELL));
                obj.softwareRamp(ch(isDC), v0(isDC), v(isDC), nSoft, QDAC.SOFT_RAMP_DWELL);
            end
            obj.channelVoltages(ch) = v;

            if opts.Wait
                [tExpected, tTimeout] = obj.estimateRampTime(ch, v0, v, rampTime);
                if ~isnan(opts.Timeout), tTimeout = opts.Timeout; end
                QDACWaitForDC(obj, ch, v, tTimeout, tExpected - toc(tStart));
            else
                obj.finish('QDACSmoothRampVoltage');
            end
        end

        function QDACWaitForDC(obj, channels, targets, timeout, expectedTime)
            % QDACWAITFORDC  Block until sweeps have finished (SWE:NCL? = 0) AND
            %   the outputs read back within settleTolerance of the targets
            %   (covers slew-limited transitions that outlast the sweep).
            %   Leaves the channels in FIXed mode (bumpless per cmd ref).
            %   expectedTime [s]: remaining ramp time; the first poll is delayed
            %   by this much so that a normal ramp needs only one poll (2 queries).
            arguments
                obj
                channels
                targets
                timeout      (1,1) double {mustBePositive} = 60
                expectedTime (1,1) double = 0
            end
            [ch, vT] = obj.checkChannelsVoltages(channels, targets);
            t0 = tic;
            if expectedTime > 1e-3
                pause(expectedTime);
            end
            pollInterval = min(0.02, max(1e-3, expectedTime / 20));
            while true
                ncl = obj.queryNum('SOUR:SWE:NCL?', ch);
                if all(ncl == 0)
                    vNow = QDACGetVoltage(obj, ch);
                    if all(abs(vNow - vT) <= obj.settleTolerance), break; end
                end
                if toc(t0) > timeout
                    obj.checkErrors('QDACWaitForDC (timeout)');   % configuration error?
                    error('QDAC:waitTimeout', ...
                        'Channels %s did not settle within %.1f s.', mat2str(ch), timeout);
                end
                pause(pollInterval);
            end
            obj.scpiWrite(['SOUR:DC:MODE FIX,' QDAC.chanList(ch)]);
            obj.finish('QDACWaitForDC');
        end

        function QDACSetAllZero(obj, opts)
            % QDACSETALLZERO  Ramp every non-zero channel to 0 V (DC generator).
            %   'Rate' [V/s] (default 1), 'Wait' (default true).
            %   Waveform generators are NOT touched; use QDACAbortAll first if
            %   any are running.
            arguments
                obj
                opts.Rate (1,1) double {mustBePositive} = 1
                opts.Wait (1,1) logical = true
            end
            ch = 1:obj.numChannels;
            v  = QDACGetVoltage(obj, ch);
            nz = abs(v) > obj.settleTolerance;
            if any(nz)
                T = max(abs(v(nz))) / opts.Rate;
                QDACSmoothRampVoltage(obj, ch(nz), 0, max(T, QDAC.MIN_DWELL), 'Wait', opts.Wait);
            end
            if ~any(nz) || opts.Wait
                QDACSetVoltage(obj, ch, 0);   % clean FIXed 0 V everywhere
            end
        end

        function QDACSetSlewRate(obj, channels, rate)
            % QDACSETSLEWRATE  DC-generator slew-rate limit [V/s]; Inf = none.
            %   Applies to FIXed, SWEep and LIST. Range 0.01 ... 2e7 V/s.
            ch = obj.checkChannels(channels);
            rate = QDAC.expand(rate, numel(ch));
            if any(~(isinf(rate) | (rate >= QDAC.MIN_SLEW & rate <= QDAC.MAX_SLEW)))
                error('QDAC:badSlew', 'Slew rate must be %g ... %g V/s or Inf.', ...
                    QDAC.MIN_SLEW, QDAC.MAX_SLEW);
            end
            clamped = strcmp(obj.channelFilter(ch), 'DC') & rate < QDAC.DC_FILTER_MIN_SLEW;
            if any(clamped)
                warning('QDAC:slewClamped', ...
                    ['Channels %s are in FILTer=DC: the instrument clamps the slew ' ...
                     'rate to >= %g V/s there (query still returns the set value).'], ...
                    mat2str(ch(clamped)), QDAC.DC_FILTER_MIN_SLEW);
            end
            obj.writeGrouped('SOUR:VOLT:SLEW', ch, rate);
            obj.ensureSlewCache();          % never index into an empty cache
            obj.channelSlew(ch) = rate;
            obj.finish('QDACSetSlewRate');
        end

        function rate = QDACGetSlewRate(obj, channels)
            % QDACGETSLEWRATE  DC slew rate [V/s] per channel (Inf = unlimited).
            ch = obj.checkChannels(channels);
            rate = obj.queryNum('SOUR:VOLT:SLEW?', ch);
        end

        function QDACAbortDC(obj, channels)
            % QDACABORTDC  Stop DC SWEep/LIST on the channels. The last DC value
            %   stays. A slew-limited transition still completes (cmd ref).
            ch = obj.checkChannels(channels);
            obj.scpiWrite(['SOUR:DC:ABOR ' QDAC.chanList(ch)]);
            obj.channelVoltages(ch) = QDACGetVoltage(obj, ch);
            obj.finish('QDACAbortDC');
        end

        function QDACAbortAll(obj)
            % QDACABORTALL  Global ABORt: all generators and current sensors.
            obj.scpiWrite('ABOR');
            obj.channelVoltages = QDACGetVoltage(obj, 1:obj.numChannels);
            obj.finish('QDACAbortAll');
        end
    end

    % =====================================================================
    %  LEGACY QUERY METHODS (return char, as before; no side effects now)
    % =====================================================================
    methods
        function querySTB = queryQDACSTB(obj)
            % Returns the status byte register
            querySTB = obj.scpiQuery('*STB?');
        end

        function queryError = queryQDACError(obj)
            % Reads AND clears the error queue.
            queryError = obj.scpiQuery('SYST:ERR:ALL?');
        end

        function qDACClearError(obj)
            % Read the queue once (stops the blinking LED), then *CLS.
            obj.scpiQuery('SYST:ERR:ALL?');
            obj.scpiWrite('*CLS');
        end

        function qDACReset(obj, opts)
            % QDACRESET  *RST. Ramps all outputs to 0 V first, because *RST
            %   steps every channel to 0 V at once. 'Force', true skips the ramp.
            arguments
                obj
                opts.Force (1,1) logical = false
                opts.Rate  (1,1) double {mustBePositive} = 1
            end
            if ~opts.Force
                QDACAbortAll(obj);
                QDACSetAllZero(obj, 'Rate', opts.Rate, 'Wait', true);
            end
            obj.scpiWrite('*RST');
            pause(1);
            obj.scpiQuery('SYST:ERR:ALL?');
            QDACRefresh(obj);
            obj.syncTraceMaps();
        end

        function ip = qDACIPAddress(obj)
            ip = obj.scpiQuery('SYST:COMM:LAN:IPAD?');
        end

        function range = queryQDACRange(obj, channels)
            range = strjoin(obj.queryList('SOUR:RANG?', obj.checkChannels(channels)), ',');
        end

        function lowPassFreq = queryQDACLowPassFreq(obj, channels)
            lowPassFreq = strjoin(obj.queryList('SOUR:FILT?', obj.checkChannels(channels)), ',');
        end

        function DCGeneratorMode = queryQDACDCGenerator(obj, channels)
            DCGeneratorMode = strjoin(obj.queryList('SOUR:DC:MODE?', obj.checkChannels(channels)), ',');
        end

        function voltage = queryQDACVoltage(obj, channels)
            % Comma-separated voltages IN THE ORDER OF 'channels'.
            % (The old version switched channels to FIX as a side effect.)
            voltage = strjoin(obj.queryList('SOUR:VOLT?', obj.checkChannels(channels)), ',');
        end

        function v = queryQDACSweepStartVoltage(obj, channels)
            v = strjoin(obj.queryList('SOUR:SWE:STAR?', obj.checkChannels(channels)), ',');
        end

        function v = queryQDACSweepStopVoltage(obj, channels)
            v = strjoin(obj.queryList('SOUR:SWE:STOP?', obj.checkChannels(channels)), ',');
        end

        function mode = queryQDACSweepMode(obj, channels)
            mode = strjoin(obj.queryList('SOUR:SWE:GEN?', obj.checkChannels(channels)), ',');
        end
    end

    % =====================================================================
    %  LEGACY / LOW-LEVEL SETTERS
    % =====================================================================
    methods
        function setQDACRange(obj, channels, lowORHigh)
            % SETQDACRANGE  0 or 'LOW' -> +/-2 V, 1 or 'HIGH' -> +/-10 V.
            %   Refuses at non-zero output; writes 0 V after the change, as the
            %   operation manual requires.
            ch = obj.checkChannels(channels);
            if isnumeric(lowORHigh) || islogical(lowORHigh)
                if lowORHigh == 0, r = 'LOW'; else, r = 'HIGH'; end
            else
                r = QDAC.normalizeRange(lowORHigh);
                if ~any(strcmp(r, {'LOW','HIGH'}))
                    error('QDAC:badRange', 'Range must be LOW/HIGH or 0/1.');
                end
            end
            v = QDACGetVoltage(obj, ch);
            if any(abs(v) > obj.settleTolerance)
                error('QDAC:rangeAtNonzero', ...
                    'Channels %s are not at 0 V. Ramp to 0 V before changing range.', ...
                    mat2str(ch(abs(v) > obj.settleTolerance)));
            end
            cl = QDAC.chanList(ch);
            obj.scpiWrite(sprintf('SOUR:RANG %s,%s', r, cl));
            obj.scpiWrite(['SOUR:DC:MODE FIX,' cl]);
            obj.scpiWrite(['SOUR:VOLT 0,' cl]);
            obj.channelRange(ch) = {r};
            obj.channelVoltages(ch) = 0;
            obj.finish('setQDACRange');
        end

        function setQDACLowPass(obj, channels, type)
            % SETQDACLOWPASS  'DC' (~10 Hz, 25-bit, FIX only), 'MED' (~10 kHz),
            %   'HIGH' (~300 kHz, default; needed for fast AWG signals).
            ch = obj.checkChannels(channels);
            t = QDAC.normalizeFilter(type);
            if ~any(strcmp(t, {'DC','MED','HIGH'}))
                error('QDAC:badFilter', 'Filter must be DC, MED or HIGH (got "%s").', char(type));
            end
            obj.scpiWrite(sprintf('SOUR:FILT %s,%s', t, QDAC.chanList(ch)));
            obj.channelFilter(ch) = {t};
            if strcmp(t, 'DC')
                fprintf(['QDAC: channels %s in FILTer=DC - sweeps, lists and waveform ' ...
                         'generators unavailable; current sensor time constant ~minutes.\n'], ...
                         mat2str(ch));
            end
            obj.finish('setQDACLowPass');
        end

        function setQDACDCGeneratorMode(obj, channels, type)
            % SETQDACDCGENERATORMODE  'FIX' | 'SWE' | 'LIST'.
            ch = obj.checkChannels(channels);
            t = upper(char(type));
            t = t(1:min(end, 4));
            if strcmp(t, 'FIXE'), t = 'FIX'; end
            if strcmp(t, 'SWEE'), t = 'SWE'; end
            if ~any(strcmp(t, {'FIX','SWE','LIST'}))
                error('QDAC:badMode', 'DC mode must be FIX, SWE or LIST.');
            end
            obj.scpiWrite(sprintf('SOUR:DC:MODE %s,%s', t, QDAC.chanList(ch)));
            obj.finish('setQDACDCGeneratorMode');
        end

        function QDACSetSweepStartVoltage(obj, channels, voltage)
            [ch, v] = obj.checkChannelsVoltages(channels, voltage);
            obj.writeGrouped('SOUR:SWE:STAR', ch, v);
            obj.finish('QDACSetSweepStartVoltage');
        end

        function QDACSetSweepStopVoltage(obj, channels, voltage)
            [ch, v] = obj.checkChannelsVoltages(channels, voltage);
            obj.writeGrouped('SOUR:SWE:STOP', ch, v);
            obj.finish('QDACSetSweepStopVoltage');
        end

        function QDACSetSweepPoints(obj, channels, numSteps)
            % Raw SOUR:SWE:POIN = number of LEVELS including the start value
            % (low-level; QDACRampVoltage's numSteps is POINts - 1).
            ch = obj.checkChannels(channels);
            if numSteps < 1 || numSteps > QDAC.MAX_SWEEP_POINTS || mod(numSteps,1) ~= 0
                error('QDAC:badPoints', 'Sweep points must be an integer 1 ... %d.', QDAC.MAX_SWEEP_POINTS);
            end
            obj.scpiWrite(sprintf('SOUR:SWE:POIN %d,%s', numSteps, QDAC.chanList(ch)));
            obj.finish('QDACSetSweepPoints');
        end

        function QDACSetSweepDwell(obj, channels, dwell)
            ch = obj.checkChannels(channels);
            dwell = QDAC.checkDwell(dwell);
            obj.scpiWrite(sprintf('SOUR:SWE:DWEL %s,%s', QDAC.fmtNum(dwell), QDAC.chanList(ch)));
            obj.finish('QDACSetSweepDwell');
        end

        function QDACSetSweepCount(obj, channels, count)
            % Number of sweep repetitions per trigger; Inf -> -1 (infinite).
            ch = obj.checkChannels(channels);
            obj.scpiWrite(sprintf('SOUR:SWE:COUN %d,%s', QDAC.countArg(count), QDAC.chanList(ch)));
            obj.finish('QDACSetSweepCount');
        end

        function QDACSetSweepMode(obj, channels, type)
            % 'STEP' (staircase) | 'ANAL' (linear ramp).
            ch = obj.checkChannels(channels);
            t = upper(char(type));
            t = t(1:min(end, 4));
            if ~any(strcmp(t, {'STEP','ANAL'}))
                error('QDAC:badSweepMode', 'Sweep generation must be STEP or ANAL.');
            end
            obj.scpiWrite(sprintf('SOUR:SWE:GEN %s,%s', t, QDAC.chanList(ch)));
            obj.finish('QDACSetSweepMode');
        end

        function QDACStartSweep(obj, channels)
            % Start a configured DC sweep/list immediately (does not change mode).
            ch = obj.checkChannels(channels);
            cl = QDAC.chanList(ch);
            obj.scpiWrite(['SOUR:DC:INIT:CONT OFF,' cl]);
            obj.scpiWrite(['SOUR:DC:TRIG:SOUR IMM,' cl]);
            obj.scpiWrite(['SOUR:DC:INIT ' cl]);
            obj.finish('QDACStartSweep');
        end
    end

    % =====================================================================
    %  CURRENT SENSING
    % =====================================================================
    methods
        function QDACSetCurrentRange(obj, channels, range)
            % QDACSETCURRENTRANGE  'LOW' (+/-200 nA, high resolution, limited
            %   output bandwidth) | 'HIGH' (+/-10 mA, default). Toggles a relay
            %   (30-40 ms); preferably done at 0 V.
            ch = obj.checkChannels(channels);
            r  = QDAC.normalizeRange(range);
            if ~any(strcmp(r, {'LOW','HIGH'}))
                error('QDAC:badCurrentRange', 'Current range must be LOW or HIGH.');
            end
            v = QDACGetVoltage(obj, ch);
            if any(abs(v) > 1e-3)
                warning('QDAC:currentRangeAtNonzero', ...
                    'Switching current range at non-zero voltage on %s: expect a transient.', ...
                    mat2str(ch(abs(v) > 1e-3)));
            end
            obj.scpiWrite(sprintf('SENS:RANG %s,%s', r, QDAC.chanList(ch)));
            pause(0.05);
            obj.channelCurrentRange(ch) = {r};
            obj.finish('QDACSetCurrentRange');
        end

        function QDACSetCurrentAperture(obj, channels, aperture)
            % QDACSETCURRENTAPERTURE  Integration time [s], 1/3 ms ... 2 s.
            ch = obj.checkChannels(channels);
            if aperture < QDAC.SENSE_SAMPLE * (1 - 1e-6) || aperture > 2
                error('QDAC:badAperture', 'Aperture must be %.3g ... 2 s.', QDAC.SENSE_SAMPLE);
            end
            obj.scpiWrite(sprintf('SENS:APER %s,%s', QDAC.fmtNum(aperture), QDAC.chanList(ch)));
            obj.finish('QDACSetCurrentAperture');
        end

        function QDACSetCurrentNPLC(obj, channels, nplc)
            % QDACSETCURRENTNPLC  Integration time in power-line cycles (<= 100).
            ch = obj.checkChannels(channels);
            if nplc <= 0 || nplc > 100
                error('QDAC:badNPLC', 'NPLC must be in (0, 100].');
            end
            obj.scpiWrite(sprintf('SENS:NPLC %s,%s', QDAC.fmtNum(nplc), QDAC.chanList(ch)));
            obj.finish('QDACSetCurrentNPLC');
        end

        function I = QDACReadCurrent(obj, channels)
            % QDACREADCURRENT  Present integrated current [A] per channel, in the
            %   order of 'channels'. Uses READ? (sets the sensor trigger to IMM,
            %   aborts ongoing sensor acquisitions). Assumes SENS:COUN = 1.
            ch = obj.checkChannels(channels);
            I  = obj.queryNum('READ?', ch);
            if any(isnan(I))
                error('QDAC:readCurrent', ...
                    'Could not parse current readings (is SENS:COUN > 1 on some channel?).');
            end
            I(abs(I) > 1e37) = NaN;   % 9.91e37 = "no measurement" marker
        end

        function R = QDACLeakageMatrix(obj, channels, dV, opts)
            % QDACLEAKAGEMATRIX  Gate-to-gate leakage resistance [Ohm].
            %   Each channel i is raised by dV in turn; the change in current on
            %   every channel j is recorded:  R(i,j) = |dV / dI_j|.
            %   R(i,i) is the total resistance seen by gate i; R(i,j), i~=j, the
            %   i -> j path (gate j holds its voltage through its 50 Ohm output).
            %   Original voltages are restored even on error / Ctrl-C.
            %
            %   'SettleTime' [s] per step (default 3 x aperture + dV/slew + 10 ms)
            %   'Plot'       draw the matrix (default true)
            %
            %   Use small dV (e.g. 10 mV) and the LOW current range for nA-level
            %   resolution. Avoid FILTer = DC (sensor time constant ~minutes).
            arguments
                obj
                channels
                dV                (1,1) double {mustBeNonzero}
                opts.SettleTime   (1,1) double = NaN
                opts.Plot         (1,1) logical = true
            end
            ch = obj.checkChannels(channels);
            n  = numel(ch);
            v0 = QDACGetVoltage(obj, ch);
            obj.checkChannelsVoltages(ch, v0 + dV);   % range check before touching anything

            if any(strcmp(obj.channelFilter(ch), 'DC'))
                warning('QDAC:leakageDCFilter', ...
                    'FILTer=DC on some channels: current sensor will not settle in time.');
            end
            settle = opts.SettleTime;
            if isnan(settle)
                aper  = max(obj.queryNum('SENS:APER?', ch));
                slew  = min(QDACGetSlewRate(obj, ch));
                settle = 3 * aper + abs(dV) / min(slew, QDAC.MAX_SLEW) + 0.01;
            end

            restore = onCleanup(@() QDACSetVoltage(obj, ch, v0)); 
            pause(settle);
            I0 = QDACReadCurrent(obj, ch);
            dI = zeros(n);
            for i = 1:n
                QDACSetVoltage(obj, ch(i), v0(i) + dV);
                pause(settle);
                dI(i, :) = QDACReadCurrent(obj, ch) - I0;
                QDACSetVoltage(obj, ch(i), v0(i));
                pause(settle);
            end
            R = abs(dV ./ dI);
            if opts.Plot
                QDAC.plotLeakage(R, ch, dV);
            end
        end
    end

    % =====================================================================
    %  ARBITRARY WAVEFORM GENERATOR AND TRACES
    % =====================================================================
    methods
        function QDACDefineTrace(obj, traceName, nPoints)
            % QDACDEFINETRACE  Allocate a named trace of nPoints samples (1 us
            %   each). nPoints must be even, 4 ... 6,291,456. Max 24 traces.
            QDAC.checkTraceName(traceName);
            if mod(nPoints,1) ~= 0 || nPoints < 4 || nPoints > QDAC.MAX_TRACE_POINTS || mod(nPoints,2) ~= 0
                error('QDAC:badTraceSize', ...
                    'Trace length must be an even integer 4 ... %d (got %g).', ...
                    QDAC.MAX_TRACE_POINTS, nPoints);
            end
            catalog = QDACTraceCatalog(obj);
            if any(strcmp(catalog, traceName))
                error('QDAC:traceExists', ...
                    'Trace "%s" already exists. Use QDACRemoveAllTraces to free memory.', traceName);
            end
            if numel(catalog) >= QDAC.MAX_TRACES
                error('QDAC:tooManyTraces', 'At most %d traces can be defined.', QDAC.MAX_TRACES);
            end
            obj.scpiWrite(sprintf('TRAC:DEF "%s",%d', traceName, nPoints));
            obj.checkErrors('QDACDefineTrace');      % always: memory may be exhausted (-225)
            obj.traceSizes(traceName) = nPoints;
        end

        function QDACUploadTrace(obj, traceName, values)
            % QDACUPLOADTRACE  Upload normalised samples in [-1, 1] to a trace,
            %   defining it first if needed. Each sample lasts 1 us; the AWG
            %   multiplies by its SCALe [V] and adds OFFSet [V].
            %   Data go as an IEEE 488.2 binary block of float32 (little-endian,
            %   as written by the official QCoDeS driver through pyvisa).
            %   The error queue is always checked afterwards (manual advice:
            %   large uploads over LAN can occasionally fail).
            QDAC.checkTraceName(traceName);
            y = double(values(:).');
            if isempty(y) || any(~isfinite(y)) || any(abs(y) > 1)
                error('QDAC:badTraceData', ...
                    'Trace samples must be finite and within [-1, 1]. Normalise and use AWG SCALe.');
            end
            if mod(numel(y), 2) == 1
                y(end+1) = y(end);
                warning('QDAC:oddTrace', 'Odd trace length: last sample duplicated (%d points).', numel(y));
            end

            if isKey(obj.traceSizes, traceName)
                if obj.traceSizes(traceName) ~= numel(y)
                    error('QDAC:traceSizeMismatch', ...
                        'Trace "%s" was defined with %d points, data have %d.', ...
                        traceName, obj.traceSizes(traceName), numel(y));
                end
            else
                if any(strcmp(QDACTraceCatalog(obj), traceName))
                    error('QDAC:traceUnknownSize', ...
                        ['Trace "%s" exists on the instrument but was not defined in this ' ...
                         'session, so its size is unknown. Call QDACRemoveAllTraces first.'], traceName);
                end
                QDACDefineTrace(obj, traceName, numel(y));
            end

            % Long uploads: extend the timeout for the error query that follows.
            oldTimeout = obj.client.Timeout;
            obj.client.Timeout = max(oldTimeout, 10 + 4 * numel(y) / 1e6);
            restoreTimeout = onCleanup(@() obj.setClientTimeout(oldTimeout)); 

            obj.writeBinaryBlock(sprintf('TRAC:DATA "%s",', traceName), y);
            obj.checkErrors(sprintf('QDACUploadTrace "%s" (%d points)', traceName, numel(y)));
            obj.traceMaxAbs(traceName) = max(abs(y));
        end

        function names = QDACTraceCatalog(obj)
            % QDACTRACECATALOG  Names of all traces in instrument memory.
            resp  = obj.scpiQuery('TRAC:CAT?');
            parts = strtrim(strsplit(resp, ','));
            names = regexprep(parts, '^["\x{201C}\x{201D}]+|["\x{201C}\x{201D}]+$', '');
            names = names(~cellfun(@isempty, names));
        end

        function QDACRemoveAllTraces(obj)
            % QDACREMOVEALLTRACES  Free all trace memory. The instrument refuses
            %   while a trace is assigned (SOUR:AWG:DEF) to any AWG; in that case
            %   an empty assignment is tried once (behaviour not documented in the
            %   Compact command reference - verify on your firmware).
            allCh = QDAC.chanList(1:obj.numChannels);
            obj.scpiWrite(['SOUR:AWG:ABOR ' allCh]);
            obj.scpiWrite('TRAC:REM:ALL');
            resp = obj.scpiQuery('SYST:ERR:ALL?');
            if QDAC.errorCode(resp) ~= 0
                obj.scpiWrite(['SOUR:AWG:DEF "",' allCh]);
                obj.scpiWrite('TRAC:REM:ALL');
                resp2 = obj.scpiQuery('SYST:ERR:ALL?');
                if QDAC.errorCode(resp2) ~= 0
                    error('QDAC:removeTraces', ...
                        ['TRAC:REM:ALL failed: %s\nThen: %s\nA trace is probably still ' ...
                         'assigned to an AWG. Power-cycling clears trace memory.'], resp, resp2);
                end
            end
            remove(obj.traceSizes, keys(obj.traceSizes));
            remove(obj.traceMaxAbs, keys(obj.traceMaxAbs));
        end

        function QDACAWGSetup(obj, channels, traceNames, opts)
            % QDACAWGSETUP  Assign traces to AWGs and set their parameters.
            %   traceNames  one name (all channels) or a cellstr, one per channel
            %   'Scale'   [V]  per channel or scalar, -10 ... 10   (default 1)
            %   'Offset'  [V]  added while running                  (default 0)
            %   'Count'        repetitions per trigger, Inf = endless (default 1)
            %   'Slew'    [V/s] AWG slew limit, Inf = none          (default Inf)
            %   'Delay'   [s]  start delay after trigger            (default 0)
            %
            %   The AWG output adds to the DC level. Requires FILTer MED or HIGH;
            %   LOW current range limits the output bandwidth.
            arguments
                obj
                channels
                traceNames
                opts.Scale  double = 1
                opts.Offset double = 0
                opts.Count  double = 1
                opts.Slew   double = Inf
                opts.Delay  double = 0
            end
            ch = obj.checkChannels(channels);
            n  = numel(ch);
            names = cellstr(traceNames);
            if isscalar(names), names = repmat(names, 1, n); end
            if numel(names) ~= n
                error('QDAC:awgNames', 'Give one trace name or one per channel.');
            end
            cellfun(@QDAC.checkTraceName, names);
            scale  = QDAC.expand(opts.Scale,  n);
            offset = QDAC.expand(opts.Offset, n);
            count  = arrayfun(@QDAC.countArg, QDAC.expand(opts.Count, n));
            slew   = QDAC.expand(opts.Slew,   n);
            delay  = QDAC.expand(opts.Delay,  n);
            if any(abs(scale) > 10), error('QDAC:awgScale', 'AWG scale must be within +/-10 V.'); end
            if any(~(isinf(slew) | (slew >= QDAC.MIN_SLEW & slew <= QDAC.MAX_SLEW)))
                error('QDAC:awgSlew', 'AWG slew must be %g ... %g V/s or Inf.', QDAC.MIN_SLEW, QDAC.MAX_SLEW);
            end
            if any(delay < 0 | delay > 3600), error('QDAC:awgDelay', 'Delay must be 0 ... 3600 s.'); end

            isDC = strcmp(obj.channelFilter(ch), 'DC');
            if any(isDC)
                error('QDAC:awgDCFilter', ...
                    'Channels %s are in FILTer=DC; waveform generators need MED or HIGH.', mat2str(ch(isDC)));
            end
            isLowI = strcmp(obj.channelCurrentRange(ch), 'LOW');
            if any(isLowI)
                warning('QDAC:awgLowCurrentRange', ...
                    'Channels %s use the LOW current range: output bandwidth is limited.', mat2str(ch(isLowI)));
            end
            obj.warnIfClipping(ch, names, scale, offset);

            % Changing AWG parameters stops a running AWG anyway; do it explicitly.
            obj.scpiWrite(['SOUR:AWG:ABOR ' QDAC.chanList(ch)]);
            obj.writeGrouped('SOUR:AWG:DEF',  ch, cellfun(@(s) ['"' s '"'], names, 'UniformOutput', false));
            obj.writeGrouped('SOUR:AWG:SCAL', ch, scale);
            obj.writeGrouped('SOUR:AWG:OFFS', ch, offset);
            obj.writeGrouped('SOUR:AWG:COUN', ch, count);
            obj.writeGrouped('SOUR:AWG:SLEW', ch, slew);
            obj.writeGrouped('SOUR:AWG:DEL',  ch, delay);
            obj.finish('QDACAWGSetup');
        end

        function QDACAWGArm(obj, channels, trigger, opts)
            % QDACAWGARM  Make AWGs wait for a trigger.
            %   trigger  internal trigger number (1-14), or 'INTn', 'EXTn'
            %            (rear trigger inputs), 'BUS' (*TRG), 'IMM' (start now)
            %   'Continuous'  re-arm after each run (default false)
            arguments
                obj
                channels
                trigger
                opts.Continuous (1,1) logical = false
            end
            ch  = obj.checkChannels(channels);
            src = QDAC.triggerSource(trigger);
            cl  = QDAC.chanList(ch);
            % Source before CONT ON: CONT ON with IMM would re-trigger endlessly.
            obj.scpiWrite(['SOUR:AWG:INIT:CONT OFF,' cl]);
            obj.scpiWrite(sprintf('SOUR:AWG:TRIG:SOUR %s,%s', src, cl));
            if opts.Continuous
                obj.scpiWrite(['SOUR:AWG:INIT:CONT ON,' cl]);
            else
                obj.scpiWrite(['SOUR:AWG:INIT ' cl]);
            end
            obj.finish('QDACAWGArm');
        end

        function QDACAWGStart(obj, channels)
            % QDACAWGSTART  Start the AWGs on all given channels on the same
            %   sample: arm them on internal trigger obj.syncTrigger, then fire it.
            ch = obj.checkChannels(channels);
            QDACAWGArm(obj, ch, obj.syncTrigger);
            QDACFireTrigger(obj, obj.syncTrigger);
        end

        function QDACAWGAbort(obj, channels)
            ch = obj.checkChannels(channels);
            obj.scpiWrite(['SOUR:AWG:ABOR ' QDAC.chanList(ch)]);
            obj.finish('QDACAWGAbort');
        end

        function n = QDACAWGCyclesLeft(obj, channels)
            % Remaining repetitions (0 = idle or armed-not-triggered, -1 = endless).
            ch = obj.checkChannels(channels);
            n  = obj.queryNum('SOUR:AWG:NCL?', ch);
        end

        function QDACAWGWait(obj, channels, timeout)
            % QDACAWGWAIT  Block until the AWGs on 'channels' have finished.
            arguments
                obj
                channels
                timeout (1,1) double {mustBePositive} = 60
            end
            ch = obj.checkChannels(channels);
            t0 = tic;
            while true
                n = QDACAWGCyclesLeft(obj, ch);
                if any(n < 0)
                    error('QDAC:awgEndless', 'AWG on %s runs endlessly (COUNt = INF).', mat2str(ch(n < 0)));
                end
                if all(n == 0), break; end
                if toc(t0) > timeout
                    error('QDAC:awgTimeout', 'AWG still running after %.1f s.', timeout);
                end
                pause(0.01);
            end
        end
    end

    % =====================================================================
    %  TRIGGERS AND MARKERS
    % =====================================================================
    methods
        function QDACFireTrigger(obj, n)
            % QDACFIRETRIGGER  Fire internal trigger n (1-14) by software (TINT).
            QDAC.checkInternalTrigger(n);
            obj.scpiWrite(sprintf('TINT %d', n));
            obj.finish('QDACFireTrigger');
        end

        function QDACBusTrigger(obj)
            % QDACBUSTRIGGER  *TRG: starts every generator whose source is BUS.
            obj.scpiWrite('*TRG');
            obj.finish('QDACBusTrigger');
        end

        function QDACSetMarker(obj, channels, generator, marker, n)
            % QDACSETMARKER  Pair a generator marker with internal trigger n
            %   (0 = unpair). generator: 'DC','SINE','SQU','TRI','AWG'.
            %   marker: 'START','END','PSTART','PEND', and for DC 'SSTART','SEND'.
            ch  = obj.checkChannels(channels);
            gen = QDAC.generatorKeyword(generator);
            mk  = QDAC.markerKeyword(marker, gen);
            if n ~= 0, QDAC.checkInternalTrigger(n); end
            for c = ch   % marker commands take no channel list
                obj.scpiWrite(sprintf('SOUR%d:%s:MARK:%s %d', c, gen, mk, n));
            end
            obj.finish('QDACSetMarker');
        end

        function QDACRouteTriggerOut(obj, port, source, opts)
            % QDACROUTETRIGGEROUT  Configure rear Trigger Out 'port' (1-5).
            %   source: internal trigger number, 'INTn', 'EXTn', 'BUS', 'HOLD'
            %   'Width' [s] (10e-6), 'Polarity' 'NORM'|'INV', 'Delay' [s] (0).
            %   Out 1-3: 0/5 V; Out 4-5: 0/3.3 V.
            arguments
                obj
                port (1,1) double {mustBeInteger, mustBePositive}
                source
                opts.Width    (1,1) double = 10e-6
                opts.Polarity (1,:) char {mustBeMember(opts.Polarity, {'NORM','INV'})} = 'NORM'
                opts.Delay    (1,1) double = 0
            end
            if port > QDAC.N_TRIGGER_OUTPUTS
                error('QDAC:badTrigOut', 'Trigger output must be 1 ... %d.', QDAC.N_TRIGGER_OUTPUTS);
            end
            src = QDAC.triggerSource(source);
            if strcmp(src, 'IMM'), error('QDAC:badTrigOut', 'IMM is not a valid output source.'); end
            % Polarity first: changing it toggles the idle level immediately.
            obj.scpiWrite(sprintf('OUTP:TRIG%d:POL %s',  port, opts.Polarity));
            obj.scpiWrite(sprintf('OUTP:TRIG%d:WIDT %s', port, QDAC.fmtNum(opts.Width)));
            obj.scpiWrite(sprintf('OUTP:TRIG%d:DEL %s',  port, QDAC.fmtNum(opts.Delay)));
            obj.scpiWrite(sprintf('OUTP:TRIG%d:SOUR %s', port, src));
            obj.finish('QDACRouteTriggerOut');
        end
    end

    % =====================================================================
    %  MONITOR PORT AND DIAGNOSTICS
    % =====================================================================
    methods
        function QDACSetMonitor(obj, ch)
            % QDACSETMONITOR  Route the front-panel monitor SMA to channel ch
            %   (0 disconnects). Use a high-impedance input (DMM, 1 MOhm scope);
            %   the manual does not specify the port's output impedance.
            if ~isscalar(ch) || mod(ch,1) ~= 0 || ch < 0 || ch > obj.numChannels
                error('QDAC:badMonitor', 'Monitor channel must be 0 ... %d.', obj.numChannels);
            end
            obj.scpiWrite(sprintf('DIAG:CCH %d', ch));
            obj.monitorChannel = ch;
            obj.finish('QDACSetMonitor');
        end

        function ch = QDACQueryMonitor(obj)
            % QDACQUERYMONITOR  Channel currently routed to the monitor port.
            ch = str2double(obj.scpiQuery('DIAG:CCH?'));
            obj.monitorChannel = ch;
        end

        function T = QDACMonitorScan(obj, channels, opts)
            % QDACMONITORSCAN  Step the monitor port through 'channels'.
            %   For each channel: route the monitor, wait 'Dwell' seconds, read
            %   the DC generator back and, if given, call 'MeasureFcn' (a
            %   function handle returning one value in volts, e.g. a DMM read):
            %       dmmRead = @() str2double(writeread(dmm, "READ?"));
            %       T = QDACMonitorScan(qdac, 1:24, 'MeasureFcn', dmmRead);
            %   Returns a table; 'Plot' draws monitor-minus-readback errors.
            %   The previous monitor routing is restored afterwards.
            arguments
                obj
                channels
                opts.Dwell      (1,1) double {mustBeNonnegative} = 1
                opts.MeasureFcn = []
                opts.Plot       (1,1) logical = true
                opts.Verbose    (1,1) logical = true
            end
            ch   = obj.checkChannels(channels);
            prev = QDACQueryMonitor(obj);
            restore = onCleanup(@() QDACSetMonitor(obj, prev)); 

            n = numel(ch);
            setV = obj.channelVoltages(ch).';
            readbackV = nan(n, 1);
            monitorV  = nan(n, 1);
            for k = 1:n
                QDACSetMonitor(obj, ch(k));
                pause(opts.Dwell);
                readbackV(k) = QDACGetVoltage(obj, ch(k));
                if ~isempty(opts.MeasureFcn)
                    monitorV(k) = opts.MeasureFcn();
                end
                if opts.Verbose
                    fprintf('ch %2d: set %+10.6f V  readback %+10.6f V  monitor %+10.6f V\n', ...
                        ch(k), setV(k), readbackV(k), monitorV(k));
                end
            end
            Channel = ch.';
            T = table(Channel, setV, readbackV, monitorV, monitorV - readbackV, ...
                'VariableNames', {'Channel','SetV','ReadbackV','MonitorV','MonitorMinusReadbackV'});
            if opts.Plot
                QDAC.plotMonitorScan(T);
            end
        end

        function D = QDACDiagnostics(obj, opts)
            % QDACDIAGNOSTICS  Snapshot of instrument state:
            %   identity, error queue (read and cleared), 9 board temperatures,
            %   monitor routing, trace catalog, and per channel: DC mode, ranges,
            %   filter, slew, voltage, current (READ?), AWG trace and cycles left.
            arguments
                obj
                opts.Currents (1,1) logical = true
                opts.Print    (1,1) logical = true
                opts.Plot     (1,1) logical = false
            end
            ch = 1:obj.numChannels;
            D.identifier = obj.identifier;
            D.errors     = obj.scpiQuery('SYST:ERR:ALL?');
            D.temperatureC = nan(3, 3);   % rows: board (ch 1-8, 9-16, 17-24); cols: left/mid/right
            for b = 1:3
                for s = 1:3
                    D.temperatureC(b, s) = str2double(obj.scpiQuery(sprintf('SYST:TEMP? %d,%d', b, s)));
                end
            end
            D.monitorChannel = QDACQueryMonitor(obj);
            D.traces = QDACTraceCatalog(obj);

            Channel   = ch.';
            Mode      = obj.queryList('SOUR:DC:MODE?', ch).';
            Range     = cellfun(@QDAC.normalizeRange,  obj.queryList('SOUR:RANG?', ch), 'UniformOutput', false).';
            Filter    = cellfun(@QDAC.normalizeFilter, obj.queryList('SOUR:FILT?', ch), 'UniformOutput', false).';
            CurrRange = cellfun(@QDAC.normalizeRange,  obj.queryList('SENS:RANG?', ch), 'UniformOutput', false).';
            Slew_Vps  = QDACGetSlewRate(obj, ch).';
            Voltage_V = QDACGetVoltage(obj, ch).';
            if opts.Currents
                Current_A = QDACReadCurrent(obj, ch).';
            else
                Current_A = nan(numel(ch), 1);
            end
            AWGTrace  = regexprep(obj.queryList('SOUR:AWG:DEF?', ch), '"', '').';
            AWGCycles = obj.queryNum('SOUR:AWG:NCL?', ch).';
            D.channels = table(Channel, Mode, Range, Filter, CurrRange, Slew_Vps, ...
                Voltage_V, Current_A, AWGTrace, AWGCycles);

            obj.channelRange  = Range.';
            obj.channelFilter = Filter.';
            obj.channelCurrentRange = CurrRange.';
            obj.channelSlew = Slew_Vps.';

            if opts.Print
                fprintf('\n=== QDAC diagnostics: %s ===\n', D.identifier);
                fprintf('Error queue : %s\n', D.errors);
                fprintf('Monitor     : channel %d\n', D.monitorChannel);
                fprintf('Traces      : %s\n', strjoin(D.traces, ', '));
                fprintf('Board temps : %s degC (max %.1f)\n', ...
                    mat2str(round(D.temperatureC, 1)), max(D.temperatureC(:)));
                disp(D.channels);
            end
            if opts.Plot
                QDAC.plotDiagnostics(D);
            end
        end
    end

    % =====================================================================
    %  LOW-LEVEL SCPI (public for advanced use)
    % =====================================================================
    methods
        function scpiWrite(obj, cmd)
            % SCPIWRITE  Send one SCPI command (no response expected). Inside a
            %   batch scope (obj.batch) the command is queued instead and sent
            %   with the others in one TCP write.
            cmd = char(cmd);
            obj.logCommand(cmd);
            if obj.verbose, fprintf('>> %s\n', cmd); end
            if obj.batchWrites && obj.batchDepth > 0
                obj.pendingWrites{end+1} = cmd;
            else
                writeline(obj.client, cmd);
            end
        end

        function flushWrites(obj)
            % FLUSHWRITES  Send all queued commands as LF-separated lines in a
            %   single TCP write (avoids one packet - and possibly one Nagle /
            %   delayed-ACK stall - per command).
            if isempty(obj.pendingWrites), return; end
            payload = [strjoin(obj.pendingWrites, char(10)) char(10)];
            obj.pendingWrites = {};
            write(obj.client, uint8(payload), "uint8");
        end

        function c = batch(obj)
            % BATCH  Start a write batch; returns an onCleanup object. Writes are
            %   queued until the object is cleared, a query is made, or
            %   flushWrites is called:
            %       b = qdac.batch();  ...scpiWrite calls...;  clear b
            obj.batchDepth = obj.batchDepth + 1;
            c = onCleanup(@() obj.endBatch());
        end

        function stats = QDACMeasureLatency(obj, opts)
            % QDACMEASURELATENCY  Communication timing, to locate overhead.
            %   (a) one query round trip (*STB?)
            %   (b) 12 separate writes followed by a query
            %   (c) the same 12 writes sent as one batch, then a query
            %   If (b) >> (a) + small, the link suffers per-packet stalls
            %   (Nagle / delayed ACK) and batching is what helps.
            %   The probe re-writes channel 1's present SWE:COUNt value: no
            %   effect unless a sweep runs on channel 1 - do not run it then.
            arguments
                obj
                opts.N    (1,1) double {mustBeInteger, mustBePositive} = 50
                opts.Plot (1,1) logical = true
            end
            probe = sprintf('SOUR1:SWE:COUN %s', strtrim(obj.scpiQuery('SOUR1:SWE:COUN?')));
            nW = 12;
            tQ = zeros(opts.N, 1); tW = tQ; tB = tQ;
            oldBatch = obj.batchWrites;
            restore = onCleanup(@() obj.setBatchWrites(oldBatch)); 
            for k = 1:opts.N
                t = tic; obj.scpiQuery('*STB?'); tQ(k) = toc(t);
            end
            obj.batchWrites = false;
            for k = 1:opts.N
                t = tic;
                for j = 1:nW, obj.scpiWrite(probe); end
                obj.scpiQuery('*STB?');
                tW(k) = toc(t);
            end
            obj.batchWrites = true;
            for k = 1:opts.N
                t = tic;
                b = obj.batch();
                for j = 1:nW, obj.scpiWrite(probe); end
                clear b
                obj.scpiQuery('*STB?');
                tB(k) = toc(t);
            end
            obj.checkErrors('QDACMeasureLatency');
            stats = struct('queryMs', 1e3 * median(tQ), ...
                           'writes12PlusQueryMs', 1e3 * median(tW), ...
                           'batch12PlusQueryMs', 1e3 * median(tB));
            fprintf(['QDAC latency (median of %d): query %.2f ms | 12 writes + query %.2f ms ' ...
                     '| batched 12 writes + query %.2f ms\n'], opts.N, stats.queryMs, ...
                     stats.writes12PlusQueryMs, stats.batch12PlusQueryMs);
            if opts.Plot
                figure('Name', 'QDAC latency', 'Color', 'w'); hold on;
                data   = 1e3 * [tQ tW tB];
                labels = {'1 query', '12 writes + query', 'batched 12 + query'};
                for g = 1:3
                    x = g + 0.15 * (rand(opts.N, 1) - 0.5);       % jitter
                    plot(x, data(:, g), '.', 'MarkerSize', 10);
                    plot(g + [-0.25 0.25], median(data(:, g)) * [1 1], 'k-', 'LineWidth', 2);
                end
                set(gca, 'XTick', 1:3, 'XTickLabel', labels, 'YScale', 'log');
                xlim([0.5 3.5]); ylabel('Time (ms)'); grid on;
                title('SCPI timing (black bar = median)');
            end
        end

        function resp = scpiQuery(obj, cmd)
            % SCPIQUERY  Send a query and return the response line (char).
            %   Queued batch writes are sent first, preserving command order.
            cmd = char(cmd);
            obj.flushWrites();
            flush(obj.client, "input");
            obj.logCommand(cmd);
            if obj.verbose, fprintf('>> %s\n', cmd); end
            writeline(obj.client, cmd);
            resp = readline(obj.client);
            if isempty(resp) || ismissing(resp)
                error('QDAC:timeout', ['No response to "%s". If this was a bad command ' ...
                    'the instrument queues an error instead of answering; check ' ...
                    'queryQDACError.'], cmd);
            end
            resp = strtrim(char(resp));
            if obj.verbose, fprintf('<< %s\n', resp); end
        end

        function checkErrors(obj, context)
            % CHECKERRORS  Read (and clear) the error queue; throw if not empty.
            if nargin < 2, context = ''; end
            resp = obj.scpiQuery('SYST:ERR:ALL?');
            if QDAC.errorCode(resp) ~= 0
                recent = obj.scpiLog(max(1, end-9):end);
                error('QDAC:deviceError', 'Instrument error after %s:\n  %s\nRecent SCPI:\n  %s', ...
                    context, resp, strjoin(recent, '\n  '));
            end
        end
    end

    % =====================================================================
    %  PRIVATE HELPERS
    % =====================================================================
    methods (Access = private)
        function ensureSlewCache(obj)
            % Fill channelSlew from the instrument if it is missing or the
            % wrong size. Happens for objects created before the property
            % existed: MATLAB adds new properties to live objects as [] when
            % the class file changes.
            if numel(obj.channelSlew) ~= obj.numChannels || any(isnan(obj.channelSlew))
                obj.channelSlew = QDACGetSlewRate(obj, 1:obj.numChannels);
            end
        end

        function setBatchWrites(obj, v)
            obj.batchWrites = v;
        end

        function endBatch(obj)
            obj.batchDepth = max(0, obj.batchDepth - 1);
            if obj.batchDepth == 0, obj.flushWrites(); end
        end

        function setClientTimeout(obj, t)
            if ~isempty(obj.client), obj.client.Timeout = t; end
        end

        function finish(obj, context)
            if obj.autoCheckErrors
                obj.checkErrors(context);
            end
        end

        function logCommand(obj, cmd)
            obj.scpiLog{end+1} = cmd;
            if numel(obj.scpiLog) > QDAC.SCPI_LOG_LENGTH
                obj.scpiLog = obj.scpiLog(end-QDAC.SCPI_LOG_LENGTH+1:end);
            end
        end

        function writeGrouped(obj, stem, channels, values)
            % One command per distinct value, with a channel list.
            % 'values' is numeric or a cellstr, scalar or one per channel.
            if isnumeric(values)
                values = QDAC.expand(values, numel(channels));
                strs = arrayfun(@QDAC.fmtNum, values, 'UniformOutput', false);
            else
                strs = cellstr(values);
                if isscalar(strs), strs = repmat(strs, 1, numel(channels)); end
            end
            [u, ~, idx] = unique(strs);
            for k = 1:numel(u)
                obj.scpiWrite(sprintf('%s %s,%s', stem, u{k}, QDAC.chanList(channels(idx == k))));
            end
        end

        function out = queryList(obj, stem, channels)
            % Query a per-channel value; returns a 1 x n cellstr in the order
            % of 'channels'. The list is sent sorted, so the reply order is
            % unambiguous; falls back to per-channel queries if the reply does
            % not split into one item per channel.
            [sortedCh, ~, back] = unique(channels);
            resp  = obj.scpiQuery(sprintf('%s %s', stem, QDAC.chanList(sortedCh)));
            parts = strtrim(strsplit(resp, ','));
            if numel(parts) ~= numel(sortedCh)
                parts = arrayfun(@(c) obj.scpiQuery(sprintf('%s %s', stem, QDAC.chanList(c))), ...
                    sortedCh, 'UniformOutput', false);
            end
            out = reshape(parts(back), 1, []);
        end

        function v = queryNum(obj, stem, channels)
            v = QDAC.parseNum(obj.queryList(stem, channels));
        end

        function writeBinaryBlock(obj, prefix, values)
            % prefix + IEEE 488.2 definite-length block of float32 + LF.
            payload = typecast(single(values(:).'), 'uint8');
            [~, ~, endian] = computer;
            if endian == 'B'   % big-endian host: swap to little-endian
                payload = typecast(swapbytes(single(values(:).')), 'uint8');
            end
            lenStr = sprintf('%d', numel(payload));
            header = sprintf('#%d%s', numel(lenStr), lenStr);
            obj.flushWrites();
            obj.logCommand(sprintf('%s%s<%d float32>', prefix, header, numel(values)));
            if obj.verbose, fprintf('>> %s%s<%d float32>\n', prefix, header, numel(values)); end
            write(obj.client, [uint8([prefix header]) payload uint8(10)], "uint8");
        end

        function startDCSweep(obj, ch)
            cl = QDAC.chanList(ch);
            obj.scpiWrite(['SOUR:DC:INIT:CONT OFF,' cl]);
            obj.scpiWrite(['SOUR:DC:TRIG:SOUR IMM,' cl]);
            obj.scpiWrite(['SOUR:DC:MODE SWE,' cl]);   % bumpless (cmd ref)
            obj.scpiWrite(['SOUR:DC:INIT ' cl]);
        end

        function softwareRamp(obj, ch, v0, vT, numSteps, dwell)
            % MATLAB-stepped linear ramp in FIXed mode (used for FILTer = DC):
            % numSteps equal increments from v0 to vT, one TCP write per step.
            obj.scpiWrite(['SOUR:DC:MODE FIX,' QDAC.chanList(ch)]);
            for k = 1:numSteps
                vk = v0 + (vT - v0) * k / numSteps;
                b = obj.batch(); 
                obj.writeGrouped('SOUR:VOLT', ch, vk);
                clear b
                pause(dwell);
            end
        end

        function [tExpected, tTimeout] = estimateRampTime(obj, ch, v0, vT, programmedTime)
            % From cached slew rates - no instrument queries (except once, if
            % the cache is missing, e.g. for an object created by an older
            % version of this class).
            % tExpected: when the outputs should be at target;
            % tTimeout : generous limit, 2 x tExpected + 2 s.
            obj.ensureSlewCache();
            slew  = min(obj.channelSlew(ch), QDAC.MAX_SLEW);
            tSlew = max(abs(vT - v0) ./ slew);
            tExpected = max(programmedTime, tSlew);
            tTimeout  = 2 * (programmedTime + tSlew) + 2;
        end

        function warnIfClipping(obj, ch, names, scale, offset)
            % Expected peak |V_DC + offset| + |scale| * max|trace| vs. range.
            for k = 1:numel(ch)
                if ~isKey(obj.traceMaxAbs, names{k}), continue; end
                vdc  = obj.channelVoltages(ch(k)) + offset(k);
                amp  = abs(scale(k)) * obj.traceMaxAbs(names{k});
                lim  = obj.rangeLimits.(obj.channelRange{ch(k)})(:, ch(k));
                if vdc + amp > lim(2) || vdc - amp < lim(1)
                    warning('QDAC:awgClipping', ...
                        ['ch %d: DC %+.3f V + AWG peak %.3f V exceeds range [%g, %g] V; ' ...
                         'the output will clip silently.'], ch(k), vdc, amp, lim(1), lim(2));
                end
            end
        end

        function syncTraceMaps(obj)
            % Drop locally known traces that are no longer on the instrument.
            onInstr = QDACTraceCatalog(obj);
            k = keys(obj.traceSizes);
            gone = k(~ismember(k, onInstr));
            if ~isempty(gone)
                remove(obj.traceSizes, gone);
                remove(obj.traceMaxAbs, gone(isKey(obj.traceMaxAbs, gone)));
            end
        end

        function ch = checkChannels(obj, ch)
            if ~isnumeric(ch) || isempty(ch) || any(mod(ch(:), 1) ~= 0) || ...
                    any(ch(:) < 1) || any(ch(:) > obj.numChannels)
                error('QDAC:badChannel', 'Channels must be integers 1 ... %d.', obj.numChannels);
            end
            ch = double(ch(:).');
            if numel(unique(ch)) ~= numel(ch)
                error('QDAC:duplicateChannel', 'Channel list contains duplicates: %s.', mat2str(ch));
            end
        end

        function [ch, v] = checkChannelsVoltages(obj, ch, v)
            ch = obj.checkChannels(ch);
            v  = QDAC.expand(v, numel(ch));
            if any(~isfinite(v))
                error('QDAC:badVoltage', 'Voltages must be finite.');
            end
            for k = 1:numel(ch)
                lim = obj.rangeLimits.(obj.channelRange{ch(k)})(:, ch(k));
                if v(k) < lim(1) || v(k) > lim(2)
                    error('QDAC:voltageRange', ...
                        'ch %d: %+.6f V is outside the %s range [%g, %g] V.', ...
                        ch(k), v(k), obj.channelRange{ch(k)}, lim(1), lim(2));
                end
            end
        end
    end

    % =====================================================================
    %  STATIC HELPERS (formatting, parsing, validation, plotting)
    % =====================================================================
    methods (Static)
        function s = chanList(ch)
            % CHANLIST  [1 2 3 7] -> '(@1:3,7)'. Sorted, consecutive runs compressed.
            ch = sort(ch(:).');
            parts = {};
            i = 1;
            while i <= numel(ch)
                j = i;
                while j < numel(ch) && ch(j+1) == ch(j) + 1, j = j + 1; end
                if j > i
                    parts{end+1} = sprintf('%d:%d', ch(i), ch(j)); %#ok<AGROW>
                else
                    parts{end+1} = sprintf('%d', ch(i)); %#ok<AGROW>
                end
                i = j + 1;
            end
            s = ['(@' strjoin(parts, ',') ')'];
        end

        function s = fmtNum(v)
            % FMTNUM  9 significant digits (num2str kept only ~5: up to 50 uV error).
            if isinf(v)
                s = 'INF';
            else
                s = sprintf('%.9g', v);
            end
        end

        function v = parseNum(c)
            % PARSENUM  cellstr -> double row; 'INF' -> Inf.
            c = regexprep(cellstr(c), '^\s*\+?inf(inity)?\s*$', 'Inf', 'ignorecase');
            c = regexprep(c, '^\s*-inf(inity)?\s*$', '-Inf', 'ignorecase');
            v = reshape(str2double(c), 1, []);
        end

        function code = errorCode(resp)
            code = str2double(strtok(char(resp), ','));
            if isnan(code), code = -1; end
        end

        function x = expand(x, n)
            x = double(x(:).');
            if isscalar(x), x = repmat(x, 1, n); end
            if numel(x) ~= n
                error('QDAC:sizeMismatch', 'Expected a scalar or %d values, got %d.', n, numel(x));
            end
        end

        function d = checkDwell(d)
            % Dwell / ramp time: 2 us ... 36000 s, rounded to whole microseconds
            % (non-integer multiples give uneven steps, cmd ref).
            if ~isscalar(d) || ~isfinite(d) || d < QDAC.MIN_DWELL || d > QDAC.MAX_DWELL
                error('QDAC:badDwell', 'Dwell must be %g ... %g s (got %g).', ...
                    QDAC.MIN_DWELL, QDAC.MAX_DWELL, d);
            end
            d = round(d / QDAC.SAMPLE_PERIOD) * QDAC.SAMPLE_PERIOD;
        end

        function c = countArg(c)
            if isinf(c) || c == -1
                c = -1;
            elseif c < 1 || mod(c, 1) ~= 0 || c > 16777215
                error('QDAC:badCount', 'Count must be an integer 1 ... 16777215 or Inf.');
            end
        end

        function r = normalizeRange(r)
            r = upper(strtrim(char(r)));
            if startsWith(r, 'LOW'), r = 'LOW'; elseif startsWith(r, 'HIGH'), r = 'HIGH'; end
        end

        function f = normalizeFilter(f)
            f = upper(strtrim(char(f)));
            if startsWith(f, 'DC'), f = 'DC';
            elseif startsWith(f, 'MED'), f = 'MED';
            elseif startsWith(f, 'HIGH'), f = 'HIGH';
            end
        end

        function checkTraceName(s)
            if ~(ischar(s) || isstring(s)) || isempty(char(s)) || ...
                    numel(char(s)) > QDAC.MAX_TRACE_NAME || ...
                    isempty(regexp(char(s), '^[A-Za-z0-9_\-]+$', 'once'))
                error('QDAC:badTraceName', ...
                    'Trace names: 1-%d characters from A-Z a-z 0-9 _ - (got "%s").', ...
                    QDAC.MAX_TRACE_NAME, char(s));
            end
        end

        function checkInternalTrigger(n)
            if ~isscalar(n) || mod(n,1) ~= 0 || n < 1 || n > QDAC.N_INTERNAL_TRIGGERS
                error('QDAC:badTrigger', 'Internal trigger must be 1 ... %d.', QDAC.N_INTERNAL_TRIGGERS);
            end
        end

        function src = triggerSource(t)
            % Number -> 'INTn'; accepts IMM, BUS, HOLD, INTn, EXTn (case-insensitive).
            if isnumeric(t)
                QDAC.checkInternalTrigger(t);
                src = sprintf('INT%d', t);
                return
            end
            src = upper(strtrim(char(t)));
            tok = regexp(src, '^(IMM|BUS|HOLD)$|^INT(\d+)$|^EXT(\d)$', 'tokens', 'once');
            if isempty(tok)
                error('QDAC:badTriggerSource', 'Trigger source "%s" not recognised.', src);
            end
            if startsWith(src, 'INT'), QDAC.checkInternalTrigger(str2double(src(4:end))); end
            if startsWith(src, 'EXT') && ~any(str2double(src(4:end)) == 1:4)
                error('QDAC:badTriggerSource', 'External trigger inputs are EXT1 ... EXT4.');
            end
        end

        function g = generatorKeyword(g)
            g = upper(strtrim(char(g)));
            map = {'DC','DC'; 'SIN','SINE'; 'SINE','SINE'; 'SQU','SQU'; 'SQUARE','SQU'; ...
                   'TRI','TRI'; 'TRIANGLE','TRI'; 'AWG','AWG'};
            k = find(strcmp(map(:,1), g), 1);
            if isempty(k), error('QDAC:badGenerator', 'Generator must be DC, SINE, SQU, TRI or AWG.'); end
            g = map{k, 2};
        end

        function m = markerKeyword(m, gen)
            m = upper(strtrim(char(m)));
            map = {'START','STAR'; 'STAR','STAR'; 'END','END'; 'PSTART','PST'; 'PST','PST'; ...
                   'PEND','PEND'; 'SSTART','SST'; 'SST','SST'; 'SEND','SEND'};
            k = find(strcmp(map(:,1), m), 1);
            if isempty(k), error('QDAC:badMarker', 'Unknown marker "%s".', m); end
            m = map{k, 2};
            if any(strcmp(m, {'SST','SEND'})) && ~strcmp(gen, 'DC')
                error('QDAC:badMarker', 'SSTART/SEND markers exist only for the DC generator.');
            end
        end

        % ---------------------------- plotting ------------------------------
        function fig = plotLeakage(R, channels, dV)
            % PLOTLEAKAGE  log10 resistance map; row = driven gate, col = sensed gate.
            fig = figure('Name', 'QDAC leakage matrix', 'Color', 'w');
            L = log10(R);
            L(~isfinite(L)) = NaN;
            imagesc(L, 'AlphaData', ~isnan(L));
            axis image;
            set(gca, 'XTick', 1:numel(channels), 'XTickLabel', channels, ...
                     'YTick', 1:numel(channels), 'YTickLabel', channels, 'Color', [0.85 0.85 0.85]);
            xlabel('Sensed channel j');
            ylabel('Driven channel i');
            cb = colorbar;
            cb.Label.String = 'log_{10}(R_{ij} / \Omega)';
            colormap(parula);
            title(sprintf('Leakage matrix, \\DeltaV = %g mV  (grey: no measurable \\DeltaI)', dV * 1e3));
        end

        function fig = plotMonitorScan(T)
            % PLOTMONITORSCAN  Readback vs. set (and monitor vs. readback if measured).
            fig = figure('Name', 'QDAC monitor scan', 'Color', 'w');
            tiledlayout(2, 1, 'TileSpacing', 'compact');
            nexttile;
            plot(T.Channel, T.SetV, 'o', T.Channel, T.ReadbackV, 'x', 'MarkerSize', 8, 'LineWidth', 1.2);
            hold on;
            if any(~isnan(T.MonitorV)), plot(T.Channel, T.MonitorV, 's', 'MarkerSize', 8); end
            grid on; ylabel('Voltage (V)');
            legend({'set (cache)', 'readback (SOUR:VOLT?)', 'monitor port'}, 'Location', 'best');
            nexttile;
            if any(~isnan(T.MonitorV))
                bar(T.Channel, 1e6 * T.MonitorMinusReadbackV);
                ylabel('V_{monitor} - V_{readback} (\muV)');
            else
                bar(T.Channel, 1e6 * (T.ReadbackV - T.SetV));
                ylabel('V_{readback} - V_{set} (\muV)');
            end
            grid on; xlabel('Channel');
        end

        function fig = plotDiagnostics(D)
            % PLOTDIAGNOSTICS  Voltages, |currents| and board temperatures.
            fig = figure('Name', 'QDAC diagnostics', 'Color', 'w');
            tiledlayout(1, 3, 'TileSpacing', 'compact');
            nexttile; bar(D.channels.Channel, D.channels.Voltage_V);
            grid on; xlabel('Channel'); ylabel('V_{DC} (V)'); title('DC output');
            nexttile; semilogy(D.channels.Channel, abs(D.channels.Current_A), 'o-');
            grid on; xlabel('Channel'); ylabel('|I| (A)'); title('Current sensor');
            nexttile; imagesc(D.temperatureC); colorbar; axis image;
            set(gca, 'XTick', 1:3, 'XTickLabel', {'L','M','R'}, 'YTick', 1:3, ...
                'YTickLabel', {'ch 1-8','ch 9-16','ch 17-24'});
            title('Board temperature (\circC)');
        end

        function fig = plotTraces(traces, names, opts)
            % PLOTTRACES  Preview normalised AWG traces (1 us per sample).
            %   traces: cell array of vectors; names: cellstr.
            %   'Scale' [V] per trace (default 1) to show output volts;
            %   'Zoom'  [t0 t1] in seconds for a second, zoomed panel.
            arguments
                traces cell
                names  cell
                opts.Scale double = 1
                opts.Zoom  double = []
            end
            scale = QDAC.expand(opts.Scale, numel(traces));
            fig = figure('Name', 'QDAC AWG traces', 'Color', 'w');
            nTiles = 1 + ~isempty(opts.Zoom);
            tiledlayout(nTiles, 1, 'TileSpacing', 'compact');
            for tile = 1:nTiles
                nexttile; hold on;
                for k = 1:numel(traces)
                    t = (0:numel(traces{k}) - 1) * QDAC.SAMPLE_PERIOD;
                    plot(t * 1e3, scale(k) * traces{k}, 'LineWidth', 1.1);
                end
                grid on; xlabel('Time (ms)');
                if all(scale == 1), ylabel('Normalised amplitude'); else, ylabel('AWG output (V)'); end
                if tile == 2
                    xlim(opts.Zoom * 1e3); title('Zoom');
                else
                    title('AWG traces (1 MS/s)');
                    legend(names, 'Interpreter', 'none', 'Location', 'eastoutside');
                end
            end
        end
    end
end