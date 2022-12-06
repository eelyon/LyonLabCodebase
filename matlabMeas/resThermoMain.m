%{
Code used for running experiments related to resistive thermometry

Experiments slated to be performed in the big glass dewar

Matt Schulz
%}

addpath(genpath(strcat(pwd, '\instrumentUtilities')));
addpath(genpath(strcat(pwd, '\resThermoHelpers')));
warning('off','all');

port = 1234;

SR830_Address = '172.29.117.106';
SR830 = TCPIP_Connect(SR830_Address, port);

DMM_Address = '172.29.117.107';
DMM = TCPIP_Connect(DMM_Address, port);

AWG_Address = '172.29.117.108';
AWG = TCPIP_Connect(AWG_Address, port);

%data = freqSweep(SR830, 1e3, 10e3, 10, 10);

SR830setAuxOut(SR830,1,1);
pause(2);
SR830setAuxOut(SR830,1,-3);
pause(2);
SR830setAuxOut(SR830,1,5);
pause(2);
SR830setAuxOut(SR830,1,0);
pause(2);

fclose(SR830);
fclose(DMM);
fclose(AWG);