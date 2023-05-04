function [address] = pulse()
  
global Agilent_TriggerLength;
global TRIG_Agilent;

CONTINUE = 0;

address = calllib('spinapi','pb_inst_pbonly',TRIG_Agilent,CONTINUE,0,Agilent_TriggerLength);
