tc = [0.01,0.02,0.03,0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]; % 0.01:0.01:0.5;
v_on = -0.3;
v_off = -0.7;

for value = tc
% [avgx,avgy,stdx,stdy] = MFLISweep1D_poll({'Guard1'},v_on,v_off,(v_off-v_on),'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
%         'filter_order',2,'time_constant',value,'poll_duration',30,'demod_rate',13e3);
%     sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,5,1100); % reset guard
[avgx,avgy,stdx,stdy] = MFLISweep1D_poll({'Guard2'},v_on,v_off,(v_off-v_on),'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
        'filter_order',2,'time_constant',value,'poll_duration',30,'demod_rate',13e3);
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,10,1100); delay(1)

    corrx = avgx-avgx(2);
    corry = avgy-avgy(2);
    corrmag = sqrt(corrx.^2 + corry.^2);
    numE = (cin2*2*sqrt(2) * (corrmag(1)-corrmag(2))) / (1.602e-19*gain2*dalpha);
    
    stdm = sqrt(stdx.^2 + stdy.^2);
    numErr = (cin2*2*sqrt(2) * (stdm(1)+stdm(2))) / (1.602e-19*gain2*dalpha);
%     SNR = numE/numErr
    fprintf(['For tc = ', num2str(value), ', numE = ', num2str(numE), ' +- ', num2str(numErr), '\n']);
end