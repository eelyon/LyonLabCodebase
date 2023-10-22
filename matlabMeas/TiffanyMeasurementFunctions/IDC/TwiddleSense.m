function [] = twiddleSense(instr, DAC, twiddlePort,sensePort, doorPort, twiddleDevice, doorDevice, start, stop)
    % start = -1;
    % stop = 0;
    DCMap;

    % bring sense and twiddle to base (-1,0,0,-1)
%     sweep1DMeasSR830({'SEN'},start,stop,-0.05,0.5,5,{instr},DAC,{sensePort},0,1);
%     sweep1DMeasSR830({'TWW'},start,stop,-0.05,0.5,5,{instr},DAC,{twiddlePort},0,1);
%     
%     TuneAmplifier(instr,twiddleDevice,doorDevice,0.2,100.125e3)

    sweep1DMeasSR830({'Door'},start,stop,-0.05,0.1,10,{instr},DAC,{doorPort},0,1); % lower door to let electrons in
    if strcmp(sensePort,'SenseEPort')
        sigDACRampVoltage(DAC,twiddlePort,0.4,1000);
        sigDACRampVoltage(DAC,STIBiasEPort,-0.1,1000);
    else
        sigDACRampVoltage(DAC,twiddlePort,0.4,1000);
        sigDACRampVoltage(DAC,STIBiasCPort,-0.3,1000);
    end    
    pause(5)
    sweep1DMeasSR830({'Door'},stop,start,-0.05,0.1,10,{instr},DAC,{doorPort},0,1); % raise to close door
    
    if strcmp(sensePort,'SenseEPort')
        sigDACRampVoltage(DAC,twiddlePort,0,1000);
        sigDACRampVoltage(DAC,STIBiasEPort,0,1000);
        pause(10)
        % twiddle measurement
        sweep1DMeasSR830({'TWW'},stop,-1+0.6,-0.02,0.1,10,{instr},DAC,{twiddlePort},1,1);
    else
        sigDACRampVoltage(DAC,twiddlePort,0,1000);
        sigDACRampVoltage(DAC,STIBiasCPort,0,1000);
        pause(10)
        % twiddle measurement
        sweep1DMeasSR830({'TWW'},stop,0-0.4,-0.02,0.1,10,{instr},DAC,{twiddlePort},1,1);
    end 
    
end