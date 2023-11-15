function [] = freqChanger(SDG5122, freq)
    set5122ModFreq(SDG5122, freq, 1);
    set5122ModFreq(SDG5122, freq, 2);
end