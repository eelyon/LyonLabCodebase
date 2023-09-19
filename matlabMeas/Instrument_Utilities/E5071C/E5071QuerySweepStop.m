function [ freqStop] = E5071QuerySweepStop(ENA)
  freqStop = str2num(query(ENA,':SENS1:FREQ:STOP?'));
end

