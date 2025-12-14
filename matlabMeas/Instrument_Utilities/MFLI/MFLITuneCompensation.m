doorDevice = Awg2ch_2; % Default channel 2
mfli_id = 'dev32061'; % 'dev32061'
startPhase = -8;
stopPhase = -6;
deltaPhase = 0.1;
startAmp = 0.037;
stopAmp = 0.038;
deltaAmp = 0.00005;

% fprintf(doorDevice.client, ['OUTP', num2str(1), ' ON'])
% fprintf(doorDevice.client, ['OUTP', num2str(2), ' ON'])

if deltaPhase < .001 || deltaAmp < .000001
    error('Too small of a step size. Check deltaPhase and/or deltaAmp.')
end

setVal(doorDevice,3,startPhase); % Set phase
setVal(doorDevice,4,startAmp); % Amplitude

[mag,~,~,~] = MFLISweep1D_getSample({'PHAS'},startPhase,stopPhase,deltaPhase,mfli_id,doorDevice,3,0, ...
    'filter_order',2,'time_constant',0.05, 'demod_rate', 1e3);

phases = startPhase:deltaPhase:stopPhase;
minValPhase = phases(find(mag==min(mag)));
fprintf('Min. phase setting at %f\n', minValPhase);
setVal(doorDevice,3,minValPhase); delay(1);

[mag,~,x,y] = MFLISweep1D_getSample({'Vpp'},startAmp,stopAmp,deltaAmp,mfli_id,doorDevice,4,0, ...
    'filter_order',2,'time_constant',0.05,'demod_rate',1e3);

amps = startAmp:deltaAmp:stopAmp;
minValAmp = amps(find(mag==min(mag)));
fprintf('Min. amplitude setting at %f\n', minValAmp);
setVal(doorDevice,4,minValAmp);

fprintf(['Parasitics of X = ',num2str(x(find(mag==min(mag)))*1e6),' uVrms and Y = ',num2str(y(find(mag==min(mag)))*1e6),' uVrms remain.\n']);