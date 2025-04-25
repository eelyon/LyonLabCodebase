%% Script for unloading electrons from 1st twiddle-sense and clean top metal
% Run DCPinout before running this script
numSteps = 20; % sigDACRampVoltage
numStepsRC = 10; % interleavedRamp
waitTime = 0.0011; % 5 times time constant
% delta = 0.25; % voltage step for sim900
% Vopen = 1; % holding voltage of ccd
% Vclose = -0.7; % closing voltage of ccd

sigDACRampVoltage(STM.Device,STM.Port,+2,numSteps)
sigDACRampVoltage(STD.Device,STD.Port,+2,numSteps)
sigDACRampVoltage(STS.Device,STS.Port,+2,numSteps)

%% Set 1st twiddle-sense for top metal sweep
% sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
% sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
% interleavedRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTime)
setSIM900Voltage(sense1_l.Device,sense1_l.Port,0); delay(2) % rampSIM900Voltage(sense1_l.Device,sense1_l.Port,0,waitTime,delta)
interleavedRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTime)
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,0,numSteps)
% sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vopen,numSteps)
% sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vopen,numSteps)
% sigDACRampVoltage(d6.Device,d6.Port,Vopen,numSteps)
% sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)

% sweep1DMeasSR830({'TM'},-0.8,-1.6,0.2,3,5,{SR830Twiddle},TM.Device,{TM.Port},1,1);
% interleavedRamp(TM.Device,TM.Port,-1.4,numStepsRC,waitTime*10); delay(1)
% interleavedRamp(TM.Device,TM.Port,-0.7,numStepsRC,waitTime)

% TwiddleUnload_Full; % Empty out 6 open channels

%% Move electrons onto vertical CCD
% sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
% sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
% interleavedRamp(d5.Device,d5.Port,Vclose,numStepsRC,waitTime)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vopen,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vopen,numSteps)
setSIM900Voltage(sense1_l.Device,sense1_l.Port,-0.5); delay(2 ...
    ) % rampSIM900Voltage(sense1_l.Device,sense1_l.Port,-0.5,waitTime,delta)
interleavedRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTime)
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,Vclose,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,0.8,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,1.2,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,1.6,numSteps)
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

%% Move electrons up
for j = 1:76
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vdown_1.Device,phi_Vdown_1.Port,Vclose,numSteps)
    unloadTwiddleSense1 % Move electrons from phi_Vdown_2 out through 6 channels
    fprintf([num2str(j),' ']);
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
interleavedRamp(d5.Device,d5.Port,-2,numStepsRC,waitTime) % close door
interleavedRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTime) % set left shield back
sigDACRampVoltage(twiddle1.Device,twiddle1.Port,0,numSteps) % set twiddle to 0V
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps) % set right shield to -2V