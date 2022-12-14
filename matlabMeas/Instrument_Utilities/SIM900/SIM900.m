classdef SIM900
    properties
        COMPort
        client
        identifier
        ch1 {mustBeNumeric}
        ch2 {mustBeNumeric}
        ch3 {mustBeNumeric}
        ch4 {mustBeNumeric}
        ch5 {mustBeNumeric}
        ch6 {mustBeNumeric}
        ch7 {mustBeNumeric}
        ch8 {mustBeNumeric}
    end
    
    methods
        function SIM900 = SIM900(COMPort)
            SIM900.COMPort = COMPort;
            SIM900.identifier = 'SIM900';
            SIM900 = serial_Connect(COMPort);
            SIM900.ch1 = 0;
            SIM900.ch2 = 0;
            SIM900.ch3 = 0;
            SIM900.ch4 = 0;
            SIM900.ch5 = 0;
            SIM900.ch6 = 0;
            SIM900.ch7 = 0;
            SIM900.ch8 = 0;
        end

       function [] = setSIM900Voltage(SIM900,port,voltage)
           voltageResolution = .001;
           currentVoltage = querySIM900Voltage(SIM900.client,port);

           if abs(voltage - currentVoltage) > voltageResolution
               fprintf('Voltage step is too small for SIM900');
              
           else
               connectSIM900Port(SIM900,Port);
               command = ['VOLT ' num2str(voltage)];
               sendCommand(SIM900.client,command);
               setSIM900PortVoltage(SIM900,port,voltage);
               disconnectSIM900Port(Device);
           end
       end

       function [voltage] = querySIM900Voltage(SIM900,port)
           command = ['VOLT? ' num2str(port)];
           voltage = query(SIM900.client,command);
       end

       function [] = connectSIM900Port(SIM900,port)
           command = ['CONN ' num2str(port) ',"xyz"'];
           sendCommand(SIM900.client,command);
       end

       function [] = disconnectSIM900Port(SIM900)
           command = 'xyz';
           sendCommand(SIM900.client,command);
       end

       function SIM900 = setSIM900PortVoltage(SIM900,port,voltage)
           if port == 1
               SIM900.ch1 = voltage;
           elseif port == 2
               SIM900.ch2 = voltage;
           elseif port == 3
               SIM900.ch3 = voltage;
           elseif port == 4
               SIM900.ch4 = voltage;
           elseif port == 5
               SIM900.ch5 = voltage;
           elseif port == 6
               SIM900.ch6 = voltage;
           elseif port == 7
               SIM900.ch7 = voltage;
           elseif port == 8
               SIM900.ch8 = voltage;
           end
       end

       function voltage = getSIM900PortVoltage(SIM900,port)
            if port == 1
                voltage = SIM900.ch1;
            elseif port == 2
                voltage = SIM900.ch2;
            elseif port == 3
                voltage = SIM900.ch3;
            elseif port == 4
                voltage = SIM900.ch4;
            elseif port == 5
                voltage = SIM900.ch5;
            elseif port == 6
                voltage = SIM900.ch6;
            elseif port == 7
                voltage = SIM900.ch7;
            elseif port == 8
                voltage = SIM900.ch8;
            end
       end
    end
end

