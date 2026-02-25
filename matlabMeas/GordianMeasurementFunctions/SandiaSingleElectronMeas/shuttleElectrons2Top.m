% Script for moving electrons into channel leading to avalanche detector
% cap2 = 5.1e-12;
% gain2 = 22.7*0.86;

vstart = 0.2;
vstop = -0.7;
vstep = -0.05;
v_on = -0.25;
v_off = -0.7;

tc = 0.5;
drat = 10e3;
filter = 2;
poll = 5;

vopen = 4; % holding voltage of ccd
vclose = -1; % closing voltage of ccd

% electronsStore(pinout,'vopen',vopen,'vclose',vclose) % Store electrons
measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);

for i = 1:5
    fprintf(['-> Iteration no. ', num2str(i),'\n'])

    shuttleUpSense2(pinout,'vopen',vopen,'vclose',vclose) % Shuttle electrons up to next Sense2
    measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
    'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
    
    electronsStore(pinout,'vopen',vopen,'vclose',vclose) % Store electrons
    fprintf('Electrons stored\n')

    measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
    'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
end

% electronsStore(pinout,'vopen',vopen,'vclose',vclose) % Store electrons
% measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
%     'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);

electronsRelease(pinout,'vopen',vopen,'vclose',vclose) % Release electrons
measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);