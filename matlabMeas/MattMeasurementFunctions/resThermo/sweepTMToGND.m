guardPort = 2;
steps = 20;
stepSize = vguInit/steps;
vguInit = sigDACQueryVoltage(DAC, guardPort);

sweep1DMeasSR830({'TM'},vguInit,0,stepSize,1,10,{SR830},DAC,{2},0);