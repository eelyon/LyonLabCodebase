function [sweepSpan] = E5071QuerySweepSpan( ENA )
  sweepSpan = str2num(query(ENA,':SENS1:FREQ:SPAN?'));
end

