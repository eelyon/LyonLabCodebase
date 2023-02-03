function [] = RC( Device )    
    
    R = (-str2num(query(Device,'OUTP?1'))/str2num(query(Device,'SLVL?')))^-1;
    C = (-str2num(query(Device,'OUTP?2'))/str2num(query(Device,'SLVL?'))/2/pi/str2num(query(Device,'FREQ?')));
    fprintf('R = %2.3e \nC = %2.3e \n',R,C)

end