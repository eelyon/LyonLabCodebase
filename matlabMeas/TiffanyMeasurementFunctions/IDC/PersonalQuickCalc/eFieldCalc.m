function [pos, eField] = eFieldCalc(dep,pos)
    e = 1.602*1e-19;
    e0 = 8.85e-12;
    z0 = 11e-9;
%     eField = [];
%     for i = 1:50
%         eField(i) = -e/(16*pi*e0)*(0.0277/(z0)^2+(1/(z0+dep(i))^2));
%     end
% 
%     [posdx, dvdx] = derivCalc(dep, pos);
%     pos = pos(1:end-1);
%     dep = dep(1:end-1);
%     eField = (-3.6e-10 .* dvdx./dep.^2);

    [posdx, dvdx] = derivCalc(dep, pos);
    pos = pos(1:end-1);
    dep = dep(1:end-1);
    eField = (-3.6e-10 .* dvdx./(z0+dep).^2)+(0.0277/z0);
end