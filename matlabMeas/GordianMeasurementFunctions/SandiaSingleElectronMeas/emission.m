% AwgFilament = Agilent33220A(port,'172.29.117.127',1);
% siglentFil = SPD330('172.29.117.8',1);

setVolt(siglentFil,2,1.98) % Set emission voltage
setGatesEmission(pinout,'vclose',-3.2,'vbackmetal',-1) % Set gates for emission and wait
delay(5)
send33220Trigger(AwgFilament) % Trigger filament AWG
fprintf('AWG triggered\n')
delay(10)
setGatesExperiment(pinout) % Set gates for experiment and wait
delay(20)
sweep1DMeasSR830({'ST'},0,-1,-0.1,1,1,{SR830ST},pinout.stm.device,{pinout.stm.port},1);