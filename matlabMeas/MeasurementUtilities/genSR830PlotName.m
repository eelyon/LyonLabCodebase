function plotName = genSR830PlotName(targetGate)
    switch targetGate
        case 'GND'
            plotName = 'PlaneSweep';
        case 'ST'
            plotName = 'Pinchoff';
        case 'TM'
            plotName = 'TopMetalSweep';
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
    end
end