function agt_load_pulse2(IQ_data,name,markers)

% global variables
global Clock_frequency;        % hertz
global io2;
IQ_data
agt_waveformload_modified2(io2, IQ_data, name, Clock_frequency, 'no_play', 'no_normscale', markers);
agt_sendcommand(io2, ':RAD:ARB:MPOL:MARK1 NEG'); % (NEG) defense pulse for Comtech PIN diode in B413 
agt_sendcommand(io2, ':RAD:ARB:MPOL:MARK2 POS'); % (POS) defense pulse for Hettite PIN diode in B413
% agt_sendcommand(io2, ':RAD:ARB:MPOL:MARK3 POS'); % (POS) RF blanking in B413
% agt_sendcommand(io2, ':RAD:ARB:MPOL:MARK4 POS'); % (POS) TWT Amplifier in B413

% agt_sendcommand(io2, ':RAD:ARB:MDES:PULS M2'); % Assign M2 marker for RF blanking
