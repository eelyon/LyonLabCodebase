function [] = DoubleSweepFunc(Config)
initializeSR830Meas2D_Func('ST', 'ST' , 1)
switch Config    
    case 'before TauE'
    % Collector Sweep
    sweepParams1 = 'ST', 'ST', sweepType1,start1,stop1,deltaParam1,device1,ports1]
    % Emitter Sweep
    sweepParams2 = 'ST', 'ST', 
    
    sweep2DMeasSR830_Func(sweepParams1,sweepParams2,timeBetweenPoints,repeat,readSR830)
    otherwise 
end
end