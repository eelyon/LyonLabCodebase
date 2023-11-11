function [sweepTime] = E5071QuerySweepTime(ENA)
    sweepTime = str2num(query(ENA,'SENS1:SWE:TIME?'));
end