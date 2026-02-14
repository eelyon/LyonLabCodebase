% Script for moving electrons into channel leading to avalanche detector
% i.e. moving electrons into 
% cap1 = 5e-12;
% gain1 = 24*0.915*100;

vstart = 0.2;
vstop = -1;
vstep = 0.05;

tc = 0.4;
drat = 10e3;
filter = 2;

vload = 0;
vopen = 4; % holding voltage of ccd
vclose = -1; % closing voltage of ccd

% %% Move electrons from Sommer-Tanner to Sense 1
% loadSense1(pinout,vload); delay(1)
% MFLISweep1D_getSample({'Guard1'},vstart,vstop,vstep,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
%         'filter_order',filter,'time_constant',tc,'demod_rate',drat);
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard
% delay(1)
% 
% %% Move electrons from Sense 1 to Sense 2
% shuttleSense1Sense2(pinout); delay(1)
% MFLISweep1D_getSample({'Guard2'},vstart,vstop,vstep,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
%         'filter_order',filter,'time_constant',tc,'demod_rate',drat);
% sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
% 
% Check if sense 1 is truly empty
% MFLISweep1D_getSample({'Guard1'},vstart,vstop,vstep,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
%         'filter_order',filter,'time_constant',tc,'demod_rate',drat);
% sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard
% delay(1)

%% Move electron(s) along 2nd horizontal CCD and trap them
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vclose,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d8.device,pinout.d8.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRamp(pinout.d8.device,pinout.d8.port,vclose,numStepsRC,waitTimeRC) % make more neg. to trap electron
sigDACRamp(pinout.d9.device,pinout.d9.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,-2,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
sigDACRamp(pinout.d9.device,pinout.d9.port,vclose,numStepsRC,waitTimeRC)

for k = 1:22 % channel narrows after 11
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
end

sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,-2,numSteps) % make more neg. to trap electron in parallel channels
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.trap1.device,pinout.trap1.port,-1,numSteps)
sigDACRampVoltage(pinout.trap3.device,pinout.trap3.port,-1,numSteps)
sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,-1,numSteps)
sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vopen,numSteps)
sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vclose,numSteps)
delay(1)

%% Move electrons in parallel channels back to Sense 2 and measure
for k = 1:22
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
end

sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
sigDACRampVoltage(pinout.d9.device,pinout.d9.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
sigDACRampVoltage(pinout.d9.device,pinout.d9.port,vclose,numSteps)
sigDACRampVoltage(pinout.d8.device,pinout.d8.port,vopen,numSteps)
sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
sigDACRampVoltage(pinout.sense2_r.device,pinout.sense2_r.port,vopen,numSteps)
sigDACRampVoltage(pinout.d8.device,pinout.d8.port,vclose,numSteps)
sigDACRampVoltage(pinout.guard2_r.device,pinout.guard2_r.port,vopen,numSteps)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
sigDACRampVoltage(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numSteps)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)

% Reset sense2 for measurement
sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)

[ne2,nerr2] = measureElectronsFn(pinout,2,'vstart',0,'vstop',-0.8,'vstep',-0.02,'filter_order',2, ...
'time_constant',0.4,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'v_on',-0.25,'v_off',-0.8, ...
'dalpha',dalpha,'cin',cin2,'gain',gain2);
fprintf(['n2 = ',num2str(ne2),' +- ',num2str(nerr2),'\n'])

% %% Move electrons out of avalanche trap
% sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vopen,numSteps)
% sigDACRampVoltage(pinout.trap4.device,pinout.trap4.port,-2,numSteps)
% sigDACRampVoltage(pinout.trap2.device,pinout.trap2.port,vclose,numSteps)
% sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
% sigDACRampVoltage(pinout.d10.device,pinout.d10.port,vclose,numSteps)
% 
% for k = 1:22
%     sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
%     sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
%     sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
% end
% 
% sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vopen,numSteps)
% sigDACRampVoltage(pinout.phi_h2_3.device,pinout.phi_h2_3.port,vclose,numSteps)
% sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vopen,numSteps)
% sigDACRampVoltage(pinout.phi_h2_2.device,pinout.phi_h2_2.port,vclose,numSteps)
% sigDACRamp(pinout.d9.device,pinout.d9.port,vopen,numStepsRC,waitTimeRC)
% sigDACRampVoltage(pinout.phi_h2_1.device,pinout.phi_h2_1.port,vclose,numSteps)
% sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
% sigDACRamp(pinout.d9.device,pinout.d9.port,vclose,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.d8.device,pinout.d8.port,vopen,numStepsRC,waitTimeRC)
% sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
% sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vopen,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.d8.device,pinout.d8.port,vclose,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,vopen,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.sense2_r.device,pinout.sense2_r.port,vclose,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
% 
% % Reset Sense2 for measurement
% sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
% sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)

% [ne2,nerr2] = measureElectronsFn(pinout,2,'vstart',0,'vstop',-0.8,'vstep',-0.02,'filter_order',2, ...
% 'time_constant',0.4,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'v_on',-0.25,'v_off',-0.8, ...
% 'dalpha',dalpha,'cin',cin2,'gain',gain2);
% fprintf(['n2 = ',num2str(ne2),' +- ',num2str(nerr2),'\n'])

% %% Move electron down to last gate before avalanche detector
% for i = 1:6
%     shuttle_store(pinout)
%     delay(1)
% 
%     [~,~,x,y,~,~,stdx,stdy] = MFLISweep1D({'Guard2'},vstart,vstop,vstep,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
%         'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
%     sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
% 
%     num_elec = calc_electrons(x,y,cap1,gain1,0.52); % Calc. tot. no. of electrons
% 
%     if round(num_elec,0) == 0 % or if averaged, one can use stdev
%         fprintf('Exiting loop. Electron is stored.\n')
%         return
%     elseif i == 6
%         fprintf('Exiting loop. Electron should be in topmost sense 2. Measure...\n')
%             MFLISweep1D({'Guard2'},vstart,vstop,vstep,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
%         'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
%         sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
%         return
%     end
% 
%     shuttleNextSense2(pinout)
%     fprintf([num2str(i), '\n'])
% end