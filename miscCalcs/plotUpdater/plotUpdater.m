x = 0:.001:4;
y = sin(x);
h = plot(x,y);

pause(1);

xnew = x;
ynew = sin(x.^3);
h = PlotUpdate(h, xnew, ynew);