% capacitance
Device = VmeasC;
capacitance = -SR830queryY(Device)/SR830queryAmplitude(Device)/2/pi/SR830queryFreq(Device)

% temperature
temp = Therm.tempFromRes(queryHP34401A(Thermometer))

% metaData
getFigMetaData(6931)
getFigMetaData(6931).numShots