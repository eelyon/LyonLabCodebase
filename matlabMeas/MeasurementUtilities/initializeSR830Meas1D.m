[time,voltage,Real,Imag,Mag] = deal(zeros(1,1));

sweepType = 'TM';

subplot(2,3,1);
realVsTime = plotData(time,Real,'xLabel',"time",'yLabel',"Real",'title',"Real vs Time",'subPlot',1);
setDataSources(realVsTime,'time','Real');


subplot(2,3,2)
imagVsTime = plotData(time,Imag,'xLabel',"time",'yLabel',"Imag",'title',"Imag vs Time",'subPlot',1);
setDataSources(imagVsTime,'time','Imag');


subplot(2,3,3)
magVsTime = plotData(time,Mag,'xLabel',"time",'yLabel',"Mag",'title',"Mag vs Time",'subPlot',1);
setDataSources(magVsTime,'time','Mag');

doBackAndForth = 1;
[vavg1,vavg2,avgxs1,avgxs2,avgys1,avgys2,stdx1,stdx2,stdy1,stdy2,avgmags1,avgmags2,stdm1,stdm2] = deal(zeros(1,1));

voltageAxisName = genSR830Axis(sweepType);
yLabel = "Current [A]";
subplot(2,3,4)
if ~doBackAndForth
    realVsVoltageErr = errorbar(vavg1,avgxs1,stdx1,'Bx');
    setDataSourcesErrorBar(realVsVoltageErr,'vavg1','avgxs1','stdx1');
else
    realVsVoltageErr = errorbar(vavg1,avgxs1,stdx1,'Bx');
    setDataSourcesErrorBar(realVsVoltageErr,'vavg1','avgxs1','stdx1');
    hold on
    realVsVoltageErr2 = errorbar(vavg2,avgxs2,stdx2,'C*');
    hold off
    setDataSourcesErrorBar(realVsVoltageErr2,'vavg2','avgxs2','stdx2');
end
xlabel(voltageAxisName);
ylabel(yLabel);
title("Real vs Voltage");

subplot(2,3,5)
if ~doBackAndForth
    imagVsVoltageErr = errorbar(vavg1,avgys1,stdy1,'RX');
    setDataSourcesErrorBar(imagVsVoltageErr,'vavg1','avgys1','stdy1');
else
    imagVsVoltageErr = errorbar(vavg1,avgys1,stdy1,'RX');
    setDataSourcesErrorBar(imagVsVoltageErr,'vavg1','avgys1','stdy1');
    hold on
    imagVsVoltageErr2 = errorbar(vavg2,avgys2,stdy2,'M*');
    setDataSourcesErrorBar(imagVsVoltageErr2,'vavg2','avgys2','stdy2');
    hold off
end
xlabel(voltageAxisName);
ylabel(yLabel);
title("Imag vs Voltage");

subplot(2,3,6)
if ~doBackAndForth
    magVsVoltageErr = errorbar(vavg1,avgmags1,stdm1,'Kd');
    setDataSourcesErrorBar(magVsVoltageErr,'vavg1','avgmags1','stdm1');
else
    magVsVoltageErr = errorbar(vavg1,avgmags1,stdm1,'Kd');
    setDataSourcesErrorBar(magVsVoltageErr,'vavg1','avgmags1','stdm1');
    hold on
    magVsVoltageErr2 = errorbar(vavg2,avgmags2,stdm2,'GO');
    setDataSourcesErrorBar(magVsVoltageErr2,'vavg2','avgmags2','stdm2');
    hold off
end
xlabel(voltageAxisName);
ylabel(yLabel);
title("Mag vs Voltage");

function xAxisName = genSR830Axis(targetGate)
    switch targetGate
        case 'STM'
            xAxisName = "STM Bias [V]";
        case 'TM'
            xAxisName = "Top Metal Voltage [V]";
        case 'Res'
            xAxisName = "Reservoir Voltage [V]";
        case 'Door'
            xAxisName = "Door Voltage [V]";
        case 'DP'
            xAxisName = "Dot Potential Voltage [V]";
        case 'Pair'
            deviceSet = evalin("base",TMDevice);
            portSet = evalin("base",TMPort);
            deviceSet2 = evalin("base",DotDevice);
            portSet2 = evlin("base",DotPort);
            delta = deviceSet2.sigDACQueryVoltage(portSet2) - deviceSet.sigDACQueryVoltage(portSet);
            xAxisName = ["Top Metal Voltage (DP Bias " num2str(delta) "V) [V]"];
    end
end

function setDataSources(handle,xName,yName)
    handle.XDataSource = xName;
    handle.YDataSource = yName;
end

function setDataSourcesErrorBar(handle,xName,yName,yError)
    handle.XDataSource = xName;
    handle.YDataSource = yName;
    handle.YNegativeDeltaSource = yError;
    handle.YPositiveDeltaSource = yError;
end