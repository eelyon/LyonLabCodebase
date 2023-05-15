disp('Programming Agilent #2 (RF pulses)');
io2 = agt_newconnection('tcpip','172.29.19.22');
[a,b,c] = agt_query(io2,'*IDN?');
if(a == -1)
  disp('Large Agilent Not Found');
  return;
end;

%%% Turn the output and modulation OFF
agt_sendcommand(io2, 'OUTP:STAT OFF');
agt_sendcommand(io2, ':SOURce:PULM:STATe OFF');
