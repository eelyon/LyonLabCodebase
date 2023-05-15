% calculate markers for CreatePulse, CreateCompositePulse and CreateAdiabaticPulse

M1_marker = [zeros(1,round((offset_left-M1_offset_left)/Sampling_time)) ones(1,round(M1_offset_left/Sampling_time))];
M2_marker = [zeros(1,round((offset_left-M2_offset_left)/Sampling_time)) ones(1,round(M2_offset_left/Sampling_time))];
M3_marker = [zeros(1,round((offset_left-M3_offset_left)/Sampling_time)) ones(1,round(M3_offset_left/Sampling_time))];
M4_marker = [zeros(1,round((offset_left-M4_offset_left)/Sampling_time)) ones(1,round(M4_offset_left/Sampling_time))];

M1_marker = [M1_marker ones(1,IQ_length)];
M2_marker = [M2_marker ones(1,IQ_length)];
M3_marker = [M3_marker ones(1,IQ_length)];
M4_marker = [M4_marker ones(1,IQ_length)];

M1_marker = [M1_marker ones(1,round(M1_offset_right/Sampling_time)) zeros(1,round((offset_right-M1_offset_right)/Sampling_time))];
M2_marker = [M2_marker ones(1,round(M2_offset_right/Sampling_time)) zeros(1,round((offset_right-M2_offset_right)/Sampling_time))];
M3_marker = [M3_marker ones(1,round(M3_offset_right/Sampling_time)) zeros(1,round((offset_right-M3_offset_right)/Sampling_time))];
M4_marker = [M4_marker ones(1,round(M4_offset_right/Sampling_time)) zeros(1,round((offset_right-M4_offset_right)/Sampling_time))];
    
%%%% Never ever uncomment this line (only used to measure high MW pulses directly): M2_marker = zeros(1, length(M2_marker));
markers = [M1_marker; M2_marker; M3_marker; M4_marker];
    
if (mod(length(markers),2))
   markers = [markers [0;0;0;0]];
   IQ_data = [IQ_data 0];
end;
