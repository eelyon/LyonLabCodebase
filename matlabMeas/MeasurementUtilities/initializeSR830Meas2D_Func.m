function [plotHandle] = initializeSR830Meas2D_Func(sweepTypes, starts, stops, deltas)

[sweepType1, sweepType2] = sweepTypes{:};
[start1, start2] = starts{:};
[stop1, stop2] = stops{:};
[deltaParam1, deltaParam2] = deltas{:};

xData = [start2, stop2];
lenX = length(start2:(2 * (start2 < stop2) - 1) * deltaParam2:stop2);
yData = [start1, stop1];
lenY = length(start1:(2 * (start1 < stop1) - 1) *deltaParam1:stop1);
zData = NaN(lenX, lenY);

xAxisName = genSR830Axis(sweepType2);
yAxisName = genSR830Axis(sweepType1);

myFig = figure(getNextMATLABFigNum());

fig = image(xData, yData, zData, 'CDataMapping', 'scaled');

if start2 < stop2
    set(gca,'XDir','normal');
else
    set(gca,'XDir','reverse');
end

if start1 < stop1
    set(gca,'YDir','normal');
else
    set(gca,'YDir','reverse');
end

colorbar;

xlabel(xAxisName);
ylabel(yAxisName);

% Compile Metadata
figDateFormat = 'mm_dd_yy HH:MM:SS';
metadata_struct.time= datestr(now(),figDateFormat);
instrumentList = parseInstrumentList();

for i = 1:length(instrumentList)
    if contains(instrumentList{i},"SR830")
        metadata_struct.SR830 = evalin("base",strcat("getSR830State(",instrumentList{i},");"));
    elseif contains(instrumentList{i},"DAC")
        metadata_struct.sigDAC = evalin('base',['sigDACGetConfig(' instrumentList{i} ');']);
    end
end

% Insert metadata structure into figure and save in data.

myFig.UserData = metadata_struct;

plotHandle = fig;
%tileFigures(myFig,1,1,2,[],[0,0,0.5,1]);

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
end
