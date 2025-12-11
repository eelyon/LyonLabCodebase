function [posdx, dvdx] = derivCalc( dep, pos )
    dvdx = [];
    posdx = [];
    dx = abs(pos(1) - pos(2));  % delta x basically
    invdx = 1 / dx;
    length(pos)
    for j = 1:1:(length(pos)-1)
        i = j+1 ; % the actual index of the derivative when correlated with the original vector
        posdx = [posdx pos(i)];
        dvdx = [dvdx ((dep(i) - dep(i - 1))*invdx)];  % loops through since delta y changes
    end
end