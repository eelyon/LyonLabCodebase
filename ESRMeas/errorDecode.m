function [  ] = errorDecode( errorFlag )
  switch errorFlag
    case -1
      fprintf('\nTool failed to output specified voltage.\n');
    case -2
      fprintf('\nCould not identify Tool.\n')
    case -3
      fprintf('\nCommand voltage is equal to current voltage.\n')
  end
end

