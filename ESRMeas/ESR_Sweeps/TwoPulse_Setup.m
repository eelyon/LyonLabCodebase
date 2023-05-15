clc; clear all;

if libisloaded('spinapi') == 0
    loadlibrary('C:\SpinCore\SpinAPI\dll\spinapi.dll','C:\SpinCore\SpinAPI\dll\spinapi.h');
end;

calllib('spinapi','pb_stop');
calllib('spinapi','pb_close');

agilent_needs_to_be_reloaded = 1;

%% AGILENT PRELOADING

% Global variables
Agilent_globals();

% Connect to Agilent
agt_connect_and_initialize;

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Microwave frequency and output power
mw_freq = 9732.6144;%9631.5107; % in MHz
agt_sendcommand(io, ['SOURce:FREQuency ' int2str(round(mw_freq*1e6))]);
agt_sendcommand(io, 'POWer -20');                    
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% TWT: power should be set to 2dBm (or less) to avoid saturating the TWT
% AR solid state: power should be set below -10dBm (which is strange! it should be 0dBm according to specs)
% Also change the gate pulse to POS for TWT and NEG for AR

% Define/load the pulse sequence 
sequenceName = sprintf('2pulse_a2');
sequence = 'a 2'; % pi/2(x) - tau - pi(y) - tau

% Create and load standard (square and adiabatic pi/2, pi) pulses to Agilent
if(agilent_needs_to_be_reloaded)
    agt_load_standard_pulses(sequence);
    agt_load_pulse_sequence(sequence,sequenceName);
end; 

agt_advanced_trigger_mode;

%% PULSEBLASTER CONTROL

PulseBlaster_definitions; % definitions from SpinCore
PulseBlaster_globals;
PulseBlaster_connect_and_initialize;

% ++++++++++++++++++++++++++++++++++++++++++++++++++
Alazar_Delay = -2000; % d0 delay [in ns]

tau0 = 15*us; % initial tau [in ns]  
dtau = 00*ns; % tau step [in ns]
ntau = 10; % # of time steps
h = 100000;  % # of shots

srt = 200*ms; % short repetition time
            % (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
d9 = 150*ms;  % delay to accomodate an LED pulse 
% +++++++++++++++++++++++++++++++++++++++++++++++++++

%% Field Controller
global B0_center B0_sweep_width nB0 B0_wait;

% +++++++++++++++++++++++++++++++++++++++++++++++++++
g_factor = 1.99875;%2.0003; % E' centers in quartz
field_error = -4.2; % between -3.9 and -4.35 Gauss
% +++++++++++++++++++++++++++++++++++++++++++++++++++

B0 = mw_freq/2.8025 * 2.0023/g_factor + field_error - 21;
B0_center = round(B0*20)/20.0;
B0_sweep_width = 0.1; % Keep it low for better precision
nB0 = 1;
B0_wait = 0;


%ConnectMag;
%pause(1)
%fieldController(SIM900,3.4844e+03);

%% Main loop
for itau = (1:ntau)

  tau = tau0 + (itau-1)*dtau;
    
  start_program; % Begin pulse program
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
    h_loop = start_loop(h); % Start of shot loop
    
      delay(10*MIL);       % Initial instruction should be longer than 2*MIL
%         Wait_for_Trigger;  % (WAIT can not be the 1st instruction) 
       

      %LED_Trigger;
      %delay(d9);  % Delay to accomodate LED pulse (or prep E-pulse)
      ZTO_Trigger;
      Alazar_Trigger;

      pulse;               % pi/2 pulse1
      
%       pre_delay = 0.1*us;
%       delay(pre_delay);         % tau
%       Stark_Trigger;               % E-pulse trigger
      delay(tau-d_a1); % tau
      
      
%       delay(tau-d_a1);     % tau
      pulse;               % inversion pi pulse
      delay(tau-d_11 + Alazar_Delay);  % tau + d0 delay
     
%       Alazar_Trigger; 
    
    end_loop(h_loop,srt); % End of shot loop
  
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
  stop_program; % End of program 
         
  PulseBlaster_run_wait_to_finish;
 
   disp(itau);
end;

% Stop and close PulseBlaster
calllib('spinapi','pb_stop');
calllib('spinapi','pb_close');


disp('Done!');
