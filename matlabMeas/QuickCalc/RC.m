function [] = RC( Device )    
    
    R = (-SR830queryX(Device)/SR830queryAmplitude(Device))^-1;
    C = (-SR830queryY(Device)/SR830queryAmplitude(Device)/2/pi/SR830queryFreq(Device));
    fprintf('R = %2.3e \nC = %2.3e \n',R,C)

end