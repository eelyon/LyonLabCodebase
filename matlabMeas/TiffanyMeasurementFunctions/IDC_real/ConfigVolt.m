DCMap

VBias = 1;
Vres = -5;
VSTM = 1;
VDoor = -5;
VDot = 3;
VTop = -3;
VTopMetal = -2;


waittime = 0.2;
    

setVal(Dot100Device,Dot100Port,VDot)
pause(waittime)
setVal(Top100Device,Top100Port,VTop)
pause(waittime)
setVal(Bias100Device,Bias100Port,VBias)
pause(waittime)
setVal(Res100Device,Res100Port,Vres)
pause(waittime)
setVal(STM100Device,STM100Port,VSTM)
pause(waittime)
setVal(Door100Device,Door100Port,VDoor)
pause(waittime)
setVal(TopMetalDevice,TopMetalPort,VTopMetal)
