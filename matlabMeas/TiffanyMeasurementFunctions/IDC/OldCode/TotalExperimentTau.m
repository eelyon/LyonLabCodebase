tic
%% Options

tScaleE = 'us';
tScaleC = 'us';

needToCleanTF = 0;
needToClean = 0;
needToUpdateTimes = 1;
needToemit = 1;
doorOpens = 1;
numRepeated = 1;
Fullwait = 3;
numberOfFlashes = 5;
DCMap;

for TauE = 200
    for TauC = 200
        
        if needToemit

            DCConfigDAC(AP24,'Emitting', 10);
            input('Flashed?')               
            if needToClean
                vPort0 = DCConfigDAC(AP24,'TransferBack', 10);
                pause(Fullwait)
                sigDACdoor(sigDAC,vPort0,500,500);
                pause(Fullwait)
    
                DCConfigDAC(AP24,'Emitting', 10);
                input('Flashed?')
            end

            for c = 1:numberOfFlashes
                fprintf(Filament, 'TRIG:SOUR BUS; *TRG');
                pause(1)
                disp('flash!');
            end    

            pause(Fullwait)

            vPort = DCConfigDAC(AP24,'Transfer', 10);
            disp('done transfer config')
            pause(Fullwait)
        end
               
        Extra = ['BeforeTauE' num2str(TauE) tScaleE]
        V          = 0:-0.1:-1;
        DoubleSweep
        
        pause(Fullwait)
        TopCVoltage = getVoltAP24(AP24,TopCPort);
        for index = 1:numRepeated
            doorAP24(AP24,vPort,TauE,TauC);
            
            pause(Fullwait)
            pause(Fullwait)
            
            fprintf('\n')
  
            
            Extra = ['AfterTauE' num2str(TauE) tScaleE];
            V          = [0:-0.02:-.2 -.3:-.2:-1.5];
            DoubleSweep

            vPort1 = DCConfigDAC(AP24,'TransferBack',20);
            pause(Fullwait)
            sigDACdoor(sigDACdoor,vPort1,5000,5000);
            Extra = 'AfterTransferBack';
            V          = [0:-0.02:-.2 -.3:-.2:-1.5];
            DoubleSweep
        end
    end
end

toc

