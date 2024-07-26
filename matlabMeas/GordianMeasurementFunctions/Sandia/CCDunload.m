% Script for moving electrons from Sommer-Tanner to first diff. meas. region
DCPinout;
deltaVal = 0.25; % voltage step for ramp
waitTime = 0.01; % set wait time after each voltage step
Vopen = 2; % holding voltage of ccd
Vclose = -1; % closing voltage of ccd

% Note - turn off AC on twiddle?
rampVal(dm1_ol.Device,dm1_ol.Port,getVal(dm1_ol.Device,dm1_ol.Port),Vopen,deltaVal,waitTime); % open offset
rampVal(dm1_t.Device,dm1_t.Port,getVal(dm1_t.Device,dm1_t.Port),Vclose,deltaVal,waitTime); % close twiddle
rampVal(dm1_gl.Device,dm1_gl.Port,getVal(dm1_gl.Device,dm1_gl.Port),Vclose,deltaVal,waitTime); % close left gate twiddle
rampVal(dm1_sl.Device,dm1_sl.Port,getVal(dm1_sl.Device,dm1_sl.Port),Vclose,deltaVal,waitTime); % close sense

ccd_units = 63; % number of repeating units in ccd array

for i = 1:ccd_units 
    rampVal(ccd3.Device,ccd3.Port,getVal(ccd3.Device,ccd3.Port),Vopen,deltaVal,waitTime); % open phi3
    rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),Vclose,deltaVal,waitTime); % close phi1
    rampVal(ccd2.Device,ccd2.Port,getVal(ccd2.Device,ccd2.Port),Vopen,deltaVal,waitTime); % open phi2
    rampVal(ccd3.Device,ccd3.Port,getVal(ccd3.Device,ccd3.Port),Vclose,deltaVal,waitTime); % close phi3
    rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),Vopen,deltaVal,waitTime); % open phi1
    rampVal(ccd2.Device,ccd2.Port,getVal(ccd2.Device,ccd2.Port),Vclose,deltaVal,waitTime); % close phi2
    fprintf(['CCD unit: ', num2str(i),'\n']);
end
fprintf(['Electrons moved ', num2str(ccd_units), ' ccd units.\n']);

% Unload ccd
rampVal(d4_ccd.Device,d4_ccd.Port,getVal(d4_ccd.Device,d4_ccd.Port),Vopen,deltaVal,waitTime); % open 3rd door
rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),Vclose,deltaVal,waitTime); % cslose phi1
rampVal(d3_ccd.Device,d3_ccd.Port,getVal(d3_ccd.Device,d3_ccd.Port),Vload,deltaVal,waitTime); % open 2nd door
rampVal(d4_ccd.Device,d4_ccd.Port,getVal(d4_ccd.Device,d4_ccd.Port),Vclose,deltaVal,waitTime); % close 3rd door
rampVal(d1_ccd.Device,d1_ccd.Port,getVal(d1_ccd.Device,d1_ccd.Port),Vload,deltaVal,waitTime); % open 1st door
rampVal(d3_ccds.Device,d3_ccd.Port,getVal(d3_ccd.Device,d3_ccd.Port),Vclose,deltaVal,waitTime); % close 2nd door
rampVal(d1_ccd.Device,d1_ccd.Port,getVal(d1_ccd.Device,d1_ccd.Port),Vclose,deltaVal,waitTime); % close 1st door
fprintf('Electrons loaded back onto ST-drive.\n');