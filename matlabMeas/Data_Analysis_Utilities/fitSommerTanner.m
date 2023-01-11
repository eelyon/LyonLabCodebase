function [fitData] = fitSommerTanner(figNum,yScale)
%  Function fits Sommer Tanner data and overlays the fit and data in a new
%  figure.
%  Inputs: figNum - Sommer Tanner Figure Number to analyze. Pulls the Mag
%          vs Bias data
%          yScale - the scaling of the y axis (e.g if the minimum value is
%          1e-9, the scale is 1e-9).
   [xDataCell,yDataCell,xLab,yLab,titleName] = pullSR830Data(figNum,'Mag vs Bias',0);
   xDat = xDataCell{1};
   yDat = yDataCell{1};
   yDatScaled = yDat./yScale;
   fitData = STFit(xDat,yDatScaled, yScale);
   plot(fitData);
   xlabel(xLab);
   ylabel([yLab, ' Scale = ' num2str(yScale)]);
   title(titleName);
   hold on;
   plot(xDat,yDatScaled,'.');
end

