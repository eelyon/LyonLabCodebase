% Sweep vload and measure sense 1
vload = -0.9:0.01:0;
start_vgd = 0.4;
stop_vgd = -2;
step_vgd = 0.05;

tc = 0.02;
drat = 10e3;
poll = 0.2;

cap1 = 3.23e-12;
gain1 = 19*0.9*100;

for value = vload
    loadSense1(pinout,value)
    [~,~,x,y,~,~,stdx,stdy] = MFLISweep1D({'Guard1'},start_vgd,stop_vgd,step_vgd, ...
        'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0,'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC) % reset guard

    mag = correct_mag(x,y); % Get corrected magnitude
    delta = max(mag) - min(mag); % Calc. change in signal
    num_electrons = calc_electrons(cap1,delta,gain1,0.52); % Calc. tot. no. of electrons
    fprintf(['-> For vload = ',num2str(value),'V, num_electrons = ',num2str(num_electrons),'\n'])

    if num_electrons <= 1
        fprintf(['Exiting loop. Loaded ', num2str(num_electrons),' electrons.'])
        return
    else
        unloadSense1(pinout)
    end
end