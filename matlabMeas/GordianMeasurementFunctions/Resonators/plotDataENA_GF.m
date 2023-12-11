%% Set single frequency sweep

power     = 10;      % in dBm
startFreq = 2110;    % in MHz
stopFreq  = 2131;    % in MHz 

% decide whether to include metadata (1=include,0=don't)
saveFig   = 1;       % for saving the figure
plotHe    = 0;       % for Patm and numShots metaData
plotIDC   = 0;       % for capacitance metaData
tag = 'freqSweep';

addedHe   = 0;       % in inHg from reading the gauge
deviceIDC = VmeasC;    % device for IDC measurement

E5071SetPower(ENA,power);           % in dBm
E5071SetStartFreq(ENA,startFreq);   % in MHz
E5071SetStopFreq(ENA,stopFreq);     % in MHz

fprintf(ENA,':INIT1');         % Set trigger value - for continuous set: ':INIT:CONT ON'
fprintf(ENA,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
fprintf(ENA,':TRIG:SING');     % Trigger ENA to start sweep cycle
query(ENA,'*OPC?');            % Execute *OPC? command and wait until command return 1

% Get mag (log) and phase (deg) data
[fdata,mag,phase] = E5071GetData(ENA,tag);
fres = fdata(find(mag(600:end)==min(mag(600:end)))); % Approximate resonance frequency

%% Plot data
measType = num2str(query(ENA,':CALC:PAR:DEF?')); % S21, S12, S22, or S11
subPlotFigure = figure(getNextMATLABFigNum());

subplot(1,2,1);
freqvsmag = plotData(fdata,mag,'xLabel',"Frequency (GHz)",'yLabel',strcat(measType," (dB)"),'color',"b.",'subPlot',1);
subplot(1,2,2);
[freqvsphase,myFig] = plotData(fdata,phase,'xLabel',"Frequency (GHz)",'yLabel',"\phi (^{\circ})",'color',"r.",'subPlot',1);

%% Set up meta data (save important params as str) and save plot
resistance = queryHP34401A(Thermometer);
temperature = Therm.tempFromRes(resistance);
sgtitle([sprintf('f_{res}= %.6f', fres),'GHz; ','T=',num2str(temperature),'K']);

metadata_struct.temperature = [num2str(temperature)];

if plotHe == 1
    Patm     = Patm + inHgToAtm(addedHe);   % initialise in command line
    numShots = numShots + 1;                % initialise in command line
    metadata_struct.Patm     = [num2str(Patm)];
    metadata_struct.numShots = [num2str(numShots)];
end

metadata_struct.power = [num2str(power)];
metadata_struct.fres  = [num2str(fres)];

if plotIDC == 1
    capIDC = cap(deviceIDC);
    metadata_struct.capIDC = [num2str(capIDC)];
end

myFig.UserData = metadata_struct;

if saveFig == 1
    plotHandles = {freqvsmag,freqvsphase};
    saveData(subPlotFigure,tag); % Save mag and phase data
    disp(metadata_struct);
end

function Patm = inHgToAtm(inHg)
    % Function converting the reading on the small, silver gas
    % manifold gauge to Patm
    % param inHg: pressure reading in inches of mercury (pos. number)
    Patm = (30-inHg)*0.0334211;
end

function capIDC = cap(Device)
    capIDC = (-SR830queryY(Device)/SR830queryAmplitude(Device)/2/pi/SR830queryFreq(Device));
end