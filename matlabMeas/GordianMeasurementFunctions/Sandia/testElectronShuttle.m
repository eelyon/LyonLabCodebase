%% Script for testing shuttling electrons from twiddle 1 to twiddle 2
numSteps = 10; % sigDACRampVoltage
numStepsRC = 10; % sigDACRamp
waitTimeRC = 1100; % 5 times time constant
Vopen = 5;
Vclose = -2;

MFLISweep1D({'Guard1'},0.4,-0.8,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.Device,{guard1_l.Port},0,1);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % reset guard

sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vopen,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vopen,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.Device,twiddle1.Port,Vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(d6.Device,d6.Port,Vopen,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vclose,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)

sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)

sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)

for a = 1:3
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
end

sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vclose,numSteps)

sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.Device,twiddle1.Port,0,numStepsRC,waitTimeRC)
delay(1)

MFLISweep1D({'Guard1'},0.4,-0.8,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.Device,{guard1_l.Port},0,1);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % reset guard

sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)

for a = 1:3
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
    sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
    sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
end

sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)

sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vopen,numSteps)
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vopen,numSteps)
sigDACRampVoltage(d6.Device,d6.Port,Vclose,numSteps)
sigDACRampVoltage(guard1_r.Device,guard1_r.Port,Vopen,numSteps)
sigDACRamp(twiddle1.Device,twiddle1.Port,Vopen,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,Vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(sense1_r.Device,sense1_r.Port,Vclose,numSteps)
sigDACRamp(sense1_l.Device,sense1_l.Port,Vopen,numStepsRC,waitTimeRC)

sigDACRampVoltage(guard1_r.Device,guard1_r.Port,-2,numSteps)
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC)
sigDACRamp(twiddle1.Device,twiddle1.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC)
sigDACRamp(sense1_l.Device,sense1_l.Port,0,numStepsRC,waitTimeRC)
delay(1)

MFLISweep1D({'Guard1'},0.5,-0.8,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.1);
% sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.Device,{guard1_l.Port},0,1);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % reset guard

% sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vopen,numSteps)
% sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
% sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vopen,numSteps)
% sigDACRampVoltage(phi_Vdown_2.Device,phi_Vdown_2.Port,Vclose,numSteps)
% 
% sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
% sigDACRampVoltage(phi_Vdown_3.Device,phi_Vdown_3.Port,Vclose,numSteps)
% 
% for a = 1:3
%     sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
%     sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
%     sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
%     sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
%     sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vopen,numSteps)
%     sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
% end
% 
% sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vopen,numSteps)
% sigDACRampVoltage(phi_Vup_1.Device,phi_Vup_1.Port,Vclose,numSteps)
% sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vopen,numSteps)
% sigDACRampVoltage(phi_Vup_2.Device,phi_Vup_2.Port,Vclose,numSteps)
% sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vopen,numSteps)
% sigDACRampVoltage(phi_Vup_3.Device,phi_Vup_3.Port,Vclose,numSteps)
% sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vopen,numSteps)
% sigDACRampVoltage(d_Vup_1.Device,d_Vup_1.Port,Vclose,numSteps)
% 
% sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
% sigDACRampVoltage(d_Vup_2.Device,d_Vup_2.Port,Vclose,numSteps)
% sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
% sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
% sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vopen,numSteps)
% sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
% sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps)
% sigDACRampVoltage(phi1_1.Device,phi1_1.Port,Vclose,numSteps)
% sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vopen,numSteps)
% sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps)
% sigDACRamp(d7.Device,d7.Port,Vopen,numStepsRC,waitTimeRC) % door for compensation of sense 1
% sigDACRampVoltage(phi1_3.Device,phi1_3.Port,Vclose,numSteps)
% sigDACRamp(sense2_l.Device,sense2_l.Port,Vopen,numStepsRC,waitTimeRC)
% sigDACRamp(guard2_l.Device,guard2_l.Port,Vopen,numStepsRC,waitTimeRC)
% sigDACRamp(twiddle2.Device,twiddle2.Port,Vopen,numStepsRC,waitTimeRC)
% sigDACRamp(d7.Device,d7.Port,-2,numStepsRC,waitTimeRC)
% 
% sigDACRamp(sense2_l.Device,sense2_l.Port,0,numStepsRC,waitTimeRC)
% sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)
% sigDACRamp(twiddle2.Device,twiddle2.Port,0,numStepsRC,waitTimeRC)
% delay(1)
% 
% MFLISweep1D({'Guard2'},0.4,-0.8,0.1,'dev32061',guard2_l.Device,guard2_l.Port,0,'time_constant',0.1,'demod_rate',100,'poll_duration',0.1);
% % sweep1DMeasSR830({'Guard2'},0.2,-1,-0.1,3,5,{SR830Twiddle},guard2_l.Device,{guard2_l.Port},0,1);
% sigDACRamp(guard2_l.Device,guard2_l.Port,0,numStepsRC,waitTimeRC)