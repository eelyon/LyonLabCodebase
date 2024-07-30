%% This script sets relevant gate voltages for emission
% Run DCPinout before running this script
deltaVal = 0.25; % set step size
numSteps = 0.01; % set wait time after each voltage step
stopVal = -1;

%% Set Sommer-Tanner
sigDACRampVoltage(TM.Device,TM.Port,-0.75,numSteps); % ramp top metal
sigDACRampVoltage(STG.Device,STG.Port,0,numSteps); % ramp Sommer-Tanner (left) guard
sigDACRampVoltage(M2S.Device,M2S.Port,-0.5,numSteps); % ramp M2 shield
sigDACRampVoltage(BPG.Device,BPG.Port,-1,numSteps); % ramp bond pad guard
fprintf('Sommer-Tanner set for emission.\n');

%% Set CCD and twiddle gates
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,stopVal,numSteps)
sigDACRampVoltage(d2_ccd.Device,d2_ccd.Port,stopVal,numSteps)
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,stopVal,numSteps)
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,stopVal,numSteps)

sigDACRampVoltage(ccd1.Device,ccd1.Port,stopVal,numSteps)
sigDACRampVoltage(ccd2.Device,ccd2.Port,stopVal,numSteps)
sigDACRampVoltage(ccd3.Device,ccd3.Port,stopVal,numSteps)
fprintf('CCDs set for emission.\n');

sigDACRampVoltage(door.Device,door.Port,stopVal,numSteps)
sigDACRampVoltage(shieldl.Device,shieldl.Port,stopVal,numSteps)
sigDACRampVoltage(twiddle.Device,twiddle.Port,stopVal,numSteps)
sigDACRampVoltage(shieldr.Device,shieldr.Port,stopVal,numSteps) % set -2V for twiddle
% sigDACRampVoltage(sense.Device,sense.Port,stopVal,numSteps)
sigDACRampVoltage(offset.Device,offset.Port,stopVal,numSteps)
sigDACRampVoltage(shield.Device,shield.Port,stopVal,numSteps)
fprintf('Twiddle and sense set for emission.\n');
 
sigDACRampVoltage(fil.Device,fil.Port,-2,numSteps); % ramp filament backing plate
fprintf('Voltages set for emission.\n')