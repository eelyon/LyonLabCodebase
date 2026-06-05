function [] = twiddleSensePush(instr, DAC, twiddlePort, doorPort, start, stop)
    % start = -1;
    % stop = 0;
    
    DCMap;
    sweep1DMeasSR830({'Door'},start,stop,-0.05,0.1,10,{instr},DAC,{doorPort},0,1); % lower door to let electrons in
    sigDACRampVoltage(DAC,twiddlePort,0.4,1000);
    sigDACRampVoltage(DAC,STIBiasEPort,-0.1,1000);
    pause(5)
    sweep1DMeasSR830({'Door'},stop,start,-0.05,0.1,10,{instr},DAC,{doorPort},0,1); % raise to close door
 
    % twiddle measurement
    sweep1DMeasSR830({'TWW'},stop,-1+0.6,-0.02,0.1,10,{instr},DAC,{twiddlePort},1,1);
end

