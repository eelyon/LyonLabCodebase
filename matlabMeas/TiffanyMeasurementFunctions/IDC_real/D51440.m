function [ T] = D51440( V )
p = [-87151.4039239664,-28396.3930991652,3885.94403532575,1897.50078051804,32.5161296281322,-40.0834299628288,-6.21529478267457,1.96118986093596];
V = log10(V);
    T = 0;
    j = length(p)-1;
    for pj = p
      T = T + pj.*(V.^j);
      j = j - 1;
    end
    T = 10.^T;
end