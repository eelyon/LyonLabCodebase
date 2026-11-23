classdef Agilent33220A < handle
    %AGILENT33220A  SCPI driver for the Agilent/Keysight 33220A 20 MHz function/AWG.
    %
    %   Backward-compatible interface: the constructor signature and all method
    %   names of the original driver (set33220*, query33220*, send33220Trigger,
    %   setAgilent33220APresetConfig) are preserved, so existing scripts run
    %   unchanged. New methods follow the same <verb>33220<Noun> convention.
    %
    %   awg = Agilent33220A(5025, '192.168.1.50');           % raw SCPI socket
    %   awg = Agilent33220A([],   '192.168.1.50', 'visa');   % VISA (any 3rd argument)
    %   awg.LoadResistance = 50;                             % physical load [Ohm]
    %   setAgilent33220APresetConfig(awg, 'Filament');
    %   plot33220Config(awg);                                % EMF, V_L and P_L(t)
    %   fire33220Burst(awg);                                 % ON -> *TRG -> wait -> OFF
    %
    %   Behavioural differences from the original driver
    %     * set33220Output / set33220OutputOnOff accept 'ON'/'OFF' text. (The
    %       original sent OUTP ON for any text, including 'OFF'.)
    %     * Invalid arguments and instrument-side SCPI errors raise MATLAB errors
    %       instead of printing a message and continuing. Set CheckErrors = false
    %       to skip the SYST:ERR? read-back after each command.
    %     * Text-returning queries return trimmed char vectors (no trailing LF).
    %     * Presets program OUTP:LOAD before any level (see set33220OutputLoad).
    %     * awg.client is a tcpclient/visadev object: use send33220Command /
    %       query33220Command instead of fprintf(awg.client,...) / query(awg.client,...).
    %
    %   Source model (Thevenin):  V_emf = V_prog (R_s + R_set)/R_set   (R_set = OUTP:LOAD)
    %                             V_L   = V_emf  R_L/(R_s + R_L)       (R_L = LoadResistance)
    %
    %   Requires MATLAB R2021a or newer (tcpclient / visadev, writeline / writeread).

    properties (Constant)
        SourceImpedance = 50        % Thevenin output impedance R_s [Ohm]
        ErrorQueueDepth = 20        % depth of the 33220A SCPI error queue
        InfResponse     = 9.9e37    % value returned by queries for INF / high-Z
        MaxBurstCycles  = 50000     % BURS:NCYC upper limit
        DefaultTimeout  = 5         % I/O timeout [s]
    end

    properties (SetAccess = private)
        IPAddress
        port        {mustBeNumeric} = []
        client                          % tcpclient or visadev object
        identifier  = '33220A'
        interface   = ''                % 'socket' or 'visa'
        IDN         = ''                % *IDN? response
    end

    properties
        LoadResistance (1,1) double  {mustBePositive} = 50   % physical load R_L [Ohm]
        CheckErrors    (1,1) logical = true                   % read SYST:ERR? after each set
    end

    methods
        %% ================================================================ Connection
        function obj = Agilent33220A(port, IPAddress, opt) %#ok<INUSD>
            % Agilent33220A(port, IPAddress)       raw SCPI socket on <port> (normally 5025)
            % Agilent33220A(port, IPAddress, opt)  VISA: TCPIP0::<IPAddress>::inst0::INSTR
            %                                      (any third argument selects VISA, as before)
            if nargin < 2
                error("Agilent33220A:args", "Usage: Agilent33220A(port, IPAddress[, opt]).");
            end
            obj.IPAddress = char(IPAddress);
            obj.port      = port;

            if nargin >= 3
                obj.interface = 'visa';
                obj.client = visadev("TCPIP0::" + string(obj.IPAddress) + "::inst0::INSTR");
                obj.client.Timeout = obj.DefaultTimeout;
            else
                validateattributes(port, {'numeric'}, {'scalar', 'integer', 'positive'});
                obj.interface = 'socket';
                obj.client = tcpclient(obj.IPAddress, port, "Timeout", obj.DefaultTimeout);
            end
            configureTerminator(obj.client, "LF");

            obj.IDN = query33220Command(obj, '*IDN?');
            if ~contains(obj.IDN, '33220A')
                warning("Agilent33220A:unexpectedIDN", ...
                    "Connected instrument identifies as '%s', not a 33220A.", obj.IDN);
            end
            send33220Command(obj, '*CLS');
        end

        function delete(obj)
            % Releasing the client closes the session. The output state is left
            % unchanged so that clearing the object mid-run does not switch the relay.
            obj.client = [];
        end

        %% ================================================================ Low-level I/O
        function send33220Command(obj, command)
            %SEND33220COMMAND  Send one LF-terminated SCPI command (no error check).
            writeline(obj.client, command);
        end

        function response = query33220Command(obj, command)
            %QUERY33220COMMAND  Send a SCPI query; returns the trimmed response (char).
            response = strtrim(char(writeread(obj.client, command)));
        end

        function value = query33220Number(obj, command)
            %QUERY33220NUMBER  Numeric query; the INF sentinel (9.9E+37) maps to Inf.
            value = str2double(query33220Command(obj, command));
            if value >= obj.InfResponse
                value = Inf;
            end
        end

        function errs = query33220Errors(obj)
            %QUERY33220ERRORS  Drain the SCPI error queue; string column, empty if clean.
            errs = strings(0, 1);
            for k = 1:obj.ErrorQueueDepth
                entry = string(query33220Command(obj, 'SYST:ERR?'));
                code  = str2double(extractBefore(entry, ","));
                if isnan(code) || code == 0
                    break
                end
                errs(end+1, 1) = entry; %#ok<AGROW>
            end
        end

        function check33220Errors(obj, context)
            %CHECK33220ERRORS  Raise a MATLAB error if the instrument queued SCPI errors.
            if nargin < 2, context = "33220A"; end
            errs = query33220Errors(obj);
            if ~isempty(errs)
                error("Agilent33220A:instrumentError", "%s\n  %s", ...
                    context, strjoin(errs, newline + "  "));
            end
        end

        function reset33220(obj)
            %RESET33220  *RST + *CLS, block until done. Leaves output OFF, load 50 Ohm.
            send33220Command(obj, '*RST');
            send33220Command(obj, '*CLS');
            wait33220Complete(obj);
        end

        function wait33220Complete(obj)
            %WAIT33220COMPLETE  Block until all pending operations finish (*OPC?).
            query33220Command(obj, '*OPC?');
        end

        %% ================================================================ Presets
        function setAgilent33220APresetConfig(obj, experimentType)
            %SETAGILENT33220APRESETCONFIG  'Filament' | 'Compensate' | 'Door'.
            %   Deterministic: *RST first, OUTP:LOAD before any level, error queue checked.
            cfg = Agilent33220A.get33220PresetDefinition(experimentType);

            set33220Output(obj, 0);                     % never reconfigure a live output
            reset33220(obj);
            set33220OutputLoad(obj, cfg.LoadSetting);   % MUST precede every level command
            set33220FunctionType(obj, cfg.Function);

            switch cfg.Function
                case 'PULS'
                    set33220PulsePeriod(obj, cfg.Period);
                    if isfield(cfg, 'Width')
                        set33220PulseWidth(obj, cfg.Width);
                    else
                        set33220PulseDutyCycle(obj, cfg.DutyCycle);
                    end
                    set33220PulseRiseTime(obj, cfg.EdgeTime);
                    set33220VoltageHighAndLow(obj, cfg.VLow, cfg.VHigh);
                case 'SIN'
                    set33220Frequency(obj, cfg.Frequency);
                    set33220Amplitude(obj, cfg.Amplitude, cfg.AmplitudeUnit);
                    set33220VoltageOffset(obj, cfg.Offset);
                    set33220Phase(obj, cfg.Phase);
            end

            if cfg.Burst
                set33220BurstMode(obj, 'TRIG');
                set33220NumBurstCycles(obj, cfg.NumCycles);
                set33220TriggerSource(obj, cfg.TriggerSource);
                set33220TrigSlope(obj, 'POS');
                set33220BurstStateOn(obj, 1);
            else
                set33220BurstStateOn(obj, 0);
            end

            wait33220Complete(obj);
            check33220Errors(obj, "setAgilent33220APresetConfig(" + string(experimentType) + ")");
        end

        %% ================================================================ Output stage
        function set33220Output(obj, OnOff)
            %SET33220OUTPUT  Output relay. OnOff: true/false, 1/0 or 'ON'/'OFF'.
            state = onOffArg(OnOff);
            writeChecked(obj, "OUTP " + state, "set33220Output");
            if query33220OutputOnOff(obj) ~= (state == "ON")
                error("Agilent33220A:outputMismatch", ...
                    "Output read-back does not match requested state %s.", state);
            end
        end

        function set33220OutputOnOff(obj, onOrOff)
            %SET33220OUTPUTONOFF  Alias of set33220Output (kept for compatibility).
            set33220Output(obj, onOrOff);
        end

        function set33220OutputLoad(obj, Ohms)
            %SET33220OUTPUTLOAD  Declared load: numeric 1..10e3 [Ohm] or 'INF'/'MIN'/'MAX'.
            %   Does not change the 50-Ohm source impedance; it sets
            %   V_emf = V_prog (R_s + R_set)/R_set. Changing it rescales the displayed
            %   levels while keeping the physical output, so call it BEFORE any level.
            if isnumeric(Ohms)
                validateattributes(Ohms, {'numeric'}, {'scalar', 'real', '>=', 1, '<=', 10e3});
                arg = fmt(Ohms);
            else
                arg = upper(string(validatestring(Ohms, ["INFinity", "MINimum", "MAXimum"])));
            end
            writeChecked(obj, "OUTP:LOAD " + arg, "set33220OutputLoad");
        end

        function set33220InvertOutput(obj, OnOff)
            %SET33220INVERTOUTPUT  true/'ON' -> inverted polarity, false/'OFF' -> normal.
            if onOffArg(OnOff) == "ON"
                arg = "INV";
            else
                arg = "NORM";
            end
            writeChecked(obj, "OUTP:POL " + arg, "set33220InvertOutput");
        end

        function set33220TriggerOutput(obj, onOrOff)
            %SET33220TRIGGEROUTPUT  Rear-panel trigger-out signal.
            writeChecked(obj, "OUTP:TRIG " + onOffArg(onOrOff), "set33220TriggerOutput");
        end

        %% ================================================================ Waveform
        function set33220FunctionType(obj, type)
            %SET33220FUNCTIONTYPE  'SIN','SQU','RAMP','PULS','NOIS','DC','USER'.
            type = upper(string(validatestring(type, ...
                ["SINusoid", "SQUare", "RAMP", "PULSe", "NOISe", "DC", "USER"])));
            writeChecked(obj, "FUNC " + type, "set33220FunctionType");
        end

        function set33220Frequency(obj, frequencyInHz)
            validateattributes(frequencyInHz, {'numeric'}, {'scalar', 'positive', 'finite'});
            writeChecked(obj, "FREQ " + fmt(frequencyInHz), "set33220Frequency");
        end

        function set33220Phase(obj, phaseInDegrees)
            validateattributes(phaseInDegrees, {'numeric'}, {'scalar', 'real', 'finite'});
            writeChecked(obj, "UNIT:ANGL DEG", "set33220Phase");
            writeChecked(obj, "PHAS " + fmt(phaseInDegrees), "set33220Phase");
        end

        %% ================================================================ Pulse timing
        function set33220PulsePeriod(obj, periodInSeconds)
            validateattributes(periodInSeconds, {'numeric'}, {'scalar', 'positive', 'finite'});
            writeChecked(obj, "PULS:PER " + fmt(periodInSeconds), "set33220PulsePeriod");
        end

        function set33220PulseWidth(obj, widthInSeconds)
            %SET33220PULSEWIDTH  50%-to-50% width; width is held on later period changes.
            validateattributes(widthInSeconds, {'numeric'}, {'scalar', 'positive', 'finite'});
            writeChecked(obj, "FUNC:PULS:HOLD WIDT", "set33220PulseWidth");
            writeChecked(obj, "FUNC:PULS:WIDT " + fmt(widthInSeconds), "set33220PulseWidth");
        end

        function set33220PulseDutyCycle(obj, dutyCycle)
            %SET33220PULSEDUTYCYCLE  Percent; duty cycle is held on later period changes.
            validateattributes(dutyCycle, {'numeric'}, {'scalar', '>', 0, '<', 100});
            writeChecked(obj, "FUNC:PULS:HOLD DCYC", "set33220PulseDutyCycle");
            writeChecked(obj, "FUNC:PULS:DCYC " + fmt(dutyCycle), "set33220PulseDutyCycle");
        end

        function set33220PulseRiseTime(obj, riseTime)
            %SET33220PULSERISETIME  10-90 % edge time, applied to BOTH edges (>= 5 ns,
            %   <= 0.625 x width).
            validateattributes(riseTime, {'numeric'}, {'scalar', 'positive', 'finite'});
            writeChecked(obj, "FUNC:PULS:TRAN " + fmt(riseTime), "set33220PulseRiseTime");
        end

        %% ================================================================ Voltages
        function set33220Amplitude(obj, amplitude, voltType)
            %SET33220AMPLITUDE  Amplitude in 'VPP' (default), 'VRMS' or 'DBM',
            %   referenced to the OUTP:LOAD setting. Limits are enforced by the instrument.
            if nargin < 3, voltType = 'VPP'; end
            validateattributes(amplitude, {'numeric'}, {'scalar', 'real', 'finite'});
            voltType = upper(string(validatestring(voltType, ["VPP", "VRMS", "DBM"])));
            if voltType == "DBM" && isinf(query33220OutputLoad(obj))
                error("Agilent33220A:dbmHighZ", ...
                    "dBm is undefined for OUTP:LOAD INF; use VPP or VRMS.");
            end
            writeChecked(obj, "VOLT:UNIT " + voltType, "set33220Amplitude");
            writeChecked(obj, "VOLT " + fmt(amplitude), "set33220Amplitude");
        end

        function set33220VoltageHigh(obj, highVoltage)
            %SET33220VOLTAGEHIGH  Single command. Prefer set33220VoltageHighAndLow,
            %   which orders the two writes so HIGH never drops below LOW.
            validateattributes(highVoltage, {'numeric'}, {'scalar', 'real', 'finite'});
            writeChecked(obj, "VOLT:HIGH " + fmt(highVoltage), "set33220VoltageHigh");
        end

        function set33220VoltageLow(obj, lowVoltage)
            %SET33220VOLTAGELOW  Single command (see set33220VoltageHigh).
            validateattributes(lowVoltage, {'numeric'}, {'scalar', 'real', 'finite'});
            writeChecked(obj, "VOLT:LOW " + fmt(lowVoltage), "set33220VoltageLow");
        end

        function set33220VoltageOffset(obj, voltageOffset)
            validateattributes(voltageOffset, {'numeric'}, {'scalar', 'real', 'finite'});
            writeChecked(obj, "VOLT:OFFS " + fmt(voltageOffset), "set33220VoltageOffset");
        end

        function set33220VoltageHighAndLow(obj, lowVoltage, highVoltage)
            %SET33220VOLTAGEHIGHANDLOW  Set both levels without a HIGH <= LOW conflict.
            %   Reversed arguments are swapped (as in the original), now with a warning.
            validateattributes(lowVoltage,  {'numeric'}, {'scalar', 'real', 'finite'});
            validateattributes(highVoltage, {'numeric'}, {'scalar', 'real', 'finite'});
            if lowVoltage == highVoltage
                error("Agilent33220A:levelOrder", "High and low levels must differ.");
            elseif lowVoltage > highVoltage
                warning("Agilent33220A:levelSwap", ...
                    "lowVoltage > highVoltage; swapping to LOW = %g V, HIGH = %g V.", ...
                    highVoltage, lowVoltage);
                [lowVoltage, highVoltage] = deal(highVoltage, lowVoltage);
            end
            present = query33220Levels(obj);               % [low, high] now programmed
            if lowVoltage >= present(2)
                % Target window lies entirely above the present HIGH: raise HIGH first.
                set33220VoltageHigh(obj, highVoltage);
                set33220VoltageLow(obj, lowVoltage);
            else
                set33220VoltageLow(obj, lowVoltage);
                set33220VoltageHigh(obj, highVoltage);
            end
        end

        %% ================================================================ Trigger
        function send33220Trigger(obj)
            %SEND33220TRIGGER  Software (bus) trigger. Requires trigger source BUS.
            writeChecked(obj, "*TRG", "send33220Trigger");
        end

        function set33220TrigSlope(obj, slope)
            %SET33220TRIGSLOPE  'POS' | 'NEG' (edge used for EXTernal triggering).
            slope = upper(string(validatestring(slope, ["POSitive", "NEGative"])));
            writeChecked(obj, "TRIG:SLOP " + slope, "set33220TrigSlope");
        end

        function set33220TriggerSource(obj, sourceType)
            %SET33220TRIGGERSOURCE  'IMM' | 'EXT' | 'BUS'.
            sourceType = upper(string(validatestring(sourceType, ["IMMediate", "EXTernal", "BUS"])));
            writeChecked(obj, "TRIG:SOUR " + sourceType, "set33220TriggerSource");
        end

        function set33220Trigger(obj, sourceType)
            %SET33220TRIGGER  Set the trigger source; if it is BUS, also send *TRG.
            set33220TriggerSource(obj, sourceType);
            if strcmpi(query33220TriggerSourceType(obj), 'BUS')
                send33220Trigger(obj);
            end
        end

        function fire33220Burst(obj, opts)
            %FIRE33220BURST  Output ON -> *TRG -> wait N_cyc*T + margin -> output OFF.
            %   fire33220Burst(awg, PreTriggerDelay=20e-3, Margin=10e-3, LeaveOn=false)
            arguments
                obj
                opts.PreTriggerDelay (1,1) double {mustBeNonnegative} = 20e-3  % relay settling [s]
                opts.Margin          (1,1) double {mustBeNonnegative} = 10e-3  % after burst [s]
                opts.LeaveOn         (1,1) logical = false
            end
            if ~query33220BurstState(obj) || ~strcmpi(query33220TriggerSourceType(obj), 'BUS')
                error("Agilent33220A:notArmed", ...
                    "fire33220Burst requires burst state ON and trigger source BUS.");
            end
            nCycles = query33220NumBurstCycles(obj);
            if isinf(nCycles)
                error("Agilent33220A:infiniteBurst", ...
                    "Infinite burst count: use send33220Trigger/set33220Output manually.");
            end
            if strcmpi(query33220FunctionType(obj), 'PULS')
                cyclePeriod = query33220Number(obj, 'PULS:PER?');
            else
                cyclePeriod = 1 / query33220Frequency(obj);
            end

            set33220Output(obj, 1);
            pause(opts.PreTriggerDelay);
            send33220Trigger(obj);
            pause(nCycles * cyclePeriod + opts.Margin);    % do not truncate the burst
            if ~opts.LeaveOn
                set33220Output(obj, 0);
            end
        end

        %% ================================================================ Burst
        function set33220BurstMode(obj, burstType)
            %SET33220BURSTMODE  'TRIG' | 'GAT'.
            burstType = upper(string(validatestring(burstType, ["TRIGgered", "GATed"])));
            writeChecked(obj, "BURS:MODE " + burstType, "set33220BurstMode");
        end

        function set33220NumBurstCycles(obj, numCycles)
            %SET33220NUMBURSTCYCLES  Integer 1..50000 or 'INF'.
            if (ischar(numCycles) || isstring(numCycles)) && strcmpi(numCycles, 'INF')
                arg = "INF";
            else
                validateattributes(numCycles, {'numeric'}, ...
                    {'scalar', 'integer', '>=', 1, '<=', obj.MaxBurstCycles});
                arg = fmt(numCycles);
            end
            writeChecked(obj, "BURS:NCYC " + arg, "set33220NumBurstCycles");
        end

        function set33220BurstStateOn(obj, onOrOff)
            writeChecked(obj, "BURS:STAT " + onOffArg(onOrOff), "set33220BurstStateOn");
        end

        function set33220BurstPhase(obj, phaseInDegrees)
            validateattributes(phaseInDegrees, {'numeric'}, {'scalar', 'real', 'finite'});
            writeChecked(obj, "BURS:PHAS " + fmt(phaseInDegrees), "set33220BurstPhase");
        end

        %% ================================================================ Queries (original: char return)
        function functionType = query33220FunctionType(obj)
            functionType = query33220Command(obj, 'FUNC?');
        end

        function isOn = query33220Output(obj)
            isOn = query33220Command(obj, 'OUTP?');
        end

        function period = query33220PulsePeriod(obj)
            period = query33220Command(obj, 'PULS:PER?');
        end

        function pulseWidth = query33220PulseWidth(obj)
            pulseWidth = query33220Command(obj, 'FUNC:PULS:WIDT?');
        end

        function trigOutp = query33220TriggerOutput(obj)
            trigOutp = query33220Command(obj, 'OUTP:TRIG?');
        end

        function trigType = query33220TriggerSourceType(obj)
            trigType = query33220Command(obj, 'TRIG:SOUR?');
        end

        function voltage = query33220VoltageHigh(obj)
            voltage = query33220Command(obj, 'VOLT:HIGH?');
        end

        function voltLow = query33220VoltageLow(obj)
            voltLow = query33220Command(obj, 'VOLT:LOW?');
        end

        %% ================================================================ Queries (original: numeric return)
        function amplitude = query33220Amplitude(obj)
            amplitude = query33220Number(obj, 'VOLT?');
        end

        function offset = query33220VoltageOffset(obj)
            offset = query33220Number(obj, 'VOLT:OFFS?');
        end

        function phase = query33220Phase(obj)
            phase = query33220Number(obj, 'PHAS?');
        end

        function frequency = query33220Frequency(obj)
            frequency = query33220Number(obj, 'FREQ?');
        end

        function output = query33220OutputOnOff(obj)
            output = query33220Number(obj, 'OUTP?');
        end

        %% ================================================================ Queries (new, numeric)
        function ohms = query33220OutputLoad(obj)
            %QUERY33220OUTPUTLOAD  Declared load [Ohm]; Inf for high-Z.
            ohms = query33220Number(obj, 'OUTP:LOAD?');
        end

        function edgeTime = query33220PulseRiseTime(obj)
            edgeTime = query33220Number(obj, 'FUNC:PULS:TRAN?');
        end

        function dutyCycle = query33220PulseDutyCycle(obj)
            dutyCycle = query33220Number(obj, 'FUNC:PULS:DCYC?');
        end

        function isOn = query33220BurstState(obj)
            isOn = query33220Number(obj, 'BURS:STAT?') == 1;
        end

        function numCycles = query33220NumBurstCycles(obj)
            numCycles = query33220Number(obj, 'BURS:NCYC?');      % Inf for INF
        end

        function levels = query33220Levels(obj)
            %QUERY33220LEVELS  [vLow, vHigh] referenced to the OUTP:LOAD setting [V].
            levels = [query33220Number(obj, 'VOLT:LOW?'), query33220Number(obj, 'VOLT:HIGH?')];
        end

        function cfg = query33220Config(obj)
            %QUERY33220CONFIG  Waveform-relevant state as a struct (same field names
            %   as get33220PresetDefinition, so it can be passed to plot33220Preview).
            levels = query33220Levels(obj);
            cfg = struct( ...
                'Function',      query33220FunctionType(obj), ...
                'LoadSetting',   query33220OutputLoad(obj), ...
                'VLow',          levels(1), ...
                'VHigh',         levels(2), ...
                'Frequency',     query33220Frequency(obj), ...
                'Phase',         query33220Phase(obj), ...
                'Period',        query33220Number(obj, 'PULS:PER?'), ...
                'Width',         query33220Number(obj, 'FUNC:PULS:WIDT?'), ...
                'EdgeTime',      query33220PulseRiseTime(obj), ...
                'Burst',         query33220BurstState(obj), ...
                'NumCycles',     query33220NumBurstCycles(obj), ...
                'TriggerSource', query33220TriggerSourceType(obj), ...
                'OutputOn',      query33220OutputOnOff(obj) == 1);
        end

        %% ================================================================ Plotting
        function fig = plot33220Config(obj)
            %PLOT33220CONFIG  Preview of the configuration presently in the instrument.
            fig = Agilent33220A.plot33220Preview(query33220Config(obj), obj.LoadResistance);
        end
    end

    methods (Static)
        function cfg = get33220PresetDefinition(experimentType)
            %GET33220PRESETDEFINITION  Data-only description of each experiment preset.
            name = string(validatestring(experimentType, ["Filament", "Compensate", "Door"]));
            switch name
                case "Filament"
                    % Heater pulse into the 50-Ohm resistor. LoadSetting = 50 makes the
                    % programmed levels equal the voltage ACROSS a 50-Ohm load
                    % (3 V -> 180 mW, 3.24 mJ per 18 ms pulse). 'INF' gives 1.5 V / 45 mW.
                    cfg = struct('Function', 'PULS', 'LoadSetting', 50, ...
                        'VLow', 0, 'VHigh', 3, ...
                        'Period', 30e-3, 'DutyCycle', 60, 'EdgeTime', 5e-9, ...
                        'Burst', true, 'NumCycles', 1, 'TriggerSource', 'BUS');
                case "Compensate"
                    % Continuous sine into a high-impedance destination.
                    cfg = struct('Function', 'SIN', 'LoadSetting', 'INF', ...
                        'Frequency', 102e3, 'Amplitude', 300e-3, 'AmplitudeUnit', 'VPP', ...
                        'Offset', 0, 'Phase', 0, 'Burst', false);
                case "Door"
                    cfg = struct('Function', 'PULS', 'LoadSetting', 'INF', ...
                        'VLow', -1, 'VHigh', 0, ...
                        'Period', 200e-3, 'Width', 100e-3, 'EdgeTime', 5e-9, ...
                        'Burst', true, 'NumCycles', 1, 'TriggerSource', 'BUS');
            end
        end

        function [vEmf, vLoad] = calc33220LoadVoltage(vProgrammed, loadSetting, loadResistance)
            %CALC33220LOADVOLTAGE  Vectorized Thevenin model.
            %   V_emf = V_prog (R_s + R_set)/R_set ;  V_L = V_emf R_L/(R_s + R_L)
            Rs   = Agilent33220A.SourceImpedance;
            Rset = loadToOhms(loadSetting);
            if isinf(Rset)
                emfScale = 1;
            else
                emfScale = (Rs + Rset) / Rset;
            end
            vEmf  = emfScale .* vProgrammed;
            vLoad = vEmf .* loadResistance ./ (Rs + loadResistance);
        end

        function fig = plot33220Preview(cfg, loadResistance)
            %PLOT33220PREVIEW  Ideal waveform (EMF, load voltage, programmed value) and
            %   instantaneous power in the load, from a preset or query33220Config struct.
            arguments
                cfg            (1,1) struct
                loadResistance (1,1) double {mustBePositive} = 50
            end
            nPts = 2e5;
            func = upper(string(cfg.Function));

            switch func
                case {"PULS", "PULSE"}
                    T       = cfg.Period;
                    width   = pulseWidth(cfg);
                    tEdge   = cfg.EdgeTime;
                    isBurst = isfield(cfg, 'Burst') && cfg.Burst && isfinite(cfg.NumCycles);
                    if isBurst, nCycles = cfg.NumCycles; else, nCycles = Inf; end
                    nShow = min(nCycles, 5);

                    t = linspace(-0.1*T, (nShow + 0.1)*T, nPts);
                    u = mod(t, T);                                   % phase within cycle
                    rise = min(max(u ./ tEdge, 0), 1);
                    fall = min(max((width + tEdge - u) ./ tEdge, 0), 1);
                    x = min(rise, fall);                             % normalized trapezoid
                    if isBurst
                        x(t < 0 | t >= nCycles*T) = 0;               % idle assumed at VLow
                    end
                    vProg = cfg.VLow + (cfg.VHigh - cfg.VLow) .* x;
                    oneCycle = (t >= 0) & (t < T);

                case {"SIN", "SINUSOID"}
                    f = cfg.Frequency;
                    [vLowS, vHighS] = sineLevels(cfg);
                    phase = 0;
                    if isfield(cfg, 'Phase'), phase = cfg.Phase; end
                    t = linspace(0, 5/f, nPts);
                    vProg = (vHighS + vLowS)/2 + (vHighS - vLowS)/2 .* sin(2*pi*f*t + deg2rad(phase));

                otherwise
                    error("Agilent33220A:previewUnsupported", ...
                        "Preview is implemented for PULS and SIN only (got %s).", func);
            end

            [vEmf, vLoad] = Agilent33220A.calc33220LoadVoltage(vProg, cfg.LoadSetting, loadResistance);
            pLoad = vLoad.^2 ./ loadResistance;                      % [W]

            if func == "SIN" || func == "SINUSOID"
                summary = sprintf("<P_L> = %.4g mW,  P_{peak} = %.4g mW", ...
                    mean(pLoad)*1e3, max(pLoad)*1e3);
            else
                eCycle = trapz(t(oneCycle), pLoad(oneCycle));        % [J]
                if isBurst
                    summary = sprintf("E_{cycle} = %.4g \\muJ,  E_{burst} = %.4g \\muJ,  P_{peak} = %.4g mW", ...
                        eCycle*1e6, nCycles*eCycle*1e6, max(pLoad)*1e3);
                else
                    summary = sprintf("<P_L> = %.4g mW,  P_{peak} = %.4g mW", ...
                        eCycle/T*1e3, max(pLoad)*1e3);
                end
            end

            % ---------------------------------------------------------------- figure
            [tScale, tLabel] = timeScale(max(abs(t)));
            fig = figure('Name', 'Agilent 33220A preview', 'Color', 'w');
            tl  = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

            ax1 = nexttile(tl);
            plot(ax1, t*tScale, vEmf,  '-',  'LineWidth', 1.4); hold(ax1, 'on');
            plot(ax1, t*tScale, vLoad, '--', 'LineWidth', 1.4);
            plot(ax1, t*tScale, vProg, ':',  'LineWidth', 1.2); hold(ax1, 'off');
            grid(ax1, 'on');
            ylabel(ax1, 'Voltage (V)');
            legend(ax1, ["Open-circuit EMF V_{emf}", ...
                         sprintf("Across load V_L (R_L = %g \\Omega)", loadResistance), ...
                         "Programmed / displayed"], 'Location', 'best');
            title(ax1, sprintf("%s  |  OUTP:LOAD = %s  |  R_s = %g \\Omega", ...
                func, loadLabel(cfg.LoadSetting), Agilent33220A.SourceImpedance));

            ax2 = nexttile(tl);
            plot(ax2, t*tScale, pLoad*1e3, 'LineWidth', 1.4);
            grid(ax2, 'on');
            xlabel(ax2, tLabel);
            ylabel(ax2, 'P_L (mW)');
            title(ax2, summary);
            linkaxes([ax1, ax2], 'x');
        end
    end

    methods (Access = private)
        function writeChecked(obj, command, context)
            %WRITECHECKED  Write a command and, if enabled, verify the error queue is empty.
            send33220Command(obj, command);
            if obj.CheckErrors
                check33220Errors(obj, string(context) + ": " + string(command));
            end
        end
    end
end

%% ==================================================================== Local functions
function s = fmt(x)
    % 12 significant digits (num2str keeps ~5 for values < 1).
    s = string(sprintf('%.12g', x));
end

function s = onOffArg(state)
    % Map true/false, 1/0 or 'ON'/'OFF' (any case) to "ON"/"OFF".
    if ischar(state) || isstring(state)
        s = upper(string(validatestring(state, ["ON", "OFF"])));
    elseif (islogical(state) || isnumeric(state)) && isscalar(state) && ismember(double(state), [0 1])
        if state, s = "ON"; else, s = "OFF"; end
    else
        error("Agilent33220A:badState", "State must be true/false, 1/0, or 'ON'/'OFF'.");
    end
end

function r = loadToOhms(loadSetting)
    if isnumeric(loadSetting)
        r = double(loadSetting);
    elseif any(strcmpi(loadSetting, ["INF", "INFINITY"]))
        r = Inf;
    else
        error("Agilent33220A:badLoad", "LoadSetting must be numeric [Ohm] or 'INF'.");
    end
end

function txt = loadLabel(loadSetting)
    r = loadToOhms(loadSetting);
    if isinf(r)
        txt = "INF (high-Z)";
    else
        txt = sprintf("%g \\Omega", r);
    end
end

function w = pulseWidth(cfg)
    if isfield(cfg, 'Width')
        w = cfg.Width;
    else
        w = cfg.DutyCycle/100 * cfg.Period;
    end
end

function [vLow, vHigh] = sineLevels(cfg)
    % Programmed sine extremes from either VLow/VHigh or Amplitude/Unit/Offset.
    if isfield(cfg, 'VHigh') && isfield(cfg, 'VLow')
        vLow = cfg.VLow; vHigh = cfg.VHigh;
        return
    end
    switch upper(string(cfg.AmplitudeUnit))
        case "VPP"
            vPeak = cfg.Amplitude / 2;
        case "VRMS"
            vPeak = sqrt(2) * cfg.Amplitude;
        case "DBM"
            Rset = loadToOhms(cfg.LoadSetting);
            if isinf(Rset)
                error("Agilent33220A:dbmHighZ", "dBm is undefined for a high-Z load setting.");
            end
            vPeak = sqrt(2) * sqrt(1e-3 * 10^(cfg.Amplitude/10) * Rset);
    end
    vLow  = cfg.Offset - vPeak;
    vHigh = cfg.Offset + vPeak;
end

function [scale, label] = timeScale(tMax)
    if tMax >= 1
        scale = 1;   label = "Time (s)";
    elseif tMax >= 1e-3
        scale = 1e3; label = "Time (ms)";
    elseif tMax >= 1e-6
        scale = 1e6; label = "Time (" + char(181) + "s)";
    else
        scale = 1e9; label = "Time (ns)";
    end
end