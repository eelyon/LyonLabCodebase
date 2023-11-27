PinHg = 16;
d = 6.5e-3; % distance of device from bottom of cell
heFill = heliumFillHeight( PinHg )*1e-3; % [m]
H = d - heFill;  % height of device above Helium [m]
h = vdWThickness( H*1e2 )*1e-9;  % [m]
Rc = radiusOfCurv( H ); %[m]

criticalElectronDensity( 'thin', h )
criticalElectronDensity( 'fraction', 10e-6 )