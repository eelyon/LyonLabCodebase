%% Script for sweeping the top metal negative to get rid of electrons
% numSteps = 20;
Vclean = 2;

%% Set Sommer-Tanner gates positive
sigDACRampVoltage(STM.Device,STM.Port,Vclean,numSteps)
sigDACRampVoltage(STD.Device,STD.Port,Vclean,numSteps)
sigDACRampVoltage(STS.Device,STS.Port,Vclean,numSteps)

%% Open all CCD gates
% sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclean,numSteps); % open phi1
% sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclean,numSteps); % open phi2
% sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclean,numSteps); % open phi3

% interleavedRamp(TM.Device,TM.Port,-0.8,numStepsRC,waitTime); % make top metal less negative
% sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclean,numSteps)

%% Loop top metal sweep and unload electrons
for n = 1:10
%     sweep1DMeasSR830({'TM'},-0.8,-1.4,-0.6,10,10,{SR830Twiddle},TM.Device,{TM.Port},1,1);
    TwiddleUnload_Full;
end

%% Set Sommer-Tanner gates back to 0V
sigDACRampVoltage(STM.Device,STM.Port,0,numSteps)
sigDACRampVoltage(STD.Device,STD.Port,0,numSteps)
sigDACRampVoltage(STD.Device,STD.Port,0,numSteps)
