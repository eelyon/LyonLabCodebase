classdef SDG5122
    % A general driver for the SDG5000 series of Siglent
    % function generators.

    properties
        USBAddress
        client
        identifier
    end

    methods
        function SDG5122 = SDG5122(USBAddress)
            SDG5122.USBAddress    = USBAddress;
            SDG5122.client        = visadev(USBAddress);
            SDG5122.identifier    = 'SDG5122';
        end

        function [] = set5122Output(SDG5122,OnOff, chann)
            if OnOff
                cmdStr = 'ON';
            else
                cmdStr = 'OFF';
            end
            command = ['C',num2str(chann),':OUTP ', cmdStr];
            fprintf(SDG5122.client,command);
        end

        function outp = get5122Output(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':OUTP?']));
            splitted = (split(outputParams, ','));
            imp = char(splitted(1));
            spaced = (split(imp, ' '));
            outp = char(spaced(2));
        end

        function [] = set5122OutputLoad(SDG5122,type, chann) 
            validTypes = '50,HZ';
            if ~contains(validTypes,type)
                fprintf('Valid function types for the 5122 are:\n');
                fprintf([validTypes '\n'])
            else
                command = ['C',num2str(chann),':OUTP LOAD, ', type];
                fprintf(SDG5122.client,command);
            end
        end

        function imp = get5122OutputLoad(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':OUTP?']));
            splitted = (split(outputParams, ','));
            imp = char(splitted(3));
        end

        function [] = set5122Polarity(SDG5122,type, chann) 
            validTypes = 'INVT,NOR';
            if ~contains(validTypes,type)
                fprintf('Valid function types for the 5122 are:\n');
                fprintf([validTypes '\n'])
            else
                command = ['C',num2str(chann),':OUTP PLRT, ', type];
                fprintf(SDG5122.client,command);
            end
        end

        function outp = get5122Polarity(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':OUTP?']));
            splitted = (split(outputParams, ','));
            cell = char(splitted(5));
            regger = regexp(cell,'[a-z,A-Z]','match');
            outp = char(transpose(cat(1, regger{:})));
        end

        function [] = set5122Freq(SDG5122, freq, chann) % sets frequency
            command = ['C',num2str(chann),':BSWV FRQ,' num2str(freq)];
            fprintf(SDG5122.client,command);
        end

        function [] = set5122ModFreq(SDG5122, freq, chann) % sets frequency
            command = ['C',num2str(chann),':MDWV CARR,FRQ,' num2str(freq)];
            fprintf(SDG5122.client,command);
        end

        function outp = get5122Freq(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':BSWV?']));
            splitted = (split(outputParams, ','));
            cell = char(splitted(4));
            outp = str2double(char(regexp(cell,'\d*','Match')));
        end

        function [] = set5122Amp(SDG5122, amp, chann) % sets ampltiude
            command = ['C',num2str(chann),':BSWV AMP,' num2str(amp)];
            fprintf(SDG5122.client,command);
        end

        function [] = set5122ModAmp(SDG5122, amp, chann) % sets ampltiude
            command = ['C',num2str(chann),':MDWV CARR,AMP,' num2str(amp)];
            fprintf(SDG5122.client,command);
        end

        function outp = get5122Amp(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':BSWV?']));
            splitted = (split(outputParams, ','));
            cell = char(splitted(8));
            regger = regexp(cell,'[0-9.-]','match');
            outp = str2double(char(cat(1, regger{:})));
        end

        function [] = set5122Phase(SDG5122, phase, chann) % sets ampltiude
            command = ['C',num2str(chann),':BSWV PHSE,' num2str(phase)];
            fprintf(SDG5122.client,command);
        end

        function [] = set5122ModPhase(SDG5122, phase, chann) % sets ampltiude
            command = ['C',num2str(chann),':MDWV CARR,PHSE,' num2str(phase)];
            fprintf(SDG5122.client,command);
        end

        function outp = get5122Phase(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':BSWV?']));
            splitted = (split(outputParams, ','));
            cell = char(splitted(16));
            regger = regexp(cell,'[0-9.-]','match');
            outp = str2double(char(cat(1, regger{:})));
        end

        function [] = set5122Offset(SDG5122, ofset, chann) % sets ampltiude
            command = ['C',num2str(chann),':BSWV OFST,' num2str(ofset)];
            fprintf(SDG5122.client,command);
        end

        function [] = set5122ModOffset(SDG5122, ofset, chann) % sets ampltiude
            command = ['C',num2str(chann),':MDWV CARR,OFST,' num2str(ofset)];
            fprintf(SDG5122.client,command);
        end

        function outp = get5122Offset(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':BSWV?']));
            splitted = (split(outputParams, ','));
            cell = char(splitted(10));
            regger = regexp(cell,'[0-9.-]','match');
            outp = str2double(char(cat(1, regger{:})));
        end

        function [] = set5122VoltageHigh(Siglent5122,amp_high, chann)
            command = ['C',num2str(chann),':BSWV HLEV,' num2str(amp_high)];
            fprintf(Siglent5122.client,command);
        end

        function outp = get5122VoltageHigh(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':BSWV?']));
            splitted = (split(outputParams, ','));
            cell = char(splitted(12));
            regger = regexp(cell,'[0-9.-]','match');
            outp = str2double(char(cat(1, regger{:})));
        end

        function [] = set5122VoltageLow(Siglent5122,amp_low, chann) % sets low level of C1
            command = ['C',num2str(chann),':BSWV LLEV,' num2str(amp_low)];
            fprintf(Siglent5122.client,command);
        end

        function outp = get5122VoltageLow(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':BSWV?']));
            splitted = (split(outputParams, ','));
            cell = char(splitted(14));
            regger = regexp(cell,'[0-9.-]','match');
            outp = str2double(char(cat(1, regger{:})));
        end
        
        function [] = set5122Rise(Siglent5122,time, chann) % sets rise time
            command = ['C',num2str(chann),':BSWV RISE,' num2str(time)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122Period(Siglent5122,periodInSec, chann) 
            command = ['C',num2str(chann),':BTWV PERI,' num2str(periodInSec)];
            fprintf(Siglent5122.client,command);
        end

        function outp = get5122Period(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':BSWV?']));
            splitted = (split(outputParams, ','));
            cell = char(splitted(6));
            regger = regexp(cell,'[e0-9.-]','match');
            outp = str2double(char(cat(1, regger{:})));
        end

        function [] = set5122PulseWidth(Siglent5122,pulseWidthInSec, chann)  % sets the pulse width (s)
            command = ['C',num2str(chann),':BSWV WIDTH,' num2str(pulseWidthInSec)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122NumBurstCycles(Siglent5122, numCycles, chann) % set num of cycles to burst
            command = ['C',num2str(chann),':BTWV TIME, ' num2str(numCycles)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122Delay(Siglent5122,delay, chann) 
            command = ['C',num2str(chann),':BSWV DLAY,' num2str(delay)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122FunctionType(Siglent5122, type, chann) 
            validTypes = 'SINE,SQUARE,RAMP,PULSE,NOISE,ARB,DC,PRBS';
            if ~contains(validTypes,type)
                fprintf('Valid function types for the 5122 are:\n');
                fprintf([validTypes '\n'])
            else
                command = ['C',num2str(chann),':BSWV WVTP, ', type];
                fprintf(Siglent5122.client,command);
            end            
        end

        function [] = set5122ModFunctionType(Siglent5122, type, chann) 
            validTypes = 'SINE,SQUARE,RAMP,PULSE,NOISE,ARB,DC,PRBS';
            if ~contains(validTypes,type)
                fprintf('Valid function types for the 5122 are:\n');
                fprintf([validTypes '\n'])
            else
                command = ['C',num2str(chann),':MDWV CARR,WVTP, ', type];
                fprintf(Siglent5122.client,command);
            end            
        end

        function outp = get5122FunctionType(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':BSWV?']));
            splitted = (split(outputParams, ','));
            outp = char(splitted(2));
        end

        function [] = set5122ModState(SDG5122,OnOff, chann)
            if OnOff
                cmdStr = 'ON';
            else
                cmdStr = 'OFF';
            end
            command = ['C',num2str(chann),':MDWV STATE,', cmdStr];
            fprintf(SDG5122.client,command);
        end

        function imp = get5122ModState(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':MDWV?']));
            splitted = (split(outputParams, ','));
            imp = char(splitted(2));
        end

       function [] = set5122AMSource(SDG5122,type, chann) 
            validTypes = 'INT,EXT,CH1,CH2';
            if ~contains(validTypes,type)
                fprintf('Valid function types for the 5122 are:\n');
                fprintf([validTypes '\n'])
            else
                command = ['C',num2str(chann),':MDWV AM,SRC, ', type];
                fprintf(SDG5122.client,command);
            end
        end

        function imp = get5122AMSource(SDG5122, chann)
            outputParams = (query(SDG5122.client,['C',num2str(chann),':MDWV?']));
            splitted = (split(outputParams, ','));
            imp = char(splitted(5));
        end

        %% Burst Wave Functions %%

        function [] = set5122BurstStateOn(SDG5122,onOrOff, chann)
            if onOrOff
                command = ['C',num2str(chann),':BTWV STATE,ON'];
            else
                command = ['C',num2str(chann),':BTWV STATE,OFF'];
            end
            fprintf(SDG5122.client,command);
        end

        function [] = set5122BurstTriggerSource(Siglent5122,burstTrigger, chann)
            set5122BurstStateOn(Siglent5122,1, chann);
            validTypes = 'EXT,INT,MAN';
            if ~contains(validTypes,burstTrigger)
                fprintf('Invalid burst trigger source, valid types are:\n');
                fprintf(validTypes);
            else
                command = ['C',num2str(chann),':BTWV TRSR, ' burstTrigger];
                fprintf(Siglent5122.client,command);
            end
        end

        function [] = set5122BurstPeriod(Siglent5122,periodInSec,chann)
            %set5122BurstStateOn(Siglent5122,1, chann);
            command = ['C',num2str(chann),':BTWV PRD,' num2str(periodInSec)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122BurstRise(Siglent5122,time,chann) % sets rise time
            set5122BurstStateOn(Siglent5122,1, chann);
            command = ['C',num2str(chann),':BTWV RISE,' num2str(time)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122BurstDelay(Siglent5122,delay, chann)
            set5122BurstStateOn(Siglent5122,1, chann);
            command = ['C',num2str(chann),':BTWV DLAY,' num2str(delay)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set33220TriggerOutput(Siglent5122,OnOff)
            set5122BurstStateOn(Siglent5122,1, chann);
            if OnOff
                command = 'OUTP:TRIG ON';
            else
                command = 'OUTP:TRIG OFF';
            end
            fprintf(Siglent5122.client,command);
        end

    end
end

