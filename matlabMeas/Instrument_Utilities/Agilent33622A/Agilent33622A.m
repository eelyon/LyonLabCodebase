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

            visaAddress = sprintf('TCPIP0::%s::inst0::INSTR', Agilent33622A.IPAddress);
            Agilent33622A.client = visadev(visaAddress);
            
            % if exist('opt','var') 
            %     Agilent33622A.client    = TCPIP_VISA_Connect(IPAddress);                
            % else
            %     Agilent33622A.client    = TCPIP_Connect(IPAddress,port);
            % end
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

        function [] = clearErr33622A(Agilent33622A)
            writeline(Agilent33622A.client, "*CLS");
        end

        function [] = reset33622A(Agilent33622A)
            writeline(Agilent33622A.client, "*RST");
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
            % fprintf(Agilent33622A.client,'TRIG');
            writeline(Agilent33622A.client, "*TRG");
        end

        function [] = set33622ATrigSlope(Agilent33622A,channel,slope)
            validSourceTypes = 'POS,NEG';
            if ~contains(validSourceTypes,slope)
                fprintf([sourceType ' is not a valid trigger slope type. Valid types are:\n'])
                fprintf([validSourceTypes, '\n']);
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

        function [] = set33622ATriggerSource(Agilent33622A,sourceType)
            validSourceTypes = 'IMM,EXT,BUS';
            if ~contains(validSourceTypes,sourceType)
                fprintf([sourceType ' is not a valid trigger source type. Valid types are:\n'])
                fprintf([validSourceTypes, '\n']);
            else
                command = ['TRIG:SOUR ' sourceType];
                fprintf(Agilent33622A.client,command);
            end
        end

        function [] = set33622ATrigger(Agilent33622A,channel,sourceType)
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

        function [] = set33622ABurstNCycles(Agilent33622A,CHAN,NCYCLES)
            % command = ['SOUR',num2str(channel),':BURS:NCYC ' num2str(numCycles)];
            % fprintf(Agilent33622A.client,command);
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":BURS:NCYC " + num2str(round(NCYCLES)));
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

        function [] = set33622AVhigh(Agilent33622A,CHAN,VHIGH)
            % command = ['SOUR',num2str(channel),'VOLT:HIGH ', num2str(highVoltage)];
            % fprintf(Agilent33622A.client,command);
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":VOLT:HIGH " + num2str(VHIGH));
        end

        function [] = set33622AVlow(Agilent33622A,CHAN,VLOW)
            % command = ['SOUR',num2str(channel),'VOLT:LOW ', num2str(lowVoltage)];
            % fprintf(Agilent33622A.client,command);
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":VOLT:LOW "  + num2str(VLOW));
        end

        function [] = set33622AVoltageOffset(Agilent33622A,channel,voltageOffset)
            command = ['SOUR',num2str(channel),':VOLTAGE:OFFS ', num2str(voltageOffset)];
            fprintf(Agilent33622A.client,command);
        end

        %% Configure arbitrary waveform
        function [] = loadArb(Agilent33622A,CHAN,arbFile)
            % Verify file exists
            writeline(Agilent33622A.client, "MMEM:CAT:DATA:ARB? ""INT:\332XX_ARBS\""");
            mmem_resp = readline(Agilent33622A.client);
            if ~contains(upper(mmem_resp), upper(arbFile))
                warning('"%s" not found in non-volatile memory. Response: %s', arbFile, mmem_resp);
            else
                fprintf('Found %s in non-volatile memory.\n', arbFile);
            end
        
            % Load and select
            writeline(Agilent33622A.client, "MMEM:LOAD:DATA" + num2str(CHAN) + " """ + arbFile + """");
            pause(0.5);
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":FUNC:ARB """ + arbFile + """");
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":FUNC ARB");
            fprintf('Channel %d: loaded %s\n', CHAN, arbFile);
        end

        function [] = configAwgArb(Agilent33622A, CHAN, SRATE, VLOW, VHIGH, NBURST, TRIGSRC)
            % configAwgArb  Configure channel settings for triggered burst playback.
            %
            % INPUTS:
            %   Agilent33622A     - instrument handle (.client must be a visadev object)
            %   CHAN    - channel number (1 or 2)
            %   SRATE   - sample rate in Sa/s
            %   VLOW    - low voltage in V
            %   VHIGH   - high voltage in V
            %   NBURST  - burst cycle count (integer >= 1)
            %   TRIGSRC - trigger source ('BUS' or 'EXT')
            
            % Sample rate, filter, load, voltages
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":FUNC:ARB:SRAT " + num2str(SRATE));
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":FUNC:ARB:FILT STEP");
            writeline(Agilent33622A.client, "OUTP" + num2str(CHAN) + ":LOAD INF");
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":VOLT:LOW "  + num2str(VLOW));
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":VOLT:HIGH " + num2str(VHIGH));
        
            % Burst
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":BURS:STAT ON");
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":BURS:MODE TRIG");
            writeline(Agilent33622A.client, "SOUR" + num2str(CHAN) + ":BURS:NCYC " + num2str(round(NBURST)));
        
            % Trigger
            writeline(Agilent33622A.client, "TRIG" + num2str(CHAN) + ":SOUR " + TRIGSRC);
            writeline(Agilent33622A.client, "TRIG" + num2str(CHAN) + ":SLOP POS");
        
            if strcmp(TRIGSRC, "BUS")
                writeline(Agilent33622A.client, "OUTP:TRIG:SLOP POS");
                writeline(Agilent33622A.client, "OUTP:TRIG:SOUR CH1");
                writeline(Agilent33622A.client, "OUTP:TRIG ON");
            else
                writeline(Agilent33622A.client, "OUTP:TRIG OFF");
            end
        
            % Output on
            writeline(Agilent33622A.client, "OUTP" + num2str(CHAN) + " ON");
        
            % Error check
            writeline(Agilent33622A.client, "SYST:ERR?");
            err = readline(Agilent33622A.client);
            if contains(err, "No error")
                fprintf('Channel %d configured: SRATE=%.0f Sa/s, VLOW=%.1fV, VHIGH=%.1fV, NBURST=%d, TRIG=%s\n', ...
                        CHAN, SRATE, VLOW, VHIGH, NBURST, TRIGSRC);
            else
                warning('Instrument error on channel %d: %s', CHAN, err);
            end
        end

        %% QUERYING %%
        function [] = queryErr33622A(Agilent33622A)
            writeline(Agilent33622A.client, "SYST:ERR?");
            err = readline(Agilent33622A.client);
            if contains(err, "No error")
                fprintf('No error: %s', err);
            else
                warning('Instrument Error: %s', err);
            end
        end

        function queryOPC33622A(Agilent33622A, varargin)
            % waitAWG  Block until AWG has completed its current operation.
            %
            % INPUTS:
            %   AWG     - instrument handle (.client must be a visadev object)
            %   timeout - (optional) timeout in seconds, default = current device timeout
            p = inputParser;
            p.addOptional('timeout', Agilent33622A.client.Timeout, @(x) isnumeric(x) && x > 0);
            p.parse(varargin{:});
            timeout = p.Results.timeout;
        
            prev_timeout = Agilent33622A.client.Timeout;
            Agilent33622A.client.Timeout = timeout;
        
            writeline(Agilent33622A.client, "*OPC?");
            opc = readline(Agilent33622A.client);
        
            Agilent33622A.client.Timeout = prev_timeout;   % restore original timeout
        
            if strcmp(strtrim(opc), "1")
                fprintf('AWG operation complete.\n');
            else
                warning('Unexpected OPC response: %s', opc);
            end
        end

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

