function [instrName] = queryIDN(dev)
    instrName = query(dev,'*IDN?');
end