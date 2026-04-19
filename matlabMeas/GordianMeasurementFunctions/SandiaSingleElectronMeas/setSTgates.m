function [] = setSTgates(pinout,bias,numSteps)
%SETSTGATES Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    pinout
    bias
    numSteps
end

sigDACRampVoltage(pinout.std.device,pinout.std.port,bias,numSteps) % ramp ST-Drive
sigDACRampVoltage(pinout.sts.device,pinout.sts.port,bias,numSteps) % ramp ST-Sense
sigDACRampVoltage(pinout.stm.device,pinout.stm.port,bias,numSteps) % ramp ST-Middle
end