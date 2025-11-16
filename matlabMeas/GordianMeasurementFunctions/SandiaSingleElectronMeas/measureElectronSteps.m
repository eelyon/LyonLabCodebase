% Load single electrons onto Sense1, measure to confirm it's a single
% electron, move onto vertical CCD and move down by at least one pixe.
% Then load another single electron, measure, and move down again. Repeat this
% for 5-10 electrons. Shuttling back may be tricky cause CCD is connected
% to all channels i.e. Sense1s - bring in electron, move over onto
% phi_h1_2, move others in parallel Sense1s back onto vertical CCD, release
% electron on phi_h1_2 and measure. Repeat until get all electrons back on
% Sense1.
vload = 3;
n = 0;
i = 1;
% nEs = [];

while n < 7
fprintf(['-- Loading iteration no. ', num2str(i), ' --\n'])
% Load electrons from Sommer-Tanner onto Sense1 and measure
loadSense1(pinout,vload)
[nE1,nErr1] = measureElectronsFn(pinout,1,'vstart',0.1,'vstop',-0.7,'vstep',-0.01,'filter_order',2, ...
    'time_constant',0.5,'demod_rate',1e3,'poll',10,'sweep',1,'onoff',1);
fprintf(['n = ',num2str(nE1),' +- ',num2str(nErr1),'\n'])
delay(2)

if nE > 0.8 && nE < 1.2
    shuttleSense1Sense2(pinout)
%     sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vopen,numSteps)
%     sigDACRamp(pinout.sense1_l.device,pinout.sense1_l.port,vclose,numStepsRC,waitTimeRC)
%     sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,vclose,numStepsRC,waitTimeRC)
%     sigDACRamp(pinout.twiddle1.device,pinout.twiddle1.port,vclose,numStepsRC,waitTimeRC)
%     sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.guard1_r.device,pinout.guard1_r.port,vclose,numSteps)
%     sigDACRampVoltage(pinout.sense1_r.device,pinout.sense1_r.port,vclose,numSteps)
%     sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.d6.device,pinout.d6.port,vclose,numSteps)
%     sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
%     sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
%     sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.phi_h1_1.device,pinout.phi_h1_1.port,vclose,numSteps)
%     sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.d4.device,pinout.d4.port,vclose,numSteps)
%     sigDACRampVoltage(pinout.phi_v1_2.device,pinout.phi_v1_2.port,vopen,numSteps)
%     sigDACRampVoltage(pinout.phi_h1_3.device,pinout.phi_h1_3.port,vclose,numSteps)
%     
%     for j = 1:1
%         sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vopen, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vclose, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vopen, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_3.device, pinout.phi_v1_3.port, vclose, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_2.device, pinout.phi_v1_2.port, vopen, numSteps)
%         sigDACRampVoltage(pinout.phi_v1_1.device, pinout.phi_v1_1.port, vclose, numSteps)
%     end
    fprintf(['-> ',num2str(n),' electrons loaded on vertical CCD\n'])
    n = n + 1; delay(2)

    [nE2,nErr2] = measureElectronsFn(pinout,2,'vstart',0.1,'vstop',-0.7,'vstep',-0.01,'filter_order',2, ...
    'time_constant',0.5,'demod_rate',1e3,'poll',10,'sweep',1,'onoff',1);
    fprintf(['n = ',num2str(nE2),' +- ',num2str(nErr2),'\n'])
% elseif nE > 2
%     unloadSense1(pinout,'vopen',7,'vclose',-1); delay(2)
%     fprintf('Error: Loading too many electrons\n')
%     return
else
    unloadSense1(pinout,'vopen',2,'vclose',-1); delay(2)
    fprintf('Sense 1 unloaded\n')
end

% nEs(i) = nE;
% 
% if length(nEs) >= 2 && nEs(i) <  0.5 && nEs(i-1) < 0.5
%     vload = vload + 0.01;
%     fprintf(['Change vload to ',num2str(vload),'\n'])
% elseif length(nEs) >= 2 && nEs(i) > 2 && nEs(i-1) > 2
%     vload = vload - 0.01;
%     unloadSense1(pinout,'vopen',7,'vclose',-1.6); delay(2)
%     fprintf(['Change vload to ',num2str(vload),'\n'])
% end

i = i + 1;
end