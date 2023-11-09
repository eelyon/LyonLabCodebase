classdef KeysightE5071
    %KeysightE5071 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        IPAddress
        port         {mustBeNumeric}
        client
        identifier
    end

    methods
        function KeysightE5071 = KeysightE5071(port,IPAddress,opt)
            KeysightE5071.IPAddress     = IPAddress;
            KeysightE5071.port          = port;
            KeysightE5071.client        = TCPIP_Connect(IPAddress,port);                
            KeysightE5071.identifier    = 'E5071';
        end

        function setKeysightE5071PresetConfig(experimentType)
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

        %% SET FREQUENCY/PERIOD %%
        function [ markerVal ] = E5071QueryMarker(ENA,markerNum,xOrY)
            % Function returns the x or the y value of a marker numbered by markerNum.
            % 
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
          markerValArr = str2double(query(ENA,cmd));
          markerVal = markerValArr(1);
        end

        
        function [numPoints] = E5071QueryNumPoints(ENA)
          numPoints = str2num(query(ENA,':SENS1:SWE:POIN?'));
        end

        function [sweepSpan] = E5071QuerySweepSpan( ENA )
          sweepSpan = str2num(query(ENA,':SENS1:FREQ:SPAN?'));
        end

        function [startFreq] = E5071QuerySweepStart(ENA)
          startFreq = str2num(query(ENA,':SENS1:FREQ:STAR?'));
        end

        function [ freqStop] = E5071QuerySweepStop(ENA)
          freqStop = str2num(query(ENA,':SENS1:FREQ:STOP?'));
        end

        function [] = E5071SetAvg(ENA,AvgOnOff)
        %param ENA: Object
        %param AvgOnOff: string 'On' or 'Off'
        
         command = [':SENS1:AVER ',AvgOnOff];
         fprintf(ENA,command);
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
         fprintf(ENA,command);
        end



        
    end
end

