classdef SIM900
    properties
        comPort
        client
        identifier
    end
    
    methods
        function SIM900 = SIM900(comPort)
            SIM900.client = serial_Connect(comPort);
            pause(1); % pause for connection to be established
            SIM900.comPort = comPort;
            SIM900.identifier = query(SIM900.client,"*IDN?");
        end

        function [] = setBuffer(SIM900,bufferSize)
            fclose(SIM900.client);
            SIM900.client.InputBufferSize = bufferSize; % 512 per module
            SIM900.client.OutputBufferSize = bufferSize; % 512 per module
            fopen(SIM900.client);
        end

       function [] = setSIM900Voltage(SIM900,port,voltage)
           voltageResolution = .001;
           currentVoltage = str2double(querySIM900Voltage(SIM900, port));
           
           if abs(voltage - currentVoltage) < voltageResolution && voltage ~= 0
               fprintf('Voltage step is too small for SIM900\n');
           else
               connectSIM900Port(SIM900,port);
               pause(0.1)
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

       function [] = rampSIM900Voltage(SIM900,port,voltage,pauser,delta)
           voltageResolution = .001;
           currentVoltage = str2double(querySIM900Voltage(SIM900, port));
           
           if abs(voltage - currentVoltage) < voltageResolution
               fprintf('Voltage step is too small for SIM928\n');
           else
               connectSIM900Port(SIM900,port);
               for volts = currentVoltage:sign(voltage - currentVoltage)*delta:voltage
                   command = ['VOLT ' num2str(volts)];
                   fprintf(SIM900.client,command);
                   while str2double(query(SIM900.client,'*OPC?')) == 0
                       continue % OPC flag writes 1 when operation complete
                   end
                   pause(pauser)
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

       function [] = setOutputSIM900Port(SIM900,port,onOff)
           % Turn port output on or off
           connectSIM900Port(SIM900,port)
           if strcmp(onOff,'ON')
               command = 'OPON';
               fprintf(SIM900.client,command);
           elseif strcmp(onOff,'OFF')
               command = 'OPOF';
               fprintf(SIM900.client,command);
           end
           disconnectSIM900Port(SIM900)
       end
    end
end

