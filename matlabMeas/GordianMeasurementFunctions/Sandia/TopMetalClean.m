%% Script for sweeping the top metal negative to get rid of electrons
Vclean = 2;
numSteps = 1000;

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
    sweep1DMeasSR830({'TM'},-1.5,-3,0.25,3,10,{SR830Twiddle},TM.Device,{TM.Port},1,1);
    CCDunload;
end

% CCDclean;