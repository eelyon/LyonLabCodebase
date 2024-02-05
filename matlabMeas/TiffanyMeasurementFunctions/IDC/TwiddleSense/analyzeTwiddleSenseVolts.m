% scan twiddle amplitude from 100mV to 500mV

lockInDevice = VmeasC;
twdDevice = VtwiddleE;
doorDevice = VdoorModE;
twdAmp = 500e-3:-100e-3:100e-3;
doorOpenVolts = -0.6:0.1:-0.2; % better to work in the few electron regime

for i =twdAmp

    set33220Amplitude(twdDevice,i,'VRMS');
    SR830setSensitivity(lockInDevice,19)
    SR830setAmplitude(lockInDevice, i)
    VcloseDoor = -0.8;

    % clean electrons off
    sigDACRampVoltage(DAC,DoorEInPort,0,1000);
    pause(2)
    sigDACRampVoltage(DAC,TwiddleEPort,-1.5,1000);
    pause(5)
    sigDACRampVoltage(DAC,SenseEPort,-1.5,1000);
    pause(5)
    sigDACRampVoltage(DAC,DoorEInPort,-0.8,1000);
    pause(2)
    sigDACRampVoltage(DAC,[SenseEPort,TwiddleEPort],[0,0],1000);
    pause(1)

    compensateParasitics(lockInDevice,doorDevice,-360,180,10,0.01,i,0.01,0)

    % let electrons in    
    for j = doorOpenVolts
        
        sweep1DMeasSR830({'Door'},VcloseDoor,j,-0.01,0.1,10,{VmeasC},DAC,{DoorEInPort},0,1); % lower door to let electrons in
        pause(2)
        sweep1DMeasSR830({'Door'},j,VcloseDoor,-0.03,0.1,5,{VmeasC},DAC,{DoorEInPort},0,1); % close door
        pause(10)
        sweep1DMeasSR830({'TWW'},0,0.5,-0.02,0.1,10,{lockInDevice},DAC,{TwiddleEPort},1,1);
    end
end
