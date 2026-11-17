function res = fit_notch_resonance(f, S21, opts)
% FIT_NOTCH_RESONANCE  Fit a notch-type (hanger / side-coupled) resonance in S21.
%
%   res = fit_notch_resonance(f, S21)          % S21 complex  -> full complex fit
%   res = fit_notch_resonance(f, S21_dB)       % S21 real (dB) -> magnitude-only fit
%   res = fit_notch_resonance(f, S21_dB, struct('phase_deg', ph))  % dB + phase [deg]
%   res = fit_notch_resonance()                % demo on synthetic data
%
%   f : frequency vector, in Hz (values < 1e3 are interpreted as GHz).
%
% Examples of loading data:
%   d = readmatrix('trace.csv');                      % columns: f, Re(S21), Im(S21)
%   res = fit_notch_resonance(d(:,1), d(:,2) + 1i*d(:,3));
%   d = readmatrix('trace.csv');                      % columns: f, |S21| (dB), phase (deg)
%   res = fit_notch_resonance(d(:,1), d(:,2), struct('phase_deg', d(:,3)));
%
% MODEL (Probst et al., Rev. Sci. Instrum. 86, 024706 (2015); Khalil et al.,
% J. Appl. Phys. 111, 054510 (2012)):
%   S21(f) = a e^{i alpha} e^{-2 pi i (f - f_ref) tau}
%            * [ 1 - (Q_l/|Q_c|) e^{i phi} / (1 + 2 i Q_l (f/f_r - 1)) ]
%   a, alpha : environment gain and phase;  tau : cable delay
%   phi      : impedance-mismatch (asymmetry) angle;  Q_c = |Q_c| e^{-i phi}
%   1/Q_i    = 1/Q_l - Re{1/Q_c} = 1/Q_l - cos(phi)/|Q_c|
%
% ALGORITHM (complex data)
%   1. Initial f_r, Q_l, depth from the smoothed |S21|^2 (half-depth width).
%   2. Cable delay from the off-resonant phase slope, refined by minimizing the
%      circle-fit residual.
%   3. Algebraic (Kasa) circle fit, refined geometrically.
%   4. Phase-vs-frequency fit about the circle center -> f_r, Q_l, theta_0.
%   5. Off-resonant point -> a, alpha; normalized circle -> |Q_c|, phi.
%   6. Simultaneous Levenberg-Marquardt fit of all 7 parameters to Re/Im S21.
%   7. 1-sigma errors from the covariance s^2 (J^T J)^{-1}, propagated to Q_i.
%   Magnitude-only data: steps 1 and 6 on |S21|, with phi kept free.
%
% OPTIONS (struct fields, all optional)
%   phase_deg      : phase [deg]; S21 is then |S21| in dB
%   fitWindow_lw   : fit only |f - f_r| < fitWindow_lw * linewidth (default Inf)
%   magSlope       : include a linear baseline slope (magnitude-only fit; default true)
%   Pin_dBm        : power at the resonator input port [dBm] -> photon number
%   plot           : true/false (default true)
%
% Compatible with MATLAB R2016b+ and GNU Octave >= 6. No toolboxes required.

%% ---------------------------- input handling -----------------------------
if nargin == 0
    [f, S21] = demoData();
    opts = struct();
    fprintf('No data given: running on synthetic demo data.\n');
end
if nargin < 3, opts = struct(); end
def = struct('phase_deg', [], 'fitWindow_lw', Inf, 'magSlope', true, ...
             'Pin_dBm', NaN, 'plot', true);
fn = fieldnames(def);
for k = 1:numel(fn), if ~isfield(opts, fn{k}), opts.(fn{k}) = def.(fn{k}); end, end

f = f(:); S21 = S21(:);
if max(f) < 1e3, f = f*1e9; end                         % GHz -> Hz
if ~isempty(opts.phase_deg)
    S21 = 10.^(S21/20) .* exp(1i*deg2rad(opts.phase_deg(:)));
end
isComplexData = ~isreal(S21);
if ~isComplexData, S21 = 10.^(S21/20); end              % dB -> linear magnitude
[f, idx] = sort(f); S21 = S21(idx);

%% ------------------- step 1: initial guesses from |S21| ------------------
ini = magnitudeGuess(f, abs(S21));
if isfinite(opts.fitWindow_lw)
    keep = abs(f - ini.fr) < opts.fitWindow_lw*ini.fr/ini.Ql;
    f = f(keep); S21 = S21(keep);
    ini = magnitudeGuess(f, abs(S21));
end
sc.fref  = mean(f);
sc.fspan = f(end) - f(1);
sc.fr0   = ini.fr;
sc.fw0   = ini.fr/ini.Ql;                               % linewidth scale for f_r

if isComplexData
    %% ---------------- steps 2-5: circle fit for initial values ------------
    offRes = abs(f - ini.fr) > 3*sc.fw0;
    if nnz(offRes) < 10, offRes = true(size(f)); end
    ph   = unwrap(angle(S21));
    pfit = polyfit(f(offRes) - sc.fref, ph(offRes), 1);
    tau0 = -pfit(1)/(2*pi);
    % Circle fit and delay refinement only within a few linewidths of f_r:
    % far from resonance a residual delay also maps the baseline onto a circle
    % (radius a, centered at 0), which would be a spurious minimum.
    win = abs(f - ini.fr) < 4*sc.fw0;
    if nnz(win) < 30, win = abs(f - ini.fr) < 10*sc.fw0; end
    if nnz(win) < 30, win = true(size(f)); end
    fw = f(win); Sw = S21(win);
    circRes = @(t) circleFit(Sw .* exp(2i*pi*(fw - sc.fref)*t)).rmsAbs;
    tauScale = 1/(2*pi*(fw(end) - fw(1)));              % delay giving 1 rad across the window
    tau = tau0 + tauScale*fminbnd(@(u) circRes(tau0 + tauScale*u), -2, 2, ...
        optimset('TolX', 1e-6, 'Display', 'off'));       % bounded: +/- 2 rad across window
    z   = Sw .* exp(2i*pi*(fw - sc.fref)*tau);
    cf  = circleFit(z);

    % Phase about the circle center: theta(f) = theta0 + 2 atan(2 Ql (1 - f/fr))
    thData = angle(z - cf.c);
    [~, iMin] = min(abs(fw - ini.fr));                  % sample nearest the initial f_r
    th0 = thData(iMin);
    phRes = @(p) angle(exp(1i*(thData - (p(1) + 2*atan(2*exp(p(2))*(1 - fw/(sc.fr0 + p(3)*sc.fw0)))))));
    pPh = lmFit(phRes, [th0; log(ini.Ql); 0]);
    th0 = pPh(1); Ql = exp(pPh(2)); fr = sc.fr0 + pPh(3)*sc.fw0;

    Poff  = cf.c + cf.r*exp(1i*(th0 + pi));             % off-resonant point
    cn    = cf.c/Poff; rn = cf.r/abs(Poff);
    phi0  = -asin(max(min(imag(cn)/rn, 1), -1));
    Qc0   = Ql/(2*rn);

    p0 = [log(abs(Poff)); angle(Poff); tau*2*pi*sc.fspan; (fr - sc.fr0)/sc.fw0; ...
          log(Ql); log(Qc0); phi0];
    resFun = @(p) stackReIm(S21 - modelComplex(f, p, sc));
else
    %% ------------------------ magnitude-only start ------------------------
    p0 = [log(ini.a); 0; 0; log(ini.Ql); log(ini.Qc); 0];  % [log a, slope, dfr, log Ql, log Qc, phi]
    resFun = @(p) abs(S21) - modelMag(f, p, sc, opts.magSlope);
end

%% ------------------- step 6: full Levenberg-Marquardt fit ----------------
[p, J, r] = lmFit(resFun, p0);
frIdx = 4 - ~isComplexData;                             % index of the f_r parameter
frFit = sc.fr0 + p(frIdx)*sc.fw0;
if any(~isfinite(p)) || frFit < f(1) || frFit > f(end) || sum(r.^2) > sum(resFun(p0).^2)
    warning('Full fit diverged; reporting the initial (circle/magnitude) estimate.');
    p = p0; r = resFun(p); J = numJac(resFun, p);
end
nDOF = numel(r) - numel(p);
s2   = sum(r.^2)/nDOF;
covP = s2*pinv(J.'*J);

%% ------------------- step 7: derived quantities and errors ---------------
derived = @(p) derivedQ(p, sc, isComplexData);
[val, err] = propagate(derived, p, covP);
names = {'fr_Hz', 'Ql', 'Qc_abs', 'Qi', 'phi_rad', 'Qc_real', 'invQi'};
res = struct();
for k = 1:numel(names)
    res.(names{k}) = val(k);
    res.([names{k} '_err']) = err(k);
end
res.linewidth_Hz = res.fr_Hz/res.Ql;
% Q_i is resolved only if 1/Q_i is significantly positive; otherwise give a bound.
res.QiResolved = res.invQi > 2*res.invQi_err;
res.Qi_lowerBound95 = 1/(max(res.invQi, 0) + 2*res.invQi_err);
res.params = p; res.cov = covP; res.rms_residual = sqrt(s2); res.complexFit = isComplexData;
if isComplexData
    res.a = exp(p(1)); res.alpha = p(2); res.tau_s = p(3)/(2*pi*sc.fspan);
else
    res.a = exp(p(1)); res.baselineSlope = p(2);
end
if isfinite(opts.Pin_dBm)
    hbar = 1.054571817e-34; Pin = 1e-3*10^(opts.Pin_dBm/10); wr = 2*pi*res.fr_Hz;
    res.photonNumber = 2/(hbar*wr^2) * res.Ql^2/res.Qc_abs * Pin;
end

%% ------------------------------- report ----------------------------------
fprintf('\n=== Notch resonance fit (%s) ===\n', ternary(isComplexData, 'complex S21', 'magnitude only'));
fprintf('  f_r        = %.6f GHz  +/- %.2f Hz\n', res.fr_Hz/1e9, res.fr_Hz_err);
fprintf('  Q_l        = %10.1f  +/- %.1f\n', res.Ql, res.Ql_err);
fprintf('  |Q_c|      = %10.1f  +/- %.1f\n', res.Qc_abs, res.Qc_abs_err);
if res.QiResolved
    fprintf('  Q_i        = %10.1f  +/- %.1f\n', res.Qi, res.Qi_err);
else
    fprintf('  Q_i        : not resolved (1/Q_i = %.2e +/- %.2e); Q_i > %.3g (95%% lower bound)\n', ...
        res.invQi, res.invQi_err, res.Qi_lowerBound95);
end
fprintf('  phi        = %+.4f rad +/- %.4f\n', res.phi_rad, res.phi_rad_err);
QiForRatio = res.Qi; if ~res.QiResolved, QiForRatio = res.Qi_lowerBound95; end
fprintf('  linewidth  = %.2f kHz;  Q_i/|Q_c| %s %.2f (%s)\n', res.linewidth_Hz/1e3, ...
    ternary(res.QiResolved, '=', '>'), QiForRatio/res.Qc_abs, couplingRegime(QiForRatio/res.Qc_abs));
if isComplexData, fprintf('  cable delay tau = %.3f ns\n', res.tau_s*1e9); end
if isfield(res, 'photonNumber'), fprintf('  <n>        = %.3g photons\n', res.photonNumber); end
if QiForRatio/res.Qc_abs > 20
    fprintf(['  NOTE: strongly overcoupled. Q_i is set by the depth of the dip (%.1f dB), so it is\n' ...
             '        sensitive to the noise floor, the frequency step at the minimum and the\n' ...
             '        mismatch angle phi. Treat Q_i as uncertain beyond the quoted statistical error.\n'], ...
             20*log10(abs(1 - res.Ql/res.Qc_abs*exp(1i*res.phi_rad))));
end

%% -------------------------------- plots ----------------------------------
if opts.plot
    ff = linspace(f(1), f(end), 4000).';
    figure('Name', 'Notch resonance fit', 'Color', 'w');
    if isComplexData
        Sfit  = modelComplex(ff, p, sc);  Sdat = S21;
        env   = @(x) exp(p(1) + 1i*p(2)) .* exp(-2i*pi*(x - sc.fref)*res.tau_s);
        subplot(2,2,1);
    else
        Sfit  = modelMag(ff, p, sc, opts.magSlope); Sdat = abs(S21);
        subplot(2,1,1);
    end
    hold on; box on; grid on;
    plot(f/1e9, 20*log10(abs(Sdat)), '.', 'Color', [0.3 0.3 0.9], 'MarkerSize', 4, 'DisplayName', 'data');
    plot(ff/1e9, 20*log10(abs(Sfit)), 'r-', 'LineWidth', 1.5, 'DisplayName', 'fit');
    xlabel('Frequency (GHz)'); ylabel('|S_{21}| (dB)');
    title(sprintf('f_r = %.6f GHz, Q_l = %.0f, |Q_c| = %.0f, Q_i %s %.3g', ...
        res.fr_Hz/1e9, res.Ql, res.Qc_abs, ternary(res.QiResolved, '=', '>'), QiForRatio));
    legend('Location', 'southeast');
    if isComplexData
        subplot(2,2,2); hold on; box on; grid on;
        plot(f/1e9, unwrap(angle(Sdat./env(f))), '.', 'Color', [0.3 0.3 0.9], 'MarkerSize', 4);
        plot(ff/1e9, unwrap(angle(Sfit./env(ff))), 'r-', 'LineWidth', 1.5);
        xlabel('Frequency (GHz)'); ylabel('arg S_{21}^{norm} (rad)');
        subplot(2,2,3); hold on; box on; grid on; axis equal;
        zn = Sdat./env(f); zf = Sfit./env(ff);
        plot(real(zn), imag(zn), '.', 'Color', [0.3 0.3 0.9], 'MarkerSize', 4);
        plot(real(zf), imag(zf), 'r-', 'LineWidth', 1.5);
        plot(1, 0, 'k+', 'MarkerSize', 10, 'LineWidth', 1.5);
        xlabel('Re S_{21}^{norm}'); ylabel('Im S_{21}^{norm}'); title('Normalized circle');
        subplot(2,2,4);
    else
        subplot(2,1,2);
    end
    hold on; box on; grid on;
    if isComplexData, rr = abs(S21 - modelComplex(f, p, sc)); ylab = '|S_{21} - fit|';
    else,             rr = abs(S21) - modelMag(f, p, sc, opts.magSlope); ylab = '|S_{21}| - fit';
    end
    plot(f/1e9, rr, '.', 'Color', [0.4 0.4 0.4], 'MarkerSize', 4);
    xlabel('Frequency (GHz)'); ylabel(ylab); title('Residuals');
end
end

%% ============================ LOCAL FUNCTIONS ============================
function S = modelComplex(f, p, sc)
a = exp(p(1)); alpha = p(2); tau = p(3)/(2*pi*sc.fspan);
fr = sc.fr0 + p(4)*sc.fw0; Ql = exp(p(5)); Qc = exp(p(6)); phi = p(7);
S = a*exp(1i*alpha)*exp(-2i*pi*(f - sc.fref)*tau) .* ...
    (1 - (Ql/Qc)*exp(1i*phi)./(1 + 2i*Ql*(f/fr - 1)));
end

function M = modelMag(f, p, sc, useSlope)
a = exp(p(1)); b = p(2)*useSlope;
fr = sc.fr0 + p(3)*sc.fw0; Ql = exp(p(4)); Qc = exp(p(5)); phi = p(6);
M = a*(1 + b*(f - sc.fref)/sc.fspan) .* ...
    abs(1 - (Ql/Qc)*exp(1i*phi)./(1 + 2i*Ql*(f/fr - 1)));
end

function v = derivedQ(p, sc, isComplexData)
% [f_r, Q_l, |Q_c|, Q_i, phi, Re-equivalent Q_c = |Q_c|/cos(phi), 1/Q_i]
if isComplexData, o = 3; else, o = 2; end
fr = sc.fr0 + p(o+1)*sc.fw0; Ql = exp(p(o+2)); Qc = exp(p(o+3)); phi = p(o+4);
invQi = 1/Ql - cos(phi)/Qc;
v = [fr; Ql; Qc; 1/invQi; phi; Qc/cos(phi); invQi];
end

function [val, err] = propagate(fun, p, covP)
% Delta-method error propagation with a numerical gradient.
val = fun(p); G = zeros(numel(val), numel(p));
for k = 1:numel(p)
    h = 1e-6*max(abs(p(k)), 1); dp = zeros(size(p)); dp(k) = h;
    G(:, k) = (fun(p + dp) - fun(p - dp))/(2*h);
end
err = sqrt(max(diag(G*covP*G.'), 0));
end

function r = stackReIm(z)
r = [real(z); imag(z)];
end

function ini = magnitudeGuess(f, m)
% Baseline, f_r, Q_l (half-depth width of the power dip) and |Q_c| from |S21|.
n = numel(f); nEdge = max(round(0.1*n), 3);
a = median(m([1:nEdge, n-nEdge+1:n]));
P = (m/a).^2;
kSm = max(round(n/2000), 1);                            % light smoothing against noise
Ps = conv(P, ones(2*kSm+1, 1)/(2*kSm+1), 'same');
[Pmin, iMin] = min(Ps(kSm+1:end-kSm)); iMin = iMin + kSm;
fr = f(iMin);
half = (1 + Pmin)/2;
iL = find(Ps(1:iMin) > half, 1, 'last'); iR = iMin - 1 + find(Ps(iMin:end) > half, 1, 'first');
if isempty(iL) || isempty(iR) || iR <= iL
    fwhm = (f(end) - f(1))/20;
else
    fwhm = interpCross(f, Ps, iL, half) - interpCross(f, Ps, iR - 1, half);
    fwhm = abs(fwhm);
end
fwhm = max(fwhm, 3*mean(diff(f)));
Ql = fr/fwhm;
depth = sqrt(max(Pmin, 0));
Qc = Ql/max(1 - depth, 0.02);
ini = struct('a', a, 'fr', fr, 'Ql', Ql, 'Qc', Qc);
end

function fx = interpCross(f, P, i, level)
% Linear interpolation of the level crossing between samples i and i+1.
fx = f(i) + (level - P(i))*(f(i+1) - f(i))/(P(i+1) - P(i));
end

function cf = circleFit(z)
% Algebraic (Kasa) circle fit followed by geometric refinement.
x = real(z); y = imag(z);
A = [x, y, ones(size(x))]; b = -(x.^2 + y.^2);
s = A\b; xc = -s(1)/2; yc = -s(2)/2; r = sqrt(max(xc^2 + yc^2 - s(3), 0));
geo = @(q) sqrt((x - q(1)).^2 + (y - q(2)).^2) - q(3);
q = lmFit(geo, [xc; yc; r]);
cf.c = q(1) + 1i*q(2); cf.r = abs(q(3));
cf.rmsAbs = sqrt(mean(geo(q).^2));
end

function [p, J, r] = lmFit(resFun, p0)
% Levenberg-Marquardt least squares with a central-difference Jacobian.
p = p0(:); r = resFun(p); cost = sum(r.^2); lambda = 1e-3;
for it = 1:200
    J = numJac(resFun, p);
    A = J.'*J; g = J.'*r;
    improved = false;
    while lambda < 1e12
        dp = -(A + lambda*diag(max(diag(A), eps)))\g;
        pTry = p + dp; rTry = resFun(pTry); cTry = sum(rTry.^2);
        if isfinite(cTry) && cTry < cost
            p = pTry; r = rTry; lambda = max(lambda/10, 1e-12);
            improved = true; relDrop = (cost - cTry)/max(cost, realmin); cost = cTry;
            break
        end
        lambda = lambda*10;
    end
    if ~improved || (relDrop < 1e-12 && norm(dp) < 1e-10*(norm(p) + 1e-10)), break; end
end
J = numJac(resFun, p);
end

function J = numJac(fun, p)
r0 = fun(p); J = zeros(numel(r0), numel(p));
for k = 1:numel(p)
    h = 1e-6*max(abs(p(k)), 1); dp = zeros(size(p)); dp(k) = h;
    J(:, k) = (fun(p + dp) - fun(p - dp))/(2*h);
end
end

function s = couplingRegime(ratio)
if ratio > 1.5,      s = 'overcoupled';
elseif ratio < 0.67, s = 'undercoupled';
else,                s = 'near critical coupling';
end
end

function out = ternary(c, a, b)
if c, out = a; else, out = b; end
end

function [f, S21] = demoData()
% Synthetic trace resembling a strongly overcoupled 2.117 GHz notch.
f   = linspace(2.100e9, 2.130e9, 6001).';
fr  = 2.11685e9; Qi = 2.5e5; Qc = 1400; phi = 0.003;
Ql  = 1/(1/Qi + cos(phi)/Qc);
a   = 10^(-18.7/20); alpha = 1.1; tau = 45e-9;
S21 = a*exp(1i*alpha)*exp(-2i*pi*(f - mean(f))*tau) .* ...
      (1 - (Ql/Qc)*exp(1i*phi)./(1 + 2i*Ql*(f/fr - 1)));
rng(1);
S21 = S21 + 0.003*a*(randn(size(f)) + 1i*randn(size(f)))/sqrt(2);
end
