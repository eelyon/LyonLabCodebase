scanType = 'DR';
currentV = getVal(Door100Device,Door100Port);
finalV = 0;

Sweep;

scanType = 'RS';
currentV = getVal(Res100Device,Res100Port);
finalV = -2;

Sweep;

scanType = 'DR';
currentV = getVal(Door100Device,Door100Port);
finalV = -1;

Sweep;