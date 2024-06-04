%% Script for loading 1st differential measurement section
waitTime = 0.01;

rampVal(d_diff(1),d_diff(2),getVal(d_diff(1),d_diff(2)),+3,+0.2,waitTime); % open door
rampVal(ccd1(1),ccd1(2),getVal(ccd1(1),ccd1(2)),-1,-0.2,waitTime); % close phi1
rampVal(dm1_ol(1),dm1_ol(2),getVal(dm1_ol(1),dm1_ol(2)),+3,+0.2,waitTime); % open offset
rampVal(d_diff(1),d_diff(2),getVal(d_diff(1),d_diff(2)),-1,-0.2,waitTime); % close door
rampVal(dm1_sl(1),dm1_sl(2),getVal(dm1_sl(1),dm1_sl(2)),+3,+0.2,waitTime); % open sense
rampVal(dm1_ol(1),dm1_ol(2),getVal(dm1_ol(1),dm1_ol(2)),-1,-0.2,waitTime); % close offset
rampVal(dm1_gl(1),dm1_gl(2),getVal(dm1_gl(1),dm1_gl(2)),+1,+0.2,waitTime); % open left gate twiddle
rampVal(dm1_t(1),dm1_t(2),getVal(dm1_t(1),dm1_t(2)),+1,+0.2,waitTime); % open twiddle
