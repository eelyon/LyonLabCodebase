function [] = initialSet(value, DAC, VmeasE, VmeasC, VpulsAgi, VpulsAgi2)

DCMap;
sigDACSetVoltage(DAC,EPort,0);

if contains(value,'start')
    sigDACSetVoltage(DAC,TopMetalPort,-2);
    SR830setAuxOut(VmeasE,1,5);
    SR830setAuxOut(VmeasE,2,5);
    SR830setAuxOut(VmeasE,3,-5);
    SR830setAuxOut(VmeasE,4,-5);

    SR830setAuxOut(VmeasC,1,4.5);
    SR830setAuxOut(VmeasC,2,-1.5);
    SR830setAuxOut(VmeasC,3,1.5);
    
    % initialize Agilent
    amp_high = 2.5;
    amp_low = 0;
    if exist('VpulsAgi2','var')
        devices  = [VpulsAgi VpulsAgi2];
    else 
        devices = VpulsAgi;
    end

    for i = 1:length(devices)
        set33220FunctionType(devices(i),'PULS');
        set33220VoltageHigh(devices(i), amp_high*2);
        set33220VoltageLow(devices(i), amp_low);
        set33220OutputLoad(devices(i), 50);
        
        set33220BurstMode(devices(i),'TRIG');
        set33220NumBurstCycles(devices(i),1);
        if i == 1
            set33220TriggerSource(devices(i),'BUS');
        else
            set33220TriggerSource(devices(i),'EXT');
        end
        set33220TrigSlope(devices(i),'POS');
        set33220BurstStateOn(devices(i),'ON');
        set33220Output(devices(i),'ON');
        
    end 

else
    SR830setAuxOut(VmeasE,1,0);
    SR830setAuxOut(VmeasE,2,0);
    SR830setAuxOut(VmeasE,3,0);
    SR830setAuxOut(VmeasE,4,0);
    SR830setAuxOut(VmeasC,1,0);
    SR830setAuxOut(VmeasC,2,0);
    SR830setAuxOut(VmeasC,3,0);
    SR830setAuxOut(VmeasC,4,0);

end

% get temperature
% resistance = queryHP34401A(Thermometer);
% temperature = Therm.tempFromRes(resistance)

end
