function [] = E5071SetStopPow(ENA,powIndBm)
 command = [':SOUR1:POW:STOP ',num2str(powIndBm)];
 fprintf(ENA,command);
end