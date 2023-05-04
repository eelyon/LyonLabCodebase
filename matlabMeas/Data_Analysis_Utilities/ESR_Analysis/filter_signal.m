function retSignal = filter_signal(sTime, sSig, cutoffHz)
   d = fdesign.lowpass('Fp,Fst,Ap,Ast',cutoffHz,cutoffHz+5e6,0.5,40,1/(sTime(2)-sTime(1)));
   Hd = design(d,'equiripple');
   retSignal = filter(Hd,sSig);
end