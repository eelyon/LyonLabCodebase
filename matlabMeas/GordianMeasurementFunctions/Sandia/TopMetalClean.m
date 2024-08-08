%% Script for sweeping the top metal negative to get rid of electrons
Vclean = 2;
numSteps = 1000;

sigDACRampVoltage(STM.Device,STM.Port,Vclean,numSteps); % open phi1
sigDACRampVoltage(STD.Device,STD.Port,Vclean,numSteps); % open phi2
sigDACRampVoltage(STS.Device,STS.Port,Vclean,numSteps); % open phi3  

% sigDACRampVoltage(ccd1.Device,ccd1.Port,Vclean,numSteps); % open phi1
% sigDACRampVoltage(ccd2.Device,ccd2.Port,Vclean,numSteps); % open phi2
% sigDACRampVoltage(ccd3.Device,ccd3.Port,Vclean,numSteps); % open phi3   

for i = 1:5
    sweep1DMeasSR830({'TM'},-1,-1.5,0.1,1,5,{SR830Twiddle},TM.Device,{TM.Port},1,1);
    CCDunload;
end

% CCDclean;