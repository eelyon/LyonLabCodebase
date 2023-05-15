%{
 { IQ_data - pulse data
 { markers - 2 marker sets (TWT - defined by offsets, DEF - defined by offsets)
%}
function [IQ_data,markers] = createAdiabaticPulse(p_duration, v10, offset0, p_type, theta)

global TWT_offset_left;        % ns
global TWT_offset_right;       % ns
global DEF_offset_left;        % ns
global DEF_offset_right;       % ns
% global Pi_pulse_length;        % ns
% global Edge_length;            % points
global Sampling_time;         % ns

  p_step = Sampling_time;
  p_time = 0:p_step:p_duration;

  % Simulate pulse envelope
  switch(p_type)
     case {'v'}
       p_envelope_I = 0.5 * v10 * (1 - cos(2*pi*p_time/p_duration));
%        n = 20;
%        p_envelope_I = fliplr(v10 * (1 - abs(sin(pi*(p_time/p_duration-1/2))).^n));
     case {'x'}
       p_envelope_I = 0.5 * v10 * (1 - cos(pi*p_time/p_duration));
     case {'w','u'}
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
  p_envelope_Q = 0 * v10 * p_envelope_I;
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
  IQ_data_length = length(IQ_data);

  
    TWT_marker = ones(1,round(TWT_offset_left/Sampling_time));
    DEF_marker = ones(1,round(DEF_offset_left/Sampling_time));
    
    if(TWT_offset_left>DEF_offset_left)
        IQ_data = [zeros(1,round(TWT_offset_left/Sampling_time)) IQ_data];
        DEF_marker = [zeros(1,round((TWT_offset_left-DEF_offset_left)/Sampling_time)) DEF_marker];
    elseif(TWT_offset_left<DEF_offset_left)
        IQ_data = [zeros(1,round(DEF_offset_left/Sampling_time)) IQ_data];
        TWT_marker = [zeros(1,round((DEF_offset_left-TWT_offset_left)/Sampling_time)) TWT_marker];
    else
        IQ_data = [zeros(1,round(DEF_offset_left/Sampling_time)) IQ_data];
    end;
    
    TWT_marker = [TWT_marker ones(1,IQ_data_length)];
    DEF_marker = [DEF_marker ones(1,IQ_data_length)];
    
    TWT_marker = [TWT_marker ones(1,round(TWT_offset_right/Sampling_time))];
    DEF_marker = [DEF_marker ones(1,round(DEF_offset_right/Sampling_time))];
    
    if(TWT_offset_right>DEF_offset_right)
        DEF_marker = [DEF_marker zeros(1,round((TWT_offset_right-DEF_offset_right)/Sampling_time))];
    else
        TWT_marker = [TWT_marker zeros(1,round((DEF_offset_right-TWT_offset_right)/Sampling_time))];
    end;
    
    markers = [TWT_marker;DEF_marker];
    
    if(length(markers)>length(IQ_data))
        IQ_data = [IQ_data zeros(1,length(markers)-length(IQ_data))];
    else
        markers = [markers zeros(2,length(IQ_data)-length(markers))];
    end;
    
    if(mod(length(markers),2))
        markers = [markers [0;0]];
        IQ_data = [IQ_data 0];
    end;
    
    % Add zeroes to make sure the signal/marker goes zero on both ends
    IQ_data = [0 IQ_data 0];
    markers = [zeros(2,1) markers zeros(2,1)];
