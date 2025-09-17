% channelMask = CHANNEL_A;
% doorDevice = Awg2ch; % Default channel 2
% twiddleDevice = Awg2ch; % Default channel 1
% startPhase = -180;
% stopPhase = 180;
% deltaPhase = 10;
% startAmp = 0.002;
% stopAmp = 0.005;
% deltaAmp = 0.0002;

doorDevice = Awg2ch_2; % Default channel 2
mfli_id = 'dev32061'; % 'dev32061'
startPhase = 22;
stopPhase = 32;
deltaPhase = 1;
startAmp = 0.003;
stopAmp = 0.004;
deltaAmp = 0.00002;

% gainFEMTO = 100;
% gainHEMT = 11;
% set33622AOutput(Awg2ch_Houck,1,1);
% set33622AOutput(Awg2ch_Houck,2,1);
% turnDevOn(doorDevice); % Turn on doesn't work! Fix!
% turnDevOn(twiddleDevice); % Twiddle gate

if deltaPhase < .001
    error('Minimum phase step size is 1e-3! Exiting compensation function!')
end

setVal(doorDevice,3,startPhase); % Set phase
setVal(doorDevice,4,startAmp); % Amplitude

[mag,~,~,~,~,~,~,~] = MFLISweep1D({'PHAS'},startPhase,stopPhase,deltaPhase,mfli_id,doorDevice,3,0);

phases = startPhase:deltaPhase:stopPhase;
minValPhase = phases(find(mag==min(mag)));
fprintf('Min. phase setting at %f\n', minValPhase);
setVal(doorDevice,3,minValPhase); delay(1);

[mag,~,x,y,~,~,~,~] = MFLISweep1D({'Vpp'},startAmp,stopAmp,deltaAmp,mfli_id,doorDevice,4,0);

amps = startAmp:deltaAmp:stopAmp;
minValAmp = amps(find(mag==min(mag)));
fprintf('Min. amplitude setting at %f\n', minValAmp);
setVal(doorDevice,4,minValAmp);

fprintf(['Parasitics of X = ',num2str(x(find(mag==min(mag)))*1e6),' uVrms and Y = ',num2str(y(find(mag==min(mag)))*1e6),' uVrms remain.\n']);