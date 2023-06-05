%% Script used to initialize an experiment.

port = 1234;

SR830_Address = '172.29.117.103';
SR830 = SR830(port,SR830_Address);

DMM_Address = '172.29.117.104';
Thermometer = TCPIP_Connect(DMM_Address,port);

sigDACPort = 'COM4';
DAC = sigDAC(sigDACPort,16);
DACGUI = sigDACGUI;

AWG_Address = '172.29.117.105';
AWG = Agilent33220A(port,AWG_Address);
% 
% TDS_Address = 'USB0::0x0699::0x03A5::C011465::INSTR';
% TDS = TDS2022C(TDS_Address);

% SR830GUI = SR830_GUI;
% SR830SWEEPGUI = sweepSR830GUI;
%
%SR830SWEEPGUI.SR830ReadEditField.Value = 'SR830';
%SR830SWEEPGUI.SweepDeviceEditField.Value = 'DAC';
%SR830SWEEPGUI.numRepeatsEditField.Value = 10;
%DCMap;