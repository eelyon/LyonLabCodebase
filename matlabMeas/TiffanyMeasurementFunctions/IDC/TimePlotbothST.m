%% Parameters

waittime = 1;
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
Extra = 'Emitting';
titlestr = [titlestr Extra];

XScale = 1e3;
IScale = 1e9;

IgainE = 1;
IgainC = 1;


%% Run
%Connect;



h = figure(800);
subplot(1,1,1)
hold off
g = figure(801);
subplot(1,1,1)
hold off
Tstamp = num2str(now());
titlestr1 = strcat(titlestr,'_',Tstamp,'.fig');
%titlestr2 = strcat(titlestr,'Temp_',Tstamp,'.fig');



VoutE = (query(VmeasE,'SLVL?'));
VoutC = (query(VmeasC,'SLVL?'));

FreqE = (query(VmeasE,'FREQ?'));
FreqC = (query(VmeasC,'FREQ?'));

t = [0];
R = [0];
x1 = [0];
y1 = [0];
x2 = [0];
y2 = [0];
m1 = [0];
m2 = [0];

i = 1;
starttime = now();

increment = 1;


while 1 == 1
    for r = 1:repeat
        t(i) = (now()-starttime)*86400*1/60;
        %R(i) = CX57781(str2double(query(Rtemp,'READ?')));
        x1(i) = -str2double(query(VmeasC,'OUTP?1')).*IgainC;
        y1(i) = -str2double(query(VmeasC,'OUTP?2')).*IgainC;
        x2(i) = -str2double(query(VmeasE,'OUTP?1')).*IgainE;
        y2(i) = -str2double(query(VmeasE,'OUTP?2')).*IgainE;
        m1(i) = sqrt(x1(i)^2+y1(i)^2);
        m2(i) = sqrt(x2(i)^2+y2(i)^2);
       
        figure(800)
        
        subplot(2,3,1)
        plot(t,x1,'bO',t,y1,'rx',t,m1,'kd')
        xlabel('Time [min]')
        %ylabel('Current Collector [A]')
        ylabel('Current IDC [A]')
        %title('Collector');
        title('IDC')
        
        subplot(2,3,2)
        plot(t,m1,'kd')
        xlabel('Time [min]')
        %ylabel('Current Collector [A]')
        ylabel('Current IDC [A]')
        title(['Vin = ' ' ' VoutC]);
        
        subplot(2,3,3)
        plot(t,y1,'rx')
        xlabel('Time [min]')
        %ylabel('Current Collector [A]')
        ylabel('Current IDC [A]')
        title(['Frequency = ' ' ' FreqC]);
        
        subplot(2,3,4)
        plot(t,x2,'bO',t,y2,'rx',t,m2,'kd')
        xlabel('Time [min]')
        ylabel('Current Emitter [A]')
        title('Emitter')
        
        subplot(2,3,5)
        plot(t,m2,'kd')
        xlabel('Time [min]')
        ylabel('Current Emitter [A]')
        title(['Vin = ' ' ' VoutE]);
        
        subplot(2,3,6)
        plot(t,y2,'rx')
        xlabel('Time [min]')
        ylabel('Current Emitter [A]')
        title(['Frequency = ' ' ' FreqE]);
        
%         figure(801)
%         plot(t,R,'kd','LineWidth',2,'MarkerSize',10)
%         xlabel('Time [min]')
%         ylabel('Temperature [K]')
%         title(num2str(R(i)))
        
        
        pause(waittime)
        i = i + 1;
    end
    

    figure(800)
    saveas(h,titlestr1,'fig')
%      figure(801)
%      saveas(g,titlestr2,'fig')
    if increment
        TimeInd = TimeInd+1;
        increment = 0;
    end
end