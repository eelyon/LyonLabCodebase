NetworkAnalyzer = HP3577A(0,11);

fclose(NetworkAnalyzer.client);
NetworkAnalyzer.client.InputBufferSize = 50000;
NetworkAnalyzer.client.OutputBufferSize = 50000;
fopen(NetworkAnalyzer.client);
query(NetworkAnalyzer.client,'ID?')

set3577ASweepMode(NetworkAnalyzer,'SING')
set3577Attenuation(NetworkAnalyzer,'R','20dB')
set3577Impedance(NetworkAnalyzer,'R','1Meg')
set3577AStartFrequency(NetworkAnalyzer,100)
set3577AStopFrequency(NetworkAnalyzer,50e3)