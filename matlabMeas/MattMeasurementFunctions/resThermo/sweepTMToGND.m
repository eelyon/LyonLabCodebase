guardPort = 2;
steps = 40;
stepSize = vguInit/steps;
vguInit = sigDACQueryVoltage(DAC, guardPort);

sweep1DMeasSR830({'TM'},vguInit,0,stepSize,1,15,{SR830},DAC,{2},0);