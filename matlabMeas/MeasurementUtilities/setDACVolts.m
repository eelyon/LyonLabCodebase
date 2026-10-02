function setDACVolts(dac, channels, voltages)
%SETVOLTAGES  Set DAC channel voltages, whichever DAC object you hand it.
%
%   setVoltages(dac, channels, voltages)
%
%   Dispatches to the right class method:
%       baselDAC  ->  baselDACSetVoltage   (single multiple-SET string)
%       qDAC      ->  QDACSetVoltage       (SCPI, fixed DC mode)
%       sigDAC    ->  sigDACSetVoltage     (per-channel CH/VOLT pairs)
%
%   channels  vector of channel numbers
%   voltages  matching vector of voltages [V], or a scalar applied to all
%
%   Examples
%       setDACVolts(basel, [1 2 3], [0.1 -0.2 1.5]);
%       setDACVolts(qdac,  1:24, 0);            % scalar expands
%
%   All three DACs step immediately to the new value. If the outputs are
%   connected to a sample, use rampVoltage instead.
%
%   See also RAMPVOLTAGE

    [channels, voltages] = normalizeDACInputs(dac, channels, voltages);

    if isa(dac, 'baselDAC')
        baselDACSetVoltage(dac, channels, voltages);

    elseif isa(dac, 'QDAC')
        QDACSetVoltage(dac, channels, voltages);

    elseif isa(dac, 'sigDAC')
        sigDACSetVoltage(dac, channels, voltages);

    else
        error('setDACVolts:unsupportedDAC', ...
            ['Do not know how to set voltages on a "%s" object.\n' ...
             'Supported: baselDAC, qDAC, sigDAC. Add a branch to ' ...
             'setDACVolts.m to extend.'], class(dac));
    end
end

% ---------------------------------------------------------------------
function [channels, voltages] = normalizeDACInputs(dac, channels, voltages)
%NORMALIZEDACINPUTS  Shared argument checking for all DAC types.

    if ~isobject(dac) || ~isscalar(dac)
        error('setVoltages:badDAC', 'First argument must be a single DAC object.');
    end
    if ~isnumeric(channels) || isempty(channels)
        error('setVoltages:badChannels', 'Channels must be a non-empty numeric vector.');
    end
    if any(mod(channels, 1) ~= 0) || any(channels < 1)
        error('setVoltages:badChannels', 'Channels must be positive integers.');
    end

    channels = channels(:).';

    if isscalar(voltages)
        voltages = repmat(voltages, 1, numel(channels));
    end
    voltages = voltages(:).';

    if numel(channels) ~= numel(voltages)
        error('setVoltages:sizeMismatch', ...
            'Number of channels (%d) and voltages (%d) must match.', ...
            numel(channels), numel(voltages));
    end
    if ~isnumeric(voltages) || any(~isfinite(voltages))
        error('setVoltages:badVoltages', 'Voltages must be finite numbers.');
    end

    % Channel-count check where the object exposes one
    if isprop(dac, 'numChannels') && ~isempty(dac.numChannels)
        if any(channels > dac.numChannels)
            error('setVoltages:channelRange', ...
                'This %s has %d channels; channel %d requested.', ...
                class(dac), dac.numChannels, max(channels));
        end
    end

    % Both the Basel and the qDAC top out at +/-10 V. Note the qDAC can be
    % put in its +/-2 V low range, which this check will not catch.
    if any(abs(voltages) > 10)
        error('setVoltages:vRange', ...
            'Voltage %+.3f V is outside the +/-10 V output range.', ...
            voltages(find(abs(voltages) > 10, 1)));
    end
end