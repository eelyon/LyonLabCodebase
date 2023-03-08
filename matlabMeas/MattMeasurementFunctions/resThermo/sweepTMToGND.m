guardPort = 2;
vguInit = sigDACQueryVoltage(DAC, guardPort);

sweep1DMeasSR830({'TM'},vguInit,0,vguInit/10,1,10,{SR830},DAC,{2},0)