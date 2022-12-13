function [] = doorAP24( AP24, vPort, TauE, TauC )
    DCMap;
    fprintf(AP24,['DOOR ' num2str([2,DoorEPort,DoorCPort, ...
                     4,vPort,2,0,0,TauE,TauC])])
end