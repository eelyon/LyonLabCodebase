function [address] = AlazarTrigger()
  
global Alazar_TriggerLength;
global TRIG_Alazar;

CONTINUE = 0;

address = calllib('spinapi64','pb_inst_pbonly',TRIG_Alazar,CONTINUE,0,Alazar_TriggerLength);

retCode = calllib('ATSApi','AlazarForceTrigger',boardHandle);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarForceTrigger failed -- %s\n', errorToText(retCode));
    return;
end