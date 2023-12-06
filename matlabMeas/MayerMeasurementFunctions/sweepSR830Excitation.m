startExcitation = .02;
stopExcitation = .1;
numExcitations = 9;
deltaExcitation = (.1-.02)/(8);
amps = [.008,.007,.006,.005,.004,.003,.002];
for i = 1:length(amps)
    currentExcitation = amps(i);
    SR830.SR830setAmplitude(currentExcitation*100);
    mag = sqrt(SR830.SR830queryY()^2);
    for j = 1:5
        SR830.adjustSensitivity(mag*1e6);
        delay(1);
    end
    delay(1);
    sweep1DMeasSR830({'DP'},0,0.2,0.001,.1,16,{SR830},DAC,{9},1);
end
