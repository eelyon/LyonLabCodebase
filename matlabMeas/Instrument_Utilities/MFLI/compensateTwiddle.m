function [] = compensateTwiddle(mfli_id,awg,options)
%COMPENSATETWIDDLE Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    mfli_id
    awg
    options.startPhase (1,1) double {mustBeInRange(options.startPhase, -180, 180)} = -180
    options.stopPhase (1,1) double {mustBeInRange(options.stopPhase, -180, 180)} = 180
    options.startAmp = 0.002
    options.stopAmp = 0.02
end

grounded = input('Did you ground ST-Drive and ST-Sense? (y/n) ',"s");
while ~strcmp(grounded,'y')
    grounded = input('Did you ground ST-Drive and ST-Sense? (y/n) ',"s"); 
end

startPhase = options.startPhase;
stopPhase = options.stopPhase;
startAmp = options.startAmp;
stopAmp = options.stopAmp;

deltaPhases = [10,1,0.1,0.01];
deltaAmps = [0.001,0.0001,0.00001,0.000001];

for i = 1:length(deltaPhases)
    if deltaPhases(i) < .001 || deltaAmps(i) < .000001
        error('Too small of a step size. Check deltaPhase and/or deltaAmp.')
    end
    
    setVal(awg,3,startPhase); % Set phase
    setVal(awg,4,startAmp); % Set amplitude
    
    [mag,~,~,~] = MFLISweep1D_getSample({'PHAS'},startPhase,stopPhase,deltaPhases(i),mfli_id,awg,3,0, ...
        'filter_order',1,'time_constant',0.1, 'demod_rate', 10e3);
    
    phases = startPhase:deltaPhases(i):stopPhase;
    minValPhase = phases(find(mag==min(mag)));
    fprintf('Min. phase setting at %f\n', minValPhase);
    setVal(awg,3,minValPhase); delay(1);
    
    [mag,~,x,y] = MFLISweep1D_getSample({'Vpp'},startAmp,stopAmp,deltaAmps(i),mfli_id,awg,4,0, ...
        'filter_order',1,'time_constant',0.1,'demod_rate',10e3);
    
    amps = startAmp:deltaAmps(i):stopAmp;
    minValAmp = amps(find(mag==min(mag)));
    fprintf('Min. amplitude setting at %f\n', minValAmp);
    setVal(awg,4,minValAmp);
    
    % Set new phase and amplitude sweep range
    startPhase = minValPhase - deltaPhases(i);
    stopPhase = minValPhase + deltaPhases(i);
    startAmp = minValAmp - deltaAmps(i);
    stopAmp = minValAmp + deltaAmps(i);
    
    fprintf(['Parasitics of X = ',num2str(x(find(mag==min(mag)))*1e6),' uVrms and Y = ',num2str(y(find(mag==min(mag)))*1e6),' uVrms remain.\n']);
end
end