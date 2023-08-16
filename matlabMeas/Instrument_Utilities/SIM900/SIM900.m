classdef SIM900
    properties
        comPort
        client
        identifier
    end
    
    methods
        function SIM900 = SIM900(comPort)
            SIM900.client = serial_Connect(comPort);
            pause(1);
            SIM900.comPort = comPort;
            SIM900.identifier = query(SIM900.client,"*IDN?");
        end

       function [] = setSIM900Voltage(SIM900,port,voltage)
           voltageResolution = .001;
           currentVoltage = str2double(querySIM900Voltage(SIM900, port));
           
           if abs(voltage - currentVoltage) < voltageResolution
               fprintf('Voltage step is too small for SIM900\n');
           else
               connectSIM900Port(SIM900,port);
               %pause(0.1)
               command = ['VOLT ' num2str(voltage)];
               fprintf(SIM900.client,command);
               disconnectSIM900Port(SIM900);
           end
       end

       function [voltage] = querySIM900Voltage(SIM900,port)
           %disconnectSIM900Port(SIM900);
           connectSIM900Port(SIM900,port);
           command = 'VOLT?';
           voltage = query(SIM900.client,command);
           disconnectSIM900Port(SIM900);
       end

       function [] = connectSIM900Port(SIM900,port)
           command = ['CONN ' num2str(port) ',"XYZ"'];
           fprintf(SIM900.client,command);
       end

       function [] = disconnectSIM900Port(SIM900)
           command = 'XYZ';
           sendCommand(SIM900.client,command);
       end
    end
end

