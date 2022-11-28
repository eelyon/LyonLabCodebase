function [] = SR830setTau(Instrument,tau)
    command = ['OFLT ' num2str(SR830tauToInd(tau))];
    fprintf(Instrument,command);
end