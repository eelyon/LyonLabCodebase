function [] = TDSacqCyc(Oscilloscope, triggerChannel, VOff, VBias, VBack, VGu, VRes, VGND)

    setTDS2022TriggerSource(Oscilloscope, triggerChannel);
    triggerLevel = VBias + VOff/2;
    samplePosition = 12;
    pause(1);
    figHandle = get2ChannelTDS2022Data(Oscilloscope);
    %emissionFigName = genFigName('Filament_Emission');
    %emissionxLim = xlim;
    %emissionyLim = ylim;
    %text(emissionxLim(2),emissionyLim(2),emissionFigName,'HorizontalAlignment','right','VerticalAlignment','top')
    titleStr = [strcat('VOffset = ', num2str(VOff), 'V, VBias = ', num2str(VBias), 'V, VBacking = ', num2str(VBack), 'V') newline strcat('VGuard = ', num2str(VGu), 'V, VRes = ', num2str(VRes), 'V, VGND = ', num2str(VGND), 'V')];
    t = title(char(titleStr));
    saveData(figHandle,'filamentEmission');

    end