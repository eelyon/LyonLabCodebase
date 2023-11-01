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
            SDG5122.client        = USB_Connect(USBAddress);
            SDG5122.identifier    = '5122';
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

        % voltage = str2double(query(sigDAC.client,'VOLT?'));

        function imp = get5122OutputLoad(SDG5122, chann) 
            imp = str2double(query(SDG5122.client,['C',num2str(chann),':OUTP LOAD?']));
        end

        function [] = set5122VoltageHigh(Siglent5122,amp_high) % sets high level of C1
            command = ['C1:BSWV HLEV,' num2str(amp_high)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122VoltageLow(Siglent5122,amp_low) % sets low level of C1
            command = ['C1:BSWV LLEV,' num2str(amp_low)];
            fprintf(Siglent5122.client,command);
        end
        
        function [] = set5122Rise(Siglent5122,time) % sets rise time
            command = ['C1:BSWV RISE,' num2str(time)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122Period(Siglent5122,periodInSec) 
            command = ['C1:BSWV PERI,' num2str(periodInSec)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122PulseWidth(Siglent5122,pulseWidthInSec)  % sets the pulse width (s)
            command = ['C1:BSWV WIDTH,' num2str(pulseWidthInSec)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122NumBurstCycles(Siglent5122, numCycles) % set num of cycles to burst
            command = ['C1:BTWV TIME, ' num2str(numCycles)];
            fprintf(Siglent5122.client,command);
        end

        function [] = set5122Delay(Siglent5122,delay) 
            command = ['C1:BTWV DLAY,' num2str(delay)];
            fprintf(Siglent5122.client,command);
        end

        

        function [] = set5122FunctionType(Siglent5122,type) 
            validTypes = 'SINE,SQUARE,RAMP,PULSE,NOISE,ARB,DC,PRBS';
            if ~contains(validTypes,type)
                fprintf('Valid function types for the 5122 are:\n');
                fprintf([validTypes '\n'])
            else
                command = ['C1:BSWV WVTP, ', type];
                fprintf(Siglent5122.client,command);
            end            
        end
       
    end
end
