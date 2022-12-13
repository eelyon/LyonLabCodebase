function [T] = lookUpTable(res,thermometerType)
    [tempCal,resistanceCal] = getLookUpTables(thermometerType);
    
    if res > 505 && res < 529
        T = 14.75;
    else
        for i = 1: length(resistanceCal)
            currRes = resistanceCal(i);
            if currRes > res
                currTempLow = tempCal(i);
                currTempHigh = tempCal(i+1);
                currResHigh = resistanceCal(i+1);
                slope = (currTempHigh - currTempLow)/(currResHigh-currRes);
                T = slope*(res-currRes) + currTempLow;
                break;
            end
        end
    end
end
