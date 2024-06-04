%% Script for moving electrons from Sommer-Tanner to first diff. meas. region
Pinout_240530;

waitTime = 0.01; % set wait time for DAC between bias steps

% Do I need to tilt the Sommer-Tanner? Create voltage differential from
% STD, STM, to STS

%% open first three doors
rampVal(d1_ccd(1),d1_ccd(2),getVal(d1_ccd(1),d1_ccd(2)),+3,+0.2,waitTime); % open 1st door
rampVal(d3_ccd(1),d3_ccd(2),getVal(d3_ccd(1),d3_ccd(2)),+3,+0.2,waitTime); % open 2nd door
rampVal(d1_ccd(1),d1_ccd(2),getVal(d1_ccd(1),d1_ccd(2)),-1,-0.2,waitTime); % close 1st door
rampVal(d4_ccd(1),d4_ccd(2),getVal(d4_ccd(1),d4_ccd(2)),+3,+0.2,waitTime); % open 3rd door
rampVal(d3_ccd(1),d3_ccd(2),getVal(d3_ccd(1),d3_ccd(2)),-1,-0.2,waitTime); % close 2nd door

rampVal(ccd1(1),ccd1(2),getVal(ccd1(1),ccd1(2)),+3,+0.2,waitTime); % open phi1
rampVal(d4_ccd(1),d4_ccd(2),getVal(d4_ccd(1),d4_ccd(2)),-1,-0.2,waitTime); % close 3rd door

delay(10);

ccd_units = 63; % number of repeating units in ccd array

for i = 1:ccd_units 
    rampVal(ccd2(1),ccd2(2),getVal(ccd2(1),ccd2(2)),+3,+0.2,waitTime); % open phi2
    rampVal(ccd1(1),ccd1(2),getVal(ccd1(1),ccd1(2)),-1,-0.2,waitTime); % close phi1
    rampVal(ccd3(1),ccd3(2),getVal(ccd3(1),ccd3(2)),+3,+0.2,waitTime); % open phi3
    rampVal(ccd2(1),ccd2(2),getVal(ccd2(1),ccd2(2)),-1,-0.2,waitTime); % close phi2
    rampVal(ccd1(1),ccd1(2),getVal(ccd1(1),ccd1(2)),+3,+0.2,waitTime); % open phi1
    rampVal(ccd3(1),ccd3(2),getVal(ccd3(1),ccd3(2)),-1,-0.2,waitTime); % close phi3
    fprintf(['CCD unit: ', num2str(i),'\n']);
end