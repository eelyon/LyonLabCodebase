classdef HarvardDAC
    %   HarvardDAC class
    %   Contains functions for initiating the Harvard DACs and setting
    %   voltages
    
    properties
        comPort  
        numChannels {mustBeNumeric}
        client
        name
        identifier
        DACRange            % Defines full range of DAC
        DACOffset           % Defines zero offset
        DACDivider          % Defines divider value
        DACLimit            % Self imposed voltage limit to prevent blowing your device
        DACLabel            % Name for a channel
        DACVoltage          % Voltage?
        rampStep            % mV per step
        rampTime            % Seconds of delay per step
    end
    
    methods
        function HarvardDAC = HarvardDAC(comPort,name,numChannels)
            
            HarvardDAC.comPort = comPort;
            HarvardDAC.client = serialport(comPort,57600,"Parity","none","DataBits",8,"StopBits",1);
            HarvardDAC.name = name;
            % HarvardDAC.identifier = writeread(HarvardDAC.client,"*IDN?");
            % DAC is unable to give responses ^
            HarvardDAC.numChannels = numChannels;
            
            % Set Harvard DAC parameters
            for chan = 1:HarvardDAC.numChannels
                HarvardDAC.DACRange(chan) = 1e4;
            end
            for chan = 1:HarvardDAC.numChannels
                HarvardDAC.DACOffset(chan) = 0;
            end
            for chan = 1:HarvardDAC.numChannels
                HarvardDAC.DACDivider(chan) = 1;
            end
            for chan = 1:HarvardDAC.numChannels
                HarvardDAC.DACLimit(chan) = 10000/HarvardDAC.DACDivider(chan);
            end
            for chan = 1:HarvardDAC.numChannels
                HarvardDAC.DACLabel(chan) = "";
            end
            for chan = 1:HarvardDAC.numChannels
                HarvardDAC.DACVoltage(chan) = 0;
            end

            restarted = input('Do you want to zero the DAC? (y/n)',"s");
            if strcmp(restarted,'y')
                SetAllDAC(HarvardDAC, 0); % Set all DAC channels to 0 mV
            end
            
            HarvardDAC.rampStep = 20; % mV per step
            HarvardDAC.rampTime = 0.005; % Seconds of delay per step
        end

        function ret = getDACChanLabel(HarvardDAC, chanNum)

            dacLabels = HarvardDAC.DACLabel;
            ret = dacLabels(chanNum);
        end

        function LimitDAC(HarvardDAC, chan, mV)
            if (chan>0 && chan<=HarvardDAC.numChannels) && (mV>1 && mV<10000)
                HarvardDAC.DACLimit(chan+1) = mV;
            else
                sprintf("LimitDAC: Range violation: channel %i", chan, "and voltage %i", mV)
                return
            end
        end

        function RampDAC(HarvardDAC, chan, mV)
            % Ramp chan # chan to voltage mV
            if (chan<0) || (chan>HarvardDAC.numChannels)
                sprintf("Channel number is out of range!")
                return
            end

            mVstart = HarvardDAC.DACVoltage(chan+1);
            rampstep = HarvardDAC.rampStep;

            if abs(mVstart-mV)>rampstep
                numsteps = ceil(abs(mV-mVstart)/rampstep);
                rampstep = (mV-mVstart)/numsteps;

                for n = 1:numsteps
                    delay(HarvardDAC.rampTime)
                    SetDAC(HarvardDAC, chan, (mVstart+n*rampstep));
                end
            end
            SetDAC(HarvardDAC, chan, mV); % Make sure there are no rounding errors
        end
   
        function SetDAC(HarvardDAC, chan, mV)
            % Set chan # chan to voltage mV

            if (chan>HarvardDAC.numChannels) || (chan<0)
                sprintf("Channel number is out of range!")
                return
            end

            if (abs(mV)>HarvardDAC.DACLimit)
                sprintf("SetDAC: Range violation channel %i", chan)
                return
            else

            mV = mV*HarvardDAC.DACDivider(chan+1); % For convenience

            % Determine the digitized value, i.e. the bin number, corresponding to mV that the DAC has to be set to
            % This DAC is 20bit, the physical range is fixed at -10V to +10V, i.e. binsize = 20/2^20= about 19 microvolts
            % If there is a voltage divider at the output of the box, binsize is divided by the value of the divider

            bin = floor(2^19+((mV-HarvardDAC.DACOffset(chan+1))*(2^19)/HarvardDAC.DACRange(chan+1)));
            
            if bin > (2^20-1)
                sprintf("SetDAC: Cannot set DAC to such a positive value! Setting to Maximum")
                bin = 2^20-1;
            end

            if bin < 0
                sprintf("SetDAC: Cannot set DAC to such a negative value! Setting to Minimum")
                bin = 0;
            end

            SetDACBin(HarvardDAC, chan, bin);

            mV = ((bin-2^19)*HarvardDAC.DACRange(chan+1)/2^19)+HarvardDAC.DACOffset(chan+1);
            evalin('base',[HarvardDAC.name '.DACVoltage( ' num2str(chan+1) ') = ' num2str(mV/HarvardDAC.DACDivider(chan+1)) ';']);
            end
        end

        function SetDACBin(HarvardDAC, chan, bin)
            % Set channel # chan to bin # bin
            flush(HarvardDAC.client);

            device = floor(chan/4)+1;
            IanChan = mod(chan,4);
            
            % TODO: Set dip switches on DAC boards
            IDby = 192+device;      % Set ID byte to "11dddddd" where dddddd is the device ID
            write(HarvardDAC.client,IDby,'uint8')
            % fprintf(HarvardDAC.client,"%d",num2str(IDby)); % Write IDby in binary to DAC (cmd, "VDTWriteBinary2 /O=10 %d", IDby)

            Commandby = 64+IanChan; % Update DAC Channel "010000cc" where cc is the channel number
            write(HarvardDAC.client,Commandby,'uint8')
            % fprintf(HarvardDAC.client,"%d",num2str(Commandby)); % Write Commandby in binary to DAC
            % Send Byte 2 = Comman Byte (Command 01000001 Update Channel 1)
            
            % Convert 20 bits
            dum = floor(bin/128)*128; % Extract the 8 least significant bits
            by3 = bin - dum;
            dum = dum/128; % Extract the 8 mid significant bits
            dum2 = floor(dum/128)*128;
            by2 = dum - dum2;
            by1 = dum2/128; % 8 most significant bits
            
            % Write bits to DAC
            write(HarvardDAC.client,by1,'uint8')
            write(HarvardDAC.client,by2,'uint8')
            write(HarvardDAC.client,by3,'uint8')
            % The data sent are 20-bit data of the form aaaaaabbbbbbcccccc

            parity = bitxor(bitxor(bitxor(bitxor(IDby,Commandby),by1),by2),by3); % Parity byte is XOR of all bytes in command

            if parity >= 128
                parity = parity - 128;
            end
            
            write(HarvardDAC.client,parity,'uint8')
            write(HarvardDAC.client,0,'uint8')
        end

        function SetAllDAC(HarvardDAC, mV)
            % Set all channels of DAC to the same voltage
            for chan = 1:HarvardDAC.numChannels
                SetDAC(HarvardDAC, chan-1, mV);
            end
        end

        function CalDAC(HarvardDAC, chan)
            % TODO...
            % Function for calibrating DAC offsets
            % Best done manually by hooking up a DMM
            low = 0;
            mid = 0;
            high = 0;

            SetDAC(HarvardDAC, chan, 0);
        end

        function turnOnHEMT_TL(HarvardDAC,channels,endVoltage)
            VtomV = 1e3;
            Vg_voltages = [0.2,0.45];
            for i = Vg_voltages
                for j = channels
                    SetDAC(HarvardDAC,j,i*VtomV)
                end
            end
            
            Vbias_voltages = 0.7:0.2:1.5;
            for i = Vbias_voltages
                for j = channels(2:3)
                    SetDAC(HarvardDAC,j,i*VtomV)
                end
            end
            SetDAC(HarvardDAC,channels(end),endVoltage*VtomV)
        end

        function turnOffHEMT_TL(HarvardDAC,channels)
            VtomV = 1e3;
            Vbias_voltages = 1.5:-0.2:0.7;
            for i = Vbias_voltages
                for j = channels(2:3)
                    SetDAC(HarvardDAC,j,i*VtomV)
                end
            end
            Vg_voltages = [0.5,0.3,0];
            for i = Vg_voltages
                for j = channels
                    SetDAC(HarvardDAC,j,i*VtomV)
                end
            end
        end
    end
end

