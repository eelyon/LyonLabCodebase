%AlazockIn Functions

function signal = square_wave(frequency, t, phase)
    % Generate a square wave
    % Inputs:
    % - frequency: Frequency of the square wave (in Hz)
    % - t: Time vector
    % - phase: Phase shift in radians

    % Create the argument for the square wave
    arg = 2 * pi * frequency * t + phase;
    
    % Generate the square wave
    signal = sign(sin(arg));
end

function [t, signal] = util_noisyGenInp(fL, ppc, tf, VL, thL, magNoise)
    % Time vector
    dt = 1 / (fL * ppc);
    t = 0:dt:tf;

    % Square wave generation
    signal = VL * square_wave(fL, t, deg2rad(thL));

    % Add noise
    signal = signal + magNoise * randn(size(signal));
end


function allpass_output = allpass_filter(input_signal, break_frequency, sampling_rate)
    allpass_output = zeros(size(input_signal)); % Initialize the output array
    dn_1 = 0; % Initialize buffer
    a1 = a1_coefficient(break_frequency, sampling_rate);
    
    for n = 1:length(input_signal)
        allpass_output(n) = a1 * input_signal(n) + dn_1; % The allpass difference equation
        dn_1 = input_signal(n) - a1 * allpass_output(n); % Store a value in the buffer for the next iteration
    end
end

function a1 = a1_coefficient(break_frequency, sampling_rate)
    tan_val = tan(pi * break_frequency / sampling_rate);
    a1 = (tan_val - 1) / (tan_val + 1);
end

function filter_output = lowpass_apb_filter(input_signal, cutoff_frequency, sampling_rate)
    allpass_output = allpass_filter(input_signal, cutoff_frequency, sampling_rate);
    filter_output = 0.5 * (input_signal + allpass_output); % Sum and scale
end

function filter_output = highpass_apb_filter(input_signal, cutoff_frequency, sampling_rate)
    allpass_output = allpass_filter(input_signal, cutoff_frequency, sampling_rate);
    filter_output = 0.5 * (input_signal - allpass_output); % Subtract and scale
end

function output_signal = double_lowpass_apb_filter(input_signal, cutoff_frequency, sampling_rate)
    output_signal = lowpass_apb_filter(input_signal, cutoff_frequency, sampling_rate);
    output_signal = lowpass_apb_filter(output_signal, cutoff_frequency, sampling_rate);
end

function output_signal = nth_lowpass_apb_filter(input_signal, cutoff_frequency, sampling_rate, n)
    if n == 1
        output_signal = lowpass_apb_filter(input_signal, cutoff_frequency, sampling_rate);
    else
        output_signal = nth_lowpass_apb_filter(lowpass_apb_filter(input_signal, cutoff_frequency, sampling_rate), cutoff_frequency, sampling_rate, n-1);
    end
end

function [t, psdi, psdq] = lockInBehavior(t, sqL, fL, fcut, stages, inp)
    dt = t(2) - t(1);
    ppc = round(1 / (dt * fL));
    fs = fL * ppc;

    % Trim the time vector and sqL for phase alignment
    t = t(1:end - floor(ppc / 4) - 1);
    sqLq = sqL((floor(ppc / 4) + 1):end);
    sqL = sqL(1:end - floor(ppc / 4) - 1);
    inp = inp(1:length(t)); % Trim inp to match the length of t

    % Ensure sqLq matches the size of inp for element-wise multiplication
    sqLq = sqLq(1:length(inp));

    ampl = (max(sqL) - min(sqL)) / 2;

    % Compute the filtered signals
    psdi = nth_lowpass_apb_filter(sqL .* inp, fcut, fs, stages) / ampl;
    psdq = nth_lowpass_apb_filter(sqLq .* inp, fcut, fs, stages) / ampl;
end