repeatNums = 10;
for i = 1:repeatNums
rampVal(supplyDAC,19,-2,0.25,0.05,0.05);
% open Door
sweep1DMeasSR830({'Door'},-1,0.25,0.05,1,1,{SR830Twiddle},controlDAC,{1},0,1);
% open CCDDoor
%sweep1DMeasSR830({'CCDdoor'},-2,0,0.05,1,9,{SR830Twiddle},supplyDAC,{19},0,1);
rampVal(supplyDAC,22,-2,-3,0.05,0.05);
rampVal(controlDAC,18,0,-3,0.05,0.05);
rampVal(controlDAC,6,0,-3,0.05,0.05);
delay(10);
display("Closing Door")
rampVal(controlDAC,1,0.25,-2,0.05,0.05);
delay(10);
% close Door
rampVal(supplyDAC,22,-3,-2,0.05,0.05);
rampVal(controlDAC,18,-3,0,0.05,0.05);
sweep1DMeasSR830({'Shield'},-3,0,0.05,1,1,{SR830Twiddle},controlDAC,{6},0,1);
% close CCD Door
%sweep1DMeasSR830({'CCDdoor'},0,-2,0.05,1,9,{SR830Twiddle},supplyDAC,{19},0,1);
rampVal(supplyDAC,19,0.5,-2,0.05,0.05);
% interleaved CCD Ramp
CCD_SetVals;
CCD_SetVals;
% Repeat

end
