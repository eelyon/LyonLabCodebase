close all;
clear all;
clc;

%% Parameters
% The directory in which to replace files. Currently this code does not modify files in
% sub-directories
directory = 'C:\Users\Lyon Lab Simulation\Documents\GitHub\LyonLabCodebase\matlabMeas\GordianMeasurementFunctions\SandiaSingleElectronMeas';
% oldString = sprintf('trap4'); % The string that will be replaced
% newString = sprintf('trap4'); % The replacement string
% The file name condition - what type of files will be examined
% It must contain any of the English character set (letters, numbers or underscore
% character i.e. a-zA-Z_0-9) and ends with a ".m" MATLAB extension (use \.txt for text files)
regularExpression   = '[\w]+\.m';

%% Determine files to update, and update them as necessary
cd(directory) % Change the current directory to the user-specified one
% Put the details of all files and folders in that current directory into a structure
allFilesInDirectory = dir;
% Initialise indexes for files that do and do not contain oldString
filesWithStringIndex = 1;
filesWithoutStringIndex = 1;
% For the number of files and folders in the directory
for idx = 1 : length(allFilesInDirectory)

    % If the file name contains any of the English character set (letters, numbers or
    % underscore character i.e. a-zA-Z_0-9) and ends with a ".m" filetype...
    if (~isempty ( regexp(allFilesInDirectory(idx).name, '[\w]+\.m','match') ))

        fileIdRead  = fopen(allFilesInDirectory(idx).name, 'r'); % Open the file for reading
        fileText = fscanf(fileIdRead,'%c'); % Extract the text
        fclose(fileIdRead); % Close the file
        occurrences = strfind(fileText,oldString); % Search for occurrences of oldString

        % If an occurrence is found...
        if ~isempty(occurrences)

            
            fileTextNew = strrep(fileText, oldString, newString); % Replace any occurrences of oldString with newString
            fileIdWrite = fopen(allFilesInDirectory(idx).name, 'w'); % Open the file for writing
            fprintf(fileIdWrite, '%c', fileTextNew); % Write the modified text
            fclose(fileIdWrite); % Close the file
            filesWithString{filesWithStringIndex} = allFilesInDirectory(idx).name; % Update the list of files that contained oldString
            filesWithStringIndex = filesWithStringIndex + 1; % Update the index for files that contained oldString

        else
            % Update the list of files that did not contain oldString
            filesWithoutString{filesWithoutStringIndex} = allFilesInDirectory(idx).name;

            % Update the index for files that did not contain oldString
            filesWithoutStringIndex = filesWithoutStringIndex + 1;

        end
    end
end
%% Display what files were changed, and what were not
% If the variable filesWithString exists in the workspace
if exist('filesWithString','var')
    disp('Files that contained the target string that were updated:');
    % Display their names
    for i = 1:filesWithStringIndex-1, disp(filesWithString{i}); end
else
    disp('No files contained the target string');
end
% Insert a clear line between lists
disp(' ');
% If the variable fileWithoutString exists in the workspace
if exist('filesWithoutString','var')
    disp('Files that were not updated:');
    % Display their names
    for j = 1:filesWithoutStringIndex-1, disp(filesWithoutString{j}); end
else
    disp('All files contained the target string.');
end