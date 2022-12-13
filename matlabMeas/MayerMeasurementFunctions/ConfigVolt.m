DCMap

VBias = -5;%0;
Vres = -5;%0.5;
VSTM = -5;%0.5;
VDoor = -5;%0.5;

VDot = 1;%-0.5;
VTop = 1;%-0.5;

%VTopMetal is for the backing plate
VTopMetal = -2;%-0.5;


waittime = 0.2;
    

setVal(Dot100Device,Dot100Port,VDot);
pause(waittime);
setVal(Top100Device,Top100Port,VTop);
pause(waittime);
%setVal(Bias100Device,Bias100Port,VBias)
%pause(waittime)
setVal(Res100Device,Res100Port,Vres);
pause(waittime);
setVal(STM100Device,STM100Port,VSTM);
pause(waittime);
setVal(Door100Device,Door100Port,VDoor);
pause(waittime);
setVal(TopMetalDevice,TopMetalPort,VTopMetal)
