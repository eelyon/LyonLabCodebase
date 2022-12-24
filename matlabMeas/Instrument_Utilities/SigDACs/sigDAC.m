classdef sigDAC
    %SIGDAC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numChannels {mustBeNumeric}
        identifier
        comPort  
        channelVoltages 
        client
    end
    
    methods
        function sigDAC = sigDAC(comPort, numChannels)
            
            sigDAC.comPort = comPort;
            sigDAC.client = serial_Connect(comPort);

            sigDAC.numChannels = numChannels;
            sigDAC.identifier = query(sigDAC.client,"*IDN?");
            pause(1);
            for i = 1:numChannels
                sigDAC.channelVoltages(i) = sigDACQueryVoltage(sigDAC,i);
            end

        end
        
        function voltage = sigDACQueryVoltage(sigDAC,channel)
                fprintf(sigDAC.client,['CH ' num2str(channel)]);
                voltage = str2double(query(sigDAC.client,'VOLT?'));
        end

        function sigDACSetVoltage(sigDAC,channel,voltage)
                fprintf(sigDAC.client,['CH ' num2str(channel)]);
                fprintf(sigDAC.client,['VOLT ' num2str(voltage)]);
        end

        function  voltageArr = sigDACGetConfig(sigDAC)
            for channel = 1:sigDAC.numChannels
                sigDAC.channelVoltages(channel) = sigDACQueryVoltage(sigDAC,channel);
            end
            voltageArr = sigDAC.channelVoltages;
        end

    end
end

