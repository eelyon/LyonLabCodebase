clc; clear all;
% close all
% instrreset

%% Get Parameters
get_parameters;
tauArr = parameters.tauArr;
hf = 1;
for nTau = 1:length(tauArr)
%% Options
Field_Sweep = 0; % Set 1 to do field sweep;
Check_Integral = 1; % Set to 1 to check the integral limits at a given field.


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
%% set microwave frequency and output power
mw_freq = parameters.mw_freq; %8417.5; % in MHz
mw_power = parameters.mw_power;
agt_sendcommand(io, ['SOURce:FREQuency ' int2str(round(mw_freq*1e6))]);
agt_sendcommand(io, ['POWer ' num2str(mw_power)]);   

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% TWT: power should be set to 2dBm (or less) to avoid saturating the TWT
% AR solid state: power should be set below -10dBm (which is strange! it should be 0dBm according to specs)
% Also change the gate pulse to POS for TWT and NEG for AR

%% Define/load the pulse sequence 
sequenceName = sprintf('2pulse_a2');
sequence = 'a 2'; % pi/2(x) - tau - pi(y) - tau
% a b c d = pi/2 pulse in x, y ... phase
% 1 2 3 4 = pi pulse in x, y, ... phase

% Create and load standard (square and adiabatic pi/2, pi) pulses to Agilent


%% Alazar Parameters

  if(agilent_needs_to_be_reloaded)
    agt_load_standard_pulses(sequence);
    agt_load_pulse_sequence(sequence,sequenceName);
end; 

agt_advanced_trigger_mode;

%% Alazar Configure
boardHandle = configureAlazarforEPR();
%% PULSEBLASTER CONTROL

PulseBlaster_definitions; % definitions from SpinCore
PulseBlaster_globals;
PulseBlaster_connect_and_initialize;

% ++++++++++++++++++++++++++++++++++++++++++++++++++
Alazar_Delay = parameters.Alazar_Delay;%3000; % d0 delay [in ns] Trigger Delay

tau0 = parameters.tau0; % tau [in ns]  
h = parameters.h; %10000;  % # of shots

srt = parameters.srt; %2.0*ms; % shot repetition time
            % (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
d9 = parameters.d9;%4*ms;  % delay to accomodate an LED pulse 
tau = tauArr(nTau)
averages = parameters.averages; % should be much less than h to take into account delay in arming Alazar.
acq_time = parameters.acq_time; % in seconds
nrepeat = parameters.nrepeat; 

pre_trig = 0; % number of samples to keep before trigger. default zero to avoid trigger pulsing during echo.
post_trig = round(acq_time / (4e-9)); % number of samples to keep after trigger.

%tau = tau0;
itau = 1;
start_program; % Begin pulse program
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
      delay(20*ms)
    
      h_loop = start_loop(h); % Start of shot loop
      delay(10*MIL);       % Initial instruction should be longer than 2*MIL
      %LED_Trigger;
      delay(d9);  % Delay to accomodate LED pulse (or prep E-pulse)
      pulse;               % pi/2 pulse1
      delay(tau-d_a1);     % tau
      pulse;               % inversion pi pulse
      delay(tau-d_11-Alazar_Delay);  % tau + d0 delay
      Alazar_Trigger;
      end_loop(h_loop,srt); % End of shot loop
  
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
  stop_program; % End of program 
  
  subFolderName = ['PSD_Shots_' num2str(getCurrentFileNum(getDataPath()))];
%% Main loop
for iB0 = (1:parameters.nshots);
 
  disp('programmed pulseBlaster')
  disp('Waiting 50s for polarization');
  pause(50);
  chAintegrated = zeros(post_trig-pre_trig,1);
  chBintegrated = zeros(post_trig-pre_trig,1);
  
  disp('start averages')
  for repeatAvg = 1:nrepeat;
    disp('start pulsing')
    PulseBlaster_run_wait_to_finish;
    disp('start alazar')
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
  disp([int2str(iB0) ' of ' int2str(parameters.nshots)]);

x_time = linspace(0,acq_time,(post_trig - pre_trig)); % do not comment this line out if rephasing and integrating data.

%% Rephase and Integrate Data
    clear Y1;
    chA = chAintegrated;
    chB = chBintegrated;
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
    Y2 = Y1(m(1):m(4)) - yb;
shotNum(iB0) = iB0;
signalI(iB0) = sum(real(Y2(int1-bl1:int2-bl1)));
signalQ(iB0) = sum(imag(Y2(int1-bl1:int2-bl1)));
signalM(iB0) = sqrt(signalI(iB0)^2 + signalQ(iB0)^2);
% signal(iB0) = sum(abs(Y2(int1-bl1:int2-bl1)));

magFig = figure(1);
magFigName = genFigName('MMF\_PSD\_Mag');
texMag = text(0,1.05,magFigName,'FontSize',8,'Color','k');
plot(shotNum,signalM,'red');
xlabel('Shot Number')
ylabel('Signal Intensity (magnitude)')
title('Magnitude PSD')
magxLim = xlim;
magyLim = ylim; 
text(magxLim(2),magyLim(2),magFigName,'HorizontalAlignment','right','VerticalAlignment','top')

pause(0.1)
rawIQFig = figure(2);
plot(xb,real(Y2),'green',xb,imag(Y2),'blue')
rawIQFigName = genFigName(['MMF\_PSD\_shotNum\_' num2str(iB0)]);
IQxLim = xlim;
IQyLim = ylim;
text(IQxLim(2),IQyLim(2),rawIQFigName,'HorizontalAlignment','right','VerticalAlignment','top')
rawSaveName = ['MMF_PSD_shotNum_' num2str(iB0)];
saveDataSubFolder(rawIQFig,rawSaveName,subFolderName);
    for i = 1:1:4
      i1 = m(i);
      line([x_time(i1) x_time(i1)],[-1 1]*max(chA(m(1):m(4)))*1.25 + real(Y1(i1)),'Color','red');
    end;
      line([x_time(int1) x_time(int1)],[-1 1]*max(chA(m(1):m(4)))*1.25 + real(Y1(int1)),'Color','black');
      line([x_time(int2) x_time(int2)],[-1 1]*max(chA(m(1):m(4)))*1.25 + real(Y1(int2)),'Color','black');
xlabel('Time (s)')
ylabel('ESR Signal')
title('Integration Limits (I = green, Q = blue)')  
pause(0.1)
IQFig = figure(3);
IQFigName = genFigName('MMF\_PSD\_IQ\_Sum');
plot(shotNum,signalI,'green',shotNum,signalQ,'blue');
xlabel('Shot Number')
ylabel('Signal Intensity (I and Q)')
title('IQ Sum PSD')
IQxLim = xlim;
IQyLim = ylim;
text(IQxLim(2),IQyLim(2),IQFigName,'HorizontalAlignment','right','VerticalAlignment','top')

pause(0.1)
end
%%
% Stop and close PulseBlaster
calllib('spinapi','pb_stop');
calllib('spinapi','pb_close')

%% Save Data

data(nTau).signalI = signalI;
data(nTau).signalQ = signalQ;
data(nTau).signalM = signalM;
data(nTau).comments = ['Enter comments here:' 'frequency = ' num2str(mw_freq) 'MHz, averages = ' num2str(averages * nrepeat) ', d9 = ' num2str(d9/1000) ' us, tau = ' num2str(parameters.tau0) ', power = ' num2str(mw_power) ' dBm + nominally 50dBm from TWT, note tau is interpulse delay, not 2*tau.'];
data(nTau).power = mw_power;
data(nTau).parameters = parameters;
IQFig.UserData = data;
saveData(magFig,'MMF_PSD_Magnitude',0);
saveData(IQFig,'MMF_PSD_IQ');
end

disp('Done!');


