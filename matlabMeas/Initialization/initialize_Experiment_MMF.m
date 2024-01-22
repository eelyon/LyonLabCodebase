%% Script used to initialize an experiment.

port = 1234;
%  
% SR830_Address = '172.29.117.106';
% SR830 = SR830(port,SR830_Address);

% NullAWGAddress = '172.29.117.125';
% NullAWG = Agilent33220A(port,NullAWGAddress,1);
DMM_Address = '172.29.117.107';
Thermometer = TCPIP_Connect(DMM_Address,port);

% sigDACPort = 'COM8';
% DAC = sigDAC(sigDACPort,24,'DAC');
% % % 
% AWG_Address = '172.29.117.126';
% AWG = Agilent33220A(port,AWG_Address,1);
% 
% DACGUI = sigDACGUI;
% SR830GUI = SR830_GUI;
% SR830SWEEPGUI = sweepSR830GUI;
% % 
% SR830SWEEPGUI.SR830ReadEditField.Value = 'SR830';
% SR830SWEEPGUI.SweepDeviceEditField.Value = 'DAC';
% SR830SWEEPGUI.numRepeatsEditField.Value = 10;
% DCMap;