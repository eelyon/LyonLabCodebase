Oscilloscope = TDS;
triggerChannel = 'CH1';
VOff = -1.5;
VBias = -2;
VBack = -1; setVal(DAC,1,VBack);
VGu = 0; setVal(DAC,2,VGu);
VRes = -0.2; setVal(DAC,4,VRes);
VGND = -0.8; setVal(DAC,3,VGND);

%primeTDS2022ForAcquisition(TDS);
pause(1);
send33220Trigger(AWG);

TDSacqCyc(Oscilloscope, triggerChannel, VOff, VBias, VBack, VGu, VRes, VGND);