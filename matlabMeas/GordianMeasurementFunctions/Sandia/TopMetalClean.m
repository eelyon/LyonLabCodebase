%% Script for sweeping the top metal negative to get rid of electrons
Vclean = 2;
numSteps = 100;

%% Set Sommer-Tanner gates positive
sigDACRampVoltage(STM.Device,STM.Port,Vclean,numSteps);
sigDACRampVoltage(STD.Device,STD.Port,Vclean,numSteps);
rampSIM900Voltage(STS.Device,STS.Port,Vclean,0.1,0.1); % ramp ST-Sense

%% Open all CCD gates
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclean,numSteps); % open phi1
sigDACRampVoltage(phi1_2.Device,phi1_2.Port,Vclean,numSteps); % open phi2
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclean,numSteps); % open phi3

%% Loop top metal sweep and unload electrons
for n = 1:5
    sweep1DMeasSR830({'TM'},-1,-2,0.2,3,5,{SR830Twiddle},TM.Device,{TM.Port},1,1);
    TwiddleUnload_Full;
end

%% Set Sommer-Tanner gates back to 0V
sigDACRampVoltage(STM.Device,STM.Port,0,numSteps);
sigDACRampVoltage(STD.Device,STD.Port,0,numSteps);
rampSIM900Voltage(STS.Device,STS.Port,0,0.1,0.1); % ramp ST-Sense
