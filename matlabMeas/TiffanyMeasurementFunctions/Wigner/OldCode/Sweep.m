%% Parameters
scanType = 'IE';
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

titlestr = [folder,'/Scan',TimeIndStr];


Extra = 'IDC Fix';
if scanType == 'SW'
    
    V =-2.6:-.4:-1 ;
    tau = .01;
    Igain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 10;
    fitBool = 0;
    DeviceRead = VmeasE;
    DeviceSet = Dot100Device;
    PortSet = Dot100Port;
    ReturnSweep = 0;
    Extra = 'DotSweep';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Dot Bias [V]'};

elseif scanType == 'ST'
    
    Vstart = getVal(Bias100Device,Bias100Port);
    Vend = Vstart - 2;
    Vstep = -.05;
    
    V = Vstart:Vstep:Vend ;
    tau = .01;
    Igain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 5;
    fitBool = 0;
    DeviceRead = STM100Device;
    DeviceSet = STM100Device;
    PortSet = STM100Port;
    ReturnSweep = 1;
    Extra = 'Pinchoff';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Current [A]'};
    xlabels = {'Time [s]','STM Bias [V]'};

    
    
    
elseif scanType == 'IM'
    
    V = 0.026:.2:5;
    tau = .1;
    Igain = -1/(2*pi*str2double(query(Vsupp,'VOLT?'))*7.5*str2double(query(Vsupp,'FREQ?')));
    waittime = tau;
    settletime = 100*tau;
    repeat = 50;
    fitBool = 0;
    Tool = Vsupp;
    ReturnSweep = 1;
    gateNum = 'VOLT:OFFS';
    Extra = 'IDC_BothBiased_RT';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Bias [V]'};
    
 elseif scanType == 'IE'
    % IDC Sweep 0 to 40V
    
    % V = 0:10:40;
    V = 0:2.45:9.8;
    tau = 5;
    DeviceRead = VmeasE;
    Igain = 1e12.*-1/(2*pi*str2double(query(DeviceRead,'SLVL?'))*str2double(query(DeviceRead,'FREQ?')));
    Vgain  = 1;
    waittime = tau;
    settletime = 10*tau;
    repeat = 10;
    fitBool = 0;
    Device1 = AP24;
    Device2 = AP24;
    Port1 = 12;   % IDC pos
    Port2 = 8;  % IDC neg 
    ReturnSweep = 1;
    Extra = 'IDCScan';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Capacitance [pF]'};
    xlabels = {'time [s]','Bias [V]'};
    
 elseif scanType == 'EI'
    % IDC sweep 0 to 80V
    
    V = 0:20:80;
    tau = 5;
    DeviceRead = VmeasE;
    Igain = 1e12.*-1/(2*pi*str2double(query(DeviceRead,'SLVL?'))*str2double(query(DeviceRead,'FREQ?')));
    Vgain  = 1;
    waittime = tau;
    settletime = 10*tau;
    repeat = 10;
    fitBool = 0;
    Device1 = SIM900;
    Device2 = SIM900;
    Device3 = SIM900;
    Device4 = SIM900;
    Port1 = 4;
    Port2 = 5;
    Port3 = 7;
    Port4 = 8;
    ReturnSweep = 1;
    Extra = 'IDCScan';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Capacitance [pF]'};
    xlabels = {'time [s]','Bias [V]'};  
    
elseif scanType == 'ab'
    
    V = 3:-.35:-3;
    tau = .5;
    Igain = 1e-8;
    waittime = tau;
    settletime = 5*tau;
    repeat = 20;
    fitBool = 1;
    gateNum = 4;
    ReturnSweep = 1;
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Bias [V]'};
    
elseif scanType == 'CL'
    
    V = -1:.1:-.2;
    VBias = getVal(BiasCDevice,BiasCPort);
    tau = .03;
    Igain = 1;
    Vgain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 10;
    fitBool = 0;
    DeviceSet = TopEDevice;
    Device2 = TopCDevice;
    DeviceRead = Device2;
    PortSet   = TopEPort;
    Port2   = TopCPort;
    ReturnSweep = 1;
    Extra = 'Cleaning';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Top Metal','Imag vs Top Metal','Mag vs Top Metal'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Bias [V]'};
    
 elseif scanType == 'CT'
    
    V = 0:1:10;
    VBias = getVal(BiasCDevice,BiasCPort);
    tau = 3;
    Igain = 1;
    Vgain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 10;
    fitBool = 0;
    DeviceSet = TopMetalDevice;
    PortSet   = TopMetalPort;
    ReturnSweep = 1;
    Extra = 'Cleaning';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Top Plate','Imag vs Top Plate','Mag vs Top Plate'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Bias [V]'};
    
elseif scanType == 'nb'
    
    V = .004:.05:.4;
    tau = .5;
    Igain = 1e-8;
    waittime = tau;
    settletime = 5*tau;
    repeat = 20;
    fitBool = 1;
    ReturnSweep = 1;
    gateNum = 'SLVL';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Voltage [V]'};
    xlabels = {'time [s]','Frequency [Hz]'};
    
 elseif scanType == 'nf'
    
    V = 1266.5:431.62:10000;
    tau = .1;
    Igain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 40;
    fitBool = 1;
    ReturnSweep = 1;
    gateNum = 'FREQ';
    Extra = 'Rout_1Mohm_Vin_4mV';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Frequency','Imag vs Frequency','Mag vs Frequency'};
    ylabels = {'Voltage [V]'};
    xlabels = {'time [s]','Bias [V]'};
    
elseif scanType == 'at'
    
    V = -2:.25:2;
    tau = .3;
    Igain = 1;
    waittime = tau;
    settletime = 8*tau;
    repeat = 20;
    fitBool = 1;
    ReturnSweep = 1;
    gateNum = 'AUXV2,';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Bias','Imag vs Bias','Mag vs Bias'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Bias [V]'};
    
elseif scanType == 'kf'
    
    V = 734:2494.356:80000;
    tau = .3;
    Igain = 1;
    Vgain = 1;
    waittime = tau;
    settletime = 12*tau;
    repeat = 5;
    fitBool = 0;
    DeviceRead = VmeasE;
    Device = VmeasE;
    ReturnSweep = 0;
    gateNum = 'FREQ';
    Extra = 'JustA1B1';
    titles = {'Real vs time','Imag vs time','Mag vs time','Real vs Frequency','Imag vs Frequency','Mag vs Frequency'};
    ylabels = {'Current [A]'};
    xlabels = {'time [s]','Frequency [Hz]'};
    
end

V2 = fliplr(V);
if ReturnSweep == 1
    V = [V V2];
elseif ReturnSweep == -1
    V = [V2];
elseif ReturnSweep == 0
    V = [V];
end

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
    Vout1 = Vout;
%     Vout2 = -Vout;
%     Vout3 = -Vout;
%     Vout4 = -Vout;
    setVoltAP24(Device1,Port1,Vout1);
    pause(0.5)
%     setVal(Device2,Port2,Vout2);
%     pause(0.5)
%     setVal(Device3,Port3,Vout3);
%     pause(0.5)
%     setVal(Device4,Port4,Vout4);
    %fprintf(Device,[gateNum ' ' num2str(Vout)])
    %setVal(DeviceSet,PortSet,Vout)
    
%     Vout1 = Vout/2;
%     %Vout2 = VBias + Vout;
%     Vout2 = Vout/2;
%     setVal(Device1,Port1,Vout1);
%     pause(0.5)
%     setVal(Device2,Port2,Vout2);
%     pause(0.5)
%     setVal(Device3,Port3,Vout3);
%     pause(0.5)
%     setVal(Device4,Port4,Vout4);
%     %fprintf(Device,[gateNum ' ' num2str(Vout)])
%     %setVal(DeviceSet,PortSet,Vout)
    
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
    % vavg = 2*[vavg Vout]; % for IDC 80V scan
    
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


    