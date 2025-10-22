function [] =  sweepGatesforTransport(device,STOuterPort,STMidPort,STInnerPort,DoorInPort,DoorOutPort,TwidPort,SensPort,TopPort,finalVoltage,sign)
%% Sweep gates slowly either overall positive or negative for transport
% finalVoltage = final ST voltages (requires sign to be correct)

numSteps=1000;
if strcmp(sign,'Pos')
    step = 0:0.5:finalVoltage-0.5;
    for i = 1:length(step)
        volt = step(i);
        doorOutVolt = volt-0.5;
        thinFilmVolt = 1.5; % getVal(device,TfVolt);
        if doorOutVolt > thinFilmVolt - 0.7
            doorOutVolt = thinFilmVolt - 0.7; 
        else
        end
        sigDACRampVoltage(device,[STOuterPort,STMidPort,STInnerPort],[volt+0.5,volt+0.5,volt+0.5],numSteps*5);
        sigDACRampVoltage(device,[DoorInPort,TwidPort,SensPort,DoorOutPort],[volt-0.5,volt+0.5,volt+0.5,volt+0.5],numSteps*5);
        sigDACRampVoltage(device,TopPort,-0.7+(0.5*i),numSteps*5);
    end
else
    step = 0:-0.5:finalVoltage+0.5;
    thinFilmVolt= -3; % getVal(controlDAC,TfVolt);
    for i = 1:length(step)
        volt = step(i);
        doorOutVolt = volt-1.5;
        if doorOutVolt > thinFilmVolt - 0.7
            doorOutVolt = thinFilmVolt - 0.7; 
        else
        end
        sigDACRampVoltage(device,TopPort,-0.7-(0.5*i),numSteps*5);
        sigDACRampVoltage(device,[DoorInPort,TwidPort,SensPort,DoorOutPort],[volt-1.5,volt-0.5,volt-0.5,doorOutVolt],numSteps*5);
        sigDACRampVoltage(device,[STOuterPort,STMidPort,STInnerPort],[volt-0.5,volt-0.5,volt-0.5],numSteps*5);
    end
end
end