function [xVals,yVals] = generate_Gaussian(mu,sigma)

xVals  = linspace(-180,180,3700);
yVals = [];
for i = 1:length(xVals)
    yVals(i) = 1/(sigma*sqrt(2*pi))*exp(-(((xVals(i)-mu)/sigma)^2)*1/2);
end

end