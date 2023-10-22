% DotLoadingProtocolParameters;
% %% Ramp Backing Plate to Backing Plate Voltage
% disp(strcat("Ramping Backing Plate to ", num2str(BackingPlateVoltage), " Volts."));
% rampVal(BackingMetalDevice,BackingMetalPort,getVal(BackingMetalDevice,BackingMetalPort),BackingPlateVoltage,-0.1,waitTime);
% DACGUI.updateDACGUI;
% drawnow;
% 
% %% Sweep the Door and Reservoir to the backing plate voltage
% disp(strcat("Ramping Res and Door to ", num2str(channelVoltages), " Volts."));
% interleavedRamp([Door100Device,Res100Device],[Door100Port,Res100Port],[channelVoltages,channelVoltages],numVoltages,waitTime);
% %sweepGatePairs(Door100Device,Res100Device,Door100Port,Res100Port,channelVoltages,channelVoltages,numVoltages,waitTime);
% DACGUI.updateDACGUI;
% drawnow;
% 
% disp(strcat("Ramping Sommer Tanner Gates to ", num2str(channelVoltages), " Volts."));
% interleavedRamp([Bias100Device,STM100Device],[Bias100Port,STM100Port],[channelVoltages,channelVoltages],numVoltages,waitTime);
% %sweepGatePairs(Bias100Device,STM100Device,Bias100Port,STM100Port,channelVoltages,channelVoltages,numVoltages,waitTime);
% DACGUI.updateDACGUI;
% drawnow;
numVoltages = 100;
waitTime = .05;
TMVoltage = 2;
%% Sweep Top Metal and Dot Potential to an attractive bias relative to the backing plate.
%disp(strcat("Ramping Top and Dots to ", num2str(TMVoltage), " Volts."));
%interleavedRamp([Top100Device,Dot100Device],[Top100Port,Dot100Port],[TMVoltage,TMVoltage],numVoltages,waitTime);
%sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,TMVoltage,TMVoltage,numVoltages,waitTime);

%% Update GUIs to keep up with parameters.
DACGUI.updateDACGUI;
drawnow;

pause(5);

input('\nFlash\n')
% 
disp('Flashing Filament');
AWG.send33220Trigger();

pause(1);

finalDotVoltage = 6;
finalTopMetalVoltage = 1;
%% Ramp all gates to their final voltages
disp(strcat("Ramping Top and Dots to ", num2str(finalTopMetalVoltage), " and ", num2str(finalDotVoltage), " Volts."));
%sweepGatePairs(Top100Device,Dot100Device,Top100Port,Dot100Port,finalTopMetalVoltage,finalDotVoltage,50,.03);
interleavedRamp([Top100Device,Dot100Device],[Top100Port,Dot100Port],[finalTopMetalVoltage,finalDotVoltage],numVoltages,waitTime);
% disp(strcat("Ramping Door and Res to ", num2str(finalResVoltage), " and ", num2str(finalDoorVoltage), " Volts."));
% %sweepGatePairs(Door100Device,Res100Device,Door100Port,Res100Port,finalDoorVoltage,finalResVoltage,numVoltages,waitTime);
% interleavedRamp([Door100Device,Res100Device],[Door100Port,Res100Port],[finalDoorVoltage,finalResVoltage],numVoltages,waitTime);
% disp(strcat("Ramping STL/R and STM to ", num2str(finalSTVoltage), " and ", num2str(finalSTVoltage), " Volts."));
%sweepGatePairs(Bias100Device,STM100Device,Bias100Port,STM100Port,0,0,numVoltages,waitTime);
%interleavedRamp([Bias100Device,STM100Device],[Bias100Port,STM100Port],[finalSTVoltage,finalSTVoltage],numVoltages,waitTime);
DACGUI.updateDACGUI;
drawnow;
