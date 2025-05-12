%% Setup
setVal(controlDAC,BlockPort,-0.5);

sigDACRampVoltage(controlDAC,[TopEPort,STOBiasEPort,StmEPort,STIBiasEPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorEInPort,TwiddleEPort,SenseEPort,DoorEOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TopCPort,STOBiasCPort,StmCPort,STIBiasCPort],[-0.7,0,0,0],numSteps);
sigDACRampVoltage(controlDAC,[DoorCInPort,TwiddleCPort,SenseCPort,DoorCOutPort],[-1,0,0,-1],numSteps);

sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[-2,-2,-2],numSteps);
sigDACRampVoltage(supplyDAC,TfEPort,-2,numSteps);


sweepGatesforTransport(controlDAC,STOBiasEPort,StmEPort,STIBiasEPort,DoorEInPort,DoorEOutPort,TwiddleEPort,SenseEPort,TopEPort,2.5,'Pos');
Vbias = 2.5;
sigDACRampVoltage(controlDAC,[STOBiasEPort,StmEPort,STIBiasEPort],[Vbias+0.5,Vbias+0.5,Vbias+0.5],numSteps);


%% LOOP
BEVoltages = -3:0.5:3;
BCVoltages = -3:0.5:3;
magC = zeros(3,3);

starts = {-3 -3};
stops  = {3 3};
deltas = {0.5 0.5};
plotHandle = initializeSR830Meas2D_Func({'BE', 'BC'}, starts, stops, deltas);

for i=1:31
    for j=1:31
        % load electrons into collector region
        sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-0.4,-0.3,-0.2],numSteps);
        sigDACRampVoltage(controlDAC,DoorCInPort,0,numSteps);
        sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);
        magCollector = SR830queryX(SR830TwiddleC);
        magC(i,j) = magCollector;
        if magCollector < 150e-6
            sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[0,0,0],numSteps); % reset ST voltages
            delay(1)
            sigDACRampVoltage(controlDAC,[STOBiasCPort,StmCPort,STIBiasCPort],[-0.4,-0.3,-0.2],numSteps);
            sigDACRampVoltage(controlDAC,DoorCInPort,0,numSteps);
            sigDACRampVoltage(controlDAC,DoorCInPort,-1,numSteps);
            disp(BEVoltages(i))
            disp(BCVoltages(j))
        end
        % set thin film voltages
        sigDACRampVoltage(controlDAC,[TfCPort,BEPort,BCPort],[2,BEVoltages(i),BCVoltages(j)],numSteps);
        sigDACRampVoltage(supplyDAC,TfEPort,0.5,numSteps);
        
        % make sure other sides door is open
        sigDACRampVoltage(controlDAC,DoorEOutPort,3,numSteps);
        
        % transfer electrons and close door
        sigDACRampVoltage(controlDAC,DoorCOutPort,0,numSteps);
        delay(2)
        sigDACRampVoltage(controlDAC,DoorCOutPort,-1,numSteps);
        sigDACRampVoltage(controlDAC,DoorEOutPort,1.5,numSteps);
        
        % check to see if anything was transferred, if so, record and clean
        % into reservoir
        magEmitter = SR830queryX(SR830Twiddle);
        plotHandle.CData(i, j) = magEmitter;   % plots data into initialized graph
        
        if magEmitter > 10e-6  % clean 
            sigDACRampVoltage(controlDAC,DoorEInPort,Vbias,numSteps);
            delay(1)
            sigDACRampVoltage(controlDAC,DoorEInPort,Vbias-1,numSteps);
        end
    end
end

