% Script used to initialize an experiment.

port = 1234;
small_glass_dewar = 0;

if small_glass_dewar
    % Anthony's 24 channel DAC
    sigDACPort = 'COM8';

    % SR830s
    VmeasC_Address = '172.29.117.102';    
    VmeasE_Address = '172.29.117.103';
    
    % Keysight DMM for thermometer
    % DMM_Address = '172.29.117.104';
    
    % Agilent for Filament
    Fil_Address = '172.29.117.105';
    
    % Agilent for emitter door
    VpulsAgi_Address = '172.29.117.109';
    
    % Siglent for collector door
    Sig_Address = 'USB0::0xF4ED::0xEE3A::SDG050D1150018::0::INSTR';
    
else
    % Anthony's 24 channel DAC
    sigDACPort = 'COM8';

    % SR830s
    VmeasC_Address = '172.29.117.103';    
    VmeasE_Address = '172.29.117.106';
    
    % Keysight DMM
    DMM_Address = '172.29.117.107';
    
    % Agilent for Filament
    Fil_Address = '172.29.117.108';
    
    % Agilent for emitter door
    VtwiddleE_Address = '172.29.117.109';
    
    % Siglent or 2nd Agilent for collector door
    Sig_Address = 'USB0::0xF4ED::0xEE3A::SDG050D1150018::0::INSTR';
    VdoorModE_Address = '172.29.117.123';
    
    % SIM900 
    IDCPort = 'COM6';

    % Oscilloscope
    % oscope_Address = 'USB0::0x0699::0x0374::C011644::0';
end

DAC = sigDAC(sigDACPort,24);
VmeasC = SR830(port,VmeasC_Address);
VmeasE = SR830(port,VmeasE_Address);
Thermometer = TCPIP_Connect(DMM_Address,port);
Filament = Agilent33220A(port,Fil_Address);
VtwiddleE = Agilent33220A(port,VtwiddleE_Address);
VdoorModE = Agilent33220A(port,VdoorModE_Address,1);
% VtwiddleC = Agilent33220A(port,VtwiddleC_Address);
% VdoorModC = Agilent33220A(port,VdoorModC_Address,1);
% VpulsSig = Siglent5122(Sig_Address);
IDC = SIM900(IDCPort);
% Oscope = TDS2022C(oscope_Address);

DACGUI = sigDACGUI;
SR830GUI = SR830_GUI;
SR830GUI = SR830_GUI;
DCMap;