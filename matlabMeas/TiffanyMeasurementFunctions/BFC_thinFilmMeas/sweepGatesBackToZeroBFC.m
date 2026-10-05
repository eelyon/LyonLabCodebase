function [] =  sweepGatesBackToZeroBFC(device,STOuterPort,STMidPort,STInnerPort,DoorInPort,DoorOutPort,TwidPort,SensPort,TopPort,startVoltage,endVoltage,sign)
%% Sweep gates back to zero from positive or negative overall voltages
% startVoltage = what you're sweeping the ST voltages from 

qDACrampTime = 0.5;
if sign == 'Pos'
    step = startVoltage:-0.5:endVoltage+0.5;
    TopVoltage = queryQDACVoltage(device,TopPort);
    for i = 1:length(step)
        volt = step(i);
        QDACSmoothRampVoltage(device,[STOuterPort,STMidPort,STInnerPort],[volt-0.5,volt-0.5,volt-0.5],qDACrampTime);
        QDACSmoothRampVoltage(device,[DoorInPort,TwidPort,SensPort,DoorOutPort],[volt-1.5,volt-0.5,volt-0.5,volt-1.5],qDACrampTime);
        QDACSmoothRampVoltage(device,TopPort,TopVoltage-(0.5*i),qDACrampTime);
    end
else
    step = startVoltage:0.5:endVoltage-0.5;
    TopVolt = getVal(device,TopPort);
    for i = 1:length(step)
        volt = step(i);
        QDACSmoothRampVoltage(device,[STOuterPort,STMidPort,STInnerPort],[volt+0.5,volt+0.5,volt+0.5],qDACrampTime);
        QDACSmoothRampVoltage(device,[DoorInPort,TwidPort,SensPort,DoorOutPort],[volt-0.5,volt+0.5,volt+0.5,volt-0.5],qDACrampTime);
        QDACSmoothRampVoltage(device,TopPort,TopVolt+(0.5*i),qDACrampTime);
    end
end
end