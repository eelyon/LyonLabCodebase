scope = Oscilloscope;
masterTrigger = Ag33220;
triggerChannel = 'CH2';
VOffset = 1;
VBias = 2.2;
VBacking = getVal(DAC,8);
VTM = getVal(DAC,7);
triggerLevel = -1*(VBias + VOffset/2);
samplePosition = 6.5;
% if ~strcmp(queryTDS2022TriggerSource(scope),triggerChannel)
%   setTDS2022TriggerSource(scope,triggerChannel);
% else
%   disp(['Trigger Source is set to ' triggerChannel])
% end
% 
% if ~strcmp(queryTDS2022TriggerState(scope),'READY')
%   primeTDS2022ForAcquisition(scope);
% else
%   disp('Oscilloscope is primed for acquisition');
% end
% 
% pause(1)
% 
% pause(1)
% %setTDS2022TriggerLevel(Oscilloscope,triggerLevel);
% pause(1)
% 
% send33220Trigger(Ag33220);
%pause(1);
figHandle = get1ChannelTDS2022Data(Oscilloscope,1);%get2ChannelTDS2022Data(Oscilloscope);
emissionxLim = xlim;
emissionyLim = ylim;
text(emissionxLim(1)+.005,emissionyLim(1)+0.1,['VOffset = ' num2str(VOffset) 'V, VBias = ' num2str(VBias) 'V, VBacking = ' num2str(VBacking) 'V'])
text(emissionxLim(1)+.005,emissionyLim(1)+0.05,['Sample position: ' num2str(samplePosition) ' mm, Sample Voltage = 4V.'])
saveData(figHandle,'Filament_Emission');