function [settling_time] = ziFO2ST(timeconstant,order,varargin)
%ZIFO2ST Returns settling times of lock in filter
%   Input time constant, filter order, and percentage of signal
% Default = 99%
% Scaling is from https://www.zhinst.com/sites/default/files/li_primer/zi_whitepaper_principles_of_lock-in_detection.pdf
p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
% Filter order
p.addParameter('percent', 99, isnonneg);
% Filter time constant
p.parse(varargin{:});
percent = p.Results.percent;

if percent == 99
    switch order
        case 1
          scale = 4.61;
        case 2
          scale = 6.64;
        case 3
          scale = 8.41;
        case 4
          scale = 10.05;
        case 5
          scale = 11.60;
        case 6
          scale = 13.11;
        case 7
          scale = 14.57;
        case 8
          scale = 16.00;
        otherwise
          error('Error: Order (%d) must be between 1 and 8!\n', order);
    end
elseif percent == 99.9
    switch order
        case 1
          scale = 6.91;
        case 2
          scale = 9.23;
        case 3
          scale = 11.23;
        case 4
          scale = 13.06;
        case 5
          scale = 14.79;
        case 6
          scale = 16.45;
        case 7
          scale = 18.06;
        case 8
          scale = 19.62;
        otherwise
          error('Error: Order (%d) must be between 1 and 8!\n', order);
    end
end

settling_time = scale.*timeconstant;
end

