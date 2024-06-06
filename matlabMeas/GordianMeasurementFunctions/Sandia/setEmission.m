%% This script sets relevant gate voltages for emission
DCPinout; % load DC pinout script
deltaVal = 0.05; % set step size
waitTime = 0.02; % set wait time after each voltage step

%% Set Sommer-Tanner
rampVal(TM.Device,TM.Port,getVal(TM.Device,TM.Port),-0.5,deltaVal,waitTime); % ramp top metal
rampVal(STG.Device,STG.Port,5,getVal(STG.Device,STG.Port),-1,deltaVal,waitTime); % ramp Sommer-Tanner (left) guard
rampVal(M2S.Device,M2S.Port,getVal(M2S.Device,M2S.Port),-0.5,deltaVal,waitTime); % ramp M2 shield
rampVal(BPG.Device,BPG.Port,getVal(BPG.Device,BPG.Port),-1,deltaVal,waitTime); % ramp bond pad guard
fprintf('Sommer-Tanner set for emission.\n'); delay(2);

%% Set ccd gates
stopVal = -1;

rampVal(d1_ccd.Device,d1_ccd.Port,getVal(d1_ccd.Device,d1_ccd.Port),stopVal,deltaVal,waitTime)
rampVal(d2.ccd.Device,d2_ccd.Port,getVal(d2.ccd.Device,d2_ccd.Port),stopVal,deltaVal,waitTime)
rampVal(d3_ccd.Device,d3_ccd.Port,getVal(d3_ccd.Device,d3_ccd.Port),stopVal,deltaVal,waitTime)
rampVal(d4_ccd.Device,d4_ccd.Port,getVal(d4_ccd.Device,d4_ccd.Port),stopVal,deltaVal,waitTime)
delay(2);

rampVal(ccd1.Device,ccd1.Port,getVal(ccd1.Device,ccd1.Port),stopVal,deltaVal,waitTime)
rampVal(ccd2.Device,ccd2.Port,getVal(ccd2.Device,ccd2.Port),stopVal,deltaVal,waitTime)
rampVal(ccd3.Device,ccd3.Port,getVal(ccd3.Device,ccd3.Port),stopVal,deltaVal,waitTime)
fprintf('CCDs set for emission.\n'); delay(2);

rampVal(d_diff.Device,d_diff.Port,getVal(d_diff.Device,d_diff.Port),stopVal,deltaVal,waitTime)
rampVal(dm1_gl.Device,dm1.gl.Port,getVal(dm1_gl.Device,dm1.gl.Port),stopVal,deltaVal,waitTime)
rampVal(dm1_t.Device,dm1_t.Port,getVal(dm1_t.Device,dm1_t.Port),stopVal,deltaVal,waitTime)
rampVal(dm1_gr.Device,dm1_gr.Port,getVal(dm1_gr.Device,dm1_gr.Port),stopVal,deltaVal,waitTime)
rampVal(dm1_sl.Device,dm1_sl.Port,getVal(dm1_sl.Device,dm1_sl.Port),stopVal,deltaVal,waitTime)
rampVal(dm1_ol.Device,dm1_ol.Port,getVal(dm1_ol.Device,dm1_ol.Port),stopVal,deltaVal,waitTime)
rampVal(shield.Device,shield.Port,getVal(shield.Device,shield.Port),stopVal,deltaVal,waitTime)
fprintf('Twiddle and sense set for emission.\n'); delay(2);

rampVal(fil.Device,fil.Port,getVal(fil.Device,fil.Port),-2,deltaVal,waitTime); % ramp filament backing plate
fprintf('Voltages set for emission.\n')