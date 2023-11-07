function [] = E5071SetStartFreq(ENA,freqInMHz)
 command = [':SENS1:FREQ:STAR ', num2str(freqInMHz*1e6)];
 fprintf(ENA,command);
end