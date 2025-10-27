% Loop for ejecting electrons.
% Usually takes 3 attempts to remove all electrons from the device.
for i = 1:5
 eject_setgates(pinout); delay(5)
 experiment_setgates(pinout); delay(5)
 sweep1DMeasSR830({'ST'},0,-0.8,-0.1,1,5,{SR830ST},pinout.stm.device,{pinout.stm.port},1);
 fprintf([num2str(i), ' '])
end
fprintf('\n')