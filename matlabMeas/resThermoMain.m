%{
Code used for running experiments related to resistive thermometry

Experiments slated to be performed in the big glass dewar

Matt Schulz
%}

port = 1234;

SR830_Address = '172.29.117.106';
SR830 = TCPIP_Connect(SR830_Address, port);

DMM_Address = '172.29.117.107';
DMM = TCPIP_Connect(DMM_Address, port);

AWG_Address = '172.29.117.108';
AWG = TCPIP_Connect(AWG_Address, port);