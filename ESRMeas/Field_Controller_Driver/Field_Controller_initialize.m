%Connect to field controller address GPIB-04
global ER032M;

ER032M = instrfind('Type', 'gpib', 'BoardIndex', 1, 'PrimaryAddress', 2, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(ER032M)
    ER032M = gpib('NI', 1, 2);
else
    fclose(ER032M);
    ER032M = ER032M(1);
end;

% Connect to instrument object, ER032M.
fopen(ER032M);

% Set initial parameters
fprintf(ER032M, ['CF' num2str(B0_center)]);
fprintf(ER032M, ['SW' num2str(B0_sweep_width)]);
