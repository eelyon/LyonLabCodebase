%% Initialise Alazar (ATS9416) board, configure, and acquire data
% ATS9416Initialize;
samplesPerSec = 10e6;
buffers = 1;
records = 1;
samples = 1000;

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
bufferVolts = [];
rec = 1;
% bufferVolts = zeros(channelCount, samplesPerRecord);

% bufferVolts = scaleValue*(double(buffer(2:2:end))-offsetValue);

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
    j
    rec
end

midPoint = min(bufferVolts) + (max(bufferVolts) - min(bufferVolts)) / 2;  % just for sine wave
bufferVolts = bufferVolts - midPoint;
xaxis = linspace(0, samples / samplesPerSec, length(bufferVolts));

figure()
% plot(bufferVolts(1,:));
plot(xaxis,bufferVolts(1,:));