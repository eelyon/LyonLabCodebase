%% Parameters
scanType = 'ST';
background = 1.2025186292635e-8;
folder = ['Cooldowns/' datestr(now(),'mm_dd_yy')];
if ~exist(folder,'dir')
  mkdir(folder)
  TimeInd = 1;
end
if exist('TimeInd','var')
  TimeIndStr = num2str(TimeInd,'%3.3d');
else
  TimeInd = 1;
  TimeIndStr = num2str(TimeInd,'%3.3d');
end

titlestr = [folder,'/Scan',TimeIndStr];

if scanType == 'SW'
    currentV = getVal(Dot100Device,Dot100Port);
    finalV = currentV - .5;
    
    if finalV > currentV
        multiplier = 1;
    else
        multiplier = -1;
    end

    V = currentV:multiplier*0.05:finalV;
    Vgain = 1;
    tau = .06;
    Igain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 5;
    fitBool = 0;
    DeviceRead = SR830.client;
    DeviceSet = Dot100Device;
    PortSet = Dot100Port;
    ReturnSweep = 0;
    Extra = 'DotSweep';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Dot Bias [V]'};
    
elseif scanType == 'ST'
    
    Vstart = 0;%getVal(STM100Device,STM100Port);
    Vend = Vstart - .3;
    Vstep = -.001;
    
    V = Vstart:Vstep:Vend ;
    tau = .05;
    Igain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 5;
    fitBool = 0;
    DeviceRead = SR830.client;
    DeviceSet = STM100Device;
    PortSet = STM100Port;
    ReturnSweep = 1;
    Extra = 'Pinchoff';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Bias [V]'};

elseif scanType == 'PR'
    topV = getVal(Top100Device,Top100Port);
    dotV = getVal(Dot100Device,Dot100Port);
    dotDelta = dotV - topV;
    xLab = ['Top Bias [V] (DP Bias ' num2str(dotDelta) ' V)'];
    V = topV:-0.1:-2;
    tau = .06;
    Igain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 5;
    fitBool = 0;
    DeviceRead = SR830.client;
    DeviceSet = Top100Device;
    DeviceSet2 = Dot100Device;
    PortSet = Top100Port;
    PortSet2 = Dot100Port;
    ReturnSweep = 1;
    Extra = 'PairSweep';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]',xLab};
    DACGUI;

elseif scanType == 'DR'
    %currentV = getVal(Door100Device,Door100Port);
    %finalV = -3;
    
    if finalV > currentV
        multiplier = 1;
    else
        multiplier = -1;
    end

    V = currentV:multiplier*0.05:finalV;
    Vgain = 1;
    tau = .06;
    Igain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 5;
    fitBool = 0;
    DeviceRead = SR830.client;
    DeviceSet = Door100Device;
    PortSet = Door100Port;
    ReturnSweep = 0;
    Extra = 'DoorSweep';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Door Bias [V]'};

elseif scanType == 'RS'
    %currentV = getVal(Res100Device,Res100Port);
    %finalV = -1;
    
    if finalV > currentV
        multiplier = 1;
    else
        multiplier = -1;
    end

    V = currentV:multiplier*0.1:finalV;
    Vgain = 1;
    tau = .06;
    Igain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 5;
    fitBool = 0;
    DeviceRead = SR830.client;
    DeviceSet = Res100Device;
    PortSet = Res100Port;
    ReturnSweep = 0;
    Extra = 'ResSweep';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Res Bias [V]'};
end



%V = [-2 -2 -2];
V2 = fliplr(V);
%V2 = -.15:.005:.3;
%V = [V V2 V V2 V V2];
if ReturnSweep == 1
    V = [V V2];
elseif ReturnSweep == -1
    V = [V2];
elseif ReturnSweep == 0
    V = [V];
end
%V = [V V(end) V(end) V(end) V2(1) V2(1) V2(1) V2];




saveBool = 1;
errType = 'CI';

%% Run

h = figure;
titlestr = strcat(titlestr,'_',Extra,'_',num2str(now()));
hold off

x = [];
y = [];
v = [];
t = [];
vavg = [];
avg = [];
avgxp = [];
avgyp = [];
avgys = [];
avgxs = [];
avgmags = [];
stdx = [];
stdy = [];
stdm = [];
%stdm2 = [];
mag = [];
angle = [];
i = 1;
k = 1;
t(i) = 0;
CI95 = tinv([0.025 0.975], repeat-1); 
HV = length(V)/2;
tstartWalk = now();

for Vout = V
    
    setVal(DeviceSet,PortSet,Vout);
    if strcmp(scanType,'PR')
        setVal(DeviceSet2,PortSet2,Vout+dotDelta);
    end
    DACGUI.updateDACGUI;
    drawnow;
    pause(settletime)
    
    avgmag = 0;
    avgx   = 0;
    avgy   = 0;
    magv = [];
    avgxv = [];
    avgyv = [];
    for j = 1:repeat
        
        x(i) = str2double(query(DeviceRead,'OUTP?1'))*Igain;
        y(i) = str2double(query(DeviceRead,'OUTP?2'))*Igain;
        v(i) = Vout;
        %t(i) = t(i)+waittime;
        t(i) = (now()-tstartWalk)*86400;
%         if j == 1
%             t(i) = t(i) + settletime;
%         end
        mag(i) = sqrt(x(i)^2 + y(i)^2);
        
        
        pause(waittime)
        
        subplot(2,3,1)
        plot(t,x,'BX')
        title(titles{1})
        xlabel(xlabels{1})
        ylabel(ylabels{1})
        
        subplot(2,3,2)
        plot(t,y,'RX');
        title(titles{2})
        xlabel(xlabels{1})
        ylabel(ylabels{1})
        
        subplot(2,3,3)
        plot(t,mag,'Kd');
        title(titles{3})
        xlabel(xlabels{1})
        ylabel(ylabels{1})

        avgmag = avgmag + mag(i)/repeat;
        avgx   = avgx   + x(i)/repeat;
        avgy   = avgy   + y(i)/repeat;
        magv = [magv mag(i)];
        avgxv = [avgxv x(i)];
        avgyv = [avgyv y(i)];
         
        t(i+1) = t(i);
        i = i + 1;
    end
    
    avg = [avg avgmag];
    avgxp = [avgxp avgx];
    avgyp = [avgyp avgy];
    vavg = [vavg Vout];
    
    avgmags = [avgmags mean(magv)];
    avgxs = [avgxs mean(avgxv)];
    avgys = [avgys mean(avgyv)];
    
    
    if errType == 'CI'
        merr = (std(magv)/sqrt(repeat).*CI95)*2; 
        xerr = (std(avgxv)/sqrt(repeat).*CI95)*2; 
        yerr = (std(avgyv)/sqrt(repeat).*CI95)*2;   
        
        stdm = [stdm merr(2)];
        stdx = [stdx xerr(2)];
        stdy = [stdy yerr(2)]; 
        
        %stdm2 = [stdm2 std(magv)];
    else
        stdm = [stdm std(magv)];
        stdx = [stdx std(avgxv)];
        stdy = [stdy std(avgyv)];
    end
    
    
    
    
    subplot(2,3,4)
    if k <= HV
        errorbar(vavg.*Vgain,avgxs,stdx,'BX')
    else
        errorbar(vavg(1:HV).*Vgain,avgxs(1:HV),stdx(1:HV),'BX')
        hold on
        errorbar(vavg(HV+1:end).*Vgain,avgxs(HV+1:end),stdx(HV+1:end),'C*')
        hold off
    end
    title(titles{4})
    xlabel(xlabels{2})
    ylabel(ylabels{1})
    
    subplot(2,3,5)
    if k <= HV
        errorbar(vavg.*Vgain,avgys,stdy,'RX')
    else
        errorbar(vavg(1:HV).*Vgain,avgys(1:HV),stdy(1:HV),'RX')
        hold on
        errorbar(vavg(HV+1:end).*Vgain,avgys(HV+1:end),stdy(HV+1:end),'M*')
        hold off
    end
    title(titles{5})
    xlabel(xlabels{2})
    ylabel(ylabels{1})
    
    subplot(2,3,6)
    if k <= HV
        errorbar(vavg.*Vgain, avgmags, stdm, 'Kd')
    else
        errorbar(vavg(1:HV).*Vgain, avgmags(1:HV), stdm(1:HV), 'Kd')
        hold on
        errorbar(vavg(HV+1:end).*Vgain, avgmags(HV+1:end), stdm(HV+1:end), 'GO')
        hold off
    end
    hold on
    %errorbar(vavg, avgmags, stdm2, 'r.')
    hold off
    title(titles{6})
    xlabel(xlabels{2})
    ylabel(ylabels{1})
    
    k = k + 1;
end
if saveBool
    saveas(h,strcat(titlestr,'.fig'),'fig')
    TimeInd = TimeInd +1;
end

if fitBool
    fits_new2(titlestr)
end


    