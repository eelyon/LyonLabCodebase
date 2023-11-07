function [] = E5071SetPower(ENA,powerdBm)
 command = [':SOUR1:POW ',num2str(powerdBm)];
 fprintf(ENA,command);
end