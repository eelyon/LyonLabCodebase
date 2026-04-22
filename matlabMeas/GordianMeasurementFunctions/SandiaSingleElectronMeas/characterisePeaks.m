for i = 1:10
    loadSense1(pinout,-0.16,'vhigh',0.5,'vlow',-0.5)
    measureElectronsFn(pinout,1,'vstart',0.1,'vstop',-0.8,'vstep',0.01,'filter_order',2,'time_constant',0.5)
end