clc; clear all;
% close all
% instrreset
%% Options
Field_Sweep = 1; % Set 1 to do field sweep;
Check_Integral = 1; % Set to 1 to check the integral limits at a given field.
npulse = 1;

%%

 

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

% Agilent_Voltmeter_initialize;
% T_start = query(CernoxVoltmeter, 'MEAS:VOLT:DC?');
% fclose(CernoxVoltmeter);
% delete(CernoxVoltmeter);


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

B0_start = parameters.B0_start;%mw_freq/2.8025 * 2.0023/g_factor + field_error - B0_span/2;

% B0_start = 8802-5%4325.5; %B0_start - 75; %4400;%2665;%2880
B0_center = round(B0_start*20)/20.0;
B0_sweep_width = 0.1; % Keep it low for better precision
nB0 = round(B0_span/B0_step);
B0_wait = parameters.B0_wait;%.1;
dB0 = B0_step; % B0 step in gauss



Field_Controller_initialize;
Field_write(B0_start);
%% Alazar Parameters

averages = parameters.averages;%10; % should be much less than h to take into account delay in arming Alazar.
acq_time = parameters.acq_time;%15e-6; % in seconds 15
nrepeat = parameters.nrepeat;%1;

pre_trig = 0; %4098; % number of samples to keep before trigger. default zero to avoid trigger pulsing during echo.
post_trig = round(acq_time / (4e-9)); % number of samples to keep after trigger.





%% Main loop
for iB0 = (1:nB0);
%   tau = tau0 + (iB0-1)*dtau;
  tau = tau0;
  itau = 1;
  %%% SET FIELD %%%
 
  B0 = B0_start + iB0*dB0;
  B0_center = round(B0*20)/20.0;
  Field_write(B0);


  
    
  start_program; % Begin pulse program
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
      delay(10*ms)
      h_loop = start_loop(h); % Start of shot loop
      delay(10*MIL);       % Initial instruction should be longer than 2*MIL
%      Wait_for_Trigger;  % (WAIT can not be the 1st instruction) 
%      ZTO_Trigger;

      LED_Trigger;
      delay(d9);  % Delay to accomodate LED pulse (or prep E-pulse)
      
      pulse;               % pi/2 pulse1
      delay(tau-d_a1-Alazar_TriggerLength);     % tau
     Alazar_Trigger;
  for pulseloop = 1:npulse;
      pulse;               % inversion pi pulse    
      delay(2*tau-d_11);  % tau + d0 delay
  end

     
    end_loop(h_loop,srt); % End of shot loop
  
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
  stop_program; % End of program 
  
  
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
% %   PulseBlaster_run_wait_to_finish;
% %   chAintegrated = zeros(post_trig-pre_trig,1);
% %   chBintegrated = zeros(post_trig-pre_trig,1);
% %   chA = zeros(post_trig-pre_trig,1);
% %   chB = zeros(post_trig-pre_trig,1);
% %   for repeatAvg = 1:nrepeat;
% %     [chA,chB,result] = acquireData(boardHandle, pre_trig, post_trig, averages);
% %     
% %     chAintegrated = chAintegrated + chA;
% %     chBintegrated = chBintegrated + chB;
% %   end
  calllib('spinapi','pb_reset');  % Reset the program to the 1st instruction  
    
  disp([int2str(iB0) ' of ' int2str(nB0)]);
  

x_time = linspace(0,acq_time,(post_trig - pre_trig)); % do not comment this line out if rephasing and integrating data.

%%  This is to check the integral window. 
% % % figure;
% % % plot(x_time,chA,'r',x_time,chB,'b');


%% Rephase and Integrate Data
clear Y1;

chA = chAintegrated;
chB = chBintegrated;
Y1 = chA' + 1i*chB';
        
    for nEchoes = 1:npulse;
    
        windowshift = (nEchoes-1)*2*tau*1e-9;
        
        int_w = 2000e-9; %
        int_c = 1.186e-5 + windowshift;
        b_offset = 2e-6;

        b_1 = int_c - b_offset - int_w/4; % time in s after trigger to start baseline correct
        b_2 = int_c - b_offset + int_w/4; % time in s after trigger to stop baseline correct
        b_3 = int_c + b_offset - int_w/4; % time in s after trigger to start baseline correct
        b_4 = int_c + b_offset + int_w/4; % time in s after trigger to stop baseline correct
        
        e_1 = int_c - int_w/2; %1.3e-6; % time in s after trigger to start echo integral;
        e_2 = int_c + int_w/2; %2.3e-6; % time in s after trigger to end echo intergral;

    
    
    
% 
%     b_1 = 1.18e-6; % time in s after trigger to start baseline correct
%     b_2 = 1.2e-6; % time in s after trigger to stop baseline correct
%     b_3 = 3.5e-6; % time in s after trigger to start baseline correct
%     b_4 = 5.0e-6; % time in s after trigger to stop baseline correct
%     
%     e_1 = 1.21e-6; % time in s after trigger to start echo integral;
%     e_2 = 2.25e-6; %


% %     figure(3);
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
        ws = round(windowshift*(post_trig - pre_trig)/acq_time);
    
         m = [bl1 bl2 bl3 bl4]; %define markers
%     Plot the baseline markers
%     for i = 1:1:4
%       i1 = m(i);
%       line([x_time(i1) x_time(i1)],[-1 1]*max(chA)*1.25 + real(Y1(i1)),'Color','red');
%     end;

    % Linear baseline and plot it
%         x = [x_time(m(1):m(2)) x_time(m(3):m(4))]';
%         yR = real([Y1(m(1):m(2)) Y1(m(3):m(4))])'; % real
%         yI = imag([Y1(m(1):m(2)) Y1(m(3):m(4))])'; % imaginary
%         qfitR = fit(x,yR,'poly1');
%         qfitI = fit(x,yI,'poly1');
%         xb = x_time(m(1):m(4));
%         yb = (qfitR.p1+1i*qfitI.p1)*xb + (qfitR.p2+1i*qfitI.p2);
%     hold on;
%     plot(xb,real(yb),'green',xb,imag(yb),'black');
%     hold off;
%     Y2n = 0;
    % Data after baseline correction
%          Y2 = Y1(m(1):m(4)) - yb;
%     Y3 = sqrt(real(Y2).^2 + imag(Y2).^2);
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

    field(iB0) = B0;

    signalI(iB0,nEchoes) = sum(real(Y1(int1:int2))) - sum(real(Y1(bl1:bl2))+real(Y1(bl3:bl4)));
    signalQ(iB0,nEchoes) = sum(imag(Y1(int1:int2))) - sum(imag(Y1(bl1:bl2))+imag(Y1(bl3:bl4)));
    signal(iB0,nEchoes) = sqrt(signalI(iB0,nEchoes).^2 + signalQ(iB0,nEchoes).^2);
    

    
   
    end
    
    pause(0.1)
    figure(2);
    plot(x_time(bl1-ws:bl4-ws),real(Y1(bl1-ws:bl4-ws)),'green',x_time(bl1-ws:bl4-ws),imag(Y1(bl1-ws:bl4-ws)),'blue')
        for i = 1:1:4
          i1 = m(i);
          line([x_time(i1-ws) x_time(i1-ws)],[-1 1]*max(abs(chA(m(2)-ws:m(3)-ws))+abs(chB(m(2)-ws:m(3)-ws))),'Color','red');
        end;
          line([x_time(int1-ws) x_time(int1-ws)],[-1 1]*max(abs(chA(m(2)-ws:m(3)-ws))+abs(chB(m(2)-ws:m(3)-ws))),'Color','black');
          line([x_time(int2-ws) x_time(int2-ws)],[-1 1]*max(abs(chA(m(2)-ws:m(3)-ws))+abs(chB(m(2)-ws:m(3)-ws))),'Color','black');
    xlabel('Time (s)')
    ylabel('ESR Signal')
    title('Integration Limits (I = green, Q = blue)')
    
    signalItot = sum(signalI,2);
    signalQtot = sum(signalQ,2);
    signaltot = sum(signal,2);

    figure(1);
    plot(field,signaltot,'red');
    xlabel('B0 (gauss)')
    ylabel('Signal Intensity')
    title('Field Sweep - Magnitude')
    pause(0.1)
    
    figure(3);
    plot(714.477./field.*parameters.mw_freq/1000,signalItot,'green',714.477./field.*parameters.mw_freq/1000,signalQtot,'blue');
    xlabel('g')
    ylabel('Signal Intensity')
    title('Field Sweep - I')
end
%%
% Stop and close PulseBlaster
calllib('spinapi','pb_stop');
calllib('spinapi','pb_close')
%%

data.field = field;
data.signal = signaltot;
save data;
% optionally plot data
x_time = linspace(0,acq_time,(post_trig - pre_trig));
% figure;
% plot(x_time,chA,'r',x_time,chB,'b');
% Disconnect from ER032M
fclose(ER032M);
delete(ER032M);

Agilent_Voltmeter_initialize;
T_stop = query(CernoxVoltmeter, 'MEAS:VOLT:DC?');
fclose(CernoxVoltmeter);
delete(CernoxVoltmeter);

data.field = field;
data.signalI = signalItot;
data.signalQ = signalQtot;
data.signal = signaltot;
data.comments = ['As doped natural Ge, 30 degree rotation, no strain, 1.8K, tau = ' num2str(tau0/1000) ' us, frequency = ' num2str(mw_freq) 'MHz, averages = ' num2str(averages * nrepeat) ', d9 = ' num2str(d9/1000) ' us, power = ' num2str(mw_power) ' dBm + nominally 50dBm from TWT'];
data.parameters = parameters;
data.T_start = T_start;
data.T_stop = T_stop;
data.integrationwidth = int_w;

disp('Done!');
