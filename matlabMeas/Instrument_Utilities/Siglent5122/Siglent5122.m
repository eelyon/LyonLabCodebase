classdef Siglent5122
    % Siglent5122 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        USBAddress
        client
        identifier
    end

    methods
        function Siglent5122 = Siglent5122(USBAddress)
            Siglent5122.USBAddress    = USBAddress;
            Siglent5122.client        = USB_Connect(USBAddress);
            Siglent5122.identifier    = '5122';
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

        function [] = set5122OutputLoad(Siglent5122,type) 
            validTypes = '50,HZ';
            if ~contains(validTypes,type)
                fprintf('Valid function types for the 5122 are:\n');
                fprintf([validTypes '\n'])
            else
                command = ['C1:OUTP LOAD, ', type];
                fprintf(Siglent5122.client,command);
            end
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

        function [] = set5122BurstTriggerSource(Siglent5122,burstTrigger)
            validTypes = 'EXT,INT,MAN';
            if ~contains(validTypes,burstTrigger)
                fprintf('Invalid burst trigger source, valid types are:\n');
                fprintf(validTypes);
            else
                command = ['C1:BTWV TRSR, ' burstType];
                fprintf(Siglent5122.client,command);
            end
        end

        function [] = set5122BurstStateOn(Siglent5122,onOrOff)
            if onOrOff
                command = 'C1:BTWV STATE,ON';
            else
                command = 'C1:BTWV STATE,OFF';
            end

            fprintf(Siglent5122.client,command);
        end

        function [] = set5122Output(Siglent5122,OnOff)
            if OnOff
                cmdStr = 'ON';
            else
                cmdStr = 'OFF';
            end
            command = ['C1:OUTP ' cmdStr];
            fprintf(Siglent5122.client,command);
        end


        function [] = set33220TriggerOutput(Agilent33220A,OnOff)
            if OnOff
                command = 'OUTP:TRIG ON';
            else
                command = 'OUTP:TRIG OFF';
            end
            fprintf(Agilent33220A.client,command);
        end
       
    end
end

