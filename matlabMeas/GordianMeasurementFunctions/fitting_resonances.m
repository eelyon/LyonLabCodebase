%Three parameter Lorentzian (with constant term)
%L3C(X) = P1./((X - P2).^2 + P3) + C

figPathCell = findFigNumPath(5626);
figPath = figPathCell{1};
[xDat,yDat] = getXYData(figPath,'Type','line','FieldNum',2);

P01 = ;
P02 = fdata(find(mag==min(mag)));
P03 = P01^2;
C0 = -50;
P0 = [P01,P02,P03,C0];
fitData = lorentzfit(x,y,varargin);

