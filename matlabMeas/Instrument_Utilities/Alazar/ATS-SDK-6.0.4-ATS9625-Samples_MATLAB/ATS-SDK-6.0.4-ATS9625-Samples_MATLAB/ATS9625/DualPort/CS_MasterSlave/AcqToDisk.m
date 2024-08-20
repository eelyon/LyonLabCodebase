%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2012 AlazarTech, Inc.
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
%
% This sample configures an ATS9625 to make a continuous mode
% AutoDMA acqusition, optionally saving the data to file and displaying it
% on screen.
%
% In continuous mode, the digitizer captures a continuous stream of samples
% from each enabled channel. The data can span multiple AutoDMA buffers,
% where each buffer contains a segment of the continuous data stream.

% Add path to AlazarTech mfiles
addpath('..\..\..\Include')

% Call mfile with library definitions
AlazarDefs

% Load driver library 
if ~alazarLoadLibrary()
    fprintf('Error: ATSApi.dll not loaded\n');
    return
end

% TODO: Select a board system
systemId = int32(1);

% Find the number of boards in the board system
boardCount = calllib('ATSApi', 'AlazarBoardsInSystemBySystemID', systemId);
if boardCount < 1
    fprintf('Error: No boards found in system Id %d\n', systemId);
    return
end
fprintf('System Id %u has %u boards\n', systemId, boardCount);

% Get a handle to each board in the board system
for boardId = 1:boardCount
    boardHandle = calllib('ATSApi', 'AlazarGetBoardBySystemID', systemId, boardId);
    setdatatype(boardHandle, 'voidPtr', 1, 1);
    if boardHandle.Value == 0
        fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
        return
    end
    boardHandleArray(1, boardId) = { boardHandle };
end

% Configure the sample rate, input, and trigger settings of each board
for boardId = 1:boardCount
    boardHandle = boardHandleArray{ 1, boardId };
    if ~configureBoard(boardId, boardHandle)
        fprintf('Error: Configure sytstemId %d board Id %d failed\n', systemId, boardId);
        return
    end
end

% Make an acquisition, optionally saving sample data to a file
fprintf('Acquire from system Id %u\n', systemId);
if ~acquireData(boardCount, boardHandleArray)
    fprintf('Error: Acquisition failed\n');
    return
end