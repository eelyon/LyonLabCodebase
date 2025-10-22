%% Script that moves single electron into avalanche ccd
% First need to load a single electron using shuttleElectrons function into
% ts1 and shuttle single electron from ts1 to ts2. Then shuttle electron
% all the way down to the avalanche ccd. "electron" and move ccd back in
% case electron  is in one of the other 6 channels. If get electron back in
% ts2, then need to move electron one up using the vertical ccd. Measure
% electron again in ts2, then mov down avalanche ccd and store. Move ccd
% back to ts2 and see if I measure electron again. Do this procedure up to
% 5 times (if electron is in bottom most channel) until I don't measure
% electron meaning that I most likely stored it at the end of the avalanche
% ccd.

numSteps = 5; % sigDACRampVoltage
numStepsRC = 5; % sigDACRamp
waitTimeRC = 1100; % in microseconds
vload = -0.3;
vopen = 1; % holding voltage of ccd
vclose = -1; % closing voltage of ccd

%% Move electron from Sommer-Tanner to twiddle-sense 1
loadTwiddleSense1(pinout, numSteps, numStepsRC, waitTimeRC, vload, vopen, vclose)
delay(1)

MFLISweep1D({'Guard1'},0.2,-1.2,0.05,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0,'time_constant',0.01,'demod_rate',1e3,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.device,{guard1_l.port},0,1);
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

%% Move electrons from twiddle-sense 1 to twiddle-sense 2
shuttleTwiddle1Twiddle2(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
delay(1)

MFLISweep1D({'Guard2'},0.2,-1,0.05,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0,'time_constant',0.01,'demod_rate',1e3,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard2'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.device,{guard2_l.port},0,1);
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)

% Check if twiddle-sense 1 is truly empty
MFLISweep1D({'Guard1'},0.2,-1,0.05,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0,'time_constant',0.01,'demod_rate',1e3,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.device,{guard1_l.port},0,1);
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

%% Move electron down to last gate before avalanche detector
shuttleAndStore(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
delay(1)

MFLISweep1D({'Guard2'},0.2,-1,0.05,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0,'time_constant',0.01,'demod_rate',1e3,'poll_duration',0.1);
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)

%% If electron is measured in ts2, then move to next ts2 above and repeat storing process
shuttleToTwiddle2Above(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
delay(1)

MFLISweep1D({'Guard2'},0.2,-1,0.05,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0,'time_constant',0.01,'demod_rate',1e3,'poll_duration',0.1);
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)

shuttleAndStore(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
delay(1)

MFLISweep1D({'Guard2'},0.2,-1,0.05,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0,'time_constant',0.01,'demod_rate',1e3,'poll_duration',0.1);
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)

% repeat above up to 5 times... only in case electron is in last channel

function loadTwiddleSense1(pinout, numSteps, numStepsRC, waitTimeRC, vload, vopen, vclose)
% Load electrons from Sommer-Tanner to twiddle-sense 1
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vload,numSteps) % open 1st door
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vload,numSteps) % open 2nd door
sigDACRampVoltage(pinout.d1_even.device,pinout.d1_even.port,vclose,numSteps);% close 1st door
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vopen,numSteps) % open 3rd door
sigDACRampVoltage(pinout.d2.device,pinout.d2.port,vclose,numSteps) % close 2nd door
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps) % open phi1
sigDACRampVoltage(pinout.d3.device,pinout.d3.port,vclose,numSteps) % close 3rd door

% Run CCD gates
ccd_units = 63; % number of repeating units in ccd array
for n = 1:ccd_units
    sigDACRampVoltage(pinout.phi1_2.device,pinout.phi1_2.port,vopen,numSteps) % open phi2
    sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps) % close phi1
    sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps) % open phi3
    sigDACRampVoltage(pinout.phi1_2.device,pinout.phi1_2.port,vclose,numSteps) % close phi2
    sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps) % open phi1
    sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps) % close phi3
end

sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
end

function shuttleTwiddle1Twiddle2(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vopen,numSteps)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vopen,numSteps)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vopen,numSteps)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)

sigDACRampVoltage(pinout.phi_Vdown_2.device,pinout.phi_Vdown_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)

for j = 1:75
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vclose, numSteps)
end

sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_Vup_1.device,pinout.d_Vup_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device,pinout.d_Vup_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_Vup_1.device,pinout.d_Vup_1.port,vclose,numSteps)

sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device,pinout.d_Vup_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.d7.device,pinout.d7.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)

sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
end

function shuttleAndStore(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d8.device,pinout.d8.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRamp(pinout.d8.device,pinout.d8.port,-2,numStepsRC,waitTimeRC) % make more neg. to trap electron
sigDACRamp(pinout.d9.device,pinout.d9.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vopen,numSteps)
sigDACRamp(pinout.d9.device,pinout.d9.port,vclose,numStepsRC,waitTimeRC)

for k = 1:22 % channel narrows after 13
    sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vclose,numSteps)
end

sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,-2,numSteps) % make more neg. to trap electron
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.trap1_2.device,pinout.trap1_2.port,-2,numSteps)
sigDACRampVoltage(pinout.trap2_2.device,pinout.trap2_2.port,-2,numSteps)
sigDACRampVoltage(pinout.trap2_1.device,pinout.trap2_1.port,-1,numSteps)
sigDACRampVoltage(pinout.trap1_1.device,pinout.trap1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vclose,numSteps)

% Now move ccd back to ts2 and measure but leave d10 closed
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vopen,numSteps)
sigDACRampVoltage(pinout.trap2_1.device,pinout.trap2_1.port,-2,numSteps)
sigDACRampVoltage(pinout.trap1_1.device,pinout.trap1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vclose,numSteps)

for k = 1:22
    sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vclose,numSteps)
end

sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi2_3.device,pinout.phi2_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi2_2.device,pinout.phi2_2.port,vclose,numSteps)
sigDACRamp(pinout.d9.device,pinout.d9.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi2_1.device,pinout.phi2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRamp(pinout.d9.device,pinout.d9.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d8.device,pinout.d8.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d8.device,pinout.d8.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
end

function shuttleToTwiddle2Above(pinout, numSteps, numStepsRC, waitTimeRC, vopen, vclose)
sigDACRamp(pinout.d7.device, pinout.d7.port, vopen, numStepsRC, waitTimeRC)
sigDACRamp(pinout.twiddle2.device, pinout.twiddle2.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.guard2_l.device, pinout.guard2_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRamp(pinout.sense2_l.device, pinout.sense2_l.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
sigDACRamp(pinout.d7.device, pinout.d7.port, vclose, numStepsRC, waitTimeRC)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_1.device, pinout.phi1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi1_3.device, pinout.phi1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.d4.device, pinout.d4.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_Vup_1.device, pinout.d_Vup_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_1.device, pinout.d_Vup_1.port, vclose, numSteps)

for j = 1:76
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vclose, numSteps)
end

sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_3.device, pinout.phi_Vdown_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_2.device, pinout.phi_Vdown_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vdown_1.device, pinout.phi_Vdown_1.port, vclose, numSteps)

for i = 1:3
    sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, vclose, numSteps)
end

sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vup_3.device, pinout.phi_Vup_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vup_2.device, pinout.phi_Vup_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_Vup_3.device, pinout.d_Vup_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_Vup_1.device, pinout.phi_Vup_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device, pinout.d_Vup_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_Vup_3.device, pinout.d_Vup_3.port, vclose, numSteps)

sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_Vup_2.device,pinout.d_Vup_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi1_1.device,pinout.phi1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.d7.device,pinout.d7.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi1_3.device,pinout.phi1_3.port,vclose,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)

sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)
end