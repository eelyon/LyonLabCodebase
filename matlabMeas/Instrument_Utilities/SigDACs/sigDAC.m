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

        function sigDACRampVoltage(sigDAC,channels,voltages,numSteps)
            numChans = length(channels);
            str = [numSteps numChans channels voltages];
            convertArray = sprintf('%d ', str);  % num2str pads the array with space, use sprintf instead!
            fprintf(sigDAC.client,['RAMP ' convertArray]);
        end

        function sigDACInit(sigDAC)
                fprintf(sigDAC.client,'INIT');
        end

        function sigDACDoor(sigDAC, vPort, TauE, TauC)
            DCMap;
            fprintf(sigDAC.client,['DOOR ' num2str([2,DoorEPort,DoorCPort, ...
                             4,vPort,2,0,0,TauE,TauC])]);
        end

        function sigDAC = disconnect_sigDAC(comPort)
            sigDAC.comPort = comPort;
            sigDAC.client = serial_Disconnect(comPort);
        end

    end
end

