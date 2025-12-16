% Load electron from ST to Sense1 and measure
% If 1 or less, shuttle to Sense2 and measure. If no electron then should
% measure no additional electron in Sense2. If 1, then add electron to
% whatever is in Sense2.
vload = -0.17;
n = 0;
i = 1;
% nEs = [];

while n < 8
fprintf(['-- Loading iteration no. ', num2str(i), ' --\n'])
% Load electrons from Sommer-Tanner onto Sense1 and measure
loadSense1(pinout,vload)
[nE1,nErr1] = measureElectronsFn(pinout,1,'vstart',0.1,'vstop',-0.7,'vstep',-0.02,'filter_order',2, ...
    'time_constant',0.6,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1);
fprintf(['n1 = ',num2str(nE1),' +- ',num2str(nErr1),'\n'])
delay(1)

    if nE1 < 1.2
        shuttleSense1Sense2(pinout)
        [nE2,nErr2] = measureElectronsFn(pinout,2,'vstart',0.1,'vstop',-0.7,'vstep',-0.02,'filter_order',2, ...
        'time_constant',0.6,'demod_rate',1e3,'poll',10,'sweep',1,'onoff',1);
        fprintf(['n2 = ',num2str(nE2),' +- ',num2str(nErr2),'\n'])

        if nE2 > 0.8 && nE2 < 1.2 % When n is between 0.8 and 1.2, 1 electron is added
            n = n + 1;
            fprintf(['n = ',num2str(n),' electrons loaded \n'])
        end
    else
        unloadSense1(pinout); delay(1)
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