

 DotLoadingScheme

for n = 0:9
    scanType = 'ST'
    Sweep;
    V = 2-n*0.2:-.025:1.9-n*0.2;
    scanType = 'SW'
    Sweep;
end
