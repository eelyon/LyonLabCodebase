% Add path to AlazarTech mfiles
addpath('C:\AlazarTech\ATS-SDK\7.2.2\Samples_MATLAB\Include')

% Call mfile with library definitions
AlazarDefs

% Load driver library
if ~alazarLoadLibrary()
  fprintf('Error: ATSApi library not loaded\n');
  return
end

% TODO: Select a board
systemId = int32(1);dis
boardId = int32(1);

% Get a handle to the board
boardHandle = AlazarGetBoardBySystemID(systemId, boardId);
setdatatype(boardHandle, 'voidPtr', 1, 1);
if boardHandle.Value == 0
  fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
  return
end

% % Configure the board's sample rate, input, and trigger settings
% if ~configureBoard(boardHandle)
%   fprintf('Error: Board configuration failed\n');
%   return
% end