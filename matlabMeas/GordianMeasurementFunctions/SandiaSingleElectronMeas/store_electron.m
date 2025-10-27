% Script for moving electron into channel leading to avalanche detector
cap1 = 3.55e-12;
gain1 = 24*0.915*100;

start_vgd = 0.4;
stop_vgd = -1.4;
step_vgd = 0.05;

tc = 0.02;
drat = 10e3;
poll = 0.1;

vload = -0.3;
vopen = 1; % holding voltage of ccd
vclose = -1; % closing voltage of ccd

%% Move electron from Sommer-Tanner to twiddle-sense 1
% load_sense1(pinout,vload)
% delay(1)
% 
% MFLISweep1D({'Guard1'},start_vgd,stop_vgd,step_vgd,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
%     'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
% % sweep1DMeasSR830({'Guard1'},0.2,-1,-0.1,3,5,{SR830ST},guard1_l.device,{guard1_l.port},0,1);
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

%% Move electrons from twiddle-sense 1 to twiddle-sense 2
shuttle_sense1sense2(pinout)
delay(1)

MFLISweep1D({'Guard2'},start_vgd,stop_vgd,step_vgd,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
    'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)

% Check if sense 1 is truly empty
MFLISweep1D({'Guard1'},start_vgd,stop_vgd,step_vgd,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
    'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

%% Move electron down to last gate before avalanche detector
for i = 1:6
    shuttle_store(pinout)
    delay(1)
    
    [~,~,x,y,~,~,stdx,stdy] = MFLISweep1D({'Guard2'},start_vgd,stop_vgd,step_vgd,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
        'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
    
    num_elec = calc_electrons(x,y,cap1,gain1,0.52); % Calc. tot. no. of electrons
    
    if round(num_elec,0) == 0 % or if averaged, one can use stdev
        fprintf('Exiting loop. Electron is stored.\n')
        return
    elseif i == 6
        fprintf('Exiting loop. Electron should be in topmost sense 2. Measure...\n')
            MFLISweep1D({'Guard2'},start_vgd,stop_vgd,step_vgd,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
        'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
        sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
        return
    end

    shuttle_nextsense2(pinout)
    fprintf([num2str(i), '\n'])
end