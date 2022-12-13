tic
%% Options

tScaleE = 'ms';
tScaleC = 'ms';

needToemit = 1;
doorOpens = 2;
numRepeated = 1;
Fullwait = 3;
DCMap;


for TauC = 1
    for TauE = 1
        if needToemit
            fprintf(VpulsC,['PULS:WIDT' ' ' num2str(TauC) ' ' tScaleC])
            fprintf(VpulsE,['PULS:WIDT' ' ' num2str(TauE)  ' ' tScaleE])
            %fprintf(VpulsE,['VOLT:HIGH' ' ' num2str(0)])

            DCConfigs2Tau('Emitting')

            input('Flashed?:\n')        

            DCConfigs2Tau('Transfer')

            pause(Fullwait)
        end
        
        Extra = ['BeforeTauE' num2str(TauE) tScaleE]
        V          = 0:-0.1:-1;
        CheckDensities
        
        pause(Fullwait)
        
        for index = 1:numRepeated
            for i = 1:doorOpens
                fprintf(VpulsE,'TRIG')
                pause(Fullwait)
                
                Extra = ['ElectrOnsTowardsCollector']
                V          = 0:-0.1:-1;
                CheckDensities
                
                %setVal(TopCDevice,TopCPort,-2);
                setVal(TfCDevice,TfCPort,-1);
                pause(1)
                fprintf(VpulsE,'TRIG')
                pause(1)
                setVal(TfCDevice,TfCPort,6);
                %setVal(TopCDevice,TopCPort,BiasC-4);
                pause(1)
            end
            
            Extra = ['ElectronsBackToEmitter']
            V          = 0:-0.1:-1;
            CheckDensities
        end
    end
end

toc

