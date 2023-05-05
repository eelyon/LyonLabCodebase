classdef TDS2022C

    properties
        USBAddress
        client
        identifier
    end

    methods
        function TDS2022C = TDS2022C(addr)
            TDS2022C.USBAddress    = addr;
            TDS2022C.client        = visadev(addr);
            TDS2022C.identifier    = '2022';
        end
        
        function [] = setTDS2022ChPos( Oscilloscope,Channel,position)
          % sets position in Volts, note that when the scale changes so too will
          % the position!!!!
          scale = queryTDS2022ChScale(Oscilloscope,Channel);
          divPos = position/scale;
          command = ['CH' num2str(Channel) ':POS ' num2str(divPos)];
          fprintf(Oscilloscope.client,command);
        end 


        function [ chOffset ] = queryTDS2022ChPos(Oscilloscope,Channel)
          % sets position in Volts, note that when the scale changes so too will
          % the position!!!!
          command = ['CH' num2str(Channel) ':POS?'];
          chPos = str2double(query(Oscilloscope.client,command));
          chOffset = chPos*queryTDS2022ChScale(Oscilloscope,Channel);
        end

        function [] = setTDS2022ChScale( Oscilloscope,chNum,scale )
          command = ['CH' num2str(chNum) ':SCA ' num2str(scale)];
          fprintf(Oscilloscope.client,command);
        end

        function [ scale ] = queryTDS2022ChScale(Oscilloscope,Channel)
          scale = str2double(query(Oscilloscope.client,['CH' num2str(Channel) ':SCA?']));
        end

        function [] = setTDS2022NumAvgs(Oscilloscope,numAvgs)
          fprintf(Oscilloscope.client,['ACQ:NUMAV ' num2str(numAvgs)]);
        end

        function [numAvgs] = queryTDS2022NumAvgs(Oscilloscope)
          numAvgs = query(Oscilloscope.client,'ACQ:NUMAV?');
        end

        function [] = setTDS2022AcqMode( Oscilloscope, mode )
          if ~strcmp(mode,'SAM') && ~strcmp(mode,'PEAK') && ~strcmp(mode,'AVE')
            disp('Invalid mode, valid modes are SAMple, PEAKdetect, or AVErage');
          else
            fprintf(Oscilloscope.client,['ACQ:MOD ' mode]);
          end
        end

        function [acqMode] = queryTDS2022AcqMode( Oscilloscope )
          acqMode = query(Oscilloscope.client,'ACQ:MOD?');
        end

        function [] = primeTDS2022ForAcquisition( Oscilloscope )
          fprintf(Oscilloscope.client,'ACQ:STATE ON');
        end

        function [] = setTDS2022DataSource( Oscilloscope,Chan )
          fprintf(Oscilloscope.client,['DAT:SOU CH' num2str(Chan)]);
        end

        function [ chSource ] = queryTDS2022DataSource( Oscilloscope )
          chSource = query(Oscilloscope.client,'DAT:SOU?');
        end

        function [ xData,yData ] = getTDS2022YData( Oscilloscope,chNum )
            if ~strcmp(['CH' chNum],queryTDS2022DataSource(Oscilloscope))
              setTDS2022DataSource(Oscilloscope,chNum);
            end
            
            data = query(Oscilloscope.client,'CURV?');
            yData = scaleTDS2022RawData(Oscilloscope,data) - queryTDS2022ChPos(Oscilloscope,chNum);
            xData = getTDS2022XData(Oscilloscope,yData);
        end
        
        function yDat = scaleTDS2022RawData(Oscilloscope,data)
            data = strsplit(data,',');
            yDat = [];
            yScaling = str2double(query(Oscilloscope.client,'WFMP:YMU?'));
            for i = 1:length(data)
              yDat(i) = str2double(data{i})*yScaling;
            end
        end
        
        function xData = getTDS2022XData(Oscilloscope,yData)
            xSpacing = queryTDS2022XInterval(Oscilloscope);
            pause(.1)
            xStart = queryTDS2022StartX(Oscilloscope);
            pause(.1)
            xStop = xStart + (length(yData)-1)*xSpacing;
            xData = xStart:xSpacing:xStop;
        end

        function [ Xinterval] = queryTDS2022XInterval( Oscilloscope)
          Xinterval = str2double(query(Oscilloscope.client,'WFMPre:XIN?'));
        end

        function [ startX ] = queryTDS2022StartX( Oscilloscope )
          startX = str2double(query(Oscilloscope.client,'WFMP:XZE?'));
        end

        function [voltFigure] = get2ChannelTDS2022Data(Oscilloscope)
          [xDat1,yDat1] = getTDS2022YData(Oscilloscope,1);
          [xDat2,yDat2] = getTDS2022YData(Oscilloscope,2);
          legCell = {'CH1','CH2'};
          
          voltFigure = figure(getNextMATLABFigNum());
          plot(xDat1,yDat1,'b');
          hold on
          plot(xDat2,yDat2,'g');
          hold off
          legend(legCell,'Location','northwest')
          xlabel('Time (s)');
          ylabel('Voltage (V)');
        end

        function [] = setTDS2022TriggerType( Oscilloscope, type)
          if ~strcmp(type,'EDGE') && ~strcmp(type,'VID') && ~strcmp(type,'PUL')
            disp('Invalid trigger type, EDGE, VID, PUL, are the only types allowed');
          else
            fprintf(Oscilloscope.client,['TRIG:MAI:TYP ' type]);
          end
        end

        function [trigType] = queryTDS2022TriggerType(Oscilloscope)
          trigType = query(Oscilloscope.client,'TRIG:MAI:TYP?');
        end

        function [] = setTDS2022TriggerSource( Oscilloscope,source )
           if ~strcmp(source,'CH1') && ~strcmp(source,'CH2') && ~strcmp(source,'EXT')
              disp('Invalid Trigger Source, only allowed sources are CH1, CH2, or EXT');
           else
             fprintf(Oscilloscope.client,['TRIG:MAI:EDGE:SOU ' source]);  
           end
        end

        function [trigSource] = queryTDS2022TriggerSource( Oscilloscope )
          trigSource = query(Oscilloscope.client,'TRIG:MAI:EDGE:SOU?');
          trigSource = trigSource(1:length(trigSource)-1);
        end

        function [ ] = setTDS2022TriggerSlope(Oscilloscope, slope)
          if ~strcmp(slope,'RIS') && ~strcmp(slope,'FALL')
              disp('Invalid trigger slope. Only allowed types are RISe and FALL');
          else
              fprintf(Oscilloscope.client,['TRIG:MAI:EDGE:SLO ' slope]);
          end
        end

        function [trigSlope] = queryTDS2022TriggerSlope( Oscilloscope )
          trigSlope = query(Oscilloscope.client,'TRIG:MAI:EDGE:SLO?');
        end

        function [trigLevel] = queryTDS2022TriggerLevel(Oscilloscope)
          trigLevel = query(Oscilloscope.client,'TRIG:MAI:LEV?');
        end

        function [] = setTDS2022TriggerLevel( Oscilloscope,level )
          fprintf(Oscilloscope.client,['TRIG:MAI:LEV ' num2str(level)]);
        end

        function [trigState] = queryTDS2022TriggerState( Oscilloscope )
          trigState = query(Oscilloscope.client,'TRIG:STATE?');
          trigState = trigState(1:length(trigState)-1);
        end
    end
end