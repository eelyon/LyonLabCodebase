function [plotHandles,subPlotFigure] = initializeHP3577AMeas1D()

[gateV,gain,freq,inducedV,measuredV] = deal(inf);

voltageAxisName = "Gate Voltage [V]";
yLabel1 = "Gain (arb. units)";
yLabel2 = "Rolloff Frequency (Hz)";
yLabel3 = "Single Electron Induced Voltage (nV)";
yLabel4 = "Measured Voltage (nV)";

subPlotFigure = figure(getNextMATLABFigNum());
subplot(2,2,1);
gainVsGate = plotData(gateV,gain,'xLabel',voltageAxisName,'yLabel',yLabel1,'subPlot',1);

subplot(2,2,2)
freqVsGate = plotData(gateV,freq,'xLabel',voltageAxisName,'yLabel',yLabel2,'subPlot',1);

subplot(2,2,3)
inducedVoltageVsGate = plotData(gateV,inducedV,'xLabel',voltageAxisName,'yLabel',yLabel3,'subPlot',1);

subplot(2,2,4)
measuredVoltageVsGate = plotData(gateV,measuredV,'xLabel',voltageAxisName,'yLabel',yLabel4,'subPlot',1);


plotHandles = {gainVsGate,freqVsGate,inducedVoltageVsGate,measuredVoltageVsGate};

tileFigures(subPlotFigure,1,1,2,[],[0,0,0.5,1]);
end

