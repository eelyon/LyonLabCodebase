%% Voltage parameters for filament emission
BackingPlateVoltage = -1;
TMBias= 4;
TMVoltage = BackingPlateVoltage + TMBias;
channelBias = 0;
channelVoltages = BackingPlateVoltage + channelBias;

%% Final voltage configuration
dotBiasFromTop = 0;
finalTopMetalVoltage = 1;
finalDotVoltage = finalTopMetalVoltage + dotBiasFromTop;
finalDoorVoltage = -2;
finalResVoltage = -3;

finalSTVoltage = 0;

%% Ramping parameters
numVoltages = 10;
waitTime = 0.3;