% Script shuttling electron along vertical CCD many times
% cin2 = 5.1e-12;
% gain2 = 22.7*0.86;

vstart = 0.2;
vstop = -0.7;
vstep = -0.05;
v_on = -0.3; % 1st channel
v_off = -0.7;

tc = 0.4;
drat = 10e3;
filter = 2;
poll = 10;

vopen = 4; % holding voltage of ccd
vclose = -1; % closing voltage of ccd

% Start with measuring electron
% measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
% 'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',0,'dalpha',dalpha,'cin',cin2,'gain',gain2);
% 
% % Confirm electron is in top channel
% electronsStore(pinout,'vopen',vopen,'vclose',vclose)
% measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
% 'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',0,'dalpha',dalpha,'cin',cin2,'gain',gain2);
% 
% % Release electrons
% electronsRelease(pinout,'vopen',vopen,'vclose',vclose)
measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',0,'dalpha',dalpha,'cin',cin2,'gain',gain2);

% for i = 1:5
%     fprintf(['-> Shuttle to channel no. ', num2str(i+1),'\n'])
% 
%     shuttleDownSense2(pinout,'vopen',vopen,'vclose',vclose) % Shuttle electrons up to next Sense2
%     measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
%     'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
% 
%     electronsStore(pinout,'vopen',vopen,'vclose',vclose) % Store electrons
%     fprintf('Electrons stored\n')
% 
%     measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
%     'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
% end
for i = 1:10
    for j = 1:100
        shuttleDownVertCCD(pinout,'vopen',vopen,'vclose',vclose,'numSteps',1,'numStepsRC',1)
        % fprintf('Electrons shuttled to 6th channel\n')
        % measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',-0.01,'v_on',-0.05,'v_off',v_off,'filter_order',filter, ...
        % 'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);

        shuttleUpVertCCD(pinout,'vopen',vopen,'vclose',vclose,'numSteps',1,'numStepsRC',1)
        % fprintf('Electrons shuttled to 1st channel\n')
        % measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',-0.01,'v_on',-0.3,'v_off',v_off,'filter_order',filter, ...
        % 'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
    end
fprintf(['->', num2str(i*100), 'shuttles performed \n'])

% Reset Sense2 for measurement
sigDACRampVoltage(pinout.guard2_r.device,pinout.guard2_r.port,-2,1)
sigDACRamp(pinout.d7.device,pinout.d7.port,-2,1,waitTimeRC)
sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,1,waitTimeRC)
sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,1,waitTimeRC)
sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,1,waitTimeRC)

measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',-0.3,'v_off',-0.7,'filter_order',filter, ...
'time_constant',0.4,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
end

% Confirm electron is not in top channel
electronsStore(pinout,'vopen',vopen,'vclose',vclose)
measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',0,'dalpha',dalpha,'cin',cin2,'gain',gain2);

% Confirm electron is not in top channel
electronsStore(pinout,'vopen',vopen,'vclose',vclose)
measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',0,'dalpha',dalpha,'cin',cin2,'gain',gain2);

% Release electrons
electronsRelease(pinout,'vopen',vopen,'vclose',vclose)
measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);