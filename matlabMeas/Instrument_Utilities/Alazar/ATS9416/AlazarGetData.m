%% Acquire data from ATS9416 board and average
global samplesPerSec;
global inputRange_volts

inputRange_volts = 1;
samplesPerSec = 10e6;

buffers = 1; % Set at least 2 buffers to allow for continuous data transfer
records = 1; % Set number of averages
samples = 100000; % Let's get many more samples for avg., 1000 should be about 100 cycles

[~,buffer,bitsPerSample,samplesPerRecord,channelCount] = ATS9416AcquireData_NPT(boardHandle,samples,records,buffers);

bufferShift = buffer / 2^(16-double(bitsPerSample)); % Right shift 16-bit to get 14-bit
%bufferCode = (bufferCode + 0x2000) & 0x1FF;

% This 14-bit sample code represents a 0V input
codeZero = 2^(double(bitsPerSample) - 1) - 0.5; % double((bitsPerSample - 1) * 2^1 - 0.5);

% This is the range of 14-bit sample codes with respect to 0V level
codeRange = 2^(double(bitsPerSample) - 1) - 0.5; % double((bitsPerSample - 1) * 2^1 - 0.5);

% Create an array to store sample data
bufferVolts = zeros(channelCount,samples);
sine = true;

if records > 1
    for i = 1:records
        for j = 1:channelCount
            col = 1; % Set counter
            for k = j:channelCount:(length(buffer)/records)
                bufferVolts(j,col) = inputRange_volts * (double(bufferShift(k)) - codeZero) / codeRange; % need double or else just have int
                col = col + 1;
            end
            if sine == true
                midPoint = min(bufferVolts(j,:)) + (max(bufferVolts(j,:)) - min(bufferVolts(j,:))) / 2;
                bufferVolts(j,:) = bufferVolts(j,:) - midPoint;
            end
        end
    end

else % For measurements with 1 record only
    for i = 1:channelCount % Each row contains a separate channel
        col = 1; % Set counter
        for j = i:channelCount:length(buffer) % Channel data is interleaved
            bufferVolts(i,col) = inputRange_volts * (double(bufferShift(j)) - codeZero) / codeRange; % Need double or else just have int
            col = col + 1;
        end
        if sine == true
            midPoint = min(bufferVolts(i,:)) + (max(bufferVolts(i,:)) - min(bufferVolts(i,:))) / 2;
            bufferVolts(i,:) = bufferVolts(i,:) - midPoint;
        end
    end
end

xaxis = linspace(0, samples/samplesPerSec, length(bufferVolts(1,:)));

figure()
plot(xaxis,bufferVolts(1,:))
% plot(xaxis,bufferVolts(2,:))