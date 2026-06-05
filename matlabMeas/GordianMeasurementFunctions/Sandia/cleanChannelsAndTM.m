%% Script for unloading electrons from 1st twiddle-sense and clean top metal
% Run DCPinout before running this script
numSteps = 10; % sigDACRampVoltage
numStepsRC = 10; % sigDACRamp
waitTimeRC = 1100; % in microseconds
% delta = 0.25; % voltage step for sim900
Vopen = 7; % holding voltage of ccd
Vclose = -2; % closing voltage of ccd

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

% MFLISweep1D({'TM'},-1.2,-2,0.1,'dev32021',TM.Device,TM.Port,1,'time_constant',0.03,'demod_rate',20e3,'poll_duration',0.2);
% sweep1DMeasSR830({'TM'},-0.8,-1.6,0.2,3,5,{SR830Twiddle},TM.Device,{TM.Port},1,1);
sigDACRamp(TM.Device,TM.Port,-2,numStepsRC,15000); delay(1)
sigDACRamp(TM.Device,TM.Port,-1.2,numStepsRC,waitTimeRC)

sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
sigDACRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,0.2,numSteps)

TwiddleUnload_Full; % Empty out 6 open channels

%% Move electrons onto vertical CCD
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTimeRC)
% sigDACRampVoltage(guard1_r.Device,guard1_r.Port,0,numSteps)
% sigDACRampVoltage(sense1_r.Device,sense1_r.Port,0,numSteps)
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

% MFLISweep1D({'Guard2'},0.2,-1,0.1,'dev32061',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',20e3,'poll_duration',0.2);
% sweep1DMeasSR830({'Guard2'},0,-2,-0.2,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},0,1);
% sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)

%% Move electrons up
for j = 1:76
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,Vclose,numSteps)
    unloadTwiddleSense1 % Move electrons from phi_Vdown_2 out through 6 channels
    fprintf([num2str(j),' '])
end
fprintf('\n')

%% Empty remaining 5 channels
for k = 1:4
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
    unloadTwiddleSense1 % Move electrons out of twiddle-sense

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

unloadTwiddleSense1 % Move electrons out of twiddle-sense

%% Reset twiddle-sense1
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC) % close door
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back
sigDACRamp(twiddle1.Device,twiddle1.Port,0,numStepsRC,waitTimeRC) % set twiddle to 0V
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps) % set right shield to -2V
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC)

TwiddleUnload_Full % Unload twiddle-sense 1

% Reset Sommer-Tanner
sigDACRampVoltage(STM.Device,STM.Port,0,numSteps)
sigDACRampVoltage(STD.Device,STD.Port,0,numSteps)
sigDACRampVoltage(STS.Device,STS.Port,0,numSteps)

% Check if any electrons remain in either twiddle-sense
% MFLISweep1D({'Guard1'}, 0.2, -1, 0.1, 'dev32021', pinout.guard1_l.device, pinout.guard1_l.port, 0, 'time_constant', 0.1, 'demod_rate', 1e3, 'poll_duration', 0.1);
% sigDACRamp(pinout.guard1_l.device, pinout.guard1_l.port, 0, numStepsRC, waitTimeRC); delay(1)
% 
% MFLISweep1D({'Guard2'}, 0.2, -1, 0.1, 'dev32061', pinout.guard2_l.device, pinout.guard2_l.port, 0, 'time_constant', 0.1, 'demod_rate', 1e3, 'poll_duration', 0.1);
% sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, 0, numStepsRC, waitTimeRC)