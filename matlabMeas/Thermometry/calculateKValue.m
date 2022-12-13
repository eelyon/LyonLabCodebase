function [kValue] = calculateKValue(resistance)
    kValue = (2*log10(resistance)-2.68491328511-3.88972245339)/(3.88972245339-2.68491328511);
end