function [] = initSigResThermo(SDG5122 ,initFreq, initAmp)
    set5122Output(SDG5122, 0, 1);
    set5122Output(SDG5122, 0, 2);

    set5122OutputLoad(SDG5122, 'HZ', 1);
    set5122OutputLoad(SDG5122, 'HZ', 2);
    set5122Polarity(SDG5122, 'NOR', 1);
    set5122Polarity(SDG5122, 'INVT', 2);

    set5122ModState(SDG5122, 1, 1);
    set5122ModState(SDG5122, 1, 2);
    set5122AMSource(SDG5122, 'EXT', 1);
    set5122AMSource(SDG5122, 'EXT', 2);

    set5122ModAmp(SDG5122, initAmp, 1);
    set5122ModAmp(SDG5122, initAmp, 2);
    set5122ModFreq(SDG5122, initFreq, 1);
    set5122ModFreq(SDG5122, initFreq, 2);

    set5122ModPhase(SDG5122, 0, 1);
    set5122ModPhase(SDG5122, 0, 2);

    set5122ModOffset(SDG5122, 0, 1);
    set5122ModOffset(SDG5122, 0, 2);
end