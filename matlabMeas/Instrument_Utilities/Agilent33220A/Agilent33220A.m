classdef Agilent33220A
    %AGILENT33220A Summary of this class goes here
    %   Detailed explanation goes here

    properties
        IPAddress
        port         {mustBeNumeric}
        client
        identifier
    end

    methods
        function Agilent33220A = Agilent33220A(port,IPAddress,opt)
            Agilent33220A.IPAddress     = IPAddress;
            Agilent33220A.port          = port;
            
            if exist('opt','var') 
                Agilent33220A.client    = TCPIP_VISA_Connect(IPAddress);                
            else
                Agilent33220A.client    = TCPIP_Connect(IPAddress,port);
            end
            Agilent33220A.identifier    = '33220A';
        end

        function setAgilent33220APresetConfig(Agilent33220A,experimentType)
            % Function to be used to create presets for the Agilent33220A.
            % This way one can program the 33220A for many different
            % configurations with a single function. 
            switch experimentType
                case 'Filament'
                    amp_high = 3;
                    amp_low = 0;
                    period = 30e-3;
                    
                    set33220FunctionType(Agilent33220A,'PULS');
                    set33220VoltageHigh(Agilent33220A, amp_high);
                    set33220VoltageLow(Agilent33220A, amp_low);
                    set33220PulsePeriod(Agilent33220A,period);
                    set33220PulseDutyCycle(Agilent33220A,60);
                    set33220PulseRiseTime(Agilent33220A,5e-9);
                    
                    set33220OutputLoad(Agilent33220A,'INF');
                    set33220BurstMode(Agilent33220A,'TRIG');
                    set33220NumBurstCycles(Agilent33220A,1);
                    set33220TriggerSource(Agilent33220A,'BUS');
                    set33220TrigSlope(Agilent33220A,'POS');
                    set33220BurstStateOn(Agilent33220A,1);
                    set33220Output(Agilent33220A,0);
                case 'Compensate'
                    amplitude = 300e-3;
                    frequency = 102e3;
                    voltType = 'VPP';
                    voltageOffset = 0;
                    
                    set33220FunctionType(Agilent33220A,'SIN');
                    set33220VoltageOffset(Agilent33220A,voltageOffset)
                    set33220Frequency(Agilent33220A,frequency);
                    set33220Phase(Agilent33220A,0);
                    set33220Amplitude(Agilent33220A,amplitude,voltType);
                    set33220OutputLoad(Agilent33220A, 'INF');
                    set33220Output(Agilent33220A,0);  % start with output OFF
                    set33220BurstStateOn(Agilent33220A,0)  % turn burst state off
                case 'Door'
                    % initial settings
                    amp_high = 0;
                    amp_low  = -1;    
                    period   = 200e-3;
                    width    = 100e-3;
                    
                    set33220FunctionType(Agilent33220A,'PULS');
                    set33220VoltageHigh(Agilent33220A,amp_high);
                    set33220VoltageLow(Agilent33220A,amp_low);
                    set33220PulsePeriod(Agilent33220A,period);
                    set33220PulseWidth(Agilent33220A,width);
                    
                    set33220OutputLoad(Agilent33220A, 'INF');
                    set33220BurstMode(Agilent33220A,'TRIG');
                    set33220NumBurstCycles(Agilent33220A,1);
                    set33220TriggerSource(Agilent33220A,'BUS');
                    set33220TrigSlope(Agilent33220A,'POS');
                    set33220BurstStateOn(Agilent33220A,1);
                    set33220Output(Agilent33220A,0);  % start with output OFF
                otherwise
                    disp(['Your experiment type preset ', experimentType, ' is invald!']);
            end
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

        function [] = set33220Output(Agilent33220A,OnOff)
            if OnOff
                cmdStr = 'ON';
            else
                cmdStr = 'OFF';
            end
            command = ['OUTP ' cmdStr];
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220OutputLoad(Agilent33220A, Ohms)
            if isletter(Ohms) == 1
                command = ['OUTP:LOAD ', Ohms];
            else
                command = ['OUTP:LOAD ', num2str(Ohms)];
            end
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220InvertOutput(Agilent33220A,OnOff)
            if OnOff
                cmdStr = 'INV';
            else
                cmdStr = 'NORM';
            end
            command = ['OUTP:POL ' cmdStr];
            fprintf(Agilent33220A.client,command);
        end

        %% SET FREQUENCY/PERIOD %%
        function [] = set33220Frequency(Agilent33220A,frequencyInHz)
            command = ['FREQ ' num2str(frequencyInHz)];
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

        function [] = set33220PulseDutyCycle(Agilent33220A,dutyCycle)
            command = ['FUNC:PULS:DCYC ' num2str(dutyCycle)];
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220PulseRiseTime(Agilent33220A,riseTime)
            command = ['PULS:TRAN ' num2str(riseTime)];
            fprintf(Agilent33220A.client,command);
        end
        
        %% SET TRIGGER %%
        
        function send33220Trigger(Agilent33220A)
            fprintf(Agilent33220A.client,'TRIG');
        end

        function [] = set33220TrigSlope(Agilent33220A,slope)
            validSourceTypes = 'POS,NEG';
            if ~contains(validSourceTypes,slope)
                fprintf([sourceType ' is not a valid trigger slope type. Valid types are:\n'])
                fprintf([validSourceTypes, '\n']);
            else
                command = ['TRIG:SLOP ' slope];
                fprintf(Agilent33220A.client,command);
            end
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

        function [] = set33220Trigger(Agilent33220A,sourceType)
            validSourceTypes = 'IMM,EXT,BUS';
            if ~contains(validSourceTypes,sourceType)
                fprintf([sourceType ' is not a valid trigger source type. Valid types are:\n'])
                fprintf([validSourceTypes, '\n']);
            else
                command = ['TRIG:SOUR ' sourceType '; *TRG'];
                fprintf(Agilent33220A.client,command);
            end
        end

        %% SET BURST %%

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

        function [] = set33220NumBurstCycles(Agilent33220A,numCycles)
            command = ['BURS:NCYC ' num2str(numCycles)];
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220BurstStateOn(Agilent33220A,onOrOff)
            if onOrOff
                command = 'BURS:STAT ON';
            else
                command = 'BURS:STAT OFF';
            end

            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220OutputOnOff(Agilent33220A,onOrOff)
            if onOrOff
                command = 'OUTP ON';
            else
                command = 'OUTP OFF';
            end

            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220BurstPhase(Agilent33220A,phaseInDegrees)
            command = ['BURS:PHAS ' num2str(phaseInDegrees)];
            fprintf(Agilent33220A.client,command);
        end

        function [] = set33220Phase(Agilent33220A,phaseInDegrees)
            % NOTE: Phase Precision in .001 degrees!
            command = ['PHAS ' num2str(phaseInDegrees)];
            fprintf(Agilent33220A.client,command);
        end


        %% SET VOLTAGES %%
        function [] = set33220Amplitude(Agilent33220A,amplitude,voltType)
            validVoltTypes = 'VPP,VRMS,DBM';
            if amplitude < .0075
                disp('ERROR minimum Agilent Voltage = 7mVRMS');
                return;
            end
            if ~contains(validVoltTypes,voltType)
                fprintf([voltType ' is not a valid voltage source type. Valid types are:\n'])
                fprintf([validVoltTypes, '\n']);
            else 
                command = ['VOLT:UNIT', ' ', voltType];
                command2 = ['VOLT ', num2str(amplitude), ' ', voltType];
            end
            fprintf(Agilent33220A.client,command);
            fprintf(Agilent33220A.client,command2);
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
        
        function [] = set33220VoltageHighAndLow(Agilent33220A,lowVoltage,highVoltage)
            % checks that low and high voltage are the correct way around
            volts = [lowVoltage,highVoltage];
            if lowVoltage > highVoltage
                lowVoltage = volts(2);
                highVoltage = volts(1);
            else
            end
            set33220VoltageLow(Agilent33220A,lowVoltage);
            set33220VoltageHigh(Agilent33220A,highVoltage);
        end
        
        %% QUERYING %%

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

        function [amplitude] = query33220Amplitude(Agilent33220A)
            amplitude = str2double(query(Agilent33220A.client,'VOLT?'));
        end

        function [offset] = query33220VoltageOffset(Agilent33220A)
            offset = str2double(query(Agilent33220A.client,'VOLT:OFFS?'));
        end
        
        function [phase] = query33220Phase(Agilent33220A)
            phase = str2double(query(Agilent33220A.client,'PHAS?'));
        end

        function [phase] = query33220Frequency(Agilent33220A)
            phase = str2double(query(Agilent33220A.client,'FREQ?'));
        end

        function [output] = query33220OutputOnOff(Agilent33220A)
            output = str2double(query(Agilent33220A.client,'OUTP?'));
        end        
    end
end

