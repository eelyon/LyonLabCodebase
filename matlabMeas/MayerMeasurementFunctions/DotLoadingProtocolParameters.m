%% Voltage parameters for filament emission
BackingPlateVoltage = -2;
TMBias= 3;
TMVoltage = BackingPlateVoltage + TMBias;
channelBias = 0;
channelVoltages = BackingPlateVoltage + channelBias;

%% Final voltage configuration
dotBiasFromTop = 0;
finalTopMetalVoltage = 1;
finalDotVoltage = finalTopMetalVoltage + TMBias + dotBiasFromTop;
finalDoorVoltage = -2;
finalResVoltage = -3;

finalSTVoltage = 0;

%% Ramping parameters
numVoltages = 10;
waitTime = 0.03;