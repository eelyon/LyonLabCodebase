%{
 { createPulse - creat a square pulse and related markers
 { args:
 { amplitude - pulse amplitude
 { rotating_angle - length of pulse
 { rotating_axis - axis of rotation of pulse
 { return values:
 { IQ_data - pulse data
 { markers - 4 marker sets (M1-M4)
%}
function [IQ_data,markers] = createPulse(amplitude,rot_angle,rot_axis)

global M1_offset_left;        % ns
global M1_offset_right;       % ns
global M2_offset_left;        % ns
global M2_offset_right;       % ns
global M3_offset_left;        % ns
global M3_offset_right;       % ns
global M4_offset_left;        % ns
global M4_offset_right;       % ns
global Pi_pulse_length;       % ns
global Edge_length;           % points
global Sampling_time;         % ns
    
% pulse shape
rise = 1/2*(1-cos(pi*(.5:(Edge_length-.5))/Edge_length));
fall = 1-rise;
center = ones(1,round(rot_angle/pi*Pi_pulse_length/Sampling_time-Edge_length));
IQ_data = amplitude*[rise center fall]*exp(1i*rot_axis);
IQ_length = length(IQ_data);

% Calculate max left and right offsets among four markers
offset_left = max([M1_offset_left M2_offset_left M3_offset_left M4_offset_left]) + 1*Sampling_time;
offset_right = max([M1_offset_right M2_offset_right M3_offset_right M4_offset_right]) + 1*Sampling_time;

% add zeros on the left and right of the IQ shape
IQ_data = [zeros(1,round(offset_left/Sampling_time)) IQ_data zeros(1,round(offset_right/Sampling_time))];

% calculate markers
create_markers;
