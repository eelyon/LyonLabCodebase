%% analyzeHeLevelResonance.m
% Resonance-frequency shift of the HeLevelMeter_top / HeLevelMeter_bottom
% resonators versus time, extracted from saved .fig sweeps.
%
% For every <tag>_<fileNum>.fig with fileNum >= the reference number of its tag:
%   1. open the figure invisibly; take |S21| (dB) from the axes whose y-label
%      contains "dB", the phase (deg) from the other axes, and the metadata
%      struct (field 'timestamp') from UserData or appdata 'sweepMeta';
%   2. fit the notch resonance with fit_notch_resonance (must be on the path):
%        useComplexFit = false : |S21| only
%        useComplexFit = true  : |S21| + phase -> complex fit (circle fit + LM)
%   3. plot  Delta f_r = f_r(t) - f_r(first sweep of that tag)  versus time,
%      optionally with the mixing-chamber temperature log on a right y-axis.
%
% Repeated sweeps: files are matched by tag (from the file name), never by
% alternating file numbers, so any order (top, top, top, bottom, ...) works.
% Back-to-back sweeps of the same tag can optionally be averaged (mergeRepeats).
%
% Requires: MATLAB R2019b or newer, fit_notch_resonance.m on the path.

%% ===================== User settings =====================================
% if exist('getCurrentDataFolder','file')
    % dataFolder = getCurrentDataFolder();     % same folder saveData writes to
% else
    dataFolder = 'C:\Users\ee_lyonlab_j409\Princeton Dropbox\Tiffany Liu\GroupDropbox\Gordian\QuSeN\data\11_12_26';
% end
tags            = ["HeLevelMeter_top", "HeLevelMeter_bottom"];
firstFileNum    = [859, 867];    % reference sweep of each tag (same order as tags)
lastFileNum     = Inf;           % ignore files above this number
useComplexFit   = true;         % false: magnitude only; true: magnitude + phase
fitWindowLW     = 15;            % fit |f - f_r| < fitWindowLW linewidths (Inf = all)
excludeDiverged = true;          % drop sweeps where the full LM fit diverged
mergeRepeats    = false;         % true: average back-to-back sweeps of one tag
mergeMaxGap     = minutes(10);   % ... only if they are closer than this in time
timeUnit        = "min";         % "min" or "h"
verboseFit      = false;         % print fit_notch_resonance's report per sweep
showRefFits     = true;          % fit_notch_resonance's own plots for the reference sweeps
saveResults     = true;          % write CSV/MAT/FIG of the results to dataFolder
tagColors       = [0 0.30 0.85;  0.85 0.20 0.10];   % RGB per tag

% --- temperature log (CSV: valueId, datetime [ISO 8601, UTC 'Z'], value [K])
tempFile        = fullfile(dataFolder, "20261114-202416-graph.csv");  % "" = no temperature
tempChannel     = "MXC_TEMPERATURE";  % valueId to plot
labTimeZone     = "local";       % time zone of the PC that wrote the VNA timestamps,
                                 % e.g. "America/New_York"; "local" = this PC's zone
tempColor       = [0 0.50 0.15];
xPadFrac        = 0.02;          % x-axis margin beyond first/last sweep (fraction of span)

if ~exist('fit_notch_resonance','file')
    error('fit_notch_resonance.m is not on the MATLAB path.');
end

%% ===================== Find files ========================================
listing  = dir(fullfile(dataFolder,'*.fig'));
fileName = string({listing.name}');
tok      = regexp(fileName,'^(.*)_(\d+)\.fig$','tokens','once');
isNamed  = ~cellfun(@isempty,tok);
listing  = listing(isNamed);
tok      = vertcat(tok{isNamed});                       % [tag, number]
fileTag  = string(tok(:,1));
fileNum  = str2double(tok(:,2));

[isTag,tagIdx] = ismember(fileTag,tags);
refNum = firstFileNum(tagIdx(isTag));
keep   = isTag;
keep(isTag) = fileNum(isTag) >= refNum(:) & fileNum(isTag) <= lastFileNum;
listing = listing(keep);  fileTag = fileTag(keep);  fileNum = fileNum(keep);

[fileNum,order] = sort(fileNum);                        % global measurement order
listing = listing(order);  fileTag = fileTag(order);
nFiles  = numel(fileNum);

for k = 1:numel(tags)
    if ~any(fileTag == tags(k) & fileNum == firstFileNum(k))
        error('Reference file %s_%d.fig not found in %s', tags(k), firstFileNum(k), dataFolder);
    end
end
fprintf('%d sweeps found in %s (%s fit)\n', nFiles, dataFolder, ...
        string(ifElse(useComplexFit,"complex","magnitude-only")));

%% ===================== Read + fit every sweep ============================
time_    = NaT(nFiles,1);
fr_Hz    = nan(nFiles,1);  frErr_Hz = nan(nFiles,1);
Ql       = nan(nFiles,1);  QlErr    = nan(nFiles,1);  Qc = nan(nFiles,1);
Qi       = nan(nFiles,1);  QiErr    = nan(nFiles,1);  QiResolved = false(nFiles,1);
phi_rad  = nan(nFiles,1);  rmsRes   = nan(nFiles,1);  diverged = false(nFiles,1);
traces   = cell(nFiles,1);

for k = 1:nFiles
    figFile = fullfile(listing(k).folder, listing(k).name);
    try
        [fGHz,magdB,phaseDeg,meta] = readSweepFig(figFile);
        time_(k) = sweepTimestamp(meta, listing(k));
        [res,diverged(k)] = runNotchFit(fGHz,magdB,phaseDeg,useComplexFit,fitWindowLW,verboseFit,false);
        fr_Hz(k) = res.fr_Hz;   frErr_Hz(k) = res.fr_Hz_err;
        Ql(k)    = res.Ql;      QlErr(k)    = res.Ql_err;    Qc(k) = res.Qc_abs;
        Qi(k)    = res.Qi;      QiErr(k)    = res.Qi_err;    QiResolved(k) = res.QiResolved;
        phi_rad(k) = res.phi_rad;   rmsRes(k) = res.rms_residual;
        traces{k} = struct('fGHz',fGHz,'magdB',magdB,'phaseDeg',phaseDeg);
        fprintf('%-28s  f_r = %.6f MHz +/- %4.0f Hz   Q_l = %5.0f%s\n', listing(k).name, ...
            res.fr_Hz/1e6, res.fr_Hz_err, res.Ql, string(ifElse(diverged(k),"   [DIVERGED]","")));
    catch ME
        warning('Skipping %s: %s', listing(k).name, ME.message);
    end
end

T = table(fileTag, fileNum, time_, fr_Hz, frErr_Hz, Ql, QlErr, Qc, Qi, QiErr, QiResolved, ...
          phi_rad, rmsRes, diverged, ...
    'VariableNames',{'tag','fileNum','time','fr_Hz','frErr_Hz','Ql','QlErr','Qc_abs', ...
                     'Qi','QiErr','QiResolved','phi_rad','rmsResidual','diverged'});
use = ~isnan(T.fr_Hz);
if excludeDiverged, use = use & ~T.diverged; end
T = T(use,:);

%% ===================== Group back-to-back repeats ========================
% A "run" = consecutive files (in file-number order) of the same tag that are
% less than mergeMaxGap apart. With mergeRepeats = false every sweep is a point.
sameAsPrev = [false; T.tag(2:end) == T.tag(1:end-1) & diff(T.time) < mergeMaxGap];
T.runID    = cumsum(~sameAsPrev);

if mergeRepeats
    G = T.runID;
    P = table();
    P.tag      = splitapply(@(s) s(1), T.tag, G);
    P.fileNum  = splitapply(@(n) n(1), T.fileNum, G);
    P.nSweeps  = splitapply(@numel,     T.fr_Hz, G);
    P.time     = splitapply(@mean,      T.time, G);
    P.fr_Hz    = splitapply(@mean,      T.fr_Hz, G);
    % standard error of the mean: scatter between repeats + fit uncertainty
    P.frErr_Hz = splitapply(@(f,s) sqrt(var(f,1)/numel(f) + mean(s.^2)/numel(f)), ...
                            T.fr_Hz, T.frErr_Hz, G);
else
    P = T(:,{'tag','fileNum','time','fr_Hz','frErr_Hz'});
    P.nSweeps = ones(height(P),1);
end

%% ===================== Shift relative to the first sweep =================
P.dfr_kHz = nan(height(P),1);
frRef_Hz  = nan(numel(tags),1);
for k = 1:numel(tags)
    isK  = P.tag == tags(k);
    iRef = find(isK & P.fileNum == firstFileNum(k), 1);   % holds also when merged
    if isempty(iRef)
        error('Fit of reference sweep %s_%d failed or diverged; choose another firstFileNum.', ...
              tags(k), firstFileNum(k));
    end
    frRef_Hz(k)    = P.fr_Hz(iRef);
    P.dfr_kHz(isK) = (P.fr_Hz(isK) - frRef_Hz(k)) / 1e3;
end
P.err_kHz = P.frErr_Hz / 1e3;

t0 = min(P.time);                                       % common time origin
switch timeUnit
    case "h",   P.elapsed = hours(P.time - t0);   tLabel = "Time since first sweep (h)";
    otherwise,  P.elapsed = minutes(P.time - t0); tLabel = "Time since first sweep (min)";
end
if timeUnit == "h", toUnit = @hours; else, toUnit = @minutes; end   % duration -> number

%% ===================== Temperature log ===================================
hasTemp = strlength(tempFile) > 0 && isfile(tempFile);
if strlength(tempFile) > 0 && ~hasTemp
    warning('Temperature file %s not found: plotting without temperature.', tempFile);
end
if hasTemp
    [tTemp, T_K] = readTemperatureLog(tempFile, tempChannel, labTimeZone);
    tempElapsed  = toUnit(tTemp - t0);
    fprintf('Temperature log: %s to %s (%s), %d points\n', ...
            char(tTemp(1)), char(tTemp(end)), labTimeZone, numel(tTemp));
    fprintf('Sweeps:          %s to %s\n', char(min(P.time)), char(max(P.time)));
    if max(P.time) < tTemp(1) || min(P.time) > tTemp(end)
        warning(['Sweeps and temperature log do not overlap in time. ' ...
                 'Check labTimeZone (log is in UTC, sweeps in lab time).']);
    end
    % temperature at each sweep (linear interpolation; NaN outside the log)
    P.T_mK = interp1(seconds(tTemp - t0), 1e3*T_K, seconds(P.time - t0), 'linear', NaN);
    T.T_mK = interp1(seconds(tTemp - t0), 1e3*T_K, seconds(T.time - t0), 'linear', NaN);
end

%% ===================== Plot: Delta f_r (left) and T_MXC (right) vs time
% x-range: first to last resonance sweep (+ small margin), not the full log
tSpan = [min(P.elapsed), max(P.elapsed)];
xWin  = tSpan + [-1 1]*xPadFrac*max(diff(tSpan), 1);    % 1 = fallback for a single sweep

figShift = figure('Name','HeLevelMeter resonance shift','Color','w');
axS = axes(figShift);
if hasTemp, yyaxis(axS,'left'); end
hold(axS,'on');  box(axS,'on');  grid(axS,'on');
hLeg = gobjects(numel(tags),1);
for k = 1:numel(tags)
    isK = P.tag == tags(k);
    hLeg(k) = errorbar(axS, P.elapsed(isK), P.dfr_kHz(isK), P.err_kHz(isK), ...
        'o-', 'Color',tagColors(k,:), 'MarkerFaceColor',tagColors(k,:), ...
        'MarkerSize',5, 'LineWidth',1.2, 'CapSize',4, ...
        'DisplayName', sprintf('%s  (f_r^{ref} = %.4f MHz)', ...
                       erase(tags(k),"HeLevelMeter_"), frRef_Hz(k)/1e6));
end
yline(axS,0,'k:','HandleVisibility','off');
ylabel(axS,'\Delta f_r = f_r(t) - f_r(t_{ref})  (kHz)');

if hasTemp
    axS.YAxis(1).Color = 'k';
    yyaxis(axS,'right');
    inWin = tempElapsed >= xWin(1) & tempElapsed <= xWin(2);   % autoscale T to visible part
    hTemp = plot(axS, tempElapsed(inWin), 1e3*T_K(inWin), '-', 'Color',tempColor, 'LineWidth',1.2, ...
                 'DisplayName', strrep(tempChannel,'_','\_'));
    ylabel(axS,'T_{MXC} (mK)');
    axS.YAxis(2).Color = tempColor;
    hLeg = [hLeg; hTemp];
end

xlim(axS, xWin);                     % shared by both y-axes
xlabel(axS,tLabel);
title(axS, sprintf('HeLevelMeter resonance shift (%s fit), t_0 = %s', ...
      ifElse(useComplexFit,'complex','|S_{21}|'), char(t0)));
legend(hLeg,'Location','best');
set(axS,'FontSize',11,'TickDir','out');

%% ===================== Reference fits (diagnostic) =======================
if showRefFits
    for k = 1:numel(tags)
        kk = find(fileTag == tags(k) & fileNum == firstFileNum(k), 1);
        if isempty(traces{kk}), continue; end
        S = traces{kk};
        fprintf('\nReference sweep %s:\n', listing(kk).name);
        runNotchFit(S.fGHz,S.magdB,S.phaseDeg,useComplexFit,fitWindowLW,true,true);
        set(gcf,'Name',sprintf('Reference fit: %s', listing(kk).name));
    end
end

%% ===================== Save ==============================================
if saveResults
    stamp   = string(datetime('now','Format','yyyyMMdd_HHmmss'));
    outBase = fullfile(dataFolder, "HeLevelMeter_fr_vs_time_" + stamp);
    writetable(T, char(outBase + "_allSweeps.csv"));
    writetable(P, char(outBase + "_plotted.csv"));
    save(char(outBase + ".mat"), 'T','P','frRef_Hz','tags','firstFileNum','t0', ...
         'useComplexFit','fitWindowLW');
    if hasTemp
        save(char(outBase + ".mat"), 'tTemp', 'T_K', 'labTimeZone', '-append');
    end
    savefig(figShift, char(outBase + ".fig"));
    fprintf('Results written to %s.*\n', outBase);
end

%% ========================================================================
%% Local functions
%% ========================================================================
function [res, diverged] = runNotchFit(fGHz, magdB, phaseDeg, useComplex, windowLW, verbose, doPlot)
% Wrapper around fit_notch_resonance: builds opts, optionally silences its
% printed report, and flags the "Full fit diverged" fallback.
    opts = struct('fitWindow_lw', windowLW, 'plot', doPlot);
    if useComplex
        if isempty(phaseDeg)
            error('no phase trace in this figure (required for useComplexFit = true)');
        end
        opts.phase_deg = phaseDeg;
    end
    lastwarn('');
    if verbose
        res = fit_notch_resonance(fGHz, magdB, opts);
    else
        [~, res] = evalc('fit_notch_resonance(fGHz, magdB, opts)');
    end
    diverged = contains(lastwarn(), 'diverged');
end

function [fGHz, magdB, phaseDeg, meta] = readSweepFig(figFile)
% Open a saved sweep figure invisibly; return |S21| (dB), phase (deg) and metadata.
    fig = openfig(figFile, 'invisible');
    closeFig = onCleanup(@() close(fig));

    % --- magnitude axes: y-label contains "dB" (fallback: left-most axes)
    ax = findall(fig, 'Type', 'axes');
    isMag = false(numel(ax),1);
    for i = 1:numel(ax)
        isMag(i) = any(contains(string(ax(i).YLabel.String), "dB"));
    end
    if ~any(isMag)
        pos = vertcat(ax.Position);
        [~, iLeft] = min(pos(:,1));
        isMag(iLeft) = true;
    end
    iMagAx = find(isMag, 1);
    [fGHz, magdB] = longestLine(ax(iMagAx));

    % --- phase: a line in another axes on exactly the same frequency points
    phaseDeg = [];
    others = ax(setdiff(1:numel(ax), iMagAx));
    for i = 1:numel(others)
        [x, y] = longestLine(others(i));
        if numel(x) == numel(fGHz) && max(abs(x - fGHz)) <= 1e-9*max(abs(fGHz))
            phaseDeg = y;   break;
        end
    end

    % --- metadata: appdata (new scripts) or any UserData struct with 'timestamp'
    meta = [];
    if isappdata(fig, 'sweepMeta'), meta = getappdata(fig, 'sweepMeta'); end
    if isempty(meta)
        objs = findall(fig);
        for i = 1:numel(objs)
            ud = get(objs(i), 'UserData');
            if isstruct(ud) && isfield(ud, 'timestamp'), meta = ud; break; end
        end
    end
end

function [x, y] = longestLine(axh)
% Data trace of an axes = the line object with the most points.
    ln = findall(axh, 'Type', 'line');
    if isempty(ln), x = []; y = []; return; end
    nPts = arrayfun(@(h) numel(h.XData), ln);
    [~, iMax] = max(nPts);
    x = double(ln(iMax).XData(:));
    y = double(ln(iMax).YData(:));
end

function [t, T_K] = readTemperatureLog(csvFile, channel, labTimeZone)
% Read a cryostat log export (valueId, datetime, value) and return the
% channel's time stamps converted from UTC to unzoned lab time, and value [K].
    opts = detectImportOptions(csvFile, 'Delimiter', ',');
    opts = setvartype(opts, {'valueId','datetime'}, 'string');
    opts = setvartype(opts, 'value', 'double');
    D = readtable(csvFile, opts);
    D = D(D.valueId == channel, :);
    if isempty(D), error('channel %s not found in %s', channel, csvFile); end

    % ISO 8601 with 'Z' = UTC. Convert to the lab time zone, then drop the
    % zone so it compares directly with the (unzoned) VNA metadata timestamps.
    t = datetime(D.datetime, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z''', ...
                 'TimeZone', 'UTC');
    t.TimeZone = labTimeZone;
    t.TimeZone = '';
    t.Format   = 'yyyy-MM-dd HH:mm:ss';
    T_K = D.value;
    [t, ix] = sort(t);   T_K = T_K(ix);
end

function t = sweepTimestamp(meta, fileInfo)
% Measurement time from metadata; fall back to the file modification date.
    if isstruct(meta) && isfield(meta, 'timestamp') && ~isempty(meta.timestamp)
        t = meta.timestamp;
        if ~isdatetime(t), t = datetime(t); end
    else
        t = datetime(fileInfo.datenum, 'ConvertFrom', 'datenum');
        warning('%s: no metadata timestamp, using file date %s', fileInfo.name, char(t));
    end
    t.TimeZone = '';   t.Format = 'yyyy-MM-dd HH:mm:ss';
end

function out = ifElse(cond, a, b)
    if cond, out = a; else, out = b; end
end