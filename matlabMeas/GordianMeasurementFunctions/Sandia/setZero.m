%% Script for removing all electrons from device
DCPinout; % load DC pinout  script
numSteps = 100; % set wait time after each voltage step
stopVal = 0;

sigDACRampVoltage(fil.Device,fil.Port,stopVal,numSteps);
sigDACRampVoltage(TM.Device,TM.Port,stopVal,numSteps);

sigDACRampVoltage(STD.Device,STD.Port,stopVal,numSteps);
sigDACRampVoltage(STS.Device,STS.Port,stopVal,numSteps);
sigDACRampVoltage(STM.Device,STM.Port,stopVal,numSteps);
sigDACRampVoltage(STG.Device,STG.Port,stopVal,numSteps);
sigDACRampVoltage(M2S.Device,M2S.Port,stopVal,numSteps);
sigDACRampVoltage(BPG.Device,BPG.Port,stopVal,numSteps);

%% Set ccd gates
sigDACRampVoltage(d1_ccd.Device,d1_ccd.Port,stopVal,numSteps)
sigDACRampVoltage(d2_ccd.Device,d2_ccd.Port,stopVal,numSteps)
sigDACRampVoltage(d3_ccd.Device,d3_ccd.Port,stopVal,numSteps)
sigDACRampVoltage(d4_ccd.Device,d4_ccd.Port,stopVal,numSteps)

sigDACRampVoltage(ccd1.Device,ccd1.Port,stopVal,numSteps)
sigDACRampVoltage(ccd2.Device,ccd2.Port,stopVal,numSteps)
sigDACRampVoltage(ccd3.Device,ccd3.Port,stopVal,numSteps)

sigDACRampVoltage(door.Device,door.Port,stopVal,numSteps)
sigDACRampVoltage(shieldl.Device,shieldl.Port,stopVal,numSteps)
sigDACRampVoltage(twiddle.Device,twiddle.Port,stopVal,numSteps)
sigDACRampVoltage(shieldr.Device,shieldr.Port,stopVal,numSteps)
sigDACRampVoltage(sense.Device,sense.Port,stopVal,numSteps)
sigDACRampVoltage(offset.Device,offset.Port,stopVal,numSteps)
sigDACRampVoltage(shield.Device,shield.Port,stopVal,numSteps)

fprintf('All gates set to 0V.\n')