function [result] = ATS9416ConfigureBoard(boardHandle, samplesPerSec)
% Configure sample rate, input, and trigger settings

% Call mfile with library definitions
AlazarDefs

% set default return code to indicate failure
result = false;

% TODO: Select clock parameters as required to generate this sample rate.
%
% A 10 MHz reference procudes a 100 MHz. Set a lower sampling frequency by
% specifying a decimation value.

% Configure sample rate, input, and trigger settings
allowedSampleRates = [100e6,50e6,20e6,10e6,5e6,2e6,1e6,500e3,200e3,100e3];

if ismember(samplesPerSec,allowedSampleRates) == 0
    fprintf('Sample rate %i is not allowed!\n', samplesPerSec)
    return
end

clockDecimation = 100e6/samplesPerSec; % Set clock decimation value
fprintf('Clock decimation is %i\n', clockDecimation)

retCode = ...
    AlazarSetCaptureClock(  ...
        boardHandle,        ... % HANDLE -- board handle
        EXTERNAL_CLOCK_10MHz_REF,     ... % U32 -- clock source id
        SAMPLE_RATE_100MSPS, ... % U32 -- sample rate id
        CLOCK_EDGE_RISING,  ... % U32 -- clock edge id
        clockDecimation                   ... % U32 -- clock decimation
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetCaptureClock failed -- %s\n', errorToText(retCode));
    return
end

%% Input control
% TODO: Select channel A input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_A,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel B input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_B,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel C input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_C,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel D input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_D,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel E input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_E,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel F input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_F,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel G input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_G,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel H input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_H,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel I input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_I,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel J input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_J,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel K input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_K,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel L input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_L,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel M input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_M,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel N input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_N,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel O input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_O,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select channel P input parameters as required.
retCode = ...
    AlazarInputControlEx(             ...
        boardHandle,                  ... % HANDLE -- board handle
        CHANNEL_P,     ... % U32 -- input channel
        DC_COUPLING,    ... % U32 -- input coupling id
        INPUT_RANGE_PM_1_V, ... % U32 -- input range id
        IMPEDANCE_50_OHM    ... % U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControlEx failed -- %s\n', errorToText(retCode));
    return
end

%% Trigger
inputRange_volts = 3.5; % +- range
triggerLevelJ_volts = inputRange_volts*0.5; % trigger level
triggerLevelJ = (128 + 128 * triggerLevelJ_volts / inputRange_volts);

% TODO: Select trigger inputs and levels as required
retCode = ...
    AlazarSetTriggerOperation( ...
        boardHandle,        ... % HANDLE -- board handle
        TRIG_ENGINE_OP_J,   ... % U32 -- trigger operation
        TRIG_ENGINE_J,      ... % U32 -- trigger engine id
        TRIG_EXTERNAL,        ... % U32 -- trigger source id
        TRIGGER_SLOPE_POSITIVE, ... % U32 -- trigger slope id
        triggerLevelJ,                ... % U32 -- trigger level from 0 (-range) to 255 (+range)
        TRIG_ENGINE_K,      ... % U32 -- trigger engine id
        TRIG_DISABLE,       ... % U32 -- trigger source id for engine K
        TRIGGER_SLOPE_POSITIVE, ... % U32 -- trigger slope id
        128                 ... % U32 -- trigger level from 0 (-range) to 255 (+range)
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerOperation failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select external trigger parameters as required
retCode = ...
    AlazarSetExternalTrigger( ...
        boardHandle,        ... % HANDLE -- board handle
        DC_COUPLING,        ... % U32 -- external trigger coupling id
        ETR_TTL              ... % U32 -- external trigger range id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetExternalTrigger failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Set trigger delay as required.
triggerDelay_sec = 0;
triggerDelay_samples = uint32(floor(triggerDelay_sec * samplesPerSec + 0.5));
retCode = AlazarSetTriggerDelay(boardHandle, triggerDelay_samples);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerDelay failed -- %s\n', errorToText(retCode));
    return;
end

% TODO: Set trigger timeout as required.

% NOTE:
% The board will wait for a for this amount of time for a trigger event.
% If a trigger event does not arrive, then the board will automatically
% trigger. Set the trigger timeout value to 0 to force the board to wait
% forever for a trigger event.
%
% IMPORTANT:
% The trigger timeout value should be set to zero after appropriate
% trigger parameters have been determined, otherwise the
% board may trigger if the timeout interval expires before a
% hardware trigger event arrives.
triggerTimeout_sec = 5;
triggerTimeout_clocks = uint32(floor(triggerTimeout_sec / 10.e-6 + 0.5));
retCode = ...
    AlazarSetTriggerTimeOut(    ...
        boardHandle,            ... % HANDLE -- board handle
        triggerTimeout_clocks   ... % U32 -- timeout_sec / 10.e-6 (0 == wait forever)
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerTimeOut failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Configure AUX I/O connector as required
retCode = ...
    AlazarConfigureAuxIO(   ...
        boardHandle,        ... % HANDLE -- board handle
        AUX_OUT_PACER,    ... % U32 -- mode
        10                   ... % U32 -- parameter
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarConfigureAuxIO failed -- %s\n', errorToText(retCode));
    return
end

% set return code to indicate success
result = true;
end