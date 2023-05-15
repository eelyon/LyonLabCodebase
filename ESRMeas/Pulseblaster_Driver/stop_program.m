function [address] = stop_program

global MIL;

STOP = 1;

address = calllib('spinapi','pb_inst_pbonly',0,STOP,0,MIL);
calllib('spinapi','pb_stop_programming');
