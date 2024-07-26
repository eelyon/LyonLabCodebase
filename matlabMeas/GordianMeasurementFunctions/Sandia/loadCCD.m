% Script for moving electrons from Sommer-Tanner to loading electrons onto
% the first ccd gate
DCPinout;
deltaVal = 0.2; % voltage step for ramp
waitTime = 0.001; % set wait time after each voltage step
Vload = 0.2; % set voltage on first two doors to control no. of electrons
Vopen = 2; % holding voltage of ccd
Vclose = -1; % closing voltage of ccd

%% open first three doors
rampVal(d1_ccd.Device,d1_ccd.Port,getVal(d1_ccd.Device,d1_ccd.Port),Vload,deltaVal,waitTime); % open 1st door
rampVal(d3_ccd.Device,d3_ccd.Port,getVal(d3_ccd.Device,d3_ccd.Port),Vload,deltaVal,waitTime); % open 2nd door
rampVal(d1_ccd.Device,d1_ccd.Port,getVal(d1_ccd.Device,d1_ccd.Port),Vclose,deltaVal,waitTime); % close 1st door
rampVal(d4_ccd.Device,d4_ccd.Port,getVal(d4_ccd.Device,d4_ccd.Port),Vopen,deltaVal,waitTime); % open 3rd door
rampVal(d3_ccds.Device,d3_ccd.Port,getVal(d3_ccd.Device,d3_ccd.Port),Vclose,deltaVal,waitTime); % close 2nd door
fprintf('Electrons loaded onto third door.\n');

rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),Vopen,deltaVal,waitTime); % open phi1
rampVal(d4_ccd.Device,d4_ccd.Port,getVal(d4_ccd.Device,d4_ccd.Port),Vclose,deltaVal,waitTime); % close 3rd door
fprintf('Electrons loaded onto first ccd gate (phi1).\n'); delay(5);