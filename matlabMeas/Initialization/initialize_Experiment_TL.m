%% Script used to initialize an experiment.

port = 1234;

VmeasC_Address = '172.29.117.102';
VmeasC = SR830(port,VmeasC_Address);

VmeasE_Address = '172.29.117.103';
VmeasE = SR830(port,VmeasE_Address);

DMM_Address = '172.29.117.104';
Thermometer = TCPIP_Connect(DMM_Address,port);

sigDACPort = 'COM8';
DAC = sigDAC(sigDACPort,12);

AWG_Address = '172.29.117.105';
AWG = Agilent33220A(port,AWG_Address);

DACGUI = sigDACGUI;
SR830GUI = SR830_GUI;