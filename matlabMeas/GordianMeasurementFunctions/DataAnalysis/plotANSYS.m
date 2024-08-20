data = readtable('C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\Simulations\sandia_loadingPotential_TM-1V.txt','HeaderLines',1);
x = data.Var1;
y = data.Var2;
voltage = data.Var4;
xVal = 0:0.1e-6:25e-6;
yVal = 0:0.1e-6:9e-6;
spacing = 0.1e-6;

vData = [];

for i = 1:length(xVal)
    for j = 1:length(yVal)
        vData(i,j) = voltage(length(yVal)*(i-1)+j);
    end
end

figure
% plot(yVal(1:30),voltage(1:30))

pcolor(xVal*1e6,yVal*1e6,vData.');
shading interp
% title("contour plot")
xlabel('x (\mum)')
ylabel('y (\mum)')

% image(x,y,voltage.','CDataMapping','scaled')
% % set(gca,'YDir','normal')

h = colorbar;
h.Label.VerticalAlignment = "bottom";
ylabel(h,'V (x,y)','FontSize',12,'Rotation',270)