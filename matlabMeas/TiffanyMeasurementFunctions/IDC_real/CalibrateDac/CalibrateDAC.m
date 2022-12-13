function [] = CalibrateDAC( AP24,Rtemp,Port )
% Calibrate DAC voltages using a Multimeter
% note: all ports have RC filters except for port 11,23 
    vRange = -9.8:.49:9.8;
    voltArr = zeros(1,numel(vRange));
    ctr = 1;
    for i = vRange
        fprintf(AP24,['CH ' num2str(Port)]);
        fprintf(AP24,['VOLT ' num2str(i)]);
        pause(1);  % to account for capacitors in filter
        voltage = str2double(query(Rtemp, 'READ?'));
        voltArr(ctr) = voltage ;
        ctr=ctr+1;
        pause(0.5);
    end
    
    filename = ['CalibrateDac\VoltSweepFiles\CH' num2str(Port) '.mat'];
    save( filename, 'voltArr' );

end

