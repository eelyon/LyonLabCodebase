ejectionVoltage = -5;
numVoltages = 10;
waitTime = 0.03;

setVal(TopMetalDevice,TopMetalPort,6)

display("Sweeping Door and Reservoir to 0.5V");
sweepGatePairs(Door100Device,Res100Device,Door100Port,Res100Port,0.5,0.5,numVoltages,waitTime);
DACGUI.updateDACGUI;
drawnow;
sweepMeasSR830_Func('ST',0,-0.3,-0.025,.1,5,SR830,DAC,{8},1);
pause(10);
display("Sweeping TM and DP to 1V");
sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,1,1,numVoltages,waitTime);
DACGUI.updateDACGUI;
drawnow;
pause(10);
display("STM to -5V");
sweepGatePairs(Bias100Device,STM100Device,Bias100Port,STM100Port,ejectionVoltage,ejectionVoltage,numVoltages,waitTime);
DACGUI.updateDACGUI;
drawnow;
pause(1);
display("Sweeping Door and Reservoir to -5V");
sweepGatePairs(Door100Device,Res100Device,Door100Port,Res100Port,ejectionVoltage,ejectionVoltage,numVoltages,waitTime);
DACGUI.updateDACGUI;
drawnow;
pause(10);
display("Sweeping TM and DP to -5V");
sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,ejectionVoltage,ejectionVoltage,numVoltages,waitTime);
DACGUI.updateDACGUI;
drawnow;
pause(20);

emissionVoltageST = 0;
emissionVoltageTM = 1;
emissionVoltageDoor = -3;



sweepGatePairs(Door100Device,Res100Device,Door100Port,Res100Port,emissionVoltageDoor,emissionVoltageDoor,numVoltages,waitTime);
pause(1);
sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,emissionVoltageTM,emissionVoltageTM,numVoltages,waitTime);
pause(1);
sweepGatePairs(Bias100Device,STM100Device,Bias100Port,STM100Port,emissionVoltageST,emissionVoltageST,numVoltages,waitTime);
DACGUI.updateDACGUI;
drawnow;
