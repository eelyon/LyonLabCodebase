function [] = twiddleSenseClean(instr, DAC, twiddlePort,sensePort, doorPort, twiddleDevice, doorDevice, start, stop)
    % start = -1;
    % stop = 0;
    sweep1DMeasSR830({'Door'},start,stop,-0.05,0.5,5,{instr},DAC,{twiddlePort},0,1); 
    sweep1DMeasSR830({'TWW'},stop,start,-0.05,0.5,5,{instr},DAC,{twiddlePort},0,1);
    sweep1DMeasSR830({'SEN'},stop,start,-0.05,0.5,5,{instr},DAC,{sensePort},0,1);
    pause(5)
    sweep1DMeasSR830({'Door'},stop,start,-0.05,0.5,5,{instr},DAC,{doorPort},0,1);
    
    sweep1DMeasSR830({'SEN'},start,stop,-0.05,0.5,5,{instr},DAC,{sensePort},0,1);
    sweep1DMeasSR830({'TWW'},start,stop,-0.05,0.5,5,{instr},DAC,{twiddlePort},0,1);
    
    TuneAmplifier(instr,twiddleDevice,doorDevice,0.2,100.125e3)
    
    % twiddle measurement
    sweep1DMeasSR830({'TWW'},stop,-1+0.6,-0.02,0.1,10,{instr},DAC,{twiddlePort},1,1);
end