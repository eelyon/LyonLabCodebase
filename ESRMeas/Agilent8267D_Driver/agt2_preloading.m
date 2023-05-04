%% AGILENT #2 (E8257D) PRELOADING

% Connect to Agilent
agt2_connect_and_initialize;

% RF frequency and output power in Agilent #2
agt_sendcommand(io2, 'SOURce:FREQuency 65165000'); % 104710000 (28SiAs) 104.78MHz (nSiAs)
agt_sendcommand(io2, 'POWer -9.2');  
% if fed directly from 8257 to AR amp, then use -9dBm with 10us RF pulse for 28Si:As`(104.71 MHz)
%                                  however, use +1dBm if fed through the combiner box
% Amplifier AR 500A250A has a gain of 60dB (at 100%) 
% Agilent output power should be set to below -7dBm
% For donor line 52.36MHz and 20us RF pulse, the optimum is -13dBm at 75%.

agt2_gated_mode;
