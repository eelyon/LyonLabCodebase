classdef BiasDAC
    %BiasDAC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numChannels {mustBeNumeric}
        identifier
        comPort  
        channelVoltages 
        client
        name
    end
    
    methods
        function sigDAC = BiasDAC(comPort, numChannels,name)
            
            sigDAC.comPort = comPort;
            sigDAC.client = serial_Connect(comPort);
            sigDAC.name = name;
            pause(1);
            sigDAC.numChannels = numChannels;
            sigDAC.identifier = query(sigDAC.client,"*IDN?");
            pause(1);
            restarted = input('Did you restart the DAC? (y/n)',"s");
            if strcmp(restarted,'y')
                sigDACInit(sigDAC);
            end
            for i = 1:numChannels
                sigDAC.channelVoltages(i) = sigDACQueryVoltage(sigDAC,i);
            end

        end
        
        function voltage = sigDACQueryVoltage(sigDAC,channel)
                fprintf(sigDAC.client,['CH ' num2str(channel)]);
                pause(0.1);
                v = query(sigDAC.client,'VOLT?');
                voltage = str2double(query(sigDAC.client,'VOLT?'));
        end

        function sigDACSetVoltage(sigDAC,channels,voltages)
                for i=1:length(channels)
                    fprintf(sigDAC.client,['CH ' num2str(channels(i))])

                    pause(.1);
                    fprintf(sigDAC.client,['VOLT ' num2str(voltages(i))])
                    pause(0.1);
                    %sigDAC.channelVoltages(24) = voltages(i);
                    evalin('base',[sigDAC.name '.channelVoltages( ' num2str(channels(i)) ') = ' num2str(voltages(i)) ';']);
                end
                
        end

        function sigDACSetChannels(sigDAC,voltage)
            % Set all channels of DAC to the same voltage
            numSteps = 100;
            for i = 1:sigDAC.numChannels
                sigDACRampVoltage(sigDAC,i,voltage,numSteps);
            end
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
                delayTime = 0.00004*numSteps*numChans; % set delay until DAC has run ramp
                delay(1.5*delayTime)
                for i=1:numChans
                    evalin('base',[sigDAC.name '.channelVoltages( ' num2str(channels(i)) ') = ' num2str(voltages(i)) ';']);
                end
           else
                str = [numSteps numChans channels voltages];
                convertArray = sprintf('%d ', str);  % num2str pads the array with space, use sprintf instead!
                fprintf(sigDAC.client,['RAMP ' convertArray]);
                delayTime = 0.00004*numSteps*numChans; 
                delay(1.5*delayTime)
                for i=1:numChans
                    evalin('base',[sigDAC.name '.channelVoltages( ' num2str(channels(i)) ') = ' num2str(voltages(i)) ';']);
                end
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

    end
end

