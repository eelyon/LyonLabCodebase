%% Script for cleaning all channels - GF 2026/10/30
% Cleaning params
vhigh = +4;
vlow = -1;
numSteps = 10;
tm_volts = -2; % Top metal voltage during clean
repeats = 5; % Repeat cleaning procedure number of times

% MFLI params
check = 0; % If 1, script checks if ccds are cleaned and measures Sense1 & Sense2
vstart = 0;
vstop = -1.5;
vstep = 0.1;
tc = 0.3;
drat = 10e3;

% Set Sommer-Tanner positive to suck electrons in
rampDACVolts(pinout.stm.device, pinout.stm.port, +1, numSteps)
rampDACVolts(pinout.std.device, pinout.std.port, +1, numSteps, pinout.std.dwell)
rampDACVolts(pinout.sts.device, pinout.sts.port, +1, numSteps, pinout.sts.dwell)

for i = 1:repeats
    %% Set 1st twiddle-sense for top metal sweep
    rampDACVolts(pinout.d5.device, pinout.d5.port, vhigh, numSteps, pinout.d5.dwell)
    rampDACVolts(pinout.sense1_l.device, pinout.sense1_l.port, vhigh, numSteps)
    rampDACVolts(pinout.guard1_l.device, pinout.guard1_l.port, vhigh, numSteps, pinout.guard1_l.dwell)
    rampDACVolts(pinout.twiddle1.device, pinout.twiddle1.port, vhigh, numSteps, pinout.twiddle1.dwell)
    rampDACVolts(pinout.guard1_r.device, pinout.guard1_r.port, vhigh, numSteps)
    rampDACVolts(pinout.sense1_r.device, pinout.sense1_r.port, vhigh, numSteps)
    rampDACVolts(pinout.d6.device, pinout.d6.port, vhigh, numSteps)
    
    % Sweep top metal
    rampDACVolts(pinout.tm.device, pinout.tm.port, tm_volts-1, 100, pinout.tm.dwell*10); delay(100e-3)
    rampDACVolts(pinout.tm.device, pinout.tm.port, tm_volts, 100, pinout.tm.dwell*10); delay(100e-3)
    
    % Move electrons to phi_v_2
    rampDACVolts(pinout.d5.device, pinout.d5.port, vlow, numSteps, pinout.d5.dwell)
    rampDACVolts(pinout.sense1_l.device, pinout.sense1_l.port, vlow, numSteps)
    rampDACVolts(pinout.guard1_l.device, pinout.guard1_l.port, vlow, numSteps, pinout.guard1_l.dwell)
    rampDACVolts(pinout.twiddle1.device, pinout.twiddle1.port, vlow, numSteps, pinout.twiddle1.dwell)
    rampDACVolts(pinout.guard1_r.device, pinout.guard1_r.port, vlow, numSteps)
    rampDACVolts(pinout.sense1_r.device, pinout.sense1_r.port, vlow, numSteps)
    rampDACVolts(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
    rampDACVolts(pinout.d6.device, pinout.d6.port, vlow, numSteps)
    rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    rampDACVolts(pinout.d4.device, pinout.d4.port, vlow, numSteps)
    rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
    rampDACVolts(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
    rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    rampDACVolts(pinout.d4.device, pinout.d4.port, vlow, numSteps)

    rampDACVolts(pinout.phi_v_2.device, pinout.phi_v_2.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)

    empty_ccd_h1(pinout, numSteps, vhigh, vlow)

    rampDACVolts(pinout.phi_v_1.device, pinout.phi_v_1.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_v_2.device, pinout.phi_v_2.port, vlow, numSteps)
    rampDACVolts(pinout.phi_v_3.device, pinout.phi_v_3.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_v_1.device, pinout.phi_v_1.port, vlow, numSteps)

    for j = 1:81
        rampDACVolts(pinout.phi_v_1.device,pinout.phi_v_1.port,vhigh,numSteps)
        rampDACVolts(pinout.phi_v_2.device,pinout.phi_v_2.port,vlow,numSteps)
        rampDACVolts(pinout.phi_v_3.device,pinout.phi_v_3.port,vhigh,numSteps)
        rampDACVolts(pinout.phi_v_1.device,pinout.phi_v_1.port,vlow,numSteps)
        rampDACVolts(pinout.phi_v_2.device,pinout.phi_v_2.port,vhigh,numSteps)
        rampDACVolts(pinout.phi_v_3.device,pinout.phi_v_3.port,vlow,numSteps)
        empty_ccd_h1(pinout,numSteps,vhigh,vlow)
    end

    %% Empty 2nd horizontal ccd and move to phi_v_2
    rampDACVolts(pinout.trap4.device,pinout.trap4.port,vhigh,numSteps)
    rampDACVolts(pinout.trap2.device,pinout.trap2.port,vhigh,numSteps)
    rampDACVolts(pinout.d10.device,pinout.d10.port,vhigh,numSteps)
    rampDACVolts(pinout.trap4.device,pinout.trap4.port,-2,numSteps)
    rampDACVolts(pinout.trap2.device,pinout.trap2.port,vlow,numSteps)
    rampDACVolts(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
    rampDACVolts(pinout.d10.device,pinout.d10.port,vlow,numSteps)
    
    for k = 1:22
        rampDACVolts(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vhigh,numSteps)
        rampDACVolts(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)
        rampDACVolts(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vhigh,numSteps)
        rampDACVolts(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
        rampDACVolts(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
        rampDACVolts(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
    end
    
    rampDACVolts(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)
    rampDACVolts(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
    rampDACVolts(pinout.d9.device,pinout.d9.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
    rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
    rampDACVolts(pinout.d9.device,pinout.d9.port,vlow,numSteps)
    rampDACVolts(pinout.d8.device,pinout.d8.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
    rampDACVolts(pinout.sense2_r.device,pinout.sense2_r.port,vhigh,numSteps)
    rampDACVolts(pinout.d8.device,pinout.d8.port,vlow,numSteps,waitTimeRC)
    rampDACVolts(pinout.guard2_r.device,pinout.guard2_r.port,vhigh,numSteps)
    rampDACVolts(pinout.twiddle2.device,pinout.twiddle2.port,vhigh,numSteps,pinout.twiddle2.dwell)
    rampDACVolts(pinout.guard2_l.device,pinout.guard2_l.port,vhigh,numSteps,pinout.guard2_l.dwell)
    rampDACVolts(pinout.sense2_l.device,pinout.sense2_l.port,vhigh,numSteps)
    rampDACVolts(pinout.sense2_r.device,pinout.sense2_r.port,vlow,numSteps)
    rampDACVolts(pinout.guard2_r.device,pinout.guard2_r.port,vlow,numSteps)

    rampDACVolts(pinout.twiddle2.device,pinout.twiddle2.port,vlow,numSteps,pinout.twiddle2.dwell)
    rampDACVolts(pinout.guard2_l.device,pinout.guard2_l.port,vlow,numSteps,pinout.guard2_l.dwell)
    rampDACVolts(pinout.d7.device, pinout.d7.port, vhigh, numSteps, pinout.d7.dwell)
    rampDACVolts(pinout.sense2_l.device, pinout.sense2_l.port, vlow, numSteps)
    rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    rampDACVolts(pinout.d7.device, pinout.d7.port, vlow, numSteps, pinout.d7.dwell)
    rampDACVolts(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
    rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
    rampDACVolts(pinout.d4.device, pinout.d4.port, vlow, numSteps)
    rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
    rampDACVolts(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
    rampDACVolts(pinout.d4.device, pinout.d4.port, vlow, numSteps)
    
    % Reset Sense2
    rampDACVolts(pinout.guard2_r.device,pinout.guard2_r.port,-2,numSteps)
    rampDACVolts(pinout.twiddle2.device, pinout.twiddle2.port, 0, numSteps, pinout.twiddle2.dwell)
    rampDACVolts(pinout.guard2_l.device, pinout.guard2_l.port, 0, numSteps, pinout.guard2_l.dwell)
    rampDACVolts(pinout.sense2_l.device, pinout.sense2_l.port, 0, numSteps)
    rampDACVolts(pinout.d7.device, pinout.d7.port, -2, numSteps, pinout.d7.dwell)
    
    for j = 1:75 % Double check if this is correct
        rampDACVolts(pinout.phi_v_1.device,pinout.phi_v_1.port,vhigh,numSteps)
        rampDACVolts(pinout.phi_v_2.device,pinout.phi_v_2.port,vlow,numSteps)
        rampDACVolts(pinout.phi_v_3.device,pinout.phi_v_3.port,vhigh,numSteps)
        rampDACVolts(pinout.phi_v_1.device,pinout.phi_v_1.port,vlow,numSteps)
        rampDACVolts(pinout.phi_v_2.device,pinout.phi_v_2.port,vhigh,numSteps)
        rampDACVolts(pinout.phi_v_3.device,pinout.phi_v_3.port,vlow,numSteps)
    end
    empty_ccd_h1(pinout, numSteps, vhigh, vlow)
    
    % Reset Sense1
    rampDACVolts(pinout.guard1_r.device, pinout.guard1_r.port, -2, numSteps)
    rampDACVolts(pinout.twiddle1.device, pinout.twiddle1.port, 0, numSteps, pinout.twiddle1.dwell)
    rampDACVolts(pinout.guard1_l.device, pinout.guard1_l.port, 0, numSteps, pinout.guard1_l.dwell)
    rampDACVolts(pinout.sense1_l.device, pinout.sense1_l.port, 0, numSteps)
    rampDACVolts(pinout.d5.device, pinout.d5.port, -2, numSteps, pinout.d5.dwell)
    fprintf([num2str(i), '\n']);
end

% Reset Sommer-Tanner
rampDACVolts(pinout.stm.device, pinout.stm.port, 0, numSteps)
rampDACVolts(pinout.std.device, pinout.std.port, 0, numSteps)
rampDACVolts(pinout.sts.device, pinout.sts.port, 0, numSteps)
delay(1)

if check == 1
    % Check if stray electrons are in parallel channels of sense 1
    rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps)
    rampDACVolts(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
    rampDACVolts(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
    rampDACVolts(pinout.d5.device,pinout.d5.port,vhigh,numSteps,pinout.d5.dwell)
    rampDACVolts(pinout.d4.device,pinout.d4.port,vlow,numSteps)
    rampDACVolts(pinout.d5.device,pinout.d5.port,-2,numSteps,pinout.d5.dwell)
    delay(100e-3)
    
    MFLISweep1D_getSample({'Guard1'}, vstart, vstop, vstep, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat);
    rampDACVolts(pinout.guard1_l.device, pinout.guard1_l.port, 0, numSteps, waitTimeRC); delay(1)
    
    MFLISweep1D_getSample({'Guard2'}, vstart, vstop, vstep, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat);
    rampDACVolts(pinout.guard2_l.device, pinout.guard2_l.port, 0, numSteps, waitTimeRC)
    
    % Check if electrons are in horizontal CCD
    loadSense1(pinout,vlow);
    MFLISweep1D_getSample({'Guard1'}, vstart, vstop, vstep, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat);
    rampDACVolts(pinout.guard1_l.device, pinout.guard1_l.port, 0, numSteps, waitTimeRC); delay(1)
    
    % Check if electrons are in vertical CCD
    shuttleSense1Sense2(pinout);
    MFLISweep1D_getSample({'Guard2'}, vstart, vstop, vstep, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat);
    rampDACVolts(pinout.guard2_l.device, pinout.guard2_l.port, 0, numSteps, waitTimeRC)
end

function empty_ccd_h1(pinout, numSteps, vhigh, vlow)
% Move electrons from phi_v_2 to Sommer-Tanner
rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
rampDACVolts(pinout.phi_v_2.device, pinout.phi_v_2.port, vlow, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vlow, numSteps)
rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
rampDACVolts(pinout.d6.device, pinout.d6.port, vhigh, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vlow, numSteps)
rampDACVolts(pinout.sense1_r.device, pinout.sense1_r.port, vhigh, numSteps)
rampDACVolts(pinout.d6.device, pinout.d6.port, vlow, numSteps)
rampDACVolts(pinout.guard1_r.device, pinout.guard1_r.port, vhigh, numSteps)
rampDACVolts(pinout.twiddle1.device, pinout.twiddle1.port, vhigh, numSteps, pinout.twiddle1.dwell)
rampDACVolts(pinout.guard1_l.device, pinout.guard1_l.port, vhigh, numSteps, pinout.guard1_l.dwell)
rampDACVolts(pinout.sense1_r.device, pinout.sense1_r.port, vlow, numSteps)
rampDACVolts(pinout.sense1_l.device, pinout.sense1_l.port, vhigh, numSteps)
rampDACVolts(pinout.guard1_r.device, pinout.guard1_r.port, vlow, numSteps)
rampDACVolts(pinout.twiddle1.device, pinout.twiddle1.port, vlow, numSteps, pinout.twiddle1.dwell)
rampDACVolts(pinout.guard1_l.device, pinout.guard1_l.port, vlow, numSteps, pinout.guard1_l.dwell)

rampDACVolts(pinout.d5.device, pinout.d5.port, vhigh, numSteps, pinout.d5.dwell)
rampDACVolts(pinout.sense1_l.device, pinout.sense1_l.port, vlow, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
rampDACVolts(pinout.d5.device, pinout.d5.port, vlow, numSteps, pinout.d5.dwell)
rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vlow+(tm_volts-vlow)/2, numSteps) % Set d4 s.t. electrons can't get onto top metal in parallel channels

% Move electrons on phi_h1_1 back to Sommer-Tanner
ccd_units = 64; % number of repeating units in ccd array
for n = 1:ccd_units
    rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
    rampDACVolts(pinout.phi_h1_2.device, pinout.phi_h1_2.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
    rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
    rampDACVolts(pinout.phi_h1_2.device, pinout.phi_h1_2.port, vlow, numSteps)
end

% Unload ccd
rampDACVolts(pinout.d3.device, pinout.d3.port, vhigh, numSteps)
rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
rampDACVolts(pinout.d2.device, pinout.d2.port, vhigh, numSteps)
rampDACVolts(pinout.d3.device, pinout.d3.port, vlow, numSteps)
rampDACVolts(pinout.d1_even.device, pinout.d1_even.port, vhigh, numSteps)
rampDACVolts(pinout.d2.device, pinout.d2.port, vlow, numSteps)
rampDACVolts(pinout.d1_even.device, pinout.d1_even.port, vlow, numSteps)

% Move electrons in closed-off channels from phi_h1_1 to phi_v_2
rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
rampDACVolts(pinout.d5.device, pinout.d5.port, vhigh, numSteps, pinout.d5.dwell)
rampDACVolts(pinout.d4.device, pinout.d4.port, vlow, numSteps)
rampDACVolts(pinout.sense1_l.device, pinout.sense1_l.port, vhigh, numSteps)
rampDACVolts(pinout.d5.device, pinout.d5.port, vlow, numSteps, pinout.d5.dwell)
rampDACVolts(pinout.guard1_l.device, pinout.guard1_l.port, vhigh, numSteps, pinout.guard1_l.dwell)
rampDACVolts(pinout.twiddle1.device, pinout.twiddle1.port, vhigh, numSteps, pinout.twiddle1.dwell)
rampDACVolts(pinout.guard1_r.device, pinout.guard1_r.port, vhigh, numSteps)
rampDACVolts(pinout.sense1_l.device, pinout.sense1_l.port, vlow, numSteps)
rampDACVolts(pinout.sense1_r.device, pinout.sense1_r.port, vhigh, numSteps)
rampDACVolts(pinout.guard1_l.device, pinout.guard1_l.port, vlow, numSteps, pinout.guard1_l.dwell)
rampDACVolts(pinout.twiddle1.device, pinout.twiddle1.port, vlow, numSteps, pinout.twiddle1.dwell)
rampDACVolts(pinout.guard1_r.device, pinout.guard1_r.port, vlow, numSteps)
rampDACVolts(pinout.d6.device, pinout.d6.port, vhigh, numSteps)
rampDACVolts(pinout.sense1_r.device, pinout.sense1_r.port, vlow, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
rampDACVolts(pinout.d6.device, pinout.d6.port, vlow, numSteps)
rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vlow, numSteps)
rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
rampDACVolts(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
rampDACVolts(pinout.d4.device, pinout.d4.port, vlow, numSteps)

rampDACVolts(pinout.phi_v_2.device, pinout.phi_v_2.port, vhigh, numSteps)
rampDACVolts(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
end