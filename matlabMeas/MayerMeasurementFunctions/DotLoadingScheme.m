waittime = 0.2;
STBias = 0;
STNeg = -5;
resOffset = -.2;
NumSteps = 10;

ConfigVolt

DACGUI.updateDACGUI;
SR830GUI.updateSR830App;
drawnow;
% for vout = linspace(STBias,STNeg,NumSteps)
% 
%     setVal(Bias100Device,Bias100Port,vout);
%     pause(waittime)
%     setVal(STM100Device,STM100Port,vout);
%     pause(waittime)
%     setVal(Door100Device,Door100Port,vout);
%     pause(waittime)
%     setVal(Res100Device,Res100Port,vout);
%     pause(waittime)
% end

input('\nFlash\n')

for vout = linspace(STNeg,STBias,NumSteps)

    setVal(Bias100Device,Bias100Port,vout);
    pause(waittime)
    setVal(STM100Device,STM100Port,vout);
    pause(waittime)
%     setVal(Door100Device,Door100Port,vout);
%     pause(waittime)
%     setVal(Res100Device,Res100Port,vout);
%     pause(waittime)
end



%setVal(Res100Device,Res100Port,STBias+resOffset)
%setVal(Res100Device,Res100Port,STBias+resOffset)



