function [address] = delay(time)
  
CONTINUE = 0;

address = calllib('spinapi','pb_inst_pbonly',0,CONTINUE,0,time);
