%% fit_Cin_ltspice.m
% Fits Cin in an LTspice netlist to an MFLI frequency sweep saved as a .fig.
% - Reads frequency, amplitude and phase straight from the .fig
% - Rewrites the .ac line so LTspice simulates exactly the measured frequencies
% - Rewrites ".param Cin=...", runs LTspice in batch mode, minimizes the misfit
% Requires MATLAB R2016b+ (local functions in scripts).

% clear; clc;

%% ---- User settings ------------------------------------------------------
ltspiceExe = 'C:\Users\Lyon Lab Simulation\AppData\Local\Programs\ADI\LTspice\LTspice.exe';     % check your install path
workDir    = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\LTSpice\ampifier_roll_off_bfc_20261002';   % folder with template + .inc files
ascFile    = 'roll_off_circuit_bfc_20261002.asc';              % schematic; netlist is regenerated from it
template   = '';                                               % or set a saved .net here and ascFile = ''
dataDir = 'C:\Users\Lyon Lab Simulation\Princeton Dropbox\Gordian Fuchs\GroupDropbox\Gordian\Experiments\Sandia2023\SingleElectronSensingShuttling\data_single_electron_shuttling\02_20_26';
figFile    = 'MFLIFreqSweep_23935.fig';                        % lock-in sweep (in workDir)
outNode    = 'V(out)';

CinBounds_pF   = [2 15];   % search range for Cin (pF)
Vin_pp         = 2e-3;       % drive amplitude (Vpp), same units as the lock-in amplitude
fitFreeGain    = true;       % true: also fit a constant gain factor (e.g. an amplifier
                             %       not in the LTspice model); false: absolute fit

%% ---- Load measured data -------------------------------------------------
if ~isfile(figFile), figFile = fullfile(dataDir, figFile); end   % accept full path or name in workDir
[fMeas, ampMeas] = loadMFLIfig(figFile);
Hmeas = ampMeas / Vin_pp;                                  % measured voltage gain (V/V)
acLine = buildAcLine(fMeas);
fprintf('Measured: %d points, %.4g Hz to %.4g Hz\nUsing: %s\n', ...
        numel(fMeas), min(fMeas), max(fMeas), strtok(acLine, newline));

%% ---- Prepare a local simulation folder (outside Dropbox) ---------------
% Cloud-sync tools lock files while uploading, which makes LTspice fail at
% random. All runs happen in a local temp folder instead.
if ~isfile(ltspiceExe)
    error(['LTspice not found at:\n  %s\nLTspice 24 often installs per-user under\n' ...
           '  %%LOCALAPPDATA%%\\Programs\\ADI\\LTspice\\LTspice.exe'], ltspiceExe);
end
if ~isempty(ascFile)
    system(sprintf('"%s" -netlist "%s"', ltspiceExe, fullfile(workDir, ascFile)));
    template = strrep(ascFile, '.asc', '.net');
end
if ~isfile(fullfile(workDir, template))
    error('Template netlist "%s" not found in %s', template, workDir);
end
simDir = fullfile(tempdir, 'ltspice_fit');
if ~isfolder(simDir), mkdir(simDir); end
if ~isempty(dir(fullfile(simDir, 'fit_run_*'))), delete(fullfile(simDir, 'fit_run_*')); end
for pat = {'*.inc', '*.lib', '*.sub', '*.mod'}
    if ~isempty(dir(fullfile(workDir, pat{1}))), copyfile(fullfile(workDir, pat{1}), simDir); end
end
copyfile(fullfile(workDir, template), fullfile(simDir, 'template.net'));
fprintf('Simulating in: %s\n', simDir);

%% ---- Fit ----------------------------------------------------------------
sim  = @(CinpF) runLTspice(CinpF, fMeas, acLine, ltspiceExe, simDir, 'template.net', outNode);
cost = @(CinpF) magCost(sim(CinpF), Hmeas, fitFreeGain);

opts = optimset('TolX', 0.01, 'Display', 'iter');
[CinBest, resid] = fminbnd(cost, CinBounds_pF(1), CinBounds_pF(2), opts);

Hbest = sim(CinBest);
[~, gain_dB] = magCost(Hbest, Hmeas, fitFreeGain);
gainFactor = 10^(gain_dB/20);                              % 1 if fitFreeGain = false
fprintf('\nBest-fit Cin = %.3f pF   (RMS error = %.3g dB', CinBest, sqrt(resid/numel(fMeas)));
if fitFreeGain, fprintf(', fitted gain factor = %.3f V/V', gainFactor); end
fprintf(')\n');

%% ---- Plot ---------------------------------------------------------------
figure;
semilogx(fMeas, Hmeas, 'o', fMeas, abs(Hbest) * gainFactor, '-', 'LineWidth', 1.2);
xlabel('Frequency (Hz)'); ylabel('Voltage gain V_{out}/V_{in} (V/V)'); grid on;
legend(sprintf('Measured (V_{in} = %g mV_{pp})', Vin_pp*1e3), ...
       sprintf('LTspice: Cin = %.2f pF, Gain = %.2f', CinBest, gainFactor), 'Location', 'best');

%% ========================================================================
function [err, gain_dB] = magCost(Hsim, Hmeas, freeGain)
    % Sum of squared dB errors. With freeGain, the best constant dB offset
    % (closed-form least squares) is removed first, so only the shape is fitted.
    d = 20*log10(abs(Hmeas)) - 20*log10(abs(Hsim));
    gain_dB = 0;
    if freeGain, gain_dB = mean(d); end
    err = sum((d - gain_dB).^2);
end

function [f, amp] = loadMFLIfig(figFile)
    % Pull the sweep out of the MFLI .fig by identifying axes from their y-labels.
    fig = openfig(figFile, 'invisible');
    closer = onCleanup(@() close(fig));
    f = []; amp = [];
    for ax = findobj(fig, 'Type', 'axes')'
        lab = ax.YLabel.String;
        if iscell(lab), lab = strjoin(lab, ' '); end
        ln = findobj(ax, 'Type', 'line');
        if isempty(ln), continue; end
        [~, k] = max(arrayfun(@(h) numel(h.XData), ln));   % skip data-tip markers
        x = ln(k).XData(:); y = ln(k).YData(:);
        if contains(lab, 'Amplitude', 'IgnoreCase', true) && ...
           ~contains(lab, 'max', 'IgnoreCase', true)        % raw amplitude, not normalized
            amp = y; f = x;
        end
    end
    if isempty(f) || isempty(amp)
        error('Could not find the raw amplitude axes in %s', figFile);
    end
end

function acLine = buildAcLine(f)
    % Match LTspice's sweep to the measured frequencies.
    f  = sort(f(:));
    n  = numel(f);
    df = diff(f);
    if max(abs(df - mean(df))) < 1e-6 * mean(df)          % linear sweep
        acLine = sprintf('.ac lin %d %.12g %.12g', n, f(1), f(end));
    else                                                    % anything else: exact list
        vals = compose('%.12g', f);
        rows = arrayfun(@(i) strjoin(vals(i:min(i+9, n))', ' '), 1:10:n, 'UniformOutput', false);
        acLine = ['.ac list ' strjoin(rows, [newline '+ '])];
    end
end

function H = runLTspice(CinpF, f, acLine, ltspiceExe, workDir, template, outNode)
    % Write a netlist with the new Cin and sweep, run LTspice, return H at f.
    persistent runCount
    if isempty(runCount), runCount = 0; end
    runCount = runCount + 1;
    oldDir = cd(workDir);
    restore = onCleanup(@() cd(oldDir));    % relative .inc paths resolve from here

    if ~isfile(template)
        error('Template netlist "%s" not found in %s', template, workDir);
    end
    txt = readTextAuto(template);
    if isempty(regexpi(txt, '\.param\s+Cin\s*=', 'once'))
        error('No ".param Cin=" line found in %s', template);
    end
    if isempty(regexpi(txt, '^\.ac\s', 'once', 'lineanchors'))
        error('No ".ac" line found in %s', template);
    end
    txt = regexprep(txt, '\.param\s+Cin\s*=\s*\S+', ...
                    sprintf('.param Cin=%.6gp', CinpF), 'ignorecase');
    txt = regexprep(txt, '^\.ac\s[^\r\n]*', acLine, 'ignorecase', 'lineanchors');

    % Fresh file names every run, so a file still held open by a previous
    % LTspice process (or antivirus/indexer) can never block this one.
    base    = sprintf('fit_run_%04d', runCount);
    netFile = [base '.net'];
    rawFile = [base '.raw'];
    logFile = [base '.log'];
    fid = fopen(netFile, 'w'); fprintf(fid, '%s', txt); fclose(fid);

    for attempt = 1:3
        [status, msg] = system(sprintf('"%s" -b -ascii %s', ltspiceExe, netFile));
        t0 = tic;
        while ~isfile(rawFile) && toc(t0) < 10, pause(0.2); end   % allow for slow file writes
        if isfile(rawFile), break; end
        pause(1);                                                  % then retry
    end
    if ~isfile(rawFile)
        logTxt = sprintf('(no %s was written - LTspice probably did not start)', logFile);
        if isfile(logFile), logTxt = readTextAuto(logFile); end
        error(['LTspice produced no .raw file after 3 attempts (Cin = %.4g pF).\n' ...
               '  exit status: %d\n  console: %s\n--- %s ---\n%s'], ...
               CinpF, status, strtrim(msg), logFile, logTxt);
    end

    [fSim, vSim] = readAsciiRaw(rawFile, outNode);
    for tmp = {netFile, rawFile, logFile}                          % tidy up; ignore locks
        if isfile(tmp{1}), try, delete(tmp{1}); catch, end, end
    end
    H = interp1(fSim, vSim, f, 'linear');   % same frequencies, so this is ~exact
end

function txt = readTextAuto(file)
    % Read a text file that may be ASCII/UTF-8 or UTF-16LE (LTspice writes both).
    fid = fopen(file, 'r'); b = fread(fid, inf, 'uint8=>uint8')'; fclose(fid);
    if numel(b) > 1 && (b(2) == 0 || (b(1) == 255 && b(2) == 254))
        txt = native2unicode(b, 'UTF-16LE');
        txt = strrep(txt, char(65279), '');        % strip byte-order mark
    else
        txt = char(b);
    end
end

function [f, v] = readAsciiRaw(rawFile, varName)
    % Minimal reader for LTspice ASCII .raw files from an AC analysis.
    fid = fopen(rawFile, 'r'); b = fread(fid, inf, 'uint8=>uint8')'; fclose(fid);
    if numel(b) > 1 && b(2) == 0
        txt = native2unicode(b, 'UTF-16LE');     % newer LTspice may write UTF-16
    else
        txt = char(b);
    end
    lines = strtrim(splitlines(string(txt)));

    nVars = str2double(extractAfter(lines(find(startsWith(lines, "No. Variables:"), 1)), ":"));
    nPts  = str2double(extractAfter(lines(find(startsWith(lines, "No. Points:"), 1)), ":"));

    iVar  = find(lines == "Variables:", 1);
    names = strings(nVars, 1);
    for k = 1:nVars
        parts = split(lines(iVar + k));
        names(k) = parts(2);
    end
    col = find(strcmpi(names, varName), 1);
    if isempty(col)
        error('Node %s not in .raw file. Available: %s', varName, strjoin(names, ', '));
    end

    iVal = find(lines == "Values:", 1);
    vals = lines(iVal+1:end);
    vals = vals(vals ~= "");
    vals = reshape(vals(1:nVars*nPts), nVars, nPts);   % one column per frequency point

    f = real(parseCplx(regexprep(vals(1,:), '^\d+\s+', '')));
    v = parseCplx(vals(col,:));
end

function z = parseCplx(s)
    p = split(s(:), ",");
    z = str2double(p(:,1)) + 1i*str2double(p(:,2));
end