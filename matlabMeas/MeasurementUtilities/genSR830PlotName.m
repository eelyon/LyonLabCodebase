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
        case 'DoorOut'
            plotName = 'DoorOutSweep';
        case 'DP'
            plotName = 'DotPotentialSweep';
        case 'Pair'
            plotName = 'PairSweep';
        case 'Freq'
            plotName = 'FrequencySweep';
        case 'ThermoFreq'
            plotName = 'ThermometryFrequencySweep';
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
        case 'PHAS'
            plotName = 'Ag33220PhaseSweep';
        case 'Vrms'
            plotName = 'Vrms';
        case 'Vpp'
            plotName = 'Vpp';
        case 'Guard'
            plotName = 'Guard';
    end
end