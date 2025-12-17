% Load electron from ST to Sense1 and measure
% If 1 or less, shuttle to Sense2 and measure. If no electron then should
% measure no additional electron in Sense2. If 1, then add electron to
% whatever is in Sense2.
v_on = -0.3;
v_off = -0.9;

dalpha = 0.503; % Change in alpha
cin1 = 6e-12; % HEMT input capacitance
gain1 = 28*0.9; % Amplifier gain
cin2 = 5e-12; % HEMT input capacitance
gain2 = 22*0.89; % Amplifier gain

vload = -0.17;
n = 0;
i = 1;

while n < 8
fprintf(['-- Loading iteration no. ', num2str(i), ' --\n'])
% Load electrons from Sommer-Tanner onto Sense1 and measure
loadSense1(pinout,vload)
[ne1,nerr1] = measureElectronsFn(pinout,1,'vstart',0.1,'vstop',-0.7,'vstep',-0.05,'filter_order',2, ...
    'time_constant',0.6,'demod_rate',10e3,'poll',10,'sweep',1,'onoff',1,'v_on',v_on,'v_off',v_off, ...
    'dalpha',dalpha,'cin',cin1,'gain',gain1);
fprintf(['n1 = ',num2str(ne1),' +- ',num2str(nerr1),'\n'])
delay(1)

    if ne1 < 1.25
        % Shuttle electron from Sense1 to Sense2 and measure
        shuttleSense1Sense2(pinout)
        [ne2,nerr2] = measureElectronsFn(pinout,2,'vstart',0.1,'vstop',-0.7,'vstep',-0.05,'filter_order',2, ...
            'time_constant',0.6,'demod_rate',1e3,'poll',10,'sweep',1,'onoff',1,'v_on',v_on,'v_off',v_off, ...
            'dalpha',dalpha,'cin',cin2,'gain',gain2);
        fprintf(['n2 = ',num2str(ne2),' +- ',num2str(nerr2),'\n'])

        if ne2 > 0.75 && ne2 < 1.25 % When n is between 0.75 and 1.25, 1 electron is added
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