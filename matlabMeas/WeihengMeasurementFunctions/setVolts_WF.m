function setVolts_WF(DAC, backing, backing_voltage, top_metal, top_metal_voltage, gates_no_st, gates_no_st_voltage, gates_st, gates_st_voltage)
    % setvolt_WF - Sets voltages for specified gates with ramping
    %
    % Syntax:  setVolts_WF(DAC, backing, backing_voltage, top_metal, topmetal_voltage, 
    %                     gates_no_st, gates_nost_voltage, gates_st, gatesst_voltage)
    %
    % Inputs:
    %    DAC - DAC object used for voltage control
    %    backing - Array of backing electrode pins
    %    backing_voltage - Voltage for backing electrodes
    %    top_metal - Array of top metal pins
    %    topmetal_voltage - Voltage for top metal
    %    gates_no_st - Array of non-ST gate pins
    %    gates_nost_voltage - Voltage for non-ST gates
    %    gates_st - Array of ST gate pins
    %    gatesst_voltage - Voltage for ST gates
    %
    % Example:
    %    setVolts_WF(myDAC, [15], -1.5, [6], -0.7, [1,2,3,4,5,7,8,9,10,11], -3, [12,16,14], 0)
    %
    % Other m-files required: sigDACRampVoltage
    % Subfunctions: none
    % MAT-files required: none
    
    % Apply voltages with ramping
    sigDACRampVoltage(DAC, backing, backing_voltage, 200);
    sigDACRampVoltage(DAC, top_metal, top_metal_voltage, 200);
    
    % Apply voltages to all non-ST gates
    for i = 1:length(gates_no_st)
        sigDACRampVoltage(DAC, gates_no_st(i), gates_no_st_voltage, 200);
    end
    
    % Apply voltages to all ST gates
    for i = 1:length(gates_st)
        sigDACRampVoltage(DAC, gates_st(i), gates_st_voltage, 200);
    end
end