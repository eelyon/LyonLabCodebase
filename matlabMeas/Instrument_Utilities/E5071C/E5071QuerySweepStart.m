function [startFreq] = E5071QuerySweepStart(ENA)
  startFreq = str2num(query(ENA,':SENS1:FREQ:STAR?'));
end

