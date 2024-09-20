% need connect since calls it anew everytime in the DCConfig function

%% Emitter
TopEPort       = 17;
STOBiasEPort   = 2;
StmEPort       = 4;
STIBiasEPort   = 14;

DoorEInPort       = 16;
TwiddleEPort      = 15;
SenseEPort        = 3;
DoorEOutPort      = 18;


%% Collector
TopCPort        = 21;

STOBiasCPort    = 24;
StmCPort        = 9;
STIBiasCPort    = 11;

DoorCInPort      = 22;
TwiddleCPort     = 20;
SenseCPort       = 12;
DoorCOutPort     = 19;

%% Thin Film
TfCPort        = 8; %bused to 13
TfEPort        = 5; %tied to sp20

%% Barriers
BEPort = 1; % bused to 6
BCPort = 7; % tied to sp7

%% Supply Voltages

BackMetalPort   = 5;  % supply voltage

% Emitter Amplifier
VbbAmpEPort   = 23;
VccAmpEPort   = 24;
VccFollowerEPort   = 13; 

% Collector Amplifier
VbbAmpCPort   = 16;
VccAmpCPort   = 14;
VccFollowerCPort   = 15; 
