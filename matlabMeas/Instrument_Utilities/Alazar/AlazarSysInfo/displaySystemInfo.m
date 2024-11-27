function [result] = displaySystemInfo(systemId)
% Display information about a board system specified by its systemId

%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2015 AlazarTech, Inc.
%
% AlazarTech, Inc. licenses this software under specific terms and
% conditions. Use of any of the software or derivatives thereof in any
% product without an AlazarTech digitizer board is strictly prohibited.
%
% AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
% EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
% MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no
% guarantee or representations regarding the use of, or the results of the
% use of, the software and documentation in terms of correctness, accuracy,
% reliability, currentness, or otherwise; and you rely on the software,
% documentation and results solely at your own risk.
%
% IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF
% BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL
% DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH%S TOTAL LIABILITY EXCEED
% THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
%
%---------------------------------------------------------------------------

%call mfile with library definitions
AlazarDefs

% set default return code to indicate failure
result = false;

% Find the number of boards in this board system
boardCount = calllib('ATSApi', 'AlazarBoardsInSystemBySystemID', systemId);
if boardCount < 1
    fprintf('Error: No boards found in system\n');
    return
end

% Get a handle to the master board
boardHandle = calllib('ATSApi', 'AlazarGetSystemHandle', systemId);
setdatatype(boardHandle, 'voidPtr', 1, 1);
if (boardHandle.Value == 0)
    fprintf('Error: AlazarGetSystemHandle system failed.\n');
    return
end

% Get the board type in this board system
boardTypeId = calllib('ATSApi', 'AlazarGetBoardKind', boardHandle);

% Get the driver version for this board type
[retCode, driverMajor, driverMinor, driverRev] = calllib('ATSApi', 'AlazarGetDriverVersion', 0, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetDriverVersion failed -- %s\n', errorToText(retCode));
    return
end

% Display general information about this board system
fprintf('System ID                 = %u\n', systemId);
fprintf('Board type                = %s\n', boardTypeIdToText(boardTypeId));
fprintf('Board count               = %u\n', boardCount);
fprintf('Driver version            = %d.%d.%d\n', driverMajor, driverMinor, driverRev);
fprintf('\n');

% Display informataion about each board in this board system
for boardId = 1 : boardCount
    if ~displayBoardInfo(systemId, boardId)
        return
    end
end

% set the return code to indicate success
result = true;

end
