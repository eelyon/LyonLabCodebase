fig = gca;
a = get(gca,'Children');
xdata = get(a, 'XData');
ydata = get(a, 'YData');
size(xdata)
figure(10)
plot(xdata,ydata)
xlabel('Transport Line Position (um)')
ylabel('Helium Depth (um)')

figure(11)
[pos, eField] = eFieldCalc(ydata*1e-6,xdata);
plot(pos,eField)
xlabel('Transport Line Position (um)')
ylabel('Electric Field (V/m)')

tfV = 3;
length = 4e-3;
E = tfV/length