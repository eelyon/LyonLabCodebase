function [errorFlag] = setVal(Device,Port,Value)

calibrate = 0;
errorLimit = 1e-3;
queryLimit = 5;

%% Determine which voltage source is being used
name = Device.identifier;
errorFlag = 0;
% In reality, we should include a setVal function in each device class.
% That way it removes any checks and allows us to change functionality in
% a single place instead of calling specific functions here.

% What if we want to change frequency or amplitude?? This setVal doesn't
% really let us do that because we default to the aux out. Need to think
% of a better solution....

if contains(name,'SR830') || contains(name,'VmeasC') || contains(name,'VmeasE')
    if contains(Port,'Freq')
        Device.SR830setFreq(Value);
        %delay(0.3);
    elseif contains(Port,'Amp')
            Device.setSR830Amplitude(Value); %might need to change this, lookre at setters

    else
        Port = str2num(Port);
        Device.SR830setAuxOut(Port,Value); %might need to change this, lookre at setters

    end

elseif contains(name,'AP24') || contains(name,'DAC')

        if calibrate
            load(['AP24/AP24_' num2str(Port) '.mat']);
            vRange = -10:.5:10;
            Value = interp1(vRange,vRange.*m+b,Value);
        end

        Device.sigDACSetVoltage(Port,Value);

elseif contains(name,'AP16')

    if calibrate
        load(['AP16A/AP16A_' num2str(Port) '.mat']);
        vRange = -10:.5:10;
        Value = interp1(vRange,vRange.*m+b,Value);
    end
    Device.sigDACSetVoltage(Port,Value)

elseif contains(name,'SIM9') 
    Device.setSIM900Voltage(Port,Value); 

elseif contains(name,'IDC')
    Device.setSIM900Voltage(Port,Value); 
    Device.setSIM900Voltage(Port+1,Value);

elseif contains(name,',33220A,')
    if Port == 1
        Device.set33220VoltageLow(Value)
    elseif Port == 2
        Device.set33220VoltageHigh(Value)
    else
        fprintf('\nUnknown Port\n')
        errorFlag = -3;
    end
else
    fprintf('\nUnknown Device\n')
    errorFlag = -2;
end
end

