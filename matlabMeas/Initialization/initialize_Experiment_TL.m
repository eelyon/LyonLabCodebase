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

%     VmeasC_Address = '172.29.117.103';    
%     VmeasE_Address = '172.29.117.106';
    
    % Keysight DMM
    DMM_Address = '172.29.117.107';
    
    % Agilent for Filament
    %Fil_Address = '172.29.117.127';

    % Agilent for collector door/twiddle
%     VdoorModC_Address = '172.29.117.127';
%     VtwiddleC_Address = '172.29.117.126';
% 
%     % Agilent for emitter door/twiddle (these are the top two Agilents)
%     VdoorModE_Address = '172.29.117.123';
%     VtwiddleE_Address = '172.29.117.125';

    % Siglent or 2nd Agilent for collector door
    Sig_Address = 'USB0::0xF4ED::0xEE3A::SDG050D1150018::0::INSTR';
    
    % SIM900 
    IDCPort = 'COM4';

    % Oscilloscope
    oscope_Address = 'USB0::0x0699::0x03A5::C011465::0';

    % Agilents for pulsed door experiment
    Vpuls1_Address = '172.29.117.125';
    Vpuls2_Address = '172.29.117.126';
    VpulsTrig_Address = '172.29.117.123';
end


controlDAC = sigDAC(sigDACPortControl,24,'controlDAC');
supplyDAC = sigDAC(sigDACPortSupply,24,'supplyDAC');
VmeasC = SR830(port,VmeasC_Address);
VmeasE = SR830(port,VmeasE_Address);

VtwiddleE = Agilent33220A(port,VtwiddleE_Address,1);
VdoorModE = Agilent33220A(port,VdoorModE_Address,1);

Vpuls1 = Agilent33220A(port,Vpuls1_Address,1);
Vpuls2 = Agilent33220A(port,Vpuls2_Address,1);
VpulsTrig = Agilent33220A(port,VpulsTrig_Address,1);
% VdoorModC = Agilent33220A(port,VdoorModC_Address,1);
% VtwiddleC = Agilent33220A(port,VtwiddleC_Address,1);

% Oscope = TDS2022C(oscope_Address);
% % IDC = SIM900(IDCPort);
% VpulsSig = SDG5122(Sig_Address);
% % Filament = Agilent33220A(port,Fil_Address,1);
% Thermometer = TCPIP_Connect(DMM_Address,port);

% GUI = Tiffany_GUI;
% DCMap;

% DMM1_Address = '172.29.117.107';
% DMM2_Address = '172.29.117.108';
% DMM1 = TCPIP_Connect(DMM1_Address,1234);
% DMM2 = TCPIP_Connect(DMM2_Address,1234);
