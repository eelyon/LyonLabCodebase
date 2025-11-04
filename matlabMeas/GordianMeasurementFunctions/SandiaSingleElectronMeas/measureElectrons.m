% Sweep vload and measure sense 1
vload = -0.1:-0.02:-0.4;
start_vgd = 0;
stop_vgd = -0.7;
step_vgd = 0.01;

filter = 3;
tc = 0.1;
drat = 13e3;
poll = 0.5;

cap1 = 3.16e-12;
gain1 = 24*0.92;

cap2 = 2.78e-12;
gain2 = 19;

MFLISweep1D({'Guard1'},start_vgd,stop_vgd,step_vgd,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
    'filter_order',filter,'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

num_electrons = calc_electrons(x,y,cap1,gain1,0.52); % Calc. tot. no. of electrons
fprintf(['-> For vload = ',num2str(value),'V, num_electrons = ',num2str(num_electrons),'\n'])

MFLISweep1D({'Guard2'},start_vgd,stop_vgd,step_vgd,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
    'filter_order',filter,'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

num_electrons = calc_electrons(x,y,cap2,gain2,0.52); % Calc. tot. no. of electrons
fprintf(['-> For vload = ',num2str(value),'V, num_electrons = ',num2str(num_electrons),'\n'])