function agt_load_pulse(IQ_data,name,markers)

% global variables
global Clock_frequency;        % hertz
global io;

agt_waveformload_modified(io, IQ_data, name, Clock_frequency, 'no_play', 'no_normscale', markers);
agt_sendcommand(io, ':RAD:ARB:MPOL:MARK1 NEG'); % (NEG) defense pulse for Comtech PIN diode in B413 
agt_sendcommand(io, ':RAD:ARB:MPOL:MARK2 POS'); % (POS) defense pulse for Hettite PIN diode in B413
agt_sendcommand(io, ':RAD:ARB:MPOL:MARK3 POS'); % (POS) RF blanking in B413
agt_sendcommand(io, ':RAD:ARB:MPOL:MARK4 NEG'); % (POS) TWT Amplifier in B413

agt_sendcommand(io, ':RAD:ARB:MDES:PULS M3'); % Assign M3 marker for RF blanking
