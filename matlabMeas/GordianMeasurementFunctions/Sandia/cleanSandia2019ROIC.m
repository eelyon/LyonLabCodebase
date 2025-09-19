function cleanSandia2019ROIC(varargin)
%% Script for unloading electrons from 1st twiddle-sense and clean top metal
% Run DCPinout before running this script

p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
p.addParameter('numSteps', 10, isnonneg);
p.addParameter('numStepsRC', 10, isnonneg);
p.addParameter('waitTimeRC', 1100, isnonneg);
p.addParameter('Vopen', 3, isnonneg);
p.addParameter('Vclose', -1, @(x) isnumeric(x) && isscalar(x) && (x < 0));
p.addParameter('clean_repeats', 1, isnonneg);
p.parse(varargin{:});

numSteps = p.Results.numSteps; % sigDACRampVoltage
numStepsRC = p.Results.numStepsRC; % sigDACRamp
waitTimeRC = p.Results.waitTimeRC; % in microseconds
Vopen = p.Results.Vopen; % holding voltage of ccd
Vclose = p.Results.Vclose; % closing voltage of ccd
clean_repeats = p.Results.clean_repeats;

for repeats = 1:clean_repeats

    % Set Sommer-Tanner positive to suck in electrons
    sigDACRampVoltage(STM.Device,STM.Port,+2,numSteps)
    sigDACRampVoltage(STD.Device,STD.Port,+2,numSteps)
    sigDACRampVoltage(STS.Device,STS.Port,+2,numSteps)
    
    %% Set 1st twiddle-sense for top metal sweep
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,0.2,numSteps)
    sigDACRampVoltage(d4.Device,d4.Port,0.2,numSteps)
    sigDACRamp(d5.Device,d5.Port,0.2,numStepsRC,waitTimeRC)
    sigDACRamp(sense1_l.Device,sense1_l.Port,0.2,numStepsRC,waitTimeRC)
    sigDACRamp(guard1_l.Device,guard1_l.Port,0.2,numStepsRC,waitTimeRC)
    sigDACRamp(twiddle1.Device,twiddle1.Port,0.2,numStepsRC,waitTimeRC)
    sigDACRampVoltage(guard1_r.Device,guard1_r.Port,0.2,numSteps)
    sigDACRampVoltage(sense1_r.Device,sense1_r.Port,0.2,numSteps)
    sigDACRampVoltage(d6.Device,d6.Port,0.2,numSteps)
    
    % Sweep top metal
    sigDACRamp(TM.Device,TM.Port,-2,numStepsRC,15000); delay(1)
    sigDACRamp(TM.Device,TM.Port,-1.2,numStepsRC,waitTimeRC)
    
    sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
    sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
    sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
    
    emptyTwiddleSense1(numSteps, numStepsRC, waitTimeRC, Vopen, Vclose); % Empty 6x twiddle-sense 1
    
    %% Move electrons onto vertical CCD
%     sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
%     sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
%     sigDACRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTimeRC)
    sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vopen,numSteps)
    sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vopen,numSteps)
    sigDACRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTimeRC)
    sigDACRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTimeRC)
    sigDACRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTimeRC)
    sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
    sigDACRampVoltage(d6.Device,d6.Port,Vopen,numSteps)
    sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
    sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
    sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
    sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
    sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
    sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % Electrons on phi1_3
    
    % Open gates to let electrons onto vertical CCD
    sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
    sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
    
    % Add bit for emptying out channels beyond twiddle-sense 2 - might want to
    % check how many electrons are stuck there
    
    %% Empty twiddle-sense 2 onto d_Vup_2
    sigDACRamp(d7.Device,d7.Port,Vopen,numStepsRC,waitTimeRC) % door for compensation of sense 1
    sigDACRamp(twiddle2.Device,twiddle2.Port,Vclose,numStepsRC,waitTimeRC)
    sigDACRamp(guard2_l.Device,guard2_l.Port,Vclose,numStepsRC,waitTimeRC)
    sigDACRamp(sense2_l.Device,sense2_l.Port,Vclose,numStepsRC,waitTimeRC)
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
    sigDACRamp(d7.Device,d7.Port,Vclose,numStepsRC,waitTimeRC) % door for compensation of sense 1
    sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
    sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
    sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
    sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
    sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
    
    % Reset twiddle-sense 2
    sigDACRamp(twiddle2.Device,twiddle2.Port,0,numStepsRC,waitTimeRC)
    sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)
    sigDACRamp(sense2_l.Device,sense2_l.Port,0,numStepsRC,waitTimeRC)
    sigDACRamp(d7.Device,d7.Port,-2,numStepsRC,waitTimeRC)
    
%     MFLISweep1D({'Guard2'},0.2,-1,0.1,'dev32061',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',20e3,'poll_duration',0.2);
    % sweep1DMeasSR830({'Guard2'},0,-2,-0.2,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},0,1);
    sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)
    
    %% Move electrons up
    for j = 1:76
        sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)
        sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
        sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,Vclose,numSteps)
        emptyCCD1(numSteps, numStepsRC, waitTimeRC, Vopen, Vclose)
        fprintf([num2str(j),' '])
    end
    fprintf('\n')
    
    %% Empty remaining 5 channels by moving electrons down
    for k = 1:4
        sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
        sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
        sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
        emptyCCD1(numSteps, numStepsRC, waitTimeRC, Vopen, Vclose)
    
        % Move electrons from phi_Vup_3 to phi_Vup_2
        sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
    end
    
    %% Empty channel parallel to 2nd twiddle-sense
    sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vopen,numSteps)
    sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
    sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vclose,numSteps)
    
    for l = 1:3
        sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
        sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
        % sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
        sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
        % sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
        % sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
    end
    
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
    
    emptyCCD1(numSteps, numStepsRC, waitTimeRC, Vopen, Vclose)
    
    %% Reset twiddle-sense1
    sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps) % set right shield to -2V
    sigDACRamp(twiddle1.Device,twiddle1.Port,0,numStepsRC,waitTimeRC) % set twiddle to 0V
    sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back
    sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC)
    sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC) % close door

    emptyTwiddleSense1(numSteps, numStepsRC, waitTimeRC, Vopen, Vclose)
    
    % Reset Sommer-Tanner
    sigDACRampVoltage(STM.Device,STM.Port,+1,numSteps)
    sigDACRampVoltage(STD.Device,STD.Port,+1,numSteps)
    sigDACRampVoltage(STS.Device,STS.Port,+1,numSteps)

    fprintf([num2str(repeats),'\n']);
end

% Check if any electrons remain in either twiddle-sense
MFLISweep1D({'Guard1'},0.2,-1,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',20e3,'poll_duration',0.2);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC); delay(1)

MFLISweep1D({'Guard2'},0.2,-1,0.1,'dev32061',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',20e3,'poll_duration',0.2);
sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)

end

function emptyTwiddleSense1(numSteps, numStepsRC, waitTimeRC, Vopen, Vclose)
%% Script for unloading electrons from 1st twiddle-sense and clean top metal
% Channels parallel to the 6 used ones are emptied by lifting electrons
% onto top metal through d4 and phi1_1

%% Unload twiddle-sense
sigDACRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTimeRC) % close twiddle
sigDACRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTimeRC) % close shield
sigDACRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTimeRC) % open door
sigDACRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps) % open d4
sigDACRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTimeRC) % close door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open ccd1
sigDACRampVoltage(d4.Device,d4.Port,Vclose-0.8,numSteps) % close door

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps) % open ccd3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close ccd1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vopen,numSteps) % open ccd2
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps) % close ccd3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open ccd1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numSteps) % close ccd2
end

%% Unload CCD
sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps) % open 3rd door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close ccd1
sigDACRampVoltage(d2.Device,d2.Port,Vopen,numSteps) % open 2nd door
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps) % close 3rd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vopen,numSteps) % open 1st door
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps) % close 2nd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps) % close 1st door

%% Reset twiddle-sense, move stray electrons from d4 back to sense1_l
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps) % close door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTimeRC) % open door
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % close door
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back
sigDACRamp(twiddle1.Device,twiddle1.Port,0,numStepsRC,waitTimeRC) % set twiddle back to 0V
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps)
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC) % close d5

MFLISweep1D({'Guard1'},0.2,-1,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',1e3,'poll_duration',0.1);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back

MFLISweep1D({'Guard2'},0.2,-1,0.1,'dev32061',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',1e3,'poll_duration',0.1);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back
% delay(1)
end

function emptyCCD1(numSteps, numStepsRC, waitTimeRC, Vopen, Vclose)
% Move electrons out of horizontal channel with ccd1, then move remaining
% electrons in parallel channels back to vertical channel

%% Move electrons from phi_Vdown_2 to Somer-Tanner
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vopen,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vopen,numSteps)
sigDACRamp(twiddle1.Device,twiddle1.Port,Vopen,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,Vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,Vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
sigDACRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTimeRC)
sigDACRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose-0.8,numSteps) % Set d4 s.t. electrons can't get onto top metal in parallel channels

%% Move electrons on CCD3 back to ST through CCD
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps) % open ccd3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close ccd1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vopen,numSteps) % open ccd2
    sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps) % close ccd3
    sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps) % open ccd1
    sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclose,numSteps) % close ccd2
end

%% Unload CCD
sigDACRampVoltage(d3.Device,d3.Port,Vopen,numSteps) % open 3rd door
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps) % close ccd1
sigDACRampVoltage(d2.Device,d2.Port,Vopen,numSteps) % open 2nd door
sigDACRampVoltage(d3.Device,d3.Port,Vclose,numSteps) % close 3rd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vopen,numSteps) % open 1st door
sigDACRampVoltage(d2.Device,d2.Port,Vclose,numSteps) % close 2nd door
sigDACRampVoltage(d1_even.Device,d1_even.Port,Vclose,numSteps) % close 1st door

%% Move electrons in closed off channels from d4 to phi_Vdown_2
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,Vopen,numStepsRC,waitTimeRC)
sigDACRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,Vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(sense1_r.Device,twiddle1.Port,Vopen,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vopen,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vopen,numSteps)
sigDACRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vopen,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)

sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
end