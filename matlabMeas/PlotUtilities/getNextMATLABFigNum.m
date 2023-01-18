function [newFigNum] = getNextMATLABFigNum()
h = findobj('type','figure');
if isempty(h)
    newFigNum = 1;
else
    newFigNum = get(gcf,'Number') + 1;
end
end

