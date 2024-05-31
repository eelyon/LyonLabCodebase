scope = Oscilloscope;
masterTrigger = AWG;
triggerChannel = 'CH2';
samplePosition = 6.5;
% if ~strcmp(queryTDS2022TriggerSource(scope),triggerChannel)
%   setTDS2022TriggerSource(scope,triggerChannel);
% else
%   disp(['Trigger Source is set to ' triggerChannel])
% end
% 
if ~strcmp(queryTDS2022TriggerState(scope),'READY')
  primeTDS2022ForAcquisition(scope);
else
  disp('Oscilloscope is primed for acquisition');
end
% 
% pause(1)
% 
% pause(1)
% %setTDS2022TriggerLevel(Oscilloscope,triggerLevel);
% pause(1)
% 
 send33220Trigger(masterTrigger);
%pause(1);
figHandle = get2ChannelTDS2022Data(scope);%get1ChannelTDS2022Data(Oscilloscope,1);%
% emissionxLim = xlim;
% emissionyLim = ylim;
% text(emissionxLim(1)+.005,emissionyLim(1)+0.1,['VOffset = ' num2str(VOffset) 'V, VBias = ' num2str(VBias) 'V, VBacking = ' num2str(VBacking) 'V'])
% text(emissionxLim(1)+.005,emissionyLim(1)+0.05,['Sample position: ' num2str(samplePosition) ' mm, Sample Voltage = 4V.'])
% saveData(figHandle,'Filament_Emission');