%% Parameters
scanType = 'ST';
folder = 'Data\04_22_22';
indCountStr = num2num(indCount)
titlestr = [folder,'/', scanType,indCountStr];
Extra = 'TFRes_23_6';
if scanType == 'ST'
    
    V = .05:-.01:-.2 ;
    tau = .03;
    Igain = -1e-6;
    waittime = tau;
    settletime = 5*tau;
    repeat = 5;
    fitBool = 0;
    gateNum = 'AUXV2,';
    titlestr = [titlestr,Extra];
    
elseif scanType == 'ab'
    
    V = 5:-.35:-3;
    tau = .5;
    Igain = 1e-8;
    waittime = tau;
    settletime = 5*tau;
    repeat = 20;
    fitBool = 1;
    gateNum = 4;
    titlestr = [titlestr,Extra];
    
elseif scanType == 'at'
    
    V = -2:.01:-1.95;
    tau = 3;
    Igain = 1;
    waittime = tau;
    settletime = 10*tau;
    repeat = 20;
    fitBool = 1;
    gateNum = 'AUXV1,';
    titlestr = [titlestr,Extra];
    
elseif scanType == 'kf'
    
    V = 500:500:10000;
    tau = .3;
    Igain = 1;
    waittime = tau;
    settletime = 8*tau;
    repeat = 20;
    fitBool = 0;
    gateNum = 'FREQ ';
    titlestr = [titlestr,Extra];

end

%V = [-2 -2 -2];
V2 = fliplr(V);
%V2 = -.15:.005:.3;
%V = [V V2 V V2 V V2];
V = [V V2];
%V = [V V(end) V(end) V(end) V2(1) V2(1) V2(1) V2];




saveBool = 1;
errType = 'CI';

%% Run

h = figure;
titlestr = strcat(titlestr,'_',num2str(now()));
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
    
    %fprintf(Vsupp,[gateNum num2str(Vout)]);
    

    fprintf(Vmeas,strcat(gateNum,num2str(Vout)));
    %fprintf(Vmeas,strcat('SLVL',num2str(Vout)));
    %DCSet(gateNum,Vout)
    %DCSet(gateNum,Vout)
    
    pause(settletime)
    
    avgmag = 0;
    avgx   = 0;
    avgy   = 0;
    magv = [];
    avgxv = [];
    avgyv = [];
    for j = 1:repeat
        
        x(i) = str2double(query(Vmeas,'OUTP?1'))*Igain;
        x(i) = Vout/(str2double(query(Rtemp,'READ?'))*Igain);
        y(i) = str2double(query(Vmeas,'OUTP?2'))*Igain;
        y(i) = (str2double(query(Rtemp,'READ?'))*Igain);
        v(i) = Vout;
        %t(i) = t(i)+waittime;
        t(i) = (now()-tstartWalk)*86400;
%         if j == 1
%             t(i) = t(i) + settletime;
%         end
        mag(i) = sqrt(x(i)^2 + y(i)^2);
        
        
        pause(waittime)
        
        subplot(2,2,1)
        plot(t,y,'BX')
        title('Current vs time')
        
        subplot(2,2,2)
        plot(t,x,'BX')
        title('Resistance vs time')

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
    
    
    
    
    subplot(2,2,3)
    if k <= HV
        errorbar(vavg,avgys,stdx,'BX')
    else
        errorbar(vavg(1:HV),avgys(1:HV),stdy(1:HV),'BX')
        hold on
        errorbar(vavg(HV+1:end),avgys(HV+1:end),stdy(HV+1:end),'C*')
        hold off
    end
    title('current vs Bias')
    
     subplot(2,2,4)
    if k <= HV
        errorbar(vavg,avgxs,stdx,'BX')
    else
        errorbar(vavg(1:HV),avgxs(1:HV),stdx(1:HV),'BX')
        hold on
        errorbar(vavg(HV+1:end),avgxs(HV+1:end),stdx(HV+1:end),'C*')
        hold off
    end
    title('Resistance vs Bias')
    
  
    hold on
    %errorbar(vavg, avgmags, stdm2, 'r.')
    hold off
    title('Mag vs Bias')
    k = k + 1;
end
if saveBool
    saveas(h,strcat(titlestr,'.fig'),'fig')
    indCount = indCount +1;
end

if fitBool
    fits_new2(titlestr)
end


    