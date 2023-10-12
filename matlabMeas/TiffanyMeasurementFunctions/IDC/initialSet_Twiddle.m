function [] = initialSet_Twiddle(value, DAC, VmeasE, VmeasC, VtwiddleE, VdoorModE)

DCMap;
sigDACSetVoltage(DAC,EPort,0);

if contains(value,'start')
    sigDACSetVoltage(DAC,TopMetalPort,-1.5);
    SR830setAuxOut(VmeasE,1,5);
    SR830setAuxOut(VmeasE,2,5);
    SR830setAuxOut(VmeasE,3,-5);
    SR830setAuxOut(VmeasE,4,-5);
    
    % initialize Agilent
    amplitude = 200e-3;
    voltType = 'VRMS';
    voltageOffset = -1;
    frequency1 = 100.125e3;
    frequency2 = 89.5e3;

    devices  = [VtwiddleE VdoorModE];


    for i = 1:length(devices)
        set33220FunctionType(devices(i),'SIN');
        set33220VoltageOffset(devices(i),voltageOffset)

        if i == 1
            set33220Phase(devices(i),0);
            set33220Amplitude(devices(i),amplitude,voltType);
            set33220Frequency(devices(i),frequency1);
        else
            set33220Phase(devices(i),120);
            set33220Amplitude(devices(i),76e-3,voltType);
            set33220Frequency(devices(i),frequency2);
        end
        set33220OutputLoad(devices(i), 'INF');
        set33220Output(devices(i),0);  % start with output OFF
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