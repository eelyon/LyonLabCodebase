function [] = E5071SetDelay(ENA,startFreq,stopFreq)
% Function that uses the ENA's Marker->Delay function to evaluate the
% electrical delay. Make sure to choose a large enough window for the ENA
% to evaluate the electrical delay, but also not too large. A few GHz is
% usually good.
% param ENA: callable object
% param startFreq: start frequency of sweep
% param stopFreq: stop frequency of sweep

% Set quick measurement sweep
E5071SetIFBand(ENA,5); % in kHz
E5071SetSweepTime(ENA,1); % in secs

E5071SetStartFreq(ENA,startFreq);
E5071SetStopFreq(ENA,stopFreq);

fprintf(ENA,':INIT1:IMM'); % Set trigger value - for continuous set: ':INIT:CONT ON'
fprintf(ENA,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
fprintf(ENA,':TRIG:SING'); % Trigger ENA to start sweep cycle
query(ENA,'*OPC?') % Execute *OPC? command and wait until command return 1

fprintf(ENA,':CALC1:SEL:MARK1:SET DEL'); % Set electrical delay

edelay = str2num(query(ENA,':CALC1:SEL:CORR:EDEL:TIME?'));

fprintf('The electrical delay is (sec) %.5e \n', edelay);

end