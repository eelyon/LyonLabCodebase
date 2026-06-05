function [] =  sweepGatesBackToZero(device,STOuterPort,STMidPort,STInnerPort,DoorInPort,DoorOutPort,TwidPort,SensPort,TopPort,startVoltage,sign)
%% Sweep gates back to zero from positive or negative overall voltages
% startVoltage = what you're sweeping the ST voltages from 

numSteps=1000;
if sign == 'Pos'
    step = startVoltage:-0.5:0.5;
    TopVoltage = getVal(device,TopPort);
    for i = 1:length(step)
        volt = step(i);
        doorOutVolt = volt - 1.5;
        thinFilmVolt= 1.5; %getVal(device,TfVolt);
        if doorOutVolt > thinFilmVolt - 0.7
            doorOutVolt = thinFilmVolt - 0.7; 
        else
        end
        sigDACRampVoltage(device,[STOuterPort,STMidPort,STInnerPort],[volt-0.5,volt-0.5,volt-0.5],numSteps*5);
        sigDACRampVoltage(device,[DoorInPort,TwidPort,SensPort,DoorOutPort],[volt-1.5,volt-0.5,volt-0.5,volt-1.5],numSteps*5);
        sigDACRampVoltage(device,TopPort,TopVoltage-(0.5*i),numSteps*5);
    end
else
    step = startVoltage:0.5:-0.5;
    TopVolt = getVal(device,TopPort);
    for i = 1:length(step)
        volt = step(i);
        sigDACRampVoltage(device,[STOuterPort,STMidPort,STInnerPort],[volt+0.5,volt+0.5,volt+0.5],numSteps*5);
        sigDACRampVoltage(device,[DoorInPort,TwidPort,SensPort,DoorOutPort],[volt-0.5,volt+0.5,volt+0.5,volt-0.5],numSteps*5);
        sigDACRampVoltage(device,TopPort,TopVolt+(0.5*i),numSteps*5);
    end
end
end