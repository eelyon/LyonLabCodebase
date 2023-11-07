function [] = E5071SetStartPow(ENA,powIndBm)
 command = [':SOUR1:POW:STAR ',num2str(powIndBm)];
 fprintf(ENA,command);
end