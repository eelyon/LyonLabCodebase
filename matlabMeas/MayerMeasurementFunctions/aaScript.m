PotBiases = 2:.5:3;
for bias = PotBiases
    STMags = sweepMeasSR830_Func('ST',0,-0.3,-0.025,.1,5,SR830,DAC,{8},1);
    if STMags(1) > backgroundSignal + 1e-10
        electronsLoaded = 1;
        disp('electrons detected');
    else
        electronsLoaded = 0;
        disp('electrons not detected in ST')
    end

    for i = 1:7
        cleanTM;
    end

    if electronsLoaded
        sweepDotDelta;
    else
        for i = 1:7
            cleanTM
        end
    end
    
    ejectionProtocol
    STMags = sweepMeasSR830_Func('ST',0,-0.1,-0.0025,.3,40,SR830,DAC,{8},1);
    if STMags(1) > backgroundSignal + 1e-10
        electronsLoaded = 1;
        disp('electrons detected');
    else
        electronsLoaded = 0;
        disp('electrons not detected in ST, changing dot potential bias.')
    end

    if electronsLoaded
        for i = 1:7
            ejectionProtocol
        end
         STMags = sweepMeasSR830_Func('ST',0,-0.1,-0.0025,.3,40,SR830,DAC,{8},1);
    end
    DPBias = bias;
    DotLoadingProtocol;
end
