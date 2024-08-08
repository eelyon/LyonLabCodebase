startFreq = 500;
stopFreq = 5e6;
numPoints = 10000;
numAvgs = 100;

fprintf(fieldFox,'*CLS\n');
fprintf(fieldFox,'SYST:ERR?\n');
initErrCheck = fscanf(fieldFox,'%c')

fprintf(fieldFox, ['FREQ:STAR ',num2str(startFreq),';STOP ',num2str(stopFreq),'\n'])
% Set number of trace points
fprintf(fieldFox,['SWE:POIN ' num2str(numPoints), '\n'])

avgData = [];
for i = 1:numAvgs
    fprintf(fieldFox,'INIT:CONT 0\n');
fprintf(fieldFox,'INIT;*OPC?\n')
trigComplete = fscanf(fieldFox,'%1d')
%Query FORMATTED data from fieldFox
% Set data format to real-32 bin block transfer
fprintf(fieldFox, 'FORM:DATA REAL,32\n')
fprintf(fieldFox, 'TRACE:DATA?')
myBinData = binblockread(fieldFox,'float');
    if i == 1
        avgData = myBinData;
    else
        avgData = avgData + myBinData;
    end
    delay(1);
end

avgData = avgData./numAvgs;
avgData = avgData.*1e9/250;

xDat = linspace(startFreq,stopFreq,numPoints);
[handle,myFig] = plotData(xDat,avgData,'xLabel',"Frequency (Hz)",'yLabel',"nV/sqrt(Hz)",'color',"r-",'type', "loglog");
%[handle2,myFig2] = plotData(xDat,myBinData,'xLabel',"Frequency (Hz)",'yLabel',"nV/sqrt(Hz)",'color',"r-",'type', "loglog");
annotation('textbox',[0.2 0.5 0.3 0.3],'String',"2K PSD Choked, x25 Amp Gain, x10 FEMTO gain",'FitBoxToText','on');
%saveData(myFig,'PSD');