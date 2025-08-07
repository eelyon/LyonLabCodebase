function emission_WF(DAC, Filament_backing, Top_metal, Gates_no_st, Gates_st)
    % emission_WF - Sets up voltage configuration for emission
    %
    % Syntax:  emission_WF(DAC)
    %
    % Inputs:
    %    DAC - DAC object used for voltage control
    %
    % Example:
    %    emission_WF(myDAC)
    
    % Define voltage settings for emission
    backing_voltage = -1.5;
    gates_voltage = -3;
    st_voltage = 0;
    tm_voltage = -0.7;
    
    % Use the more general setvolt_WF function
    setVolts_WF(DAC, Filament_backing, backing_voltage, Top_metal, tm_voltage, ...
              Gates_no_st, gates_voltage, Gates_st, st_voltage);
end