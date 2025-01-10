function [] =  test(startVoltage,sign)
%UNTITLED19 Summary of this function goes here
%   Detailed explanation goes here

numSteps=1000;
if strcmp(sign,'Pos')
    step = startVoltage:-0.5:0.5;
    for i = 1:length(step)
        volt = step(i);
        doorOutVolt = volt-1.5;
        thinFilmVolt = 1.5; %getVal(controlDAC,TfVolt);
        if doorOutVolt > thinFilmVolt - 0.7
            doorOutVolt = thinFilmVolt - 0.7; 
        else
        end
        disp('these are the ST voltages')
        disp(volt-0.5)
        disp('these are Drin, twid/sense, Drout Voltages')
        disp([volt-1.5,volt-0.5,volt-0.5,doorOutVolt]);
        disp('this is the top voltage')
        disp(1.8-(0.5*i));
    end
else
    step = startVoltage:0.5:-0.5;
    for i = 1:length(step)
        volt = step(i);
        disp('these are the ST voltages')
        disp(volt+0.5);
        disp([volt-0.5,volt+0.5,volt+0.5,volt-0.5]);
        disp(-3.2+(0.5*i));
    end
end
end