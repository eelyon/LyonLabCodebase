function [plotHandles,subPlotFigure] = initializeATS9416Meas1D(sweepType,doBackAndForth)
%INITIALIZEATS9416MEAS1D Summary of this function goes here
%   Detailed explanation goes here

[xaxis,yaxis,yerror] = deal(inf);
voltageAxisName = genATS9416Axis(sweepType);

subPlotFigure = figure(getNextMATLABFigNum());

subplot(2,2,1)
if ~doBackAndForth
    magVsVoltageErr = errorbar(xaxis,yaxis,yerror,'Ro');
else
    magVsVoltageErr = errorbar(xaxis,yaxis,yerror,'Ro');
    hold on
    magVsVoltageErr2 = errorbar(xaxis,yaxis,yerror,'Md');
    hold off
end

xlabel(voltageAxisName);
ylabel("Magnitude [V_{rms}]");
title("Mag vs Voltage");
ax = gca;
ax.LineWidth = 1;
ax.XMinorTick = 'on';
ax.YMinorTick = 'on';

subplot(2,2,2)
if ~doBackAndForth
    phiVsVoltageErr = errorbar(xaxis,yaxis,yerror,'Bo');
else
    phiVsVoltageErr = errorbar(xaxis,yaxis,yerror,'Bo');
    hold on
    phiVsVoltageErr2 = errorbar(xaxis,yaxis,yerror,'Cd');
    hold off
end

xlabel(voltageAxisName);
ylabel("Phase [^{\circ}]");
title("Phase vs Voltage");
ax = gca;
ax.LineWidth = 1;
ax.XMinorTick = 'on';
ax.YMinorTick = 'on';

subplot(2,2,3);
if ~doBackAndForth
    realVsVoltageErr = errorbar(xaxis,yaxis,yerror,'Bo');
else
    realVsVoltageErr = errorbar(xaxis,yaxis,yerror,'Bo');
    hold on
    realVsVoltageErr2 = errorbar(xaxis,yaxis,yerror,'Cd');
    hold off
end

xlabel(voltageAxisName);
ylabel("X [V_{rms}]");
title("X vs Voltage");
ax = gca;
ax.LineWidth = 1;
ax.XMinorTick = 'on';
ax.YMinorTick = 'on';

subplot(2,2,4)
if ~doBackAndForth
    imagVsVoltageErr = errorbar(xaxis,yaxis,yerror,'Ro');
else
    imagVsVoltageErr = errorbar(xaxis,yaxis,yerror,'Ro');
    hold on
    imagVsVoltageErr2 = errorbar(xaxis,yaxis,yerror,'Md');
    hold off
end

xlabel(voltageAxisName);
ylabel("Y [V_{rms}]");
title("Y vs Voltage");
ax = gca;
ax.LineWidth = 1;
ax.XMinorTick = 'on';
ax.YMinorTick = 'on';

if ~doBackAndForth
    plotHandles = {realVsVoltageErr,imagVsVoltageErr,magVsVoltageErr,phiVsVoltageErr};
else
    plotHandles = {realVsVoltageErr,realVsVoltageErr2,imagVsVoltageErr,imagVsVoltageErr2,magVsVoltageErr,magVsVoltageErr2,phiVsVoltageErr,phiVsVoltageErr2};
end
% tileFigures(subPlotFigure,1,1,2,[],[0,0,0.5,1]);
end

function xAxisName = genATS9416Axis(targetGate)
switch targetGate
    case 'GND'
        xAxisName = "Plane Bias [V]";
    case 'ST'
        xAxisName = "STM Bias [V]";
    case 'TM'
        xAxisName = "Top Metal Voltage [V]";
    case 'TMHeat'
        xAxisName = "Top Metal Voltage [V]";
    case 'TC'
        xAxisName = "Top Metal Voltage Collector [V]";
    case 'TE'
        xAxisName = "Top Metal Voltage Emitter [V]";
    case 'Res'
        xAxisName = "Reservoir Voltage [V]";
    case 'Door'
        xAxisName = "Door Voltage [V]";
    case 'DoorOut'
        xAxisName = "Door Out Voltage [V]";
    case 'DP'
        xAxisName = "Dot Potential Voltage [V]";
    case 'Guard'
        xAxisName = "Guard Voltage [V]";
    case 'Guard1'
        xAxisName = "Guard 1 Voltage [V]";
    case 'Guard2'
        xAxisName = "Guard 2 Voltage [V]";
    case 'Freq'
        xAxisName = "SR830 Frequency [Hz]";
    case 'ThermoFreq'
        xAxisName = "Heating Frequency [Hz]";
    case 'Amp'
        xAxisName = "SR830 Amplitude [V]";
    case 'IDC'
        xAxisName = "IDC Voltage [V]";
    case 'TFE'
        xAxisName = "Thin Film Emitter [V]";
    case 'TFC'
        xAxisName = "Thin Film Collector [V]";
    case 'TWW'
        xAxisName = "Twiddle [V]";
    case 'SEN'
        xAxisName = "Sense [V]";
    case 'PHAS'
        xAxisName = 'Phase [Degrees]';
    case 'Vrms'
        xAxisName = 'Agilent Amplitude [Vrms]';
    case 'HeatPhase'
        xAxisName = 'Phase [Degrees]';
    case 'HeatPhaseUnmod'
        xAxisName = 'Phase [Degrees]';
    case 'HeatAmp'
        xAxisName = 'Amplitude [Vpp]';
    case 'HeatAmpUnmod'
        xAxisName = 'Voltage Amplitude [Vrms]';
    case 'Vpp'
        xAxisName = 'Voltage Amplitude [Vpp]';
    case 'STG'
        xAxisName = 'Sommer Tanner Voltage [V]';
    case 'Load'
        xAxisName = "Guard Voltage [V]";
    otherwise
        xAxisName = 'unknown';
end
end

