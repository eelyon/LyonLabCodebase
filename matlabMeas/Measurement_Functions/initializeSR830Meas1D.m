function [plotHandles,subPlotFigure] = initializeSR830Meas1D(sweepType,doBackAndForth)

[time,Real,Imag] = deal(inf);

timeLabel = "Time [s]";
voltageAxisName = genSR830Axis(sweepType);
yLabel = "Current [A]";

subPlotFigure = figure(getNextMATLABFigNum());
subplot(2,3,1);
realVsTime = plotData(time,Real,'xLabel',timeLabel,'yLabel',"Real",'title',"Real vs Time",'subPlot',1);

subplot(2,3,2)
imagVsTime = plotData(time,Real,'xLabel',timeLabel,'yLabel',"Imag",'title',"Imag vs Time",'subPlot',1);

subplot(2,3,3)
magVsTime = plotData(time,Real,'xLabel',timeLabel,'yLabel',"Mag",'title',"Mag vs Time",'subPlot',1);



%[vavg1,vavg2,avgxs1,avgxs2,avgys1,avgys2,stdx1,stdx2,stdy1,stdy2,avgmags1,avgmags2,stdm1,stdm2] = deal(inf);


subplot(2,3,4)
if ~doBackAndForth
    realVsVoltageErr = errorbar(time,Real,Imag,'Bx');
else
    realVsVoltageErr = errorbar(time,Real,Imag,'Bx');
    hold on
    realVsVoltageErr2 = errorbar(time,Real,Imag,'C*');
    hold off
end
xlabel(voltageAxisName);
ylabel(yLabel);
title("Real vs Voltage");

subplot(2,3,5)
if ~doBackAndForth
    imagVsVoltageErr = errorbar(time,Real,Imag,'RX');
else
    imagVsVoltageErr = errorbar(time,Real,Imag,'RX');
    hold on
    imagVsVoltageErr2 = errorbar(time,Real,Imag,'M*');
    hold off
end
xlabel(voltageAxisName);
ylabel(yLabel);
title("Imag vs Voltage");

subplot(2,3,6)
if ~doBackAndForth
    magVsVoltageErr = errorbar(time,Real,Imag,'Kd');
else
    magVsVoltageErr = errorbar(time,Real,Imag,'Kd');
    hold on
    magVsVoltageErr2 = errorbar(time,Real,Imag,'GO');
    hold off
end
xlabel(voltageAxisName);
ylabel(yLabel);
title("Mag vs Voltage");

if ~doBackAndForth
    plotHandles = {realVsTime,imagVsTime,magVsTime,realVsVoltageErr,imagVsVoltageErr,magVsVoltageErr};
else
    plotHandles = {realVsTime,imagVsTime,magVsTime,realVsVoltageErr,realVsVoltageErr2,imagVsVoltageErr,imagVsVoltageErr2,magVsVoltageErr,magVsVoltageErr2};
end
tileFigures(subPlotFigure,1,1,2,[],[0,0,0.5,1]);
end

function xAxisName = genSR830Axis(targetGate)
switch targetGate
    case 'ST'
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
        deviceSet = evalin("base","Top100Device");
        portSet = evalin("base","Top100Port");
        deviceSet2 = evalin("base","Dot100Device");
        portSet2 = evalin("base","Dot100Port");
        delta = deviceSet2.sigDACQueryVoltage(portSet2) - deviceSet.sigDACQueryVoltage(portSet);
        xAxisName = strcat("Top Metal Voltage (DP Bias ",num2str(delta),"V) [V]");
    case 'Freq'
        xAxisName = "SR830 Frequency [Hz]";
    case 'Amp'
        xAxisName = "SR830 Amplitude [V]";
    otherwise
        xAxisName = 'unknown';
end
end

