close all;

figNum1 = 7423;
figNum2 = 7487;

figPath1 = findFigNumPath(figNum1);
[xDat1,yDat1]=getXYData(figPath1{1},'Type','line','FieldNum',2);

LHe_cc = @(Patm) Patm.*(18.44+3.213)*2.54^3/757;

[figMetaData1,figHandle1] = displayFigNum(figNum1,'visibility',0);
LHe1 = figMetaData1{1}.Patm;
T1 = figMetaData1{1}.temperature;
closeFigure(figHandle1); pause(0.01);

figPath2 = findFigNumPath(figNum2);
[xDat2,yDat2]=getXYData(figPath2{1},'Type','line','FieldNum',2);

[figMetaData2,figHandle2] = displayFigNum(figNum2,'visibility',0);
LHe2 = figMetaData2{1}.Patm;
T2 = figMetaData2{1}.temperature;
closeFigure(figHandle2); pause(0.01);

figure();
%Patm1 = figMetaData1{1}.Patm;
%LHe =num2str(LHe_cc(figMetaData1{1}.Patm));
%display(append('LHe =', LHe,'cm^3'));
%LHe1 = LHe_cc(figMetaData1{1}.Patm);
plot(xDat1,yDat1,'DisplayName',['LHe = ', num2str(LHe1),' cm^3']);
sgtitle(['T=', num2str(T1),'K']);

%hold on;
%plot(xDat2,yDat2,'DisplayName',['LHe = ', num2str(28.2743),' cm^3']);
%hold off;

legend
xlabel('Frequency (GHz)');ylabel('S_{21} (dB)')
xlim([1.33,1.36])

function [LHe_cc] = liquidHe(Patm)
    LHe_cc = Patm.*(18.44+3.213)*2.54^3/757;
end