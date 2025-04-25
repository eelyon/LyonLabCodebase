function [address] = Alazar_Trigger()
  
global Alazar_TriggerLength;
global TRIG_Alazar;

CONTINUE = 0;

address = calllib('spinapi','pb_inst_pbonly',TRIG_Alazar,CONTINUE,0,Alazar_TriggerLength);
