% Script for moving electrons from Sommer-Tanner to first diff. meas. region
DCPinout;
deltaVal = 0.5; % voltage step for ramp
waitTime = 0.001; % set wait time after each voltage step
Vopen = 2; % holding voltage of ccd
Vclose = -1; % closing voltage of ccd

%% open first three doors
rampVal(d1_ccd.Device,d1_ccd.Port,getVal(d1_ccd.Device,d1_ccd.Port),Vopen,deltaVal,waitTime); % open 1st door
rampVal(d3_ccd.Device,d3_ccd.Port,getVal(d3_ccd.Device,d3_ccd.Port),Vopen,deltaVal,waitTime); % open 2nd door
rampVal(d1_ccd.Device,d1_ccd.Port,getVal(d1_ccd.Device,d1_ccd.Port),Vclose,deltaVal,waitTime); % close 1st door
rampVal(d4_ccd.Device,d4_ccd.Port,getVal(d4_ccd.Device,d4_ccd.Port),Vopen,deltaVal,waitTime); % open 3rd door
rampVal(d3_ccd.Device,d3_ccd.Port,getVal(d3_ccd.Device,d3_ccd.Port),Vclose,deltaVal,waitTime); % close 2nd door
fprintf('Doors opened.\n');

rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),Vopen,deltaVal,waitTime); % open phi1
rampVal(d4_ccd.Device,d4_ccd.Port,getVal(d4_ccd.Device,d4_ccd.Port),Vclose,deltaVal,waitTime); % close 3rd door
fprintf('Electrons loaded onto first ccd gate (phi1).\n'); delay(5);

ccd_units = 63; % number of repeating units in ccd array

for i = 1:ccd_units 
    rampVal(ccd2.Device,ccd2.Port,getVal(ccd2.Device,ccd2.Port),Vopen,deltaVal,waitTime); % open phi2
    rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),Vclose,deltaVal,waitTime); % close phi1
    rampVal(ccd3.Device,ccd3.Port,getVal(ccd3.Device,ccd3.Port),Vopen,deltaVal,waitTime); % open phi3
    rampVal(ccd2.Device,ccd2.Port,getVal(ccd2.Device,ccd2.Port),Vclose,deltaVal,waitTime); % close phi2
    rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),Vopen,deltaVal,waitTime); % open phi1
    rampVal(ccd3.Device,ccd3.Port,getVal(ccd3.Device,ccd3.Port),Vclose,deltaVal,waitTime); % close phi3
    fprintf(['CCD unit: ', num2str(i),'\n']);
end
fprintf(['Electrons moved ', num2str(ccd_units), ' ccd units.\n']);