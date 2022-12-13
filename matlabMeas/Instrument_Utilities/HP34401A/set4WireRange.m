function [] = set4WireRange(Instrument,Range)
% Available rangers are 100, 1000,10000,100000,1000000,10000000,100000000
% (100 ohms to 100 MOhms in powers of 10)
    command = ['CONF:FRES ' num2str(Range)];
    fprintf(Instrument, command);
end