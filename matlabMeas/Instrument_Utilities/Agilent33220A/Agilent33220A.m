classdef Agilent33220A
    %AGILENT33220A Summary of this class goes here
    %   Detailed explanation goes here

    properties
        IPAddress
        port         {mustBeNumeric}
        client
    end

    methods
        function Agilent33220A = Agilent33220A(port,IPAddress)
            Agilent33220A.IPAddress     = IPAddress;
            Agilent33220A.port          = port;
            Agilent33220A.client        = TCPIP_Connect(IPAddress,port);
        end

        function setAgilent33220APresetConfig(experimentType)
            % Function to be used to create presets for the Agilent33220A.
            % This way one can program the 33220A for many different
            % configurations with a single function. 
            switch experimentType
                case 'LED'
                case 'Filament'
                otherwise
                    disp(['Your experiment type preset ', experimentType, ' is invald!']);
            end

        end

        function send33220Trigger(Agilent33220A)
            fprintf(Agilent33220A.client,'TRIG');
        end
        
        function [] = set33220BurstMode(Agilent33220A,burstType)
            validTypes = 'TRIG,GAT';
            if ~contains(validTypes,burstType)
                fprintf('Invalid burst type, valid types are:\n');
                fprintf(validTypes);
            else
                command = ['BURS:MODE ' burstType];
                fprintf(Agilent33220A.client,command);
            end
        end

        function [] = set33220BurstStateOn(Agilent33220A,onOrOff)
            if onOrOff
                command = 'BURS:STAT ON';
            else
                command = 'BURS:STAT OFF';
            end

            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220FunctionType(Agilent33220A,type)

            validTypes = 'SIN,SQU,RAMP,PULS,NOIS,DC,USER';
            if ~contains(validTypes,type)
                fprintf('Valid function types for the 33220 are:\n');
                fprintf([validTypes '\n'])
            else
                command = ['FUNC ', type];
                fprintf(Agilent33220A.client,command);
            end

        end

        function [] = set33220NumBurstCycles(Agilent33220A,numCycles)
            command = ['BURS:NCYC ' num2str(numCycles)];
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220Output(Agilent33220A,OnOff)
            if OnOff
                cmdStr = 'ON';
            else
                cmdStr = 'OFF';
            end
            command = ['OUTP ' cmdStr];
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220PulsePeriod(Agilent33220A,periodInSeconds)
            command = ['PULS:PER ' num2str(periodInSeconds)];
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220PulseWidth(Agilent33220A, widthInSeconds)
            command = ['FUNC:PULS:WIDT ', num2str(widthInSeconds)];
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220TriggerOutput(Agilent33220A,onOrOff)
            if onOrOff
                command = 'OUTP:TRIG ON';
            else
                command = 'OUTP:TRIG OFF';
            end
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220TriggerSource(Agilent33220A,sourceType)
            validSourceTypes = 'IMM,EXT,BUS';
            if ~contains(validSourceTypes,sourceType)
                fprintf([sourceType ' is not a valid trigger source type. Valid types are:\n'])
                fprintf([validSourceTypes, '\n']);
            else
                command = ['TRIG:SOUR ' sourceType];
                fprintf(Agilent33220A.client,command);
            end
        end

        function [] = set33220VoltageHigh(Agilent33220A,highVoltage)
            command = ['VOLT:HIGH ', num2str(highVoltage)];
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220VoltageLow(Agilent33220A, lowVoltage)
            command = ['VOLT:LOW ', num2str(lowVoltage)];
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220VoltageOffset(Agilent33220A,voltageOffset)
            command = ['VOLTAGE:OFFS ', num2str(voltageOffset)];
            fprintf(Agilent33220A.client,command);
        end

        function [functionType] = query33220FunctionType(Agilent33220A)
            functionType = query(Agilent33220A.client,'FUNC?');
        end

        function [isOn] = query33220Output(Agilent33220A)
            isOn = query(Agilent33220A.client,'OUTP?');
        end

        function [period] = query33220PulsePeriod(Agilent33220A)
            period = query(Agilent33220A.client,'PULS:PER?');
        end

        function [pulseWidth] = query33220PulseWidth(Agilent33220A)
            pulseWidth = query(Agilent33220A.client,'FUNC:PULS:WIDT?');
        end

        function [trigOutp] = query33220TriggerOutput(Agilent33220A)
            trigOutp = query(Agilent33220A.client,'OUTP:TRIG?');
        end

        function [trigType] = query33220TriggerSourceType(Agilent33220A)
            trigType = query(Agilent33220A.client,'TRIG:SOUR?');
        end

        function [voltage] = query33220VoltageHigh(Agilent33220A)
            voltage = query(Agilent33220A.client,'VOLT:HIGH?');
        end

        function [voltLow] = query33220VoltageLow(Agilent33220A)
            voltLow = query(Agilent33220A.client,'VOLT:LOW?');
        end

        function [offset] = query33220VoltageOffset(Agilent33220A)
            offset = query(Agilent33220A.client,'VOLT:OFFS?');
        end

    end
end

