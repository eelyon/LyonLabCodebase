% Loop for ejecting electrons.
% Usually takes 3 attempts to remove all electrons from the device.
for i = 1:5
 ejectSetGates(pinout); delay(5)
 experimentSetGates(pinout); delay(5)
 sweep1DMeasSR830({'ST'},0,-0.6,-0.05,1,1,{SR830ST},pinout.stm.device,{pinout.stm.port},1);
 fprintf([num2str(i), ' '])
end
ejectSetGates(pinout)
fprintf('\n')