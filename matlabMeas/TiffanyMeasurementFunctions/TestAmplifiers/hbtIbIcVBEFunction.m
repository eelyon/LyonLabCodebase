function [] = hbtIbIcVBEFunction(vSource,DMMVb,DMMVc,chan,IbVsVBEPlot,IcVsVBEPlot,IcVsIbPlot,startVoltage,stopVoltage,deltaVoltage,amplification,resistorVal,backgroundVoltageVi,waitTime,IbPObj,IcPObj,IcvsIbPObj)

cleanupObj = onCleanup(@()cleanMeUp(IbPObj,IcPObj,IcvsIbPObj));

voltage_VE = [];
voltage_VBE = [];
current_IB= [];
current_IC = [];

deltaVoltage = checkDeltaSign(startVoltage,stopVoltage,deltaVoltage);
voltArr = startVoltage:deltaVoltage:stopVoltage;
currentVal = 1;

for i=voltArr   
    setVolt(vSource,chan,i);
    delay(waitTime);
    voltage_VE(currentVal) = queryVolt(vSource,chan);
    current_IC(currentVal) = (queryHP34401A(DMMVc)-backgroundVoltageVi)*amplification;  % Amplification set on Ithaco! e.g 10^-6A/V = 10^6V/A amplification!!!
    delay(waitTime);
    vLoad = queryHP34401A(DMMVb);
    current_IB(currentVal) = vLoad/resistorVal;
    voltage_VBE(currentVal) = voltage_VE(currentVal) - vLoad;
    
    IbVsVBEPlot.YData = current_IB;
    IbVsVBEPlot.XData = voltage_VBE;

    IcVsVBEPlot.YData = current_IC;
    IcVsVBEPlot.XData = voltage_VBE;

    IcVsIbPlot.YData = current_IC;
    IcVsIbPlot.XData = current_IB;

    currentVal = currentVal+1;
    refreshdata;
    drawnow;
end

    function cleanMeUp(IbVsVBEPlot,IcVsVBEPlot,IcVsIbPlot)
        disp('Operation Terminated, saving data');
        saveData(IbVsVBEPlot,'IbVsVBE');
        saveData(IcVsVBEPlot,'IcVsVBEPlot');
        saveData(IcVsIbPlot,'IcVsIbPlot');
    end
end