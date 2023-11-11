function [] = E5071SetSweepTime(ENA,sweepTimeInSec)
 command = [':SENS1:SWE:TIME ',num2str(sweepTimeInSec)];
 fprintf(ENA,command);
end