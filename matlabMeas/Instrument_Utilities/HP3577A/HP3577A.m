classdef HP3577A
    properties
        Address            {mustBeNumeric}
        boardIndex         {mustBeNumeric}
        client
        identifier
    end

    methods
        function HP3577A = HP3577A(boardIndex,Address)
            HP3577A.Address     = Address;
            HP3577A.boardIndex  = boardIndex;
            HP3577A.client      = GPIB_Connect(boardIndex,Address);                
            HP3577A.identifier  = '3577A';
        end

        function [datArr,freqArr] = pull3577AData(HP3577A,startFreq,stopFreq)
            fprintf(HP3577A.client,'FM1;DT1;');
            datArr = str2num((fscanf(HP3577A.client,'%s')));
            freqArr = linspace(startFreq,stopFreq,401);
            
        end
        
        function [freqArr,datArr,voltageGain,fit] = pull3577ARollOff(HP3577A,startFreq,stopFreq)
            [datArr,freqArr] = pull3577AData(HP3577A,startFreq,stopFreq);
            correctY = [];
            [correctionX,correctionY] = getXYData('C:\Users\Lyon-Lab-B417\Documents\GitHub\LyonLabCodebase\matlabMeas\Data\07_10_24\Background_S21.fig');
            for i = 1:length(correctionY)
                correctY(i) = datArr(i)+ 76;
            end
            voltageGain = convertdBmToVoltage(correctY);
            [fit,gof] = fitRollOff(freqArr,voltageGain);
        end

        function [] = pullAndPlot3577ARollOff(HP3577A,startFreq,stopFreq)
            [freqArr,datArr,voltageGain,fit] = pull3577ARollOff(HP3577A,startFreq,stopFreq);
            [hand,myFig] = plotData(freqArr,voltageGain,'color',"b-",'type',"semilogx");
            hold on;
            
            fitHandle = plot(fit);
            hold off;
            legend('Measured S_{21}','Fit');
            xlabel('Frequency (Hz)');
            ylabel('Voltage Gain (arb. units)');
            txt = strcat("Fitted Rolloff Frequency = ", num2str(fit.b), " HZ");
            annotation('textbox',[0.2 0.5 0.3 0.3],'String',txt,'FitBoxToText','on');
            saveData(myFig,'CorrectedRollOff',0);
            [hand2,myFig2] = plotData(freqArr,datArr,'xLabel',"Frequency (Hz)",'yLabel',"S_{21} (dBm)",'type',"semilogx",'color',"r-");
            saveData(myFig2,'RawRollOff');
        end
        %% GETTER Functions

        function startFreq = get3577AStartFreq(HP3577A)
            startFreq = num2str(query(HP3577A.client,'FRA?'));
        end

        function stopFreq = get3577AStopFreq(HP3577A)
            stopFreq = num2str(query(HP3577A.client,'FRB?'));
        end

        %% SET SOURCE FUNCTIONS %%
        function [] = set3577ASweepType(HP3577A,type)
            validTypes = 'LIN,ALT,LOG,AMP,CW,SDU,SDD';
            if ~contains(validTypes,type)
                fprintf('Valid function types for the HP3577A are:\n');
                fprintf([validTypes '\n'])
            else
                switch type
                    case 'LIN'
                        cmd = 'ST1';
                    case 'ALT'
                        cmd = 'ST2';
                    case 'LOG'
                        cmd = 'ST3';
                    case 'AMP'
                        cmd = 'ST4';
                    case 'CW'
                        cmd = 'ST5';
                    case 'SDU'
                        cmd = 'SUP';
                    case 'SDD'
                        cmd = 'SDN';
                end
                command = cmd;
                fprintf(HP3577A.client,command);
            end
        end

        function [] = set3577ASweepMode(HP3577A,mode)
            validModes = 'CONT,SING,MAN,';
            if ~contains(validModes,mode)
                fprintf('Valid sweep modes for the HP3577A are:\n');
                fprintf([validModes '\n'])
            else
                switch mode
                    case 'CONT'
                        cmd = 'SM1';
                    case 'SING'
                        cmd = 'SM2';
                    case 'MAN'
                        cmd = 'SM3';
                end
                command = cmd;
                fprintf(HP3577A.client,command);
            end
        end
        
        function [] = set3577ASweepTime(HP3577A,sweepTime)
            command = ['SWT ',num2str(sweepTime), 'SEC'];
            fprintf(HP3577A.client,command);
        end

        function [] = set3577AStepTime(HP3577A,stepTime)
            command = ['SMT ',num2str(stepTime), 'SEC'];
            fprintf(HP3577A.client,command);
        end

        function [] = set3577ASampleTime(HP3577A,sampleTime)
            command = ['SMR ',num2str(sampleTime), 'SEC'];
            fprintf(HP3577A.client,command);
        end
        
        function [] = set3577ASourceFrequency(HP3577A,sourceFreq)
            command = ['SFR ',num2str(sourceFreq), 'Hz'];
            fprintf(HP3577A.client,command);
        end

        function [] = set3577AStartFrequency(HP3577A,startFreq)
            command = ['FRA ',num2str(startFreq), 'Hz'];
            fprintf(HP3577A.client,command);
        end

        function [] = set3577AStopFrequency(HP3577A,stopFreq)
            command = ['FRB ',num2str(stopFreq), 'Hz'];
            fprintf(HP3577A.client,command);
        end

        function [] = set3577ACenterFrequency(HP3577A,centerFreq)
            command = ['FRC ',num2str(centerFreq), 'Hz'];
            fprintf(HP3577A.client,command);
        end
        
        function [] = set3577AFrequencySpan(HP3577A,freqSpan)
            command = ['FRS ',num2str(freqSpan), 'Hz'];
            fprintf(HP3577A.client,command);
        end


        %% SET RECEIVER FUNCTIONS
        function [] = set3577Attenuation(HP3577A,inputChannel,attenuation)
            validChannels = 'R,A,B';
            validAttenuation = '0dB,20dB';
            if ~contains(validChannels,inputChannel) && ~contains(validAttenuation,attenuation)
                fprintf('Valid input channels for the HP3577A are:\n');
                fprintf([validChannels '\n'])
                fprintf('Valid attenuation for the HP3577A are:\n');
                fprintf([validAttenuation '\n'])
            else
                switch attenuation
                    case '0dB'
                        atten = '1';
                    case '20dB'
                        atten = '2';
                end
                command = ['A',inputChannel,atten];
                fprintf(HP3577A.client,command);
            end 
        end 

        function [] = set3577Impedance(HP3577A,inputChannel,impedance)
            validChannels = 'R,A,B';
            validImpedance = '50ohm,1Meg';
            if ~contains(validChannels,inputChannel) && ~contains(validImpedance,impedance)
                fprintf('Valid input channels for the HP3577A are:\n');
                fprintf([validChannels '\n'])
                fprintf('Valid output impedances for the HP3577A are:\n');
                fprintf([validImpedance '\n'])
            else
                switch impedance
                    case '50ohm'
                        imp = '1';
                    case '1Meg'
                        imp = '2';
                end
                command = ['I',inputChannel,imp];
                fprintf(HP3577A.client,command);
            end
        end 

        function [] = set3577Average(HP3577A,numAverage)
            validAveraging = '0,4,8,16,32,64,128,256';
            if ~contains(validAveraging,numAverage)
                fprintf('Valid number of averages for the HP3577A are:\n');
                fprintf([validAveraging '\n'])
            else
                switch numAverage
                    case '0'
                        avg = '0';
                    case '4'
                        avg = '1';
                    case '8'
                        avg = '2';
                    case '16'
                        avg = '3';
                    case '32'
                        avg = '4';
                    case '64'
                        avg = '5';
                    case '128'
                        avg = '6';
                    case '256'
                        avg = '7';
                end
                command = ['AV',avg];
                fprintf(HP3577A.client,command);
            end
        end

        %% SET HP-IP PLOTTING FUNCTIONS %%
        function [] = set3577ADataFormatASCII(HP3577A)
            command = 'FM1';
            fprintf(HP3577A.client,command);
        end

        function [] = set3577ADataFormat64Bit(HP3577A)
            % 64bit IEEE data format %
            command = 'FM2';
            fprintf(HP3577A.client,command);
        end

        function [] = set3577ADataFormatBinary(HP3577A)
            % 32bit HP 3577A data format %
            command = 'FM3';
            fprintf(HP3577A.client,command);
        end

        function [] = get3577ATrace(HP3577A,traceNumber)
            command = ['DT',num2str(traceNumber)];
            fprintf(HP3577A.client,command);
        end
    end
end

