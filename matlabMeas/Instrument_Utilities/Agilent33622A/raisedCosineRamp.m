%% TCPIP AWG Control: 79-Pulse Shuttling Burst
clear; clc; close all;

% --- 1. Connection Parameters ---
instrumentIP = '192.168.1.101'; % <--- Change to your AWG's IP address
visaAddress = sprintf('TCPIP0::%s::inst0::INSTR', instrumentIP);

% --- 2. Waveform & Timing Parameters ---
sampleRate = 160e6;      % 160 MSa/s (Max for 33512B)
Vlow = -1.0;             % Low Level
Vhigh = 3.0;             % High Level
numFast = 76;            % Fast cycles
numSlow = 3;             % Slow cycles
numBursts = 5;           % Hardware repetitions

% Pulse Specs
freqFast = 100e3;        % 100 kHz
rampFast = 100e-9;       % 100 ns S-curve ramp
freqSlow = 50e3;         % 50 kHz
rampSlow = 200e-9;       % 200 ns S-curve ramp

% --- 3. Generate Pulse Profiles (S-Curve / Raised Cosine) ---
% Helper function for S-curve pulses
genPulse = @(freq, ramp, sr) ...
    struct('y', computeSCurve(freq, ramp, sr), 't', (0:round((1/freq)*sr)-1)/sr);

fastPulse = genPulse(freqFast, rampFast, sampleRate);
slowPulse = genPulse(freqSlow, rampSlow, sampleRate);

% Concatenate Full Sequence (76 Fast + 3 Slow)
y_norm = [repmat(fastPulse.y, 1, numFast), repmat(slowPulse.y, 1, numSlow)];
t_total = (0:length(y_norm)-1) / sampleRate;

% --- 4. Visualization ---
figure('Name', 'Waveform Preview', 'Color', 'w');
% Subplot 1: First 3 Fast Pulses
subplot(2,1,1);
plot_limit = round(3 * (1/freqFast) * sampleRate);
plot(t_total(1:plot_limit)*1e6, (y_norm(1:plot_limit)*4)-1, 'b', 'LineWidth', 1.5);
title('Detail: First 3 Fast Pulses (S-Curve)');
xlabel('Time (\mus)'); ylabel('Voltage (V)'); grid on; ylim([-1.5 3.5]);

% Subplot 2: Entire 79-Pulse Buffer
subplot(2,1,2);
plot(t_total*1e3, (y_norm*4)-1, 'r');
title('Full 79-Pulse Sequence (One iteration)');
xlabel('Time (ms)'); ylabel('Voltage (V)'); grid on; ylim([-1.5 3.5]);

% --- 5. Connect and Upload ---
% try
%     fgen = visadev(visaAddress);
%     fgen.ByteOrder = "big-endian";
%     fgen.Timeout = 20; % Increase timeout for large data transfers
% 
%     % Reset and Clear
%     writeline(fgen, "*RST");
%     writeline(fgen, "DATA:VOLATILE:CLEAR");
% 
%     % Convert to 16-bit DAC values (Maps 0..1 to -32767..32767)
%     y_dac = int16((y_norm * 2 - 1) * 32767);
% 
%     fprintf('Uploading waveform to %s...\n', instrumentIP);
%     writebinblock(fgen, y_dac, "int16", "DATA:ARB:DAC SHUTTLE, ");
%     pause(1); % Allow time for processing
% 
%     % --- 6. Instrument Configuration ---
%     writeline(fgen, "FUNC:ARB SHUTTLE");
%     writeline(fgen, "FUNC:ARB:SRAT " + num2str(sampleRate));
%     writeline(fgen, "FUNC ARB");
% 
%     % Set Levels and Filtering
%     writeline(fgen, "VOLT:LOW " + num2str(Vlow));
%     writeline(fgen, "VOLT:HIGH " + num2str(Vhigh));
%     writeline(fgen, "OUTP:FILT:CH1 STEP"); % Optimize for pulse response
% 
%     % Burst Setup (Repeat the whole sequence 5 times)
%     writeline(fgen, "BURS:STAT ON");
%     writeline(fgen, "BURS:MODE TRIG");
%     writeline(fgen, "BURS:NCYC " + num2str(numBursts));
%     writeline(fgen, "TRIG:SOUR BUS");
%     writeline(fgen, "OUTP ON");
% 
%     % --- 7. Execution ---
%     fprintf('Ready! Each trigger will fire 5 iterations of the 79 pulses.\n');
%     input('Press ENTER to send Software Trigger...', 's');
%     writeline(fgen, "*TRG");
%     fprintf('Burst Fired.\n');
% 
% catch ME
%     error('Connection failed: %s', ME.message);
% end

% --- Helper Function for S-Curve Construction ---
function y = computeSCurve(freq, rampTime, sr)
    period = 1/freq;
    pts = round(period * sr);
    t = linspace(0, period, pts);
    y = zeros(size(t));
    
    % 50% Duty Cycle logic
    pw = period * 0.5;
    
    % Rise
    r_idx = t < rampTime;
    y(r_idx) = 0.5 * (1 - cos(pi * t(r_idx) / rampTime));
    % High
    h_idx = t >= rampTime & t < (pw - rampTime);
    y(h_idx) = 1;
    % Fall
    f_start = pw - rampTime;
    f_idx = t >= f_start & t < pw;
    y(f_idx) = 0.5 * (1 + cos(pi * (t(f_idx) - f_start) / rampTime));
end