BackingPlateVoltage = -3;
DPVoltage = 0;
TMDelta = 5;

numVoltages = 10;
waitTime = 0.03;

sweepGatePairs(Door100Device,Res100Device,Door100Port,Res100Port,BackingPlateVoltage,BackingPlateVoltage-2,numVoltages,waitTime);
sweepGatePairs(Bias100Device,STM100Device,Bias100Port,STM100Port,BackingPlateVoltage,BackingPlateVoltage-2,numVoltages,waitTime);

sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,BackingPlateVoltage + TMDelta,BackingPlateVoltage + TMDelta,numVoltages,waitTime);
DACGUI.updateDACGUI;
SR830GUI.updateSR830App;
drawnow;
%rampVal(Dot100Device,Dot100Port,DPVoltage,1,.1);

input('\nFlash\n')
sweepGate(Dot100Device,Dot100Port,BackingPlateVoltage+TMDelta,BackingPlateVoltage+TMDelta+1,.01,.03);
sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,BackingPlateVoltage-2,BackingPlateVoltage - 1,50,.03);
pause(10);
sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,1,2,50,.03);
%sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,-0.5,numVoltages,waitTime);
sweepGatePairs(Door100Device,Res100Device,Door100Port,Res100Port,BackingPlateVoltage+2,BackingPlateVoltage,numVoltages,waitTime);
%rampVal(Top100Device,Top100Port,-0.25,1,0.1);

sweepGatePairs(Bias100Device,STM100Device,Bias100Port,STM100Port,0,0,numVoltages,waitTime);

