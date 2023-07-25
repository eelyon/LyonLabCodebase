function [newFigNum] = getNextMATLABFigNum()
h = findobj('type','figure');
if isempty(h)
    newFigNum = 1;
else
    checkArr = 1;
    newFigNum = get(h(checkArr),'Number') + 1;
    while ishandle(newFigNum)
        checkArr = checkArr + 1;
        newFigNum  = get(h(checkArr),'Number') + 1;
    end
end
end

