% channelMask = CHANNEL_A;
% doorDevice = Awg2ch; % Default channel 2
% twiddleDevice = Awg2ch; % Default channel 1
% startPhase = -180;
% stopPhase = 180;
% deltaPhase = 10;
% startAmp = 0.002;
% stopAmp = 0.005;
% deltaAmp = 0.0002;

channelMask = CHANNEL_B;
doorDevice = AwgComp; % Default channel 2
twiddleDevice = AwgTwiddle; % Default channel 1
startPhase = 140;
stopPhase = 170;
deltaPhase = 2;
startAmp = 0.195;
stopAmp = 0.21;
deltaAmp = 0.0005;

gainFEMTO = 100;
% gainHEMT = 11;
% set33622AOutput(Awg2ch_Houck,1,1);
% set33622AOutput(Awg2ch_Houck,2,1);
% turnDevOn(doorDevice); % Turn on doesn't work! Fix!
% turnDevOn(twiddleDevice); % Twiddle gate

if deltaPhase < .001
    disp('Minimum phase step size is 1e-3! Exiting compensation function!')
    return
end

setVal(doorDevice,3,startPhase); % Set phase
setVal(doorDevice,4,startAmp); % Amplitude

[mag,~,~,~,~,~,~,~] = sweep1DMeasATS9416({'PHAS'},1e6,gainFEMTO,startPhase,stopPhase,deltaPhase,0.1,boardHandle,channelMask,doorDevice,3,0);

phases = startPhase:deltaPhase:stopPhase;
minValPhase = phases(find(mag==min(mag)));
fprintf('Min. phase setting at %f\n', minValPhase);
setVal(doorDevice,3,minValPhase); delay(1);

[mag,~,x,y,~,~,~,~] = sweep1DMeasATS9416({'Vpp'},1e6,gainFEMTO,startAmp,stopAmp,deltaAmp,0.1,boardHandle,channelMask,doorDevice,4,0);

amps = startAmp:deltaAmp:stopAmp;
minValAmp = amps(find(mag==min(mag)));
fprintf('Min. amplitude setting at %f\n', minValAmp);
setVal(doorDevice,4,minValAmp);

fprintf(['Parasitics of X = ',num2str(x(find(mag==min(mag)))*1e6),' uVrms and Y = ',num2str(y(find(mag==min(mag)))*1e6),' uVrms remain.\n']);