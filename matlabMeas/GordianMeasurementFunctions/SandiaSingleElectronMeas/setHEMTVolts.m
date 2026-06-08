%% HEMT1
% setOutputSIM900Port(sim900,8,'ON')
% setOutputSIM900Port(sim900,6,'ON')
% setOutputSIM900Port(sim900,7,'ON')

rampSIM900Voltage(sim900,8,0.4,0.1,0.1); delay(0.2)
rampSIM900Voltage(sim900,6,2.4,0.1,0.1); delay(0.2)
rampSIM900Voltage(sim900,7,2,0.1,0.1)

%% HEMT2
% setOutputSIM900Port(sim900,3,'ON')
% setOutputSIM900Port(sim900,1,'ON')
% setOutputSIM900Port(sim900,2,'ON')

rampSIM900Voltage(sim900,3,0.4,0.2,0.1); delay(0.2)
rampSIM900Voltage(sim900,1,2.4,0.1,0.1); delay(0.2)
rampSIM900Voltage(sim900,2,2,0.1,0.1)