function boardHandle = configureAlazarforEPR


disp('Loading Alazar Libraries...');
alazarLoadLibrary
AlazarDefs

acqinfo = [];
sysinfo = [];

systemId = int32(1);
boardId = int32(1);

% Get a handle to the board
handle1 = calllib('ATSApi', 'AlazarGetBoardBySystemID', systemId, boardId);
boardHandle = handle1;
setdatatype(boardHandle, 'voidPtr', 1, 1);
if boardHandle.Value == 0
    fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
    return
end

[retCode, sysinfo.boardHandle, sysinfo.maxSamplesPerRecord, sysinfo.bitsPerSample] = calllib('ATSApi', 'AlazarGetChannelInfo', handle1, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
    return
end

sysinfo.ChannelCount = 2;
% new code defining trigger parameters
retCode = calllib('ATSApi', 'AlazarSetTriggerOperation', handle1, TRIG_ENGINE_OP_J, TRIG_ENGINE_J, TRIG_EXTERNAL, TRIGGER_SLOPE_POSITIVE, 150, TRIG_ENGINE_K, TRIG_DISABLE, TRIGGER_SLOPE_POSITIVE, 128);

if retCode ~= ApiSuccess
    fprintf('Error: Alazarsettriggeroperation failed -- %s\n', errorToText(retCode));
    return
end


retCode = calllib('ATSApi', 'AlazarSetExternalTrigger', handle1, DC_COUPLING, ETR_5V);

if retCode ~= ApiSuccess
    fprintf('Error: Alazarsetexttriggeroperation failed -- %s\n', errorToText(retCode));
    return
end

disp('configuring board')
configureBoard(boardHandle);
disp('board configured')
retCode = calllib('ATSApi', 'AlazarAbortCapture', boardHandle);
