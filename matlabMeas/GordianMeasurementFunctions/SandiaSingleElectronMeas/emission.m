% awgFilament = Agilent33220A(port,'172.29.117.127',1);
% siglentFilament = SPD330('172.29.117.8',1);

setVolt(siglentFilament,2,2.02) % Set emission voltage
setGatesEmission(pinout,'vlow',-3.1,'vbackmetal',0) % Set gates for emission and wait
delay(5)
send33220Trigger(awgFilament) % Trigger filament AWG
fprintf('AWG triggered\n')
delay(10)
setGatesExperiment(pinout) % Set gates for experiment and wait
delay(20)
sweep1DMeasSR830({'ST'},0,-1.5,-0.1,1,1,{SR830ST},pinout.stm.device,{pinout.stm.port},1);