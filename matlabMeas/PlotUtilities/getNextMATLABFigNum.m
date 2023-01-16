function [figNum] = getNextMATLABFigNum()
% Returns the next available MATLAB figure number for plotting purposes.
    figNum = get(gcf,'Number') + 1;
end

