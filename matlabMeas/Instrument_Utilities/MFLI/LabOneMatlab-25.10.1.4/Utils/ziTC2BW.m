function bandwidth = ziTC2BW(timeconstant, order)
% ZITC2BW Convert the demod timeconstant to its 3 dB bandwidth
%
% BANDWIDTH = ZITC2BW(TIMECONSTANT, ORDER)
%
% Convert the specified TIMECONSTANT to the equivalent 3dB BANDWIDTH for the
% specified demodulator ORDER.
%
% SEE ALSO ZIBW2TC
  
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

  bandwidth = scale./(2*pi*timeconstant);

end
