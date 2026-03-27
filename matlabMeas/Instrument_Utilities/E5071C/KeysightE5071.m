classdef KeysightE5071
    %KeysightE5071 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        IPAddress
        port         {mustBeNumeric}
        client
        identifier
        InputBufferSize
    end

    methods
        function KeysightE5071 = KeysightE5071(IPAddress)
            KeysightE5071.IPAddress     = IPAddress;
            KeysightE5071.port          = 5025;
            KeysightE5071.client        = TCPIP_Connect(IPAddress,KeysightE5071.port);                
            KeysightE5071.identifier    = 'E5071';
            KeysightE5071.InputBufferSize = 32000;
        end

        function setKeysightE5071PresetConfig(ENA,experimentType)
            % Function to be used to create presets for the Network Analyzer.
            % This way one can program the E5071 for many different
            % configurations with a single function. 
            switch experimentType
                case 'HeLevelRes'
                    E5071SetAvg(ENA,'Off'); % Turn off averaging
                    E5071SetMeas(ENA,1,'S12'); % S11, S12, S21, S22
                    E5071SetNumPoints(ENA,10000); % set no. of points
                    E5071SetDataFormat(ENA,'PLOG'); % SLIN, SLOG, SCOM, SMIT, SADM, PLIN, PLOG, or POL
                    %E5071SetDelay(ENA,500,2200); % correct for electrical delay
                    E5071SetIFBand(ENA,1); % in kHz
                    E5071SetSweepTime(ENA,4); % in secs
                case 'CoaxCharact'
                otherwise
                    disp(['Your experiment type preset ', experimentType, ' is invald!']);
            end
        end

        %% QUERY FUNCTIONS %%
        function [ markerVal ] = E5071QueryMarker(ENA,markerNum,xOrY)
            % Function returns the x or the y value of a marker numbered by markerNum.
            % Arguments
            % 
            % ENA: TCPIP object that defines the E5071C.
            %
            % markerNum: integer defining the marker number in question.
            %
            % xOrY: string value either 'X' or 'Y'. No other values allowed.
          validInput = {'X','Y'};
          if ~any(strcmp(validInput,xOrY))
            fprintf(['Invalid input: ', xOrY, '. Input must be X or Y\n']);
            return
          end
          cmd = [':CALC1:MARK',num2str(markerNum),':',xOrY,'?'];
          markerValArr = str2double(query(ENA.client,cmd));
          markerVal = markerValArr(1);
        end

        
        function [numPoints] = E5071QueryNumPoints(ENA)
          numPoints = str2num(query(ENA.client,':SENS1:SWE:POIN?'));
        end

        function [sweepSpan] = E5071QuerySweepSpan( ENA )
          sweepSpan = str2num(query(ENA.client,':SENS1:FREQ:SPAN?'));
        end

        function [startFreq] = E5071QuerySweepStart(ENA)
          startFreq = str2num(query(ENA.client,':SENS1:FREQ:STAR?'));
        end

        function [ freqStop] = E5071QuerySweepStop(ENA)
          freqStop = str2num(query(ENA.client,':SENS1:FREQ:STOP?'));
        end
        
        
       %% SET FUNCTIONS %%
        function [] = E5071AutoScale(ENA)
            command = 'DISP:WIND1:TRAC1:Y:AUTO';
            fprintf(ENA.client,command);
        end

        function [] = E5071SetAvg(ENA,AvgOnOff)
            %param ENA: Object
            %param AvgOnOff: string 'On' or 'Off'
        
            command = [':SENS1:AVER ',AvgOnOff];
            fprintf(ENA.client,command);
        end     

        function [] = E5071SetDataFormat(ENA,dataFormat)
        %param ENA: Object
        %param dataFormat: 'SLIN','SLOG','SCOM','SMIT','SADM','PLIN','PLOG', or 'POL'
        
         validDataFormat = {'SLIN','SLOG','SCOM','SMIT','SADM','PLIN','PLOG','POL'};
         if ~any(strcmp(validDataFormat, dataFormat))
           fprintf(['Measurement type: ', dataFormat, ' is not valid.\n']);
           return
         end
        
         command = [':CALC1:FORM ', dataFormat];
         fprintf(ENA.client,command);
        end
        
        function [] = E5071SetDelay(ENA,startFreq,stopFreq)
            % Function that uses the ENA's Marker->Delay function to evaluate the
            % electrical delay. Make sure to choose a large enough window for the ENA
            % to evaluate the electrical delay, but also not too large. A few GHz is
            % usually good.
            % param ENA: callable object
            % param startFreq: start frequency of sweep
            % param stopFreq: stop frequency of sweep
            
            % Set quick measurement sweep
            E5071SetIFBand(ENA,5); % in kHz
            E5071SetSweepTime(ENA,1); % in secs
            
            E5071SetStartFreq(ENA,startFreq);
            E5071SetStopFreq(ENA,stopFreq);
            
            fprintf(ENA.client,':INIT1:IMM'); % Set trigger value - for continuous set: ':INIT:CONT ON'
            fprintf(ENA.client,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
            fprintf(ENA.client,':TRIG:SING'); % Trigger ENA to start sweep cycle
            query(ENA.client,'*OPC?') % Execute *OPC? command and wait until command return 1
            
            fprintf(ENA.client,':CALC1:SEL:MARK1:SET DEL'); % Set electrical delay
            
            edelay = str2num(query(ENA.client,':CALC1:SEL:CORR:EDEL:TIME?'));
            
            fprintf('The electrical delay is (sec) %.5e \n', edelay);
        end
        
        function [] = E5071SetIFBand(ENA,IFBandInKHz)
            command = [':SENS1:BAND ',num2str(IFBandInKHz*1000)];
            fprintf(ENA.client,command);
        end
        
        function [] = E5071SetMarkerX(ENA,markerNum,xVal)
        % xVal in GHz!
          
          startFreq = E5071QuerySweepStart(ENA)/(1e9);
          if(xVal < startFreq)
            fprintf(['Target frequency ', num2str(xVal), 'GHz is less than the start frequency ', num2str(startFreq), 'GHz please increase the frequency\n']);
            return;
          end
          
          stopFreq = E5071QuerySweepStop(ENA)/(1e9);
          if(xVal > stopFreq)
            fprintf(['Target frequency ', num2str(xVal), 'GHz is greater than the stop frequency ', num2str(stopFreq), 'GHz please increase the frequency\n']);
            return;
          end
          
          xVal = xVal*1e9;
          cmd = [':CALC1:TRAC1:MARK',num2str(markerNum),':X ',num2str(xVal)];
          fprintf(ENA.client, cmd);
        end
        
        function [] = E5071SetMeas(ENA, traceNum, measType)
            % sets the measurement type (S11,S12,S21,S22) for trace number N.
            % 
            % Arguments:
            %
            % E5071C: ENA object that contains information about the address and port.
            % traceNum: integer representing the trace that will be modified
            % measType: string representing the type of measurement to perform. Valid
            %           strings are: S11, S12, S21, S22
            
            validMeasType = {'S11','S12','S21', 'S22'};
            if ~any(strcmp(validMeasType,measType))
              fprintf(['Measurement type: ', measType, ' is not valid.\n']);
              return
            end
            
            cmd = [':CALC', num2str(traceNum), ':PAR', num2str(traceNum), ':DEF ', measType,'\n'];
            fprintf(ENA.client,cmd);
          
        end
        
        function [] = E5071SetNumPoints(ENA,numPoints)
         command = [':SENS1:SWE:POIN ',num2str(numPoints)];
         fprintf(ENA.client,command);
        end

        function [] = E5071SetPower(ENA,powerdBm)
        command = [':SOUR1:POW ',num2str(powerdBm)];
         fprintf(ENA.client,command);
        end 

        function [] = E5071SetStartFreq(ENA,freqInMHz)
         command = [':SENS1:FREQ:STAR ', num2str(freqInMHz*1e6)];
         fprintf(ENA.client,command);
        end
        
        function [] = E5071SetStartPow(ENA,powIndBm)
         command = [':SOUR1:POW:STAR ',num2str(powIndBm)];
         fprintf(ENA.client,command);
        end

        function [] = E5071SetStopFreq(ENA,freqInMHz)
         command = [':SENS1:FREQ:STOP ', num2str(freqInMHz*1e6)];
         fprintf(ENA.client,command);
        end

        function [] = E5071SetStopPow(ENA,powIndBm)
         command = [':SOUR1:POW:STOP ',num2str(powIndBm)];
         fprintf(ENA.client,command);
        end

        function [] = E5071SetSweepTime(ENA,sweepTimeInSec)
         command = [':SENS1:SWE:TIME ',num2str(sweepTimeInSec)];
         fprintf(ENA.client,command);
        end
        
        function [] = E5071SetTriggerValue(ENA,opt)
            if exist('opt','var') 
                command = ':INIT1:CONT ON';                
            else
                command = ':INIT1';
            end
            fprintf(ENA.client,command);
        end

        

        function [] = E5071SetTrig(ENA,trigType)
            % Sets the trigger value for the E5071. Arguments are:
            % 
            % E5071C: TCP object that contains the connection info for the E5071C in
            % question
            %
            % trigType: trigger type to change to. Valid inputs are CONT, SINGLE, or HOLD.
            validTrigTypes = {'CONT','HOLD','SINGLE'};
            if ~any(strcmp(validTrigTypes,trigType));
              fprintf(['Trigger Type: ', trigType , ' is not supported. Trigger type not set.\n']);
              return
            end
            
            cmd = ':INIT1:';
            contCmd = ':INIT1:CONT';
            
            if strcmp(trigType,'CONT')
              cmd = [contCmd, ' ON'];
              fprintf(ENA.client, cmd);
            elseif (strcmp(trigType,'SINGLE') || strcmp(trigType,'HOLD'))
              fprintf(ENA.client, [contCmd, ' OFF']);
              if(strcmp(trigType,'SINGLE'))
                cmd = [cmd, 'IMM'];
                fprintf(ENA.client,cmd);
              end
            end
        end
    end
end

