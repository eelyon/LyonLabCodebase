function [calvoltList] = calibratedAP24Volt(channels,voltages)

Folder = 'TiffanyMeasurementFunctions\IDC\CalibrateDac\AP24\';
calvoltList = zeros(1,numel(voltages));
ctr = 1;

for i=1:length(voltages)
    channel = channels(i);
    load([Folder 'CH' num2str(channel) '.mat']);
    value = voltages(i);
    vRange = -9.8:0.7:9.8;
    new = interp1(vRange, vRange*m+b, value);
    newVolt = (value-new)+value;
    convert = num2str(newVolt,'%.3f');
    convertback = str2double(convert);
    calvoltList(ctr) = convertback;
    ctr = ctr+1;
end

end