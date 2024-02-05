function [] = twiddleSense1(instr, DAC, twiddleDevice, doorDevice, start, stop)
    % start = -1;
    % stop = 0;

    % bring sense and twiddle to base (-1,0,0,-1)
    sweep1DMeasSR830({'SEN'},start,stop,-0.05,0.5,5,{instr},DAC,{16},0,1);
    sweep1DMeasSR830({'TWW'},start,stop,-0.05,0.5,5,{instr},DAC,{twiddleDevice},0,1);
    
    % TuneAmplifier(instr,twiddleDevice,doorDevice,0.2,100.125e3)

    sweep1DMeasSR830({'Door'},start,stop,-0.05,0.1,10,{instr},DAC,{doorDevice},0,1); % lower door to let electrons in
    pause(5)
    sweep1DMeasSR830({'Door'},stop,start,-0.05,0.1,10,{instr},DAC,{doorDevice},0,1); % raise to close door
    
    % twiddle measurement
    stop = -1;
    start = 0;
    sweep1DMeasSR830({'TWW'},stop,start+0.6,-0.02,0.1,10,{instr},DAC,{twiddleDevice},1,1);

    sweep1DMeasSR830({'TWW'},0,-1+0.6,-0.02,0.1,10,{VmeasC},DAC,{TwiddleEPort},1,1);
    sweep1DMeasSR830({'Door'},-1,0,-0.05,0.1,10,{VmeasC},DAC,{DoorEInPort},0,1); % lower door to let electrons in
    sweep1DMeasSR830({'Door'},0,-1,-0.05,0.1,10,{VmeasC},DAC,{DoorEInPort},0,1); % lower door to let electrons in

    sweep1DMeasSR830({'Door'},-1,0,-0.05,0.1,10,{VmeasE},DAC,{DoorEClosePort},0,1);

    sweep1DMeasSR830({'Door'},0.5,-0.5,-0.05,0.1,10,{VmeasC},DAC,{DoorCInPort},0,1); % lower door to let electrons in
    sweep1DMeasSR830({'TWW'},0.5,0.5-0.4,-0.02,0.1,10,{VmeasC},DAC,{TwiddleCPort},1,1);
    sweep1DMeasSR830({'Door'},-1,-0.1,-0.05,0.1,10,{VmeasE},DAC,{DoorEInPort},0,1); % lower door to let electrons in
end




    sweep1DMeasSR830({'Door'},-1,-0,-0.05,0.1,10,{VmeasC},DAC,{DoorEInPort},0,1); % lower door to let electrons in
    sweep1DMeasSR830({'TWW'},0,-1+0.6,-0.02,0.1,10,{VmeasC},DAC,{TwiddleEPort},1,1);
