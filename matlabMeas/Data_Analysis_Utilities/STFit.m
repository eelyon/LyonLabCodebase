function mdl = STFit(dataX,dataY)
% STFit fits the Sommer Tanner data using a normcdf function. It returns a
% plotable object (via plot()) which is the output of the fitting. To get
% good fits, ensure that the lower and upper bounds of a,b,mu, and sigma (y
% intercept, scale, center of pinchoff, and standard deviation) are good.
% Having a decent starting point is also beneficial for good fits.
%
% NOTE: yData must be > 1 for fit to work well, scale your data properly!
%
% Inputs: datax - array containing the x data for ST pinchoff.
%         datay - array containing the y data for ST pinchoff.
%         yScale - the scale of the data (nA = 1e-9, uA = 1e-6, etc...)
%         startX - the first xData point.
    ft = fittype('a + b*normcdf(x,mu,sig)','indep','x');
    Fopts = fitoptions(ft);
    [lowerBounds,upperBounds,startPoints] = genSTFitParams(dataX,dataY);
    Fopts.Lower = lowerBounds;
    Fopts.Upper = upperBounds;
    Fopts.StartPoint = startPoints;
    mdl = fit(dataX',dataY',ft,Fopts);
end


function [lowerBounds,upperBounds,startPoints] = genSTFitParams(dataX,dataY)
    % Helper function generates start points, lower bounds, and upper
    % bounds for Sommer Tanner fits.

    % Find the y intercepts. Assume that a pinchoff exists. High lock-in
    % signals occur at voltages close to 0 while low lock-in signals (stray
    % capacitance) happen at lower voltages.
    yMin = dataY(length(dataY));
    yMax = dataY(1);
    lowA = yMin - .05;
    highA = yMin + .05;
    
    % Find the delta in the max and min values.
    bVal = yMax - yMin;
    lowB = bVal - .05;
    highB = bVal + .05;
    
    % Find the search area for the center of the pinchoff transition.
    % Create a bound that captures the center of the pinchoff region.
    maxPercentage = yMin/yMax;
    transitionPercentage = maxPercentage*.1;
    transitionHigh = yMax - bVal*transitionPercentage;
    transitionLow = yMin + bVal*transitionPercentage;
    foundHighTrans = 0;
    foundLowTrans = 0;
    for i = 1:length(dataY)
        if dataY(i) < transitionHigh && foundHighTrans == 0
            highTransX = dataX(i);
            foundHighTrans = 1;
        elseif dataY(i) < transitionLow && foundLowTrans == 0
            lowTransX = dataX(i);
            foundLowTrans = 1;
        end
    end
    centerTrans = (highTransX + lowTransX)/2;
    startTransitionDelta = lowTransX - highTransX;

    % Create the lower, upper, and starting point arrays.
    lowerBounds = [lowA,lowB,lowTransX,0];
    upperBounds = [highA,highB,highTransX,.1];
    startPoints = [yMin,bVal,centerTrans,startTransitionDelta];
end
