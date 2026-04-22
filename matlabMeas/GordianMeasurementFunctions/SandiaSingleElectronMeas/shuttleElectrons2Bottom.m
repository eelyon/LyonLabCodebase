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

vhigh = 2; % holding voltage of ccd
vlow = -1; % closing voltage of ccd

% electronsStore(pinout,'vhigh',vhigh,'vlow',vlow) % Store electrons
measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);

for i = 1:5
    fprintf(['-> Shuttle to channel no. ', num2str(i+1),'\n'])

    shuttleDownSense2(pinout,'vhigh',vhigh,'vlow',vlow) % Shuttle electrons up to next Sense2
    measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
    'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
    
    electronsStore(pinout,'vhigh',vhigh,'vlow',vlow) % Store electrons
    fprintf('Electrons stored\n')
    
    measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
    'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
end

% electronsRelease(pinout,'vhigh',vhigh,'vlow',vlow) % Release electrons
% measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
% 'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);