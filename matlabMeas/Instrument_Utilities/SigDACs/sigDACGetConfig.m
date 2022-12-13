function [sigDACConfig] = sigDACGetConfig(instrument,numChannels)
    sigDACConfig = strings(1,numChannels+1);
    sigDACConfig(1) = 'sigDAC Channel Voltages (V)';

    for i = 1:numChannels
        sigDACConfig(i+1) = num2str(sigDACQueryVoltage(instrument,i));
    end
    
end

