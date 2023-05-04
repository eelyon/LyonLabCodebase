function Agilent_Globals()
    % global variables
    global M1_offset_left;        % ns
    global M1_offset_right;       % ns
    global M2_offset_left;        % ns
    global M2_offset_right;       % ns
    global M3_offset_left;        % ns
    global M3_offset_right;       % ns
    global M4_offset_left;        % ns
    global M4_offset_right;       % ns
    global Composite_pulse_offset; % ns, delay between pulses in composite pulse
    
    global Pi_pulse_length;        % ns
    global Edge_length;            % points
    global Clock_frequency;        % Hertz
    global Sampling_time;          % ns
    
    % adiabatic pi/2 and pi pulses
    global p1u_duration;
    global p1w_duration;
    
    % B413: Comtech P6IN diode (NEGATIVE)Diode on signal arm (bolted to aluminum plate)
    M1_offset_left = 320; % (should be longer by 100ns than M2_offset_left)
    M1_offset_right = 10100;%5100;%4000; % (should be longer by 100ns than M2_offset_right)

    % B413: Hittite switch (POSITIVE)switch at the bottom of the cryostat
    % Adjust according to Q-factor (for example, set 1000 for Q=1500 and 1500 for Q=3000)
    M2_offset_left = 220;      
    M2_offset_right = 10000;%5000;%3500;
    % B413: RF blanking (POSITIVE) internal to the agilent vector source.
    M3_offset_left = 200;      
    M3_offset_right = 200;     

    % B124: AR pin diode negative at the front of the amplifier (big TWT or solid state 20W)
    M4_offset_left = 300;
    M4_offset_right = 200;

    % Remember of the 60 point requirement (each waveworm should be longer than 600 ns)
    % There is a general requirement for each waveform to be at least 60 points or longer
    
    Composite_pulse_offset = 10;     % ns 
    Pi_pulse_length =  1500;           % ns
    Edge_length = 1;                 % [in points] must be 1 or larger
    
    
    Clock_frequency = 100e6;         % 100 MHz is maximum
    Sampling_time = 1e9/Clock_frequency; % 10 ns is minimum
    
    p1u_duration = 10000;             % pi/2 (ns) %%lowered by factor of 10
    p1w_duration = 10000;             % pi (ns)   %%lowered by factor of 10
  