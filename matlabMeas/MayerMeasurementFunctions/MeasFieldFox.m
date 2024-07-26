%Query FORMATTED data from fieldFox
% Set data format to real-32 bin block transfer
fprintf(SpectrumAnalyzer, 'FORM:DATA REAL,32\n')
fprintf(SpectrumAnalyzer,'CALC:DATA:FDATA?\n')
myBinData = binblockread(SpectrumAnalyzer,'float')
% There will be a line feed not read, i.e. hanging. Read it to clear
%buffer.
% If you do not read the hanging line feed a -410, "Query Interrupted
% Error" will occur
hangLineFeed = fread(SpectrumAnalyzer,1)