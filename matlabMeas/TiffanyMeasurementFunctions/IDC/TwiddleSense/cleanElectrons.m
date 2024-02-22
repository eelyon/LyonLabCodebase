function [] = cleanElectrons(DAC, DoorInPort, SensePort, TwiddlePort, Vopen, Vclose, type)
    sigDACRampVoltage(DAC,[DoorInPort,SensePort,TwiddlePort],[Vopen,Vopen,Vopen],1000);
    pause(1)
    if strcmp(type,'Emitter')
        sigDACRampVoltage(DAC,TwiddlePort,Vclose-0.2,1000);
        pause(5)
        sigDACRampVoltage(DAC,SensePort,Vclose-0.2,1000);
        pause(5)
    else
        sigDACRampVoltage(DAC,SensePort,Vclose-0.2,1000);
        pause(5)
        sigDACRampVoltage(DAC,TwiddlePort,Vclose-0.2,1000);
        pause(5)
    end
    sigDACRampVoltage(DAC,14,Vclose-0.3,3000);
    pause(5)
    sigDACRampVoltage(DAC,DoorInPort,Vclose-0.2,1000);
    pause(2)
    sigDACRampVoltage(DAC,14,-0.7,3000);
    pause(5)
    sigDACRampVoltage(DAC,[SensePort,TwiddlePort],[Vopen,Vopen],1000);
    pause(1)
end