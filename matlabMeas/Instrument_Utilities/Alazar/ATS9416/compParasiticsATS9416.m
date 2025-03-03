channelMask = CHANNEL_A;
doorDevice = Awg2ch; % Default channel 2
twiddleDevice = Awg2ch; % Default channel 1
startPhase = -154.5;
stopPhase = -154;
deltaPhase = 0.05;
startAmp = 0.00439;
stopAmp = 0.00441;
deltaAmp = 0.000001;

gain = 100*20;
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

[mag,~,~,~,~,~,~,~] = sweep1DMeasATS9416({'PHAS'},startPhase,stopPhase,deltaPhase,1,1.8e6,boardHandle,channelMask,doorDevice,3,0);

phases = startPhase:deltaPhase:stopPhase;
minValPhase = phases(find(mag==min(mag)));
fprintf('Min. phase setting at %f\n', minValPhase);
setVal(doorDevice,3,minValPhase); delay(1);

[mag,~,x,y,~,~,~,~] = sweep1DMeasATS9416({'Vpp'},startAmp,stopAmp,deltaAmp,1,1.8e6,boardHandle,channelMask,doorDevice,4,0);

amps = startAmp:deltaAmp:stopAmp;
minValAmp = amps(find(mag==min(mag)));
fprintf('Min. amplitude setting at %f\n', minValAmp);
setVal(doorDevice,4,minValAmp);

fprintf(['Parasitics of X = ',num2str(x(find(mag==min(mag)))/gain*1e6),' uVrms and Y = ',num2str(y(find(mag==min(mag)))/gain*1e6),' uVrms remain.\n']);