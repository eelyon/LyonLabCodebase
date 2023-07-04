function [figText] = genFigText(preamble)
    if preamble contains(preamble,'_')
        preamble = replace(preamble,'_','\_');
    end
    figText = [preamble '_{' num2str(getCurrentFileNum()) '}'];
end

