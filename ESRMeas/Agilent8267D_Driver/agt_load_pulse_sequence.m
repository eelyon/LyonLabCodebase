function agt_load_pulse_sequence(sequence,sequenceName)

global io;

% Waveform names for pi/2 pulses along (+x,+y,-x,-y) = (p0a,p0b,p0c,p0d)
p0a_name = 'p0a';
p0b_name = 'p0b';
p0c_name = 'p0c';
p0d_name = 'p0d';

% Waveform names for pi pulses along (+x,+y,-x,-y) = (p11,p12,p13,p14)
p11_name = 'p11';  
p12_name = 'p12';
p13_name = 'p13';
p14_name = 'p14';

% Waveform name for adiabatic pi pulses = ("p1v" for up, and "p1w" for down)
p1v_name = 'p1v';
p1w_name = 'p1w';
p0x_name = 'p0x';
p0u_name = 'p0u';

    tmpStr = '';
    for counter=1:length(sequence)
        num = sequence(counter);
        switch(num)
            case 'a'
                tmpStr = [tmpStr '"WFM1:' p0a_name '",1,ALL,'];
            case 'b'
                tmpStr = [tmpStr '"WFM1:' p0b_name '",1,ALL,'];
            case 'c'
                tmpStr = [tmpStr '"WFM1:' p0c_name '",1,ALL,'];
            case 'd'
                tmpStr = [tmpStr '"WFM1:' p0d_name '",1,ALL,'];
            case '1'
                tmpStr = [tmpStr '"WFM1:' p11_name '",1,ALL,'];
            case '2'
                tmpStr = [tmpStr '"WFM1:' p12_name '",1,ALL,'];
            case '3'
                tmpStr = [tmpStr '"WFM1:' p13_name '",1,ALL,'];
            case '4'
                tmpStr = [tmpStr '"WFM1:' p14_name '",1,ALL,'];
            case '5'
                tmpStr = [tmpStr '"WFM1:' p15_name '",1,ALL,'];
            case '6'
                tmpStr = [tmpStr '"WFM1:' p16_name '",1,ALL,'];
            case '7'
                tmpStr = [tmpStr '"WFM1:' p17_name '",1,ALL,'];
            case '8'
                tmpStr = [tmpStr '"WFM1:' p18_name '",1,ALL,'];
            case 'e'
                tmpStr = [tmpStr '"WFM1:' p1e_name '",1,ALL,'];
            case 'v'
                tmpStr = [tmpStr '"WFM1:' p1v_name '",1,ALL,'];
            case 'w'
                tmpStr = [tmpStr '"WFM1:' p1w_name '",1,ALL,'];
            case 'x'
                tmpStr = [tmpStr '"WFM1:' p0x_name '",1,ALL,'];
            case 'u'
                tmpStr = [tmpStr '"WFM1:' p0u_name '",1,ALL,'];
                
            case {'0',' '}  % for delays
        end
    end
    
    tmpStr = tmpStr(1:end-1); % remove extra comma at the end
    tmpStr = [':SOUR:RAD:ARB:SEQ "SEQ:' sequenceName '",' tmpStr];
    
    disp(['Load pulse sequence: ' sequenceName]);
    [status, status_description] = agt_sendcommand(io, tmpStr); 
    if (status ~= 0)
      disp(['Error loading the sequence: ' sequenceName ', ' status_description]);
      return;
    end;
    disp('Done loading pulse sequence');

