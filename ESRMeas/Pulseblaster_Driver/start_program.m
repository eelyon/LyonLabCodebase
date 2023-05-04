function [address] = start_program

PULSE_PROGRAM  = 0;

address = calllib('spinapi','pb_start_programming',PULSE_PROGRAM);
