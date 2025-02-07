%% Initialize relevent Alazar parameters
Alazar_Delay = parameters.Alazar_Delay;% d0 delay [in ns] Trigger Delay

% Isn't this dangerous? h sets the number of shots in the Alazar...
% Using averages may not be as simple as I thought. Wouldn't this then 
% square the number of shots taken?
h = parameters.h;% # of shots

srt = parameters.srt;   % shot repetition time (should be longer than 10ms which is longer than 5ms, re-programming time for PulseBlaster)
d9 = parameters.d9;  % delay to accomodate an LED pulse
% +++++++++++++++++++++++++++++++++++++++++++++++++++
averages = parameters.averages;%10; % should be much less than h to take into account delay in arming Alazar.
acq_time = parameters.acq_time;%15e-6; % in seconds 15
nrepeat = parameters.nrepeat;%1;

pre_trig = 0; %4098; % number of samples to keep before trigger. default zero to avoid trigger pulsing during echo.
post_trig = round(acq_time / (4e-9)); % number of samples to keep after trigger.

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
disp('configuring board')
configureBoard(boardHandle);
disp('board configured')
