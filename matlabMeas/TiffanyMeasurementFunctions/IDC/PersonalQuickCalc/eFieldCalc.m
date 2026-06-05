function [pos, eField] = eFieldCalc(dep,pos)
    [posdx, dvdx] = derivCalc(dep, pos);
    pos = pos(1:end-1);
    dep = dep(1:end-1);
    eField = -3.6e-10 .* dvdx./dep.^2;
end