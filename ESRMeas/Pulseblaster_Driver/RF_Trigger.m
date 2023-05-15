function [address] = RF_Trigger()
  
global RF_TriggerLength;
global TRIG_RF TRIG_Stark;

CONTINUE = 0;

address = calllib('spinapi','pb_inst_pbonly',TRIG_RF + TRIG_Stark,CONTINUE,0,RF_TriggerLength);
