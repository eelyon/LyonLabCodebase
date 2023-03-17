function [plotHandles,subPlotFigure] = Tiff_initializeSR830Meas1D(sweepType,doBackAndForth)

[time,Real,Imag] = deal(inf);

timeLabel = "Time [s]";
voltageAxisName = genSR830Axis(sweepType);
yLabel = "Current [A]";

subPlotFigure = figure(getNextMATLABFigNum());
subplot(2,3,1);
realVsTimeC = plotData(time,Real,'xLabel',timeLabel,'yLabel',"Real Current [A]",'title',"Real vs Time",'subPlot',1);

subplot(2,3,2)
imagVsTimeC = plotData(time,Real,'xLabel',timeLabel,'yLabel',"Imag Current [A]",'title',"Imag vs Time",'subPlot',1);

subplot(2,3,4);
realVsTimeE = plotData(time,Real,'xLabel',timeLabel,'yLabel',"Real Current [A]",'title',"Real vs Time",'subPlot',1);

subplot(2,3,5)
imagVsTimeE = plotData(time,Real,'xLabel',timeLabel,'yLabel',"Imag Current [A]",'title',"Imag vs Time",'subPlot',1);

%[vavg1,vavg2,avgxs1,avgxs2,avgys1,avgys2,stdx1,stdx2,stdy1,stdy2,avgmags1,avgmags2,stdm1,stdm2] = deal(inf);

subplot(2,3,3)
if ~doBackAndForth
    imagVsVoltageErrC = errorbar(time,Real,Imag,'RX');
else
    imagVsVoltageErrC = errorbar(time,Real,Imag,'RX');
    hold on
    imagVsVoltageErrC2 = errorbar(time,Real,Imag,'M*');
    hold off
end
xlabel(voltageAxisName);
ylabel(yLabel);
title("Collector: Imag vs Voltage");

subplot(2,3,6)
if ~doBackAndForth
    imagVsVoltageErrE = errorbar(time,Real,Imag,'RX');
else
    imagVsVoltageErrE = errorbar(time,Real,Imag,'RX');
    hold on
    imagVsVoltageErrE2 = errorbar(time,Real,Imag,'M*');
    hold off
end
xlabel(voltageAxisName);
ylabel(yLabel);
title("Emitter: Imag vs Voltage");


if ~doBackAndForth
    plotHandles = {realVsTimeC,imagVsTimeC,realVsTimeE,imagVsTimeE,imagVsVoltageErrC,imagVsVoltageErrE};
else
    plotHandles = {realVsTimeC,imagVsTimeC,realVsTimeE,imagVsTimeE,imagVsVoltageErrC,imagVsVoltageErrC2,imagVsVoltageErrE,imagVsVoltageErrE2};
end
tileFigures(subPlotFigure,1,1,2,[],[0,0,0.5,1]);
end

function xAxisName = genSR830Axis(targetGate)
switch targetGate
    case 'GND'
        xAxisName = "Plane Bias [V]";
    case 'ST'
        xAxisName = "STM Bias [V]";
    case 'TM'
        xAxisName = "Top Metal Voltage [V]";
    case 'TC'
        xAxisName = "Top Metal Voltage Collector [V]";
    case 'TE'
        xAxisName = "Top Metal Voltage Emitter [V]";
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

