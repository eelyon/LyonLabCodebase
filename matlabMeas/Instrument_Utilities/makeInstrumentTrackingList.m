function [] = makeInstrumentTrackingList(instrumentList)
    listPath = getInstUtilitiesPath();

    utilitiesPath = fullfile(listPath,'instrumentList.txt');
    
    if ~exist(utilitiesPath,'file')
        listFile = fopen(utilitiesPath,'a+');
        fprintf(listFile,'%s', 'Instruments: ');
    else
        listFile = fopen(utilitiesPath,'a+');
    end

    for i = 1:length(instrumentList)
        if i ~= length(instrumentList)
            instStr = append(instrumentList(i),',');
        else
            instStr = instrumentList(i);
        end
        fprintf(listFile,'%s',instStr);
    end
    fclose(listFile);
end

