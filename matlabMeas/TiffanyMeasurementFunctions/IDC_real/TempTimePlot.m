%% Parameters
% plots the temperature over time with the capacitance of IDC and collector
% current

waittime = 5;
repeat = 5;
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
titlestr = [folder,'/TimePlot',TimeIndStr];
Extra = 'MonitoringEmitterCurrentLoss';
titlestr = [titlestr Extra];

XScale = 1e3;
IScale = 1e9;

DeviceIDC = VmeasC;
DeviceST = VmeasE;

Igain = 1;


%% Run
%Connect;
fprintf(Rtemp,'SENS:FUNC "RES"')
fprintf(Rtemp,'CONF:RES 1000,.01')


h = figure(800);
Tstamp = num2str(now());
titlestr = strcat(titlestr,'_',Tstamp,'.fig');
title(titlestr);
hold off


t = [0];
R = [0];
CIDC = [0];
xe = [0];
xc = [0];
ye = [0];
yc = [0];
me = [0];
mc = [0];
CST = [0];


i = 1;
starttime = now();

increment = 1;

while 1 == 1
    for r = 1:repeat
        t(i) = (now()-starttime)*86400*1/60;
        R(i) = CX57781(str2double(query(Rtemp,'READ?')));  % converts resistance to temperature using calibration
        CIDC(i) = -str2double(query(DeviceIDC,'OUTP?2'))./2./pi./str2double(query(DeviceIDC,'SLVL?'))./str2double(query(DeviceIDC,'FREQ?')).*Igain;
        CST(i) = -str2double(query(DeviceST,'OUTP?2'))./2./pi./str2double(query(DeviceST,'SLVL?'))./str2double(query(DeviceST,'FREQ?')).*Igain;
        
        xc(i) = str2double(query(DeviceIDC,'OUTP?1'));  % current (real)
        xe(i) = str2double(query(DeviceST,'OUTP?1'));   % current (real)
        
        yc(i) = str2double(query(DeviceIDC,'OUTP?2'));  % current (imag)
        ye(i) = str2double(query(DeviceST,'OUTP?2'));   % current (imag)
        
        me(i) = norm([xe(i) ye(i)]);   % magnitude
        mc(i) = norm([xc(i) yc(i)]);   % magnitude
        
        figure(800)
        
        %% IDC Capacitance Plot
        subplot(2,2,2)
        plot(t,CIDC.*1e12,'bO','LineWidth',2,'MarkerSize',10)
        xlabel('Time [min]')
        ylabel('IDC Capacitance (With some parasitic) [pF]')
        title(['Time =' ' ' num2str(t(i)) ', Capacitance ='  ' ' num2str(CIDC(i)*1e12)],'FontSize',17)

%         subplot(2,2,2)
%         plot(t,CST.*1e12,'bO','LineWidth',2,'MarkerSize',10)
%         xlabel('Time [min]')
%         ylabel('Door to Top Capacitance (With some parasitic) [pF]')
%         
        %% Collector Current Plot
        subplot(2,2,1)
        plot(t,xe,'bO',t,ye,'rx',t,me,'kd')  % real, imag, and mag current
        xlabel('Time [min]')
        ylabel('Collector Current [A]')
%         
%         subplot(2,2,2)
%         plot(t,xc,'bO',t,yc,'rx',t,mc,'kd')
%         xlabel('Time [min]')
%         ylabel('Collector Current [A]')
        
        %% Temperature Plot
        subplot(2,2,3:4)
        plot(t,R,'kd','LineWidth',2,'MarkerSize',10)
        xlabel('Time [min]')
        ylabel('Temperature [K]')
        title(['T=', num2str(R(i))])

         pause(waittime)
         i = i + 1;
    end
    
    hold off
    figure(800)
    saveas(h,titlestr,'fig')
    if increment
        TimeInd = TimeInd+1;
        increment = 0;
    end
end