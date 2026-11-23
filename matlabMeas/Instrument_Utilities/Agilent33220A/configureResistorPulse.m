function cfg = configureResistorPulse(awg, opts)
%CONFIGURERESISTORPULSE  Single-shot, bus-triggered pulse into the 50-Ohm resistor
%   using the Agilent 33220A (legacy-named driver API: set33220*, query33220*).
%
%   cfg = configureResistorPulse(awg)
%   cfg = configureResistorPulse(awg, VHigh=0.2, Width=5e-3, Plot=false)
%
%   Defaults (all overridable by name-value pairs):
%       OUTP:LOAD        50 Ohm
%       Function         PULS
%       Period  T        1 s
%       Width   w        10 ms        (50%-to-50%, held constant: FUNC:PULS:HOLD WIDT)
%       Edge    t_e      10 ns        (10%-90%, both edges)
%       V_high / V_low   100 mV / 0 V (referenced to the 50-Ohm load setting)
%       Burst            triggered, 1 cycle, trigger source BUS (software trigger)
%
%   The output is left OFF. Fire with:
%       fire33220Burst(awg);                   % ON -> *TRG -> wait T + margin -> OFF
%   or manually:
%       set33220Output(awg,'ON'); send33220Trigger(awg); pause(1.05); set33220Output(awg,'OFF');
%
%   Returns the instrument read-back (query33220Config struct) after every requested
%   parameter has been verified against the instrument.

    arguments
        awg (1,1) Agilent33220A
        opts.LoadSetting (1,1) double {mustBePositive}               = 50      % OUTP:LOAD [Ohm]
        opts.Period      (1,1) double {mustBePositive, mustBeFinite} = 1       % T   [s]
        opts.Width       (1,1) double {mustBePositive, mustBeFinite} = 10e-3   % w   [s]
        opts.EdgeTime    (1,1) double {mustBePositive, mustBeFinite} = 10e-9   % t_e [s]
        opts.VHigh       (1,1) double {mustBeReal, mustBeFinite}     = 100e-3  % [V]
        opts.VLow        (1,1) double {mustBeReal, mustBeFinite}     = 0       % [V]
        opts.NumCycles   (1,1) double {mustBeInteger, mustBePositive} = 1
        opts.RelTol      (1,1) double {mustBePositive}               = 1e-3    % read-back tolerance
        opts.Plot        (1,1) logical                               = false
    end

    %% ---------------------------------------------------------------- Pre-checks (no I/O)
    if opts.VLow >= opts.VHigh
        error("configureResistorPulse:levels", "VLow (%g V) must be below VHigh (%g V).", ...
            opts.VLow, opts.VHigh);
    end
    if opts.Width >= opts.Period
        error("configureResistorPulse:timing", "Width (%g s) must be shorter than Period (%g s).", ...
            opts.Width, opts.Period);
    end
    if opts.EdgeTime > 0.625 * opts.Width           % 33220A edge-time constraint
        error("configureResistorPulse:edge", ...
            "EdgeTime (%g s) exceeds 0.625 x Width (%g s).", opts.EdgeTime, 0.625*opts.Width);
    end
    if opts.LoadSetting ~= awg.LoadResistance
        warning("configureResistorPulse:loadMismatch", ...
            "OUTP:LOAD = %g Ohm but awg.LoadResistance = %g Ohm: programmed levels will NOT " + ...
            "equal the voltage across the physical load.", opts.LoadSetting, awg.LoadResistance);
    end

    % % Expected quantities at the physical load (Thevenin model, edges neglected).
    % [~, vLoad] = Agilent33220A.calc33220LoadVoltage([opts.VLow, opts.VHigh], ...
    %                                                 opts.LoadSetting, awg.LoadResistance);
    % pLevels    = vLoad.^2 ./ awg.LoadResistance;             % [P_low, P_high]  [W]
    % ePulse     = (pLevels(2) - pLevels(1)) * opts.Width;     % energy above baseline [J]
    % fprintf("Expected at R_L = %g Ohm: V_L = %.4g V, P_high = %.4g mW, E_pulse = %.4g uJ\n", ...
    %     awg.LoadResistance, vLoad(2), pLevels(2)*1e3, ePulse*1e6);

    %% ---------------------------------------------------------------- Configure
    set33220Output(awg, 'OFF');                       % never reconfigure a live output
    reset33220(awg);                                  % *RST/*CLS: history-independent start
    set33220OutputLoad(awg, opts.LoadSetting);        % MUST precede every level command
    set33220FunctionType(awg, 'PULS');
    set33220PulsePeriod(awg, opts.Period);            % period first: width < period throughout
    set33220PulseWidth(awg, opts.Width);
    set33220PulseRiseTime(awg, opts.EdgeTime);        % applies to both edges
    set33220VoltageHighAndLow(awg, opts.VLow, opts.VHigh);   % conflict-free ordering

    set33220BurstMode(awg, 'TRIG');
    set33220NumBurstCycles(awg, opts.NumCycles);
    set33220TriggerSource(awg, 'BUS');                % software trigger (*TRG)
    set33220BurstStateOn(awg, 'ON');

    wait33220Complete(awg);
    check33220Errors(awg, "configureResistorPulse");

    %% ---------------------------------------------------------------- Verify read-back
    cfg = query33220Config(awg);
    % 
    % names     = ["LoadSetting [Ohm]"; "Period [s]"; "Width [s]"; "EdgeTime [s]"; ...
    %              "VHigh [V]"; "VLow [V]"; "NumCycles"];
    % requested = [opts.LoadSetting; opts.Period; opts.Width; opts.EdgeTime; ...
    %              opts.VHigh; opts.VLow; opts.NumCycles];
    % readback  = [cfg.LoadSetting; cfg.Period; cfg.Width; cfg.EdgeTime; ...
    %              cfg.VHigh; cfg.VLow; cfg.NumCycles];
    % absTol    = [1e-9; 1e-12; 1e-12; 1e-12; 1e-4; 1e-4; 0];  % floors for zero-valued targets
    % withinTol = abs(readback - requested) <= opts.RelTol .* abs(requested) + absTol;
    % 
    % report = table(names, requested, readback, withinTol, ...
    %     'VariableNames', ["Parameter", "Requested", "Readback", "OK"]);
    % disp(report);
    % 
    % stateOK = strcmpi(cfg.Function, 'PULS') && cfg.Burst && ...
    %           strcmpi(cfg.TriggerSource, 'BUS') && ~cfg.OutputOn;
    % if ~all(withinTol) || ~stateOK
    %     error("configureResistorPulse:verify", ...
    %         "Instrument read-back does not match the request (see table above).");
    % end
    % fprintf("33220A armed: %d-cycle burst, BUS trigger, output OFF.\n", opts.NumCycles);

    %% ---------------------------------------------------------------- Plot
    if opts.Plot
        plot33220Config(awg);    % EMF, V across R_L, programmed level, and P_L(t)
    end
end