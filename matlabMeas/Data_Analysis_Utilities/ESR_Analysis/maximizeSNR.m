function [plotHandle,maxMag] = maximizeSNR(figureNum,startCenter,stopCenter,deltaCenter,startWidth,stopWidth,deltaWidth)
    dataPathCell = findFigNumPath(figureNum);%{'C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\04_11_23\filteredData\MMF_He_3_Cryo_IQ_748_filtered_100000_Hz.fig'};%findFigNumPath(figureNum);
    [QxDat,QyDat] = getXYData(dataPathCell{1},'fieldNum',7);
    [IxDat,IyDat] = getXYData(dataPathCell{1},'fieldNum',8);
    plotHandle = initializeSR830Meas2D_Func({'IntegrationWidth', 'ESRCenter'}, {startWidth, startCenter}, {stopWidth,stopCenter}, {deltaWidth, deltaCenter});
    maxMag = 0;
    sampleRate = 250*1e6;
    centerArr = [];
    numCenters = (stopCenter - startCenter)/deltaCenter + 1;
    for cIndex = 1:numCenters
        currentCenter = startCenter + deltaCenter*(cIndex-1);
        centerArr(cIndex) = currentCenter;
        [widthArr,magArr,maxMag] = echoIntegrationForSingleCenter(IyDat,QyDat,currentCenter,startWidth,stopWidth,deltaWidth,sampleRate,maxMag);
        distributeSNR2DData(cIndex,widthArr,magArr,plotHandle);
    end
end


function [noiseMagnitudeBaseline] = calculateMagnitudeNoise(IyDat,QyDat,widthInUs,sampleRate)

    noiseIntegrationWidthInSamples = 1e-6*sampleRate;
    noiseCenterLocation = 1e-6*sampleRate;
    [noiseI,noiseQ] = integrateEcho(IyDat,QyDat,noiseCenterLocation,noiseIntegrationWidthInSamples);
    scaledNoiseI = widthInUs*noiseI;
    scaledNoiseQ = widthInUs*noiseQ;
    noiseMagnitudeBaseline = sqrt(scaledNoiseI+scaledNoiseQ);
end

function distributeSNR2DData(cIndex,widthArr,magArr,plotHandle)
    for wIndex = 1:length(widthArr)
        plotHandle.CData(wIndex,cIndex) = magArr(wIndex);
    end
end

function [widthArr,magArr,maxMag] = echoIntegrationForSingleCenter(IyDat,QyDat,centerInUs,startWidth,stopWidth,deltaWidth,sampleRate,maxMag)
    centerSampleLocation = convertTimeToSample(centerInUs,sampleRate);
    widthArr = [];
    magArr = [];
    numWidths = (stopWidth - startWidth)/(deltaWidth) + 1;
    for wIndex = 1:numWidths
        currentWidthInUs = startWidth + deltaWidth*(wIndex-1);
        widthArr(wIndex) = currentWidthInUs;
        widthInSamples = convertTimeToSample(currentWidthInUs,sampleRate);
        [ISumSquared,QSumSquared] = integrateEcho(IyDat,QyDat,centerSampleLocation,widthInSamples);
        noiseMagnitude = calculateMagnitudeNoise(IyDat,QyDat,currentWidthInUs,sampleRate);
        mag = sqrt(ISumSquared+QSumSquared)/noiseMagnitude;
        if maxMag < mag
            maxMag = mag;
        end
        magArr(wIndex) = mag;
    end
end


function [ISumSquared,QSumSquared] = integrateEcho(IArr,QArr,centerSample,integrationWidth)
    leftSample = round(centerSample - integrationWidth/2);
    rightSample = round(centerSample + integrationWidth/2);

    ISumSquared = sum(IArr(leftSample:rightSample).^2);
    QSumSquared = sum(QArr(leftSample:rightSample).^2);
end

function sampleLocation = convertTimeToSample(timeInUs,sampleRateInS)
    sampleLocation = round(timeInUs*sampleRateInS*1e-6);
end
