function plotSR830DataAnalysis(figNum,subPlotName,pullForwardAndBack)
    % Pulls/plots data from SR830 data subplots and gives them the
    % appropriate labels (x,y,title, and legend). As of 1/11/2023, SR830 plots
    % contain 6 subplots. Real/Imag/Magnitude vs Time and vs Voltage. These
    % are currently just 1D sweeps. 
    % Inputs: 
    %   figNum - (integer) the figure number of desired SR830 plot
    %   plotName - (character string) title of desired subplot, see
    %   pullSR830Data.m for more details
    %   pullForwardAndBack - (integer, 1/0) Boolean that suppresses pulling
    %   the back sweep on the Real/Imag/Magnitude vs Voltage sweeps.
    [xDataCell,yDataCell,xLab,yLab,titleName] = pullSR830Data(figNum,subPlotName,pullForwardAndBack);
    
    if pullForwardAndBack
        colorScheme = {'g.','b.'};
    else
        colorScheme = {'b.'};
    end

    figure(getNextMATLABFigNum());
    for i = 1:length(xDataCell)
        plot(xDataCell{i},yDataCell{i},colorScheme{i});
        if i == 1 && length(xDataCell) ~= 1
            hold on
        else
            hold off;
        end
    end
    xlabel(xLab);
    ylabel(yLab);
    title(titleName);
    if length(xDataCell) > 1
        legend('Final Sweep','Initial Sweep');
    end
end

