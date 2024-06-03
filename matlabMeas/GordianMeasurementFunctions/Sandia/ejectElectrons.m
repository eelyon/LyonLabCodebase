%% Script for removing all electrons from device
Pinout_240530;

waitTime = 0.1; % set wait time for voltage ramps

rampVal(FilBack(1),FilBack(2),getVal(FilBack(1),FilBack(2)),+3,+0.05,waitTime); % make backing plate positive
rampVal(TM(1),TM(2),getVal(TM(1),TM(2)),+1,+0.05,waitTime); % make top metal positive

%% Check if electrons are still there with Sommer-Tanner
sweep1DMeasSR830('ST',0,-0.6,-0.02,0.1,9,"SR830",STM(1),STM(2),1)
delay(5); % wait

%% Set underlying gates negative
gateDevices = [STD(1),STS(1),STM(1),STGuard(1),M2Shield(1),BPGuard(1),d1_ccd(1),d2_ccd(1)];
ccdDevices = [d3_ccd(1),d4_ccd(1),ccd1(1),ccd2(1),ccd3(1),d_diff(1),dm1_gl(1),dm1_t(1),dm1_gr(1),dm1_sl(1),dm1_ol(1),shield(1)];
gatePorts = [STD(2),STS(2),STM(2),STGuard(2),M2Shield(2),BPGuard(2),d1_ccd(2),d2_ccd(2)];
ccdPorts = [d3_ccd(2),d4_ccd(2),ccd1(2),ccd2(2),ccd3(2),d_diff(2),dm1_gl(2),dm1_t(2),dm1_gr(2),dm1_sl(2),dm1_ol(2),shield(2)];
interleavedRamp([gateDevices,ccdDevices],[gatePort,ccdPorts],-2,10,waitTime);

delay(5); % wait
rampVal(TM(1),TM(2),getVal(TM(1),TM(2)),-2,-0.05,waitTime); % make top metal negative
fprintf('Electrons are ejected.\n')