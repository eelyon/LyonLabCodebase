%% This script sets up a frequency sweep on the vna every given time between
% points
powerIndBm = -5; % dBm
startFreq = 1285; % MHz
stopFreq = 1365; % MHz
tag = 'freqSweepFilter_warmUp';

thermometerType = 'X117656';
Therm = initializeThermometry(thermometerType);

timeBetweenPoints = 60; % in seconds
startTime = now();
time = [];
i = 1;

while 1
    time(i) = (now()-startTime)*86400/60;
    E5071FreqSweep(ENA,powerIndBm,startFreq,stopFreq,Therm,Thermometer,tag);
    i = i+1;
    pause(timeBetweenPoints)
    close all
end