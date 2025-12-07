% Loop for ejecting electrons.
% Usually takes 3 attempts to remove all electrons from the device.
for i = 1:10
 fprintf([num2str(i), ' '])
 setGatesEject(pinout); delay(5)
 setGatesExperiment(pinout); delay(5)
%  sweep1DMeasSR830({'ST'},0,-0.6,-0.05,1,1,{SR830ST},pinout.stm.device,{pinout.stm.port},1);
end
setGatesEject(pinout)
sigDACSetChannels(controlDAC,0)
sigDACSetChannels(supplyDAC,0)