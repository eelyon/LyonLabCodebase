function [] = loadTwiddleTiff(DAC,SR830,STOut,STIn,STM,Door, targetSTOut,targetSTIn,targetSTM,deltaDoor)
    
    startSTOut = getVal(DAC,STOut);
    startSTIn = getVal(DAC,STIn);
    startSTM = getVal(DAC,STM );
    startDoor = getVal(DAC,Door);
    
    disp("Ramping STM to STI");
    rampVal(DAC,STM,startSTM,startSTIn,0.05,0.05);

    disp("Ramping ST Out");
    rampVal(DAC,STOut,startSTOut,targetSTOut,0.05,0.05);

    disp("Ramping STM");
    rampVal(DAC,STM,startSTIn,targetSTM,0.05,0.05);

    disp("Ramping ST In");
    rampVal(DAC,STIn,startSTIn,targetSTIn,0.05,0.05);

    rampVal(DAC,Door,startDoor,0,0.05,0.05);
    sweep1DMeasSR830({'Door'},0,-0.5,0.01,1,25,{SR830},DAC,{Door},0);
end

