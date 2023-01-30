function [plotHandle] = initializeSR830Meas2D_Func(sweepTypes, starts, stops, deltas)

%% Test command (FOR TESTING PURPOSES ONLY, NOT INDICATIVE OF ANY OTHER FUNCTIONALITY)
% initializeSR830Meas2D_Func({'Freq', 'ST'}, {1000, 0}, {10000, 1}, {1000, 0.01})

%% Read in and up pack variables to use in preparation functions
[sweepType1, sweepType2] = sweepTypes{:};
dataToPlot = generate2DPlotData(starts, stops, deltas);

yAxisName = genSR830Axis(sweepType1);
xAxisName = genSR830Axis(sweepType2);

myFig = figure(getNextMATLABFigNum());

%% Plot data
plotHandle = plot2DData(dataToPlot{1},dataToPlot{2},dataToPlot{3},'xLabel',xAxisName,'yLabel', yAxisName);
axisDirectionCorrector(starts{1}, starts{2}, stops{1}, stops{2});

tileFigures(myFig,1,1,2,[],[0,0,0.5,1]);

function [] = axisDirectionCorrector(start1, start2, stop1, stop2)
    %% axisDirectionCorrector
    % This function changes the orientation of the axes in the final plot 
    % to match the sweeping direction implied by the relative magnitudes of
    % the starting and stopping points.
    %
    % This reversal is useful due to how data is updated in the plot (from
    % the bottom left corner up. Naturally, this can be changed to plot in
    % any way desired, but this is the easiest solution, especially since
    % the data can be affected afterwords to be plotted in any direction
    % desired once captured.
    %
    % For example, if the start of a voltage sweep is at 1 V and ends at
    % 0 V, the sweep will start at 1 V. The axis then, due to this
    % function, will flip such that the left-most axis label is 1 V and the
    % right most axis label is 0 V.
    %
    % The need for 2 starts and stops is born from the 2 axes of any matlab
    % image plot.

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
end

function outData = generate2DPlotData(starts, stops, deltas)
    %% generate2DPlotData
    % Generates the data used in initializing an image plot in matlab using
    % the input data (such as starting points, stopping points, and the
    % distances between variables in sweeps). This is done to prep the plot
    % for data to be changed in it later.

    [start1, start2] = starts{:};
    [stop1, stop2] = stops{:};
    [deltaParam1, deltaParam2] = deltas{:};
    
    xData = [start2, stop2];
    lenX = length(start2:(2 * (start2 < stop2) - 1) * abs(deltaParam2):stop2);
    yData = [start1, stop1];
    lenY = length(start1:(2 * (start1 < stop1) - 1) * abs(deltaParam1):stop1);
    zData = NaN(lenY, lenX);

    outData = {xData, yData, zData};
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
end
