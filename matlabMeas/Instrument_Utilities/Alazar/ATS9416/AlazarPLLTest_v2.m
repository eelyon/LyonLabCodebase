% Digital PLL with VCO for lock-in amplifier
clear; clc;

%% Parameters
Fs = 2000;             % Sampling frequency (Hz)
T = 1/Fs;              % Sampling period
t = 0:T:1;             % Time vector (1 second)
f_signal = 100;         % Input signal frequency (Hz)
f_vco_init = 100;       % Initial VCO frequency (Hz)

%% Input signal (sinusoid to be tracked)
input_signal = sin(2*pi*f_signal*t+pi/2);

%% PLL parameters
Kp = 2;                % Proportional gain
Ki = 10;               % Integral gain

% Initialize loop
N = length(t);
phase_error = zeros(1, N);
vco_output = zeros(1, N);
vco_phase = zeros(1, N);
control_signal = zeros(1, N);
integrator = 0;
vco_freq = f_vco_init;

%% PLL Loop
for n = 2:N
    % Generate VCO output
    vco_output(n) = sin(2*pi*vco_phase(n-1));
    
    % Phase Detector (Multiply input and VCO output)
    phase_error(n) = input_signal(n) * vco_output(n);
    
    % Loop Filter (PI Controller)
    integrator = integrator + Ki * phase_error(n) * T;
    control_signal(n) = Kp * phase_error(n) + integrator;
    
    % Update VCO frequency (Control voltage)
    vco_freq = f_vco_init + control_signal(n);  % VCO gain assumed 1 Hz/V
    
    % Integrate to get VCO phase
    vco_phase(n) = vco_phase(n-1) + vco_freq*T;
end

%% Plot Results
figure;
subplot(3,1,1);
plot(t, input_signal, t, vco_output);
title('Input Signal and VCO Output');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Input', 'VCO');

subplot(3,1,2);
plot(t, phase_error);
title('Phase Detector Output');
xlabel('Time (s)'); ylabel('Error');

subplot(3,1,3);
plot(t, control_signal);
title('Loop Filter Output (Control Voltage)');
xlabel('Time (s)'); ylabel('Control Signal');
