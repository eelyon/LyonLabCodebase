%% Get a handle to the board

boardHandle = ...
    calllib('ATSApi', 'AlazarGetBoardBySystemID', ...
        1,		...	% system ID
        1		...	% board ID
        );

retCode = ...
    calllib('ATSApi', 'AlazarSetLED', ...
        boardHandle,		...	% system ID
        LED_OFF		...	% board ID
        );

value = ...
    calllib('ATSApi', 'AlazarTriggered', ...
        boardHandle		...	% system ID
        );

AlazarForceTrigger(boardHandle)
AlazarTriggered(boardHandle)
AlazarStartCapture(boardHandle)