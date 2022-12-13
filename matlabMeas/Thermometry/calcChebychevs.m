function [cheb] = calcChebychevs(order,res,coefficient)
    cheb = coefficient*cos(order*acos(calculateKValue(res)));
end
