function [] = SR830setAmplitude(Instrument, amplitude)
    % 2 mV precision (rounds to closest 2mV). Range of .004 to 5V

    if amplitude < .004 || amplitude > 5
        fprintf(['Desired SR830 amplitude ' num2str(amplitude) ' out of range (.004V -> 5V)'] )
    else
        command = ['SLVL ' num2str(amplitude)];
        fprintf(Instrument,command);
    end
end

