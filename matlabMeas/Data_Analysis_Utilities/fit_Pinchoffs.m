ft = fittype('a + b*normcdf(x,mu,sig)','indep','x')

ft(a,b,mu,sig,x) = a + b*normcdf(x,mu,sig);
Fopts = fitoptions(ft);
Fopts.Lower = [-1 0 15 .1];
Fopts.Upper = [1 2 16 3];
Fopts.StartPoint = [0 1 15.2 1];
mdl = fit(xavg_40s1',havg_40s1',ft,Fopts);

     mdl(x) = a + b*normcdf(x,mu,sig)
     %Coefficients (with 95% confidence bounds):
       a =    5.2*10^(-10)  
       b =       0.9*10^(-10) 
       mu =       0.05 
       sig =         0.01  
plot(mdl)
hold on
plot(xPinch{32},yPinch{32},'.')