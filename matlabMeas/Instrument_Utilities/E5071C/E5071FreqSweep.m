function [fres,subPlotFigure,tag,myFig] = E5071FreqSweep(ENA,powerIndBm,startFreq,stopFreq,tag)
    % Function that sets VNA measurement and plots data
    E5071SetPower(ENA,5); % in dBm
    E5071SetStartFreq(ENA,2120); % in MHz
    E5071SetStopFreq(ENA,2140); % in MHz
    
    fprintf(ENA,':INIT1'); % Set trigger value - for continuous set: ':INIT:CONT ON'
    fprintf(ENA,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
    fprintf(ENA,':TRIG:SING'); % Trigger ENA to start sweep cycle
    query(ENA,'*OPC?'); % Execute *OPC? command and wait until command return 1
    
    % Get mag (log) and phase (deg) data
    tag = 'freqSweep';
    [fdata,mag,phase] = E5071GetData(ENA,tag);
    fres = fdata(find(mag==min(mag))); % min point
    
    %% Plot data
    measType = num2str(query(ENA,':CALC:PAR:DEF?')); % S21, S12, S22, or S11
    subPlotFigure = figure(getNextMATLABFigNum());
    
    subplot(1,2,1);
    freqvsmag = plotData(fdata,mag,'xLabel',"Frequency (GHz)",'yLabel',strcat(measType," (dB)"),'color',"b.",'subPlot',1);
    subplot(1,2,2);
    [freqvsphase,myFig] = plotData(fdata,phase,'xLabel',"Frequency (GHz)",'yLabel',"\phi (^{\circ})",'color',"r.",'subPlot',1);
    sgtitle([sprintf('f_{res}= %.6f', fres),'GHz']);
end