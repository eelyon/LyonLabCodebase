function [] = rampAP24( AP24 , chanList, voltList, numSteps )
  calibrate = 0;
  numChans = length(chanList);
  numVolts = length(voltList);

   if calibrate
        Folder = 'CalibrateDac\AP24\';
        calvoltList = zeros(1,numel(voltList));
        ctr = 1;
        
        for i=1:length(voltList)
            load([Folder 'CH' num2str(i) '.mat']);
            value = voltList(i);
            vRange = -9.8:0.49:9.8;
            new = interp1(vRange, vRange*m+b, value);
            newVolt = (value-new)+value;
            calvoltList(ctr) = newVolt;
            ctr = ctr+1;
        end
        
        fprintf(AP24,['RAMP ' num2str([numSteps,numChans,chanList, ...
            numVolts,calvoltList])]);
    
    else
        fprintf(AP24,['RAMP ' num2str([numSteps,numChans,chanList, ...
            numVolts,voltList])])
    end
end