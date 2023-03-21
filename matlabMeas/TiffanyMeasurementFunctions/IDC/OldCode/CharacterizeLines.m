numports = 35;
Cs = zeros([numports numports]); 
Rs = zeros([numports numports]); 
% for i = 1:numports-1
%     for j = i+1:numports  
 for i = 35
     for j = 1:34 
        input([num2str(i) ',' num2str(j) ':\n']);
        RC
        Cs(i,j) =  C;
        Cs(j,i) =  C;      
        Rs(i,j) =  R;
        Rs(j,i) =  R; 
        fprintf('\n')
        
    end
end

