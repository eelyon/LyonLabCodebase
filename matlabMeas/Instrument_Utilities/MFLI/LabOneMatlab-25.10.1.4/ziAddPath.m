function ziAddPath
% ZIADDPATH add the LabOne Matlab drivers and utilities to Matlab's Search Path
%
% USAGE:
% ziAddPath();

% Get the name of the current function complete with full path
mfile = which(mfilename);
[pathstr, name] = fileparts(mfile);
driverPath = [pathstr filesep 'Driver'];
utilsPath = [pathstr filesep 'Utils'];
if isdir(driverPath) && isdir(utilsPath)
    addpath(driverPath);
    addpath(utilsPath);
    dbs = dbstack;
    % If ziAddPath was called directly in Matlab output some help, otherwise output nothing.
    if strcmp(dbs(end).name, 'ziAddPath')
        fprintf('Added ziDAQ''s Driver and Utilities directories to Matlab''s path\n')
        fprintf('for this session.\n\n');
        fprintf('To make this configuration persistent across Matlab sessions either:\n\n')
        fprintf('1. Run the ''pathtool'' command in the Matlab Command Window and add the\n')
        fprintf('   following paths WITH SUBFOLDERS to the Matlab search path:\n\n')
        fprintf('   %s\n', pathstr);
        fprintf('\nor\n\n');
        fprintf('2. Add the following line to your Matlab startup.m file:\n');
        fprintf('\n');
        fprintf('   run(''%s%s%s'');\n\n', pathstr, filesep, name);
        fprintf('\n');
        fprintf('See the LabOne Programming Manual for more help.\n');
    end
else
    fprintf('Error: ''Driver'' and ''Utils'' are not subfolders of\n');
    fprintf('%s\n', pathstr);
    fprintf('where ''%s'' is located: Not adding paths.\n', name);
end
