samplingTime = 1e-3; % Sampling time
samples = samplingTime/(1/10e6); % Number of samples for sampling rate of 10MHz
navg = 10; % Number of averages
nrecords = 1;

[time,avgVolts] = deal([]);

vectorRepeat = [];

% result = false;

for i = 1:navg
    [result, xaxis, bufferVolts] = ATS9416AcquireData_NPT(boardHandle,samples,nrecords);
    for j = 1:length(bufferVolts)
        vectorRepeat(i) = bufferVolts(j);
    end
end

% results = success;