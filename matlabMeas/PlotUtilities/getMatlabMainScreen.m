function mon = getMatlabMainScreen(target)
% mon =  GETMATLABMAINSCREEN(target)
% returns monitor index.
% target can be either 'Desktop' - matlab's main window. or 'Editor'-matlab's
% editor window.
if nargin<1
    target = 'Desktop';
end
%% Get monitor list:
monitors = getMonitors; % uses .Net for windows modified screen positions
%% Get the position of the 'target' MATLAB screen:
switch target
    case 'Desktop'
        %editor position:
        frame  = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame;                
        pt     = frame.getLocationOnScreen;
        center = [frame.getWidth , frame.getHeight]/2;
    case 'Editor'
        %Matlab Desktop position:
        frame  = com.mathworks.mlservices.MLEditorServices.getEditorApplication.getActiveEditor.getComponent.getRootPane;
        pt     = frame.getLocationOnScreen;
        center = [frame.getWidth , frame.getHeight]/2;
end
matlabScreenPos = [pt.x pt.y] + center;%
%% Find the screen in which matlabScreenPos falls:
mon = 0;
nMons = size(monitors,1);
if nMons == 1
  mon = 1;
else
    marginLimit = 200;
    margin =0;
    while ~mon
        for ind1 = 1:nMons
            mon = mon + ind1*(...
                matlabScreenPos(1) + margin >= monitors(ind1,1) && matlabScreenPos(1) < sum(monitors(ind1,[1 3])) + margin && ...
                matlabScreenPos(2) + margin >= monitors(ind1,2) && matlabScreenPos(2) < sum(monitors(ind1,[2 4])) + margin );
        end
        margin = margin + 10;
        if margin > marginLimit
            break;
        end
    end
end

