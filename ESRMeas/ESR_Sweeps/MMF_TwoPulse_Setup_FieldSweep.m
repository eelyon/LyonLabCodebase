clc; clear all;

%% Options
Field_Sweep = 1; % Set 1 to do field sweep;
Check_Integral = 1; % Set to 1 to check the integral limits at a given field.
agilent_needs_to_be_reloaded = 0;
flowCryo = 0;

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
sequence = 'a 2'; % pi/2(x) - tau - pi(y) - tau
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
dtau = 00*ns; % tau step [in ns]
ntau = 1; % # of time steps
h = parameters.h;%100000;  % # of shots

srt = parameters.srt;%2*ms; % short repetition time
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

% Get a handle to the board
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
global B0_center B0_sweep_width nB0 B0_wait;

% +++++++++++++++++++++++++++++++++++++++++++++++++++
% g_factor = 2.0003; % E' centers in quartz
% aiso = 0;
g_factor = parameters.g_factor; %1.99875% As donors in Ge
% aiso = 42; 
field_error = parameters.field_error; %-2.67;%-2.6%61%5%4%6; %2.3 between -3.9 and -4.35 Gauss -2.5
B0_span = parameters.B0_span;%150;
B0_step = parameters.B0_step;%.5;

% +++++++++++++++++++++++++++++++++++++++++++++++++++

B0_start =parameters.B0_start;

B0_center = round(B0_start*20)/20.0;
B0_sweep_width = 0.1; % Keep it low for better precision
nB0 = round(B0_span/B0_step);
B0_wait = parameters.B0_wait;%.1;
dB0 = B0_step; % B0 step in gauss


if(flowCryo)
  Field_Controller_initialize;
  Field_write(B0_start);
else
  ConnectMag;
  pause(1);
  %fieldController(SIM900,B0_start);
end
tau = tau0;
itau = 1;
start_program; % Begin pulseblaster program
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
      delay(10*ms)
      h_loop = start_loop(h); % Start of shot loop
    
      delay(10*MIL);       % Initial instruction should be longer than 2*MIL
      %calllib('spinapi','pb_inst_pbonly',TRIG_Stark,CONTINUE,0,d9); 
      %LED_Trigger;
      delay(d9);  % Delay to accomodate LED pulse (or prep E-pulse)
      %Alazar_Trigger;
     
      pulse;               % pi/2 pulse1 
      delay(tau-d_a1);     % tau
      %Alazar_Trigger;
      pulse;               % inversion pi pulse    
      delay(tau-d_11-Alazar_Delay);  % tau + d0 delay
      Alazar_Trigger;
    end_loop(h_loop,srt); % End of shot loop
  
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
 stop_program; % End of program 

%% Main loop
for iB0 = (1:nB0);
%   tau = tau0 + (iB0-1)*dtau;
 
  %%% SET FIELD %%%
 
  B0 = B0_start + iB0*dB0; %+               
  if flowCryo
    Field_write(B0);
    %pause(.5);
  else
    sweepFieldController(SIM900,B0);
  end
  disp('Waiting 20s after field change.')
  pause(20); 

  
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
    
  disp([int2str(iB0) ' of ' int2str(nB0)]);
  

  x_time = linspace(0,acq_time,(post_trig - pre_trig)); % do not comment this line out if rephasing and integrating data.

%%  This is to check the integral window. 
% % % figure;
% % % plot(x_time,chA,'r',x_time,chB,'b');


%% Rephase and Integrate Data
    clear Y1;
    chA = chAintegrated/nrepeat/averages;
    chB = chBintegrated/nrepeat/averages;
    Y1 = chA' + 1i*chB';

  % alazar delay 4000
  % alazar delay 4000
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

  field(iB0) = B0;

  signalI(iB0) = sum(real(Y2(int1-bl1:int2-bl1)));
  signalQ(iB0) = sum(imag(Y2(int1-bl1:int2-bl1)));
  signal(iB0) = sum(abs(Y2(int1-bl1:int2-bl1)));

  magnitudePlot = figure(1);
  plot(field,signal,'red');
  magFigName = genFigName('MMF\_Field\_Sweep\_Magnitude');
  texMag = text(0,1.05,magFigName,'FontSize',8,'Color','k');
  xlabel('B0 (gauss)')
  ylabel('Signal Intensity')
  title('Field Sweep - Magnitude')

  magxLim = xlim;
  magyLim = ylim; 

  text(magxLim(2),magyLim(2),magFigName,'HorizontalAlignment','right','VerticalAlignment','top')
  %pause(0.1)

  IQPlot = figure(2);
  plot(xb,real(Y2),'green',xb,imag(Y2),'blue')
  IQFigName = genFigName('MMF\_Field\_Sweep\_IQ');
    for i = 1:1:4
      i1 = m(i);
      line([x_time(i1) x_time(i1)],[-1 1]*.1*max(abs(chA(m(2):m(3)))+abs(chB(m(2):m(3)))),'Color','red','LineWidth',3);
    end;
      line([x_time(int1) x_time(int1)],[-1 1]*.1*max(abs(chA(m(2):m(3)))+abs(chB(m(2):m(3)))),'Color','black','LineWidth',3);
      line([x_time(int2) x_time(int2)],[-1 1]*.1*max(abs(chA(m(2):m(3)))+abs(chB(m(2):m(3)))),'Color','black','LineWidth',3);
  xlabel('Time (s)')
  ylabel('ESR Signal')
  title('Integration Limits (I = green, Q = blue)')
  IQxLim = xlim;
  IQyLim = ylim;
  text(IQxLim(2),IQyLim(2),IQFigName,'HorizontalAlignment','right','VerticalAlignment','top')
  %pause(0.1)
  gPlot = figure(3);
  plot(714.477./field.*parameters.mw_freq/1000,signalI,'green',714.477./field.*parameters.mw_freq/1000,signalQ,'blue');
  gFigName = genFigName('MMF\_Field\_Sweep\_gFactor');
  texG = text(0,1.05,gFigName,'FontSize',8,'Color','k');
  xlabel('g')
  ylabel('Signal Intensity')
  title('Field Sweep - I')

  gxLim = xlim;
  gyLim = ylim; 

  text(gxLim(2),gyLim(2),gFigName,'HorizontalAlignment','right','VerticalAlignment','top')
  %pause(0.1)
end


% Stop and close PulseBlaster
calllib('spinapi','pb_stop');
calllib('spinapi','pb_close')


global Pi_pulse_length;
HF = 1;
data(HF).field = field;
data(HF).signal = signal;
save data;

%Disconnect from ER032M
% fclose(ER032M);
% delete(ER032M);

data(HF).field = field;
data(HF).signalI = signalI;
data(HF).signalQ = signalQ;
data(HF).signal = signal;
data(HF).parameters = parameters;
data(HF).integrationwidth = int_w;
data(HF).Pi_pulse_length = Pi_pulse_length;
saveData(magnitudePlot,'MMF_Field_Sweep_Magnitude',0);
saveData(IQPlot,'MMF_Field_Sweep_IQ',0);
saveData(gPlot,'MMF_Field_Sweep_gFactor');
disp('Done!');

