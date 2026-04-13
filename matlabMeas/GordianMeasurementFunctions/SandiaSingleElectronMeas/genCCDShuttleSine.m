function genCCDShuttleSine(AWG1, AWG2, AWG3, F_SLOW, F_FAST, V_HIGH, V_LOW)
% generateCCDShuttleWaveformsSine(AWG1, AWG2, AWG3, F_SLOW, F_FAST, V_HIGH, V_LOW)
%
%   Full round-trip CCD electron shuttle sequence — sinusoidal gate transitions.
%   Each gate transition is a smooth raised cosine. Non-transitioning channels
%   hold their constant HI or LO value within each gate period.
%
% REQUIRED:
%   AWG1, AWG2, AWG3  — instrument handles
%
% OPTIONAL (use [] or omit to accept defaults):
%   F_SLOW   Slow gate clock frequency in Hz  (default: 40e3  = 40  kHz)
%   F_FAST   Fast gate clock frequency in Hz  (default: 900e3 = 900 kHz)
%   V_HIGH   High voltage level in V          (default: +2.0 V)
%   V_LOW    Low  voltage level in V          (default: -1.0 V)
%
% MID voltage is always (V_HIGH + V_LOW) / 2.
%
% The AWG sample rate is chosen automatically to give SPG_SLOW >= 120
% samples per slow gate (for a smooth cosine shape) while keeping
% SRATE <= 250 MSa/s.
%
% Channel assignment:
%   AWG1 CH1->H1  AWG1 CH2->H2
%   AWG2 CH1->H3  AWG2 CH2->V1
%   AWG3 CH1->V2  AWG3 CH2->V3

    %% ----------------------------------------------------------------- %%
    %  Defaults
    %% ----------------------------------------------------------------- %%
    if nargin < 4 || isempty(F_SLOW),  F_SLOW = 40e3;   end
    if nargin < 5 || isempty(F_FAST),  F_FAST = 900e3;  end
    if nargin < 6 || isempty(V_HIGH),  V_HIGH =  2.0;   end
    if nargin < 7 || isempty(V_LOW),   V_LOW  = -1.0;   end

    %% ----------------------------------------------------------------- %%
    %  Derived voltage levels
    %% ----------------------------------------------------------------- %%
    V_MID  = (V_HIGH + V_LOW) / 2;
    V_SPAN =  V_HIGH - V_LOW;
    HI = 1.0;
    MI = (V_MID - V_LOW) / V_SPAN;   % always 0.5 regardless of V levels
    LO = 0.0;

    %% ----------------------------------------------------------------- %%
    %  Sample rate and gate sizes
    %
    %  For sine transitions the only constraint is SPG >= 12 for a smooth
    %  cosine shape (more is better). SRATE chosen as smallest multiple of
    %  lcm(F_SLOW, F_FAST) giving SPG_SLOW >= 120 and SRATE <= 250 MSa/s.
    %% ----------------------------------------------------------------- %%
    MAX_SRATE = 250e6;

    lcm_constraint = lcm(round(F_SLOW), round(F_FAST));
    % Aim for SPG_SLOW >= 120 for a visually smooth cosine
    k = max(1, ceil(120 * F_SLOW / lcm_constraint));
    SRATE = k * lcm_constraint;

    if SRATE > MAX_SRATE
        error(['Cannot satisfy timing constraints within 250 MSa/s.\n' ...
               'F_SLOW=%.0f Hz, F_FAST=%.0f Hz require SRATE=%.3f MSa/s.\n' ...
               'Try reducing F_FAST or increasing F_SLOW.'], ...
               F_SLOW, F_FAST, SRATE/1e6);
    end

    SPG_SLOW = round(SRATE / F_SLOW);   % samples per slow gate
    SPG_FAST = round(SRATE / F_FAST);   % samples per fast gate

    % Round to nearest integer
    SPG_SLOW = max(12, round(SPG_SLOW));
    SPG_FAST = max(6,  round(SPG_FAST));
    % SEG sizes: for sine, use half-SPG as the transition region
    SEG_SLOW = round(SPG_SLOW / 2);
    SEG_FAST = round(SPG_FAST / 2);
    assert(SRATE <= MAX_SRATE, 'SRATE exceeds 250 MSa/s');

    fprintf('--- Timing ---\n');
    fprintf('SRATE    : %.4f MSa/s\n', SRATE/1e6);
    fprintf('F_SLOW   : %.2f kHz  -> SPG_SLOW = %d samples  (%.2f us)\n', ...
            F_SLOW/1e3, SPG_SLOW, SPG_SLOW/SRATE*1e6);
    fprintf('F_FAST   : %.2f kHz  -> SPG_FAST = %d samples  (%.3f us)\n', ...
            F_FAST/1e3, SPG_FAST, SPG_FAST/SRATE*1e6);
    fprintf('V_HIGH   : %.2f V  V_MID : %.2f V  V_LOW : %.2f V\n', ...
            V_HIGH, V_MID, V_LOW);

    %% ----------------------------------------------------------------- %%
    %  Sequence counts (unchanged)
    %% ----------------------------------------------------------------- %%
    N_HGATES    = 5;
    N_SLOW_INIT = 4;
    N_FAST_PIX  = 75;
    N_INTER_PIX = 5;
    N_REPEATS   = 5;

    %% ----------------------------------------------------------------- %%
    %  Primitive builders — sinusoidal transitions
    %
    %  G(va, ~, vc, spg) produces a gate of length spg samples:
    %    va == vc  -> flat at va (constant)
    %    va != vc  -> flat at va for (spg-seg)/2 samples,
    %                 raised cosine from va to vc over seg samples,
    %                 flat at vc for (spg-seg)/2 samples
    %  where seg = SEG (half of spg by default).
    %  The middle argument vb is accepted for API compatibility but ignored.
    %% ----------------------------------------------------------------- %%
    function s = G(va, ~, vc, spg, seg)
        if nargin < 5, seg = round(spg/2); end
        if va == vc
            s = repmat(va, 1, spg);
            return;
        end
        n_flat = floor((spg - seg) / 2);
        n_tail = spg - seg - n_flat;   % absorb rounding
        t      = (0:seg-1) / seg;
        trans  = va + (vc - va) * 0.5 * (1 - cos(pi * t));
        s      = [repmat(va,1,n_flat), trans, repmat(vc,1,n_tail)];
    end
    Gs  = @(a,b,c) G(a,b,c,SPG_SLOW,SEG_SLOW);
    Gf  = @(a,b,c) G(a,b,c,SPG_FAST,SEG_FAST);
    Fls = @(v)     repmat(v,1,SPG_SLOW);
    Flf = @(v)     repmat(v,1,SPG_FAST);

    %% ----------------------------------------------------------------- %%
    %  Section builders
    %% ----------------------------------------------------------------- %%

    % One slow vertical pixel — charge starts on V3
    % G1: V3->V1   G2: V1->V2   G3: V2->V3
    function [v1,v2,v3] = slowVpix()
        v1 = [Gs(LO,MI,HI), Gs(HI,MI,LO), Fls(LO)     ];
        v2 = [Fls(LO),      Gs(LO,MI,HI), Gs(HI,MI,LO)];
        v3 = [Gs(HI,MI,LO), Fls(LO),      Gs(LO,MI,HI)];
    end

    % One slow vertical pixel — charge starts on V1 (no V3->V1 prefix gate)
    % G1: V1->V2   G2: V2->V3   G3: V3->V1
    % Used as the first pixel after buildFS where V1 is already HI.
    % Subsequent pixels continue with slowVpix (charge back on V3 after G3).
    function [v1,v2,v3] = slowVpixFromV1()
        v1 = [Gs(HI,MI,LO), Fls(LO),       Gs(LO,MI,HI)];
        v2 = [Gs(LO,MI,HI), Gs(HI,MI,LO),  Fls(LO)     ];
        v3 = [Fls(LO),       Gs(LO,MI,HI),  Gs(HI,MI,LO)];
    end
    % Note: slowVpixFromV1 ends with V3->V1 (G3), leaving charge on V1.
    % So subsequent pixels after it must also use slowVpixFromV1, OR we
    % need to track that charge ends on V1 not V3.
    % Simplest: build all N_INTER_PIX pixels starting from V1 using
    % buildSlowVfromV1 which chains correctly: each pixel is V1->V2->V3->V1.

    % N slow pixels starting from V1 HI — each pixel: V1->V2, V2->V3, V3->V1
    % Charge exits on V1 after last pixel (last gate is V3->V1).
    % BUT we want charge on V3 after the slow section (for next ST gate).
    % So use N pixels of slowVpixFromV1 then drop the last V3->V1 gate,
    % leaving charge on V3.
    function [v1,v2,v3] = buildSlowVfromV1(N)
        % N full pixels: V1->V2->V3->V1 repeated
        [pv1,pv2,pv3] = slowVpixFromV1();
        v1 = repmat(pv1,1,N);
        v2 = repmat(pv2,1,N);
        v3 = repmat(pv3,1,N);
        % Trim the last gate (V3->V1) so charge parks on V3 for next ST gate
        trim = SPG_SLOW;
        v1 = v1(1:end-trim);
        v2 = v2(1:end-trim);
        v3 = v3(1:end-trim);
    end

    % One fast vertical pixel — charge starts on V1
    % G1: V1->V2   G2: V2->V3   G3: V3->V1
    function [v1,v2,v3] = fastVpix()
        v1 = [Gf(HI,MI,LO), Flf(LO),       Gf(LO,MI,HI)];
        v2 = [Gf(LO,MI,HI), Gf(HI,MI,LO),  Flf(LO)     ];
        v3 = [Flf(LO),       Gf(LO,MI,HI),  Gf(HI,MI,LO)];
    end

    % N slow vertical pixels
    function [v1,v2,v3] = buildSlowV(N)
        [pv1,pv2,pv3] = slowVpix();
        v1=repmat(pv1,1,N); v2=repmat(pv2,1,N); v3=repmat(pv3,1,N);
    end

    % N fast vertical pixels — charge starts on V1 HI (coming from ST gate)
    % G1: V1->V2   G2: V2->V3   G3: V3->V1  (repeating)
    % leaveOnV2: if true, stop after G2 of last pixel (V3 still HI, V2 just fell)
    %            so the FS gate can do the mirror of ST cleanly.
    function [v1,v2,v3] = buildFastV(N, leaveOnV2)
        if nargin < 2, leaveOnV2 = false; end
        [pv1,pv2,pv3] = fastVpix();
        if ~leaveOnV2
            v1=repmat(pv1,1,N); v2=repmat(pv2,1,N); v3=repmat(pv3,1,N);
        else
            % Build N-1 full pixels then the first 2 gates of the last pixel
            % G1 (V1->V2) + G2 (V2->V3): leaves V3 HI after rising
            g1v1=Gf(HI,MI,LO); g1v2=Gf(LO,MI,HI); g1v3=Flf(LO);
            g2v1=Flf(LO);      g2v2=Gf(HI,MI,LO); g2v3=Gf(LO,MI,HI);
            tail_v1 = [g1v1, g2v1];
            tail_v2 = [g1v2, g2v2];
            tail_v3 = [g1v3, g2v3];
            if N > 1
                v1=[repmat(pv1,1,N-1), tail_v1];
                v2=[repmat(pv2,1,N-1), tail_v2];
                v3=[repmat(pv3,1,N-1), tail_v3];
            else
                v1=tail_v1; v2=tail_v2; v3=tail_v3;
            end
        end
    end

    % FS gate: mirror image of ST gate.
    % Called after buildFastV(..., leaveOnV2=true), so V3 is HI coming in.
    % Structure:
    %   Fast tail : HALF_FAST samples — V3 stays HI (first half of fast gate)
    %   Slow gate : SPG_SLOW samples — V3 [HI|MI|LO], V1 [LO|MI|HI]
    % This gives V3 a half-fast-gate HI cap then a slow fall, while V1
    % rises slowly — exact mirror of the slow rise + fast drop in ST.
    function [v1,v2,v3] = buildFS()
        % Fast->slow transition gate.
        % V3 is HI coming in (was DST of last fast gate).
        % Fast tail: HALF_FAST samples holding V3=HI, V1/V2=LO.
        % Then one slow gate: V3 falls (Gs HI->LO), V1 rises (Gs LO->HI).
        HF   = round(SPG_FAST / 2);
        ft_v1 = repmat(LO, 1, HF);
        ft_v2 = repmat(LO, 1, HF);
        ft_v3 = repmat(HI, 1, HF);
        sg_v1 = Gs(LO, MI, HI);   % smooth cosine rise
        sg_v2 = Fls(LO);
        sg_v3 = Gs(HI, MI, LO);   % smooth cosine fall
        v1 = [ft_v1, sg_v1];
        v2 = [ft_v2, sg_v2];
        v3 = [ft_v3, sg_v3];
    end

    function [v1,v2,v3] = buildST()
        % Slow->fast transition gate (one slow gate).
        % V3 falls (Gs HI->LO), V1 rises (Gs LO->HI), V2 flat LO.
        v1 = Gs(LO, MI, HI);
        v2 = Fls(LO);
        v3 = Gs(HI, MI, LO);
    end


    % Forward horizontal: H1->H2->H3->H1->H2 (5 gates)
    % Gate 5 hands charge to V2 (V1 stays LOW)
    function [h1,h2,h3,v1,v2,v3] = buildForwardH()
        z=Fls(LO);
        g1h1=Gs(HI,MI,LO); g1h2=Gs(LO,MI,HI); g1h3=z;           % H1->H2
        g2h1=z;             g2h2=Gs(HI,MI,LO); g2h3=Gs(LO,MI,HI);% H2->H3
        g3h1=Gs(LO,MI,HI); g3h2=z;             g3h3=Gs(HI,MI,LO);% H3->H1
        g4h1=Gs(HI,MI,LO); g4h2=Gs(LO,MI,HI); g4h3=z;           % H1->H2
        g5h1=z;             g5h2=Gs(HI,MI,LO); g5h3=z;           % H2->V2
        g5v2=Gs(LO,MI,HI);

        h1=[g1h1,g2h1,g3h1,g4h1,g5h1];
        h2=[g1h2,g2h2,g3h2,g4h2,g5h2];
        h3=[g1h3,g2h3,g3h3,g4h3,g5h3];
        v1=repmat(LO,1,5*SPG_SLOW);
        v2=[z,z,z,z,g5v2];
        v3=repmat(LO,1,5*SPG_SLOW);
    end

    % CCD1->CCD2 handoff: V2 falls, V3 rises (V1 stays LOW)
    function [h1,h2,h3,v1,v2,v3] = buildHandoff()
        z=Fls(LO);
        h1=z; h2=z; h3=z; v1=Fls(LO);
        v2=Gs(HI,MI,LO); v3=Gs(LO,MI,HI);
    end

    % Return transition: V1->V2->H2 (2 slow gates, H1/H3 stay LOW)
    % Called after FS gate which leaves charge on V1=HI.
    % R1: V1->V2   R2: V2->H2  (H1/H3 stay LOW throughout)
    function [h1,h2,h3,v1,v2,v3] = buildReturnTrans()
        z = Fls(LO);
        h1 = repmat(LO, 1, 2*SPG_SLOW);
        h3 = repmat(LO, 1, 2*SPG_SLOW);
        h2 = [z,             Gs(LO,MI,HI)];   % H2 rises in R2
        v1 = [Gs(HI,MI,LO), z            ];   % V1 falls in R1
        v2 = [Gs(LO,MI,HI), Gs(HI,MI,LO)];   % V2 rises R1, falls R2
        v3 = [z,             z            ];   % V3 stays LOW
    end

    % Reverse horizontal: H2->H1->H3->H2->H1 (5 gates, mirror of forward)
    % Charge arrives on H2. Each gate: destination rises, source falls.
    function [h1,h2,h3,v1,v2,v3] = buildReverseH()
        z=Fls(LO);
        r1h1=Gs(LO,MI,HI); r1h2=Gs(HI,MI,LO); r1h3=z;           % H2->H1
        r2h1=Gs(HI,MI,LO); r2h2=z;             r2h3=Gs(LO,MI,HI);% H1->H3
        r3h1=z;             r3h2=Gs(LO,MI,HI); r3h3=Gs(HI,MI,LO);% H3->H2
        r4h1=Gs(LO,MI,HI); r4h2=Gs(HI,MI,LO); r4h3=z;           % H2->H1
        r5h1=Gs(HI,HI,HI); r5h2=z;             r5h3=z;            % H1 holds

        h1=[r1h1,r2h1,r3h1,r4h1,r5h1];
        h2=[r1h2,r2h2,r3h2,r4h2,r5h2];
        h3=[r1h3,r2h3,r3h3,r4h3,r5h3];
        v1=repmat(LO,1,5*SPG_SLOW);
        v2=repmat(LO,1,5*SPG_SLOW);
        v3=repmat(LO,1,5*SPG_SLOW);
    end

    %% ----------------------------------------------------------------- %%
    %  Assemble
    %% ----------------------------------------------------------------- %%
    [fH1,fH2,fH3,fV1,fV2,fV3]   = buildForwardH();
    [hH1,hH2,hH3,hV1,hV2,hV3]   = buildHandoff();
    [siV1,siV2,siV3]             = buildSlowV(N_SLOW_INIT);
    siH = zeros(1,N_SLOW_INIT*3*SPG_SLOW);

    % Fast block: stop after V2->V3 of last pixel (V3 ends HI, ready for FS)
    [fv1,fv2,fv3]    = buildFastV(N_FAST_PIX, true);

    % FS gate: half-fast HI tail on V3, then slow V3 fall + V1 rise
    [fsv1,fsv2,fsv3] = buildFS();

    % ST gate: slow V3 fall + V1 rise, V1 ends HI for fast section
    [stv1,stv2,stv3] = buildST();

    % Slow pixels after FS: charge arrives on V1 HI after FS.
    % buildSlowVfromV1 does N pixels of V1->V2->V3->V1, then trims
    % the last V3->V1 gate so charge parks on V3 ready for next ST gate.
    [isv1,isv2,isv3] = buildSlowVfromV1(N_INTER_PIX);

    HZ_F   = zeros(1, length(fv1));
    HZ_FS  = zeros(1, length(fsv1));
    HZ_ST  = zeros(1, length(stv1));
    HZ_IS  = zeros(1, length(isv1));

    V1r=[]; V2r=[]; V3r=[]; Hr=[];
    for r = 1:N_REPEATS
        isLast = (r == N_REPEATS);

        % ST gate then fast block (fast ends with V3 HI after V2->V3)
        V1r=[V1r, stv1, fv1];
        V2r=[V2r, stv2, fv2];
        V3r=[V3r, stv3, fv3];
        Hr =[Hr,  HZ_ST, HZ_F];

        % FS gate always (mirrors the fast->slow transition)
        V1r=[V1r, fsv1];
        V2r=[V2r, fsv2];
        V3r=[V3r, fsv3];
        Hr =[Hr,  HZ_FS];

        if ~isLast
            % Inter-burst: 5 slow pixels to park charge on V3 for next ST gate
            V1r=[V1r, isv1];
            V2r=[V2r, isv2];
            V3r=[V3r, isv3];
            Hr =[Hr,  HZ_IS];
        end
        % On last repeat: no slow pixels — FS leaves V1=HI and return
        % transition (V3->V1->V2->H2) takes over directly.
    end

    [rtH1,rtH2,rtH3,rtV1,rtV2,rtV3] = buildReturnTrans();
    [rH1,rH2,rH3,rV1,rV2,rV3]       = buildReverseH();

    wH1=[fH1,hH1,siH, Hr, rtH1,rH1];
    wH2=[fH2,hH2,siH, Hr, rtH2,rH2];
    wH3=[fH3,hH3,siH, Hr, rtH3,rH3];
    wV1=[fV1,hV1,siV1,V1r,rtV1,rV1];
    wV2=[fV2,hV2,siV2,V2r,rtV2,rV2];
    wV3=[fV3,hV3,siV3,V3r,rtV3,rV3];

    % Append exact mirror (reverse trip) — fliplr reverses both gate order
    % and voltage transitions within each gate, giving a perfect time-mirror.
    wH1=[wH1, fliplr(wH1)];
    wH2=[wH2, fliplr(wH2)];
    wH3=[wH3, fliplr(wH3)];
    wV1=[wV1, fliplr(wV1)];
    wV2=[wV2, fliplr(wV2)];
    wV3=[wV3, fliplr(wV3)];

    N = max([length(wH1),length(wH2),length(wH3), ...
             length(wV1),length(wV2),length(wV3)]);
    pad=@(w)[w,repmat(LO,1,N-length(w))];
    wH1=pad(wH1); wH2=pad(wH2); wH3=pad(wH3);
    wV1=pad(wV1); wV2=pad(wV2); wV3=pad(wV3);

    %% ----------------------------------------------------------------- %%
    %  Sanity checks
    %% ----------------------------------------------------------------- %%
    assert(all(wH1>=0&wH1<=1),'H1 out of [0,1]');
    assert(all(wH2>=0&wH2<=1),'H2 out of [0,1]');
    assert(all(wH3>=0&wH3<=1),'H3 out of [0,1]');
    assert(all(wV1>=0&wV1<=1),'V1 out of [0,1]');
    assert(all(wV2>=0&wV2<=1),'V2 out of [0,1]');
    assert(all(wV3>=0&wV3<=1),'V3 out of [0,1]');

    %% ----------------------------------------------------------------- %%
    %  Report
    %% ----------------------------------------------------------------- %%
    n_fh=N_HGATES*SPG_SLOW; n_hf=SPG_SLOW; n_si=N_SLOW_INIT*3*SPG_SLOW;
    n_rep=length(V1r); n_rt=2*SPG_SLOW; n_rh=N_HGATES*SPG_SLOW;
    n_fwd = n_fh+n_hf+n_si+n_rep+n_rt+n_rh;  % length of forward half
    fprintf('=== CCD Shuttle Waveform ===\n');
    fprintf('Total        : %d samples = %.3f ms (round-trip)\n',N,N/SRATE*1e3);
    fprintf('Forward half : %d samples = %.3f ms\n',n_fwd,n_fwd/SRATE*1e3);
    fprintf('Reverse half : %d samples (fliplr mirror)\n',n_fwd);
    fprintf('Fwd H        : %6d samp\n',n_fh);
    fprintf('Hndff V2->V3 : %6d samp\n',n_hf);
    fprintf('Init slow V  : %6d samp  (%d pixels)\n',n_si,N_SLOW_INIT);
    fprintf('Repeats x%d  : %6d samp\n',N_REPEATS,n_rep);
    fprintf('Return trans : %6d samp\n',n_rt);
    fprintf('Rev H        : %6d samp\n',n_rh);

    %% ----------------------------------------------------------------- %%
    %  Upload
    %% ----------------------------------------------------------------- %%
    % fprintf('\nUploading at %.2f MSa/s...\n',SRATE/1e6);
    % configAWG(AWG1,1,wH1,SRATE,V_LOW,V_HIGH); pause(0.5);
    % configAWG(AWG1,2,wH2,SRATE,V_LOW,V_HIGH); pause(0.5);
    % configAWG(AWG2,1,wH3,SRATE,V_LOW,V_HIGH); pause(0.5);
    % configAWG(AWG2,2,wV1,SRATE,V_LOW,V_HIGH); pause(0.5);
    % configAWG(AWG3,1,wV2,SRATE,V_LOW,V_HIGH); pause(0.5);
    % configAWG(AWG3,2,wV3,SRATE,V_LOW,V_HIGH);
    % fprintf('Upload complete.\n');

    %% ----------------------------------------------------------------- %%
    %  Plots
    %% ----------------------------------------------------------------- %%
    % Overview: show both forward and reverse halves
    bounds_fwd = cumsum([n_fh,n_hf,n_si,n_rep,n_rt,n_rh]);
    bounds_rev = n_fwd + (n_fwd - fliplr(bounds_fwd));
    bounds_all = [bounds_fwd, n_fwd, bounds_rev];
    plotOverview(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,V_LOW,V_HIGH, ...
        [bounds_fwd, n_fwd, n_fwd+bounds_fwd], ...
        {'Fwd H','Hndff','Slow','Rpts','Ret','RevH','<-->','RevH','Ret','Rpts','Slow','Hndff','Rev H'});

    % Zoom: forward horizontal start
    plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,V_LOW,V_HIGH, ...
        1, 8*SPG_SLOW, 'Zoom: forward horizontal');

    % Zoom: first slow->fast transition
    idx_st1 = n_fh + n_hf + n_si;
    plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,V_LOW,V_HIGH, ...
        idx_st1 - 3*SPG_SLOW, idx_st1 + SPG_SLOW + 12*SPG_FAST, ...
        'Zoom: first slow->fast transition');

    % Zoom: first fast->slow transition
    n_fast_block = (N_FAST_PIX*3 - 1) * SPG_FAST;
    idx_fs1 = idx_st1 + SPG_SLOW + n_fast_block;
    plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,V_LOW,V_HIGH, ...
        idx_fs1 - 12*SPG_FAST, idx_fs1 + 4*SPG_SLOW, ...
        'Zoom: first fast->slow transition');

    % Zoom: turnaround point (end of forward rev-H, start of reverse fwd-H)
    idx_turn = n_fwd;
    plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,V_LOW,V_HIGH, ...
        idx_turn - 4*SPG_SLOW, idx_turn + 4*SPG_SLOW, ...
        'Zoom: turnaround (fwd rev-H -> rev fwd-H)');

    % Zoom: return transition (forward half)
    idx_rt = n_fh + n_hf + n_si + n_rep;
    plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,V_LOW,V_HIGH, ...
        idx_rt - 2*SPG_SLOW, idx_rt + n_rt + 4*SPG_SLOW, ...
        'Zoom: return transition V3->H2 (forward half)');
end


%% ====================================================================== %%
function plotOverview(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,vlow,vhigh,bounds,slabels)
    N=length(wH1); vspan=vhigh-vlow;
    toV=@(x) x*vspan+vlow;
    t_ms=(0:N-1)/SRATE*1e3;
    phases={toV(wH1),toV(wH2),toV(wH3),toV(wV1),toV(wV2),toV(wV3)};
    labels={'H1','H2','H3','V1','V2','V3'};
    colors={'#0072BD','#D95319','#77AC30','#7E2F8E','#EDB120','#4DBEEE'};
    bms=bounds/SRATE*1e3;

    figure('Name','Full sequence overview','NumberTitle','off', ...
           'Position',[60 60 1400 820]);
    for k=1:6
        ax=subplot(6,1,k);
        plot(t_ms,phases{k},'Color',colors{k},'LineWidth',1.2);
        hold on;
        for b=1:length(bms)
            xline(bms(b),'-','Color',[0.35 0.35 0.35],'LineWidth',1,'Alpha',0.6);
        end
        yline(vhigh,':r','LineWidth',0.7);
        yline(0.5,':','Color',[0.6 0.6 0],'LineWidth',0.7);
        yline(vlow,':b','LineWidth',0.7);
        ylim([vlow-0.4,vhigh+0.5]); yticks([vlow,0.5,vhigh]);
        yticklabels({'-1V','+0.5V','+2V'});
        ylabel(labels{k},'FontWeight','bold','FontSize',8);
        set(ax,'XTickLabel',[]); grid on; box off;
        if k==1
            prev=0;
            for b=1:length(bms)
                text((prev+bms(b))/2,vhigh+0.3,slabels{b}, ...
                    'HorizontalAlignment','center','FontSize',7,'Color',[0.3 0.3 0.3]);
                prev=bms(b);
            end
        end
    end
    subplot(6,1,6); set(gca,'XTickLabelMode','auto'); xlabel('Time (ms)');
    sgtitle(sprintf('Round-trip CCD shuttle  |  %.2f MSa/s  |  %d samp  |  %.3f ms', ...
                    SRATE/1e6,N,N/SRATE*1e3),'FontSize',10);
end


%% ====================================================================== %%
function plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,vlow,vhigh,i1,i2,titleStr)
    i1=max(1,round(i1)); i2=min(length(wH1),round(i2));
    idx=i1:i2; vspan=vhigh-vlow;
    toV=@(x) x*vspan+vlow;
    t_us=(idx-1)/SRATE*1e6;
    phases={toV(wH1(idx)),toV(wH2(idx)),toV(wH3(idx)), ...
            toV(wV1(idx)),toV(wV2(idx)),toV(wV3(idx))};
    labels={'H1','H2','H3','V1','V2','V3'};
    colors={'#0072BD','#D95319','#77AC30','#7E2F8E','#EDB120','#4DBEEE'};

    figure('Name',titleStr,'NumberTitle','off','Position',[100 100 1200 720]);
    for k=1:6
        ax=subplot(6,1,k);
        stairs(t_us,phases{k},'Color',colors{k},'LineWidth',1.8);
        hold on;
        yline(vhigh,':r','LineWidth',0.8);
        yline(0.5,':','Color',[0.55 0.55 0],'LineWidth',0.8);
        yline(vlow,':b','LineWidth',0.8);
        ylim([vlow-0.4,vhigh+0.5]); yticks([vlow,0.5,vhigh]);
        yticklabels({'-1V','+0.5V','+2V'});
        ylabel(labels{k},'FontWeight','bold','FontSize',8);
        xlim([t_us(1),t_us(end)]);
        set(ax,'XTickLabel',[]); grid on; box off;
    end
    subplot(6,1,6); set(gca,'XTickLabelMode','auto'); xlabel('Time (µs)');
    sgtitle(sprintf('%s  |  %.2f MSa/s',titleStr,SRATE/1e6),'FontSize',10);
end