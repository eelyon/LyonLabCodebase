scope = Oscilloscope;
%masterTrigger = Ag33220;
triggerChannel = 'CH1';
VOffset = 2.2;
VBias = 2.6;
VBacking = 0;
triggerLevel = VBias + VOffset/2;
samplePosition = 12;
% if ~strcmp(queryTDS2022TriggerSource(scope),triggerChannel)
%   setTDS2022TriggerSource(scope,triggerChannel);
% else
%   display(['Trigger Source is set to ' triggerChannel])
% end
% 
% if ~strcmp(queryTDS2022TriggerState(scope),'READY')
%   primeTDS2022ForAcquisition(scope);
% else
%   display('Oscilloscope is primed for acquisition');
% end
% 
% pause(1)
% 
% pause(1)
% setTDS2022TriggerLevel(Oscilloscope,triggerLevel);
% pause(1)

%send33220Trigger(Ag33220);
pause(1);
figHandle = get2ChannelTDS2022Data(Oscilloscope);
emissionFigName = genFigName('Filament\_Emission');
emissionxLim = xlim;
emissionyLim = ylim;
text(emissionxLim(2),emissionyLim(2),emissionFigName,'HorizontalAlignment','right','VerticalAlignment','top')
text(.013,-.05,['VOffset = ' num2str(VOffset) 'V, VBias = ' num2str(VBias) 'V, VBacking = ' num2str(VBacking) 'V. Sample Position = ' num2str(samplePosition) 'mm. Moving back in'],'HorizontalAlignment','center','VerticalAlignment','top')
saveData(figHandle,'Filament_Emission');