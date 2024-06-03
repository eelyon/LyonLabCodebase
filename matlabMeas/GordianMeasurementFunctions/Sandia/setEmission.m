%% This script sets relevant gate voltages for emission
%% Sommer-Tanner pinout
Pinout_240530;

%% ramp voltages
waitTime = 0.1;

rampVal(TM(1),TM(2),getVal(TM(1),TM(2)),-0.75,-0.05,waitTime); % ramp top metal
rampVal(STGuard(1),STGuard(2),getVal(STGuard(1),STGuard(2)),-1,-0.05,waitTime); % ramp Sommer-Tanner (left) guard
rampVal(M2Shield(1),M2Shield(2),getVal(M2Shield(1),M2Shield(2)),-0.5,-0.05,waitTime); % ramp M2 shield
rampVal(BPGuard(1),BPGuard(2),getVal(BPGuard(1),BPGuard(2)),-0.75,-0.05,waitTime); % ramp bond pad guard

%% ramp remaining gates to -1V
gateDevices = [d1_ccd(1),d2_ccd(1),d3_ccd(1),d4_ccd(1),ccd1(1),ccd2(1),ccd3(1),d_diff(1),dm1_gl(1),dm1_t(1),dm1_gr(1),dm1_sl(1),dm1_ol(1),shield(1)];
gatePorts = [d1_ccd(2),d2_ccd(2),d3_ccd(2),d4_ccd(2),ccd1(2),ccd2(2),ccd3(2),d_diff(2),dm1_gl(2),dm1_t(2),dm1_gr(2),dm1_sl(2),dm1_ol(2),shield(2)];
interleavedRamp(gateDevices,gatePorts,-2,10,waitTime);

rampVal(FilBack(1),FilBack(2),getVal(FilBack(1),FilBack(2)),-2,-0.05,waitTime); % ramp filament backing plate
fprintf('Voltages set for emission.\n')