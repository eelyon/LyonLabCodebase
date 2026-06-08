function [plotHandles,subPlotFigure] = initializeSR830Meas1D(sweepType,doBackAndForth,opt)

[time,Real,Imag] = deal(inf);

timeLabel = "Time [s]";
voltageAxisName = genSR830Axis(sweepType);

if exist('opt','var') 
    yLabel = "Voltage [V]";
else
    yLabel = "Current [A]";
end

if contains(sweepType, 'TMHeat') || contains(sweepType, 'Amp') || contains(sweepType, 'HeatPhase') || contains(sweepType, 'HeatPhaseUnmod')
        yLabel = "Voltage [V]";
end

if contains(sweepType, 'IDC')
        yLabel = "Capacitance [pF]";
end

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
ax = gca;
ax.LineWidth = 1;
ax.XMinorTick = 'on';
ax.YMinorTick = 'on';

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
ax = gca;
ax.LineWidth = 1;
ax.XMinorTick = 'on';
ax.YMinorTick = 'on';

subplot(2,3,6)
if ~doBackAndForth
    magVsVoltageErr = errorbar(time,Real,Imag,'Kd');
else
    magVsVoltageErr = errorbar(time,Real,Imag,'Kd');
    hold on
    magVsVoltageErr2 = errorbar(time,Real,Imag,'GO');
    hold off
end
ax = gca;
ax.LineWidth = 1;
ax.XMinorTick = 'on';
ax.YMinorTick = 'on';
xlabel(voltageAxisName);
ylabel(yLabel);
title("Mag vs Voltage");

if ~doBackAndForth
    plotHandles = {realVsTime,imagVsTime,magVsTime,realVsVoltageErr,imagVsVoltageErr,magVsVoltageErr};
else
    plotHandles = {realVsTime,imagVsTime,magVsTime,realVsVoltageErr,realVsVoltageErr2,imagVsVoltageErr,imagVsVoltageErr2,magVsVoltageErr,magVsVoltageErr2};
end
% tileFigures(subPlotFigure,1,1,2,[],[0,0,0.5,1]);
end

function xAxisName = genSR830Axis(targetGate)
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
    case 'Guard1'
        xAxisName = "Guard 1 Voltage [V]";
    case 'Guard2'
        xAxisName = "Guard 2 Voltage [V]";
    case 'Pair'
        deviceSet = evalin("base","Top100Device");
        portSet = evalin("base","Top100Port");
        deviceSet2 = evalin("base","Dot100Device");
        portSet2 = evalin("base","Dot100Port");
        DPVoltage = evalin('base',[deviceSet.name '.channelVoltages( ' num2str(portSet2) ');']);
        TMVoltage = evalin('base',[deviceSet.name '.channelVoltages( ' num2str(portSet) ');']);
        deltaGateParam = DPVoltage - TMVoltage;
        
        xAxisName = strcat("Top Metal Voltage (DP Bias ",num2str(deltaGateParam),"V) [V]");
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
%         xAxisName = 'Amplitude [Vpp]';
        xAxisName = 'Voltage Amplitude [Vrms]';
    case 'Vpp'
        xAxisName = 'Voltage Amplitude [Vpp]';
    case 'STG'
        xAxisName = 'Sommer Tanner Voltage [V]';
    case 'Shield'
        xAxisName = 'Shield Voltage [V]';
    case 'Load'
        xAxisName = "Shield Voltage [V]";
    otherwise
        xAxisName = 'unknown';
end
end