%% Script for sweeping the top metal negative to get rid of electrons
Vclean = 2;
numSteps = 500;

%% Set Sommer-Tanner gates positive
% sigDACRampVoltage(STM.Device,STM.Port,Vclean,numSteps);
% sigDACRampVoltage(STD.Device,STD.Port,Vclean,numSteps);
% sigDACRampVoltage(STS.Device,STS.Port,Vclean,numSteps); 

%% Open all CCD gates
% sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclean,numSteps); % open phi1
% sigDACRampVoltage(ccd2.Device,ccd2.Port,Vclean,numSteps); % open phi2
% sigDACRampVoltage(ccd3.Device,ccd3.Port,Vclean,numSteps); % open phi3

%% Loop top metal sweep and unload electrons
for n = 1:5
    sweep1DMeasSR830({'TM'},-1,-2,0.2,3,5,{SR830Twiddle},TM.Device,{TM.Port},1,1);
    TwiddleUnload_Full;
end

%% Set Sommer-Tanner gates back to 0V
% sigDACRampVoltage(STM.Device,STM.Port,0,numSteps);
% sigDACRampVoltage(STD.Device,STD.Port,0,numSteps);
% sigDACRampVoltage(STS.Device,STS.Port,0,numSteps);