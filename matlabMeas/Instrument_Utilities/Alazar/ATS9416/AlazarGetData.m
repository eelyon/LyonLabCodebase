%% Acquire data from ATS9416 board and average
samplesPerSec = 10e6;
buffers = 2; % Set at least 2 buffers to allow for continuous data transfer
records = 1; % Set number of averages
samples = 1000; % Let's get many more samples for avg., 1000 should be about 100 cycles

[~,buffer,bitsPerSample,samplesPerRecord,channelCount] = ATS9416AcquireData_NPT(boardHandle,samples,records,buffers);

% This 16-bit sample code represents a 0V input
codeZero = 2 ^ (double(bitsPerSample) - 1) - 0.5;

% This is the range of 16-bit sample codes with respect to 0V level
codeRange = 2 ^ (double(bitsPerSample) - 1) - 0.5;

% Subtract this amount from a 16-bit sample value to remove the 0V offset
offsetValue = codeZero;

% Multiply a 16-bit sample value by this factor to convert it to volts
scaleValue = 1 / codeRange;

% create an array to store sample data
% bufferPerCh = [];
bufferVolts = zeros(channelCount,samples);
rec = 1;
sine = true;
% bufferVolts = zeros(channelCount, samplesPerRecord);

% bufferVolts = scaleValue*(double(buffer(2:2:end))-offsetValue);

if records > 1
    for i = 1:records
        for j = 1:channelCount
        %     for j = i:channelCount:length(buffer)
        %         bufferVolts(i,j) = scaleValue * (double(buffer(j)) - offsetValue); % need double or else just have int
        %     end
            for k = j:channelCount:(length(buffer)/records)
        %         bufferPerCh = buffer(i:channelCount:length(buffer));
                bufferVolts(j,rec) = scaleValue * (double(buffer(k)) - offsetValue); % need double or else just have int
                rec = rec + 1;
            end
        
            if sine == true
                midPoint = min(bufferVolts(j,:)) + (max(bufferVolts(j,:)) - min(bufferVolts(j,:))) / 2;
                bufferVolts(j,:) = bufferVolts(j,:) - midPoint;
            end
        end
    end
else
    % Convert sample values to volts and store for display
    for i = 1:channelCount
    %     for j = i:channelCount:length(buffer)
    %         bufferVolts(i,j) = scaleValue * (double(buffer(j)) - offsetValue); % need double or else just have int
    %     end
        for j = i:channelCount:length(buffer)
    %         bufferPerCh = buffer(i:channelCount:length(buffer));
            bufferVolts(i,rec) = scaleValue * (double(buffer(j)) - offsetValue); % need double or else just have int
            rec = rec + 1;
        end
    
        if sine == true
            midPoint = min(bufferVolts(i,:)) + (max(bufferVolts(i,:)) - min(bufferVolts(i,:))) / 2;
            bufferVolts(i,:) = bufferVolts(i,:) - midPoint;
        end
    end
end



% midPoint = min(bufferVolts) + (max(bufferVolts) - min(bufferVolts)) / 2;  % just for sine wave
% bufferVolts = bufferVolts - midPoint;
xaxis = linspace(0, samples / samplesPerSec, length(bufferVolts(1,:)));

figure()
% plot(bufferVolts(1,:));
plot(xaxis,bufferVolts(1,:));