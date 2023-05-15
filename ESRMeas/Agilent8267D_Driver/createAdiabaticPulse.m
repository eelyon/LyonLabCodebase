function [IQ_data,markers] = createAdiabaticPulse(p_duration, v10, offset0, p_type, theta)

global M1_offset_left;        % ns
global M1_offset_right;       % ns
global M2_offset_left;        % ns
global M2_offset_right;       % ns
global M3_offset_left;        % ns
global M3_offset_right;       % ns
global M4_offset_left;        % ns
global M4_offset_right;       % ns
global Sampling_time;         % ns

p_step = Sampling_time;
p_time = 0:p_step:p_duration;

% Simulate pulse envelopes
  switch(p_type)
     case {'v'} % simple pi pulse (two versions: "simplest" and "sin20")
       p_envelope_I = 0.5 * v10 * (1 - cos(2*pi*p_time/p_duration));
%        n = 20;
%        p_envelope_I = fliplr(v10 * (1 - abs(sin(pi*(p_time/p_duration-1/2))).^n));
     case {'x'} % simple pi/2 pulse
       p_envelope_I = 0.5 * v10 * (1 - cos(pi*p_time/p_duration));
     case {'w','u'} % BIR4 pulses (two versions: "sin20" and "???")
       p_time = 0:p_step:p_duration/4;
%        zeta = 10;
%        p_envelope_I = v10 * tanh(zeta*(1 - 4*p_time/p_duration));
%           flipped = fliplr(p_envelope_I); flipped = flipped(2:length(flipped));
%        p_envelope_I = [p_envelope_I flipped p_envelope_I(2:length(p_envelope_I)) flipped];
       n = 20;
       p_envelope_I = fliplr(v10 * (1 - abs(sin(pi*(p_time/(p_duration/2)-1/2))).^n));
          flipped = fliplr(p_envelope_I); flipped = flipped(2:length(flipped));
       p_envelope_I = [p_envelope_I flipped p_envelope_I(2:length(p_envelope_I)) flipped];
  end;
  p_envelope_Q = zeros(1,length(p_envelope_I));
  p_envelope = p_envelope_I + 1i*p_envelope_Q;
  
% Simulate pulse modulation
  % for "v" and "w" pulses: p_mod_freq = (-1 + 2*p_time/p_duration);
  % for "x" pulse: p_mod_freq = (-1 + p_time/p_duration);
  switch(p_type)
     case {'v'}
       p_mod_phase = 2*pi*offset0*(-p_time + p_time.^2/p_duration);
     case {'x'}
       p_mod_phase = 2*pi*offset0*(-p_time + 0.5*p_time.^2/p_duration);
     case {'w','u'}
%        kappa = atan(20);
%        p_mod_phase = - 2*pi*offset0*p_duration/(4*kappa*tan(kappa)) * log(cos(4*kappa*p_time/p_duration));
%          flipped = fliplr(p_mod_phase); flipped = flipped(2:length(flipped));
%        p_mod_phase = [p_mod_phase flipped+(pi+theta/2) p_mod_phase(2:length(p_mod_phase))+(pi+theta/2) flipped];
       p_mod_phase = fliplr(2*pi*offset0*(p_duration/8 - p_time + p_time.^2/(p_duration/2)));
         flipped = fliplr(p_mod_phase); flipped = flipped(2:length(flipped));
       p_mod_phase = [p_mod_phase flipped+(pi+theta/2) p_mod_phase(2:length(p_mod_phase))+(pi+theta/2) flipped];
  end;
  p_mod = exp(1i*p_mod_phase);
 
  IQ_data = p_envelope .* p_mod;
  IQ_length = length(IQ_data);

% Calculate max left and right offsets among four markers
offset_left = max([M1_offset_left M2_offset_left M3_offset_left M4_offset_left]) + 1*Sampling_time;
offset_right = max([M1_offset_right M2_offset_right M3_offset_right M4_offset_right]) + 1*Sampling_time;

% add zeros on the left and right of the IQ shape
IQ_data = [zeros(1,round(offset_left/Sampling_time)) IQ_data zeros(1,round(offset_right/Sampling_time))];

% calculate markers
create_markers;
