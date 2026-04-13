%% Mixed-Speed Pulse Train (76 Fast + 3 Slow)
% clear; clc;

% --- 1. Global Parameters ---
sampleRate = 160e6;     % 160 MSa/s for 33512B
Vlow = -1.0;
Vhigh = 3.0;
Vrange = Vhigh - Vlow;

% --- 2. Define "Fast" Pulses (76 cycles) ---
freqFast = 100e3;           
dutyFast = 0.5;       
% rampFast = 300e-9;      
numFast  = 2;
numSteps = 2;
dutyRise = 1/3;

% --- 3. Define "Slow" Pulses (3 cycles) ---
freqSlow = 50e3;
dutySlow = 0.355;
rampSlow = 0.5e-6;
numSlow  = 2;

% --- 1. Define the Loading Header (e.g., 2 periods long) ---
% We create a custom sequence to "Hand-off" the electron to Phase 1
% loadHeader = zeros(1, 2 * ptsPerPeriod); 
% Logic: Rise slowly at the start of the second period of the header
% so that Phase 1 is HIGH exactly when the CCD clock starts.
% t_header = linspace(0, 2*T, 2*ptsPerPeriod);
% loadHeader(t_header > 1.5*T) = (t_header(t_header > 1.5*T) - 1.5*T) / (0.5*T);
% Now y_final_P1 = [loadHeader, y_body, tail];

shifts = [0,1/3,2/3];
y1_single = computeStaircase(freqFast, sampleRate, shifts(1), numSteps, dutyFast, dutyRise);
y1_final = repmat(y1_single, 1, numFast); %, repmat(y_slow, 1, numSlow)];

% Force the first pulse to start HIGH
% Find the index where the first high plateau normally begins
T = 1/freq;
totalRiseTime = T * dutyRise;
firstPlateauIdx = find(y1_single >= 1.0, 1, 'first');
% firstHighIdx = round(totalRiseTime * sr);

% Overwrite the beginning of the array with 1.0
% This removes the "Rise" steps for the first pulse
y1_final(1:firstPlateauIdx) = 1.0;

% Add the Buffer (Idle Low at the end)
% We still want it to end low so the AWG doesn't stay at 4V forever
tail = zeros(1, round(0.001 * sr)); 
y1_final = [y1_final, tail];

y2 = computeStaircase(freqFast, sampleRate, shifts(2), numSteps, dutyFast, dutyRise);
y3 = computeStaircase(freqFast, sampleRate, shifts(3), numSteps, dutyFast, dutyRise);
y2_norm = repmat(y2, 1, numFast); %, repmat(y_slow, 1, numSlow)];
y3_norm = repmat(y3, 1, numFast); %, repmat(y_slow, 1, numSlow)];

% y1_norm = computePulse(sampleRate,shifts(1),freqFast,freqSlow,numFast,numSlow,rampFast,rampSlow,dutyFast,dutySlow);
% y2_norm = computePulse(sampleRate,shifts(2),freqFast,freqSlow,numFast,numSlow,rampFast,rampSlow,dutyFast,dutySlow);
% y3_norm = computePulse(sampleRate,shifts(3),freqFast,freqSlow,numFast,numSlow,rampFast,rampSlow,dutyFast,dutySlow);

y_volt1 = (y1_final * Vrange) + Vlow; % Scale to -1V to +3V
t_total1 = (0:length(y_volt1)-1) / sampleRate;
y_volt2 = (y2_norm * Vrange) + Vlow; % Scale to -1V to +3V
t_total2 = (0:length(y_volt2)-1) / sampleRate;
y_volt3 = (y3_norm * Vrange) + Vlow; % Scale to -1V to +3V
t_total3 = (0:length(y_volt3)-1) / sampleRate;

figure()
subplot(2,1,1)
periodFast = 1/freqFast;
ptsFast = round(periodFast * sampleRate);
plot_pts = ptsFast * 2;
% t_total = (0:length(y_full)-1)/sampleRate;
plot(t_total1(1:plot_pts)*1e6, y_volt1(1:plot_pts))
hold on
plot(t_total2(1:plot_pts)*1e6, y_volt2(1:plot_pts))
plot(t_total3(1:plot_pts)*1e6, y_volt3(1:plot_pts))
hold off
title('Full 79-Pulse Sequence (-1V to +3V)')
xlabel('Time (us)'); ylabel('Voltage (V)'); grid on

subplot(2,1,2)
% t_total = (0:length(y_full)-1)/sampleRate;
plot(t_total1*1e3, y_volt1)
hold on
plot(t_total2*1e3, y_volt2)
plot(t_total3*1e3, y_volt3)
hold off
title('Full 79-Pulse Sequence (-1V to +3V)')
xlabel('Time (ms)'); ylabel('Voltage (V)'); grid on

% configAWG(awg2ch_3,1,y1_norm,sampleRate,Vlow,Vhigh)
% configAWG(awg2ch_3,2,y2_norm,sampleRate,Vlow,Vhigh)
% configAWG(Awg2ch_1,1,y3_norm,sampleRate,Vlow,Vhigh)

% writeline(awg2ch_3.client, "FUNC:ARB:SYNC")

% input('Press Enter to fire the 79-pulse sequence...', 's');
% writeline(awg2ch_3.client, "*TRG");

function y = computeStaircase(freq, sr, shiftFactor, numSteps, duty, dutyRise)
    T = 1/freq;
    pts = round(T * sr);
    t = linspace(0, T, pts);
    pw = T * duty;
    
    % Define how long each individual step lasts
    totalRiseTime = T * dutyRise; 
    stepDuration = totalRiseTime / numSteps;
    
    t_pulse = t - (shiftFactor * T);
    y = zeros(size(t));
    
    % Build the Steps
    for s = 1:numSteps
        v_level = s / numSteps;
        
        % Rise timing for this specific step
        t_start_rise = (s-1) * stepDuration;
        t_end_rise = s * stepDuration;
        
        % Fall timing for this specific step (symmetrical)
        t_start_fall = pw - (s * stepDuration);
        t_end_fall = pw - ((s-1) * stepDuration);
        
        % Apply voltage to the rise side
        y(t_pulse >= t_start_rise & t_pulse < t_end_rise) = v_level;
        
        % Apply voltage to the fall side
        y(t_pulse >= t_start_fall & t_pulse < t_end_fall) = v_level;
    end
    
    % Build the High Plateau
    % Fills the gap between the last rise step and the first fall step
    y(t_pulse >= totalRiseTime & t_pulse < (pw - totalRiseTime)) = 1.0;
end

function plotPulse(y_norm,Vrange,Vlow,sampleRate,periodFast)
    y_volt = (y_norm * Vrange) + Vlow; % Scale to -1V to +3V
    t_total = (0:length(y_volt)-1) / sampleRate;

    figure;
    subplot(2,1,1);
    ptsFast = round(periodFast * sampleRate);
    plot_pts = ptsFast * 3;
    % t_total = (0:length(y_full)-1)/sampleRate;
    plot(t_total(1:plot_pts)*1e6, y_volt(1:plot_pts)); 
    title('Full 79-Pulse Sequence (-1V to +3V)');
    xlabel('Time (ms)'); ylabel('Voltage (V)'); grid on;
    
    subplot(2,1,2);
    % t_total = (0:length(y_full)-1)/sampleRate;
    plot(t_total*1e3, y_volt); 
    title('Full 79-Pulse Sequence (-1V to +3V)');
    xlabel('Time (ms)'); ylabel('Voltage (V)'); grid on;
end

function [] = configAWG(Agilent33512B,ch,y_norm,sampleRate,vlow,vhigh)
    % % --- 5. Upload and Configure ---
    % command = ['SOUR',num2str(channel),':FUNC ', type];
    % fprintf(Awg2ch_1,['SOUR',num2str(channel),':FUNC ', type]);
    
    % awgIP = '172.29.117.62';
    % visaAddress = sprintf('TCPIP0::%s::inst0::INSTR', awgIP);
    % awg2ch_3.client = visadev(visaAddress);
    % awg3_Address = '172.29.117.62';
    % awg2ch_3 = Agilent33622A(1234,awg3_Address,1);
    
    Agilent33512B.client.ByteOrder = "big-endian";
    
    writeline(Agilent33512B.client, "*CLS"); % Clear status and error queue
    writeline(Agilent33512B.client, "*RST"); % Reset instrument
    writeline(Agilent33512B.client, "DATA:VOL:CLE");
    
    % Convert to DAC values (-32767 to +32767)
    y_dac = int16((y_norm*2 - 1) * 32767);
    writebinblock(Agilent33512B.client, y_dac, "int16", "SOURCE"+num2str(ch)+":DATA:ARB:DAC SHUTTLE"+num2str(ch)+", ");
    pause(1);
    
    writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":FUNC:ARB SHUTTLE" + num2str(ch));
    writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":FUNC:ARB:SRAT " + num2str(sampleRate));
    writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":FUNC ARB");
    writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":FUNC:ARB:FILT STEP"); % Pulse optimised filter
    writeline(Agilent33512B.client, "OUTP"+num2str(ch)+":LOAD INF");
    writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":VOLT:LOW " + num2str(vlow));
    writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":VOLT:HIGH " + num2str(vhigh));
    % writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":VOLT " + num2str(4));
    % writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":VOLT:OFFS " + num2str(1));
    
    % Trigger Setup: Play the whole sequence once per trigger
    writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":BURS:STAT ON");
    writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":BURS:MODE TRIG");
    writeline(Agilent33512B.client, "SOUR"+num2str(ch)+":BURS:NCYC " + num2str(5)); % We treat the entire 79-pulse array as 1 cycle

    % writeline(Agilent33512B.client, "TRIG" + ch + ":SOUR BUS");
    writeline(Agilent33512B.client, "TRIG" + ch + ":SOUR EXT");
    writeline(Agilent33512B.client, "TRIG" + ch + ":SLOP POS")

    writeline(Agilent33512B.client, "OUTP" + ch + " ON");
    writeline(Agilent33512B.client, "OUTP:SYNC:SOUR CH1");
    writeline(Agilent33512B.client, "OUTP:SYNC:MODE NORM"); % Pulse at start of Arb
    writeline(Agilent33512B.client, "OUTP:SYNC ON");
    
    writeline(Agilent33512B.client, "SYST:ERR?");
    err = readline(Agilent33512B.client);
    if contains(err, "No error")
        fprintf('Configuration successful: %s', err);
    else
        warning('Instrument Error: %s', err);
    end
end