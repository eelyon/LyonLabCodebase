%% Script for taking noise data
tag = 'noise_movingDewar'; % Set tag name for data plot

power        = 5;      % In dBm
centFreq     = fres;   % Set center frequency to approx. res. freq.
spanFreq     = 0;      % Set span to 0Hz
IFBW         = 2;      % Set the IF Bandwidth (in kHz)
samplingRate = 1000;   % In Hz
numPoints    = 5000;   % Set number of points
sweepTime    = 1/samplingRate*numPoints; % Sweep time in secs

fprintf(ENA,[':SENS1:FREQ:CENT ',num2str(centFreq*1e9)]); % set the center frequency
fprintf(ENA,[':SENS1:FREQ:SPAN ',num2str(spanFreq*1e9)]); % Set the frequency span
E5071SetPower(ENA,power);
E5071SetIFBand(ENA,IFBW);
E5071SetSweepTime(ENA,sweepTime);
E5071SetNumPoints(ENA,numPoints);

fprintf(ENA,':INIT1'); % Set trigger value - for continuous set: ':INIT:CONT ON'
fprintf(ENA,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
fprintf(ENA,':TRIG:SING'); % Trigger ENA to start sweep cycle
query(ENA,'*OPC?'); % Execute *OPC? command and wait until command return 1

% Get mag (log) and phase (deg) data
[fdata,mag,phase] = E5071GetData(ENA,tag);
sTime = E5071QuerySweepTime(ENA);
Ts = sTime/numPoints; % Time increment per point
time = 0:Ts:sTime-Ts;

%% Plot data
measType = num2str(query(ENA,':CALC:PAR:DEF?')); % S21, S12, S22, or S11
subPlotFigure = figure(getNextMATLABFigNum());

subplot(1,2,1);
freqvsmag = plotData(time,mag,'xLabel',"Time (s)",'yLabel',strcat(measType," (dB)"),'color',"b.",'subPlot',1);
subplot(1,2,2);
[freqvsphase,myFig] = plotData(time,phase,'xLabel',"Time (s)",'yLabel',"\phi (^{\circ})",'color',"r.",'subPlot',1);

%% Set up meta data and save plot
resistance = queryHP34401A(Thermometer);
temperature = Therm.tempFromRes(resistance);

% Patm = Patm + inHgToAtm(25); % Atmospheric pressure (volume of 18.4 in^3)
% numShots = numShots + 1; % % Number of gaseous He shots, can reset in command line

metadata_struct.temperature = [num2str(temperature)];
metadata_struct.Patm = [num2str(Patm)];
metadata_struct.numShots = [num2str(numShots)];
metadata_struct.sTime = [num2str(sTime)];
metadata_struct.numPoints = [num2str(numPoints)];
metadata_struct.IFBW = [num2str(IFBW)];
metadata_struct.power = [num2str(power)];
metadata_struct.fres = [num2str(fres)];
myFig.UserData = metadata_struct;

plotHandles = {freqvsmag,freqvsphase};
saveData(subPlotFigure,tag); % Save mag and phase data

disp(metadata_struct);

function Patm = inHgToAtm(inHg)
    % Function converting the reading on the small, silver gas
    % manifold gauge to Patm
    % param inHg: pressure reading in inches of mercury (pos. number)
    Patm = (30-inHg)*0.0334211;
end