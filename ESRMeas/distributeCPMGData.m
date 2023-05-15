function [] = distributeCPMGData(timeData,rawI,rawQ,parameters)
  numShots = parameters.npulse;
  tau = parameters.tau0;
  tOffset = parameters.tOffset;
  acq_time = parameters.acq_time;
  netNumSamples = acq_time/(4e-9); %Assumption is that we're using 250MHz sampling rate
  int_width = parameters.int_w;
  binningWidth = round(20000*1e-9*(netNumSamples)/acq_time);
  figNum = 4;
  for i = 1:numShots
    centerTime = 1e-9*(tau*(2*i-1)+tOffset);
    centerSample = round(centerTime*(netNumSamples)/acq_time);
    
    xData = timeData(round(centerSample - binningWidth/2):round(centerSample+binningWidth/2));
    iData = rawI(round(centerSample - binningWidth/2):round(centerSample+binningWidth/2));
    qData = rawQ(round(centerSample - binningWidth/2):round(centerSample+binningWidth/2));
    currentEchoShot = figure(figNum);
    plot(xData,iData,'green',xData,qData,'blue');
    figNum = figNum + 1;
    saveCPMGShots(currentEchoShot,numShots,i);
  end
%   dataPath = getDataPath();
%   fileNum = getCurrentFileNum(dataPath);
%   currentDateFolder = getCurrentDataFolder(dataPath);
%   figName = [figName '_' num2str(fileNum)];
%   figPath = getFigPath(currentDateFolder,figName);
%   saveas(figObject,figPath,'fig');
end

