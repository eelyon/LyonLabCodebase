folder = '03_22_24';
Folder     = append('Data\',folder); 

%% Read From Files
i        = 11510;
File     = sprintf('*IcVsIbPlot_%i*.fig',i);
S        = dir(fullfile(Folder,File));
IbSweep = S.name;
 
IbScan   = open([Folder '/' IbSweep]);     %load data to workspace
dataObjsX = findobj(IbScan,'-property','XData');
dataObjsY = findobj(IbScan,'-property','YData');

Ib = dataObjsX(1).XData;
Ic = dataObjsX(1).YData;
gain = abs(Ic./Ib);

figure(1)
yyaxis right
leftAxisRange = ylim([0 3e-6]);
dataAxisRange = [0 420];
dataScaled = ((Ic - dataAxisRange(1)) / range(dataAxisRange)) * range(leftAxisRange) + leftAxisRange(1); 

yyaxis left
plot(Ib,dataScaled)

xl = xlim([0 7e-9]); 
yTicks = -1:6; 
% This next line is the same exact scaling we did above.
yTicksScaled = ((yTicks - dataAxisRange(1)) / range(dataAxisRange)) * range(leftAxisRange) + leftAxisRange(1); 
yTickXvals = repmat(xl(1), size(yTicksScaled)); 
yTickLabels = strsplit(num2str(yTicks)); 
text(yTickXvals, yTicksScaled, yTickLabels, 'HorizontalAlignment', 'Left')
hold off


close(IbScan)