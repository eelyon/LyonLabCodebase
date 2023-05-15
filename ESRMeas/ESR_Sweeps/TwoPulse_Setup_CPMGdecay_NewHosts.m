clc; clear all;

global TRIG_Stark; % Start channel is used for custom laser shutter. The instruction length will determine the shutter open duration.
% close all
% instrreset

exptname = '\01_T2_decay'; % folder name for the experiment.
Expt = '_2000ms_405nm_WAR5_site1_2474p75G_CPMGn256';
savedata = 1;
%% Options
Field_Sweep = 0; % Set 1 to do field sweep;
Check_Integral = 1; % Set to 1 to check the integral limits at a given field.

%%
% clf(1);
% clf(2);
% clf(3);

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

%% Get Parameters
get_parameters;
% uncomment to do multiple hyperfine lines
% if hf ==1;
%      parameters.B0_start = 4349.7;
% end
%
% if hf ==2;
%     parameters.B0_start = 4385.2;
% end
%
% if hf ==3;
%     parameters.B0_start = 4420.7;
% end
%
% if hf ==4;
%     parameters.B0_start = 4456.7;
% end
% uncomment to do multiple hyperfine lines
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
sequence = 'a '; % pi/2(x) - tau - pi(y) - tau

npulse = parameters.npulse;

for sequenceloop = 1:npulse;
    sequence = [sequence, '2 '];
end
% Create and load standard (square and adiabatic pi/2, pi) pulses to Agilent
if(agilent_needs_to_be_reloaded)
  agt_load_standard_pulses(sequence);
  agt_load_pulse_sequence(sequence,sequenceName);
end;

agt_advanced_trigger_mode;
%% Cernox measurement
%


% Agilent_Voltmeter_initialize;
% T_start = query(CernoxVoltmeter, 'MEAS:VOLT:DC?');
% fclose(CernoxVoltmeter);
% delete(CernoxVoltmeter);


%% Alazar Configure
boardHandle = configureAlazarforEPR();
%% PULSEBLASTER CONTROL

PulseBlaster_definitions; % definitions from SpinCore
PulseBlaster_globals;
PulseBlaster_connect_and_initialize;

% ++++++++++++++++++++++++++++++++++++++++++++++++++
Alazar_Delay = parameters.Alazar_Delay;%3000; % d0 delay [in ns] Trigger Delay

tau0 = parameters.tau0; % initial tau [in ns]
dtau = parameters.dtau; %100*ns; % tau step [in ns]
ntau = parameters.ntau; %800; % # of time steps
h = parameters.h; %10000;  % # of shots

srt = parameters.srt; %2.0*ms; % shot repetition time
% (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
d9 = parameters.d9;%4*ms;  % delay to accomodate an LED pulse


%% Field Controller
global B0_center B0_sweep_width nB0 B0_wait;

% +++++++++++++++++++++++++++++++++++++++++++++++++++
% g_factor = 2.0003; % E' centers in quartz
% aiso = 0;
g_factor = parameters.g_factor;%1.57% As donors in Ge
% aiso = 42;
field_error = parameters.field_error; %-2.67;%-2.6%61%5%4%6; %2.3 between -3.9 and -4.35 Gauss -2.5
% +++++++++++++++++++++++++++++++++++++++++++++++++++

% B0_start = mw_freq/2.8025 * 2.0023/g_factor - aiso/2 + field_error;
B0_start = parameters.B0_start;%4300;%2880
B0_center = round(B0_start*20)/20.0;
B0_sweep_width = 0.1; % Keep it low for better precision
% nB0 = 200;
B0_wait = parameters.B0_wait;%.1;
dB0 = parameters.dB0; %-.3; % B0 step in gauss

%
%
Field_Controller_initialize;
Field_write(B0_start);
%% Alazar Parameters

averages = parameters.averages;%500; % should be much less than h to take into account delay in arming Alazar.
acq_time = parameters.acq_time; %10e-6; % in seconds
nrepeat = parameters.nrepeat; %1;

pre_trig = 0; %4098; % number of samples to keep before trigger. default zero to avoid trigger pulsing during echo.
post_trig = round(acq_time / (4e-9)); % number of samples to keep after trigger.

%% Main loop
for iB0 = (1:ntau);
  tau = tau0 + (iB0-1)*dtau;
  %   tau = tau0;
  itau = 100;
  %%% SET FIELD %%%
  %
  %   B0 = B0_start - iB0*dB0
  %   B0_center = round(B0*20)/20.0;
  %   Field_write(B0);
  
  start_program; % Begin pulse program
  % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  delay(20*ms)
  
  h_loop = start_loop(h); % Start of shot loop
  delay(10*MIL);       % Initial instruction should be longer than 2*MIL
  %      Wait_for_Trigger;  % (WAIT can not be the 1st instruction)
  %ZTO_Trigger;
  
  %LED_Trigger;
  calllib('spinapi','pb_inst_pbonly',TRIG_Stark,CONTINUE,0,d9);
  %delay(d9);  % Delay to accomodate LED pulse (or prep E-pulse)
  delay(30*ms);
  %       Alazar_Trigger;
  pulse;               % pi/2 pulse1
  delay(tau-d_a1);     % tau
  if npulse >=2;
    for pulseloop = 1:(npulse-1);
      pulse;               % inversion pi pulse
      delay(2*tau-d_11);  % tau + d0 delay
    end
  end
  %       Alazar_Trigger;
   pulse;               % inversion pi pulse
   delay(tau-d_11-Alazar_Delay);  % tau + d0 delay
  
  
  % % % %       pulse;               % pi/2 pulse1
  % % % %
  % % % % %       delay(tau-d_a1);     % tau
  % % % %
  % % % % %%% Next four lines are for Stark experiment
  % % % %       pre_delay = 3*us;
  % % % %       delay(pre_delay);         % tau
  % % % %       Ep_Trigger;               % E-pulse trigger
  % % % %       delay(tau-d_a1-pre_delay); % tau
  % % % %
  % % % %
  % % % %       pulse;               % inversion pi pulse
  % % % %       delay(tau-d_11 + Alazar_Delay);  % tau + d0 delay
  
  Alazar_Trigger;
  %
  end_loop(h_loop,srt); % End of shot loop
  
  % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  stop_program; % End of program
  
  
  
  disp('programmed pulseBlaster')
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
  
  disp([int2str(iB0) ' of ' int2str(ntau)]);
  
  
  x_time = linspace(0,acq_time,(post_trig - pre_trig)); % do not comment this line out if rephasing and integrating data.
  
  %%  This is to check the integral window.
  % % % figure;
  % % % plot(x_time,chA,'r',x_time,chB,'b');
  
  
  %% Rephase and Integrate Data
  clear Y1;
  chA = chAintegrated;
  chB = chBintegrated;
  Y1 = chA' + 1i*chB';
  %     Ymag = sqrt(chA'.^2 + chB'.^2);
  %     Y1 = Ymag;
  b_1 = parameters.b_1; %4.5e-6; % time in s after trigger to start baseline correct
  b_2 = parameters.b_2; %5.0e-6; % time in s after trigger to stop baseline correct
  b_3 = parameters.b_3;%7.0e-6; % time in s after trigger to start baseline correct
  b_4 = parameters.b_4; % time in s after trigger to stop baseline correct
  int_w = parameters.int_w;%600e-9; % integral width/2
  int_c = parameters.int_c;%6.00e-6; % integral center
  e_1 = int_c - int_w/2; %1.3e-6; % time in s after trigger to start echo integral;
  e_2 = int_c + int_w/2; %2.3e-6; % time in s after trigger to end echo intergral;
  % %
  %     b_1 = 3.9e-6; % time in s after trigger to start baseline correct
  %     b_2 = 4.0e-6; % time in s after trigger to stop baseline correct
  %     b_3 = 7.5e-6; % time in s after trigger to start baseline correct
  %     b_4 = 9.0e-6; % time in s after trigger to stop baseline correct
  %
  %     e_1 = 4.2e-6; % time in s after trigger to start echo integral;
  %     e_2 = 6.0e-6; % time in s after trigger to end echo intergral;
  % % %     figure(3);
  % %     plot(x_time,real(Y1),'g',x_time,imag(Y1),'y');
  % %     xlabel('Time (us)');
  % %     ylabel('Echo Signal (V)');
  % %     title(sprintf('Echo signal: I (blue) and Q (red), and linear baseline (pink)'));
  
  % Define indexes (markers) for baseline correction
  bl1 = round(b_1*(post_trig - pre_trig)/acq_time);
  bl2 = round(b_2*(post_trig - pre_trig)/acq_time);
  bl3 = round(b_3*(post_trig - pre_trig)/acq_time);
  bl4 = round(b_4*(post_trig - pre_trig)/acq_time);
  int1 = round(e_1*(post_trig - pre_trig)/acq_time);
  int2 = round(e_2*(post_trig - pre_trig)/acq_time);
  
  m = [bl1 bl2 bl3 bl4]; %define markers
  %     Plot the baseline markers
  %     for i = 1:1:4
  %       i1 = m(i);
  %       line([x_time(i1) x_time(i1)],[-1 1]*max(chA)*1.25 + real(Y1(i1)),'Color','red');
  %     end;
  
  % Linear baseline and plot it
  x = [x_time(m(1):m(2)) x_time(m(3):m(4))]';
  yR = real([Y1(m(1):m(2)) Y1(m(3):m(4))])'; % real
  yI = imag([Y1(m(1):m(2)) Y1(m(3):m(4))])'; % imaginary
  qfitR = fit(x,yR,'poly1');
  qfitI = fit(x,yI,'poly1');
  xb = x_time(m(1):m(4));
  yb = (qfitR.p1+1i*qfitI.p1)*xb + (qfitR.p2+1i*qfitI.p2);
  %     hold on;
  %     plot(xb,real(yb),'green',xb,imag(yb),'black');
  %     hold off;
  %     Y2n = 0;
  % Data after baseline correction
  Y2 = Y1(m(1):m(4)) - yb;
  %     Y3 = sqrt(abs(real(Y2).^2) + abs(imag(Y2).^2));
  %     Y2 = Y3;
  
  %     window = sum(Y2(bl2-bl1:bl3-bl1));
  %
  %     Ntheta = 1000;
  %     for itheta = 1:Ntheta;
  %
  %         theta = (itheta-1) * 2*pi/Ntheta;
  %         Y3 = Y2 .* exp(-1i*theta);
  %
  %         Integ(itheta) = sum(real(Y3));
  %         ang(itheta) = theta;
  %     end;
  
  %     [minimum_value,indx] = max(Integ);
  %     angle = ang(indx) * 360 / (2*pi);
  
  tauplot(iB0) = tau;
  signalI(iB0) = sum(real(Y2(int1-bl1:int2-bl1)));
  signalQ(iB0) = sum(imag(Y2(int1-bl1:int2-bl1)));
  signalM(iB0) = sqrt(signalI(iB0)^2 + signalQ(iB0)^2);
  % signal(iB0) = sum(abs(Y2(int1-bl1:int2-bl1)));
  figure(1);
  plot(tauplot./500*npulse,signalM,'red');
  xlabel('2*tau (us)*npulse')
  ylabel('Signal Intensity (magnitude)')
  title('T2 decay')
  pause(0.1)
  figure(2);
  plot(xb,real(Y2),'green',xb,imag(Y2),'blue')
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
  figure(3)
  plot(tauplot./500*npulse,signalI,'green',tauplot./500*npulse,signalQ,'blue');
  xlabel('2*tau (us)*npulse')
  ylabel('Signal Intensity (I and Q)')
  title('T2 decay')
  pause(0.1)
end
%%
% Stop and close PulseBlaster
calllib('spinapi','pb_stop');
calllib('spinapi','pb_close')

%% Save data and script
if savedata == 1
  data.tau = tauplot;
  data.npulse = npulse;
  data.signalI = signalI;
  data.signalQ = signalQ;
  data.signalM = signalM;
  data.comments = ['Enter comments here:' 'frequency = ' num2str(mw_freq) 'MHz, averages = ' num2str(averages * nrepeat) ', d9 = ' num2str(d9/1000) ' us, power = ' num2str(mw_power) ' dBm + nominally 50dBm from TWT, note tau is interpulse delay, not 2*tau, resonator Q overcoupled to ~2000.'];
  data.field = B0_start;
  data.power = mw_power;
  % data(hf).T_start = str2double(T_start);
  % data(hf).T_stop = str2double(T_stop);
  data.parameters = parameters;
  CurrDate = datestr(now,'yyyy-mm-dd');
  CurrTime = datestr(now,'HH-MM-SS');
  datefolder = strcat('\\quantumstorage.ee.princeton.edu\home\newHosts\ESR_pulsed\Daily\2021\',CurrDate);
  scriptfolder = strcat('\\quantumstorage.ee.princeton.edu\home\newHosts\ESR_pulsed\Dailyscripts\',CurrDate);
  if ~exist(datefolder,'dir')
    mkdir(datefolder);
  end
  
  savefolder = strcat(datefolder,exptname);
  if ~exist(savefolder,'dir')
    mkdir(savefolder);
  end
  
  savefoldersript = strcat(scriptfolder,exptname);
  if ~exist(savefoldersript,'dir')
    mkdir(savefoldersript);
  end
  
  numfile = size(dir(strcat(savefolder,'\*.mat')),1);
  save(strcat(savefolder,'\',num2str(numfile + 1),exptname(4:end),Expt,'.mat'),'-struct','data');
  
  FileNameAndLocation = mfilename('fullpath');
  currentfile = strcat(FileNameAndLocation,'.m');
  FileName = strsplit(FileNameAndLocation,'\');
  FileName = FileName{end};
  backupfile = strcat(savefoldersript,'\',FileName,'_',CurrTime,'.m');
  copyfile(currentfile,backupfile);
end
%%


% Disconnect from ER032M
fclose(ER032M);
delete(ER032M);


disp('Done!');
