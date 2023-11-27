PinHg  = 16;    % added Helium to the cell                 
d      = 6.5e-3;    % distance of the device from bottom of cell
heFill = heliumFillHeight( PinHg )*1e-3;   % [m], height of He in the cell
H      = d - heFill;                       % [m], height of device above Helium
h      = vdWThickness( H*1e2 )*1e-9;       % [m], vdW film thickness
Rc     = radiusOfCurv( H );                % [m]

criticalElectronDensity( 'thin', h )
criticalElectronDensity( 'fraction', 10e-6 )