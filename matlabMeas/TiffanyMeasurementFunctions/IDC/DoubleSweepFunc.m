function [] = DoubleSweepFunc(Config)
initializeSR830Meas2D_Func('ST','ST',1)

switch Config
    case 'before TauE'
    % Collector Sweep
    sweepParams1 = {'ST','ST',0,1,-0.1,VmeasC,StmCPort};
    % Emitter Sweep
    sweepParams2 = {'ST','ST',0,1,-0.1,VmeasE,StmEPort};    
    
    case 'after TauE'
    % Collector Sweep
    sweepParams1 = {'ST','ST',0,1,-1,VmeasC,StmCPort};
    % Emitter Sweep
    sweepParams2 = {'ST','ST',0,1,-1,VmeasE,StmEPort};
    V          = [0:-0.02:-.2 -.3:-.2:-1.5]
    otherwise 
    disp('error!')
end

timeBetweenPoints = 12*0.01;
repeat = 10;
sweep2DMeasSR830_Func(sweepParams1,sweepParams2,timeBetweenPoints,repeat,readSR830)

end