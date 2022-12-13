function [instruments] = parseInstrumentList()
    instrumentPath = getInstUtilitiesPath();
    instPath = catFileAndFolders(instrumentPath,'instrumentList.txt');
    instrumentFile = fopen(instPath,'r+');
    instruments = fgetl(instrumentFile);
    fclose(instrumentFile);

    instruments = split(instruments,' ');
    instruments = split(instruments(2),',');
end

