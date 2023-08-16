function [] = CalibrateDAC( AP24,VoltMeter,Port )
%% Calibrate DAC voltages using a MultiMeter
%% note: all ports have RC filters except for port 11,23 
%% to calibrate your DAC, run this function for each port, then FitCode, then CheckCalibration

    vRange = -9.8:.49:9.8;
    voltArr = zeros(1,numel(vRange));
    ctr = 1;
    for i = vRange
        fprintf(AP24.client,['CH ' num2str(Port)]);
        fprintf(AP24.client,['VOLT ' num2str(i)]);
        pause(1);  % to account for capacitors in filter
        voltage = str2double(query(VoltMeter, 'READ?'));
        voltArr(ctr) = voltage ;
        ctr=ctr+1;
        pause(0.5);
    end
    
    Folder = 'TiffanyMeasurementFunctions\IDC\CalibrateDac\VoltSweepFiles\';
    filename = [Folder 'CH' num2str(Port) '.mat'];
    save( filename, 'voltArr' );

end

