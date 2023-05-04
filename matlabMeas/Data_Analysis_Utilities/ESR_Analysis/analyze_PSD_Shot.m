function [phase] = analyze_PSD_Shot(filePath)
    [QxDat,QyDat] = getXYData(filePath,'fieldNum',2);
    [IxDat,IyDat] = getXYData(filePath,'fieldNum',1);
    sampleRate = 250*1e6;
    peakLocInSeconds = 14.35*1e-6;
    arrLoc = sampleRate*peakLocInSeconds;
    widthInSeconds = 4*1e-6;
    widthInSamples = sampleRate*widthInSeconds;
    
    startInt = round(arrLoc-widthInSamples/2);
    stopInt = round(arrLoc+widthInSamples/2);
    QInt = sum(QyDat(startInt:stopInt));
    IInt = sum(IyDat(startInt:stopInt));

    phase = atan2(QInt,IInt)*180/pi;

end

