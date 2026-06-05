for i = 1:10
    sigDACRampVoltage(DAC,[12,16,14],[0.6,0.3,0],200);
    pause(2);
    sigDACRampVoltage(DAC,[4],[0],20000);
    pause(2);
    sigDACRampVoltage(DAC,[4],[-1],20000);
    pause(2);
    sigDACRampVoltage(DAC,[12,16,14],[0,0.3,0.6],200);
    pause(2);
    sigDACRampVoltage(DAC,[1],[0.5],20000);
    pause(2);
    sigDACRampVoltage(DAC,[1],[-1],20000);
    pause(2);
end