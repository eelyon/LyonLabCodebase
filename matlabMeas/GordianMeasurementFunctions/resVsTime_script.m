timeBetweenPoints = 10;
[time,frequency] = deal(inf);

freqvsmag = plotData(time,frequency,'xLabel',"Time (sec)",'yLabel',"Frequency (GHz)",'color',"r-x");
resVsTime(ENA,timeBetweenPoints,freqvsmag);