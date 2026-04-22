% 1. load electrons into Sense 1, measure
% 2. shuttle from Sense 1 to Sense 2, measure again
% 3. figure out which channel electron is in
% 4. shuttle back from S2 to S1, measure again
% 5. move electron out to phi_h1_2 
% 6. increase voltage to suck electron manually
% 7. decrease voltage, move back to Sense 1, measure
% (8. if too noisy, move to Sense 2 and measure) 

%sweep params
vstart = 1.5;
vstop = -1.5;
vstep = -0.1;
v_on = 1;
v_off = -1.4;

vhigh = 3;
vlow = -1;
numStepsRC = 2;
waitTimeRC = 1100;

%lockin params
filter = 2;
tc = 0.5;

measureSense2 = 0;

% shuttleSense2Sense1(pinout) % 4. shuttle back from s2 to s1
% measureElectronsFn(pinout,1,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
% 'time_constant',tc,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin1,'gain',gain1);

%move back

sigDACRamp(pinout.d5.device,pinout.d5.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d4.device,pinout.d4.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d5.device,pinout.d5.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d4.device,pinout.d4.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numStepsRC,waitTimeRC)

phi_2_set = input('Did you set phi_h1_2 to 2 V? (y/n) ',"s");
if strcmp(phi_2_set,'y')
    sigDACRamp(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numStepsRC,waitTimeRC)
end

%now electron is on phi_h1_2
%increase voltage manually, decrease back to 0

volt_increase = input('Did you increase and lower phi_h1_2? (y/n) ',"s");

while ~strcmp(volt_increase,'y')
    volt_increase = input('Did you increase and lower phi_h1_2? (y/n) ',"s"); 
end  

sigDACRamp(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vhigh,numStepsRC,waitTimeRC)

sigDACRamp(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d4.device,pinout.d4.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d5.device,pinout.d5.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d4.device,pinout.d4.port,vlow,numStepsRC,waitTimeRC)
sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vhigh,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d5.device,pinout.d5.port,vlow,numStepsRC,waitTimeRC)

sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)

if measureSense2 == 0
% measure again
    measureElectronsFn(pinout,1,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
    'time_constant',tc,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin1,'gain',gain1);
else
    shuttleSense1Sense2(pinout)
    measureElectronsFn(pinout,2,'vstart',vstart,'vstop',vstop,'vstep',vstep,'v_on',v_on,'v_off',v_off,'filter_order',filter, ...
    'time_constant',tc,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'dalpha',dalpha,'cin',cin2,'gain',gain2);
end
    




