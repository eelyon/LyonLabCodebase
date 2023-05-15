function [address] = Stark_Trigger()
  
global Stark_TriggerLength;
global TRIG_Stark;

CONTINUE = 0;

address = calllib('spinapi','pb_inst_pbonly',TRIG_Stark,CONTINUE,0,Stark_TriggerLength);
