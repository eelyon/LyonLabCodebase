function initializeCharVariable(varName,val)

varExists = workspaceVariableExists(varName);

if ~varExists
    
    if nargin == 1
        assignin("base",varName,'')
    else
        assignin("base",varName,val);
    end
end

end
