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
            pause(1);
            sigDAC.numChannels = numChannels;
            sigDAC.identifier = query(sigDAC.client,"*IDN?");
            pause(1);
            for i = 1:numChannels
                sigDAC.channelVoltages(i) = sigDACQueryVoltage(sigDAC,i);
            end

        end
        
        function voltage = sigDACQueryVoltage(sigDAC,channel)
                fprintf(sigDAC.client,['CH ' num2str(channel)]);
                pause(0.1);
                voltage = str2double(query(sigDAC.client,'VOLT?'));
        end

        function sigDACSetVoltage(sigDAC,channel,voltage)
                fprintf(sigDAC.client,['CH ' num2str(channel)])
                pause(.1);
                fprintf(sigDAC.client,['VOLT ' num2str(voltage)])
        end

        function  voltageArr = sigDACGetConfig(sigDAC)
            for channel = 1:sigDAC.numChannels
                sigDAC.channelVoltages(channel) = sigDACQueryVoltage(sigDAC,channel);
            end
            voltageArr = sigDAC.channelVoltages;
        end

        function sigDACRampVoltage(sigDAC,channels,voltages,numSteps)
            calibrate = 0;
            numChans = length(channels);
            numVolts = length(voltages);
    
            if calibrate
                Folder = 'TiffanyMeasurementFunctions\IDC\CalibrateDac\AP24\';
                calvoltList = zeros(1,numel(voltages));
                ctr = 1;
            
                for i=1:length(voltages)
                    channel = channels(i);
                    load([Folder 'CH' num2str(channel) '.mat']);
                    value = voltages(i);
                    vRange = -9.8:0.7:9.8;
                    new = interp1(vRange, vRange*m+b, value);
                    newVolt = (value-new)+value;
                    convert = num2str(newVolt,'%.3f');
                    convertback = str2double(convert);
                    calvoltList(ctr) = convertback;
                    ctr = ctr+1;
                end
        
                str = [numSteps numChans channels calvoltList];
                convertArray = sprintf('%d ', str);
                fprintf(sigDAC.client,['RAMP ' convertArray]);
           else
                str = [numSteps numChans channels voltages];
                convertArray = sprintf('%d ', str);  % num2str pads the array with space, use sprintf instead!
                fprintf(sigDAC.client,['RAMP ' convertArray]);
           end
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

