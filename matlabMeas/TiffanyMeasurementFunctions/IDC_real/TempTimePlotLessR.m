%% Parameters

waittime = 3;
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
Extra = 'Cooling';
titlestr = [titlestr Extra];

XScale = 1e3;
IScale = 1e9;

Igain = 1;


%% Run
%Connect;
%  fprintf(Rtemp,'SENS:FUNC "RES"')
%  fprintf(Rtemp,'CONF:RES 10000,.01')


h = figure(800);
subplot(1,1,1)
Tstamp = num2str(now());
titlestr = strcat(titlestr,'_',Tstamp,'.fig');
title(titlestr);
hold off
%Vout = str2double(query(Vmeas,'AUXV?2'));
%Vout = str2double(query(Vmeas,'SLVL?'));

t = [0];
t2 = [0];
R = [0];
CIDC = [0];


i = 1;
i2 = 1;

starttime = now();

increment = 1;


while 1 == 1
    for r = 1:repeat
        t(i) = (now()-starttime)*86400*1/60;
        
        %CIDC(i) = -str2double(query(VmeasC,'OUTP?2'))./2./pi./str2double(query(Vsupp,'VOLT?'))./7.5./str2double(query(Vsupp,'FREQ?')).*Igain;
        CIDC(i) = -str2double(query(VmeasE,'OUTP?2'))./2./pi./str2double(query(VmeasE,'SLVL?'))./str2double(query(VmeasE,'FREQ?')).*Igain;
       
        figure(800)
        
        
        subplot(2,2,1:2)
        plot(t,CIDC.*1e12,'bO','LineWidth',2,'MarkerSize',10)
        xlabel('Time [min]')
        ylabel('Combined IDC Capacticace (With some parasitic) [pF]')
        
     
        

        pause(waittime)
        i = i + 1;
    end
         R(i2) = CX57781(str2double(query(Rtemp,'READ?')));
         t2(i2) = (now()-starttime)*86400*1/60;
         subplot(2,2,3:4)
         plot(t2,R,'kd','LineWidth',2,'MarkerSize',10)
         xlabel('Time [min]')
         ylabel('Temperature [K]')
         title(num2str(R(i2)))
         i2 = i2 + 1;
    
    hold off
    figure(800)
    saveas(h,titlestr,'fig')
    if increment
        TimeInd = TimeInd+1;
        increment = 0;
    end
end