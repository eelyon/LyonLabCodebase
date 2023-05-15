function create_load_pulse(p,amplitude)

if (p.pulse(3))
  [IQ_data,markers] = createCompositePulse(amplitude,p.pulse(1),p.pulse(2));
else
  [IQ_data,markers] = createPulse(amplitude,p.pulse(1),p.pulse(2));
end;

agt_load_pulse(IQ_data, p.name, markers);
