%{
 { createCompositePulse
 { args:
 { rot_angle - length of pulse 1
 { rot_axis - axis of rotation of pulse 1
 { return values:
 { IQ_data - pulse data (will include 4 pulses)
 { markers - 2 marker sets (TWT - defined by offsets, DEF - defined by offsets)
%}
function [IQ_data,markers] = createCompositePulse(amplitude,rot_angle, rot_axis)

global M1_offset_left;        % ns
global M1_offset_right;       % ns
global M2_offset_left;        % ns
global M2_offset_right;       % ns
global M3_offset_left;        % ns
global M3_offset_right;       % ns
global M4_offset_left;        % ns
global M4_offset_right;       % ns
global Composite_pulse_offset; % seconds, delay between pulses in composite pulse
global Pi_pulse_length;        % ns
global Edge_length;            % points
global Sampling_time;          % ns

% pulse shape
angle0 = rot_axis;
delta  = acos(-rot_angle/(4*pi));
angle1 = angle0+delta;
angle2 = angle0+3*delta;
    
rise = 1/2*(1-cos(pi*(.5:(Edge_length-.5))/Edge_length));
fall = 1-rise;
IQ_data_p1 = [rise ones(1,round(rot_angle/pi*Pi_pulse_length/Sampling_time-Edge_length)) fall]*exp(1i*angle0);
IQ_data_p2 = [rise ones(1,round(       pi/pi*Pi_pulse_length/Sampling_time-Edge_length)) fall]*exp(1i*angle1);
IQ_data_p3 = [rise ones(1,round(     2*pi/pi*Pi_pulse_length/Sampling_time-Edge_length)) fall]*exp(1i*angle2);
IQ_data_p4 = [rise ones(1,round(       pi/pi*Pi_pulse_length/Sampling_time-Edge_length)) fall]*exp(1i*angle1);
    
delay1 = round(Composite_pulse_offset/Sampling_time);
delay2 = delay1;
delay3 = delay1;
    
IQ_data = amplitude*[IQ_data_p1 zeros(1,delay1) IQ_data_p2 zeros(1,delay2) IQ_data_p3 zeros(1,delay3) IQ_data_p4];
IQ_length = length(IQ_data);

% Calculate max left and right offsets among four markers
offset_left = max([M1_offset_left M2_offset_left M3_offset_left M4_offset_left]) + 1*Sampling_time;
offset_right = max([M1_offset_right M2_offset_right M3_offset_right M4_offset_right]) + 1*Sampling_time;

% add zeros on the left and right of the IQ shape
IQ_data = [zeros(1,round(offset_left/Sampling_time)) IQ_data zeros(1,round(offset_right/Sampling_time))];

% calculate markers
create_markers;
