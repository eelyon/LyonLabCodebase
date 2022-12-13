%% Parameters
DCMap;
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
BiasC = getVoltAP24(AP24,BiasCPort);    

%Extra= 'STMDoubleScan'

    %V          = 0:-0.1:-1;
    Vbias      = BiasC;
    tau        = .01;
    IgainE     = 1;
    IgainC     = 1;
    waittime   = tau;
    settletime = 12*tau;
    repeat     = 10;
    fitBool    = 0;
    titlestr   = [titlestr,Extra];
    Device1    = StmEDevice;
    Port1      = StmEPort;
    Device2    = StmCDevice;
    Port2      = StmCPort;
    
V2 = fliplr(V);
V = [V V2];

saveBool = 1;
errType = 'CI';

%% Run
h = figure;
titlestr = strcat(titlestr,'_',num2str(now()));
hold off

x = [];
y = [];
x2 = [];
y2 = [];
v = [];
t = [];
vavg = [];
vavg2 = [];
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
avg2 = [];
avgxp2 = [];
avgyp2 = [];
avgys2 = [];
avgxs2 = [];
avgmags2 = [];
stdx2 = [];
stdy2 = [];
stdm2 = [];
mag2 = [];
angle2 = [];
i = 1;
k = 1;
t(i) = 0;
CI95 = tinv([0.025 0.975], repeat-1); 
HV = length(V)/2;
tstartWalk = now();

for Vout = V
    
    VoutE  = Vout;
    VoutC  = Vout+Vbias;
    
    % setting STM voltages to loop through
    errC = setVoltAP24(AP24, Port2, VoutC);
    errE = setVoltAP24(AP24, Port1, VoutE);
    
    pause(settletime)
    
    avgmag = 0;
    avgx   = 0;
    avgy   = 0;
    magv = [];
    avgxv = [];
    avgyv = [];
    avgmag2 = 0;
    avgx2   = 0;
    avgy2   = 0;
    magv2 = [];
    avgxv2 = [];
    avgyv2 = [];

    for j = 1:repeat
        
        x(i) = str2double(query(VmeasC,'OUTP?1'))*IgainC; % current (real)
        y(i) = str2double(query(VmeasC,'OUTP?2'))*IgainC; % current (imag)

        x2(i) = str2double(query(VmeasE,'OUTP?1'))*IgainE; % current (real)
        y2(i) = str2double(query(VmeasE,'OUTP?2'))*IgainE; % current (imag)
         
        v(i) = VoutC;
        %t(i) = t(i)+waittime;
        t(i) = (now()-tstartWalk)*86400;
        mag(i) = sqrt(x(i)^2 + y(i)^2);
        mag2(i) = sqrt(x2(i)^2 + y2(i)^2);
        
        pause(waittime)
        
        %% Collector
        subplot(2,3,1)
        plot(t,x,'BX',t,y,'RX',t,mag,'Kd')  % real, imag, mag current
        title('Collector (real, imag, mag)')
        xlabel('Time [s]')
        ylabel('Current [A]')

        subplot(2,3,2)
        plot(t,y,'rx');  % just imag current
        title('Collector (imag) vs time')
        xlabel('Time [s]')
        ylabel('Current [A]')
        
        %% Emitter
        subplot(2,3,4)
        plot(t,x2,'BX',t,y2,'RX',t,mag2,'Kd')
        title('Emitter (real, imag, mag)')
        xlabel('Time [s]')
        ylabel('Current [A]')
        
        subplot(2,3,5)
        plot(t,y2,'rx');
        title('Emitter (imag) vs time')
        xlabel('Time [s]')
        ylabel('Current [A]')

        avgmag = avgmag + mag(i)/repeat;
        avgx   = avgx   + x(i)/repeat;
        avgy   = avgy   + y(i)/repeat;
        magv = [magv mag(i)];
        avgxv = [avgxv x(i)];
        avgyv = [avgyv y(i)];
        
        avgmag2 = avgmag2 + mag2(i)/repeat;
        avgx2   = avgx2   + x2(i)/repeat;
        avgy2   = avgy2   + y2(i)/repeat;
        magv2 = [magv2 mag2(i)];
        avgxv2 = [avgxv2 x2(i)];
        avgyv2 = [avgyv2 y2(i)];
         
        t(i+1) = t(i);
        i = i + 1;
    end
    
    avg = [avg avgmag];
    avgxp = [avgxp avgx];
    avgyp = [avgyp avgy];
    vavg = [vavg VoutC];
    
    avgmags = [avgmags mean(magv)];
    avgxs = [avgxs mean(avgxv)];
    avgys = [avgys mean(avgyv)];
    
    avg2 = [avg2 avgmag2];
    avgxp2 = [avgxp2 avgx2];
    avgyp2 = [avgyp2 avgy2];
    vavg2 = [vavg2 VoutE];
    
    avgmags2 = [avgmags2 mean(magv2)];
    avgxs2 = [avgxs2 mean(avgxv2)];
    avgys2 = [avgys2 mean(avgyv2)];
    
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
    
        if errType == 'CI'
        merr2 = (std(magv2)/sqrt(repeat).*CI95)*2; 
        xerr2 = (std(avgxv2)/sqrt(repeat).*CI95)*2; 
        yerr2 = (std(avgyv2)/sqrt(repeat).*CI95)*2;   
        
        stdm2 = [stdm2 merr2(2)];
        stdx2 = [stdx2 xerr2(2)];
        stdy2 = [stdy2 yerr2(2)]; 
        
        %stdm2 = [stdm2 std(magv)];
    else
        stdm2 = [stdm2 std(magv2)];
        stdx2 = [stdx2 std(avgxv2)];
        stdy2 = [stdy2 std(avgyv2)];
    end
    
    
    
    %% Collector vs STM plot
    subplot(2,3,3)
    if k <= HV
        errorbar(vavg,avgys,stdy,'RX')
    else
        
        errorbar(vavg(1:HV),avgys(1:HV),stdy(1:HV),'RX')
        hold on
        errorbar(vavg(HV+1:end),avgys(HV+1:end),stdy(HV+1:end),'M*')
        hold off
    end
    title('Collector vs STM')
    xlabel('STM voltage [V]')
    ylabel('Collector Current [A]')
    
    %% Emitter vs STM plot
    subplot(2,3,6)
    if k <= HV
        errorbar(vavg2,avgys2,stdy2,'RX')
    else
        errorbar(vavg2(1:HV),avgys2(1:HV),stdy2(1:HV),'RX')
        hold on
        errorbar(vavg2(HV+1:end),avgys2(HV+1:end),stdy2(HV+1:end),'M*')
        hold off
    end
    title('Emitter vs STM') 
    xlabel('STM voltage [V]')
    ylabel('Emitter Current [A]')
    
    k = k + 1;
end
if saveBool
    saveas(h,strcat(titlestr,'.fig'),'fig')
    TimeInd = TimeInd +1;
end

if fitBool
    fits_new2(titlestr)
end


    