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
    % Anthony's 24 channel DACs
    sigDACPortControl = 'COM6';
    sigDACPortSupply  = 'COM8';

    % SR830s
    VmeasTop_Address    = '172.29.117.106';    
    VmeasBottom_Address = '172.29.117.103';
    
    % Keysight DMM
    DMM_Address = '172.29.117.107';
    
    % Keysight AWG (Houck)
    houckAWG_Address = '172.29.117.137';
    
    % Keysight AWG (Natalie)
    deLeonAWG_Address = '172.29.117.133';

    % Oscilloscope
    oscope_Address = 'USB0::0x0699::0x03A5::C011465::0';



end

controlDAC = sigDAC(sigDACPortControl,24,'controlDAC');
supplyDAC = sigDAC(sigDACPortSupply,24,'supplyDAC');
controlDACGUI = sigDACGUI;
supplyDACGUI = sigDACGUI;

% VmeasTop = SR830(port,VmeasTop_Address);
SR830Twiddle = SR830(port,VmeasBottom_Address);
SR830TwiddleC = SR830(1234,VmeasTop_Address);

Awg2Ch = Agilent33622A(1234,houckAWG_Address,1); % two-channel AWG
Ag2Nat = Agilent33622A(1234,deLeonAWG_Address,1); % two-channel AWG

% Oscope = TDS2022C(oscope_Address);
% % IDC = SIM900(IDCPort);
% VpulsSig = SDG5122(Sig_Address);
% % Filament = Agilent33220A(port,Fil_Address,1);
% Thermometer = TCPIP_Connect(DMM_Address,port);

% GUI = Tiffany_GUI;
% DCMap;