% Script for cleaning all channels
repeats = 5;
numSteps = 5;
numStepsRC = 5;
waitTimeRC = 1100;
vopen = 3;
vclose = -1;

start_vgd = 0.1;
stop_vgd = -0.8;
step_vgd = 0.05;
tc = 0.03;
drat = 13e3;
poll = 0.3;

for i = 1:repeats
    % Set Sommer-Tanner positive to suck electrons in
    sigDACRampVoltage(pinout.stm.device, pinout.stm.port, +2, numSteps)
    sigDACRampVoltage(pinout.std.device, pinout.std.port, +2, numSteps)
    sigDACRampVoltage(pinout.sts.device, pinout.sts.port, +2, numSteps)
    
    %% Set 1st twiddle-sense for top metal sweep
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
    sigDACRamp(pinout.d5.device, pinout.d5.port, vopen, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vopen, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vopen, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vopen, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vopen, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vopen, numSteps)
    
    % Sweep top metal
    sigDACRamp(pinout.tm.device, pinout.tm.port, -2, numStepsRC, 15000); delay(1)
    sigDACRamp(pinout.tm.device, pinout.tm.port, -1.2, numStepsRC, waitTimeRC)
    
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vclose, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vclose, numSteps)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vclose, numSteps)
    
    empty_sense1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose); % Empty 6x twiddle-sense 1
    
    %% Move electrons onto vertical CCD
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vopen, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vopen, numSteps)
    sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vclose, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vclose, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vclose, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vclose, numSteps)
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vopen, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vclose, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,  pinout.phi_h1_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps) % Electrons on phi_h1_3
    
    % Open gates to let electrons onto vertical CCD
    sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_v2_2.device, pinout.phi_v2_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
    
    % Add bit for emptying out channels beyond twiddle-sense 2
    % Can park electrons on d_2_Vup
%     sigDACRampVoltage(phi_v2_1.device,phi_v2_1.port,vopen,numSteps)
%     sigDACRampVoltage(phi_v1_3.device,phi_v1_3.port,vclose,numSteps)

    for j = 1:3
        sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vclose,numSteps)
        sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vclose,numSteps)
        sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vclose,numSteps)
    end

    sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vclose,numSteps)
    sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vclose,numSteps) % e are on d_v_2

    %% Empty 2nd horizontal ccd and move to d_v_2
    sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,vopen,numSteps)
    sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vopen,numSteps)
    sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,-2,numSteps)
    sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vclose,numSteps)
    
    for k = 1:22
        sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
        sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
        sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
    end
    
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
    sigDACRamp(pinout.d9.device,pinout.d9.port,vopen,numStepsRC,waitTimeRC)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
    sigDACRamp(pinout.d9.device,pinout.d9.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.d8.device,pinout.d8.port,vopen,numStepsRC,waitTimeRC)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
    sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vopen,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.d8.device,pinout.d8.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vopen,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)

    % Reset sense 2 to measure stray electrons in 2nd horizontal ccd
    sigDACRamp(pinout.d7.device, pinout.d7.port, -2, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
    delay(2)
    
%     MFLISweep1D({'Guard2'}, start_vgd, stop_vgd, step_vgd, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, ...
%         'time_constant', tc, 'demod_rate', drat, 'poll_duration', poll);
%     sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)

    sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.d7.device, pinout.d7.port, vopen, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, vclose, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
    sigDACRamp(pinout.d7.device, pinout.d7.port, vclose, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
%     sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
    
    % Reset twiddle-sense 2
    sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.d7.device, pinout.d7.port, -2, numStepsRC, waitTimeRC)
    delay(2)
    
%     MFLISweep1D({'Guard2'}, start_vgd, stop_vgd, step_vgd, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, ...
%         'time_constant', tc, 'demod_rate', drat, 'poll_duration', poll);
%     sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)

    sigDACRampVoltage(pinout.d_v_1.device, pinout.d_v_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d_v_1.device, pinout.d_v_1.port, vclose, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port,
%     vopen, numSteps) % already open from earlier
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
    
    % Move electrons up
    for l = 1:76
        empty_ccd1(pinout, numSteps,  numStepsRC,  waitTimeRC,  vopen,  vclose)
        sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vopen, numSteps)
        sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)
        sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
        sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vclose, numSteps)
        sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
        sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
%         fprintf([num2str(l), ' '])
    end
%     fprintf('\n')

    empty_ccd1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
    
    % Reset twiddle-sense1
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, -2, numSteps)
    sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.d5.device, pinout.d5.port, -2, numStepsRC, waitTimeRC)

    % Reset Sommer-Tanner
    sigDACRampVoltage(pinout.stm.device, pinout.stm.port, 0, numSteps)
    sigDACRampVoltage(pinout.std.device, pinout.std.port, 0, numSteps)
    sigDACRampVoltage(pinout.sts.device, pinout.sts.port, 0, numSteps)
    fprintf([num2str(i), '\n']);
end
delay(2);

% Check if any electrons remain in either twiddle-sense
MFLISweep1D({'Guard1'}, start_vgd, stop_vgd, step_vgd, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, ...
    'time_constant', tc, 'demod_rate', drat, 'poll_duration', poll);
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC); delay(1)

MFLISweep1D({'Guard2'}, start_vgd, stop_vgd, step_vgd, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, ...
    'time_constant', tc, 'demod_rate', drat, 'poll_duration', poll);
sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)

function empty_sense1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
% Unload sense 1
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, -1.6, numSteps)

% Move electrons on phi_h1_1 back to Sommer-Tanner through horizontal ccd
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_h1_2.device, pinout.phi_h1_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_2.device, pinout.phi_h1_2.port, vclose, numSteps)
end

% Unload ccd
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vopen, numSteps)
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vclose, numSteps)
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vopen, numSteps)
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vclose, numSteps)

% Reset twiddle-sense, move stray electrons from d4 back to sense1_l
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vopen, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, 0, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, 0, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, -2, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, -2, numSteps)
end

function empty_ccd1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
% Move electrons from phi_v1_2 to Somer-Tanner
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vopen, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vclose, numSteps)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vopen, numSteps)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vopen, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vclose, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vopen, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vclose, numSteps)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose-0.8, numSteps) % Set d4 s.t. electrons can't get onto top metal in parallel channels

% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_h1_2.device, pinout.phi_h1_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_h1_2.device, pinout.phi_h1_2.port, vclose, numSteps)
end

% Unload ccd
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vopen, numSteps)
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vclose, numSteps)
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vopen, numSteps)
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vclose, numSteps)

% Move electrons in closed off channels from d4 to phi_v1_2
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vopen, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vopen, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device, pinout.twiddle1.port, vopen, numSteps)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vopen, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vopen, numSteps)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vclose, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vopen, numSteps)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)

sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_v2_2.device, pinout.phi_v2_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vclose, numSteps)
end