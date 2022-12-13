function [figText] = genFigText(preamble)
    figText = [preamble '_{' num2str(getCurrentFileNum()) '}'];
end

