% vload = -0.14;
% 
% loadSense1(pinout,vload);
% measureElectronsFn(pinout,1);
% 
% sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vhigh,numSteps)
% sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vlow,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vlow,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vlow,numStepsRC,waitTimeRC)
% sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vlow,numSteps)
% sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vlow,numSteps)
% sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vlow,numSteps)
% sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vlow,numSteps)
% sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
% sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
% sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vlow,numSteps)
% sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vhigh,numSteps)
% sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
% 
% for j = 1:10
%     sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vhigh, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vlow, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vhigh, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vlow, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vhigh, numSteps)
%     sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vlow, numSteps)
% end
% 
% Reset sense1 for measurement
% sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
% sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)
% 
% measureElectronsFn(pinout,1);

for j = 1:10
    sigDACRampVoltage(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vlow,numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_v1_1.device,pinout.phi_v1_1.port,vlow,numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vhigh,numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device,pinout.phi_v1_3.port,vlow,numSteps)
end

sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vlow,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vlow,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vhigh,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vhigh,numSteps)
sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vlow,numSteps)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vhigh,numSteps)
sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vlow,numSteps)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vhigh,numSteps)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vlow,numSteps)
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vlow,numSteps)

% Reset sense1 for measurement
sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)

measureElectronsFn(pinout,1);