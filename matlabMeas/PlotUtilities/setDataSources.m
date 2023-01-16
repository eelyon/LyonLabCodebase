function error = setDataSources(handle,xName,yName)
% Function takes in a figure handle and sets its x and y data source to the
% workspace variables with name xName and yName respectively.
%
% Parameters: 
%   handle - The graphics handle for the target figure
%
%   xName - character variable for workspace variable name to link
%           XDataSource to
%
%   yName - character variable for workspace variable name to link
%           YDataSource to.

if ~workspaceVariableExists(xName) || ~workspaceVariableExists(yName)
    disp([xName, ' or ' yName ' are not valid workspace variables!']);
    error = 1;
else
    handle.XDataSource = xName;
    handle.YDataSource = yName;
    error = 0;
end

end