%% Linear fit for DAC calibration
%% generates m,b value to AP24 folder, use to calibrate any voltage

Folder = 'CalibrateDac\VoltSweepFiles';

a = dir([Folder '/*.mat']);
num = size(a,1);  % runs code for number of files in folder

for i = 1:num
    File = sprintf('CH%i.mat',i);
    S = dir(fullfile(Folder,File));

    v = load([Folder '/' File]);
    voltArr = cell2mat(struct2cell(v));

    vRange = -9.8:.49:9.8;
    P = polyfit(vRange,voltArr,1);
    m = P(1);
    b = P(2);
    Folder2 = 'TiffanyMeasurementFunctions\IDC\CalibrateDac\AP24\';
    filename = [Folder2 'CH' num2str(i) '.mat'];
    save( filename, 'm','b' );
end