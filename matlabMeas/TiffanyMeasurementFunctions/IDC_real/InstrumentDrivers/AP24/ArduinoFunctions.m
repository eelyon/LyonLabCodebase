
% NOTE: having a ; at the end of the line suppresses the output 

query(AP24,'')      % clear buffer

query(AP24,'*IDN?')
query(AP24,'CH?')
query(AP24,'VOLT?')
query(AP24,'TEST')

query(AP24, 'ZERO') % outputs words not sure why query doesn't fix it, still get things in buffer
query(AP24, ['ZERO ' num2str([2])])

query(AP24,['MVOLT ' num2str([1,0])])
query(AP24,['MVOLT? ' num2str(1)])

% outputs words not sure why query doesn't fix it, still get things in
% buffer, this is because there's multiple outputs in the buffer...
fprintf(AP24,['RAMP ' num2str([2,2,[1,2],2,[2,4]])])

fprintf(AP24,['DOOR ' num2str([2,1,2,4,2,0,2,0,2,0,0,10,20])])
fprintf(AP24,['RAMP ' num2str([5,2,[2,5],2,[1,2]])])

fprintf(AP24, 'INIT')
fprintf(AP24, 'VERBOSE')
