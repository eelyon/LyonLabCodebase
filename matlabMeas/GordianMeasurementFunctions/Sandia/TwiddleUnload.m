% Script for unloading electrons from the first twiddle-sense
DCPinout;
numSteps = 1000;
Vopen = 2; % holding voltage of ccd
Vclose = -1; % closing voltage of ccd

% Set potential gradient across twiddle to door to eject electrons
sigDACRampVoltage(shieldl.Device,shieldl.Port,0,numSteps); % open left shield
sigDACRampVoltage(door.Device,door.Port,1.5,numSteps); % open door
sigDACRampVoltage(ccd1.Device,ccd1.Port,Vopen,numSteps); % open ccd1
% sigDACRampVoltage(ccd3.Device,ccd3.Port,Vopen,numSteps); % open ccd3

%% Sweep doors
sweep1DMeasSR830({'Door'},-1,1,0.1,1,9,{SR830Twiddle},offset.Device,{offset.Port},0);
sweep1DMeasSR830({'TWW'},0,-3,0.1,1,9,{SR830Twiddle},controlDAC,{18},0);
% rampVal(dm1_t.Device,dm1_t.Port,getVal(dm1_t.Device,dm1_t.Port),Vclose,deltaVal,waitTime); % close twiddle
% rampVal(dm1_gl.Device,dm1_gl.Port,getVal(dm1_gl.Device,dm1_gl.Port),Vclose,deltaVal,waitTime); % close left gate twiddle