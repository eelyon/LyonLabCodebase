function [] = resThermoSweep(SDG5122, SR830, amp, freqi, freqo, deltafreq, shots)
    set5122ModAmp(SDG5122, amp, 1);
    set5122ModAmp(SDG5122, amp, 2);

    basilSens = SR830querySensitivityArrNum(SR830);
    maxSense = 26;

    freqs = freqi:freqo:deltafreq;
    for freq = freqs
        SR830setSensitivity(SR830, maxSense);
        pause(3);
        set5122Output(SDG5122, 0, 1);
        set5122Output(SDG5122, 0, 2);

        set5122ModFreq(SDG5122, freq, 1);
        set5122ModFreq(SDG5122, freq, 2);

        set5122Output(SDG5122, 1, 1);
        set5122Output(SDG5122, 1, 2);
        pause(3);
        SR830setSensitivity(SR830, basilSens);
        sweep1DMeasSR830({'TMHeat'},-0.0,-0.0,1,10,shots,{SR830},SR830,{'1'},0);
    end
end