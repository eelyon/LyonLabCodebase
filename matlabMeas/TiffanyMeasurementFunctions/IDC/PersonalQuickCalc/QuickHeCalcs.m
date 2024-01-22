function [] = QuickHeCalcs()
%% calculations that give a general idea of helium height in channels and
%% how different densities of electrons change that
    % set parameters
    h = 6e-3;              % distance of device from bulk helium that you want
    Vpinch = -0.2;         % pinch off voltage     
    channelDepth = 1.2e-6; % depth of ST channels 
    width = 10e-6;         % width of ST channels
    
    % calculated
    Rc = radiusOfCurv(h);             % radius of curvature with no electrons
    d  = dmin(Rc,width,channelDepth); % height of helium in channels
    
    n = electronDensityST( Vpinch,d ); % density of electrons (1/cm^2)
    
    nc = criticalElectronDensity('fraction', 10e-6); % critical electron density
    Rc_withElectron = radiusOfCurv(h,n);
    d_withElectron  = dmin(Rc_withElectron,width,channelDepth);
    
    fprintf('\n')
    fprintf(['For a channel height of ', num2str(channelDepth), ' you have a helium filling of ', num2str(d), ' with Rc=', num2str(Rc), ' and nc=', num2str(nc*1e-10), 'e10/cm^2', '\n']);
    fprintf(['For a pinch off of ', num2str(Vpinch), ' you have a density of ', num2str(n*1e-9), 'e9/cm^2 with He compression of ', num2str(d_withElectron), ' and Rc=', num2str(Rc_withElectron), '\n'])

% %% calculations of thin vdW film and nc given added He into cell
%     PinHg  = 25;          % added Helium to the cell as read from gauge                 
%     d      = 14.25e-3;    % distance of the device from bottom of cell
%     heFill = heliumFillHeight( PinHg )*1e-3;   % [m], height of He in the cell
%     H      = d - heFill;                       % [m], height of device above Helium
%     h      = vdWThickness( H*1e2 )*1e-9;       % [m], vdW film thickness    
%     nc_thin = criticalElectronDensity('thin', h );
% 
%     fprintf('\n')
%     fprintf(['For ', num2str(30-PinHg), 'inHg of added Helium, you have filled the cell with ', num2str(heFill),'m of He.','\n']);
%     fprintf(['The device is ', num2str(H*1e3), 'mm away from the bulk which gives a vdW film of ', num2str(h*1e9),'nm and nc_thin=',num2str(nc_thin*1e-10),'e10/cm^2 \n']);

end


