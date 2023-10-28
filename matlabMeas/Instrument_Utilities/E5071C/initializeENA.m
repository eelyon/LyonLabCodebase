port = 5025;
ipAddress = '172.29.117.72';
ENA = TCPIP_Connect(ipAddress,port);
ENA.InputBufferSize = 32000;