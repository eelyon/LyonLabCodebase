numpointsarr = linspace(5,100,20);

for numpoints = numpointsarr
    sweep1DMeasSR830Fast({'ST'},-0.0,-0.04,0.01,1,numpoints,{SR830},DAC,{7},1);
    sweep1DMeasSR830({'ST'},-0.0,-0.04,0.01,1,numpoints,{SR830},DAC,{7},1);
end