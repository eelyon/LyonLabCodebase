% Load say 10 electrons from ST to Sense1 and measure
% NOTE: Do vload sweep before running this script
vopen = 2;
vclose = -1;
numSteps = 2;
numStepsRC = 2;
waitTimeRC = 1100;
% loadSense1(pinout,0)
% [ne1,nerr1] = measureElectronsFn(pinout,1,'vstart',0.1,'vstop',-0.7,'vstep',-0.05,'filter_order',2, ...
%     'time_constant',0.6,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'v_on',v_on,'v_off',v_off, ...
%     'dalpha',dalpha,'cin',cin1,'gain',gain1);
% fprintf(['n1 = ',num2str(ne1),' +- ',num2str(nerr1),'\n'])
% 
% % Shuttle electrons from Sense1 to Sense2 and measure
% shuttleSense1Sense2(pinout)
% [ne1,nerr1] = measureElectronsFn(pinout,1,'vstart',0,'vstop',-0.8,'vstep',-0.05,'filter_order',3, ...
%     'time_constant',1,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'v_on',-0.25,'v_off',-0.8, ...
%     'dalpha',dalpha,'cin',cin1,'gain',gain1);
% fprintf(['n1 = ',num2str(ne1),' +- ',num2str(nerr1),'\n'])

% Move electrons from Sense2 out onto d7, phi_h1_3, and d4
for vturn = 0:0.02:0.3
    fprintf(['-- Vturnstile ', num2str(vturn), ' --\n'])
    % Move electrons from Sense1 and split
    sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vopen,numSteps)
    sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vopen,numSteps)
    sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vclose,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vclose,numStepsRC,waitTimeRC)
    sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vopen,numSteps)
    sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vclose,numSteps)
    sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vclose,numSteps)
    sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vopen-vturn,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)

    % Move electrons on d6 back to Sense1
    sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vclose,numSteps)
    sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vopen,numSteps)
    sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vopen,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vopen,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vopen,numStepsRC,waitTimeRC)
    sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vclose,numSteps)
    sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vclose,numSteps)

    % Reset sense1 for measurement
    sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,-2,numSteps)
    sigDACRamp(pinout.d5.device,pinout.d5.port,-2,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,0,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,0,numStepsRC,waitTimeRC)

    [ne1,nerr1] = measureElectronsFn(pinout,1,'vstart',0,'vstop',-0.8,'vstep',-0.05,'filter_order',2, ...
    'time_constant',1,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'v_on',-0.25,'v_off',-0.8, ...
    'dalpha',dalpha,'cin',cin1,'gain',gain1);
    fprintf(['n1 = ',num2str(ne1),' +- ',num2str(nerr1),'\n'])

    % Move electrons on dphi_h1_3 to Sense2
    sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
    sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
    
    for j = 1:75
        sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
        sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)
        sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vopen, numSteps)
        sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
        sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
        sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vclose, numSteps)
    end
    
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
    sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)
    sigDACRampVoltage(pinout.d_v_1.device,pinout.d_v_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
    sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d_v_1.device,pinout.d_v_1.port,vclose,numSteps)
    
    sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d_v_2.device,pinout.d_v_2.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
    sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
    sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
    sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
    sigDACRamp(pinout.d7.device,pinout.d7.port,vopen,numStepsRC,waitTimeRC)
    sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
    sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,vopen,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,vopen,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,vopen,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.d7.device,pinout.d7.port,vclose,numStepsRC,waitTimeRC)

    % Reset sense2 for measurement
    sigDACRamp(pinout.guard2_r.device,pinout.guard2_r.port,-2,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.d7.device,pinout.d7.port,-2,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.sense2_l.device,pinout.sense2_l.port,0,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,numStepsRC,waitTimeRC)
    sigDACRamp(pinout.twiddle2.device,pinout.twiddle2.port,0,numStepsRC,waitTimeRC)

    [ne2,nerr2] = measureElectronsFn(pinout,2,'vstart',0,'vstop',-0.8,'vstep',-0.05,'filter_order',2, ...
        'time_constant',0.4,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'v_on',-0.25,'v_off',-0.8, ...
        'dalpha',dalpha,'cin',cin2,'gain',gain2);
    fprintf(['n2 = ',num2str(ne2),' +- ',num2str(nerr2),'\n'])
    delay(1)
end