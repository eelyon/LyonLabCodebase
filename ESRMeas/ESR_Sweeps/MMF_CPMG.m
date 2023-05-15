clc; clear all;

%% Options
Field_Sweep = 0; % Set 1 to do field sweep;
Check_Integral = 1; % Set to 1 to check the integral limits at a given field.
agilent_needs_to_be_reloaded = 1;
shotNum=1;

%% HF loop

if libisloaded('spinapi') == 0
  loadlibrary('C:\SpinCore\SpinAPI\dll\spinapi.dll','C:\SpinCore\SpinAPI\dll\spinapi.h');
end;

calllib('spinapi','pb_stop');
calllib('spinapi','pb_close');

%% AGILENT PRELOADING

% Global variables
Agilent_globals(); %*** here you set the pi pulse length and defense pulse lengths

% Connect to Agilent
agt_connect_and_initialize; % here set IP address

%% Get Parameters
get_parameters;


%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Microwave frequency and output power
mw_freq = parameters.mw_freq; % in MHz
mw_power = parameters.mw_power;
agt_sendcommand(io, ['SOURce:FREQuency ' int2str(round(mw_freq*1e6))]);
agt_sendcommand(io, ['POWer ' num2str(mw_power)]);
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% TWT: power should be set to 2dBm (or less) to avoid saturating the TWT
% AR solid state: power should be set below -10dBm (which is strange! it should be 0dBm according to specs)
% Also change the gate pulse to POS for TWT and NEG for AR

% Define/load the pulse sequence
sequenceName = sprintf('2pulse_a2');
sequence = 'a '; % pi/2(x) - tau - pi(y) - tau
numPulses = parameters.npulse;
for i = 1:numPulses
  sequence = [sequence, '2 '];
end
% a,b,c,d = pi/2 pulses
% 1,2,3,4 = pi pulses
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
Alazar_Delay = parameters.Alazar_Delay;%2000; % d0 delay [in ns] Trigger Delay

tau0 = parameters.tau0; % initial tau [in ns]

h = parameters.h;  % # of shots
srt = parameters.srt;%shot repetition time

% (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
d9 = parameters.d9;  % delay to accomodate an LED pulse
% +++++++++++++++++++++++++++++++++++++++++++++++++++

%% Alazar Parameters

averages = parameters.averages;%10; % should be much less than h to take into account delay in arming Alazar.
acq_time = parameters.acq_time;%15e-6; % in seconds 15
nrepeat = parameters.nrepeat;%1;

pre_trig = 0; %4098; % number of samples to keep before trigger. default zero to avoid trigger pulsing during echo.
post_trig = round(acq_time / (4e-9)); % number of samples to keep after trigger.

%% Alazar Configure
disp('Loading Alazar Libraries...');
alazarLoadLibrary
AlazarDefs

acqinfo = [];
sysinfo = [];

systemId = int32(1);
boardId = int32(1);

handle1 = calllib('ATSApi', 'AlazarGetBoardBySystemID', systemId, boardId);
boardHandle = handle1;
setdatatype(boardHandle, 'voidPtr', 1, 1);
if boardHandle.Value == 0
  fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
  return
end

[retCode, sysinfo.boardHandle, sysinfo.maxSamplesPerRecord, sysinfo.bitsPerSample] = calllib('ATSApi', 'AlazarGetChannelInfo', handle1, 0, 0);

if retCode ~= ApiSuccess
  fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
  return
end

sysinfo.ChannelCount = 2;
disp('configuring board')
configureBoard(boardHandle);
disp('board configured')

%% Field Controller
tau = tau0;
itau = 1;
start_program; % Begin pulseblaster program
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  delay(10*ms)
  h_loop = start_loop(h); % Start of shot loop
  delay(10*MIL);       % Initial instruction should be longer than 2*MIL
  LED_Trigger;
  delay(d9);  % Delay to accomodate LED pulse (or prep E-pulse)
  pulse;
  delay(tau-d_a1);     % tau
  Alazar_Trigger;
  for i = 1:numPulses
    pulse; % inversion pi pulse
    delay(2*tau-d_11);
  end
  
  delay(tau-d_11-Alazar_Delay);  % tau + d0 delay
  
%
end_loop(h_loop,srt); % End of shot loop

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
stop_program; % End of program

%% Main loop

chAintegrated = zeros(post_trig-pre_trig,1);
chBintegrated = zeros(post_trig-pre_trig,1);

for repeatAvg = 1:nrepeat;
  PulseBlaster_run_wait_to_finish;
  [chA,chB,result] = acquireData(boardHandle, pre_trig, post_trig, averages);
  retCode = calllib('ATSApi', 'AlazarAbortCapture', boardHandle);
  chAintegrated = chAintegrated + chA;
  chBintegrated = chBintegrated + chB;
  istatus = calllib('spinapi','pb_read_status');
  
  while (mod(istatus,2)==0); % read least significant bit (bit 0); if it's a 1, program has finished
    istatus = calllib('spinapi','pb_read_status');
  end;
end;

calllib('spinapi','pb_reset');  % Reset the program to the 1st instruction
x_time = linspace(0,acq_time,(post_trig - pre_trig)); % do not comment this line out if rephasing and integrating data.

%% Rephase and Integrate Data
clear Y1;
chA = chAintegrated/nrepeat/averages;
chB = chBintegrated/nrepeat/averages;
Y1 = chA' + 1i*chB';


b_1 = parameters.b_1; %4.5e-6; % time in s after trigger to start baseline correct
b_2 = parameters.b_2; %5.0e-6; % time in s after trigger to stop baseline correct
b_3 = parameters.b_3;%7.0e-6; % time in s after trigger to start baseline correct
b_4 = parameters.b_4; % time in s after trigger to stop baseline correct
int_w = parameters.int_w;%600e-9; % integral width/2
int_c = parameters.int_c;%6.00e-6; % integral center
e_1 = int_c - int_w/2; %1.3e-6; % time in s after trigger to start echo integral;
e_2 = int_c + int_w/2; %2.3e-6; % time in s after trigger to end echo intergral;


% Define indexes (markers) for baseline correction
bl1 = round(b_1*(post_trig - pre_trig)/acq_time);
bl2 = round(b_2*(post_trig - pre_trig)/acq_time);
bl3 = round(b_3*(post_trig - pre_trig)/acq_time);
bl4 = round(b_4*(post_trig - pre_trig)/acq_time);
int1 = round(e_1*(post_trig - pre_trig)/acq_time);
int2 = round(e_2*(post_trig - pre_trig)/acq_time);

m = [bl1 bl2 bl3 bl4]; %define markers

% Linear baseline and plot it
x = [x_time(m(1):m(2)) x_time(m(3):m(4))]';
yR = real([Y1(m(1):m(2)) Y1(m(3):m(4))])'; % real
yI = imag([Y1(m(1):m(2)) Y1(m(3):m(4))])'; % imaginary
qfitR = fit(x,yR,'poly1');
qfitI = fit(x,yI,'poly1');
xb = x_time(m(1):m(4));
yb = (qfitR.p1+1i*qfitI.p1)*xb + (qfitR.p2+1i*qfitI.p2);

% Data after baseline correction
Y2 = Y1(m(1):m(4)) - yb;

field(shotNum) = shotNum;

signalI(shotNum) = sum(real(Y2(int1-bl1:int2-bl1)));
signalQ(shotNum) = sum(imag(Y2(int1-bl1:int2-bl1)));
signal(shotNum) = sum(abs(Y2(int1-bl1:int2-bl1)));

IQPlot = figure(2);
plot(xb,real(Y2),'green',xb,imag(Y2),'blue')
IQFigName = genFigName('MMF\_CPMG\_IQ');

for i = 1:1:4
  i1 = m(i);
  line([x_time(i1) x_time(i1)],[-1 1]*.1*max(abs(chA(m(2):m(3)))+abs(chB(m(2):m(3)))),'Color','red','LineWidth',3);
end;

line([x_time(int1) x_time(int1)],[-1 1]*.1*max(abs(chA(m(2):m(3)))+abs(chB(m(2):m(3)))),'Color','black','LineWidth',3);
line([x_time(int2) x_time(int2)],[-1 1]*.1*max(abs(chA(m(2):m(3)))+abs(chB(m(2):m(3)))),'Color','black','LineWidth',3);
xlabel('Time (s)')
ylabel('ESR Signal (arb. units)')
title('Integration Limits (I = green, Q = blue)')
IQxLim = xlim;
IQyLim = ylim;
text(IQxLim(2),IQyLim(2),IQFigName,'HorizontalAlignment','right','VerticalAlignment','top')

% Stop and close PulseBlaster
calllib('spinapi','pb_stop');
calllib('spinapi','pb_close')
distributeCPMGData(xb,real(Y2),imag(Y2),parameters);

global Pi_pulse_length;
HF = 1;
data(HF).field = field;
data(HF).signal = signal;
save data;

data(HF).field = field;
data(HF).signalI = signalI;
data(HF).signalQ = signalQ;
data(HF).signal = signal;
data(HF).parameters = parameters;
data(HF).integrationwidth = int_w;
data(HF).Pi_pulse_length = Pi_pulse_length;
saveData(IQPlot,'MMF_CPMG_IQ');
disp('Done!');

