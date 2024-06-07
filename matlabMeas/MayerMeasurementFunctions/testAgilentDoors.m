%% testAgilentdoors

powerSwitchBox(supplyDAC,4,5,1)  % turn on switch box

closedDoor1 = 17;
openDoor1   = 22;

closedDoor2 = 8;
openDoor2   = 9;

setVal(supplyDAC,closedDoor1,-0.25);
setVal(supplyDAC,openDoor1,0.25);

setVal(supplyDAC,closedDoor2,-0.5);
setVal(supplyDAC,openDoor2,0.5);

pulseWidthArr = 1e-6:10e-6:300e-6;
for pulseWidth = pulseWidthArr
    % set both door pulse lengths
    doorAgi(Vpuls1,Vpuls2,10e-6,pulseWidth,'s');

    if ~strcmp(queryTDS2022TriggerState(scope),'READY')
        primeTDS2022ForAcquisition(scope);
    else
        disp('Oscilloscope is primed for acquisition');
    end
    pause(1);
    send33220Trigger(masterTrigger);
    pause(1);
    %[xDat1,yDat1] = getTDS2022YData(Oscilloscope,1);
    [xDat2,yDat2] = getTDS2022YData(Oscilloscope,2);
    if pulseWidth == 1e-6
        plotData(xDat2,yDat2,'holdOn',1,'color',"r-");
    else
        plot(xDat2,yDat2);
    end
end


% turn off all voltages
setVal(supplyDAC,closedDoor1,0);
setVal(supplyDAC,openDoor1,0);
setVal(supplyDAC,closedDoor2,0);
setVal(supplyDAC,openDoor2,0);
powerSwitchBox(supplyDAC,4,5,0)  % turn off switch box

