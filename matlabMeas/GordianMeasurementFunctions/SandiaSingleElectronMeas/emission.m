setVolt(siglentFil,2,1.9) % Set emission voltage
setGatesEmission(pinout,'vclose',-3.1,'vbackmetal',0) % Set gates for emission and wait
delay(5)
send33220Trigger(AwgFilament) % Trigger filament AWG
fprintf('AWG triggered\n')
delay(10)
setGatesExperiment(pinout) % Set gates for experiment and wait
delay(10)
sweep1DMeasSR830({'ST'},0,-0.9,-0.05,1,1,{SR830ST},pinout.stm.device,{pinout.stm.port},1);