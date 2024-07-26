% yDat = []
% for i = 1:length(RTX)
%     yDat(i) = 31*(10000/(RTX(i) + 10000));
% end
% 
% plotData(RTX,yDat);
RTVoltageRatio = []

for i = 1:length(correctRTY)
    RTVoltageRatio(i) = 10^(testY(i)/20);%sqrt((10^(correctRTY(i)/10))*0.001*50);
end