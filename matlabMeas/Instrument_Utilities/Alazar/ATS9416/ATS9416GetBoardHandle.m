%% Select board and get handle
systemId = int32(1);
boardId = int32(1);

% Get handle to the board
boardHandle = AlazarGetBoardBySystemID(systemId, boardId);
displayBoardInfo(systemId, boardId);
displaySystemInfo(systemId);
% AlazarGetBoardKind(boardHandle)
% AlazarGetChannelInfoEx(boardHandle)
% AlazarGetDriverVersion()

% Toggle LED on board's PCI/PCIe mounting bracket
AlazarSetLED(boardHandle, LED_ON);
delay(500);
AlazarSetLED(boardHandle, LED_OFF);