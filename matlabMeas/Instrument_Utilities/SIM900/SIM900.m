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

       function [] = setBulkSIM900Voltage(SIM900,ports,voltages)
           for k = 1:numel(ports)
               setSIM900Voltage(SIM900,ports(k),voltages(k))
           end
       end

       function [] = rampSIM900Voltage(SIM900,port,voltage, pauser, delta)
           voltageResolution = .001;
           currentVoltage = str2double(querySIM900Voltage(SIM900, port));
           
           if abs(voltage - currentVoltage) < voltageResolution
               fprintf('Voltage step is too small for SIM900\n');
           else
               connectSIM900Port(SIM900,port);
               for volts = currentVoltage:sign(voltage - currentVoltage)*delta:voltage
                   command = ['VOLT ' num2str(volts)];
                   fprintf(SIM900.client,command);
                   pause(0.01+pauser);
               end
               disconnectSIM900Port(SIM900);
           end
       end

       function [] = rampBulkSIM900Voltage(SIM900,ports,voltages)
           for k = 1:numel(ports)
               rampSIM900Voltage(SIM900,ports(k),voltages(k), 0.001, 0.001)
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

