%% Script used to initialize an experiment.

port = 1234;

% SR830_Address = '172.29.117.102';
% SR830 = SR830(port,SR830_Address);
% 
% DMM_Address = '172.29.117.104';
% Thermometer = TCPIP_Connect(DMM_Address,port);
% 
% sigDACPort = 'COM8';
% DAC = sigDAC(sigDACPort,12);
%
% AWG_Address = '172.29.117.108';
% AWG = Agilent33220A(port,AWG_Address);

 DACGUI = sigDACGUI;
% SR830GUI = SR830_GUI;
%SR830SWEEPGUI = sweepSR830GUI;

%SR830SWEEPGUI.SR830ReadEditField.Value = 'SR830';
%SR830SWEEPGUI.SweepDeviceEditField.Value = 'DAC';
%SR830SWEEPGUI.numRepeatsEditField.Value = 10;
%DCMap;