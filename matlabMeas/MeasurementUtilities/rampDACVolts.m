function rampDACVolts(dac, channels, voltages, numSteps, varargin)
%RAMPVOLTAGE  Ramp DAC channels to a target, whichever DAC object you hand it.
%
%   rampVoltage(dac, channels, voltages)
%   rampVoltage(dac, channels, voltages, numSteps)
%   rampVoltage(dac, channels, voltages, numSteps, dwell)        <- positional
%   rampVoltage(..., 'Dwell', d, 'Wait', tf, 'DwellUnits', u)    <- named
%
%   channels  vector of channel numbers
%   voltages  matching vector of target voltages [V], or a scalar
%   numSteps  number of intermediate steps (default 100)
%   dwell     settling time per step, IN SECONDS by default. Optional.
%
%   The fifth argument is taken as the dwell if it is numeric, so no name
%   is needed:
%       rampVoltage(basel, [1 2], [1 -1], 200, 1e-3);
%
%   UNITS. Dwell is in SECONDS unless you say otherwise. If your existing
%   scripts pass microseconds (as sigDACRamp does), either scale them or
%   pass the units once per call:
%       rampVoltage(sig, 3, 0.5, 100, 200, 'DwellUnits', 'us');   % 200 us
%       rampVoltage(sig, 3, 0.5, 100, 200e-6);                    % same
%   As a guard against silent unit errors, a dwell of 40 s or more given in
%   seconds is rejected - that is almost always a microsecond value.
%
%   The underlying drivers disagree about units; this wrapper converts:
%     baselDAC  seconds  - extra pause after each multiple-SET write
%     QDAC      seconds  - SOUR:SWE:DWEL, minimum 1e-6 s
%     sigDAC    MICROseconds - sigDACRamp(...,dwellUs), 40 to 16383 us
%
%   PER-DAC BEHAVIOUR
%     baselDAC  Software-stepped multiple-SET writes, blocking. Dwell is an
%               extra pause on top of the round-trip time, so the real step
%               period is dwell + ~1 ms (Ethernet) or more (RS-232).
%               Default dwell 0.
%
%     QDAC      Hardware sweep generator, staircase (STEP) mode, count 1.
%               With no dwell this calls the lab's QDACRampVoltage unchanged
%               (which hard-codes 1 ms). With a dwell it runs the same
%               sequence with your value substituted. The sweep is armed and
%               returns immediately, so 'Wait' pauses for the estimated
%               duration. Minimum dwell 1e-6 s.
%               For a true analog ramp rather than a staircase, use
%               QDACSmoothRampVoltage(qdac, channels, voltages, totalTime).
%
%     sigDAC    With no dwell: sigDACRampVoltage, all channels interleaved.
%               With a dwell: sigDACRamp, which is SINGLE-CHANNEL ONLY, so
%               multiple channels are ramped SEQUENTIALLY, not together.
%               A warning is issued in that case. Dwell must be within
%               40e-6 to 16383e-6 s (the firmware's own limits).
%
%   START POINT differs too:
%     baselDAC  interpolates from its cached channelVoltages - call
%               baselDACGetConfig first if the outputs may have moved
%     QDAC      queries the present voltage over SCPI
%     sigDAC    the Arduino interpolates from its own current value
%
%   See also SETVOLTS, QDACSMOOTHRAMPVOLTAGE, BASELDACRAMP

    if nargin < 4 || isempty(numSteps)
        numSteps = 100;
    end
    if ~isscalar(numSteps) || mod(numSteps,1) ~= 0 || numSteps < 1
        error('rampVoltage:badNumSteps', 'numSteps must be a positive integer.');
    end

    [dwellSec, wait] = parseRampOptions(varargin);
    [channels, voltages] = normalizeDACInputs(dac, channels, voltages);

    % =================================================================
    if isa(dac, 'baselDAC')
    % =================================================================
        if isempty(dwellSec), dwellSec = 0; end
        baselDACRampVoltage(dac, channels, voltages, numSteps, dwellSec);

    % =================================================================
    elseif isa(dac, 'QDAC')
    % =================================================================
        if isempty(dwellSec)
            % Untouched lab code path: QDACRampVoltage hard-codes 1 ms.
            QDACRampVoltage(dac, channels, voltages, numSteps);
            dwellSec = 1e-3;
        else
            if dwellSec < 1e-6
                error('rampVoltage:qdacDwell', ...
                    ['QDAC sweep dwell must be at least 1e-6 s (1 us). ' ...
                     'Requested %.3e s.'], dwellSec);
            end
            qdacSteppedRamp(dac, channels, voltages, numSteps, dwellSec);
        end

        if wait
            % Hardware sweep returns as soon as it is armed.
            pause(numSteps * dwellSec + 0.05);
        end

    % =================================================================
    elseif isa(dac, 'sigDAC')
    % =================================================================
        if isempty(dwellSec)
            % Interleaved multi-channel ramp, fixed 40 us firmware timing.
            sigDACRampVoltage(dac, channels, voltages, numSteps);
        else
            dwellUs = dwellSec * 1e6;
            if dwellUs < 40
                error('rampVoltage:sigDacDwellLow', ...
                    ['sigDAC dwell must be at least 40e-6 s (40 us), the ' ...
                     'firmware minimum. Requested %.3e s.'], dwellSec);
            elseif dwellUs > 16383
                error('rampVoltage:sigDacDwellHigh', ...
                    ['sigDAC dwell must not exceed 16383e-6 s (~16.4 ms); ' ...
                     'the Arduino delay is inaccurate above that. ' ...
                     'Requested %.3e s.'], dwellSec);
            end
            if numel(channels) > 1
                warning('rampVoltage:sigDacSequential', ...
                    ['sigDACRamp is single-channel, so channels %s will be ' ...
                     'ramped SEQUENTIALLY, not together. Omit the dwell to ' ...
                     'use the interleaved sigDACRampVoltage instead.'], ...
                     mat2str(channels));
            end
            for i = 1:numel(channels)
                % sigDACRamp blocks until the Arduino answers.
                sigDACRamp(dac, channels(i), voltages(i), numSteps, dwellUs);
            end
        end

    % =================================================================
    else
    % =================================================================
        error('rampVoltage:unsupportedDAC', ...
            ['Do not know how to ramp a "%s" object.\n' ...
             'Supported: baselDAC, QDAC, sigDAC. Add a branch to ' ...
             'rampVoltage.m to extend.'], class(dac));
    end
end

% ---------------------------------------------------------------------
function [dwellSec, wait] = parseRampOptions(args)
%PARSERAMPOPTIONS  Accept dwell positionally or by name.
%   A leading numeric argument is the dwell; everything after that is
%   name-value pairs. Done by hand rather than with an arguments block,
%   because an optional positional followed by name-value pairs is
%   ambiguous there (the block would swallow 'Wait' as the dwell).

    dwellSec   = [];
    wait       = true;
    dwellRaw   = [];
    unitFactor = 1;            % seconds
    unitsGiven = false;

    % --- leading positional dwell -----------------------------------
    if ~isempty(args) && isnumeric(args{1})
        dwellRaw = args{1};
        args(1)  = [];
    end

    % --- name-value pairs -------------------------------------------
    if mod(numel(args), 2) ~= 0
        error('rampVoltage:badPairs', ...
            ['Options must be name-value pairs. If you meant to pass a ' ...
             'dwell, it must be numeric and come straight after numSteps.']);
    end
    for k = 1:2:numel(args)
        name = args{k};
        val  = args{k+1};
        if ~(ischar(name) || isstring(name))
            error('rampVoltage:badOptionName', ...
                'Expected an option name in position %d, got a %s.', ...
                k, class(name));
        end
        switch lower(char(name))
            case 'dwell'
                if ~isempty(dwellRaw)
                    error('rampVoltage:dwellTwice', ...
                        'Dwell given both positionally and as ''Dwell''.');
                end
                dwellRaw = val;
            case 'wait'
                wait = logical(val);
            case 'dwellunits'
                unitsGiven = true;
                switch lower(char(val))
                    case {'s','sec','secs','second','seconds'}
                        unitFactor = 1;
                    case {'us','usec','microsecond','microseconds'}
                        unitFactor = 1e-6;
                    case {'ms','msec','millisecond','milliseconds'}
                        unitFactor = 1e-3;
                    otherwise
                        error('rampVoltage:badUnits', ...
                            ['DwellUnits must be ''s'', ''ms'' or ''us''. ' ...
                             'Got ''%s''.'], char(val));
                end
            otherwise
                error('rampVoltage:unknownOption', ...
                    'Unknown option "%s".', char(name));
        end
    end

    if isempty(dwellRaw)
        return
    end
    if ~isnumeric(dwellRaw) || ~isscalar(dwellRaw) || ...
            ~isfinite(dwellRaw) || dwellRaw < 0
        error('rampVoltage:badDwell', ...
            'Dwell must be a non-negative finite scalar.');
    end

    % --- units guard -------------------------------------------------
    % A "seconds" dwell of 40 or more means an hour-plus ramp at typical
    % step counts. Overwhelmingly likely to be a microsecond value.
    if ~unitsGiven && dwellRaw >= 40
        error('rampVoltage:dwellUnitsSuspect', ...
            ['Dwell is interpreted as SECONDS, and %g s per step would ' ...
             'take %.1f minutes over %s steps.\n' ...
             'If you meant microseconds, pass %g*1e-6 or add ' ...
             '''DwellUnits'',''us''.\nIf you really want %g s per step, ' ...
             'add ''DwellUnits'',''s'' to say so explicitly.'], ...
             dwellRaw, dwellRaw*100/60, '100', dwellRaw, dwellRaw);
    end

    dwellSec = dwellRaw * unitFactor;
end

% ---------------------------------------------------------------------
function qdacSteppedRamp(dac, channels, voltages, numSteps, dwellSec)
%QDACSTEPPEDRAMP  QDACRampVoltage with a user-supplied dwell.
%   Mirrors the sequence in QDAC.m/QDACRampVoltage exactly, substituting
%   the dwell. Kept here so QDAC.m does not have to be edited.

    % Present voltages become the sweep start points. queryQDACVoltage
    % switches the channels to FIX mode as a side effect.
    startVoltages = str2num(queryQDACVoltage(dac, channels)); %#ok<ST2NM>

    for i = 1:numel(voltages)
        QDACSetSweepStartVoltage(dac, channels(i), startVoltages(i));
        QDACSetSweepStopVoltage(dac,  channels(i), voltages(i));
    end

    QDACSetSweepPoints(dac, channels, numSteps);
    QDACSetSweepDwell(dac,  channels, dwellSec);
    QDACSetSweepCount(dac,  channels, 1);
    QDACSetSweepMode(dac,   channels, 'STEP');

    setQDACDCGeneratorMode(dac, channels, 'SWE');
    QDACStartSweep(dac, channels);

    % Keep the cached voltages (and hence the lab GUI) in step. QDAC is a
    % handle class, so this updates the base-workspace object too.
    if isprop(dac, 'channelVoltages')
        dac.channelVoltages(channels) = voltages;
    end
end

% ---------------------------------------------------------------------
function [channels, voltages] = normalizeDACInputs(dac, channels, voltages)
%NORMALIZEDACINPUTS  Shared argument checking for all DAC types.

    if ~isobject(dac) || ~isscalar(dac)
        error('rampVoltage:badDAC', 'First argument must be a single DAC object.');
    end
    if ~isnumeric(channels) || isempty(channels)
        error('rampVoltage:badChannels', 'Channels must be a non-empty numeric vector.');
    end
    if any(mod(channels, 1) ~= 0) || any(channels < 1)
        error('rampVoltage:badChannels', 'Channels must be positive integers.');
    end

    channels = channels(:).';

    if isscalar(voltages)
        voltages = repmat(voltages, 1, numel(channels));
    end
    voltages = voltages(:).';

    if numel(channels) ~= numel(voltages)
        error('rampVoltage:sizeMismatch', ...
            'Number of channels (%d) and voltages (%d) must match.', ...
            numel(channels), numel(voltages));
    end
    if ~isnumeric(voltages) || any(~isfinite(voltages))
        error('rampVoltage:badVoltages', 'Voltages must be finite numbers.');
    end

    if isprop(dac, 'numChannels') && ~isempty(dac.numChannels)
        if any(channels > dac.numChannels)
            error('rampVoltage:channelRange', ...
                'This %s has %d channels; channel %d requested.', ...
                class(dac), dac.numChannels, max(channels));
        end
    end

    % Both the Basel and the QDAC top out at +/-10 V. Note the QDAC can be
    % put in its +/-2 V low range, which this check will not catch.
    if any(abs(voltages) > 10)
        error('rampVoltage:vRange', ...
            'Voltage %+.3f V is outside the +/-10 V output range.', ...
            voltages(find(abs(voltages) > 10, 1)));
    end
end