%% Start up acquisition using the Alazar Digitizer Board

AlazarSysInfo
systemId = int32(1);
boardId = int32(1);

[retCode, boardHandle] = displayBoardInfo(systemId, boardId);