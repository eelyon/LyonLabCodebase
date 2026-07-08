% Script for shuttling electrons back and forth sense 1 and sense 2
% vload = -0.3;
start_vgd = 0.4;
stop_vgd = -2;
step_vgd = 0.05;

tc = 0.02;
drat = 1e3;
poll = 0.1;

%% Move electrons from Sommer-Tanner to twiddle-sense 1
% load_sense1(pinout,-0.3)
% delay(1)
% 
% MFLISweep1D({'Guard1'},0.2,-1.2,0.05,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
%     'time_constant',tc,'drat',drat,'poll_duration',poll);
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

for i = 1:10
    %% Move electrons from twiddle-sense 1 to twiddle-sense 2
    shuttleSense1Sense2(pinout)
    delay(1)
    
    MFLISweep1D({'Guard2'},start_vgd,stop_vgd,step_vgd,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
        'time_constant',tc,'drat',drat,'poll_duration',poll);
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
    
    % Check if twiddle-sense 1 is truly empty
    MFLISweep1D({'Guard1'},start_vgd,stop_vgd,step_vgd,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
        'time_constant',tc,'drat',drat,'poll_duration',poll);
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard
    
    %% Move electrons from twiddle-sense 2 to twiddle-sense 1
    shuttleSense2Sense1(pinout)
    delay(1)
    
    MFLISweep1D({'Guard1'},start_vgd,stop_vgd,step_vgd,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
        'time_constant',tc,'drat',drat,'poll_duration',poll);
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard
    
    % Check if twiddle-sense 2 is truly empty
    MFLISweep1D({'Guard2'},start_vgd,stop_vgd,step_vgd,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
        'time_constant',tc,'drat',drat,'poll_duration',poll);
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
end

%% Move electrons from twiddle-sense 1 to Sommer-Tanner
% unload_sense1(pinout)
% delay(1)

% % Check electron signal in twiddle-sense 1
% MFLISweep1D({'Guard1'},0.2,-1.2,0.1,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
%     'time_constant',tc,'drat',drat,'poll_duration',poll);
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)