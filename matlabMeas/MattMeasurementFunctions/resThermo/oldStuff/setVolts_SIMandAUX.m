%% Set voltages for a specific purpose

%[arrAux, arrSim] = voltsGND();
%[arrAux, arrSim] = voltsEMT();
[arrAux, arrSim] = voltsKEP();
%[arrAux, arrSim] = voltsTST();

dcSetters(arrAux, arrSim, SR830, SIM900);
%dcRampers(arrAux, arrSim, SR830, SIM900);

function [arrAux, arrSim] = arrer(Vtopmetal, Vsense, Vresright, Vresleft, Vfilback, Vgroundplane)
    arrAux = [Vsense, Vgroundplane, Vfilback];
    arrSim = [Vtopmetal, Vresleft, Vresright];
end

function [arrAux, arrSim] = voltsEMT()
    Vtopmetal       = -1;
    Vsense          = 0.0;%-1.0;
    Vresright       = -1.0;
    Vresleft        = -1.0;
    Vfilback        = -0.0;
    Vgroundplane    = -0.0;
    
    [arrAux, arrSim] = arrer(Vtopmetal, Vsense, Vresright, Vresleft, Vfilback, Vgroundplane);
end

function [arrAux, arrSim] = voltsKEP()
    Vtopmetal       = -0.3;
    Vsense          = 0.0;
    Vresright       = -1.5;
    Vresleft        = -1.5;
    Vfilback        = -2.0;
    Vgroundplane    = -1.5;
    
    [arrAux, arrSim] = arrer(Vtopmetal, Vsense, Vresright, Vresleft, Vfilback, Vgroundplane);
end

function [arrAux, arrSim] = voltsTST()
    Vtopmetal       = -4.0;
    Vsense          = -4.0;
    Vresright       = -4.0;
    Vresleft        = -4.0;
    Vfilback        = 0.0;
    Vgroundplane    = -4.0;
    
    [arrAux, arrSim] = arrer(Vtopmetal, Vsense, Vresright, Vresleft, Vfilback, Vgroundplane);
end

function [arrAux, arrSim] = voltsGND()
    Vtopmetal       = 0;
    Vsense          = 0;
    Vresright       = 0;
    Vresleft        = 0;
    Vfilback        = 0;
    Vgroundplane    = 0;
    
    [arrAux, arrSim] = arrer(Vtopmetal, Vsense, Vresright, Vresleft, Vfilback, Vgroundplane);
end

function [] = dcSetters(arrAux, arrSim, SR830, SIM900)
    SR830setBulkAuxOut(SR830,[1, 2, 3],arrAux);
    setBulkSIM900Voltage(SIM900,[1, 2, 3],arrSim);
end

function [] = dcRampers(arrAux, arrSim, SR830, SIM900)
    SR830rampBulkAuxOut(SR830,[1, 2, 3],arrAux);
    rampBulkSIM900Voltage(SIM900,[1, 2, 3],arrSim);
end