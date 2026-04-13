CHAN = 1;
AWG = awg2ch_1;

arbName = "SHUTTLE" + num2str(CHAN);   % max 12 chars per manual
arbFile = "INT:\332XX_ARBS\" + arbName + ".arb";

% ------------------------------------------------------------------ %
%  1. Reset and clear volatile memory
% ------------------------------------------------------------------ %
writeline(AWG.client, "*CLS");
writeline(AWG.client, "*RST");
writeline(AWG.client, "DATA:VOL:CLE");
pause(0.5);

% ------------------------------------------------------------------ %
%  2. Byte order: SWAP = little-endian, matches MATLAB/x86 typecast
% ------------------------------------------------------------------ %
writeline(AWG.client, "FORM:BORD SWAP");

% ------------------------------------------------------------------ %
%  3. Validate waveform length
% ------------------------------------------------------------------ %
N = length(YNORM);
if N < 8
    YNORM = [YNORM, zeros(1, 8 - N)];
    fprintf('Padded waveform from %d to 8 samples (minimum).\n', N);
    N = 8;
end
if N > 1048576
    error(['Waveform length %d exceeds 33512B standard limit of 1,048,576 Sa. ' ...
           'Upgrade to MEM option for 16,777,216 Sa.'], N);
end

% ------------------------------------------------------------------ %
%  4. Build and send DATA:ARB:DAC binary command manually
%
%     Format: DATA:ARB:DAC <name>,#<d><byte_count><raw_LE_int16><LF>
%     typecast gives native little-endian bytes (correct for FORM:BORD SWAP)
% ------------------------------------------------------------------ %
fprintf('Uploading %d samples (%.2f MB)...\n', N, N * 2 / 1e6);

y_dac     = int16((YNORM * 2 - 1) * 32767);
raw_bytes = typecast(y_dac, 'uint8');       % little-endian, 2N bytes
num_bytes = numel(raw_bytes);
n_str     = num2str(num_bytes);
d         = numel(n_str);

ascii_hdr = sprintf('DATA:ARB:DAC %s,#%d%s', char(arbName), d, n_str);
full_cmd  = [uint8(ascii_hdr), raw_bytes, uint8(10)];   % uint8(10) = LF

write(AWG.client, full_cmd, "uint8");
pause(1 + N * 2 / 5e6);

% Check error queue immediately after upload
writeline(AWG.client, "SYST:ERR?");
upload_err = readline(AWG.client);
if ~contains(upload_err, "No error")
    warning('Upload error: %s', upload_err);
    return;
end

% ------------------------------------------------------------------ %
%  5. Verify with DATA:VOL:CAT? (correct command per manual)
%     Note: DATA:CAT? does not exist — it returns the non-volatile
%     built-in catalog, which is why previous checks appeared to fail.
% ------------------------------------------------------------------ %
writeline(AWG.client, "DATA:VOL:CAT?");
cat_resp = readline(AWG.client);
fprintf('Volatile catalog: %s\n', cat_resp);
if ~contains(upper(cat_resp), upper(arbName))
    warning('"%s" not found in volatile catalog: %s', arbName, cat_resp);
    return;
end
fprintf('Volatile upload confirmed.\n');

% ------------------------------------------------------------------ %
%  6. Configure channel BEFORE saving (settings baked into .arb file)
% ------------------------------------------------------------------ %
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":FUNC:ARB " + arbName);
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":FUNC:ARB:SRAT " + num2str(SRATE));
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":FUNC ARB");
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":FUNC:ARB:FILT STEP");
writeline(AWG.client, "OUTP" + num2str(CHAN) + ":LOAD INF");
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":VOLT:LOW "  + num2str(VLOW));
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":VOLT:HIGH " + num2str(VHIGH));

% ------------------------------------------------------------------ %
%  9. Burst and trigger
% ------------------------------------------------------------------ %
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":BURS:STAT ON");
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":BURS:MODE TRIG");
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":BURS:NCYC " + num2str(round(NBURST)));
writeline(AWG.client, "TRIG" + num2str(CHAN) + ":SOUR EXT");
writeline(AWG.client, "TRIG" + num2str(CHAN) + ":SLOP POS");

writeline(AWG.client, "OUTP:SYNC:SOUR CHAN1");
writeline(AWG.client, "OUTP:SYNC:MODE NORM");

% ------------------------------------------------------------------ %
%  7. Save volatile -> non-volatile: MMEM:STORe:DATA[1|2] <filename>
% ------------------------------------------------------------------ %
fprintf('Saving to non-volatile: %s\n', arbFile);
writeline(AWG.client, "MMEM:STOR:DATA" + num2str(CHAN) + " """ + arbFile + """");
pause(1);

% Verify in non-volatile arb catalog
writeline(AWG.client, "MMEM:CAT:DATA:ARB? ""INT:\332XX_ARBS\""");
mmem_resp = readline(AWG.client);
if contains(upper(mmem_resp), upper(arbName))
    fprintf('Non-volatile save confirmed: %s\n', arbFile);
else
    warning('Could not confirm non-volatile save. Response: %s', mmem_resp);
end

% ------------------------------------------------------------------ %
%  8. Clear volatile and reload from non-volatile for the channel
% ------------------------------------------------------------------ %
writeline(AWG.client, "DATA:VOL:CLE");
pause(0.3);
writeline(AWG.client, "MMEM:LOAD:DATA" + num2str(CHAN) + " """ + arbFile + """");
pause(0.5);
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":FUNC:ARB " + arbName);
writeline(AWG.client, "SOUR" + num2str(CHAN) + ":FUNC ARB");

% ------------------------------------------------------------------ %
%  10. Output and sync
% ------------------------------------------------------------------ %
writeline(AWG.client, "OUTP" + num2str(CHAN) + " ON");
writeline(AWG.client, "OUTP:SYNC ON");

% ------------------------------------------------------------------ %
%  11. Final error check
% ------------------------------------------------------------------ %
writeline(AWG.client, "SYST:ERR?");
err = readline(AWG.client);
if contains(err, "No error")
    fprintf('Channel %d configuration successful: %s', CHAN, err);
else
    warning('Instrument Error on channel %d: %s', CHAN, err);
end