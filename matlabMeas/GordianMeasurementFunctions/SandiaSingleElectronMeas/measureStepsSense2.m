numSteps = 5; % sigDACRampVoltage
numStepsRC = 5; % sigDACRamp
waitTimeRC = 1100; % in microseconds
vopen = 1; % holding voltage of ccd
vclose = -1; % closing voltage of ccd

% for j = 1:68
%     sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vopen, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vclose, numSteps)
% end
% 
% % Move electrons onto phi_v1_3
% sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
% sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)

for i = 1:3
fprintf(['-- Loading iteration no. ', num2str(i+6), ' --\n'])
sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vclose, numSteps)
sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)

% sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
% sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)
sigDACRampVoltage(pinout.d_v_1.device,pinout.d_v_1.port,+3,numSteps)
% sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, -1.8, numSteps)
% sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,-1.8,numSteps)
% sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,+5,numSteps)
sigDACRampVoltage(pinout.d_v_1.device,pinout.d_v_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vopen,numSteps)

sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
sigDACRamp(pinout.d7.device,pinout.d7.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,vclose,numStepsRC,waitTimeRC)
% 
% % Reset sense1 for measurement
% sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
% sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)

% Reset sense2 for measurement
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)

[nE,nErr] = measureElectronsFn(pinout,2,'vstart',0.1,'vstop',-0.7,'vstep',-0.01,'filter_order',2, ...
    'time_constant',0.5,'demod_rate',1e3,'poll',10,'sweep',1,'onoff',1);
fprintf(['n = ',num2str(nE),' +- ',num2str(nErr),'\n'])
end