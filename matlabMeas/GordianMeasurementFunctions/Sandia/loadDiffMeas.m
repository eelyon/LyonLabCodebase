%% Script for loading 1st differential measurement section
waitTime = 0.001; % wait time after each voltage step
deltaVal = 0.1; % set voltage step size for ramp
Vopen = 2; % set holding voltage of gates
Vclose = -1; % set closing voltage

rampVal(dm1_gr.Device,dm1_gr.Port,getVal(dm1_gr.Device,dm1_gr.Port),-2,deltaVal,waitTime); % close door right of twiddle

rampVal(d_diff.Device,d_diff.Port,getVal(d_diff.Device,d_diff.Port),Vopen,deltaVal,waitTime); % open door
rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),Vclose,deltaVal,waitTime); % close phi1
rampVal(dm1_ol.Device,dm1_ol.Port,getVal(dm1_ol.Device,dm1_ol.Port),Vopen,deltaVal,waitTime); % open offset
rampVal(d_diff.Device,d_diff.Port,getVal(d_diff.Device,d_diff.Port),Vclose,deltaVal,waitTime); % close door
rampVal(dm1_sl.Device,dm1_sl.Port,getVal(dm1_sl.Device,dm1_sl.Port),0,deltaVal,waitTime); % open sense
rampVal(dm1_ol.Device,dm1_ol.Port,getVal(dm1_ol.Device,dm1_ol.Port),-2,deltaVal,waitTime); % close offset
rampVal(dm1_gl.Device,dm1_gl.Port,getVal(dm1_gl.Device,dm1_gl.Port),0,deltaVal,waitTime); % open left gate twiddle
rampVal(dm1_t.Device,dm1_t.Port,getVal(dm1_t.Device,dm1_t.Port),0,deltaVal,waitTime); % open twiddle
fprintf('Twiddle and sense loaded.\n');