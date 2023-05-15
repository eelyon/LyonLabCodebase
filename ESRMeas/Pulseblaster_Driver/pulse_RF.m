function [address] = pulse_RF(theta)
  
global TRIG_RF TRIG_Stark;
global Pi_pulse_length_RF;

CONTINUE = 0;
ns = 1.0;

p_length = theta/pi*Pi_pulse_length_RF*ns;

address = calllib('spinapi','pb_inst_pbonly',TRIG_RF + TRIG_Stark,CONTINUE,0,p_length);
