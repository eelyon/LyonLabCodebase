
n = [10 1 10 20 30 50 80 100 1000 0.1 5 200 0.5 0.01];  % first one doesnt count

for i = n
    DCConfigDAC(DAC,'FlipTransfer1',8000);
    pause(8)
    
    DCConfigDAC(DAC,'FlipTransfer',8000);
    pause(8)
        
    DCConfigDAC(DAC,'FlipTransferBack1',10000);
    pause(10)
    
    DCConfigDAC(DAC,'FlipTransferBack2',10000);
    pause(10)
    
    DCConfigDAC(DAC,'FlipTransferBack',10000);
    pause(10)
    
    sigDACRampVoltage(DAC,STOBiasEPort,-3.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,StmEPort,-3.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasEPort,-3.5,1000)
    pause(1)
    sigDACRampVoltage(DAC,STOBiasEPort,-3.3,1000)
    pause(1)
    sigDACRampVoltage(DAC,StmEPort,-3.3,1000)
    pause(1)
    sigDACRampVoltage(DAC,STIBiasEPort,-3.3,1000)
    pause(1)
    

    DCConfigDAC(DAC,'FlipEmit',8000);
    pause(8)
    disp('hi')
    
end


