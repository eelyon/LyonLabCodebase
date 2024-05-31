function [] = ejectTwiddleTiff(DAC,SR830,STOut,STIn,STM,Door, targetSTOut,targetSTIn,targetSTM)
    
    startSTOut = getVal(DAC,STOut);
    startSTIn = getVal(DAC,STIn);
    startSTM = getVal(DAC,STM );
    startDoor = getVal(DAC,Door);
    
    disp("Ramping STOut");
    rampVal(DAC,STOut,startSTOut,targetSTOut,0.05,0.05);

    disp("Ramping STM");
    rampVal(DAC,STM,startSTM,targetSTM,0.05,0.05);
    disp("Ramping STIn");
    rampVal(DAC,STIn,startSTIn,targetSTIn,0.05,0.05);

    disp("Ramping Door");
    rampVal(DAC,Door,startDoor,0.75,0.05,0.05);
    delay(10);
    sweep1DMeasSR830({'Door'},0.75,startDoor,0.05,1,25,{SR830},DAC,{Door},0);
end