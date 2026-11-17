function results = spiral_helium_shift(userParams)
% SPIRAL_HELIUM_SHIFT  Superfluid-4He-induced resonance shift of a planar
% (self-resonant) spiral resonator, capacitively coupled to a CPW feedline.
%
%   results = spiral_helium_shift()        % defaults below
%   results = spiral_helium_shift(P)       % override any field of the defaults
%
% PHYSICAL MODEL
%   * Zero-thickness conductors on the substrate/vacuum interface (y = 0).
%     For any such planar structure the quasi-static potential is identical
%     in both half-spaces, so W_sub/W_vac = eps_s exactly. L is unchanged by
%     helium (non-magnetic; kinetic inductance unaffected). Hence, for ANY
%     planar geometry,
%         f/f0 = sqrt( (eps_s + 1) / (eps_s + 1 + (eps_He - 1) q) ),
%     where q = vacuum-side field energy inside the helium / total vacuum-side
%     field energy. The bulk limit (q = 1) is therefore geometry-independent.
%   * q is computed for a 2D cross-section through the spiral center: each
%     crossing of the spiral trace is an infinitely long strip at the mode
%     voltage V(s) of that point of the winding (s = arc length from the
%     inner end). Archimedean spiral, centerline r = r0 + p*theta/(2*pi):
%     crossings at +x (theta = 2*pi*k) and -x (theta = 2*pi*k + pi).
%     Mode profiles: 'open-open' V = cos(pi s/l) (floating spiral, lambda/2-like);
%     'outer-grounded' V = cos(pi s/(2l)); 'inner-grounded' V = sin(pi s/(2l)).
%   * Strip charges from a 2D method of moments (log kernel, edge-graded
%     panels, overall charge neutrality). The field above the surface is
%     evaluated analytically from the panel charges and |E|^2 is integrated
%     over 0 < y < h(x) on a graded G.
%   * Helium profile h(x) as in cpw_helium_shift.m: van der Waals film on all
%     surfaces plus a capillary meniscus (radius R_c = sigma/(rho g H)) pinned
%     at the edges of every gap trench of depth t_gap; for a submerged chip,
%     h = D over metal and D + t_gap in gaps.
%   * geometry = 'cpw' reproduces the conformal-map CPW case (validation).
%
% LIMITATIONS
%   * A 2D cut of a 3D disk: the turn-to-turn near field (which dominates the
%     thin-film participation) is captured; the disk-scale far field decays
%     more slowly in 2D than in 3D, so q at large film thickness (d ~ disk
%     radius) is approximate. The bulk limit is exact regardless.
%   * The mode profile V(s) is an approximation for a strongly coupled spiral.
%     q is a ratio of energies and only weakly sensitive to it.
%   * The coupling pad to the feedline is neglected; it contributes a
%     correction of order C_c/C_total * (q_c - q), well below 1 %.
%
% Compatible with MATLAB R2016b+ and GNU Octave >= 6.

%% ======================= USER INPUT PARAMETERS ===========================
P = struct();
P.f0_Hz            = 2.1e9;      % bare resonance frequency [Hz]
P.geometry         = 'spiral';   % 'spiral' or 'cpw' (validation)

% --- Spiral (defaults estimated from the layout screenshot; replace with GDS values)
P.traceWidth_m     = 3e-6;       % spiral trace width w [m]
P.traceGap_m       = 3e-6;       % gap between adjacent turns g [m]
P.nTurns           = 11;         % number of turns N
P.innerRadius_m    = 85e-6;      % centerline radius of the innermost turn start r0 [m]
P.groundRadius_m   = 275e-6;     % radius of the surrounding ground-plane edge [m]
P.innerPadRadius_m = 75e-6;          % radius of a central metal pad tied to the inner end (0 = none) [m]
P.modeProfile      = 'open-open';% 'open-open' | 'outer-grounded' | 'inner-grounded'

% --- CPW (only for geometry = 'cpw')
P.cpwCenterWidth_m = 10e-6;
P.cpwGap_m         = 4.186e-6;

% --- Common
P.metalThick_m     = 200e-9;     % metal thickness [m]
P.overEtch_m       = 0;          % substrate trench depth in gaps [m]
P.loadedQ          = 1800;        % loaded Q (expresses shift in linewidths)
P.substrates       = {'Si', 'sapphire'};
P.eps_Si           = 11.45;
P.eps_sapph_perp   = 9.30;
P.eps_sapph_par    = 11.50;

% --- Helium state at the operating point
% levelInput = 'height': heightAboveBulk_m > 0 -> chip above bulk; < 0 -> submerged depth.
% levelInput = 'dose'  : bulk level computed from the helium dose and cell geometry.
P.levelInput        = 'height';
P.heightAboveBulk_m = 5e-3;
P.dose_cm3STP       = 50;
P.cellFloorArea_m2  = 4e-4;
P.chipHeight_m      = 10e-3;
P.coldWetArea_m2    = 2e-2;

% --- Sweeps
P.H_sweep_m         = logspace(-4, log10(5e-2), 30);
P.D_sweep_m         = logspace(-8, -3, 30);

% --- Helium constants (T -> 0)
P.eps_He            = 1.0572;
P.rho_He            = 145;        % [kg/m^3]
P.sigma_He          = 0.375e-3;   % [N/m]
P.molarVol_He_m3    = 27.6e-6;    % [m^3/mol]
P.filmRef_m         = 30e-9;      % vdW film at H_ref
P.filmRefHeight_m   = 1e-2;       % H_ref [m]
P.filmExponent      = 3;

% --- Numerics
P.minPanel_m        = 0.5e-9;     % smallest MoM panel at conductor edges [m]
P.panelRatio        = 1.6;        % geometric growth of MoM panels away from edges
P.groundWidthFactor = 20;         % ground strip width = factor x structure size
%% =========================================================================

if nargin > 0 && isstruct(userParams)
    fn = fieldnames(userParams);
    for i = 1:numel(fn), P.(fn{i}) = userParams.(fn{i}); end
end
g0 = 9.80665; Vmolar_STP_m3 = 22.414e-3;

%% 1) Cross-section: strips [x_left, x_right, V]
[strips, geoInfo] = buildCrossSection(P);
tGap = P.metalThick_m + P.overEtch_m;
gaps = [strips(1:end-1, 2), strips(2:end, 1)];          % [x_left, x_right] of each gap
gaps = gaps(gaps(:,2) - gaps(:,1) > 0, :);

%% 2) Method of moments: panel charge densities (eps0 = 1 units)
[pan, sigmaPan, Wvac] = solveMoM(strips, P);

%% 3) Field energy on a graded (x, y) grid, cumulative in y
G    = buildGrid(strips, geoInfo);
E2   = fieldSquared(G.X, G.Y, pan, sigmaPan);     % [nx x ny]
Icum = cumEnergy(E2, G);                            % [nx x (nyPanels+1)] at y breakpoints
qFromH = @(h) layerParticipation(h, G, Icum, Wvac); % h: [nx x 1]
qCoverage = qFromH(G.yBreaks(end)*ones(numel(G.x), 1));

%% 4) Substrates and frequency map
nSub = numel(P.substrates); epsSub = zeros(1, nSub);
for i = 1:nSub
    switch lower(P.substrates{i})
        case {'si','silicon'}, epsSub(i) = P.eps_Si;
        case {'sapphire','al2o3','c-sapphire'}, epsSub(i) = sqrt(P.eps_sapph_perp*P.eps_sapph_par);
        otherwise, error('Unknown substrate "%s".', P.substrates{i});
    end
end
dfFromQ = @(q) P.f0_Hz .* (sqrt((epsSub + 1)./(epsSub + 1 + (P.eps_He - 1).*q(:))) - 1);
dfBulk  = dfFromQ(1);
linewidth_Hz = P.f0_Hz/P.loadedQ;

fprintf('\n=== Geometry: %s ===\n', P.geometry);
fprintf('%s\n', geoInfo.description);
fprintf('MoM: %d panels | field grid %d x %d | domain energy coverage q(Y_max) = %.4f\n', ...
    size(pan,1), numel(G.x), numel(G.yNodes), qCoverage);

%% 5) Operating point
switch lower(P.levelInput)
    case 'height'
        H_op = P.heightAboveBulk_m;
    case 'dose'
        nHe = P.dose_cm3STP*1e-6/Vmolar_STP_m3;  Vliq = nHe*P.molarVol_He_m3;
        H_op = P.chipHeight_m;
        for it = 1:20
            dFilm = vdwFilm(max(H_op, 1e-4), P);
            Vbulk = max(Vliq - P.coldWetArea_m2*dFilm, 0);
            level = Vbulk/P.cellFloorArea_m2;  H_op = P.chipHeight_m - level;
        end
        fprintf('Dose %.3g cm^3 STP -> %.3g mm^3 liquid; bulk level %.3f mm; H = %.3f mm\n', ...
            P.dose_cm3STP, Vliq*1e9, level*1e3, H_op*1e3);
        if Vbulk == 0
            warning('Dose below the saturated-film inventory: film is unsaturated and thinner than modeled.');
        end
    otherwise
        error('levelInput must be ''height'' or ''dose''.');
end
[h_op, st] = heliumProfile(G.x, H_op, gaps, tGap, P, g0);
q_op  = qFromH(h_op);
df_op = dfFromQ(q_op);

fprintf('\n=== Operating point ===\n');
if H_op > 0
    fprintf('H above bulk = %.3f mm | vdW film = %.1f nm | R_c = %.1f um | turn-gap level = %.1f nm (trench %.0f nm)\n', ...
        H_op*1e3, st.dFilm*1e9, st.Rc*1e6, st.levelNarrowGap*1e9, tGap*1e9);
else
    fprintf('Submerged, depth above metal = %.3g um\n', -H_op*1e6);
end
fprintf('Helium participation q = %.4e\n', q_op);
for i = 1:nSub
    fprintf('  %-9s eps = %5.2f : df = %+9.2f kHz (%+.2f linewidths at Q_L = %.0e) | bulk limit %+.3f MHz\n', ...
        P.substrates{i}, epsSub(i), df_op(i)/1e3, df_op(i)/linewidth_Hz, P.loadedQ, dfBulk(i)/1e6);
end

%% 6) Sweeps (cheap: only h(x) changes)
qAbove = zeros(size(P.H_sweep_m)); filmAbove = qAbove; gapAbove = qAbove;
for j = 1:numel(P.H_sweep_m)
    [hj, sj] = heliumProfile(G.x, P.H_sweep_m(j), gaps, tGap, P, g0);
    qAbove(j) = qFromH(hj); filmAbove(j) = sj.dFilm; gapAbove(j) = sj.levelNarrowGap;
end
qSub = zeros(size(P.D_sweep_m));
for j = 1:numel(P.D_sweep_m)
    qSub(j) = qFromH(heliumProfile(G.x, -P.D_sweep_m(j), gaps, tGap, P, g0));
end
dfAbove = dfFromQ(qAbove);  dfSub = dfFromQ(qSub);

% Uniform-film reference curve (no capillary fill), useful for comparison with FEM
dRef = logspace(-9, -4, 26);
qRef = arrayfun(@(d) qFromH(d*ones(numel(G.x), 1)), dRef);

%% 7) Plots
colors = lines(max(nSub, 2));
figure('Name', 'He shift vs height above bulk', 'Color', 'w');
subplot(2,1,1); hold on; box on; grid on;
for i = 1:nSub
    plot(P.H_sweep_m*1e3, abs(dfAbove(:,i))/1e3, '-o', 'Color', colors(i,:), 'MarkerSize', 4, ...
        'DisplayName', P.substrates{i});
end
set(gca, 'XScale', 'log', 'YScale', 'log');
xlim([min(P.H_sweep_m)/1.25, max(P.H_sweep_m)*1.25]*1e3);
ylim([min([abs(dfAbove(:)); linewidth_Hz])/2, max(abs(dfAbove(:)))*2]/1e3);
refLine('h', linewidth_Hz/1e3, sprintf('linewidth (Q_L = %.0e)', P.loadedQ));
if H_op > 0, refLine('v', H_op*1e3, 'operating H'); end
xlabel('Chip height above bulk level H (mm)'); ylabel('|\Deltaf| (kHz)');
title(sprintf('%s, f_0 = %.3f GHz', P.geometry, P.f0_Hz/1e9)); legend('Location', 'best');
subplot(2,1,2); hold on; box on; grid on;
plot(P.H_sweep_m*1e3, filmAbove*1e9, '-', 'LineWidth', 1.5, 'DisplayName', 'vdW film');
plot(P.H_sweep_m*1e3, gapAbove*1e9, '--', 'LineWidth', 1.5, 'DisplayName', 'level in narrowest gap');
set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('Chip height above bulk level H (mm)'); ylabel('Helium thickness (nm)'); legend('Location', 'best');

dfRef = dfFromQ(qRef);
figure('Name', 'He shift vs uniform film / submersion', 'Color', 'w'); hold on; box on; grid on;
for i = 1:nSub
    plot(dRef*1e6, abs(dfRef(:,i))/1e3, '-', 'Color', colors(i,:), ...
        'LineWidth', 1.5, 'DisplayName', sprintf('%s, uniform film (t_{gap} = 0)', P.substrates{i}));
    plot(P.D_sweep_m*1e6, abs(dfSub(:,i))/1e3, 'o', 'Color', colors(i,:), 'MarkerSize', 4, ...
        'DisplayName', sprintf('%s, submerged (with trenches)', P.substrates{i}));
end
set(gca, 'XScale', 'log', 'YScale', 'log');
xlim([min(dRef) max(dRef)]*1e6);
for i = 1:nSub, refLine('h', abs(dfBulk(i))/1e3, sprintf('bulk limit, %s', P.substrates{i})); end
xlabel('Helium thickness above metal (\mum)'); ylabel('|\Deltaf| (kHz)'); legend('Location', 'best');

figure('Name', 'Cross-section at operating point', 'Color', 'w');
xWin = geoInfo.plotHalfWidth;
subplot(2,1,1); hold on; box on; grid on;
for n = 1:size(strips, 1)
    xl = max(strips(n,1), -xWin); xr = min(strips(n,2), xWin);
    if xr > xl, fill([xl xr xr xl]*1e6, [0 0 strips(n,3) strips(n,3)], [0.85 0.4 0.4], 'EdgeColor', 'none'); end
end
xlim([-xWin xWin]*1e6); xlabel('x (\mum)'); ylabel('Mode voltage V/V_0');
title(sprintf('Strip potentials (%s)', P.modeProfile));
subplot(2,1,2); hold on; box on;
[xs, is] = sort(G.x); hs = h_op(is);
keep = abs(xs) <= xWin;
area(xs(keep)*1e6, hs(keep)*1e9, 'FaceColor', [0.6 0.8 1], 'EdgeColor', 'b');
for n = 1:size(strips, 1)
    xl = max(strips(n,1), -xWin); xr = min(strips(n,2), xWin);
    if xr > xl, plot([xl xr]*1e6, [0 0], 'k', 'LineWidth', 3); end
end
xlim([-xWin xWin]*1e6); xlabel('x (\mum)'); ylabel('He height (nm)');
title(sprintf('Helium profile: %s', st.regime)); grid on;

%% Output
results = struct('params', P, 'strips', strips, 'epsSub', epsSub, 'H_op_m', H_op, ...
    'q_op', q_op, 'df_op_Hz', df_op, 'df_bulk_Hz', dfBulk, 'H_sweep_m', P.H_sweep_m, ...
    'q_above', qAbove, 'df_above_Hz', dfAbove, 'D_sweep_m', P.D_sweep_m, 'q_sub', qSub, ...
    'df_sub_Hz', dfSub, 'uniformFilm_m', dRef, 'q_uniformFilm', qRef, 'qCoverage', qCoverage);
end

%% ============================ LOCAL FUNCTIONS ============================
function [strips, info] = buildCrossSection(P)
% Strip list [x_left, x_right, V] sorted in x, including the ground planes.
switch lower(P.geometry)
    case 'spiral'
        w = P.traceWidth_m; p = w + P.traceGap_m; N = P.nTurns; r0 = P.innerRadius_m;
        kP = (0:N).';  kM = (0:N-1).';
        thP = 2*pi*kP;          rP = r0 + p*kP;          % crossings on +x
        thM = 2*pi*kM + pi;     rM = r0 + p*(kM + 0.5);  % crossings on -x
        sOf = @(th) r0*th + p*th.^2/(4*pi);              % arc length from inner end
        len = sOf(2*pi*N);
        switch lower(P.modeProfile)
            case 'open-open',      Vof = @(s) cos(pi*s/len);
            case 'outer-grounded', Vof = @(s) cos(pi*s/(2*len));
            case 'inner-grounded', Vof = @(s) sin(pi*s/(2*len));
            otherwise, error('Unknown modeProfile.');
        end
        S = [rP - w/2, rP + w/2, Vof(sOf(thP)); -rM - w/2, -rM + w/2, Vof(sOf(thM))];
        if P.innerPadRadius_m > 0
            if r0 - w/2 - P.innerPadRadius_m <= 0, error('Inner pad overlaps the first turn.'); end
            S = [S; -P.innerPadRadius_m, P.innerPadRadius_m, Vof(0)];
        end
        rOut = max(max(abs(S(:, 1:2))));
        if P.groundRadius_m <= rOut, error('Ground radius must exceed the outer turn.'); end
        Lg = P.groundWidthFactor*P.groundRadius_m;
        S = [S; P.groundRadius_m, P.groundRadius_m + Lg, 0; -P.groundRadius_m - Lg, -P.groundRadius_m, 0];
        info.description = sprintf(['w = %.2f um, g = %.2f um, N = %d turns, r0 = %.1f um, ', ...
            'outer turn r = %.1f um, ground edge r = %.1f um, wire length = %.2f mm, mode %s'], ...
            w*1e6, P.traceGap_m*1e6, N, r0*1e6, (r0 + p*N)*1e6, P.groundRadius_m*1e6, len*1e3, P.modeProfile);
        info.size = P.groundRadius_m;
        info.plotHalfWidth = 1.1*P.groundRadius_m;
    case 'cpw'
        a = P.cpwCenterWidth_m/2; b = a + P.cpwGap_m; Lg = 1000*b;
        S = [-a, a, 1; b, b + Lg, 0; -b - Lg, -b, 0];
        info.description = sprintf('CPW: w = %.3f um, s = %.3f um', 2*a*1e6, P.cpwGap_m*1e6);
        info.size = b;
        info.plotHalfWidth = 3*b;
    otherwise
        error('geometry must be ''spiral'' or ''cpw''.');
end
[~, idx] = sort(S(:,1)); strips = S(idx, :);
info.ground = strips(:,3) == 0 & (strips(:,2) - strips(:,1)) > 10*info.size;
end

function [pan, sigma, Wvac] = solveMoM(strips, P)
% Piecewise-constant charge density on edge-graded panels; collocation at
% panel midpoints; unknown potential offset C with total charge = 0 (2D).
pan = zeros(0, 3);                                      % [a, b, V]
for n = 1:size(strips, 1)
    xl = strips(n,1); xr = strips(n,2); W = xr - xl;
    if W > 100e-6 && strips(n,3) == 0                   % wide ground: geometric toward its inner edge
        dmin = P.minPanel_m; nG = ceil(log(W/dmin)/log(P.panelRatio));
        t = [0, dmin*P.panelRatio.^(0:nG-1)]; t = t(t < W); t = [t, W];
        if abs(xl) > abs(xr), t = xr - fliplr(t); else, t = xl + t; end  % refine toward edge nearer origin
    else                                                % geometric grading toward both edges
        dmin = P.minPanel_m; r = P.panelRatio;
        nH = max(ceil(log((W/2)/dmin)/log(r)), 1);
        th = [0, dmin*r.^(0:nH-1)]; th = th(th < W/2);  % half-strip breakpoints from the edge
        t = unique([xl + th, xl + W/2, xr - fliplr(th)]);
    end
    pan = [pan; t(1:end-1).', t(2:end).', strips(n,3)*ones(numel(t)-1, 1)]; %#ok<AGROW>
end
xm = (pan(:,1) + pan(:,2))/2; dl = pan(:,2) - pan(:,1);
F  = @(u) u.*log(abs(u) + (u == 0)) - u;               % antiderivative of ln|u|
A  = -(F(pan(:,2).' - xm) - F(pan(:,1).' - xm))/(2*pi);
Np = size(pan, 1);
sol = [A, ones(Np, 1); dl.', 0] \ [pan(:,3); 0];
sigma = sol(1:Np);
Wvac = 0.25*sum(sigma.*dl.*pan(:,3));                  % vacuum-half energy, all-vacuum problem
end

function G = buildGrid(strips, info)
% x: Gauss nodes on panels graded toward every conductor edge.
% y: absolute geometric panels from 0.1 nm to Y_max (Gauss nodes inside).
[g, gw] = gauss4();
edges = unique(strips(:, 1:2));
xMax  = max(abs(edges)); xMax = min(xMax, 50*info.size);
edges = edges(abs(edges) <= xMax);
edges = unique([-xMax; edges; xMax]);
x = []; xw = [];
for n = 1:numel(edges) - 1
    L = edges(n); R = edges(n+1);
    if R - L > 20*info.size, nP = 22; else, nP = 9; end
    [xi, wi] = gradedBoth(L, R, nP, 0.3, g, gw);
    x = [x; xi]; xw = [xw; wi];                         %#ok<AGROW>
end
yMax = 3*info.size; yMin = 1e-10; rho = 0.75;
nY = ceil(log(yMin/yMax)/log(rho));
yb = [0, yMax*rho.^(nY:-1:0)];                          % breakpoints, dense near 0
lo = yb(1:end-1); hi = yb(2:end); half = (hi - lo)/2; mid = (hi + lo)/2;
yN = mid + g*half;  yW = gw*half;                        % [4 x nPanels]
G.x = x; G.xw = xw; G.yBreaks = yb;
G.yNodes = yN(:).'; G.yW = yW(:).';
G.panelOfNode = repmat(1:numel(lo), 4, 1); G.panelOfNode = G.panelOfNode(:).';
[G.X, G.Y] = ndgrid(x, G.yNodes);
end

function E2 = fieldSquared(X, Y, pan, sigma)
% |E|^2 from uniformly charged panels (eps0 = 1), evaluated analytically.
Ex = zeros(size(X)); Ey = Ex;
for j = 1:size(pan, 1)
    a = pan(j,1); b = pan(j,2); s = sigma(j);
    if s == 0, continue; end
    Ex = Ex + s/(4*pi)*log(((X - a).^2 + Y.^2)./((X - b).^2 + Y.^2));
    Ey = Ey + s/(2*pi)*(atan((X - a)./Y) - atan((X - b)./Y));
end
E2 = Ex.^2 + Ey.^2;
end

function Icum = cumEnergy(E2, G)
% Cumulative integral of |E|^2 dy at the y breakpoints, for every x node.
nPan = numel(G.yBreaks) - 1;
Ipan = zeros(size(E2, 1), nPan);
contrib = E2 .* G.yW;                                 % implicit expansion over rows
for k = 1:nPan
    Ipan(:, k) = sum(contrib(:, G.panelOfNode == k), 2);
end
Icum = [zeros(size(E2, 1), 1), cumsum(Ipan, 2)];
end

function q = layerParticipation(h, G, Icum, Wvac)
% Fraction of vacuum-side energy in 0 < y < h(x); linear interpolation of the
% cumulative energy within a y panel.
yb = G.yBreaks; h = min(max(h(:), 0), yb(end));
k  = min(floor(interp1(yb, 1:numel(yb), h)), numel(yb) - 1);   % panel index containing h
nx = numel(h); idxLo = sub2ind(size(Icum), (1:nx).', k); idxHi = sub2ind(size(Icum), (1:nx).', k + 1);
yLo = reshape(yb(k), [], 1); yHi = reshape(yb(k + 1), [], 1);
frac = (h - yLo)./(yHi - yLo);
Ih = Icum(idxLo) + frac.*(Icum(idxHi) - Icum(idxLo));
q = 0.5*sum(G.xw .* Ih)/Wvac;
end

function [h, st] = heliumProfile(x, Hsigned, gaps, tGap, P, g0)
% Helium height h(x) on the vacuum side (mapped coordinate, see header).
x = x(:); h = zeros(size(x));
gw = gaps(:,2) - gaps(:,1); [~, iNarrow] = min(gw);
if Hsigned > 0
    H = Hsigned; dFilm = vdwFilm(H, P); Rc = P.sigma_He/(P.rho_He*g0*H);
    h(:) = dFilm; levelNarrow = dFilm;
    for i = 1:size(gaps, 1)
        in = x > gaps(i,1) & x < gaps(i,2);
        if ~any(in) || Rc <= gw(i)/2, continue; end
        xc = mean(gaps(i,:)); yC = tGap + sqrt(Rc^2 - (gw(i)/2)^2);
        men = yC - sqrt(max(Rc^2 - (x(in) - xc).^2, 0));
        h(in) = max(men, dFilm);
        if i == iNarrow, levelNarrow = max(yC - Rc, dFilm); end
    end
    if levelNarrow >= 0.9*tGap,   regime = 'vdW film + capillary-filled gaps';
    elseif levelNarrow > dFilm,   regime = 'vdW film + partially filled gaps';
    else,                         regime = 'vdW film only';
    end
    st = struct('dFilm', dFilm, 'Rc', Rc, 'levelNarrowGap', levelNarrow, 'regime', regime);
else
    D = -Hsigned; h(:) = D;
    for i = 1:size(gaps, 1)
        in = x > gaps(i,1) & x < gaps(i,2); h(in) = D + tGap;
    end
    st = struct('dFilm', D, 'Rc', Inf, 'levelNarrowGap', D + tGap, 'regime', 'submerged');
end
end

function d = vdwFilm(H, P)
d = P.filmRef_m .* (P.filmRefHeight_m ./ H).^(1/P.filmExponent);
end

function [x, w] = gradedBoth(L, R, nPan, ratio, g, gw)
% Gauss nodes on panels graded geometrically toward both ends of [L, R].
t = [0, ratio.^(nPan-1:-1:0)]/2;                        % in [0, 1/2], dense at 0
t = unique([t, 1 - fliplr(t)]);
lo = t(1:end-1); hi = t(2:end); half = (hi - lo)/2; mid = (hi + lo)/2;
x = mid + g*half; w = gw*half;
x = L + (R - L)*x(:); w = (R - L)*w(:);
end

function [g, w] = gauss4()
g = [-0.8611363115940526; -0.3399810435848563; 0.3399810435848563; 0.8611363115940526];
w = [ 0.3478548451374538;  0.6521451548625461; 0.6521451548625461; 0.3478548451374538];
end

function refLine(dirn, val, label)
if dirn == 'h', xl = xlim; plot(xl, [val val], 'k--', 'DisplayName', label);
else,           yl = ylim; plot([val val], yl, 'k:', 'DisplayName', label);
end
end
