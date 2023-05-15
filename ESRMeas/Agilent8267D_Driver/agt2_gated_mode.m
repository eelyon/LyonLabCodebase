%%% Set Agilent to advance trigger mode
agt_sendcommand(io2, ':SOURce:PULM:SOURce EXTernal');  % Set to external trigger (gate) mode
agt_sendcommand(io2, ':SOURce:PULM::POLarity NORMal'); % Set the polarity of TTL gate trigger

agt_sendcommand(io2, ':POW:ALC OFF');

%%% Turns ON modulation subsystem and RF ouput power
agt_sendcommand(io2, ':SOURce:PULM:STATe ON');
agt_sendcommand(io2, 'OUTPut:STATe ON' );

% agt_closeAllSessions; % closes connection with Agilent #2
disp('Agilent #2 is ready');
disp(' ');

