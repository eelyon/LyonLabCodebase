%% Connect to HP3577A network analyzer
NetworkAnalyzer = HP3577A(0,11);

fclose(NetworkAnalyzer.client);
NetworkAnalyzer.client.InputBufferSize = 50000;
NetworkAnalyzer.client.OutputBufferSize = 50000;
fopen(NetworkAnalyzer.client);
query(NetworkAnalyzer.client,'ID?')

%% Set up network analyzer for measurement
set3577ASweepMode(NetworkAnalyzer,'SING')
set3577Impedance(NetworkAnalyzer,'R','1Meg')
% set3577Impedance(NetworkAnalyzer,'R','50ohm')
set3577Attenuation(NetworkAnalyzer,'R','20dB')

set3577AStartFrequency(NetworkAnalyzer,100)
set3577AStopFrequency(NetworkAnalyzer,50e3)

% set3577ASweepMode(NetworkAnalyzer,'CONT')
set3577Average(NetworkAnalyzer,'0')
% set3577Average(NetworkAnalyzer,'128')
% 
% pullAndPlot3577ARollOff(NetworkAnalyzer,100,50e3)