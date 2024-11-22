function [result, chData] = ATS9416AcquireData_TS(boardHandle)
% Make an AutoDMA acquisition from dual-ported memory.

% global variable set in configureBoard.m
global samplesPerSec;
global inputRangeIdChA;

% set default return code to indicate failure
result = false;

% call mfile with library definitions
AlazarDefs

% TODO: Select the total acquisition length in seconds
acquisitionLength_sec = 0.5;

% TODO: Select the number of samples in each DMA buffer
samplesPerBufferPerChannel = 204800;

% TODO: Select which channels to capture (A, B, or both)
channelMask = CHANNEL_A;

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
            % If plotting data then calculate scale factors to convert sample
            % values to volts, and allocate a buffer to store the values in volts.
            inputRangeInVolts = inputRangeIdToVolts(inputRangeIdChA);

            % This 16-bit sample code represents a 0V input
            codeZero = 2 ^ (double(bitsPerSample) - inputRangeInVolts);
        
            % This is the range of 16-bit sample codes with respect to 0V level
            codeRange = 2 ^ (double(bitsPerSample) - inputRangeInVolts);
        
            % Subtract this amount from a 16-bit sample value to remove the 0V offset
            offsetValue = codeZero;
        
            % Multiply a 16-bit sample value by this factor to convert it to volts
            scaleValueChB = inputRangeInVolts/codeRange;
        
            % create an array to store sample data     
            % bufferVolts = zeros(channelCount, samplesPerBuffer);

           % Find scale factor for this channel
            scaleValue = scaleValueChB;                   
            
            bufferVolts = zeros(channelCount, samplesPerRecord);

            % Convert sample values to volts and store for display
            for col = 1 : samplesPerBuffer
                    bufferVolts(rowInPlotBuffer, col) = scaleValue * (double(bufferOut(col)) - offsetValue);
            end
            rowInPlotBuffer = rowInPlotBuffer + 1;
            bufferVolts = scaleValue * (bufferOut - offsetValue);
           
            plot(bufferVolts.Value);
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