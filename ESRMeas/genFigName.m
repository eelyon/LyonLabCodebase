function [ figName ] = genFigName(figPreamble)
  figName = [figPreamble '\_' num2str(getCurrentFileNum(getDataPath()))];
end

