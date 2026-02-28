% need connect since calls it anew everytime in the DCConfig function
VtomV = 1e3;


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
TfEPort        = 6; %careful, harvad DAC H6 output

%% Barriers
BEPort = 1; % bussed to 5
BCPort = 8; % tied to SP7 (supply BoB)

%% other barriers
BlockPort = 6; % bussed to 23


%% Harvard DAC outputs
BackMetalPort      = 7; 

% Emitter Amplifier
VbbAmpEPort        = 0;
VccAmpEPort        = 1;
VccFollowerEPort   = 2; 

% Collector Amplifier
VbbAmpCPort        = 3;
VccAmpCPort        = 4;
VccFollowerCPort   = 5; 
