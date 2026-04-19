% Script shuttling electron along vertical CCD many times
% cin2 = 5.1e-12;
% gain2 = 22.7*0.86;

%% Set sweep parameters
vstart = 0.2;
vstop = -0.7;
vstep = -0.05;
v_on = -0.3; % 1st channel
v_off = -0.7;

tc = 0.4;
drat = 10e3;
filter = 2;
poll = 10;

%% Set shuttling parameters and load arb file
vhigh = 2; % voltage high of ccd
vlow = -1; % voltage low of ccd

nbursts = 10;
awg_list = {awg2ch_1, awg2ch_2, awg2ch_3};
for i = 1:length(awg_list)
    awg = awg_list{i};
    for chan = 1:2
        arbFile = "COS_CCD" + num2str(chan);
        loadArb(Agilent33622A,chan,arbFile)

        set33622ABurstNCycles(awg,chan,nbursts)
        set33622AVhigh(awg,chan,vhigh)
        set33622AVlow(awg,chan,vlow)
    end
end

% Start with measuring electron
measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
'time_constant',tc,'demod_rate',drat,'poll',poll,'sweep',1,'onoff',0,'dalpha',dalpha,'cin',cin2,'gain',gain2);

for i = 1:10
    send33622ATrigger(awg2ch_1)
    queryOPC33622A(Agilent33622A)
    fprintf(['->', num2str(i*nbursts), 'shuttles performed \n'])
    
    % Push electron off phi_h1_3 onto d7
    sigDACRamp(pinout.d7.device,pinout.d7.port,vhigh,4,waitTimeRC)
    % set33622AVlow(Agilent33622A,CHAN,vlow)
    set33622AVhigh(Agilent33622A,CHAN,round(vhigh/2,2))
    set33622AVhigh(Agilent33622A,CHAN,vlow+0.1) % just set to slighlty above vlow
    
    % Reset Sense2 for measurement
    sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vhigh,4,waitTimeRC)
    sigDACRamp(pinout.d7.device,pinout.d7.port,-2,4,waitTimeRC)
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,4,waitTimeRC)
    sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,4,waitTimeRC)
    sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,4,waitTimeRC)
    
    measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep, ...
        'v_on',-0.3,'v_off',-0.7,'filter_order',filter,'time_constant',0.4, ...
        'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'dalpha',dalpha, ...
        'cin',cin2,'gain',gain2);
    
    % Push electrons back onto phi_h1_3
    sigDACRamp(pinout.d7.device,pinout.d7.port,vhigh,4,waitTimeRC)
    sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vlow,4,waitTimeRC)
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vlow,4,waitTimeRC)
    sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vlow,4,waitTimeRC)
    set33622AVhigh(Agilent33622A,CHAN,round(vhigh/2,2))
    set33622AVhigh(Agilent33622A,CHAN,vhigh)
    sigDACRamp(pinout.d7.device,pinout.d7.port,vlow,4,waitTimeRC)
end

% Confirm electron is not in top channel
measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep, ...
    'v_on',v_on,'v_off',v_off,'filter_order',filter,'time_constant',tc, ...
    'demod_rate',drat,'poll',poll,'sweep',1,'onoff',0,'dalpha',dalpha, ...
    'cin',cin2,'gain',gain2);