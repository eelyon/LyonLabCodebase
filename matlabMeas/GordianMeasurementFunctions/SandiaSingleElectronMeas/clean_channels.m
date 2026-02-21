%% Script for cleaning all channels
vopen = 3;
vclose = -1;

repeats = 5;
numSteps = 2;
numStepsRC = 2;
waitTimeRC = 1100;

% vstart = 0;
% vstop = -1.5;
% vstep = 0.1;
% tc = 0.3;
% drat = 10e3;

% Set Sommer-Tanner positive to suck electrons in
sigDACRampVoltage(pinout.stm.device, pinout.stm.port, +2, numSteps)
sigDACRampVoltage(pinout.std.device, pinout.std.port, +2, numSteps)
sigDACRampVoltage(pinout.sts.device, pinout.sts.port, +2, numSteps)

for i = 1:repeats    
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
    sigDACRamp(pinout.tm.device, pinout.tm.port, -3, numStepsRC, 15000); delay(2)
    sigDACRamp(pinout.tm.device, pinout.tm.port, -2, numStepsRC, waitTimeRC)
    
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vclose, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vclose, numSteps)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vclose, numSteps)
    
    % unloadSense1(pinout,'vopen',vopen,'vclose',vclose)
    % sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps) % open ccd1
    % sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps) % close door
    % sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
    % sigDACRamp(pinout.d5.device,pinout.d5.port,vopen,numStepsRC,waitTimeRC) % open door
    % sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps) % close door
    % sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vopen, numStepsRC, waitTimeRC)
    % sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
    % sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, 0, numStepsRC, waitTimeRC)

    empty_sense1(pinout,numSteps,numStepsRC,waitTimeRC,vopen,vclose); % Empty 6x twiddle-sense 1
    
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
        sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vclose,numSteps)
        sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vclose,numSteps)
        sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vclose,numSteps)
    end

    sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vclose,numSteps)
    % sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vclose,numSteps) % E are on d_v_2

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
    sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vclose,numStepsRC,waitTimeRC)

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
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
    
    % Reset Sense2
    sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.d7.device, pinout.d7.port, -2, numStepsRC, waitTimeRC)

    sigDACRampVoltage(pinout.d_v_1.device, pinout.d_v_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d_v_1.device, pinout.d_v_1.port, vclose, numSteps)
    % sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
    % sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
    
    % Move electrons up
%     for l = 1:76
%         empty_ccd_h1(pinout, numSteps,  numStepsRC,  waitTimeRC,  vopen,  vclose)
%         sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vopen, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vclose, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
% %         fprintf([num2str(l), ' '])
%     end
%     fprintf('\n')
    for j = 1:75
        sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vclose,numSteps)
        empty_ccd_h1(pinout,numSteps,numStepsRC,waitTimeRC,vopen,vclose)
        sigDACRampVoltage(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vclose,numSteps)
        sigDACRampVoltage(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vclose,numSteps)
    end
    
    sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vclose,numSteps)

    empty_ccd_h1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
    
    % Reset Sense1
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, -2, numSteps)
    sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.d5.device, pinout.d5.port, -2, numStepsRC, waitTimeRC)
    fprintf([num2str(i), '\n']);
end

% Reset Sommer-Tanner
sigDACRampVoltage(pinout.stm.device, pinout.stm.port, +0.5, numSteps)
sigDACRampVoltage(pinout.std.device, pinout.std.port, +0.5, numSteps)
sigDACRampVoltage(pinout.sts.device, pinout.sts.port, +0.5, numSteps)
delay(1)

% Check if stray electrons are in parallel channels of sense 1
% sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps)
% sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
% sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
% sigDACRamp(pinout.d5.device,pinout.d5.port,vopen,numStepsRC,waitTimeRC)
% sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
% sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
% delay(1)

% MFLISweep1D_getSample({'Guard1'}, vstart, vstop, vstep, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, ...
%     'time_constant', tc, 'demod_rate', drat);
% sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC); delay(1)
% 
% % Check if electrons are in horizontal CCD
% loadSense1(pinout,vclose);
% MFLISweep1D_getSample({'Guard1'}, vstart, vstop, vstep, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, ...
%     'time_constant', tc, 'demod_rate', drat);
% sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC); delay(1)
% 
% % Check if electrons are in vertical CCD
% shuttleSense1Sense2(pinout);
% MFLISweep1D_getSample({'Guard2'}, vstart, vstop, vstep, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, ...
%     'time_constant', tc, 'demod_rate', drat);
% sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)

function empty_sense1(pinout,numSteps,numStepsRC,waitTimeRC,vopen,vclose)
% Unload Sense1
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port,vclose-0.5, numSteps)

% Move electrons on phi_h1_1 back to Sommer-Tanner through horizontal ccd
ccd_units = 64; % number of repeating units in ccd array
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
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vclose, numSteps)
end

function empty_ccd_h1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
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
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose-0.5, numSteps) % Set d4 s.t. electrons can't get onto top metal in parallel channels

% Move electrons on CCD3 back to ST through CCD
ccd_units = 64; % number of repeating units in ccd array
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
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vclose, numSteps)
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