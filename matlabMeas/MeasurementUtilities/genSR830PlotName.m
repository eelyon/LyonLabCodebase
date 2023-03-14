function plotName = genSR830PlotName(targetGate)
    switch targetGate
        case 'GND'
            plotName = 'PlaneSweep';
        case 'ST'
            plotName = 'Pinchoff';
        case 'TM'
            plotName = 'TopMetalSweep';
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
    end
end