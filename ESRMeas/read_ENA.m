function [my_data] = read_ENA(handle)
%READ_ENA Pulls the trace from the ENA
%   Issues:
%   1)buffer size of 65000 might be too long

%The buffer size is increased here to accomodate 1601 sweep points
fclose(handle);
set(handle, 'InputBufferSize',650000);
set(handle, 'Timeout', 30);
fopen(handle);

%Read the data from ENA
fprintf(handle,':CALC1:DATA:FDAT?;'); %write formatted data to buffer
data_buffer=fscanf(handle, '%19E %1s %19E %1s', [4 3201]);
my_data=data_buffer(1,:);

fclose(handle);
set(handle, 'InputBufferSize',20000);
fopen(handle);


end