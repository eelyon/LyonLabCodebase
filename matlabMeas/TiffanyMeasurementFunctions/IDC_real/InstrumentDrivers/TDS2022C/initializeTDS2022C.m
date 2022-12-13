function [ eScope ] = initializeTDS2022C(USB)
    obj1 = instrfind('Type', 'visa-usb', 'RsrcName', USB, 'Tag', '');
    
    if isempty(obj1)
        obj1 = visa('NI', USB);
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
        fopen(obj1);
        eScope = obj1;
        fclose(eScope);
        eScope.InputBufferSize = (100000 * 2 + 100) * 2*8;
        fopen(eScope);    
end
