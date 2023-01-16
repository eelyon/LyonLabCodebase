function initializeNumericVariable(varName,val)

varExists = workspaceVariableExists(varName);

if ~varExists
    if nargin == 1
        assignin("base",varName,0)
    else
        assignin("base",varName,val);
    end
end

end