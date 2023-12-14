function [fres,subPlotFigure,tag,myFig] = E5071FreqSweep(ENA,powerIndBm,startFreq,stopFreq,Therm,Thermometer,tag,opt)
    % Function that sets VNA measurement and plots data
    E5071SetPower(ENA,powerIndBm);    % in dBm
    E5071SetStartFreq(ENA,startFreq); % in MHz
    E5071SetStopFreq(ENA,stopFreq);   % in MHz
    
    fprintf(ENA,':INIT1');         % Set trigger value - for continuous set: ':INIT:CONT ON'
    fprintf(ENA,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
    fprintf(ENA,':TRIG:SING');     % Trigger ENA to start sweep cycle
    query(ENA,'*OPC?');            % Execute *OPC? command and wait until command return 1
    
    % Get mag (log) and phase (deg) data
    [fdata,mag,phase] = E5071GetData(ENA,tag);
    fres = fdata(find(mag==min(mag))); % min point
    
    if ~exist('opt','var') % defaults to plotting data
        %% Plot data
        measType = num2str(query(ENA,':CALC:PAR:DEF?')); % S21, S12, S22, or S11
        subPlotFigure = figure(getNextMATLABFigNum());
        
        subplot(1,2,1);
        freqvsmag = plotData(fdata,mag,'xLabel',"Frequency (GHz)",'yLabel',strcat(measType," (dB)"),'color',"b.",'subPlot',1);
        subplot(1,2,2);
        [freqvsphase,myFig] = plotData(fdata,phase,'xLabel',"Frequency (GHz)",'yLabel',"\phi (^{\circ})",'color',"r.",'subPlot',1);

        %% Set up meta data and save plot
        resistance = queryHP34401A(Thermometer);
        temperature = Therm.tempFromRes(resistance);

        sgtitle(['f_{res}= %.5f', num2str(fres),'GHz, T=%.3f', num2str(temperature),'K']);

        metadata_struct.temperature = [num2str(temperature)]; % add temperature to metadata
        metadata_struct.power = [num2str(powerIndBm)];
        metadata_struct.fres  = [num2str(fres)];

        myFig.UserData = metadata_struct;
        
        saveData(subPlotFigure,tag); % Save mag and phase data
    else
    end
end