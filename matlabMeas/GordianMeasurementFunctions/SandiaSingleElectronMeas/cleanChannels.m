function [] = cleanChannels(pinout,repeats,sense1,sense2,options)
%CLEANCHANNELS Cleaning all channels after emission
%   Detailed explanation goes here
arguments (Input)
    pinout
    repeats    (1,1) double {mustBeInteger, mustBeGreaterThanOrEqual(repeats, 1), mustBeLessThan(repeats, 20)}
    sense1     (1,1) double {mustBeMember(sense1, [0 1])}
    sense2     (1,1) double {mustBeMember(sense2, [0 1])}
    options.vhigh      (1,1) double                                    = 3.0
    options.vlow       (1,1) double                                    = -1.0
    options.numSteps   (1,1) double {mustBeNumeric, mustBePositive}    = 2
    options.numStepsRC (1,1) double {mustBeNumeric, mustBePositive}    = 2
    options.waitTimeRC (1,1) double {mustBeInRange(options.waitTimeRC, 40, 16383)} = 1100
    options.biasST     (1,1) double                                    = 2.0
end

vhigh      = options.vhigh;
vlow       = options.vlow;
numSteps   = options.numSteps;
numStepsRC = options.numStepsRC;
waitTimeRC = options.waitTimeRC;
biasST     = options.biasST;

%% MFLI parameters
vstart = 0.2;
vstop = -1.5;
vstep = -0.1;
tc = 0.2;
drat = 10e3;

vstm = sigDACQueryVoltage(pinout.stm.device, pinout.stm.port);
vstd = sigDACQueryVoltage(pinout.std.device, pinout.std.port);
vsts = sigDACQueryVoltage(pinout.sts.device, pinout.sts.port);
vtm = sigDACQueryVoltage(pinout.tm.device, pinout.tm.port);

% Set Sommer-Tanner positive to suck electrons in
sigDACRampVoltage(pinout.stm.device, pinout.stm.port, biasST, numSteps)
sigDACRampVoltage(pinout.std.device, pinout.std.port, biasST, numSteps)
sigDACRampVoltage(pinout.sts.device, pinout.sts.port, biasST, numSteps)

for i = 1:repeats    
    %% Set 1st twiddle-sense for top metal sweep
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
    sigDACRamp(pinout.d5.device, pinout.d5.port, vhigh, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vhigh, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vhigh, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vhigh, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vhigh, numSteps)
    
    % Sweep top metal
    sigDACRamp(pinout.tm.device, pinout.tm.port, -3, 100, 15000); delay(0.1)
    sigDACRamp(pinout.tm.device, pinout.tm.port, vtm, 100, 15000)
    
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vlow, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vlow, numSteps)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vlow, numSteps)
    
    % unloadSense1(pinout,'vhigh',vhigh,'vlow',vlow)
    % sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps) % open ccd1
    % sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vhigh,numSteps) % close door
    % sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
    % sigDACRamp(pinout.d5.device,pinout.d5.port,vhigh,numStepsRC,waitTimeRC) % open door
    % sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vlow,numSteps) % close door
    % sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vhigh, numStepsRC, waitTimeRC)
    % sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
    % sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, 0, numStepsRC, waitTimeRC)

    empty_sense1(pinout,numSteps,numStepsRC,waitTimeRC,vhigh,vlow); % Empty 6x twiddle-sense 1
    
    %% Move electrons onto vertical CCD
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vhigh, numSteps)
    sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vlow, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vlow, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vlow, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vlow, numSteps)
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vlow, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,  pinout.phi_h1_3.port, vlow, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps) % Electrons on phi_h1_3
    
    % Open gates to let electrons onto vertical CCD
    sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_v2_2.device, pinout.phi_v2_2.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
    
    % Add bit for emptying out channels beyond twiddle-sense 2
    % Can park electrons on d_2_Vup
%     sigDACRampVoltage(phi_v2_1.device,phi_v2_1.port,vhigh,numSteps)
%     sigDACRampVoltage(phi_v1_3.device,phi_v1_3.port,vlow,numSteps)

    for j = 1:3
        sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vhigh,numSteps)
        sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vlow,numSteps)
        sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vhigh,numSteps)
        sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vhigh,numSteps)
        sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vlow,numSteps)
        sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vlow,numSteps)
        sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vhigh,numSteps)
        sigDACRampVoltage(pinout.phi_v2_3.device,pinout.phi_v2_3.port,vlow,numSteps)
    end

    sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_v2_2.device,pinout.phi_v2_2.port,vlow,numSteps)
    sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_v2_1.device,pinout.phi_v2_1.port,vlow,numSteps)
    % sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.d_v_3.device,pinout.d_v_3.port,vlow,numSteps) % E are on d_v_2

    %% Empty 2nd horizontal ccd and move to d_v_2
    % sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,vhigh,numSteps)
    % sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vhigh,numSteps)
    % sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vhigh,numSteps)
    % sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,-2,numSteps)
    % sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vlow,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vlow,numSteps)

    % ccdShuttleBackward(pinout.phi_h2_1.device,'B',22*3);
    
    for k = 1:22
        sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vhigh,numSteps)
        sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)
        sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vhigh,numSteps)
        sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
        sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vhigh,numSteps)
        sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
    end
    
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vlow,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vlow,numSteps)
    sigDACRamp(pinout.d9.device,pinout.d9.port,vhigh,numStepsRC,waitTimeRC)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vlow,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
    sigDACRamp(pinout.d9.device,pinout.d9.port,vlow,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.d8.device,pinout.d8.port,vhigh,numStepsRC,waitTimeRC)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
    sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vhigh,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.d8.device,pinout.d8.port,vlow,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vhigh,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vhigh,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vhigh,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vhigh,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vlow,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vlow,numStepsRC,waitTimeRC)

    sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vlow,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vlow,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.d7.device, pinout.d7.port, vhigh, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, vlow, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    sigDACRamp(pinout.d7.device, pinout.d7.port, vlow, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)
    
    % Reset Sense2
    sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.d7.device, pinout.d7.port, -2, numStepsRC, waitTimeRC)

    sigDACRampVoltage(pinout.d_v_1.device, pinout.d_v_1.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.d_v_1.device, pinout.d_v_1.port, vlow, numSteps)
    % sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vhigh, numSteps)
    % sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vlow, numSteps)
    
    % Move electrons up
%     for l = 1:76
%         empty_ccd_h1(pinout, numSteps,  numStepsRC,  waitTimeRC,  vhigh,  vlow)
%         sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vhigh, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vlow, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vhigh, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vlow, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vhigh, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vlow, numSteps)
% %         fprintf([num2str(l), ' '])
%     end
%     fprintf('\n')

    % ccdShuttleBackward(pinout.phi_v1_1.device,'C',75*3);

    for j = 1:75
        sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vhigh,numSteps)
        sigDACRampVoltage(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vlow,numSteps)
        empty_ccd_h1(pinout,numSteps,numStepsRC,waitTimeRC,vhigh,vlow)
        sigDACRampVoltage(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vhigh,numSteps)
        sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vlow,numSteps)
        sigDACRampVoltage(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vhigh,numSteps)
        sigDACRampVoltage(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vlow,numSteps)
    end
    
    sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port,vlow,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vlow,numSteps)

    empty_ccd_h1(pinout, numSteps, numStepsRC, waitTimeRC, vhigh, vlow)
    
    % Reset Sense1
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, -2, numSteps)
    sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.d5.device, pinout.d5.port, -2, numStepsRC, waitTimeRC)
    fprintf([num2str(i), '\n']);
end

% Reset Sommer-Tanner
sigDACRampVoltage(pinout.stm.device, pinout.stm.port, vstm, numSteps)
sigDACRampVoltage(pinout.std.device, pinout.std.port, vstd, numSteps)
sigDACRampVoltage(pinout.sts.device, pinout.sts.port, vsts, numSteps)
delay(0.1)

if sense1 == 1
    % % Check if stray electrons are in parallel channels of sense 1
    % sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps)
    % sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
    % sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
    % sigDACRamp(pinout.d5.device,pinout.d5.port,vhigh,numStepsRC,waitTimeRC)
    % sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vlow,numSteps)
    % sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
    % delay(1)

    MFLISweep1D_getSample({'Guard1'}, vstart, vstop, vstep, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat);
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC)

    loadSense1(pinout,vlow)
    MFLISweep1D_getSample({'Guard1'}, vstart, vstop, vstep, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat);
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC)

    if sense2 == 1
        MFLISweep1D_getSample({'Guard2'}, vstart, vstop, vstep, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat);
        sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)

        shuttleSense1Sense2(pinout)
        MFLISweep1D_getSample({'Guard2'}, vstart, vstop, vstep, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, ...
            'time_constant', tc, 'demod_rate', drat);
        sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)
    else
        return
    end
elseif sense1 == 0 && sense2 == 1
    MFLISweep1D_getSample({'Guard2'}, vstart, vstop, vstep, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat);
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)

    loadSense1(pinout,vlow)
    shuttleSense1Sense2(pinout)
    MFLISweep1D_getSample({'Guard2'}, vstart, vstop, vstep, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat);
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)
end

end

function empty_sense1(pinout,numSteps,numStepsRC,waitTimeRC,vhigh,vlow)
% Unload Sense1
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vlow, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vlow, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, vhigh, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vlow, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vlow, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port,vlow-0.5, numSteps)

% ccdShuttleBackward(pinout.phi_h1_1.device,'A',64*3);

% Move electrons on phi_h1_1 back to Sommer-Tanner through horizontal ccd
ccd_units = 64; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_h1_2.device, pinout.phi_h1_2.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_2.device, pinout.phi_h1_2.port, vlow, numSteps)
end

% Unload ccd
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vlow, numSteps)
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vlow, numSteps)
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vlow, numSteps)

% Reset twiddle-sense, move stray electrons from d4 back to sense1_l
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vhigh, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vhigh, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vhigh, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vhigh, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, vlow, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vlow, numSteps)
end

function empty_ccd_h1(pinout, numSteps, numStepsRC, waitTimeRC, vhigh, vlow)
% Move electrons from phi_v1_2 to Somer-Tanner
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vlow, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vlow, numSteps)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vhigh, numSteps)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vhigh, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vhigh, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vlow, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vhigh, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vlow, numSteps)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vlow, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vlow, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, vhigh, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vlow, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vlow, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow-0.5, numSteps) % Set d4 s.t. electrons can't get onto top metal in parallel channels

% Move electrons on CCD3 back to ST through CCD
ccd_units = 64; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_h1_2.device, pinout.phi_h1_2.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
    sigDACRampVoltage(pinout.phi_h1_2.device, pinout.phi_h1_2.port, vlow, numSteps)
end

% Unload ccd
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vlow, numSteps)
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vlow, numSteps)
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vlow, numSteps)

% Move electrons in closed off channels from d4 to phi_v1_2
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vhigh, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vhigh, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, vlow, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vhigh, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device, pinout.twiddle1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vhigh, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vlow, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vhigh, numSteps)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vlow, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vlow, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, vlow, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vhigh, numSteps)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, vlow, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device, pinout.phi_h1_1.port, vlow, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vlow, numSteps)

sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_v2_2.device, pinout.phi_v2_2.port, vhigh, numSteps)
sigDACRampVoltage(pinout.d_v_2.device, pinout.d_v_2.port, vhigh, numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device, pinout.phi_h1_3.port, vlow, numSteps)
end