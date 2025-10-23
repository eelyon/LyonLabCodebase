function clean_channelsfn(pinout,repeats,varargin)
% Script for cleaning all channels
% Run pinout before running this script
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 5, isnonneg);
p.addParameter('numStepsRC', 5, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('vopen', 1, isnonneg);
p.addParameter('vclose', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.addParameter('tc', 0.02, isnonneg);
p.addParameter('drat', 10e3, isnonneg);
p.addParameter('poll', 0.5, isnonneg);
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
vopen = p.Results.vopen; % holding voltage of ccd
vclose = p.Results.vclose; % closing voltage of ccd
tc = p.Results.tc;
drat = p.Results.drat;
poll = p.Results.poll;

for repeats = 1:repeats

    % Set Sommer-Tanner positive to suck electrons in
    sigDACRampVoltage(pinout.stm.device, pinout.stm.port, +2, numSteps)
    sigDACRampVoltage(pinout.std.device, pinout.std.port, +2, numSteps)
    sigDACRampVoltage(pinout.sts.device, pinout.sts.port, +2, numSteps)
    
    %% Set 1st twiddle-sense for top metal sweep
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
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
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device,  pinout.phi1_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps) % Electrons on phi1_3
    
    % Open gates to let electrons onto vertical CCD
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
    
    % Add bit for emptying out channels beyond twiddle-sense 2
    % Can park electrons on d_2_Vup
%     sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,vopen,numSteps)
%     sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,vclose,numSteps)

    for i = 1:3
        sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,vopen,numSteps)
        sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,vclose,numSteps)
        sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,vopen,numSteps)
        sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,vclose,numSteps)
        sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,vopen,numSteps)
        sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,vclose,numSteps)
    end

    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,vopen,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,vclose,numSteps)
    sigDACRampVoltage(d_Vup_3.Device,d_Vup_3.Port,vopen,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,vclose,numSteps)
    sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,vopen,numSteps)
    sigDACRampVoltage(d_Vup_3.Device,d_Vup_3.Port,vclose,numSteps) % e are on d_Vup_2

    %% Empty 2nd horizontal ccd and move to d_Vup_2
    sigDACRampVoltage(pinout.trap2_1.device,pinout.trap2_1.port,open,numSteps)
    sigDACRampVoltage(pinout.trap1_1.device,pinout.trap1_1.port,open,numSteps)
    sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vopen,numSteps)
    sigDACRampVoltage(pinout.trap2_1.device,pinout.trap2_1.port,-2,numSteps)
    sigDACRampVoltage(pinout.trap1_1.device,pinout.trap1_1.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vclose,numSteps)
    
    for k = 1:22
        sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vclose,numSteps)
        sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vclose,numSteps)
        sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vopen,numSteps)
        sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vclose,numSteps)
    end
    
    sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vclose,numSteps)
    sigDACRamp(pinout.d9.device,pinout.d9.port,vopen,numStepsRC,waitTimeRC)
    sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
    sigDACRamp(pinout.d9.device,pinout.d9.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.d8.device,pinout.d8.port,vopen,numStepsRC,waitTimeRC)
    sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
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
    delay(1)
    
    MFLISweep1D({'Guard2'}, 0.4, -1.2, 0.1, 'dev32061', guard2_l.device, guard2_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat, 'poll_duration', poll);
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)

    sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.d7.device, pinout.d7.port, vopen, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, vclose, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
    sigDACRamp(pinout.d7.device, pinout.d7.port, vclose, numStepsRC, waitTimeRC)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
%     sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
    
    % Reset twiddle-sense 2
    sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, 0, numStepsRC, waitTimeRC)
    sigDACRamp(pinout.d7.device, pinout.d7.port, -2, numStepsRC, waitTimeRC)
    delay(1)
    
    MFLISweep1D({'Guard2'}, 0.4, -1.2, 0.1, 'dev32061', guard2_l.device, guard2_l.port, 0, ...
        'time_constant', tc, 'demod_rate', drat, 'poll_duration', poll);
    sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)

    sigDACRampVoltage(pinout.d_Vup_1.device, pinout.d_Vup_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, close, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.d_Vup_1.device, pinout.d_Vup_1.port, close, numSteps)
%     sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port,
%     vopen, numSteps) % already open from earlier
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
    
    % Move electrons up
    for j = 1:76
        empty_ccd1(pinout, numSteps,  numStepsRC,  waitTimeRC,  vopen,  vclose)
        sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vclose, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
        sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
        fprintf([num2str(j), ' '])
    end
    fprintf('\n')

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

    fprintf([num2str(repeats), '\n']);
end

% Check if any electrons remain in either twiddle-sense
MFLISweep1D({'Guard1'}, 0.2, -1, 0.1, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, 'time_constant', 0.1, 'demod_rate', 1e3, 'poll_duration', 0.1);
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC); delay(1)

MFLISweep1D({'Guard2'}, 0.2, -1, 0.1, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, 'time_constant', 0.1, 'demod_rate', 1e3, 'poll_duration', 0.1);
sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)

end

function empty_sense1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
% Unload sense 1
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, -1.6, numSteps)

% Move electrons on phi1_1 back to Sommer-Tanner through horizontal ccd
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_2.device, pinout.phi1_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi1_2.device, pinout.phi1_2.port, vclose, numSteps)
end

% Unload ccd
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vopen, numSteps)
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vclose, numSteps)
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vopen, numSteps)
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vclose, numSteps)

% Reset twiddle-sense, move stray electrons from d4 back to sense1_l
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps)
sigDACRamp(pinout.d5.device, pinout.d5.port, vopen, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRamp(pinout.sense1_l.device, pinout.sense1_l.port, 0, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle1.device, pinout.twiddle1.port, 0, numStepsRC, waitTimeRC)
sigDACRamp(pinout.d5.device, pinout.d5.port, -2, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device, pinout.guard1_r.port, -2, numSteps)
end

function empty_ccd1(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
% Move electrons from phi_Vdown_2 to Somer-Tanner
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
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
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose-0.8, numSteps) % Set d4 s.t. electrons can't get onto top metal in parallel channels

% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps) % open ccd3
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps) % close ccd1
    sigDACRampVoltage(pinout.phi1_2.device, pinout.phi1_2.port, vopen, numSteps) % open ccd2
    sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps) % close ccd3
    sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps) % open ccd1
    sigDACRampVoltage(pinout.phi1_2.device, pinout.phi1_2.port, vclose, numSteps) % close ccd2
end

% Unload ccd
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vopen, numSteps) % open 3rd door
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps) % close ccd1
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vopen, numSteps) % open 2nd door
sigDACRampVoltage(pinout.d3.device, pinout.d3.port, vclose, numSteps) % close 3rd door
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vopen, numSteps) % open 1st door
sigDACRampVoltage(pinout.d2.device, pinout.d2.port, vclose, numSteps) % close 2nd door
sigDACRampVoltage(pinout.d1_even.device, pinout.d1_even.port, vclose, numSteps) % close 1st door

% Move electrons in closed off channels from d4 to phi_Vdown_2
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
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)

sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
end