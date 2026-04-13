function y = computeStaircasePulse(freq, sr, shiftFactor)
    T = 1/freq;
    pts = round(T * sr);
    t = linspace(0, T, pts);
    
    % --- Configuration ---
    pw = T * 0.5;                % 50% duty cycle
    stepTime = T * 0.05;         % Duration of each intermediate plateau
    t_pulse = t - (shiftFactor * T);
    y = zeros(size(t));
    
    % Define the "Up" sequence logic
    % 0 -> Step 1 (0.33) -> Step 2 (0.66) -> High (1.0)
    
    % Rise to Step 1
    idx1 = t_pulse >= 0 & t_pulse < stepTime;
    y(idx1) = 0.33;
    
    % Rise to Step 2
    idx2 = t_pulse >= stepTime & t_pulse < 2*stepTime;
    y(idx2) = 0.66;
    
    % High Plateau
    idxH = t_pulse >= 2*stepTime & t_pulse < (pw - 2*stepTime);
    y(idxH) = 1.0;
    
    % Fall to Step 2
    f1_start = pw - 2*stepTime;
    idx3 = t_pulse >= f1_start & t_pulse < (pw - stepTime);
    y(idx3) = 0.66;
    
    % Fall to Step 1
    f2_start = pw - stepTime;
    idx4 = t_pulse >= f2_start & t_pulse < pw;
    y(idx4) = 0.33;
    
    % Result: A pulse with a "staircase" on both sides.
end