folder = ['Cooldowns/' datestr(now(),'mm_dd_yy')];
if ~exist(folder,'dir')
  mkdir(folder)
  TimeInd = 1;
end
if exist('TimeInd','var')
  TimeIndStr = num2str(TimeInd,'%3.3d')
else
  TimeInd = 1;
  TimeIndStr = num2str(TimeInd,'%3.3d')
end
titlestr = [folder,'/',TimeIndStr];

Extra = 'TimePlot_ThermometerIDCCalibrations';
titlestr1 = [titlestr Extra];

Extra = 'TempPlot_ThermometerIDCCalibrations';
titlestr2 = [titlestr Extra];

Extra = 'IDCPlot_ThermometerIDCCalibrations';
titlestr3 = [titlestr Extra];


%% Parameters
waittime = 15;
repeat = 12;
plotting = 1;


Igain = 1;
%% Run
%ConnectTherms;




h = figure(800);
h2 = figure(801);
h3 = figure(802);
hold off

Rs = [];
t = [];
f = [];
Vin = [];
x = [];
y = [];
mag = [];
Cap = [];
Rlabel = {};
Rlabel{1} = 'D51440 [Volts]';    %3a (Window Shelf Top)
Rlabel{2} = 'CX57781 [Ohms]';    %3b (Window Shelf Bottom)
Rlabel{3} = 'Temp From Old DT fit[K]';     

iCal = 1;


i = 1;
starttime = now();

if plotting
    figure(800)
    hold off
    subplot(1,1,1)
    hold off
end

first = 1;
while 1 == 1
    for r = 1:repeat
        Rs(1,i) = str2double(query(Rtemp2,'READ?'));
        Rs(2,i) = str2double(query(Rtemp,'READ?'));
        Vin(i) = str2double(query(VmeasE,'SLVL?'));
        f(i) = str2double(query(VmeasE,'FREQ?'));
        y(i) = str2double(query(VmeasE,'OUTP?2'));
        x(i) = str2double(query(VmeasE,'OUTP?1'));
        mag(i) = norm([x(i) y(i)]);
        Cap(i) = -y(i)./2./pi./Vin(i)./f(i);
        Rs(3,i)   = D51440(Rs(iCal,i));
        t(i)   = (now()-starttime)*86400*1/60;
        
        if plotting
            figure(800)
            for j = 1:3
                subplot(2,2,j)
                if j == 3
                    subplot(2,2,3:4)
                end
                plot(t,Rs(j,:),'bd')
                xlabel('Time [min]')
                ylabel(Rlabel{j})
            end
        end
            
        if plotting
            figure(801)
            for j = 1:2
                subplot(1,2,j)
                plot(Rs(3,:),Rs(j,:),'k+')
                xlabel('Temperature [K]')
                ylabel(Rlabel{j})
            end
        end
        if plotting
            figure(802)
            
                subplot(2,2,1)
                plot(t,Vin,'rd')
                xlabel('Time [min]')
                ylabel('Vin [V]')
                
                subplot(2,2,2)
                plot(t,f,'rd')
                xlabel('Time [min]')
                ylabel('f [Hz]')
                
                subplot(2,2,3)
                plot(t,x,'bO',t,y,'rx',t,mag,'kd')
                xlabel('Time [min]')
                ylabel('Current Out [Amps]')
                
                subplot(2,2,4)
                plot(t,Cap,'k*')
                xlabel('Time [min]')
                ylabel('Capacitance [F]')
            
        end
        
        pause(waittime)
        i = i + 1;
    end
    saveas(h,strcat(titlestr1,'.fig'),'fig')
    saveas(h2,strcat(titlestr2,'.fig'),'fig')
    saveas(h3,strcat(titlestr3,'.fig'),'fig')
    save(strcat(titlestr,'.mat'),'Rs','Rlabel')
    

    if first
        TimeInd = TimeInd+1;
        first = 0;
    end
end


