function [] = E5071SetTrig(ENA,trigType)
% Sets the trigger value for the E5071. Arguments are:
% 
% E5071C: TCP object that contains the connection info for the E5071C in
% question
%
% trigType: trigger type to change to. Valid inputs are CONT, SINGLE, or HOLD.
validTrigTypes = {'CONT','HOLD','SINGLE'};
if ~any(strcmp(validTrigTypes,trigType));
  fprintf(['Trigger Type: ', trigType , ' is not supported. Trigger type not set.\n']);
  return
end

cmd = ':INIT1:';
contCmd = ':INIT1:CONT';

if strcmp(trigType,'CONT')
  cmd = [contCmd, ' ON'];
  fprintf(ENA, cmd);
elseif (strcmp(trigType,'SINGLE') || strcmp(trigType,'HOLD'))
  fprintf(ENA, [contCmd, ' OFF']);
  if(strcmp(trigType,'SINGLE'))
    cmd = [cmd, 'IMM'];
    fprintf(ENA,cmd);
  end
end

end

