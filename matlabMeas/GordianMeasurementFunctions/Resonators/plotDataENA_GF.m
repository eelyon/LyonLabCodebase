%% Set single frequency sweep
power = 5;                  % power in dBm
startFreq = 2122;           % start frequency in MHz
stopFreq = 2135;            % stop frequency in MHz

E5071SetPower(ENA,power);           % in dBm
E5071SetStartFreq(ENA,startFreq);   % in MHz
E5071SetStopFreq(ENA,stopFreq);     % in MHz

fprintf(ENA,':INIT1');         % Set trigger value - for continuous set: ':INIT:CONT ON'
fprintf(ENA,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
fprintf(ENA,':TRIG:SING');     % Trigger ENA to start sweep cycle
query(ENA,'*OPC?');            % Execute *OPC? command and wait until command return 1

% Get mag (log) and phase (deg) data
tag = 'freqSweepFilter_warm';
[fdata,mag,phase] = E5071GetData(ENA,tag);
fres = fdata(find(mag==min(mag))); % Approximate resonance frequency

%% Plot data
measType = num2str(query(ENA,':CALC:PAR:DEF?')); % S21, S12, S22, or S11
subPlotFigure = figure(getNextMATLABFigNum());

subplot(1,2,1);
freqvsmag = plotData(fdata,mag,'xLabel',"Frequency (GHz)",'yLabel',strcat(measType," (dB)"),'color',"b.",'subPlot',1);
subplot(1,2,2);
[freqvsphase,myFig] = plotData(fdata,phase,'xLabel',"Frequency (GHz)",'yLabel',"\phi (^{\circ})",'color',"r.",'subPlot',1);
sgtitle([sprintf('f_{res}= %.6f', fres),'GHz']);

%% Set up meta data (save important params as str) and save plot
resistance = queryHP34401A(Thermometer);
temperature = Therm.tempFromRes(resistance);

% Patm = Patm + inHgToAtm(10); % initialise in command line
% numShots = numShots + 1; % initialise in command line
% capIDC = cap(VmeasC);

metadata_struct.temperature = [num2str(temperature)];
%metadata_struct.Patm = [num2str(Patm)];
%metadata_struct.numShots = [num2str(numShots)];
metadata_struct.power = [num2str(power)];
metadata_struct.fres = [num2str(fres)];
metadata_struct.capIDC = [num2str(capIDC)];
myFig.UserData = metadata_struct;

plotHandles = {freqvsmag,freqvsphase};
% saveData(subPlotFigure,tag); % Save mag and phase data
% disp(metadata_struct);

function Patm = inHgToAtm(inHg)
    % Function converting the reading on the small, silver gas
    % manifold gauge to Patm
    % param inHg: pressure reading in inches of mercury (pos. number)
    Patm = (30-inHg)*0.0334211;
end

function capIDC = cap(Device)
    capIDC = (-SR830queryY(Device)/SR830queryAmplitude(Device)/2/pi/SR830queryFreq(Device));
end    