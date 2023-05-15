clc; clear all;
% close all
% instrreset
global TRIG_Stark;
%% Options
Field_Sweep = 0; % Set 1 to do field sweep;
Check_Integral = 1; % Set to 1 to check the integral limits at a given field.

%%
for hf = 1:1
% clf(1);
% clf(2);
% clf(3);

if libisloaded('spinapi') == 0
    loadlibrary('C:\SpinCore\SpinAPI\dll\spinapi.dll','C:\SpinCore\SpinAPI\dll\spinapi.h');
end;

calllib('spinapi','pb_stop');
calllib('spinapi','pb_close');

agilent_needs_to_be_reloaded = 0;



%% Get Parameters
get_parameters;

if hf ==1;
%     parameters.B0_start = 4460;
end

if hf ==2;
    parameters.B0_start = 4358.1;
end

if hf ==3;
    parameters.B0_start = 4392.1;
end

if hf ==4;
    parameters.B0_start = 4428.1;
end
%% AGILENT PRELOADING

% Global variables
Agilent_globals();

% Connect to Agilent
agt_connect_and_initialize;

power_start = parameters.power_start;
power_stop = parameters.power_stop;
power_step = parameters.power_step;

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Microwave frequency and output power
mw_freq = parameters.mw_freq; %8417.5; % in MHz
mw_power = parameters.power_start;
agt_sendcommand(io, ['SOURce:FREQuency ' int2str(round(mw_freq*1e6))]);
agt_sendcommand(io, ['POWer ' num2str(mw_power)]);   

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
retCode = calllib('ATSApi', 'AlazarAbortCapture', boardHandle);
%% PULSEBLASTER CONTROL

PulseBlaster_definitions; % definitions from SpinCore
PulseBlaster_globals;
PulseBlaster_connect_and_initialize;

% ++++++++++++++++++++++++++++++++++++++++++++++++++
Alazar_Delay = parameters.Alazar_Delay;%3000; % d0 delay [in ns] Trigger Delay

tau0 = parameters.tau0; % initial tau [in ns]  
% dtau = parameters.dtau; %100*ns; % tau step [in ns]
ntau = parameters.ntau; %800; % # of time steps
h = parameters.h; %10000;  % # of shots

srt = parameters.srt; %2.0*ms; % short repetition time
            % (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
d9 = parameters.d9;%4*ms;  % delay to accomodate an LED pulse 
% +++++++++++++++++++++++++++++++++++++++++++++++++++

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



%Field_Controller_initialize;
%Field_write(B0_start);
%% Alazar Parameters

averages = parameters.averages;%500; % should be much less than h to take into account delay in arming Alazar.
acq_time = parameters.acq_time; %10e-6; % in seconds
nrepeat = parameters.nrepeat; %1;
nscan = parameters.nscan;

pre_trig = 0; %4098; % number of samples to keep before trigger. default zero to avoid trigger pulsing during echo.
post_trig = round(acq_time / (4e-9)); % number of samples to keep after trigger.

tau = tau0;% + (iB0-1)*dtau;   

 start_program; % Begin pulse program
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
%       delay(200*ms)
%     
%       h_loop = start_loop(h); % Start of shot loop
%       delay(10*MIL);       % Initial instruction should be longer than 2*MIL
% %      Wait_for_Trigger;  % (WAIT can not be the 1st instruction) 
% %      ZTO_Trigger;
%       calllib('spinapi','pb_inst_pbonly',TRIG_Stark,CONTINUE,0,d9);
%       LED_Trigger;
%       delay(100*ms);  % Delay to accomodate LED pulse (or prep E-pulse)
% 
%       pulse;
%       delay(tau-d_a1);     % tau
%       %Alazar_Trigger; 
%       pulse;               % inversion pi pulse    
%       delay(tau-d_11-Alazar_Delay);  % tau + d0 delay
%       
%      
% % % % %       pulse;               % pi/2 pulse1
% % % % %       
% % % % % %       delay(tau-d_a1);     % tau
% % % % % 
% % % % % %%% Next four lines are for Stark experiment
% % % % %       pre_delay = 3*us;
% % % % %       delay(pre_delay);         % tau
% % % % %       Ep_Trigger;               % E-pulse trigger
% % % % %       delay(tau-d_a1-pre_delay); % tau
% % % % %       
% % % % % 
% % % % %       pulse;               % inversion pi pulse
% % % % %       delay(tau-d_11 + Alazar_Delay);  % tau + d0 delay
     
%       Alazar_Trigger; 
% %     
%     end_loop(h_loop,srt); % End of shot loop
  
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
  stop_program; % End of program 
  
  

npower = round(abs((parameters.power_stop - parameters.power_start)/ parameters.power_step));
dpower = (parameters.power_stop - parameters.power_start)/npower;


%% Main loop
for iB0 = (1:npower);
  
  pwr_current = parameters.power_start + dpower*iB0;
  agt_connect_and_initialize;
  agt_sendcommand(io, ['POWer ' num2str(pwr_current)]); 
  agt_advanced_trigger_mode;
  agt_closeAllSessions; % closes connection with Agilent
  
%   tau = tau0;
  itau = 100;
  %%% SET FIELD %%%
%  
%   B0 = B0_start - iB0*dB0
%   B0_center = round(B0*20)/20.0;
%   Field_write(B0);

for nscan = (1:nscan);
 
  
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
  disp('Waiting 50s');
  pause(50);
  
  
 
  calllib('spinapi','pb_reset');  % Reset the program to the 1st instruction  
    
  disp([int2str(iB0) ' of ' int2str(npower)]);
  

x_time = linspace(0,acq_time,(post_trig - pre_trig)); % do not comment this line out if rephasing and integrating data.

%%  This is to check the integral window. 
% % % figure;
% % % plot(x_time,chA,'r',x_time,chB,'b');


%% Rephase and Integrate 5Data
    clear Y1;
    chA = chAintegrated/nrepeat/averages;
    chB = chBintegrated/nrepeat/averages;
    Y1 = chA' + 1i*chB';
%     Ymag = sqrt(chA'.^2 + chB'.^2);
%     Y1 = Ymag;
%RECTANGULAR VALUES
%   
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

pwrplot(iB0,nscan) = pwr_current;
signalI(iB0,nscan) = sum(real(Y2(int1-bl1:int2-bl1)));
signalQ(iB0,nscan) = sum(imag(Y2(int1-bl1:int2-bl1)));
signalM(iB0,nscan) = sum(abs(Y2(int1-bl1:int2-bl1)));%sqrt(signalI(iB0)^2 + signalQ(iB0)^2);
% signal(iB0) = sum(abs(Y2(int1-bl1:int2-bl1)));

figure(1);
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

end

pwrplotavg(iB0) = pwr_current;
signalIavg(iB0) = sum(signalI(iB0,:));
signalQavg(iB0) = sum(signalQ(iB0,:));
signalMavg(iB0) = sum(abs(Y2(int1-bl1:int2-bl1)));%sqrt(signalIavg(iB0)^2 + signalQavg(iB0)^2);


magnitudePlot = figure(2);
plot(pwrplot,signalMavg,'red');
magFigName = genFigName('MMF\_Rabi\_Magnitude');
xlabel('power (dBm)')
ylabel('Signal Intensity (magnitude)')
title('Rabi Experiment')
magxLim = xlim;
magyLim = ylim; 

text(magxLim(2),magyLim(2),magFigName,'HorizontalAlignment','right','VerticalAlignment','top')
pause(0.1)

IQPlot = figure(3);
plot(pwrplot,signalIavg,'green',pwrplot,signalQavg,'blue');
IQFigName = genFigName('MMF\_Rabi\_IQ');
IQxLim = xlim;
IQyLim = ylim;
text(IQxLim(2),IQyLim(2),IQFigName,'HorizontalAlignment','right','VerticalAlignment','top')
xlabel('power (dBm)')
ylabel('Signal Intensity (I and Q)')
title('Rabi Experiment')
pause(0.1)
end
%%
% Stop and close PulseBlaster
calllib('spinapi','pb_stop');
calllib('spinapi','pb_close')

%% Save Data

% Agilent_Voltmeter_initialize;
% T_stop = query(CernoxVoltmeter, 'MEAS:VOLT:DC?');
% fclose(CernoxVoltmeter);
% delete(CernoxVoltmeter);

% data(hf).power = pwrplot;
% data(hf).signalI = signalI;
% data(hf).signalQ = signalQ;
% data(hf).signalM = signalM;
% data(hf).signalIavg = signalIavg;
% data(hf).signalQavg = signalQavg;
% data(hf).signalMavg = signalMavg;
% data(hf).comments = ['P donors in DIL Fridge, tau = swept, pi pulse - pi pulse ID extraction' ' us, frequency = ' num2str(mw_freq) 'MHz, averages = ' num2str(averages * nrepeat) ', d9 = ' num2str(d9/1000) ' us, power = ' num2str(mw_power) ' dBm, note tau is interpulse delay, not 2*tau, resonator Q overcoupled to ~2000.'];
% data(hf).field = B0_start;
% data(hf).power = mw_power;
% data(hf).T_start = str2double(T_start);
% data(hf).T_stop = str2double(T_stop);
% data(hf).parameters = parameters;

% % optionally plot data
% x_time = linspace(0,acq_time,(post_trig - pre_trig));
% figure;
% plot(x_time,chA,'r',x_time,chB,'b');
% Disconnect from ER032M
% fclose(ER032M);
% delete(ER032M);


disp('Done!');

saveData(magnitudePlot,'MMF_Rabi_Magnitude',0);
saveData(IQPlot,'MMF_Rabi_IQ');
end