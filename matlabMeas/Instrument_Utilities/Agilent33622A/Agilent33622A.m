classdef Agilent33622A
    properties
        IPAddress
        port         {mustBeNumeric}
        client
        identifier
    end

    methods
        function Agilent33622A = Agilent33622A(port,IPAddress,opt)
            Agilent33622A.IPAddress     = IPAddress;
            Agilent33622A.port          = port;
            
            if exist('opt','var') 
                Agilent33622A.client    = TCPIP_VISA_Connect(IPAddress);                
            else
                Agilent33622A.client    = TCPIP_Connect(IPAddress,port);
            end
            Agilent33622A.identifier    = '33622A';
        end

        function setAgilent33622APresetConfig(experimentType,Agilent33622A,channel)
            % Function to be used to create presets for the Agilent33622A.
            % This way one can program the 333622A for many different
            % configurations with a single function. 
            switch experimentType
                case 'CharacterizeHEMT'
                    amplitude = 2e-3; 
                    frequency = 100;
                    voltType = 'VPP';
                    voltageOffset = 0;
                    
                    set33622AFunctionType(Agilent33622A,channel,'SIN');
                    set33622AVoltageOffset(Agilent33622A,channel,voltageOffset)
                    set33622AFrequency(Agilent33622A,channel,frequency);
                    set33622APhase(Agilent33622A,channel,0);
                    set33622AAmplitude(Agilent33622A,channel,amplitude,voltType);
                    set33622AOutputLoad(Agilent33622A,channel,'INF');
                    set33622AFrequencyCoupling(Agilent33622A,channel,1);
                    set33622AOutput(Agilent33622A,channel,0);  % start with output OFF
                case 'Compensation'
                    amplitude = 300e-3; 
                    frequency = 102e3;
                    voltType = 'VPP';
                    voltageOffset = 0;
                    
                    set33622AFunctionType(Agilent33622A,channel,'SIN');
                    set33622AVoltageOffset(Agilent33622A,channel,voltageOffset)
                    set33622AFrequency(Agilent33622A,channel,frequency);
                    set33622APhase(Agilent33622A,channel,0);
                    set33622AAmplitude(Agilent33622A,channel,amplitude,voltType);
                    set33622AOutputLoad(Agilent33622A,channel,'INF');
                    set33622AFrequencyCoupling(Agilent33622A,channel,1);
                    set33622AOutput(Agilent33622A,channel,0);  % start with output OFF
                otherwise
                    disp(['Your experiment type preset ', experimentType, ' is invald!']);
            end

        end

        function [] = set33622AFunctionType(Agilent33622A,channel,type)

            validTypes = 'SIN,SQU,RAMP,PULS,NOIS,DC,USER';
            if ~contains(validTypes,type)
                fprintf('Valid function types for the 33622A are:\n');
                fprintf([validTypes '\n'])
            else
                command = ['SOUR',num2str(channel),':FUNC ', type];
                fprintf(Agilent33622A.client,command);
            end

        end

        function [] = set33622AOutput(Agilent33622A,channel, OnOff)
            if OnOff
                cmdStr = ' ON';
            else
                cmdStr = ' OFF';
            end
            fprintf(Agilent33622A.client, ['OUTP', num2str(channel), cmdStr]);
        end

        function [] = set33622AOutputLoad(Agilent33622A, channel, Ohms)
            if isletter(Ohms) == 1
                command = ['OUTP', num2str(channel),':LOAD ', Ohms];
            else
                command = ['OUTP', num2str(channel),':LOAD ', num2str(Ohms)];
            end
            fprintf(Agilent33622A.client,command);
        end

        %% SET FREQUENCY/PERIOD %%
        function [] = set33622AFrequency(Agilent33622A,channel,frequencyInHz)
            command = ['SOUR',num2str(channel),':FREQ ' num2str(frequencyInHz)];
            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622APulsePeriod(Agilent33622A,channel,periodInSeconds)
            command = ['SOUR',num2str(channel),':PULS:PER ' num2str(periodInSeconds)];
            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622APulseWidth(Agilent33622A, channel,widthInSeconds)
            command = ['SOUR',num2str(channel),':FUNC:PULS:WIDT ', num2str(widthInSeconds)];
            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622APulseDutyCycle(Agilent33622A,channel,dutyCycle)
            command = ['SOUR',num2str(channel),':FUNC:PULS:DCYC ' num2str(dutyCycle)];
            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622APulseRiseTime(Agilent33622A,channel,riseTime)
            command = ['SOUR',num2str(channel),':PULS:TRAN ' num2str(riseTime)];
            fprintf(Agilent33622A.client,command);
        end
        
        function [] = set33622AFrequencyCoupling(Agilent33622A,channel,onOrOff)
            command = ['SOUR',num2str(channel),':FREQ:COUP ',num2str(onOrOff)];
            fprintf(Agilent33622A.client,command);
        end


        %% SET TRIGGER %%
        
        function send33622ATrigger(Agilent33622A)
            fprintf(Agilent33622A.client,'TRIG');
        end

        function send33622ATriggerBUS(Agilent33622A)
            fprintf(Agilent33622A.client,'*TRG');
        end

        function [] = set33622ATrigSlope(Agilent33622A,channel,slope)
            validSourceTypes = 'POS,NEG';
            if ~contains(validSourceTypes,slope)
                fprintf([sourceType ' is not a valid trigger slope type. Valid types are:\n'])
                fprintf([validSourceTypes, '\n'])
            else
                command = ['TRIG',num2str(channel),':SLOP ' slope];
                fprintf(Agilent33622A.client,command);
            end
        end

        function [] = set33622ATriggerOutput(Agilent33622A,onOrOff)
            if onOrOff
                command = 'OUTP:TRIG ON';
            else
                command = 'OUTP:TRIG OFF';
            end
            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622ATriggerSource(Agilent33622A,channel,sourceType)
            validSourceTypes = 'IMM,EXT,BUS';
            if ~contains(validSourceTypes,sourceType)
                fprintf([sourceType ' is not a valid trigger source type. Valid types are:\n'])
                fprintf([validSourceTypes, '\n']);
            else
                command = ['TRIG',num2str(channel),':SOUR ' sourceType '; *TRG'];
                fprintf(Agilent33622A.client,command);
            end
        end

        %% SET BURST %%

        function [] = set33622ABurstMode(Agilent33622A,channel,burstType)
            validTypes = 'TRIG,GAT';
            if ~contains(validTypes,burstType)
                fprintf('Invalid burst type, valid types are:\n');
                fprintf(validTypes);
            else
                command = ['SOUR',num2str(channel),':BURS:MODE ' burstType];
                fprintf(Agilent33622A.client,command);
            end
        end

        function [] = set33622ANumBurstCycles(Agilent33622A,channel,numCycles)
            command = ['SOUR',num2str(channel),':BURS:NCYC ' num2str(numCycles)];
            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622ABurstStateOn(Agilent33622A,onOrOff)
            if onOrOff
                command = ['SOUR',num2str(channel),':BURS:STAT ON'];
            else
                command = ['SOUR',num2str(channel),':BURS:STAT OFF'];
            end

            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622AOutputOnOff(Agilent33622A,channel,onOrOff)
            if onOrOff
                command = strcat("OUTP",num2str(channel)," ON");
            else
                command = strcat("OUTP",num2str(channel)," OFF");
            end

            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622ABurstPhase(Agilent33622A,phaseInDegrees)
            command = ['SOUR',num2str(channel),':BURS:PHAS ' num2str(phaseInDegrees)];
            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622APhase(Agilent33622A,channel,phaseInDegrees)
            % NOTE: Phase Precision in .001 degrees!
            command = ['SOUR',num2str(channel),':PHAS ' , num2str(phaseInDegrees)];
            fprintf(Agilent33622A.client,command);
        end


        %% SET VOLTAGES %%
        function [] = set33622AAmplitude(Agilent33622A,channel,amplitude,voltType)
            validVoltTypes = 'VPP,VRMS,DBM';
            preCommand = strcat('SOUR',num2str(channel),':');
            if amplitude < .001 && strcmp(validVoltTypes,'VPP')
                disp('ERROR minimum Agilent Voltage = 1mVpp');
                return;
            elseif amplitude < .000707
                disp('ERROR minimum Agilent Voltage = .707mVrms');
                return;
            end
            if ~contains(validVoltTypes,voltType)
                fprintf([voltType ' is not a valid voltage source type. Valid types are:\n'])
                fprintf([validVoltTypes, '\n']);
            else 
                command = [preCommand, 'VOLT:UNIT', ' ', voltType];
                command2 = [preCommand, 'VOLT ', num2str(amplitude), ' ', voltType];
            end
            fprintf(Agilent33622A.client,command);
            fprintf(Agilent33622A.client,command2);
        end

        function [] = set33622AVoltageHigh(Agilent33622A,channel,highVoltage)
            command = ['SOUR',num2str(channel),':VOLT:HIGH ', num2str(highVoltage)];
            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622AVoltageLow(Agilent33622A,channel,lowVoltage)
            command = ['SOUR',num2str(channel),':VOLT:LOW ', num2str(lowVoltage)];
            fprintf(Agilent33622A.client,command);
        end

        function [] = set33622AVoltageOffset(Agilent33622A,channel,voltageOffset)
            command = ['SOUR',num2str(channel),':VOLTAGE:OFFS ', num2str(voltageOffset)];
            fprintf(Agilent33622A.client,command);
        end
        
        function [] = set33622ADoorVoltageLowAndHigh(Agilent33622A,channel,lowVoltage,highVoltage)
            % checks that low and high voltage are the correct way around
            volts = [lowVoltage,highVoltage];
            if lowVoltage > highVoltage
                lowVoltage = volts(2);
                highVoltage = volts(1);
            else
            end
            set33622AVoltageLow(Agilent33622A,channel,lowVoltage);
            set33622AVoltageHigh(Agilent33622A,channel,highVoltage);
        end
        
        %% QUERYING %%

        function [functionType] = query33622AFunctionType(Agilent33622A,channel)
            command = strcat('SOUR',num2str(channel),'FUNC?');
            functionType = query(Agilent33622A.client,command);
        end

        function [isOn] = query33622AOutput(Agilent33622A,channel)
            command = strcat('OUTP',num2str(channel),'?');
            isOn = query(Agilent33622A.client,command);
        end

        function [period] = query33622APulsePeriod(Agilent33622A,channel)
            command = strcat('SOUR',num2str(channel),'FUNC:PULS:PER?');
            period = query(Agilent33622A.client,command);
        end

        function [pulseWidth] = query33622APulseWidth(Agilent33622A,channel)
            command = strcat('SOUR',num2str(channel),'FUNC:PULS:WIDT?');
            pulseWidth = query(Agilent33622A.client,command);
        end

        function [trigOutp] = query33622ATriggerOutput(Agilent33622A)
            trigOutp = query(Agilent33622A.client,'OUTP:TRIG?');
        end

        function [trigType] = query33622ATriggerSourceType(Agilent33622A)
            trigType = query(Agilent33622A.client,'TRIG:SOUR?');
        end

        function [voltage] = query33622AVoltageHigh(Agilent33622A,channel)
            command = strcat('SOUR',num2str(channel), 'VOLT:HIGH?');
            voltage = query(Agilent33622A.client,command);
        end

        function [voltLow] = query33622AVoltageLow(Agilent33622A,channel)
            command = strcat('SOUR',num2str(channel),':VOLT:LOW?');
            voltLow = query(Agilent33622A.client,command);
        end

        function [amplitude] = query333622Amplitude(Agilent33622A,channel)
            command = strcat('SOUR',num2str(channel),':VOLT?');
            amplitude = str2double(query(Agilent33622A.client,command));
        end

        function [offset] = query33622AVoltageOffset(Agilent33622A,channel)
            command = strcat('SOUR',num2str(channel),':VOLT:OFFS?');
            offset = str2double(query(Agilent33622A.client,command));
        end
        
        function [phase] = query33622APhase(Agilent33622A,channel)
            command = strcat('SOUR',num2str(channel),':PHAS?');
            phase = str2double(query(Agilent33622A.client,command));
        end

        function [phase] = query33622AFrequency(Agilent33622A,channel)
            command = strcat('SOUR',num2str(channel),':FREQ?');
            phase = str2double(query(Agilent33622A.client,command));
        end

        function [output] = query33622AOutputOnOff(Agilent33622A,channel)
            command = strcat('OUTP',num2str(channel),'?');
            output = str2double(query(Agilent33622A.client,command));
        end
    end
end

