function [address] = start_loop(h)
  
global MIL;

LOOP = 2;

address = calllib('spinapi','pb_inst_pbonly',0,LOOP,h,MIL);
