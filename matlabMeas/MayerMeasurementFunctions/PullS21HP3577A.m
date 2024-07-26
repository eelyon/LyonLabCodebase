% Find a GPIB object.
NetworkAnalyzer = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 11, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(NetworkAnalyzer)
    NetworkAnalyzer = gpib('NI', 0, 11);
else
    fclose(NetworkAnalyzer);
    NetworkAnalyzer = NetworkAnalyzer(1);
end

NetworkAnalyzer.InputBufferSize = 10000;
NetworkAnalyzer.OutputBufferSize = 10000;

% Connect to instrument object, obj1.
fopen(NetworkAnalyzer);
