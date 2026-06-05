%% HEMT voltages

setAgilent33622APresetConfig('CharacterizeHEMT',Awg2Ch,1);
setAgilent33622APresetConfig('CharacterizeHEMT',Awg2Ch,2);

hDAC = HarvardDAC('COM5','hDAC', 8);

% turn on HEMTs at RT
HEMT1Channels = [0,1,2];    
HEMT2Channels = [3,4,5];
% turnOnHEMT_TL(hDAC,HEMT1Channels,2)
% turnOnHEMT_TL(hDAC,HEMT2Channels,2)

% turn on HEMTs when cold
turnOnHEMT_TL(hDAC,HEMT1Channels,1.7)
turnOnHEMT_TL(hDAC,HEMT2Channels,1.7)

% turn off HEMTS
turnOffHEMT_TL(hDAC,HEMT1Channels)
turnOffHEMT_TL(hDAC,HEMT2Channels)
SetAllDAC(hDAC,0);

