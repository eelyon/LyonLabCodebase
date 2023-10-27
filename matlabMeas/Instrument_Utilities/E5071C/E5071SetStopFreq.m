function [] = E5071SetStopFreq(ENA,freqInMHz)
 command = [':SENS1:FREQ:STOP ', num2str(freqInMHz*1e6)];
 fprintf(ENA,command);
end