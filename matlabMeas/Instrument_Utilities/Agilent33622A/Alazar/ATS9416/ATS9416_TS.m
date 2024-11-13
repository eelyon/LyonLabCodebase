%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2016 AlazarTech, Inc.
%
% AlazarTech, Inc. licenses this software under specific terms and
% conditions. Use of any of the software or derivatives thereof in any
% product without an AlazarTech digitizer board is strictly prohibited.
%
% AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
% EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
% MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no
% guarantee or representations regarding the use of, or the results of the
% use of, the software and documentation in terms of correctness, accuracy,
% reliability, currentness, or otherwise; and you rely on the software,
% documentation and results solely at your own risk.
%
% IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF
% BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL
% DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH%S TOTAL LIABILITY EXCEED
% THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
%
%---------------------------------------------------------------------------
%
% This sample configures an ATS9350 to make a no pre-trigger (NPT) mode
% AutoDMA acqusition, optionally saving the data to file and displaying it
% on screen.
%

% Add path to AlazarTech mfiles
addpath('C:\AlazarTech\ATS-SDK\7.2.2\Samples_MATLAB\Include')


%%%%%%%%%%
%% MAIN %%
%%%%%%%%%%

% Call mfile with library definitions
AlazarDefs

% Load driver library
if ~alazarLoadLibrary()
  fprintf('Error: ATSApi library not loaded\n');
  return
end

% TODO: Select a board
systemId = int32(1);
boardId = int32(1);

% Get a handle to the board
boardHandle = AlazarGetBoardBySystemID(systemId, boardId);
setdatatype(boardHandle, 'voidPtr', 1, 1);
if boardHandle.Value == 0
  fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
  return
end

% Configure the board's sample rate, input, and trigger settings
if ~configureBoard(boardHandle)
  fprintf('Error: Board configuration failed\n');
  return
end

% Acquire data, optionally saving it to a file
if ~acquireData(boardHandle)
  fprintf('Error: Acquisition failed\n');
  return
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configure board function %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result] = configureBoard(boardHandle)
% Configure sample rate, input, and trigger settings

% Call mfile with library definitions
AlazarDefs

% set default return code to indicate failure
result = false;

% TODO: Select clock parameters as required to generate this sample rate.
%
% For example: if samplesPerSec is 100.e6 (100 MS/s), then:
% - select clock source INTERNAL_CLOCK and sample rate SAMPLE_RATE_100MSPS
% - select clock source FAST_EXTERNAL_CLOCK, sample rate SAMPLE_RATE_USER_DEF,
%   and connect a 100 MHz signalto the EXT CLK BNC connector.

% global variable used in acquireData.m
global samplesPerSec;

samplesPerSec = 100000000.0;

retCode = ...
    AlazarSetCaptureClock(  ...
        boardHandle,        ... % HANDLE -- board handle
        INTERNAL_CLOCK,     ... % U32 -- clock source id
        SAMPLE_RATE_100MSPS, ... % U32 -- sample rate id
        CLOCK_EDGE_RISING,  ... % U32 -- clock edge id
        0                   ... % U32 -- clock decimation
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetCaptureClock failed -- %s\n', errorToText(retCode));
    return
end
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

% TODO: Select trigger inputs and levels as required
retCode = ...
    AlazarSetTriggerOperation( ...
        boardHandle,        ... % HANDLE -- board handle
        TRIG_ENGINE_OP_J,   ... % U32 -- trigger operation
        TRIG_ENGINE_J,      ... % U32 -- trigger engine id
        TRIG_CHAN_A,        ... % U32 -- trigger source id
        TRIGGER_SLOPE_POSITIVE, ... % U32 -- trigger slope id
        150,                ... % U32 -- trigger level from 0 (-range) to 255 (+range)
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
        AUX_OUT_TRIGGER,    ... % U32 -- mode
        0                   ... % U32 -- parameter
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarConfigureAuxIO failed -- %s\n', errorToText(retCode));
    return
end

% set return code to indicate success
result = true;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Acquire data function %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result, chData] = acquireData(boardHandle)
% Make an AutoDMA acquisition from dual-ported memory.

% global variable set in configureBoard.m
global samplesPerSec;

% set default return code to indicate failure
result = false;

% call mfile with library definitions
AlazarDefs
% TODO: Select the total acquisition length in seconds
acquisitionLength_sec = 1.;

% TODO: Select the number of samples in each DMA buffer
samplesPerBufferPerChannel = 204800;

% TODO: Select which channels to capture (A, B, or both)
channelMask = CHANNEL_B;

% TODO: Select if you wish to save the sample data to a binary file
saveData = false;

% TODO: Select if you wish to plot the data to a chart
drawData = true;

% Calculate the number of enabled channels from the channel mask
channelCount = 0;
channelsPerBoard = 16;
for channel = 0:channelsPerBoard - 1
    channelId = 2^channel;
    if bitand(channelId, channelMask)
        channelCount = channelCount + 1;
    end
end

if (channelCount < 1) || (channelCount > channelsPerBoard)
    fprintf('Error: Invalid channel mask %08X\n', channelMask);
    return
end

% Get the sample and memory size
[retCode, boardHandle, maxSamplesPerRecord, bitsPerSample] = AlazarGetChannelInfo(boardHandle, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
    return
end

% Calculate the size of each buffer in bytes
bytesPerSample = floor((double(bitsPerSample) + 7) / double(8));
samplesPerBuffer = samplesPerBufferPerChannel * channelCount;
bytesPerBuffer = bytesPerSample * samplesPerBuffer;

% Find the number of buffers in the acquisition
if acquisitionLength_sec > 0
    samplesPerAcquisition = uint32(floor((samplesPerSec * acquisitionLength_sec + 0.5)));
    buffersPerAcquisition = uint32(floor((samplesPerAcquisition + samplesPerBufferPerChannel - 1) / samplesPerBufferPerChannel));
else
    buffersPerAcquisition = hex2dec('7FFFFFFF');  % acquire until aborted
end

% TODO: Select the number of DMA buffers to allocate.
% The number of DMA buffers must be greater than 2 to allow a board to DMA into
% one buffer while, at the same time, your application processes another buffer.
bufferCount = uint32(4);

% Create an array of DMA buffers
buffers = cell(1, bufferCount);
for j = 1 : bufferCount
    pbuffer = AlazarAllocBuffer(boardHandle, bytesPerBuffer);
    if pbuffer == 0
        fprintf('Error: AlazarAllocBuffer %u samples failed\n', samplesPerBuffer);
        return
    end
    buffers(1, j) = { pbuffer };
end

% Create a data file if required
fid = -1;
if saveData
    fid = fopen('data.bin', 'w');
    if fid == -1
        fprintf('Error: Unable to create data file\n');
    end
end
retCode = AlazarBeforeAsyncRead(boardHandle, channelMask, 0, samplesPerBufferPerChannel, 1, hex2dec('7FFFFFFF'), ADMA_EXTERNAL_STARTCAPTURE + ADMA_TRIGGERED_STREAMING);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarBeforeAsyncRead failed -- %s\n', errorToText(retCode));
    return
end

% Post the buffers to the board
for bufferIndex = 1 : bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = AlazarPostAsyncBuffer(boardHandle, pbuffer, bytesPerBuffer);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
        return
    end
end

% Update status
if buffersPerAcquisition == hex2dec('7FFFFFFF')
    fprintf('Capturing buffers until aborted...\n');
else
    fprintf('Capturing %u buffers ...\n', buffersPerAcquisition);
end

% Arm the board system to wait for triggers
retCode = AlazarStartCapture(boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarStartCapture failed -- %s\n', errorToText(retCode));
    return
end

% AlazarForceTrigger(boardHandle);

% Create a progress window
waitbarHandle = waitbar(0, ...
                        'Captured 0 buffers', ...
                        'Name','Capturing ...', ...
                        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
setappdata(waitbarHandle, 'canceling', 0);

% Wait for sufficient data to arrive to fill a buffer, process the buffer,
% and repeat until the acquisition is complete
startTickCount = tic;
updateTickCount = tic;
updateInterval_sec = 0.1;
buffersCompleted = 0;
captureDone = false;
success = false;

while ~captureDone

    bufferIndex = mod(buffersCompleted, bufferCount) + 1;
    pbuffer = buffers{1, bufferIndex};

    % Wait for the first available buffer to be filled by the board
    [retCode, boardHandle, bufferOut] = ...
        AlazarWaitAsyncBufferComplete(boardHandle, pbuffer, 5000);
    if retCode == ApiSuccess
        % This buffer is full
        bufferFull = true;
        captureDone = false;
    elseif retCode == ApiWaitTimeout
        % The wait timeout expired before this buffer was filled.
        % The board may not be triggering, or the timeout period may be too short.
        fprintf('Error: AlazarWaitAsyncBufferComplete timeout -- Verify trigger!\n');
        bufferFull = false;
        captureDone = true;
    else
        % The acquisition failed
        fprintf('Error: AlazarWaitAsyncBufferComplete failed -- %s\n', errorToText(retCode));
        bufferFull = false;
        captureDone = true;
    end

    if bufferFull
        % TODO: Process sample data in this buffer.
        %
        % NOTE:
        %
        % While you are processing this buffer, the board is already
        % filling the next available buffer(s).
        %
        % You MUST finish processing this buffer and post it back to the
        % board before the board fills all of its available DMA buffers
        % and on-board memory.
        %
        % Samples are arranged in the buffer as follows: S0A, S0B, ..., S1A, S1B, ...
        % with SXY the sample number X of channel Y.
        %
        % A 14-bit sample code is stored in the most significant bits of
        % in each 16-bit sample value.
        %
        % Sample codes are unsigned by default. As a result:
        % - a sample code of 0x0000 represents a negative full scale input signal.
        % - a sample code of 0x8000 represents a ~0V signal.
        % - a sample code of 0xFFFF represents a positive full scale input signal.

        if bytesPerSample == 1
            setdatatype(bufferOut, 'uint8Ptr', 1, samplesPerBuffer);
        else
            setdatatype(bufferOut, 'uint16Ptr', 1, samplesPerBuffer);
        end

        % Save the buffer to file
        if fid ~= -1
            if bytesPerSample == 1
                samplesWritten = fwrite(fid, bufferOut.Value, 'uint8');
            else
                samplesWritten = fwrite(fid, bufferOut.Value, 'uint16');
            end
            if samplesWritten ~= samplesPerBuffer
                fprintf('Error: Write buffer %u failed\n', buffersCompleted);
            end
        end

        % Display the buffer on screen
        if drawData
%             % If plotting data then calculate scale factors to convert sample
%             % values to volts, and allocate a buffer to store the values in volts.
%             inputRangeInVolts = inputRangeIdToVolts(INPUT_RANGE_PM_1_V);
% 
%             % This 16-bit sample code represents a 0V input
%             codeZero = 2 ^ (double(bitsPerSample) - inputRangeInVolts);
%         
%             % This is the range of 16-bit sample codes with respect to 0V level
%             codeRange = 2 ^ (double(bitsPerSample) - inputRangeInVolts);
%         
%             % Subtract this amount from a 16-bit sample value to remove the 0V offset
%             offsetValue = codeZero;
%         
%             % Multiply a 16-bit sample value by this factor to convert it to volts
%             scaleValueChB = inputRangeInVolts/codeRange;
%         
%             % create an array to store sample data     
%             % bufferVolts = zeros(channelCount, samplesPerBuffer);
% 
%            % Find scale factor for this channel
%             scaleValue = scaleValueChB;                   
%             
%             bufferVolts = zeros(channelCount, samplesPerRecord);
% 
%             % Convert sample values to volts and store for display
%             for col = 1 : samplesPerBuffer
%                     bufferVolts(rowInPlotBuffer, col) = scaleValue * (double(bufferOut(col)) - offsetValue);
%             end
%             rowInPlotBuffer = rowInPlotBuffer + 1;
%             bufferVolts = scaleValue * (bufferOut - offsetValue);
           
            plot(bufferOut.Value);
            % bufferOut.Value
        end

        % Make the buffer available to be filled again by the board
        retCode = AlazarPostAsyncBuffer(boardHandle, pbuffer, bytesPerBuffer);
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
            captureDone = true;
        end

        % Update progress
        buffersCompleted = buffersCompleted + 1;
        if buffersCompleted >= buffersPerAcquisition
            captureDone = true;
            success = true;
        elseif toc(updateTickCount) > updateInterval_sec
            updateTickCount = tic;

            % Update waitbar progress
            waitbar(double(buffersCompleted) / double(buffersPerAcquisition), ...
                    waitbarHandle, ...
                    sprintf('Completed %u buffers', buffersCompleted));

            % Check if waitbar cancel button was pressed
            if getappdata(waitbarHandle,'canceling')
                break
            end
        end

    end % if bufferFull

end % while ~captureDone

% Save the transfer time
transferTime_sec = toc(startTickCount);

% Close progress window
delete(waitbarHandle);

% Abort the acquisition
retCode = AlazarAbortAsyncRead(boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarAbortAsyncRead failed -- %s\n', errorToText(retCode));
end

% Close the data file
if fid ~= -1
    fclose(fid);
end

% Release the buffers
for bufferIndex = 1:bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = AlazarFreeBuffer(boardHandle, pbuffer);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarFreeBuffer failed -- %s\n', errorToText(retCode));
    end
    clear pbuffer;
end

% Display results
if buffersCompleted > 0
    bytesTransferred = double(buffersCompleted) * double(bytesPerBuffer);

    if transferTime_sec > 0
        buffersPerSec = buffersCompleted / transferTime_sec;
        bytesPerSec = bytesTransferred / transferTime_sec;
    else
        buffersPerSec = 0;
        bytesPerSec = 0;
    end

    fprintf('Captured %u buffers in %g sec (%g buffers per sec)\n', buffersCompleted, transferTime_sec, buffersPerSec);
    fprintf('Transferred %u bytes (%.4g bytes per sec)\n', bytesTransferred, bytesPerSec);
end

                                % set return code to indicate success

result = success;
end