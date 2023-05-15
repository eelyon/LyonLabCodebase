function [address] = end_loop(h_loop,time)

END_LOOP = 3;

address = calllib('spinapi','pb_inst_pbonly',0,END_LOOP,h_loop,time);
