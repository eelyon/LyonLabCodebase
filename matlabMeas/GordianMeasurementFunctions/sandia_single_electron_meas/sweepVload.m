vload = -0.16:0.02:-0.1;

for value = vload
    fprintf(['Vload = ',num2str(value),'V.\n'])
    shuttleElectrons(pinout,'numSteps',5,'numStepsRC',5,'vload',value)
end