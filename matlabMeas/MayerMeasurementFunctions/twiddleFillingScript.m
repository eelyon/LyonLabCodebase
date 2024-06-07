
deltaST = 0:-0.01:-0.3;

for delta = deltaST
    display(strcat("Current Delta ",num2str(delta), " Volts"));
loadTwiddleTiff(controlDAC,SR830,22,24,10,11,delta,delta,delta,0);
ejectTwiddleTiff(controlDAC,SR830,22,24,10,11,1,1,1)

end