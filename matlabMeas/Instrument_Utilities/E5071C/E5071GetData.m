function [freqData, yData] = E5071GetData(ENA,tag)
  % This function pulls data from the E5071 and returns the x and y values
  % in 2 separate arrays. Note that the scaling factor for the buffer size
  % has been arbitrary for now, the input buffer can be overflowed if the
  % numbers are large (query returns strings which take up so much space).
  
  numPoints = E5071QueryNumPoints(ENA);
  bufferSize = numPoints*50;
  
  if ENA.InputBufferSize ~= bufferSize
     fclose(ENA);
     ENA.InputBufferSize = bufferSize;
     fopen(ENA);
  end
  
  %Query freq. data (in GHz)
  freqData = str2num(query(ENA,':SENS1:FREQ:DATA?'))/1e9;
  
  % Y Data has 2 values, the primary and secondary, to accomodate for Smith
  % and Polar data formats. Most of the time, one only cares about the
  % primary format, so we will parse this data accordingly.
  rawYData = str2num(query(ENA,':CALC1:DATA:FDAT?\n'));
  yData = parseE5071Data(rawYData);
  %[freqScan, freqScanHandle] = plotData(freqData,yData,'xLabel','Frequency (GHz)','yLabel','Power (dBm)','color','r.','Title',[tag '']);
  %saveData(freqScanHandle,tag);
end


function [parsedData] = parseE5071Data(inputDataArr)
  for i = 1:2:length(inputDataArr)
    parsedData(floor(i/2) + 1) = inputDataArr(i);
  end
end
