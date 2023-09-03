function plotName = genSR830PlotName(targetGate)
    switch targetGate
        case 'GND'
            plotName = 'PlaneSweep';
        case 'ST'
            plotName = 'Pinchoff';
        case 'TM'
            plotName = 'TopMetalSweep';
        case 'TMHeat'
            plotName = 'TopMetalHeatingSweep';
        case 'TC'
            plotName = 'TopCSweep';
        case 'TE'
            plotName = 'TopESweep';
        case 'Res'
            plotName = 'ReservoirSweep';
        case 'Door'
            plotName = 'DoorSweep';
        case 'DP'
            plotName = 'DotPotentialSweep';
        case 'Pair'
            plotName = 'PairSweep';
        case 'Freq'
            plotName = 'FrequencySweep';
        case 'IDC'
            plotName = 'IDCSweep';
        case 'TFE'
            plotName = 'ThinFilmEmitterSweep';
        case 'TFC'
            plotName = 'ThinFilmCollectorSweep';
        case 'TWW'
            plotName = 'TwiddleAmplitudeSweep';
        case 'SEN'
            plotName = 'SenseAmplitudeSweep';
        case 'Amp'
            plotName = 'TwiddleSenseSweep';
    end
end