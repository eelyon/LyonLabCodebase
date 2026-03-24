%% for measuring input capacitance of HEMT circuit
NetworkAnalyzer = HP3577A(0,11);
initHP3577AforRollOff(NetworkAnalyzer,3e3,100e3)
set3577ASweepMode(NetworkAnalyzer,'SING');
% connect
set3577ASweepMode(NetworkAnalyzer,'CONT');
set3577Average(NetworkAnalyzer,'0');
set3577Average(NetworkAnalyzer,'128');

pullAndPlot3577ARollOff(NetworkAnalyzer,3e3,100e3)

rolloff = 55.9e3;
Cinput = 1/(2*pi*rolloff*1e6)
Cinput = 1/(2*pi*rolloff*1.1e6)

set3577Average(NetworkAnalyzer,'0');
set3577ASweepMode(NetworkAnalyzer,'SING');
fclose(NetworkAnalyzer.client)

%% for measuring roll off of HEMT
NetworkAnalyzer = HP3577A(0,11);
initHP3577AforRollOff(NetworkAnalyzer,1e3,10e6)
set3577Average(NetworkAnalyzer,'0');
set3577ASweepMode(NetworkAnalyzer,'SING');
% connect
set3577ASweepMode(NetworkAnalyzer,'CONT');
set3577Average(NetworkAnalyzer,'128');

pullAndPlot3577ARollOff(NetworkAnalyzer,1e3,10e6)