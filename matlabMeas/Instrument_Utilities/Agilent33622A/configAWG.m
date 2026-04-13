function [] = configAWG(AWG, CHAN, YNORM, SRATE, VLOW, VHIGH, NBURST)
    % % --- 5. Upload and Configure ---
    % command = ['SOUR',num2str(CHAN),':FUNC ', type];
    % fprintf(Awg2CHAN_1,['SOUR',num2str(CHAN),':FUNC ', type]);
    
    % awgIP = '172.29.117.62';
    % visaAddress = sprintf('TCPIP0::%s::inst0::INSTR', awgIP);
    % awg2CHAN_3.client = visadev(visaAddress);
    % awg3_Address = '172.29.117.62';
    % awg2CHAN_3 = Agilent33622A(1234,awg3_Address,1);
    
    AWG.client.ByteOrder = "big-endian";
    
    writeline(AWG.client, "*CLS"); % Clear status and error queue
    writeline(AWG.client, "*RST"); % Reset instrument
    writeline(AWG.client, "DATA:VOL:CLE");
    
    % Convert to DAC values (-32767 to +32767)
    y_dac = int16((YNORM*2 - 1) * 32767);
    writebinblock(AWG.client, y_dac, "int16", "SOURCE"+num2str(CHAN)+":DATA:ARB:DAC SHUTTLE"+num2str(CHAN)+", ");
    pause(1);
    
    writeline(AWG.client, "SOUR"+num2str(CHAN)+":FUNC:ARB SHUTTLE" + num2str(CHAN));
    writeline(AWG.client, "SOUR"+num2str(CHAN)+":FUNC:ARB:SRAT " + num2str(SRATE));
    writeline(AWG.client, "SOUR"+num2str(CHAN)+":FUNC ARB");
    writeline(AWG.client, "SOUR"+num2str(CHAN)+":FUNC:ARB:FILT STEP"); % Pulse optimised filter
    writeline(AWG.client, "OUTP"+num2str(CHAN)+":LOAD INF");
    writeline(AWG.client, "SOUR"+num2str(CHAN)+":VOLT:LOW " + num2str(VLOW));
    writeline(AWG.client, "SOUR"+num2str(CHAN)+":VOLT:HIGH " + num2str(VHIGH));
    % writeline(AWG.client, "SOUR"+num2str(CHAN)+":VOLT " + num2str(4));
    % writeline(AWG.client, "SOUR"+num2str(CHAN)+":VOLT:OFFS " + num2str(1));
    
    % Trigger Setup: Play the whole sequence once per trigger
    writeline(AWG.client, "SOUR"+num2str(CHAN)+":BURS:STAT ON");
    writeline(AWG.client, "SOUR"+num2str(CHAN)+":BURS:MODE TRIG");
    writeline(AWG.client, "SOUR"+num2str(CHAN)+":BURS:NCYC " + num2str(NBURST)); % We treat the entire 79-pulse array as 1 cycle

    % writeline(AWG.client, "TRIG" + CHAN + ":SOUR BUS");
    writeline(AWG.client, "TRIG" + CHAN + ":SOUR EXT");
    writeline(AWG.client, "TRIG" + CHAN + ":SLOP POS")

    writeline(AWG.client, "OUTP" + CHAN + " ON");
    writeline(AWG.client, "OUTP:SYNC:SOUR CH1");
    writeline(AWG.client, "OUTP:SYNC:MODE NORM"); % Pulse at start of Arb
    writeline(AWG.client, "OUTP:SYNC ON");
    
    writeline(AWG.client, "SYST:ERR?");
    err = readline(AWG.client);
    if contains(err, "No error")
        fprintf('Configuration successful: %s', err);
    else
        warning('Instrument Error: %s', err);
    end
end