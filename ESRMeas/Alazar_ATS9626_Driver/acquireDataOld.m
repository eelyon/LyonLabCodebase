function [outA, outB, result] = acquireData(boardHandle, pre_trig, post_trig, records)
% Acquire to on-board memory. After the acquisition is complete,
% transfer data to an application buffer.
% pre_trig = number of samples to record before trigger event (4098 default)
% post_trig = number of samples to record after the trigger event.(4098 default)
% records = number of records per acquisition (100 default)

%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2012 AlazarTech, Inc.
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

% global variables set in configureBoard.m
global InputRangeIdChA
global InputRangeIdChB

% set default return code to indicate failure
result = false;

%call mfile with library definitions
AlazarDefs

% TODO: Select the number of pre-trigger samples per record 
preTriggerSamples = uint32(pre_trig);

%TODO: Select the number of post-trigger samples per record 
postTriggerSamples = uint32(post_trig);

% TODO: Select the number of records in the acquisition
recordsPerCapture = uint32(records);

% TODO: Select the amount of time, in seconds, to wait for a trigger
timeout_sec = 5;

% TODO: Select if you wish to save the sample data to a binary file
saveData = false;

% TODO: Select if you wish to plot the data to a chart
plotData = false;

% TODO: Select which channels read from on-board memory (A, B, or both)
channelMask = CHANNEL_A + CHANNEL_B;

% Calculate the number of enabled channels from the channel mask 
channelCount = 0;
channelsPerBoard = 2;
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
[retCode, boardHandle, maxSamplesPerRecord, bitsPerSample] = calllib('ATSApi', 'AlazarGetChannelInfo', boardHandle, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
    return;
end

% Calculate the size of each record in bytes
bytesPerSample = floor((double(bitsPerSample) + 7) / double(8));
samplesPerRecord = uint32(preTriggerSamples + postTriggerSamples);
if samplesPerRecord > maxSamplesPerRecord
    samplesPerRecord = maxSamplesPerRecord;
end
bytesPerRecord = double(bytesPerSample) * samplesPerRecord;

% The buffer must be at least 16 samples larger than the transfer size
samplesPerBuffer = samplesPerRecord + 16;

% Set the number of samples per record
retCode = calllib('ATSApi', 'AlazarSetRecordSize', boardHandle, preTriggerSamples, postTriggerSamples);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetRecordSize failed -- %s\n', errorToText(retCode));
    return;
end

% Set the number of records in the acquisition
retCode = calllib('ATSApi', 'AlazarSetRecordCount', boardHandle, recordsPerCapture);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetRecordCount failed -- %s\n', errorToText(retCode));
    return;
end

% Arm the board system to begin the acquisition 
retCode = calllib('ATSApi', 'AlazarStartCapture', boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarStartCapture failed -- %s\n', errorToText(retCode));
    return;
end

% Create progress window
waitbarHandle = waitbar(0, ...
                        sprintf('Captured 0 of %u records', recordsPerCapture), ...
                        'Name','Capturing ...', ...
                        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
setappdata(waitbarHandle, 'canceling', 0);

% Wait for the board to capture all records to on-board memory
fprintf('Capturing %u records ...\n', recordsPerCapture);

tic;
updateTic = tic;
updateInterval_sec = 0.1;
captureDone = false;
triggerTic = tic;
triggerCount = 0;

while ~captureDone
    if ~calllib('ATSApi', 'AlazarBusy', boardHandle)
        % The capture to on-board memory is done
        captureDone = true;
    elseif toc(triggerTic) > timeout_sec
        % The acquisition timeout expired before the capture completed
        % The board may not be triggering, or the capture timeout may be too short.
        fprintf('Error: Capture timeout after %.3f sec -- verify trigger.\n', timeout_sec);
        break;
    elseif toc(updateTic) > updateInterval_sec         
        updateTic = tic;                
        % Check if the waitbar cancel button was pressed
        if getappdata(waitbarHandle,'canceling')
            break
        end        
        % Get the number of records captured = triggers received
        [retCode, boardHandle, recordsCaptured] = calllib('ATSApi', 'AlazarGetParameter', boardHandle, 0, GET_RECORDS_CAPTURED, 0);
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarGetParameter failed -- %s\n', AlazarErrorToText(retCode));
            break;
        end        
        if triggerCount ~= recordsCaptured            
            % Update the waitbar progress 
            waitbar(double(recordsCaptured) / double(recordsPerCapture), ...
                    waitbarHandle, ...
                    sprintf('Captured %u of %u records', recordsCaptured, recordsPerCapture));                
            % Reset the trigger timeout counter
            triggerCount = recordsCaptured;
            triggerTic = tic;
        end       
    else
        % Wait for triggers
        pause(0.01);
    end        
end

% Close progress bar
delete(waitbarHandle);

if ~captureDone
    % Abort the acquisition
    retCode = calllib('ATSApi', 'AlazarAbortCapture', boardHandle);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarAbortCapture failed -- %s\n', errorToText(retCode));
    end
    return;
end

% The board captured all records to on-board memory
captureTime_sec = toc;
if captureTime_sec > 0.
    recordsPerSec = recordsPerCapture / captureTime_sec;
else
    recordsPerSec = 0.;
end
fprintf('Captured %u records in %g sec (%.4g records / sec)\n', recordsPerCapture, captureTime_sec, recordsPerSec);
	
% Create a buffer to store a record
buffer = uint16(zeros(1,samplesPerBuffer));

% Create a data file if required
fid = -1;
if saveData
    fid = fopen('data.bin', 'w');
    if fid == -1
        fprintf('Error: Unable to create data file\n');        
    end
end

% If plotting data then calculate scale factors to convert sample
% values to volts, and allocate a buffer to store the values in volts.
% if plotData
    % This 16-bit sample code represents a 0V input
    codeZero = 2 ^ (double(bitsPerSample) - 1) - 0.5;

    % This is the range of 16-bit sample codes with respect to 0V level
    codeRange = 2 ^ (double(bitsPerSample) - 1) - 0.5;

    % Subtract this amount from a 16-bit sample value to remove the 0V offset
    offsetValue = codeZero;

    % Multiply a 16-bit sample value by this factor to convert it to volts
    scaleValueChA = inputRangeIdToVolts(InputRangeIdChA) / codeRange;
    scaleValueChB = inputRangeIdToVolts(InputRangeIdChB) / codeRange;

    % create an array to store sample data     
    bufferVolts = zeros(channelCount, samplesPerRecord);
% end   

% Create progress window
waitbarHandle = waitbar(0, ...
                        sprintf('Transferred 0 of %u records', recordsPerCapture), ...
                        'Name','Reading ...', ...
                        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
setappdata(waitbarHandle, 'canceling', 0);

% Transfer the records from on-board memory to our buffer
fprintf('Transferring %u records ...\n', recordsPerCapture);

tic;
updateTic = tic;
bytesTransferred = 0;
success = true;
idx = 0;

for record = 0 : recordsPerCapture - 1    
    idx = idx + 1;
    rowInPlotBuffer = 1;
    
    for channel = 0 : channelsPerBoard - 1        
        % Find channel Id from channel index
        channelId = 2 ^ channel;

        % Skip this channel if it's not in channel mask
        if ~bitand(channelId,channelMask)
            continue;
        end
        
        % Transfer one full record from on-board memory to our buffer
        [retCode, boardHandle, bufferOut] = ...
            calllib('ATSApi', 'AlazarRead', ...
                boardHandle,            ...	% HANDLE -- board handle
                channelId,              ...	% U32 -- channel Id
                buffer,                 ...	% void* -- buffer
                bytesPerSample,         ...	% int -- bytes per sample
                record + 1,             ... % long -- record (1 indexed)
                -int32(preTriggerSamples),   ...	% long -- offset from trigger in samples
                samplesPerRecord		...	% U32 -- samples to transfer
                );
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarRead record %u failed -- %s\n', record, errorToText(retCode));
            success = false;
        else
            bytesTransferred = bytesTransferred + bytesPerRecord;

            % TODO: Process record here.
            % 
            % Samples values are arranged contiguously in the buffer.
            % A 16-bit sample code is stored in each 16-bit sample value. 
            %
            % Sample codes are unsigned by default so that:
            % - a sample code of 0x0000 represents a negative full scale input signal;
            % - a sample code of 0x8000 represents a ~0V signal;
            % - a sample code of 0xFFFF represents a positive full scale input signal.

            if fid ~= -1
                samplesWritten = fwrite(fid, bufferOut(1:samplesPerRecord), 'uint16');
                if samplesWritten ~= samplesPerRecord
                    fprintf('Error: Write record %u failed\n', record);
                    success = false;
                end
            end
            
%             if plotData
                % Find scale factor for this channel
                if channelId == CHANNEL_A
                    scaleValue = scaleValueChA;
                else
                    scaleValue = scaleValueChB;                   
                end
                    
                % Convert sample values to volts and store for display
                for col = 1 : samplesPerRecord
                    bufferVolts(rowInPlotBuffer, col) = scaleValue * (double(bufferOut(col)) - offsetValue);
                end
                rowInPlotBuffer = rowInPlotBuffer + 1;
%             end                     
        end
        
        if ~success
            break;
        end
               
    end % next channel 
chA(:,idx) = bufferVolts(1,:);
chB(:,idx) = bufferVolts(2,:);    
% % %     % Draw all enabled channels on the same plot    
% % %     if plotData
% % %         for channel = 1:channelCount
% % %             if channel == 1
% % %                 % draw first channel in cyan
% % %                 hold off;
% % %                 color = 'c';
% % %             else
% % %                 % overlay next channel in magenta
% % %                 hold on;
% % %                 color = 'm';
% % %             end           
% % %             plot(bufferVolts(channel,:), color);
% % %         end
% % %         hold off
% % %     end
    
    if toc(updateTic) > updateInterval_sec
        % Check if waitbar cancel button was pressed            
        if getappdata(waitbarHandle,'canceling')
            break
        end        
        % Update progress        
        waitbar(double(record) / double(recordsPerCapture), ...
                waitbarHandle, ...
                sprintf('Transferred %u of %u records', record, recordsPerCapture));            
        updateTic = tic;
    end

end % next record

outA = sum(chA,2);%/double(recordsPerCapture);
outB = sum(chB,2);%/double(recordsPerCapture);
% Close progress bar
delete(waitbarHandle);

% Display results
transferTime_sec = toc;
if transferTime_sec > 0.
    bytesPerSec = bytesTransferred / transferTime_sec;
else
    bytesPerSec = 0.;
end
fprintf('Transferred %d bytes in %g sec (%.4g bytes per sec)\n', bytesTransferred, transferTime_sec, bytesPerSec);

% Close the data file
if fid ~= -1
    fclose(fid);
end

result = true;