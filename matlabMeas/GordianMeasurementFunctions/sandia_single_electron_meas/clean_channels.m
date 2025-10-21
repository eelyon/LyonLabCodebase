function clean_channels(pinout,repeats,varargin)
% Script for cleaning all channels
% Run pinout before running this script
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 5, isnonneg);
p.addParameter('numStepsRC', 5, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('Vopen', 1, isnonneg);
p.addParameter('Vclose', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
Vopen = p.Results.Vopen; % holding voltage of ccd
Vclose = p.Results.Vclose; % closing voltage of ccd

for repeats = 1:repeats

    % Set Sommer-Tanner positive to suck in electrons
    sigDACRampVoltage(pinout.stm.device, pinout.stm.port, +2, numSteps)
    sigDACRampVoltage(pinout.std.device, pinout.std.port, +2, numSteps)
    sigDACRampVoltage(pinout.sts.device, pinout.sts.port, +2, numSteps)
    
    %% Set 1st twiddle-sense for top metal sweep
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
    sigDACRamp(pinout.d5.device, pinout.d5.port, Vopen, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, Vopen, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, Vopen, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, Vopen, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, Vopen, numSteps)
    
    % Sweep top metal
    sigDACRamp(pinout.tm.device, pinout.tm.port, -2, numStepsRC, 15000); delay(1)
    sigDACRamp(pinout.tm.device, pinout.tm.port, -1.2, numStepsRC, waitTimeRC)
    
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, Vclose, numSteps)
    
    emptyTwiddleSense1(pinout, numSteps, numStepsRC, waitTimeRC, Vopen, Vclose); % Empty 6x twiddle-sense 1
    
    %% Move electrons onto vertical CCD
%     sigDACRampVoltage(phi1_1.device, phi1_1.port, Vclose, numSteps)
%     sigDACRampVoltage(d4.device, d4.port, Vclose, numSteps)
%     sigDACRamp(d5.device, d5.port, Vclose, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, Vopen, numSteps)
    sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, Vclose, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, Vclose, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, Vclose, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.d6.device, pinout.d6.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device,  pinout.phi1_3.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose, numSteps) % Electrons on phi1_3
    
    % Open gates to let electrons onto vertical CCD
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vclose, numSteps)
    
    % Add bit for emptying out channels beyond twiddle-sense 2 - might want to
    % check how many electrons are stuck there
    
    %% Empty twiddle-sense 2 onto d_Vup_2
    sigDACRamp(pinout.d7.device, pinout.d7.port, Vopen, numStepsRC, waitTimeRC) % door for compensation of sense 1
    sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, Vclose, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, Vclose, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, Vclose, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vopen, numSteps)
    sigDACRamp(pinout.d7.device, pinout.d7.port, Vclose, numStepsRC, waitTimeRC) % door for compensation of sense 1
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose, numSteps)
    
    % Reset twiddle-sense 2
    sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.d7.device, pinout.d7.port, -2, numStepsRC, waitTimeRC)
    
%     MFLISweep1D({'Guard2'}, 0.2, -1, 0.1, 'dev32061', guard2_l.device, guard2_l.port, 0, 'time_constant', 0.1, 'demod_rate', 20e3, 'poll_duration', 0.2);
    % sweep1DMeasSR830({'Guard2'}, 0, -2, -0.2, 3, 5, {SR830Twiddle}, guard2_l.device, {guard2_l.port}, 0, 1);
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)
    
    %% Move electrons up
    for j = 1:76
        sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, Vclose, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, Vclose, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, Vclose, numSteps)
        emptyCCD1(pinout, numSteps,  numStepsRC,  waitTimeRC,  Vopen,  Vclose)
        fprintf([num2str(j), ' '])
    end
    fprintf('\n')
    
    %% Empty remaining 5 channels by moving electrons down
    for k = 1:4
        sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, Vclose, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, Vclose, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, Vclose, numSteps)
        emptyCCD1(pinout, numSteps,  numStepsRC,  waitTimeRC,  Vopen,  Vclose)
    
        % Move electrons from phi_Vup_3 to phi_Vup_2
        sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, Vclose, numSteps)
    end
    
    %% Empty channel parallel to 2nd twiddle-sense
    sigDACRampVoltage(pinout.d_Vup_1.device, pinout.d_Vup_1.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.d_Vup_1.device, pinout.d_Vup_1.port, Vclose, numSteps)
    
    for l = 1:3
        sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, Vclose, numSteps)
        sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, Vclose, numSteps)
        % sigDACRampVoltage(phi_Vdown_3.device, phi_Vdown_3.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, Vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, Vclose, numSteps)
        % sigDACRampVoltage(phi_Vdown_2.device, phi_Vdown_2.port, Vopen, numSteps)
        % sigDACRampVoltage(phi_Vdown_3.device, phi_Vdown_3.port, Vclose, numSteps)
    end
    
    sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, Vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, Vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, Vclose, numSteps)
    
    emptyCCD1(pinout, numSteps, numStepsRC, waitTimeRC, Vopen, Vclose)
    
    %% Reset twiddle-sense1
    sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, -2, numSteps) % set right shield to -2V
    sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, 0, numStepsRC, waitTimeRC) % set twiddle to 0V
    sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC) % set left shield back
    sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.d5.device, pinout.d5.port, -2, numStepsRC, waitTimeRC) % close door

    emptyTwiddleSense1(pinout, numSteps, numStepsRC, waitTimeRC, Vopen, Vclose)
    
    % Reset Sommer-Tanner
    sigDACRampVoltage(pinout.stm.device, pinout.stm.port, 0, numSteps)
    sigDACRampVoltage(pinout.std.device, pinout.std.port, 0, numSteps)
    sigDACRampVoltage(pinout.sts.device, pinout.sts.port, 0, numSteps)

    fprintf([num2str(repeats), '\n']);
end

% Check if any electrons remain in either twiddle-sense
MFLISweep1D({'Guard1'}, 0.2, -1, 0.1, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, 'time_constant', 0.1, 'demod_rate', 1e3, 'poll_duration', 0.1);
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC); delay(1)

MFLISweep1D({'Guard2'}, 0.2, -1, 0.1, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, 'time_constant', 0.1, 'demod_rate', 1e3, 'poll_duration', 0.1);
sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)

end

function emptyTwiddleSense1(pinout, numSteps, numStepsRC, waitTimeRC, Vopen, Vclose)
%% Script for unloading electrons from 1st twiddle-sense and clean top metal
% Channels parallel to the 6 used ones are emptied by lifting electrons
% onto top metal through d4 and phi1_1

%% Unload twiddle-sense
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, Vclose, numStepsRC, waitTimeRC) % close twiddle
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, Vclose, numStepsRC, waitTimeRC) % close shield
sigDACRamp(pinout.d5.device, pinout.d5.port, Vopen, numStepsRC, waitTimeRC) % open door
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, Vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps) % open d4
sigDACRamp(pinout.d5.device, pinout.d5.port, Vclose, numStepsRC, waitTimeRC) % close door
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vopen, numSteps) % open ccd1
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose-0.8, numSteps) % close door

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vopen, numSteps) % open ccd3
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vclose, numSteps) % close ccd1
    sigDACRampVoltage(pinout.phi1_2.device, pinout.phi1_2.port, Vopen, numSteps) % open ccd2
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vclose, numSteps) % close ccd3
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vopen, numSteps) % open ccd1
    sigDACRampVoltage(pinout.phi1_2.device, pinout.phi1_2.port, Vclose, numSteps) % close ccd2
end

%% Unload CCD
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, Vopen, numSteps) % open 3rd door
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vclose, numSteps) % close ccd1
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, Vopen, numSteps) % open 2nd door
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, Vclose, numSteps) % close 3rd door
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, Vopen, numSteps) % open 1st door
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, Vclose, numSteps) % close 2nd door
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, Vclose, numSteps) % close 1st door

%% Reset twiddle-sense,  move stray electrons from d4 back to sense1_l
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps) % close door
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vclose, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, Vopen, numStepsRC, waitTimeRC) % open door
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose, numSteps) % close door
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, 0, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC) % set left shield back
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, 0, numStepsRC, waitTimeRC) % set twiddle back to 0V
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, -2, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, -2, numStepsRC, waitTimeRC) % close d5

% MFLISweep1D({'Guard1'}, 0.2, -1, 0.1, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, 'time_constant', 0.1, 'demod_rate', 1e3, 'poll_duration', 0.1);
% sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC) % set left shield back

% MFLISweep1D({'Guard2'}, 0.2, -1, 0.1, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, 'time_constant', 0.1, 'demod_rate', 1e3, 'poll_duration', 0.1);
% sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC) % set left shield back
% delay(1)
end

function emptyCCD1(pinout, numSteps, numStepsRC, waitTimeRC, Vopen, Vclose)
% Move electrons out of horizontal channel with ccd1,  then move remaining
% electrons in parallel channels back to vertical channel

%% Move electrons from phi_Vdown_2 to Somer-Tanner
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, Vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vclose, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vopen, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vclose, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, Vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose, numSteps)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, Vopen, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, Vclose, numSteps)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, Vopen, numSteps)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, Vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, Vopen, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, Vclose, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, Vopen, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, Vclose, numSteps)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, Vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, Vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, Vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, Vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, Vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose-0.8, numSteps) % Set d4 s.t. electrons can't get onto top metal in parallel channels

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vopen, numSteps) % open ccd3
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vclose, numSteps) % close ccd1
    sigDACRampVoltage(pinout.phi1_2.device, pinout.phi1_2.port, Vopen, numSteps) % open ccd2
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vclose, numSteps) % close ccd3
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vopen, numSteps) % open ccd1
    sigDACRampVoltage(pinout.phi1_2.device, pinout.phi1_2.port, Vclose, numSteps) % close ccd2
end

%% Unload CCD
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, Vopen, numSteps) % open 3rd door
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vclose, numSteps) % close ccd1
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, Vopen, numSteps) % open 2nd door
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, Vclose, numSteps) % close 3rd door
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, Vopen, numSteps) % open 1st door
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, Vclose, numSteps) % close 2nd door
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, Vclose, numSteps) % close 1st door

%% Move electrons in closed off channels from d4 to phi_Vdown_2
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, Vopen, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, Vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, Vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, Vopen, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device, pinout.twiddle1.port, Vopen, numSteps)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, Vopen, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, Vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, Vopen, numSteps)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, Vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, Vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, Vclose, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, Vopen, numSteps)
sigDACRampVoltage(pinout.sense1_r.device, pinout.sense1_r.port, Vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
sigDACRampVoltage(pinout.d6.device, pinout.d6.port, Vclose, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vopen, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, Vclose, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, Vclose, numSteps)

sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, Vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, Vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, Vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, Vclose, numSteps)
end