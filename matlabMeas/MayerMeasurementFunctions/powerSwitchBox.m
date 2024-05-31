function [] = powerSwitchBox(dev,chan1,chan2,OnOff)
% TURN ON/OFF THE DOOR SWITCH BOX
%   dev: power supply source
%   chan1: +5 volt supply
%   chan2: -5 volt supply
if OnOff
    display("Ramping switchbox on");
    rampVal(dev,chan1,getVal(dev,chan1),5,0.05,0.05);
    rampVal(dev,chan2,getVal(dev,chan2),-5,0.05,0.05);
else
    display("Ramping switchbox off");
    rampVal(dev,chan1,getVal(dev,chan1),0,-0.05,0.05);
    rampVal(dev,chan2,getVal(dev,chan2),0,-0.05,0.05);
end

end