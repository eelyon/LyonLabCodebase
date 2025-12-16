% Sweep vload and measure sense 1
vload = -0.2:0.005:-0.17;
% start_vgd = 0.1;
% stop_vgd = -0.8;
% step_vgd = 0.05;

% tc = 0.1;
% drat = 13e3;
% poll = 1;

% cap1 = 3.16e-12;
% gain1 = 24*0.92;

for value = vload
    loadSense1(pinout,value); delay(1)
    % shuttleSense1Sense2(pinout); delay(1)
    [ne,nerr] = measureElectronsFn(pinout,1,'vstart',0.1,'vstop',-0.8,'vstep',-0.05, ...
        'filter_order',2,'time_constant',0.8,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1);
    delay(1)
%     [~,~,x,y,~,~,stdx,stdy] = MFLISweep1D({'Guard1'},start_vgd,stop_vgd,step_vgd, ...
%         'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0,'filter_order',3,'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
%     sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

%     mag = correct_mag(x,y); % Get corrected magnitude
%     delta = max(mag) - min(mag); % Calc. change in signal
%     num_electrons = calc_electrons(x,y,cap1,gain1,0.52); % Calc. tot. no. of electrons
    fprintf(['-> For vload = ',num2str(value),'V, num_electrons = ',num2str(ne),'\n'])
    % shuttleSense2Sense1(pinout); delay(1)
    unloadSense1(pinout);
    delay(1)
%     unloadSense1(pinout)
%     if num_electrons <= 1
%         fprintf(['Exiting loop. Loaded ', num2str(num_electrons),' electrons.'])
%         return
%     else
%         unloadSense1(pinout)
%     end
end