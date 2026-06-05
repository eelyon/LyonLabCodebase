% Loop for ejecting electrons. It usually takes around 3 attempts to fully
% remove all electrons from the device.

for i = 1:3
 setGatesEject(pinout_sandia_roic)
 setGatesMeas(pinout_sandia_roic)
 sweep1DMeasSR830({'ST'},0,-0.8,-0.1,1,5,{SR830ST},pinout.tm.device,{pinout.tm.port},1);
 fprintf([num2str(i), ' '])
end
fprintf('\n')
