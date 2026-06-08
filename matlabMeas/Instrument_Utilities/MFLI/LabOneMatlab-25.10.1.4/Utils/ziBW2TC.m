function timeconstant = ziBW2TC(bandwidth, order)
% ZIBW2TC Convert the demod 3 dB bandwidth to its timeconstant
%
% TIMECONSTANT = ZIBW2TC(BANDWIDTH, ORDER)
%
% Convert the specified 3 dB bandwidths in BANDWIDTH to its equivalent
% TIMECONSTANT for the specified demodulator ORDER.
% 
% SEE ALSO ZITC2BW
  
  scale = 0.0;
  switch order
    case 1
      scale = 1.0;
    case 2
      scale = 0.643594;
    case 3
      scale = 0.509825;
    case 4
      scale = 0.434979;
    case 5
      scale = 0.385614;
    case 6
      scale = 0.349946;
    case 7
      scale = 0.322629;
    case 8
      scale = 0.300845;
    otherwise
      error('Error: Order (%d) must be between 1 and 8!\n', order);
  end

  timeconstant= scale./(2*pi*bandwidth);

end
