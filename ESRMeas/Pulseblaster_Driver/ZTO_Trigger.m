function [address] = ZTO_Trigger()
  
global ZTO_TriggerLength;
global TRIG_ZTO;

CONTINUE = 0;

address = calllib('spinapi','pb_inst_pbonly',TRIG_ZTO,CONTINUE,0,ZTO_TriggerLength);
