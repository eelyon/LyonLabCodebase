%% Initialize workspace arrays. Must be in workspace to update plots properly.
[voltage,Ib,Ic] = deal(inf);

%% Change this value for the resistor on the base (load resistance)
baseResistor = 580e3;


metaDatStr = strcat("Base Resistor: ",num2str(baseResistor)," Ohms");
label = sprintf('Rb = %0.2f Ohms', baseResistor);

%% Create plot for thermometry and set the data sources for the figure handle below.
[IbVsVBE,IbObj] = plotData(voltage,Ib,'xLabel',"VBE (Volts)",'yLabel',"Ib (A)",'color',"r.",'type',"linear",'metaData',metaDatStr);
[IcVsVBE,IcObj] = plotData(voltage,Ic,'xLabel',"VBE (Volts)",'yLabel',"Ic (A)",'color',"r.",'type',"linear",'metaData',metaDatStr);
[IcVsIb,IcvsIbObj] = plotData(Ib,Ic,'xLabel',"Ib (A)",'yLabel',"Ic (A)",'color',"r.",'type',"linear",'metaData',metaDatStr);

backgroundIthacoVoltageAvg = 0;
repeat = 25;
for i = 1:repeat
    backgroundIthacoVoltageAvg = backgroundIthacoVoltageAvg + queryHP34401A(DMM2);
end
backgroundIthacoVoltageAvg = backgroundIthacoVoltageAvg/repeat;

%% Start and Stop voltages on the Sigilent power supply.
startVolt = 0;
stopVolt = 1;
amplification = 1e-4;
flush(DMM1);
flush(DMM2);

hbtIbIcVBEFunction(vSource,DMM1,DMM2,1,IbVsVBE,IcVsVBE,IcVsIb,startVolt,stopVolt,.01,amplification,baseResistor,backgroundIthacoVoltageAvg,.025,IbObj,IcObj,IcvsIbObj)