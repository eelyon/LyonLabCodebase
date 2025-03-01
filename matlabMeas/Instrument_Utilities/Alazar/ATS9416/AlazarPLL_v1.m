% Parameters
fs = 1e4;                % Sampling frequency (Hz)
T = 1;                   % Time duration (seconds)
t = 0:1/fs:T-1/fs;       % Time vector
f_ref = 100;             % Frequency of reference signal (Hz)
f_vco = 100;             % Initial frequency of VCO (Hz)

% Reference signal
ref_signal = sqrt(2)*sin(2*pi*f_ref*t+0.5);  % Reference sine wave

% Initialize the VCO (start with a phase offset)
vco_phase = 0; 
vco_signal = sin(2*pi*f_vco*t + vco_phase);

% PLL parameters (tuning constants)
Kp = 1e-2;  % Proportional gain
Ki = 1e-4;  % Integral gain

% Phase error (Initial phase difference)
phase_error = 0;

% Loop filter integrator (to control the VCO)
integrator = 0;

% Plot the signals
figure;
subplot(3,1,1);
plot(t, ref_signal);
title('Reference Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Run the PLL loop
for i = 2:length(t)
    % Phase detector: XOR (simplified to phase difference)
    phase_error = ref_signal(i) - vco_signal(i-1);
    
    % Loop filter: Simple Integrator (Low-pass filter)
    integrator = integrator + phase_error * Ki * (t(i) - t(i-1)) + Kp * phase_error;
    
    % VCO update (with integrator as frequency control input)
    vco_phase = 2*pi*f_vco*t(i) + integrator;
    vco_signal(i) = sin(vco_phase);
    
end

% Plot the VCO output
subplot(3,1,2);
plot(t, vco_signal);
title('VCO Output');
xlabel('Time (s)');
ylabel('Amplitude');

% Plot phase error over time
subplot(3,1,3);
plot(t, ref_signal - vco_signal);
title('Phase Error');
xlabel('Time (s)');
ylabel('Phase Error');
