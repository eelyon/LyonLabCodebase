function [varExists] = workspaceVariableExists(varName)
command = strcat('exist(',"'",varName,"')");
varExists = evalin("base",command);
end

