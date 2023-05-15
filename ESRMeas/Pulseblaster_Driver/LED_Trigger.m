function [address] = LED_Trigger()
  
global LED_TriggerLength;
global TRIG_LED;

CONTINUE = 0;

address = calllib('spinapi','pb_inst_pbonly',TRIG_LED,CONTINUE,0,LED_TriggerLength);
