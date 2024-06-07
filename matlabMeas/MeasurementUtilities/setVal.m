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
        Device.SR830setAmplitude(Value); %might need to change this, lookre at setters
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

elseif contains(name,'SIM9') || contains(name,'IDC')
    if Value == 0
        Value = 0.25;
    end
    Device.setSIM900Voltage(Port,Value); 

elseif contains(name,'33220A')
    if Port == 1
        Device.set33220VoltageLow(Value)
    elseif Port == 2
        Device.set33220VoltageHigh(Value)
    elseif Port == 3
        Device.set33220Phase(Value);
    elseif Port == 4
        Device.set33220Amplitude(Value,'VPP')
    elseif Port == 5
        Device.set33220VoltageOffset(Value)
    else
        fprintf('\nUnknown Port\n')
        errorFlag = -3;
    end
elseif contains(name,'33622A')
    % Honestly this 33622A portion is pretty bad. The port should also be
    % passed in but I'm just going to assume port 2 is the one that will
    % vary......
    if Port == 3
        Device.set33622APhase(Value,2);
    elseif Port == 4
        Device.set33622AAmplitude(Value,'VPP',2)
    end
elseif contains(name,'SDG5122') || contains(name,'5122')
    if contains(Port, 'ModPhase1')
        set5122ModPhase(Device, Value, 1)
    end
    if contains(Port, 'ModPhase2')
        set5122ModPhase(Device, Value, 2)
    end
    if contains(Port, 'ModAmp1')
        set5122ModAmp(Device, Value, 1)
    end
    if contains(Port, 'ModAmp2')
        set5122ModAmp(Device, Value, 2)
    end
    if contains(Port, 'BasePhase1')
        set5122Phase(Device, Value, 1)
    end
    if contains(Port, 'BasePhase2')
        set5122Phase(Device, Value, 2)
    end
    if contains(Port, 'BaseAmp1')
        set5122Amp(Device, Value, 1)
    end
    if contains(Port, 'BaseAmp2')
        set5122Amp(Device, Value, 2)
    end
    if contains(Port,'DualModFreq')
        set5122ModFreq(Device, Value, 1);
        set5122ModFreq(Device, Value, 2);
    end
else
    fprintf('\nUnknown Device\n')
    errorFlag = -2;
end
end

