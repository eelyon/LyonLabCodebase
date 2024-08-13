%% This script sets all gate voltages for emission
% Run DCPinout before running this script
numSteps = 500; % sigDACRampVoltage
numStepsRC = 5; % interleavedRamp
waitTime = 0.5; % interleavedRamp
stopVal = -2;

%% Set Sommer-Tanner
interleavedRamp(TM.Device,TM.Port,-3,numStepsRC,waitTime) % ramp top metal
sigDACRampVoltage(M2S.Device,M2S.Port,-0.5,numSteps) % ramp M2 shield
sigDACRampVoltage(BPG.Device,BPG.Port,-1,numSteps) % ramp bond pad guard
fprintf('Top metal, M2 shield, and bond pad guard set for emission.\n')

sigDACRampVoltage(STD.Device,STD.Port,+2,numSteps) % ramp ST-Drive
sigDACRampVoltage(STS.Device,STS.Port,+2,numSteps) % ramp ST-Sense
sigDACRampVoltage(STM.Device,STM.Port,+2,numSteps) % ramp ST-Middle
sigDACRampVoltage(STG.Device,STG.Port,-2,numSteps) % ramp Sommer-Tanner (left) guard
fprintf('Sommer-Tanner set for emission.\n')

%% Set CCD and twiddle gates
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,stopVal,numSteps)
sigDACRampVoltage(d2_ccd.Device,d2_ccd.Port,stopVal,numSteps)
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,stopVal,numSteps)
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,stopVal,numSteps)

sigDACRampVoltage(ccd1.Device,ccd1.Port,stopVal,numSteps)
sigDACRampVoltage(ccd2.Device,ccd2.Port,stopVal,numSteps)
sigDACRampVoltage(ccd3.Device,ccd3.Port,stopVal,numSteps)
fprintf('CCDs set for emission.\n')

sigDACRampVoltage(door.Device,door.Port,stopVal,numSteps)
interleavedRamp(offset.Device,offset.Port,stopVal,numStepsRC,waitTime)
interleavedRamp(sense.Device,sense.Port,-0.5,numStepsRC,waitTime)
interleavedRamp(shieldl.Device,shieldl.Port,stopVal,numStepsRC,waitTime)
sigDACRampVoltage(twiddle.Device,twiddle.Port,stopVal,numSteps)
sigDACRampVoltage(shieldr.Device,shieldr.Port,stopVal,numSteps)
interleavedRamp(shield.Device,shield.Port,-0.5,numStepsRC,waitTime) % this is the guard underneath twiddle-sense
fprintf('Twiddle and sense set for emission.\n')

sigDACRampVoltage(filament.Device,filament.Port,-1,numSteps) % ramp filament backing plate
fprintf('Backing plate set for emission.\n')