function agt_load_standard_pulses2(sequence)

% global variables
global p1u_duration;           % ns
global p1w_duration;           % ns

  composite1 = 0;
  composite2 = 0;
  coeff1 = 1;
  coeff2 = 1; %%%%%
  amplitude = 1;  % Pulse amplitude, the same for all square pulses

  defined_pulses = 'abcd1234';
  
  % pi/2 pulses along (+x,+y,-x,-y) = (p0a,p0b,p0c,p0d)
  % each pulse is [rot_angle rot_axis composite]
  p(1).pulse = [pi/2*coeff1   0     composite1];     p(1).name = 'p0a';
  p(2).pulse = [pi/2*coeff1   pi/2  composite1];     p(2).name = 'p0b';
  p(3).pulse = [pi/2*coeff1   pi    composite1];     p(3).name = 'p0c';
  p(4).pulse = [pi/2*coeff1 3*pi/2  composite1];     p(4).name = 'p0d';

  % pi pulses along (+x,+y,-x,-y) = (p11,p12,p13,p14)
  % each pulse is [rot_angle rot_axis composite]
  p(5).pulse = [pi*coeff2   0     composite2];     p(5).name = 'p11';
  p(6).pulse = [pi*coeff2   pi/2  composite2];     p(6).name = 'p12';
  p(7).pulse = [pi*coeff2   pi    composite2];     p(7).name = 'p13';
  p(8).pulse = [pi*coeff2 3*pi/2  composite2];     p(8).name = 'p14';

% Create and load pulses. 
disp('Loading square pulses');

for ip = 1:length(defined_pulses)
  if any(defined_pulses(ip) == sequence) > 0 % check if given pulse (ip) is used in the "sequence"
     create_load_pulse2(p(ip),amplitude); % create and load the pulse in case it is used
  end;
end;

disp('Done loading square pulses');

%% ADIABATIC PULSES
  % OUR ORIGINAL DEFINITION (sin for B1/linear for offset)
  p1v_name = 'p1v'; % pi pulse (AFP)
%   p1w_duration = 10000; % pulse duration (in ns)
  v10 = 1; % max B1 field (Agilent units)
  offset0 = 2; % Initial offset (in MHz)
  [p1v_IQ_data,p1v_markers] = createAdiabaticPulse(p1w_duration, v10, offset0/1e3,'v',0);

  p0x_name = 'p0x'; % pi/2 pulse (AHP)
%   p1u_duration = 10000; % pulse duration (in ns)
  v10 = 1; % max B1 field (Agilent units)
  offset0 = 2; % Initial offset (in MHz)
  [p0x_IQ_data,p0x_markers] = createAdiabaticPulse(p1u_duration, v10, offset0/1e3,'x',0);

  c_adiabatic = 1.0; % Coefficient used to change rotating angle of pi(w) pulse. Used in Rabi experiments.
  
  % BIR4 pulses with arbitrary rotation angle
  % The sin20 definition, BIR4 option as in JMR v.94, p.511-525 (1991) - see equations [3-5] and [7-14]
  p1w_name = 'p1w'; % pi pulse
  v10 = 1; % max B1 field (Agilent units)
  offset0 = 2; % Initial offset (in MHz)
  theta = pi * c_adiabatic; % Desired rotation angle **********************************************
  [p1w_IQ_data,p1w_markers] = createAdiabaticPulse(p1w_duration, v10, offset0/1e3,'w',theta);
  p1w_IQ_data = p1w_IQ_data * exp(1i*pi/2);

  p0u_name = 'p0u';  % pi/2 pulse
  v10 = 1; % max B1 field (Agilent units)
  offset0 = 2; % Initial offset (in MHz)
  theta = pi/2; % Desired rotation angle
  [p0u_IQ_data,p0u_markers] = createAdiabaticPulse(p1u_duration, v10, offset0/1e3,'u',theta);

%   agt_load_pulse(p1v_IQ_data, p1v_name, p1v_markers);
%   agt_load_pulse(p0x_IQ_data, p0x_name, p0x_markers);

  agt_load_pulse2(p1w_IQ_data, p1w_name, p1w_markers);
  agt_load_pulse2(p0u_IQ_data, p0u_name, p0u_markers);
        
