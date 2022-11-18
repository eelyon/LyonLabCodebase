function [] = SR830setFreq(Instrument,freq)
    if freq < .001 || freq > 102000
        fprintf(['Desired SR830 frequency ' num2str(freq) ' out of range (.001->102000Hz)']);
    else
        command = ['FREQ ' num2str(freq)];
        fprintf(Instrument,command);
    end
end

