%%% Set Agilent to advance trigger mode
agt_sendcommand( io, ':RAD:ARB:TRIG:TYPE SADV' );        % segment advance trigger mode
agt_sendcommand( io, ':RAD:ARB:TRIG:TYPE:SADV SING' );   % trigger one pulse
agt_sendcommand( io, ':RAD:ARB:TRIG EXT' );              % external trigger
agt_sendcommand( io, ':RAD:ARB:TRIG:EXT EPT1' );         % ext trigger 1
agt_sendcommand( io, ':RAD:ARB:TRIG:EXT:DEL:STAT OFF' ); % no delay before firing
agt_sendcommand( io, ':RAD:ARB:TRIG:EXT:SLOP POS' );     % fire on positive slope of trigger
agt_sendcommand( io, ':RAD:ARB:RETR OFF');               % make sure retrigger is off

disp('Set RMS');
    agt_sendcommand(io, ['RAD:ARB:HEADER:RMS "SEQ:' sequenceName '", 1']);
    agt_sendcommand(io, ':RAD:ARB:HEADER:SAVE');
    agt_sendcommand(io, ':POW:ALC OFF');
disp('Done setting RMS');

% selects new pulse sequence
disp(['Select pulse sequence: ' sequenceName]);
    [status, status_description] = agt_sendcommand(io, [':SOUR:RAD:ARB:WAV "SEQ:' sequenceName '"']);
    if (status ~= 0)
      disp('Error selecting the sequence: ', status_description);
      return;
    end;
disp('Done selecting sequence');

%%% turn on arbitrary waveform generator, modulation subsystem and RF ouput power
agt_sendcommand(io, ':SOURce:RADio:ARB:STATe ON');
agt_sendcommand(io, ':OUTPut:MODulation:STATe ON');
agt_sendcommand(io, 'OUTPut:STATe ON' );

agt_closeAllSessions; % closes connection with Agilent
disp('Agilent is ready');
