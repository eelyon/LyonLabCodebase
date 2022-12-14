classdef cernoxThermom
    properties
        % all properties listed below are in the datasheet provided in the
        % calibrated thermometer.
        ZL;
        ZU;
        chebychevCoefficients;
        lookUpRes;
        lookUpTemp;
    end

    methods
        function ct = cernoxThermom(ZL, ZU, chebychevCoefficients,lookUpTemp,lookUpRes)
            ct.ZL = ZL;
            ct.ZU = ZU;
            ct.chebychevCoefficients = chebychevCoefficients;
            ct.lookUpRes = lookUpRes;
            ct.lookUpTemp = lookUpTemp;
        end
        
        function T = tempFromRes(obj,resistance)
            if resistance <= obj.lookUpRes(length(obj.lookUpRes))
                T = tempFromLookUpTable(obj,resistance);
            else
                T = tempFromResChebychev(obj,resistance);
            end
        end

        function k = calculateKValue(obj, resistance)
            k = ((log10(resistance) - obj.ZL) - (obj.ZU - log10(resistance))) / (obj.ZU - obj.ZL);
        end
        
        function T = tempFromResChebychev(obj, resistance)
            % Function calculates the temperature using the chebychev
            % equation/coefficients provided by the datasheet. 
            chebychevArray = cos((0:(length(obj.chebychevCoefficients) - 1)) * acos(calculateKValue(obj, resistance)));
            T = sum(obj.chebychevCoefficients .* chebychevArray);
        end

        function T = tempFromLookUpTable(obj,resistance)
            % To connect all the resistances and temperatures, we need to 
            % use the look up tables given in the datasheets. For
            % resistances less than the lookup resistance we can linearly
            % interpolate what their temperature is.

            % loop through the lookupresistance table. We'll have a break
            % to break out of the for loop when we find the index of the resistance 
            % that's larger than our current resistance. Start at 2 to 
            % ensure no index out of bounds error.
            for i = 2: length(obj.lookUpRes)
                currRes = obj.lookUpRes(i);
                
                % if the resistance in the array is larger than our current
                % resistance value, create a linear interpolation between
                % the previous and current look up table value and
                % associate it with a temperature. Break after finished.
                if currRes > resistance
                    currTempHigh = obj.lookUpTemp(i-1);
                    currTemp = obj.lookUpTemp(i);
                    currResHigh = obj.lookUpRes(i-1);
                    slope = (currTempHigh - currTemp)/(currResHigh - currRes);
                    T = slope*(resistance-currRes) + currTemp;
                    break;
                end
            end
        end

    end
end