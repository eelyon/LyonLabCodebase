ejectionVoltage = -5;
numVoltages = 10;
waitTime = 0.03;

setVal(TopMetalDevice,TopMetalPort,2)

sweepGatePairs(Door100Device,Res100Device,Door100Port,Res100Port,0.5,numVoltages,waitTime);
pause(10);
sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,1,1,numVoltages,waitTime);
pause(10);
sweepGatePairs(Bias100Device,STM100Device,Bias100Port,STM100Port,ejectionVoltage,ejectionVoltage,numVoltages,waitTime);
pause(1);
sweepGatePairs(Door100Device,Res100Device,Door100Port,Res100Port,ejectionVoltage,ejectionVoltage,numVoltages,waitTime);
pause(10);
sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,ejectionVoltage,ejectionVoltage,numVoltages,waitTime);
pause(20);

emissionVoltageST = 0;
emissionVoltageTM = 1;
emissionVoltageDoor = -3;



sweepGatePairs(Door100Device,Res100Device,Door100Port,Res100Port,emissionVoltageDoor,emissionVoltageDoor,numVoltages,waitTime);
pause(1);
sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,emissionVoltageTM,emissionVoltageTM,numVoltages,waitTime);
pause(1);
sweepGatePairs(Bias100Device,STM100Device,Bias100Port,STM100Port,emissionVoltageST,emissionVoltageST,numVoltages,waitTime);

