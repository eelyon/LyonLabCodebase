global Pi_pulse_length; 
global p1u_duration;
global p1w_duration;

global TRIG_Agilent;
global TRIG_ZTO;
global TRIG_Alazar;
global TRIG_LED;

global Agilent_TriggerLength;
global ZTO_TriggerLength;
global Alazar_TriggerLength;
global LED_TriggerLength;

global clock_freq;
global MIL;

%%% Connect and initialize
disp('Start programming PulseBluster');
calllib('spinapi','pb_select_board',1);
    
% Initialize the board
if (calllib('spinapi','pb_init') ~= 0)
  disp(['Error initializing board: ' calllib('spinapi','pb_get_error')]);
  return;
end;

% Set PulseBlaster clock frequency (MHz)
calllib('spinapi','pb_set_clock',clock_freq);

% Compensation delays for PulseBlaster
d_a1 = round( (Pi_pulse_length/2 - Pi_pulse_length/4) + Agilent_TriggerLength);
d_1a = round( (Pi_pulse_length/4 - Pi_pulse_length/2) + Agilent_TriggerLength);
d_aa = Agilent_TriggerLength;
d_11 = Agilent_TriggerLength;

d_aw = round( (p1w_duration/2 - Pi_pulse_length/4) + Agilent_TriggerLength);
d_uw = round( (p1w_duration/2 - p1u_duration) + Agilent_TriggerLength); % half length of pi minus full length of pi/2
d_u1 = round( (Pi_pulse_length/2 - p1u_duration) + Agilent_TriggerLength);
d_ww = Agilent_TriggerLength;
