%% Script for loading 1st differential measurement section
rampVal(d_diff(1),d_diff(2),getVal(d_diff(1),d_diff(2)),+3,+0.2,waitTime); % open door
rampVal(ccd1(1),ccd1(2),getVal(ccd1(1),ccd1(2)),-1,-0.2,waitTime); % close phi1
