% Script for moving electrons into channel leading to avalanche detector
% i.e. moving electrons into 
% cap1 = 5e-12;
% gain1 = 24*0.915*100;

vstart = 0.5;
vstop = -1;
vstep = -0.05;

tc = 0.5;
drat = 10e3;
filter = 2;

vload = 0;
vopen = 4; % holding voltage of ccd
vclose = -1; % closing voltage of ccd

% storeE = 1;
% releaseE = 0;

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

% electronStore(pinout,'vopen',vopen,'vclose',vclose)
% measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'filter_order',filter, ...
% 'time_constant',tc,'demod_rate',drat,'poll',5,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);

for i = 1:4
    shuttleUpSense2(pinout)
    
    % if storeE == 1
        % Measure 
    measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'filter_order',filter, ...
    'time_constant',tc,'demod_rate',drat,'poll',5,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
    
    electronStore(pinout,'vopen',vopen,'vclose',vclose)
    fprintf('Electrons stored\n')
    
    measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'filter_order',filter, ...
    'time_constant',tc,'demod_rate',drat,'poll',5,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
    % fprintf(['n2 = ',num2str(ne2),' +- ',num2str(nerr2),'\n'])
    % end
    
    % if releaseE == 1
    %     electronRelease(pinout,'vopen',vopen,'vclose',vclose)
    %     fprintf('Electrons released\n')
    % 
    %     measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'filter_order',filter, ...
    %     'time_constant',tc,'demod_rate',drat,'poll',10,'sweep',1,'onoff',0,'dalpha',dalpha,'cin',cin2,'gain',gain2);
    %     % fprintf(['n2 = ',num2str(ne2),' +- ',num2str(nerr2),'\n'])
    % end
    % fprintf(['Electrons are in channel no. ', num2str(6-i),'/n'])
    fprintf(['Iteration no. ', num2str(i),'/n'])
end

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