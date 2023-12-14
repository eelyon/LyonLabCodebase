close all;

figPathCell = findFigNumPath(7423);
figPath = figPathCell{1};
[xData,yData] = getXYData(figPath,'Type','line','FieldNum',2);
xDat = xData(5740:8210);
yDat = yData(5740:8210);

P01 = fullWHM(xDat,yDat); % full width half maximum
P02 = xDat(find(yDat==min(yDat))); % resonance frequency
P03 = 4e-2; % height normalisation
C0 = max(yDat); % y-axis offset
P0 = [P01,P02,P03,C0]; % parameter matrix

[params,resnorm,residual,~,~,~,J] = lsqcurvefit(@lfun3c,P0,xDat,yDat);
yFit = lfun3c(params,xDat);
display(params)

figure
plot(xDat,yDat,'bo','DisplayName',sprintf('Q= %0.0f',Qfactor(P02,P01)))

hold on
plot(xDat,yFit,'r-','DisplayName','Lorentzian Fit')
hold off

legend
xlabel('Frequency (GHz)')
ylabel('S_{21} (dB)')
xlim([xDat(1),xDat(end)])

function F = lfun3c(p,x)
    % Four parameter lorentzian
    F = -1*0.5*p(1)./((x-p(2)).^2+(0.5*p(1)).^2)*p(3) + p(4);
end

function Q = Qfactor(fres,FWHM)
    % Quality factor
    Q = fres/FWHM;
end

function FWHM = fullWHM(x,y)
    % Function that gives rough estimate of FWHM
    halfMax = max(y)+(min(y)-max(y))/2;
    leftIndex = find(y <= halfMax,1,'first');
    rightIndex = find(y <= halfMax,1,'last');
    FWHM = x(rightIndex)-x(leftIndex);
end