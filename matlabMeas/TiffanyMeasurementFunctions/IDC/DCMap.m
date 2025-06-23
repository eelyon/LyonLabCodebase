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
TfCPort        = 13;
TfEPort        = 20; %careful, supplyDAC

%% Barriers
BEPort = 1; % bussed to 5
BCPort = 8; % tied to SP7

%% other barriers
BlockPort = 6; % bussed to 23


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
