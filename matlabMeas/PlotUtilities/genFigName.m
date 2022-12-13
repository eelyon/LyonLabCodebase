function [figName] = genFigName(preamble)
    figName = [preamble '_' num2str(getCurrentFileNum()) ''];
end

