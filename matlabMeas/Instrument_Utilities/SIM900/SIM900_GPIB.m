classdef SIM900_GPIB
    %SIM900_GPIB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        IPAddress
        identifier
        port         {mustBeNumeric}
        client
    end
    
    methods
        function SIM900_GPIB = SIM900_GPIB(port,IPAddress)
            SIM900_GPIB.IPAddress     = IPAddress;
            SIM900_GPIB.port          = port;
            SIM900_GPIB.client        = TCPIP_Connect(IPAddress,port);
            SIM900_GPIB.identifier    = 'SIM900';
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

