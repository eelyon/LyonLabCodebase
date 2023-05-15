function [address] = RF_Defense(time)
  

global TRIG_Stark;

CONTINUE = 0;

address = calllib('spinapi','pb_inst_pbonly',TRIG_Stark,CONTINUE,0,time);
