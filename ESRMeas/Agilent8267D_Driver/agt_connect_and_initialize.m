global io;

io = agt_newconnection('tcpip','172.29.19.21');
[a,b,c] = agt_query(io,'*IDN?');

if(a == -1)
  disp('Large Agilent Not Found');
  return;
end

%%% Turn OFF 
agt_sendcommand(io, 'OUTP:STAT OFF');
agt_sendcommand(io, ':SOURce:RADio:ARB:STATe OFF');
agt_sendcommand(io, ':OUTPut:MODulation:STATe OFF');
