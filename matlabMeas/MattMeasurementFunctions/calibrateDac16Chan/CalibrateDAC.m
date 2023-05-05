function [] = CalibrateDAC(DAC,DMM,Port)
% Calibrate DAC voltages using a Multimeter
% note: this calibration was done without a filter box 
    vRange = -9.8:.49:9.8;
    voltArr = zeros(1,numel(vRange));
    ctr = 1;
    for i = vRange
        setVal(DAC,Port, i);
        pause(1);
        voltage = str2double(query(DMM, 'READ?'));
        voltArr(ctr) = voltage ;
        ctr=ctr+1;
        pause(0.5);
    end
    
    filename = ['VoltSweepFiles\CH' num2str(Port) '.mat'];
    save( filename, 'voltArr' );

end