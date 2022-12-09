%{
Code used for running experiments related to resistive thermometry

Experiments slated to be performed in the big glass dewar

Matt Schulz
%}

addpath(genpath(strcat(pwd, '\instrumentUtilities')));
addpath(genpath(strcat(pwd, '\resThermoHelpers')));
warning('off','all');

port = 1234;

SR830_Address = '172.29.117.103';
SR830 = TCPIP_Connect(SR830_Address, port);
tauSR = 30 * 1e-3;
SR830setTau(SR830, tauSR);

DMM_Address = '172.29.117.104';
DMM = TCPIP_Connect(DMM_Address, port);

AWG_Address = '172.29.117.108';
AWG = TCPIP_Connect(AWG_Address, port);

timeMult = 10 * tauSR;

%data1 = freqSweep(SR830, 1e3, 10e3, 3, 1, timeMult);
data2 = auxSweep(SR830, 1, -10, 10, 10, 1, timeMult);

fclose(SR830);
fclose(DMM);
fclose(AWG);