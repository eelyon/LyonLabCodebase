%% Script for loading electrons on sense and twiddle of 1st differential 
waitTime = 0.001; % wait time after each voltage step
deltaVal = 0.2; % set voltage step size for ramp
Vopen = 2; % set holding voltage of gates
Vclose = -1; % set closing voltage

%% Set sense, shield and twiddle to 0V
rampVal(dm1_sl.Device,dm1_sl.Port,getVal(dm1_sl.Device,dm1_sl.Port),0,deltaVal,waitTime); % open sense
rampVal(dm1_gl.Device,dm1_gl.Port,getVal(dm1_gl.Device,dm1_gl.Port),0,deltaVal,waitTime); % open left gate twiddle
rampVal(dm1_t.Device,dm1_t.Port,getVal(dm1_t.Device,dm1_t.Port),0,deltaVal,waitTime); % open twiddle
rampVal(dm1_gr.Device,dm1_gr.Port,getVal(dm1_gr.Device,dm1_gr.Port),-2,deltaVal,waitTime); % close door right of twiddle
fprintf('Sense, twiddle, and shields gate voltages set.\n');

%% Move electrons onto door before offset
rampVal(d_diff.Device,d_diff.Port,getVal(d_diff.Device,d_diff.Port),Vopen,deltaVal,waitTime); % open door
rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),Vclose,deltaVal,waitTime); % close phi1
% rampVal(dm1_ol.Device,dm1_ol.Port,getVal(dm1_ol.Device,dm1_ol.Port),Vopen,deltaVal,waitTime); % open offset
% rampVal(d_diff.Device,d_diff.Port,getVal(d_diff.Device,d_diff.Port),Vclose,deltaVal,waitTime); % close door
fprintf('Electrons loaded onto compensation door.\n');