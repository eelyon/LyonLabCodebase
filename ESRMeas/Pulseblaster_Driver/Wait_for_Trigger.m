function [address] = Wait_for_Trigger()
  
global MIL;

WAIT = 8;

address = calllib('spinapi','pb_inst_pbonly',0,WAIT,0,10*MIL);   % wait for an external trigger
