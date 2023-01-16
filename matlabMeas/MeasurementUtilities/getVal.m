function [ Value ] = getVal( Device, Port)
%% Determine which voltage source is being used
name = Device.identifier;
if strfind(name,'SR830')
    if contains(Port,'Freq')
        Value = Device.SR830getFreq();
    else if contains(Port, 'Amp')
        Value = Device.SR830getAmplitude();
    else
        Value = Device.SR830queryAuxOut(Port);
    end

    end
elseif strfind(name,'AP24')

    Value = Device.sigDACQueryVoltage(Port);

elseif strfind(name,'AP16A')

    Value = Device.sigDACQueryVoltage(Port);

elseif strfind(name,'SIM9')

    Value = Device.querySIM900Voltage(Port);

elseif strfind(name,',33220A,')

    if Port == 1
        Value = Device.query33220VoltageLow();
    elseif Port == 2
        Value = Device.query33220VoltageHigh();
    else
        fprintf('\nUnknown Port\n')
    end

else
    fprintf('\nUnknown Device\n')
end

end

