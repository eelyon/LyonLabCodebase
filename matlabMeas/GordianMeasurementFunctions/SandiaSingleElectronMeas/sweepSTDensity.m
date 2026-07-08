vhold = 0:0.1:0.5;

for value = vhold
    fprintf(['vhold = +',num2str(value),' V\n'])
    sigDACRampVoltage(pinout.stm.device, pinout.stm.port, value, numSteps)
    sigDACRampVoltage(pinout.std.device, pinout.std.port, value, numSteps)
    sigDACRampVoltage(pinout.sts.device, pinout.sts.port, value, numSteps)
    delay(2)
    
    sweep1DMeasSR830({'ST'},0,-0.7,-0.05,1,1,{SR830ST},pinout.stm.device,{pinout.stm.port},1);
    delay(2)
end