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
    DMM_Address = '172.29.117.104';
    
    % Agilent for Filament
    Fil_Address = '172.29.117.105';
    
    % Agilent for emitter door
    VpulsAgi_Address = '172.29.117.109';
    
    % Siglent for collector door
    Sig_Address = 'USB0::0xF4ED::0xEE3A::SDG050D1150018::0::INSTR';
    
else
    % Anthony's 24 channel DAC
    sigDACPort = 'COM4';

    % SR830s
    VmeasC_Address = '172.29.117.102';    
    VmeasE_Address = '172.29.117.106';
    
    % Keysight DMM
    DMM_Address = '172.29.117.107';
    
    % Agilent for Filament
    Fil_Address = '172.29.117.108';
    
    % Agilent for emitter door
    VpulsAgi_Address = '172.29.117.109';
    
    % Siglent for collector door
    Sig_Address = 'USB0::0xF4ED::0xEE3A::SDG050D1150018::0::INSTR';
end

DAC = sigDAC(sigDACPort,24);
VmeasC = SR830(port,VmeasC_Address);
VmeasE = SR830(port,VmeasE_Address);
Thermometer = TCPIP_Connect(DMM_Address,port);
Filament = Agilent33220A(port,Fil_Address);
VpulsAgi = Agilent33220A(port,VpulsAgi_Address);
VpulsSig = Siglent5122(Sig_Address);

DACGUI = sigDACGUI;
SR830GUI = SR830_GUI;
DCMap;