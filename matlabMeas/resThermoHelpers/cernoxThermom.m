classdef cernoxThermom
    properties
        ZL;
        ZU;
        A;
    end
    methods
        function ct = cernoxThermom(ZL, ZU, A)
            ct.ZL = ZL;
            ct.ZU = ZU;
            ct.A = A;
        end

        function k = kval(obj, R)
            k = ((log10(R) - obj.ZL) - (obj.ZU - log10(R))) / (obj.ZU - obj.ZL);
        end

        function T = temp(obj, R)
            argint = cos((0:(length(obj.A) - 1)) * acos(kval(obj, R)));
            T = sum(obj.A .* argint);
        end
    end
end