%% Script for sweeping the top metal negative to get rid of electrons
for i = 1:5
    sweep1DMeasSR830({'TM'},-0.65,-1.5,0.05,1,9,{SR830Twiddle},TM.Device,{TM.Port},1,1);
end