DMM1_Address = '172.29.117.107';
DMM2_Address = '172.29.117.108';
vSource_Address = '172.29.117.132';

DMM1 = TCPIP_Connect(DMM1_Address,1234);
DMM2 = TCPIP_Connect(DMM2_Address,1234);
vSource = SPD330(vSource_Address,1234);