%% 2D sweep for Wigner crystal and melting
tStart = tic;

sweepTypes = {'TM','CT'};  
starts = {0,-0.1};
stops = {-0.5,0.5};
deltaParams = {-0.1,0.1};

devices = {DAC,DAC};
ports = {{IdcNFPort},{TfCPort}};  % (IDC neg, TFC)
extraPorts = {{IdcPFPort},{TfEPort},BiasCPort};  % (IDC pos,TFE)
readSR830 = VmeasE;

timeBetweenPoints = 0.5;
repeat = 5;

sweep2DMeasSR830_Func(sweepTypes, starts, stops, deltaParams, devices, ports, timeBetweenPoints,repeat,readSR830,extraPorts)

tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));

