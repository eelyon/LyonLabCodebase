
% measure Vbb vs Ib
Rb = 20e6;
setVolt(vSource,1,0);
delay(0.1);
Vbb = queryVolt(vSource,1);
delay(0.1);
Ib = queryHP34401A(DMM1)/Rb

