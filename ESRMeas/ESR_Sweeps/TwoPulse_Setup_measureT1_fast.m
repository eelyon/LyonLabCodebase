clc; clear all;
% close all
% instrreset
%% Options

%%
for hf = 1:1;


if libisloaded('spinapi') == 0
    loadlibrary('C:\SpinCore\SpinAPI\dll\spinapi.dll','C:\SpinCore\SpinAPI\dll\spinapi.h');
end;

calllib('spinapi','pb_stop');
calllib('spinapi','pb_close');

agilent_needs_to_be_reloaded = 1;
%% Get preloaded experiment parameters

get_parameters;

% if hf ==1;
% %     parameters.B0_start = 4349.7;
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
pause(4);

%% AGILENT PRELOADING
% Global variables
Agilent_globals();

% Connect to Agilent
agt_connect_and_initialize;
% agt_load_pulse_sequence(sequence,sequenceName);
% agt_advanced_trigger_mode_for_phase_cycle;
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Microwave frequency and output power
mw_freq = parameters.mw_freq;%9634.080; %8417.5; % in MHz
mw_power = parameters.mw_power;%1;
agt_sendcommand(io, ['SOURce:FREQuency ' int2str(round(mw_freq*1e6))]);
agt_sendcommand(io, ['POWer ' num2str(mw_power)]);   

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% TWT: power should be set to 2dBm (or less) to avoid saturating the TWT
% AR solid state: power should be set below -10dBm (which is strange! it should be 0dBm according to specs)
% Also change the gate pulse to POS for TWT and NEG for AR

% Define/load the pulse sequence 
sequenceName = sprintf('2pulse_a2');
sequence = '2 a 2'; % pi/2(x) - tau - pi(y) - tau

% Create and load standard (square and adiabatic pi/2, pi) pulses to Agilent
if(agilent_needs_to_be_reloaded)
    agt_load_standard_pulses('a b c d 1 2 3 4');
    agt_load_pulse_sequence(sequence,sequenceName);
end; 

agt_advanced_trigger_mode_for_phase_cycle;


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
retCode = calllib('ATSApi', 'AlazarAbortAsyncRead', boardHandle);
%% Alazar Parameters

averages = parameters.averages; % Should be less than 1000 to avoid buffer problems on Alazar.
acq_time = parameters.acq_time;%10e-6; % in seconds
nrepeat = parameters.nrepeat;

pre_trig = 0; %4098; % number of samples to keep before trigger. default zero to avoid trigger pulsing during echo.
post_trig = round(acq_time / (4e-9)); % number of samples to keep after trigger.

%% PULSEBLASTER CONTROL

PulseBlaster_definitions; % definitions from SpinCore
PulseBlaster_globals;
PulseBlaster_connect_and_initialize;

% ++++++++++++++++++++++++++++++++++++++++++++++++++
Alazar_Delay = parameters.Alazar_Delay;%000;%2000; % d0 delay [in ns] Trigger Delay

T0 = parameters.T0;%18*us; % initial tau between first pi pulse and pi/2 [in ns]  
dT = parameters.dT;%2000*ns; % tau step [in ns]
nT = parameters.nT;%300; % # of time steps
tauConstant = parameters.tauConstant;%8*us; % tau between pi/2 and pi pulse
srt = parameters.srt;%1.25*ms; % shot repetition time            % (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
d9 = parameters.d9;%10*ms;  % delay to accomodate an LED pulse 
h = parameters.h;%round(200*ms/d9+averages);  % # of shots. should be larger than averages by enough to keep alazar from timing out.
% +++++++++++++++++++++++++++++++++++++++++++++++++++

%% Field Controller
global B0_center B0_sweep_width nB0 B0_wait;

% +++++++++++++++++++++++++++++++++++++++++++++++++++
% g_factor = 2.0003; % E' centers in quartz
% aiso = 0;
g_factor = parameters.g_factor;%1.57;% As donors in Ge
% aiso = 42; 
field_error = parameters.field_error;%-2.6%61%5%4%6; %2.3 between -3.9 and -4.35 Gauss -2.5
% +++++++++++++++++++++++++++++++++++++++++++++++++++

% B0_start = mw_freq/2.8025 * 2.0023/g_factor - aiso/2 + field_error;
B0_start = parameters.B0_start;%4325.4;%2880
B0_center = round(B0_start*20)/20.0;
B0_sweep_width = 0.1; % Keep it low for better precision
% nB0 = 200;
B0_wait = parameters.B0_wait;%.1;
dB0 = parameters.dB0;%-.3; % B0 step in gauss



Field_Controller_initialize;
Field_write(B0_start);


%% Main loop
phasecycle = 1;
 for phasecycle = 1:1;%%%% %%%% changed from 2 to 1
        
        % Program Agilent for current phase cycle
        if phasecycle == 1;
            agt_connect_and_initialize;
            agt_load_pulse_sequence('2 a 2','Phase_1'); %%%% %%%%
%             agt_load_pulse_sequence('1 a 1 3 a 1','Phase_1');
            agt_advanced_trigger_mode_for_phase_cycle;
            pause(0.1)
        end
        if phasecycle == 2;
            agt_connect_and_initialize;
            agt_load_pulse_sequence('1 c 1 3 c 1','Phase_2');
            agt_advanced_trigger_mode_for_phase_cycle;
            pause(0.1)
        end
%         if phasecycle == 3;
%             agt_connect_and_initialize;
%             agt_load_pulse_sequence('3 a 1','Phase_3');
%             agt_advanced_trigger_mode_for_phase_cycle;
%         end
%         if phasecycle == 4;
%             agt_connect_and_initialize;
%             agt_load_pulse_sequence('3 c 1','Phase_4');
%             agt_advanced_trigger_mode_for_phase_cycle;
%         end
    

for iB0 = (1:nT);
  tau = T0 + (iB0-1)*dT;
%   tau = tau0;
  itau = 100;
  %%% SET FIELD %%%
%  
%   B0 = B0_start - iB0*dB0
%   B0_center = round(B0*20)/20.0;
%   Field_write(B0);
              
        
    


      start_program; % Begin pulse program
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
        
          delay(200*ms) % for alazar load
          h_loop = start_loop(h); % Start of shot loop

          delay(10*MIL);       % Initial instruction should be longer than 2*MIL
    %      Wait_for_Trigger;  % (WAIT can not be the 1st instruction) 
    %      ZTO_Trigger;

          LED_Trigger;
          delay(d9);  % Delay to accomodate LED pulse (or prep E-pulse)

        %   Alazar_Trigger;
%           delay(tauConstant)
          pulse;               % pi pulse1
          delay(tau-d_11);     % tau
%           Alazar_Trigger;
          pulse;               % pi/2 pulse    
          delay(tauConstant-d_a1);  % tau + d0 delay

          pulse;               % pi pulse    
          delay(tauConstant-d_11-Alazar_Delay);  % tau + d0 delay
          
      %    Alazar_Trigger;

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



     
      chAintegrated = zeros(post_trig-pre_trig,1);
      chBintegrated = zeros(post_trig-pre_trig,1);
      for repeatAvg = 1:nrepeat;
        PulseBlaster_run_wait_to_finish;
        [chA,chB,result] = acquireData(boardHandle, pre_trig, post_trig, averages);
%         calllib('spinapi','pb_reset');  % Reset the program to the 1st instruction  
        retCode = calllib('ATSApi', 'AlazarAbortCapture', boardHandle);
        chAintegrated = chAintegrated + chA;
        chBintegrated = chBintegrated + chB;
        istatus = calllib('spinapi','pb_read_status');
            
        while (mod(istatus,2)==0); % read least significant bit (bit 0); if it's a 1, program has finished
                istatus = calllib('spinapi','pb_read_status');
        end;

      end
%       calllib('spinapi','pb_reset');  % Reset the program to the 1st instruction  

      disp([int2str(iB0) ' of ' int2str(nT)]);


    x_time = linspace(0,acq_time,(post_trig - pre_trig)); % do not comment this line out if rephasing and integrating data.

    %%  This is to check the integral window. 
    % % % figure;
    % % % plot(x_time,chA,'r',x_time,chB,'b');


    %% Rephase and Integrate Data
        clear Y1;
        if phasecycle == 1;
%             chAintegrated = chAintegrated;
%             chBintegrated = chBintegrated;
            Y1 = chAintegrated' + 1i*chBintegrated';
        end
        if phasecycle == 2;
            Y1 = -1*chAintegrated' - 1i*chBintegrated';
        end
%         if phasecycle == 3;
%             Y1 = chAintegrated' + 1i*chBintegrated';
%         end
%         if phasecycle == 4;
%             Y1 = -1*chAintegrated' - 1i*chBintegrated';
%         end
        
%         chA = chAintegrated;
%         chB = chBintegrated;
        Y1 = chA' + 1i*chB';
    %     Ymag = sqrt(chA'.^2 + chB'.^2);
    %     Y1 = Ymag;
  
%       b_1 = .75e-6; % time in s after trigger to start baseline correct
%     b_2 = .8e-6; % time in s after trigger to stop baseline correct
%     b_3 = 2.6e-6; % time in s after trigger to start baseline correct
%     b_4 = 4.6e-6; % time in s after trigger to stop baseline correct
%     int_w = 500e-9; % integral width/2
%     int_c = 1.8e-6; % integral center
%     e_1 = int_c - int_w/2; %1.3e-6; % time in s after trigger to start echo integral;
%     e_2 = int_c + int_w/2; %2.3e-6; % time in s after trigger to end echo intergral;
        b_1 = parameters.b_1; %4.5e-6; % time in s after trigger to start baseline correct
        b_2 = parameters.b_2; %5.0e-6; % time in s after trigger to stop baseline correct
        b_3 = parameters.b_3;%7.0e-6; % time in s after trigger to start baseline correct
        b_4 = parameters.b_4; % time in s after trigger to stop baseline correct
        int_w = parameters.int_w;%600e-9; % integral width/2
        int_c = parameters.int_c;%6.00e-6; % integral center
        e_1 = int_c - int_w/2; %1.3e-6; % time in s after trigger to start echo integral;
        e_2 = int_c + int_w/2; %2.3e-6; % time in s after trigger to end echo intergral;
%     b_1 = 0.1e-6; % time in s after trigger to start baseline correct
%     b_2 = 0.4e-6; % time in s after trigger to stop baseline correct
%     b_3 = 9.5e-6; % time in s after trigger to start baseline correct
%     b_4 = 10.6e-6; % time in s after trigger to stop baseline correct
%     int_w = 500e-9; % integral width/2
%     int_c = 3.90e-6; % integral center
%     e_1 = int_c - int_w/2; %1.3e-6; % time in s after trigger to start echo integral;
%     e_2 = int_c + int_w/2; %2.3e-6; % time in s after trigger to end echo intergral;
%     
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
        
        %% Baseline correction turned off here... recomment in yb in following line to turn back on.
        Y3 = Y1(m(1):m(4))- yb;
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
    signalI(iB0) = sum(real(Y3(int1-bl1:int2-bl1)));
    signalQ(iB0) = sum(imag(Y3(int1-bl1:int2-bl1)));
    signalM(iB0) = sqrt(signalI(iB0)^2 + signalQ(iB0)^2);
    % signal(iB0) = sum(abs(Y2(int1-bl1:int2-bl1)));
 
   

figure(1);
plot(tauplot,signalM);
xlabel('tau (ns)')
ylabel('Signal Intensity')
title('T1 Inversion Recovery (magnitude)')
pause(0.1)
figure(2);
plot(xb,real(Y3),'green',xb,imag(Y3),'blue')
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
plot(tauplot,signalI,'green',tauplot,signalQ,'blue');
xlabel('tau (ns)')
ylabel('Signal Intensity')
title('T1 decay (I and Q)')
pause(0.1)
end
    tottauplot = tauplot;
    totsignalI(:,phasecycle) = signalI;
    totsignalQ(:,phasecycle) = signalQ;
    totsignalM(:,phasecycle) = signalM;
%     clear signalI signalQ signalM tauplot
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

data(hf).tau = tauplot;
data(hf).signalI = sum(totsignalI,2);
data(hf).signalQ = sum(totsignalQ,2);
data(hf).signalM = sum(totsignalM,2);
data(hf).comments = ['ran out of helium so only was able to do one phase for the mI = +3/2 hyperfine line. T1 measurement over all HF lines in Transmutation doped Ge:As (10^15), B0 oriented in [100] T = swept' ' us, frequency = ' num2str(mw_freq) ' tau(constant) = ' num2str(tauConstant) 'MHz, averages = ' num2str(averages * nrepeat) ', d9 = ' num2str(d9/1000) ' us, power = ' num2str(mw_power) ' dBm + nominally 50dBm from TWT, note tau is interpulse delay, not 2*tau, resonator Q overcoupled to ~2000.'];
data(hf).field = B0_start;
data(hf).power = mw_power;
% data(hf).T_start = str2double(T_start);
% data(hf).T_stop = str2double(T_stop);
data(hf).parameters = parameters;



% optionally plot data
% x_time = linspace(0,acq_time,(post_trig - pre_trig));
% figure;
% % plot(x_time,chA,'r',x_time,chB,'b');
% Disconnect from ER032M
% fclose(ER032M);
% delete(ER032M);


disp('Done!');
end