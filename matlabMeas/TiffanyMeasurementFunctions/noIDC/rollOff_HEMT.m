NetworkAnalyzer = HP3577A(0,11)
initHP3577AforRollOff(NetworkAnalyzer,100,70e3)
set3577Average(NetworkAnalyzer,'0');
set3577ASweepMode(NetworkAnalyzer,'SING');
% connect
set3577ASweepMode(NetworkAnalyzer,'CONT');
set3577Average(NetworkAnalyzer,'128');

pullAndPlot3577ARollOff(NetworkAnalyzer,100,70e3)

rolloff = 62.254e3;
Cinput = 1/(2*pi*rolloff*1.1e6)


set3577Average(NetworkAnalyzer,'0');
set3577ASweepMode(NetworkAnalyzer,'SING');
fclose(NetworkAnalyzer.client)
