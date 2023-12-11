function [freq,PSD] = PSDfromNoiseData(sweepTime,numPoints,noiseData)
    % Gives the Power Spectral density from a noise measurement in the time
    % domain.
    % param sweepTime: duration of time domain sweep (in secs)
    % param numPoints: number of points in time domain sweep
    % param noiseData: time domain y data
    Ts = str2num(sweepTime)/str2num(numPoints); % Time increment per point
    fs = 1/Ts; % Sampling rate
    
    n = length(noiseData);
    y = fft(noiseData);
    y = y(1:floor(n/2)+1);
    PSD = 2*(1/(sqrt(fs)*n))*abs(y); % Multiply by two to conserve power
    % PSD_dB = 10*log10(PSD);
    freq = 0:fs/length(noiseData):fs/2;
end