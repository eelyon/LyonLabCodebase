classdef QDAC
    %   QDAC class
    %   Contains functions for initiating the Quantum Machine DAC II compact 
    %   and setting voltages
    
    properties
        comPort 
        IPAddress
        numChannels {mustBeNumeric}
        channelVoltages
        client
        name
        identifier
    end
    
    methods
        % function QDAC = QDAC(comPort, numChannels, name) % for initial Serial Connection
        %     QDAC.comPort   = comPort;
        %     QDAC.client    = serialport(comPort,921600); % Baud rate needs to be this value or you can't communicate
        %     QDAC.name      = name;
        %     pause(1)
        %     QDAC.numChannels = numChannels;
        %     QDAC.identifier = query(QDAC.client,"*IDN?");
        %     pause(1)
        % end

        function QDAC = QDAC(IPAddress, numChannels, name)
            QDAC.IPAddress     = IPAddress;
            QDAC.client        = TCPIP_Connect(IPAddress,5025); % port needs to be 5025 or else can't communicate
            QDAC.name          = name;
            pause(1)
            QDAC.numChannels = numChannels;
            QDAC.identifier = query(QDAC.client,"*IDN?");
            pause(1)
            for i = 1:numChannels
                QDAC.channelVoltages(i) =  str2double(queryQDACVoltage(QDAC,i));
            end
        end
        
        %% Query Error and System related

        function querySTB = queryQDACSTB(QDAC)
            querySTB = query(QDAC.client,'*STB?');
        end

        function queryError = queryQDACError(QDAC)
            queryError = query(QDAC.client,'SYST:ERR:ALL?');
        end

        function [] = qDACClearError(QDAC) % clears status and error queue
            queryQDACError(QDAC); % need to do this once or else red light will continue blinking
            fprintf(QDAC.client,'*CLS');
        end

        function [] = qDACReset(QDAC) 
            fprintf(QDAC.client,'*RST');
        end

        function getIPAddress = qDACIPAddress(QDAC)
            getIPAddress = query(QDAC.client,'SYST:COMM:LAN:IPAD?');
        end
        
        %% Query Functions
        function range = queryQDACRange(QDAC,channels)
            command = sprintf('SOUR:RANG? (@%s)', strjoin(string(channels), ','));
            range = query(QDAC.client,command);
        end 

        function lowPassFreq = queryQDACLowPassFreq(QDAC,channels)
            command = sprintf('SOUR:FILT? (@%s)', strjoin(string(channels), ','));
            lowPassFreq = query(QDAC.client,command);
        end 

        function DCGeneratorMode = queryQDACDCGenerator(QDAC,channels)
            command = sprintf('SOUR:DC:MODE? (@%s)', strjoin(string(channels), ','));
            DCGeneratorMode = query(QDAC.client,command);
        end 

        function voltage = queryQDACVoltage(QDAC,channels)
            setQDACDCGeneratorMode(QDAC,channels,'FIX')   
            command = sprintf('SOUR:VOLT? (@%s)', strjoin(string(channels), ','));
            voltage = query(QDAC.client,command);
        end 
        
        function sweepStartVoltage = queryQDACSweepStartVoltage(QDAC,channels)
            setQDACDCGeneratorMode(QDAC,channels,'SWE')   
            command = sprintf('SOUR:SWE:STAR? (@%s)', strjoin(string(channels), ','));
            sweepStartVoltage = query(QDAC.client,command);
        end 

        function sweepStopVoltage = queryQDACSweepStopVoltage(QDAC,channels)       
            setQDACDCGeneratorMode(QDAC,channels,'SWE')   
            command = sprintf('SOUR:SWE:STOP? (@%s)', strjoin(string(channels), ','));
            sweepStopVoltage = query(QDAC.client,command);
        end 

        function sweepStopVoltage = queryQDACSweepMode(QDAC,channels)       
            setQDACDCGeneratorMode(QDAC,channels,'SWE')   
            command = sprintf('SOUR:SWE:GEN? (@%s)', strjoin(string(channels), ','));
            sweepStopVoltage = query(QDAC.client,command);
        end 

        %% Set Functions
        function [] = setQDACRange(QDAC,channels,lowORHigh)
            if lowORHigh == 1
                command = sprintf('SOUR:VOLT:RANG LOW,(@%s)', strjoin(string(channels), ',')); % +/- 2V range
                fprintf(QDAC.client,command);
            else
                command = sprintf('SOUR:VOLT:RANG HIGH,(@%s)', strjoin(string(channels), ',')); % +/- 10V (default)
                fprintf(QDAC.client,command);
            end
        end  

        function [] = setQDACLowPass(QDAC,channels,type)
            validTypes = 'DC,MED,HIGH';
            % DC cutoff ~ 10Hz. Stable, precise
            % MED cutoff ~10kHz. DC, slow ramps
            % HIGH cutoff ~100kHz. Fast ramps (default)
            
            if ~contains(validTypes,type)
                fprintf('Valid function types for the QDAC-II compact are:\n');
                fprintf([validTypes '\n'])
            else
                channelStr = strjoin(string(channels), ',');
                command = sprintf('SOUR:FILT %s,(@%s)',type,channelStr);
                fprintf(QDAC.client,command);
            end
        end 
        
        function [] = setQDACDCGeneratorMode(QDAC,channels,type)
            validTypes = 'FIX,SWE,LIST';
            % FIXed = constant output (default)
            % SWEep = voltage sweep output
            % LIST = outputs voltage sequence
            if ~contains(validTypes,type)
                fprintf('Valid function types for the QDAC-II compact are:\n');
                fprintf([validTypes '\n'])
            else
                channelStr = strjoin(string(channels), ',');
                command = sprintf('SOUR:DC:MODE %s,(@%s)',type,channelStr);
                fprintf(QDAC.client,command);
            end
        end 
        
        function [] = QDACSetAllZero(QDAC)         
            channels = 1:24;
            voltages = zeros(1,24);
            QDACSetVoltage(QDAC,channels,voltages);
            % for updating DAC GUI
            numChans = length(channels);
            for i=1:numChans
                evalin('base',[QDAC.name '.channelVoltages( ' num2str(channels(i)) ') = ' num2str(voltages(i)) ';']);
            end
        end 
        %% Set DC voltage functions
        

        function [] = QDACSetVoltage(QDAC,channels,voltages) % sets voltage in Fixed mode
            setQDACDCGeneratorMode(QDAC,channels,'FIX');                     
            for i=1:length(voltages)
                command = sprintf('SOUR:VOLT %s,(@%s)',num2str(voltages(i)),num2str(channels(i)));
                fprintf(QDAC.client,command);
            end
            
            % for updating DAC GUI
            numChans = length(channels);
            for i=1:numChans
                    evalin('base',[QDAC.name '.channelVoltages( ' num2str(channels(i)) ') = ' num2str(voltages(i)) ';']);
            end
        end
         

        function [] = QDACSetSweepStartVoltage(QDAC,channels,voltage) % sets Start Voltage in Sweep mode          
            channelStr = strjoin(string(channels), ',');
            command = sprintf('SOUR:SWE:STAR %s,(@%s)',num2str(voltage),channelStr);
            fprintf(QDAC.client,command);
        end 

        function [] = QDACSetSweepStopVoltage(QDAC,channels,voltage) % sets stop Voltage in Sweep mode          
            channelStr = strjoin(string(channels), ',');
            command = sprintf('SOUR:SWE:STOP %s,(@%s)',num2str(voltage),channelStr);
            fprintf(QDAC.client,command);
        end 

        function [] = QDACSetSweepPoints(QDAC,channels,numSteps)           
            channelStr = strjoin(string(channels), ',');
            command = sprintf('SOUR:SWE:POIN %s,(@%s)',num2str(numSteps),channelStr);
            fprintf(QDAC.client,command);
        end 

        function [] = QDACSetSweepDwell(QDAC,channels,dwell)        
            channelStr = strjoin(string(channels), ',');
            command = sprintf('SOUR:SWE:DWEL %s,(@%s)',num2str(dwell),channelStr);
            fprintf(QDAC.client,command);
        end 

        function [] = QDACSetSweepCount(QDAC,channels,count)  % sets number of times to repeat sweep
            channelStr = strjoin(string(channels), ',');
            command = sprintf('SOUR:SWE:COUN %s,(@%s)',num2str(count),channelStr);
            fprintf(QDAC.client,command);
        end 

        function [] = QDACSetSweepMode(QDAC,channels,type)  % sets the sweep mode
            validTypes = 'STEP,ANAL';
            % STEPped = staircase style sweep (default)
            % ANALog = linear ramp, discretized by sampling rate and DAC
            % precision
            if ~contains(validTypes,type)
                fprintf('Valid function types for the QDAC-II compact are:\n');
                fprintf([validTypes '\n'])
            else
                channelStr = strjoin(string(channels), ',');
                command = sprintf('SOUR:SWE:GEN %s,(@%s)',type,channelStr);
                fprintf(QDAC.client,command);
            end
        end
        
        function [] = QDACRampVoltage(QDAC,channels,voltages,numSteps) % sets interleaved voltage ramp in Sweep mode                       
            % start and stop voltages, and num steps
            startVoltages = str2num(queryQDACVoltage(QDAC,channels));
            for i=1:length(voltages)
                QDACSetSweepStartVoltage(QDAC,channels(i),startVoltages(i))
                QDACSetSweepStopVoltage(QDAC,channels(i),voltages(i))
            end
            QDACSetSweepPoints(QDAC,channels,numSteps)

            % set dwell and count 
            QDACSetSweepDwell(QDAC,channels,0.001) % lowest dwell time = 1us
            QDACSetSweepCount(QDAC,channels,1) % just repeat sweep once
            QDACSetSweepMode(QDAC,channels,'STEP')

            % start sweep
            setQDACDCGeneratorMode(QDAC,channels,'SWE')
            QDACStartSweep(QDAC,channels)

            % for updating DAC GUI
            numChans = length(channels);
            for i=1:numChans
                    evalin('base',[QDAC.name '.channelVoltages( ' num2str(channels(i)) ') = ' num2str(voltages(i)) ';']);
            end
        end 

        function [] = QDACSmoothRampVoltage(QDAC,channels,voltages,time) % sets interleaved voltage ramp in Sweep mode                       
            % start and stop voltages, and num steps
            startVoltages = str2num(queryQDACVoltage(QDAC,channels));
            for i=1:length(voltages)
                QDACSetSweepStartVoltage(QDAC,channels(i),startVoltages(i))
                QDACSetSweepStopVoltage(QDAC,channels(i),voltages(i))
            end
            QDACSetSweepPoints(QDAC,channels,1)

            % set dwell and count 
            QDACSetSweepDwell(QDAC,channels,time) % give this in multiples of 1us (sample rate)
            QDACSetSweepCount(QDAC,channels,1) % just repeat sweep once
            QDACSetSweepMode(QDAC,channels,'ANAL')

            % start sweep
            setQDACDCGeneratorMode(QDAC,channels,'SWE')
            QDACStartSweep(QDAC,channels)
            
            % for updating DAC GUI
            numChans = length(channels);
            for i=1:numChans
                    evalin('base',[QDAC.name '.channelVoltages( ' num2str(channels(i)) ') = ' num2str(voltages(i)) ';']);
            end
        end 

        function [] = QDACStartSweep(QDAC,channels)  % sets number of times to repeat sweep
            channelStr = strjoin(string(channels), ',');
            command = sprintf('SOUR:DC:TRIG:SOUR IMM ,(@%s)',channelStr);
            fprintf(QDAC.client,command);
            command = sprintf('SOUR:DC:INIT (@%s)',channelStr);
            fprintf(QDAC.client,command);
        end 
    end
end
