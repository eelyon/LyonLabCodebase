function [] = E5071SetMarkerX(ENA,markerNum,xVal)
% xVal in GHz!
  
  startFreq = E5071QuerySweepStart(ENA)/(1e9);
  if(xVal < startFreq)
    fprintf(['Target frequency ', num2str(xVal), 'GHz is less than the start frequency ', num2str(startFreq), 'GHz please increase the frequency\n']);
    return;
  end
  
  stopFreq = E5071QuerySweepStop(ENA)/(1e9);
  if(xVal > stopFreq)
    fprintf(['Target frequency ', num2str(xVal), 'GHz is greater than the stop frequency ', num2str(stopFreq), 'GHz please increase the frequency\n']);
    return;
  end
  
  xVal = xVal*1e9;
  cmd = [':CALC1:TRAC1:MARK',num2str(markerNum),':X ',num2str(xVal)];
  fprintf(ENA, cmd);
end

