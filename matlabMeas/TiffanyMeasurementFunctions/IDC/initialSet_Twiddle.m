function [] = initialSet_Twiddle(value, DAC, VmeasE, VmeasC, VtwiddleE, VdoorModE)

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
    amplitude = 100e-3;
    voltType = 'VRMS';
    frequency = 101.9e3;

    if exist('VpulsAgi2','var')
        devices  = [VtwiddleE VdoorModE];
    else 
        devices = VtwiddleE;
    end

    for i = 1:length(devices)
        set33220FunctionType(devices(i),'SIN');
        set33220Amplitude(devices(i),amplitude,voltType);
        set33220Frequency(devices(i),frequency);
        set33220BurstMode(devices(i),'TRIG')
        if i == 1
            set33220BurstPhase(devices(i),0);
        else
            set33220BurstPhase(devices(i),225);
        end

        set33220OutputLoad(devices(i), 50);
        set33220BurstMode(devices(i),'TRIG');
        set33220NumBurstCycles(devices(i),'INF')
        set33220TriggerSource(devices(i),'BUS');
        set33220TrigSlope(devices(i),'POS');
        set33220BurstStateOn(devices(i),'ON');
        set33220Output(devices(i),'ON');
    end 
else
    instrList = [VmeasE,VmeasC];
    for i = instrList
        SR830setAuxOut(i,1,0);
        SR830setAuxOut(i,2,0);
        SR830setAuxOut(i,3,0);
        SR830setAuxOut(i,4,0);
    end
end

% get temperature
% temperature = Therm.tempFromRes(queryHP34401A(Thermometer))

end