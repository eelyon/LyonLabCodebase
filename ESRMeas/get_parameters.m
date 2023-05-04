parameters.comments = ['insert comments here'];

%% configuration of setup (shouldn't change often)
% agilent
ns = 1.0;
us = 1000.0;
ms = 1000000.0;


%% Agilent Parameters

parameters.mw_freq = 9588.7; %9632.3245 - 0; %9615.975;% 9575.2;%9015.9688;%9476.05;%9634.080; % microwave frequency in MHz
parameters.mw_power = -15.0; % Agilent Power in dBm. not including gain on big amplifier

% param eters for second agilent if doing ENDOR
parameters.RFpulselength = 100000; %200000 subharmonic with 12dBm in ns
parameters.RFPOW = 15;

%% Data Collection Parameters

parameters.Alazar_Delay = 12*us; % timing delay depending on pulse sequence used.

parameters.averages = 1;%20; % number of averages to fill into Alazar buffer before dumping to memory. Keep below 1000.
parameters.nrepeat = 1; % number of times to repeat parameters.averages. Slower averaging than parameters.averages but doesn't have the buffer limitations.

parameters.acq_time = 40e-6;%280 10e-6 typical % time to record after alazar trigger. must be longer than baseline correct markers but short enough to save memory.

parameters.b_1 = 1e-6; %4e-6 time in s after trigger to start baseline correct 20
parameters.b_2 = 2e-6; % time in s after trigger to stop baseline correct 25
parameters.b_3 = 37e-6; % time in s after trigger to start baseline correct
parameters.b_4 = 40e-6; % time in s after trigger to stop baseline correct
parameters.int_w = 8e-6; % integral width
parameters.int_c = 14.5e-6; %5.85e-6; %parameters.Alazar_Delay * 1e-9; % integral center

%% LED SRT params

parameters.d9 = 3000*ms;%10*ms; %530*ms; % delay after LED trigger.
parameters.srt = 55*ms; % shot repetition time.

%% Field Sweep Parameters
% % 
% parameters.tau0 = 30*us;
% parameters.h = 2; 
% 
% parameters.field_error = 0;% for 2500G %-5.5 for 4400 gauss;
% parameters.B0_span = 5;
% parameters.B0_step = 0.2;%.05;
% parameters.zfs = 2800;%2800/2.8025; % zero field splitting
% parameters.aiso = 42;
% parameters.g_factor = 1.99875;%1.99875
% parameters.B0_start = (parameters.mw_freq)/2.8025 * 2.0023/parameters.g_factor + parameters.field_error - parameters.B0_span/2;
% parameters.B0_start = 3456;%%(parameters.mw_freq)/2.8025 * 2.0023/parameters.g_factor + parameters.field_error + parameters.aiso/2- parameters.B0_span/2; %- span
% parameters.noB0step = -2;
% 
% parameters.B0_wait = 50;

%% Oscilloscope mode parameters
% 
% parameters.tau0 = 10*us;
% parameters.h = round(parameters.averages+10);
% parameters.d9 = 150*ms;
% parameters.srt = 50*ms;
% 
% parameters.field_error = 0;% for 2500G %-5.5 for 4400 gauss;
% %parameters.B0_span = 10;
% %parameters.B0_step = .1; 
% 
% %parameters.aiso = 42;% 20.4;%35.62;
% parameters.g_factor = 1.99875;%1.99875;
% %parameters.B0_start = (parameters.mw_freq)/2.8025 * 2.0023/parameters.g_factor - parameters.field_error - parameters.B0_span/2 - 21;
% parameters.B0 = 2893.5; %(parameters.mw_freq)/2.8025 * 2.0023/parameters.g_factor - parameters.field_error - 21;
% 
% 
% parameters.B0_wait = 0.2;
%% T2 decay Parameters
% 
% parameters.tau0 = 30*us;
% parameters.dtau = 30*us;
% parameters.tauArr = 3*logspace(4,8,300);
% 
% parameters.ntau = 600;
% parameters.h = 2;%round(parameters.averages);%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
% parameters.srt = 50*ms;
% 
% parameters.field_error = 0;% -5.5;
% parameters.aiso = 42;
% parameters.g_factor = 1.99875;
% parameters.B0_start = (parameters.mw_freq)/2.8025 * 2.0023/parameters.g_factor - parameters.field_error + parameters.aiso/2;
% parameters.noB0step = 0;
% 
% parameters.B0_start = 3440;%parameters.mw_freq/2.8025 * 2.0023/parameters.g_factor + parameters.field_error;
% parameters.B0_wait = .1;
% parameters.dB0 = 0.3;
% 
% parameters.npulse=1;
% % % % % % % 

%% CPMG Parameters

% parameters.tau0 = 1000*us;
% parameters.tOffset = 6*us; % The offset in time from the start of the acquisition to align center of pulse
% parameters.dtau = 1*us;
% parameters.ntau = 200;
% parameters.npulse = 5;
% parameters.h = 2;
% parameters.srt = 50*ms;
% parameters.acq_time = (2*parameters.npulse + 1)*parameters.tau0*1e-9;
% parameters.b_4 = parameters.acq_time;

% If doing a field sweep with CPMG, add below

% parameters.B0_span = 1;
% parameters.B0_step = 0.05;
% parameters.B0_start = (parameters.mw_freq)/2.8025 * 2.0023/parameters.g_factor + parameters.field_error + parameters.aiso/2- parameters.B0_span/2; 

%% PSD Parameters
% % % 
% parameters.tau0 = 60*us;
% parameters.tauArr = [3000*us];%,30*us,100*us,500*us,1000*us, 2000*us,3000*us];
% parameters.nshots = 100;
% parameters.h = 2;%round(parameters.averages);%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
% parameters.srt = 50*ms;


%% Optical Polarization Saturation Curve Parameters
% % % 
% parameters.tau = 8*us;
% parameters.tau0 = 100*ms;
% parameters.dtau = 200*ms;
% parameters.ntau = 12;
% parameters.nRepeats = 1;   % repeat the optical pulse. Sometimes need this due to the maximum instruction length of pulseblaster
% parameters.spacing = 'linear';
% % %parameters.spacing = 'log';
% parameters.d9 = 230*ms;
% parameters.h = round(parameters.averages+5);%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
% parameters.srt = 50*ms;
% 
% parameters.field_error = 0;% -5.5;
% parameters.aiso = 20.4;
% parameters.g_factor = 1.917;%1.5631;
% parameters.B0_start = 2520.25;%parameters.mw_freq/2.8025 * 2.0023/parameters.g_factor + parameters.field_error;
% parameters.B0_wait = .1;
% parameters.dB0 = 0.3;
% % % % % % 
%% 2p ESEEM Parameters
% 
% parameters.tau0 = 2*us;%%1.8*us;
% parameters.dtau = 50*ns;
% parameters.ntau = 500;
% parameters.d9 = 2*ms;
% parameters.h = round(parameters.averages+10);%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
% parameters.srt = 2.0*ms;
% 
% parameters.B0_start = 4364.9;
% parameters.g_factor = 1.5631;
% parameters.B0_wait = .1;
% parameters.dB0 = 0.3;
% parameters.field_error = -2.67;


 %% Rabi Parameters

% parameters.tau0 = 30*us;
% parameters.power_start = -25;
% parameters.power_stop = -15;
% parameters.power_step = 1;
% 
% parameters.ntau = 30;
% parameters.h = 2;%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
% 
% parameters.B0_wait = 1;
% parameters.dB0 = 0.3;
% 
% parameters.field_error = 0;%2.9;%-2.7;
% parameters.aiso = 20.4;
% parameters.g_factor = 1.99837;
% parameters.B0_start = 2474.5;%parameters.mw_freq/2.8025 * 2.0023/parameters.g_factor - parameters.field_error-35.5;
% parameters.nscan = 1;

% 
%% Stark Parameters;
% 
% parameters.tau0 = 20*us;
% parameters.dtau = 0*ns;
% parameters.ntau = 100; % number of data points to take (stark data points are half this)
% parameters.d9 = 2*ms;
% parameters.h = round(parameters.averages+30);%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
% parameters.srt = 2*ms;
% 
% parameters.field_error = -5.26;%-2.7;
% parameters.aiso = 20.4;%20.4;
% parameters.g_factor = 1.5631;
% 
% parameters.B0_start = 4385.86-parameters.aiso/2;%parameters.mw_freq/2.8025 * 2.0023/parameters.g_factor + parameters.field_error - parameters.aiso/2;
% 
% parameters.B0_wait = 3;
% parameters.dB0 = 0.0;

%% T1 IR parameters
% % % % 
%   parameters.T0 = 30*us; % initial tau between first pi pulse and pi/2 [in ns]  
%   parameters.dT = 100*ms; % tau step [in ns]
%   parameters.nT = 20; % # of time steps
%   parameters.tauConstant = 8*us; % tau between pi/2 and pi pulse
%   parameters.srt = 50.0*ms; % shot repetition time            % (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
%   parameters.d9 =2000*ms;  % delay to accomodate an LED pulse 
%   parameters.h = round(parameters.averages+1);%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
%   
%   parameters.field_error = -5.26;%-2.7;
%   parameters.aiso = 0;%20.4;
%   parameters.g_factor = 1.5631;
%   
%   parameters.B0_start = 2473.2;% parameters.mw_freq/2.8025 * 2.0023/parameters.g_factor + parameters.field_error - parameters.aiso/2;
%   parameters.B0_wait = 1;
%   parameters.dB0 = 0.3;

%% Davies ENDOR parameters
% % % % % % 
% parameters.T0 = 40*us; % initial tau between first pi pulse and pi/2 [in ns]  
% 
% parameters.tauConstant = 50*us; % tau between pi/2 and pi pulse
% parameters.srt = 2.0*ms; % shot repetition time            % (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
% parameters.d9 = 6*ms;  % delay to accomodate an LED pulse 
% parameters.h = round(parameters.averages+20);%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
% 
% parameters.field_error = -5.26;%-2.7;
% parameters.aiso = 42;%20.4;
% parameters.g_factor = 1.99875;
% 
% parameters.B0_start = 2749.77;%parameters.mw_freq/2.8025 * 2.0023/parameters.g_factor + parameters.field_error - parameters.aiso/2;
% parameters.B0_wait = 1;
% parameters.dB0 = 0.3;
% 
% parameters.fcenter = 63.95* 1e6;%53.6775/2*1e6; % center frequency in Hz
% parameters.fspan = .3e6;
% parameters.nFreq = 60; % numer of frequency steps
% parameters.RF_Pow = 15;%12;%3;
% 
% parameters.RFstart = parameters.fcenter - parameters.fspan/2;
% parameters.df = parameters.fspan / parameters.nFreq;
% 

%% Davies ENDOR RABI parameters
% % % % % % % 
% parameters.T0 = 40*us; % initial tau between first pi pulse and pi/2 [in ns]  
% 
% parameters.tauConstant = 40*us; % tau between pi/2 and pi pulse
% parameters.srt = 2.0*ms; % shot repetition time            % (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
% parameters.d9 = 6*ms;  % delay to accomodate an LED pulse 
% parameters.h = round(parameters.averages+10);%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
% 
% parameters.field_error = -5.26;%-2.7;
% parameters.aiso = 42;%20.4;
% parameters.g_factor = 1.99875;
% 
% parameters.B0_start =  2750.6;%parameters.mw_freq/2.8025 * 2.0023/parameters.g_factor + parameters.field_error - parameters.aiso/2;
% parameters.B0_wait = 1;
% parameters.dB0 = 0.3;
% 
% parameters.fcenter = 63.955/2*1e6;%93.3324/2*1e6; % center frequency in Hz
% parameters.RFwattPOW = (linspace(sqrt(.03), sqrt(0.0005), 15)).^2;
% parameters.RFPOW = 10.*log10(1000 .* parameters.RFwattPOW/1); % linearize the power sweep.
% % % % % % parameters.POWstart = 18;
% % % % % % parameters.pwrstop = 20;
% % % % % % parameters.dPOW = 1;
% % % % % % parameters.nPOW = 1;%round((parameters.pwrstop - parameters.POWstart)/parameters.dPOW); % numer of frequency steps

%% Davies ENDOR 2D vary frequency and length parameters
% % % % % 
% parameters.T0 = 40*us; % initial tau between first pi pulse and pi/2 [in ns]  
% 
% parameters.tauConstant = 40*us; % tau between pi/2 and pi pulse
% parameters.srt = 2.0*ms; % shot repetition time            % (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
% parameters.d9 = 6*ms;  % delay to accomodate an LED pulse 
% parameters.h = round(parameters.averages+13);%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
% 
% parameters.field_error = -5.26;%-2.7;
% parameters.aiso = 42;%20.4;
% parameters.g_factor = 1.99875;
% 
% parameters.B0_start =  2749.77;%parameters.mw_freq/2.8025 * 2.0023/parameters.g_factor + parameters.field_error - parameters.aiso/2;
% parameters.B0_wait = 1;
% parameters.dB0 = 0.3;
% 
% parameters.fspan = 12e3;
% parameters.fcenter = 63.955*1e6;%93.3324/2*1e6; % center frequency in Hz
% parameters.freqs = linspace(parameters.fcenter - parameters.fspan/2,parameters.fcenter + parameters.fspan/2, 50);
% 
% % % % % % parameters.pwrstop = 20;
% % % % % % parameters.dPOW = 1;
% % % % % % parameters.nPOW = 1;%round((parameters.pwrstop - parameters.POWstart)/parameters.dPOW); % numer of frequency steps
%% Davies ENDOR 2D vary frequency and power parameters

% parameters.T0 = 40*us; % initial tau between first pi pulse and pi/2 [in ns]  
% 
% parameters.tauConstant = 40*us; % tau between pi/2 and pi pulse
% parameters.srt = 3.0*ms; % shot repetition time            % (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
% parameters.d9 = 9*ms;  % delay to accomodate an LED pulse 
% parameters.h = round(parameters.averages+13);%200*ms/parameters.d9+parameters.averages);% changing this can cause timeout errors.
% 
% parameters.field_error = -5.26;%-2.7;
% parameters.aiso = 42;%20.4;
% parameters.g_factor = 1.99875;
% 
% parameters.B0_start = 2750.85-.26;%parameters.mw_freq/2.8025 * 2.0023/parameters.g_factor + parameters.field_error - parameters.aiso/2;
% parameters.B0_wait = 1;
% parameters.dB0 = 0.3;
% 
% parameters.RFwattPOW = (linspace(sqrt(0.0002),sqrt(.04),50)).^2;
% parameters.RFPOW = 10.*log10(1000 .* parameters.RFwattPOW/1); % linearize the power sweep.
% 
% 
% parameters.fspan = 40e3;
% parameters.fcenter = 63.955*1e6;%93.3324/2*1e6; % center frequency in Hz
% parameters.freqs = linspace(parameters.fcenter - parameters.fspan/2,parameters.fcenter + parameters.fspan/2, 25);
% % % 

%% Fourier Transform EPR Parameters
% % % 
% parameters.Alazar_Delay = 10000;
% parameters.acq_time = 30e-6;
% 
% parameters.tau0 = 25*us;
% parameters.h = round(parameters.averages+110);
% parameters.d9 = 4*ms;
% parameters.srt = 1*ms;
% 
% parameters.field_error = -2.54;% for 2500G %-5.5 for 4400 gauss;
% parameters.B0_span = 25;
% parameters.B0_step = 0; 
% 
% parameters.aiso = 41.8;% 20.4;%35.62;
% parameters.g_factor = 1.99875;
% parameters.B0_start = 544;%parameters.mw_freq/2.8025 * 2.0023/parameters.g_factor + parameters.field_error - parameters.B0_span/2 - parameters.aiso/2;
% 
% parameters.B0_wait = 0.2;


