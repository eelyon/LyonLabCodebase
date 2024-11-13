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
% This sample code configures an ATS9625 to acquire to on-board memonry,
% optionally saving the data to text file in volts, and displaying it on screen.
%
% In an acquisition to on-board memory, the digitizer:
% 1. Waits for a trigger event;
% 2. Captures a record containing a specified number of samples before and
%    after the trigger to on-board memory;
% 3. Repeats from (1) until a specified number of records have been captured;
% 4. Transfers records from on-board memory to an application buffer.
%
% IMPORTANT: This sample requires a trigger source!
% By default, the sample configures the board to trigger when a signal connected
% to CHA rises through 0V, and was tested with a +/-500 mV 1 KHz sine connected
% to CHA.

addpath('..\..\..\Include')

%call mfile with library definitions
AlazarDefs

% Load driver library 
if ~alazarLoadLibrary()
    fprintf('Error: ATSApi.dll not loaded\n');
    return
end

% TODO: Select a board 
systemId = int32(1);
boardId = int32(1);

% Get a handle to the board
boardHandle = calllib('ATSApi', 'AlazarGetBoardBySystemID', systemId, boardId);
setdatatype(boardHandle, 'voidPtr', 1, 1);
if boardHandle.Value == 0
    fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
    return
end

% Configure the board's sample rate, input, and trigger settings
if ~configureBoard(boardHandle)
    fprintf('Error: Board configuration failed\n');
    return
end

% Acquire data, optionally saving it to a file
if ~acquireData(boardHandle)
    fprintf('Error: Acquisition failed\n');
    return
end