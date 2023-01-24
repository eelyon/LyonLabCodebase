function [] = initialize_Experiment(User)
%% function used to initialize an experiment.

    if strcmp(User,'MMF')
        port = 1234;

        SR830_Address = '172.29.117.106';
        SR830 = SR830(port,SR830_Address);
        % 
        DMM_Address = '172.29.117.107';
        Thermometer = TCPIP_Connect(DMM_Address,port);
        
        sigDACPort = 'COM5';
        DAC = sigDAC(sigDACPort,8);
        
        AWG_Address = '172.29.117.108';
        AWG = Agilent33220A(port,AWG_Address);
        
        DACGUI = sigDACGUI;
        SR830GUI = SR830_GUI;

    elseif strcmp(User,'TL')
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

    else strcmp(User,'Matt')
        disp('under construction')
    
    end
end 
