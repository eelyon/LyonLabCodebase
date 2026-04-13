function genCCDShuttlePulse(awg1,awg2,awg3,varargin)
% generateCCDShuttleWaveforms(awg1, awg2, awg3, f_slow, f_fast, v_high, v_low)
%
%   Full round-trip CCD electron shuttle sequence.
%
% REQUIRED:
%   awg1, awg2, awg3  — instrument handles
%
% OPTIONAL:
%   f_slow   Slow gate clock frequency in Hz  (default: 40e3  = 40  kHz)
%   f_fast   Fast gate clock frequency in Hz  (default: 900e3 = 900 kHz)
%   v_high   High voltage level in V          (default: +2.0 V)
%   v_low    Low  voltage level in V          (default: -1.0 V)
%   nbursts   Number of nbursts/repeats       (default: 1)
%
% MID voltage is always (v_high + v_low) / 2.
%
% The AWG sample rate is chosen automatically as the lowest value that:
%   - gives an integer number of samples per slow gate divisible by 3
%   - gives an integer number of samples per fast gate divisible by 6
%     (divisible by 6 so HALf_fast = SPG_FAST/2 is also an integer)
%   - does not exceed 160 MSa/s (33512B limit)
%
% Channel assignment:
%   awg1 CH1->H1  awg1 CH2->H2
%   awg2 CH1->H3  awg2 CH2->V1
%   awg3 CH1->V2  awg3 CH2->V3

    %%  Defaults
    p = inputParser;
    isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    p.addParameter('f_slow', 40e3, isnonneg);
    p.addParameter('f_fast', 900e3, isnonneg);
    p.addParameter('v_high', 2.0, isnonneg);
    p.addParameter('v_low', -1.0, @(x) isnumeric(x) && isscalar(x));
    p.addParameter('nbursts', 1, isnonneg);
    p.parse(varargin{:});
    
    f_slow = p.Results.f_slow; % sigDACRampVoltage
    f_fast = p.Results.f_fast; % sigDACRamp
    v_high = p.Results.v_high; % in microseconds
    v_low = p.Results.v_low; % holding voltage of ccd
    nbursts = p.Results.nbursts; % closing voltage of ccd

    %%  Derived voltage levels
    V_MID  = (v_high + v_low) / 2;
    V_SPAN =  v_high - v_low;
    HI = 1.0;
    MI = (V_MID - v_low) / V_SPAN;
    LO = 0.0;

    %%  Sample rate and gate sizes
    %
    %  We need:
    %    SRATE = SPG_SLOW * f_slow  (integer SPG_SLOW, divisible by 3)
    %    SRATE = SPG_FAST * f_fast  (integer SPG_FAST, divisible by 6)
    %
    %  Strategy: find the smallest SRATE = k * lcm(f_slow*3, f_fast*6)
    %  that keeps both SPG values reasonable (>= 6 for slow, >= 6 for fast)
    %  and SRATE <= 160 MSa/s.
    MAX_SRATE = 160e6;

    % SPG must be divisible by 3 for slow, by 6 for fast.
    % Find LCM of the two constraints on SRATE:
    %   SRATE must be divisible by (f_slow * 3) and by (f_fast * 6)
    lcm_constraint = lcm(round(f_slow * 3), round(f_fast * 6));

    % Find smallest multiple of lcm_constraint giving SPG_SLOW >= 9
    k = max(1, ceil(9 * f_slow / lcm_constraint));
    SRATE = k * lcm_constraint * 10;

    if SRATE > MAX_SRATE
        error(['Cannot satisfy timing constraints within 160 MSa/s.\n' ...
               'f_slow=%.0f Hz, f_fast=%.0f Hz require SRATE=%.3f MSa/s.\n' ...
               'Try reducing f_fast or increasing f_slow.'], ...
               f_slow, f_fast, SRATE/1e6);
    end

    SPG_SLOW = round(SRATE / f_slow);   % samples per slow gate
    SPG_FAST = round(SRATE / f_fast);   % samples per fast gate

    % Enforce divisibility (should be exact, but guard against float rounding)
    SPG_SLOW = 3 * round(SPG_SLOW / 3);
    SPG_FAST = 6 * round(SPG_FAST / 6);

    SEG_SLOW = SPG_SLOW / 3;
    SEG_FAST = SPG_FAST / 3;

    % Verify
    assert(mod(SPG_SLOW,3)==0, 'SPG_SLOW not divisible by 3');
    assert(mod(SPG_FAST,6)==0, 'SPG_FAST not divisible by 6');
    assert(SRATE <= MAX_SRATE, 'SRATE exceeds 160 MSa/s');

    fprintf('--- Timing ---\n');
    fprintf('SRATE    : %.4f MSa/s\n', SRATE/1e6);
    fprintf('f_slow   : %.2f kHz  -> SPG_SLOW = %d samples  (%.2f us)\n', ...
            f_slow/1e3, SPG_SLOW, SPG_SLOW/SRATE*1e6);
    fprintf('f_fast   : %.2f kHz  -> SPG_FAST = %d samples  (%.3f us)\n', ...
            f_fast/1e3, SPG_FAST, SPG_FAST/SRATE*1e6);
    fprintf('v_high   : %.2f V  V_MID : %.2f V  v_low : %.2f V\n', ...
            v_high, V_MID, v_low);

    %%  Sequence counts (unchanged)
    N_HGATES    = 5;
    N_SLOW_INIT = 4;
    N_FAST_PIX  = 75;
    N_INTER_PIX = 5;
    N_REPEATS   = 5;

    %%  Primitive builders
    function s = G(va, vb, vc, seg_len)
        s = [repmat(va,1,seg_len), repmat(vb,1,seg_len), repmat(vc,1,seg_len)];
    end
    Gs  = @(a,b,c) G(a,b,c,SEG_SLOW);
    Gf  = @(a,b,c) G(a,b,c,SEG_FAST);
    Fls = @(v)     G(v,v,v,SEG_SLOW);
    Flf = @(v)     G(v,v,v,SEG_FAST);

    %%  Section builders
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
    %   Fast tail : HALf_fast samples — V3 stays HI (first half of fast gate)
    %   Slow gate : SPG_SLOW samples — V3 [HI|MI|LO], V1 [LO|MI|HI]
    % This gives V3 a half-fast-gate HI cap then a slow fall, while V1
    % rises slowly — exact mirror of the slow rise + fast drop in ST.
    function [v1,v2,v3] = buildFS()
        HF  = int32(SPG_FAST / 2);   % 3 samples
        SEG = int32(SEG_SLOW);        % 45 samples
        % Fast tail: V3 HI for HALf_fast, V1/V2 LO
        ft_v1 = repmat(LO, 1, HF);
        ft_v2 = repmat(LO, 1, HF);
        ft_v3 = repmat(HI, 1, HF);
        % Slow gate: V3 falls, V1 rises
        sg_v1 = [repmat(LO,1,SEG), repmat(MI,1,SEG), repmat(HI,1,SEG)];
        sg_v2 =  repmat(LO, 1, SEG*3);
        sg_v3 = [repmat(HI,1,SEG), repmat(MI,1,SEG), repmat(LO,1,SEG)];
        v1 = [ft_v1, sg_v1];
        v2 = [ft_v2, sg_v2];
        v3 = [ft_v3, sg_v3];
        % After FS: V1=HI, V3=LO — charge on V1, ready for slow pixels
        % (slowVpix expects charge on V3, so caller must prepend a V1->V2->V3
        %  slow pixel before calling buildSlowV, OR we continue with V1->V2 etc.)
    end

    function [v1,v2,v3] = buildST()
        % ST gate = exactly 1 slow gate (SPG_SLOW samples).
        % V3 falls: [HI | MI | LO] x SEG_SLOW each.
        % V1 rises: [LO | MI | HI] x SEG_SLOW each — ends HI with NO trailing LO,
        % so the fast section starts immediately with V1 already high.
        SEG = int32(SEG_SLOW);
        v2 = repmat(LO, 1, SEG*3);
        v1 = [repmat(LO,1,SEG), repmat(MI,1,SEG), repmat(HI,1,SEG)];
        v3 = [repmat(HI,1,SEG), repmat(MI,1,SEG), repmat(LO,1,SEG)];
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

    %%  Assemble
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

    % % Enforce AWG arb length requirement: multiple of 8, min 32
    % N8 = 8 * ceil(N / 8);
    % pad8 = @(w) [w, repmat(LO, 1, N8 - length(w))];
    % wH1=pad8(wH1); wH2=pad8(wH2); wH3=pad8(wH3);
    % wV1=pad8(wV1); wV2=pad8(wV2); wV3=pad8(wV3);
    % N = N8;

    %%  Sanity checks
    assert(all(wH1>=0&wH1<=1),'H1 out of [0,1]');
    assert(all(wH2>=0&wH2<=1),'H2 out of [0,1]');
    assert(all(wH3>=0&wH3<=1),'H3 out of [0,1]');
    assert(all(wV1>=0&wV1<=1),'V1 out of [0,1]');
    assert(all(wV2>=0&wV2<=1),'V2 out of [0,1]');
    assert(all(wV3>=0&wV3<=1),'V3 out of [0,1]');

    %%  Report
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

    %%  Upload
    fprintf('\nUploading at %.2f MSa/s...\n',SRATE/1e6);

    % awg_list = {awg1, awg2, awg3};
    % for i = 1:length(awg_list)
    %     awg = awg_list{i};
    %     writeline(awg.client, "*CLS");
    %     writeline(awg.client, "*RST");
    %     writeline(awg.client, "DATA:VOL:CLE");
    %     pause(0.5);
    %     fprintf('Cleared AWG %d\n', i);
    % end
    % 
    % configAWG_mem(awg1,1,wH1,SRATE,v_low,v_high,nbursts,"BUS"); pause(0.5);
    % configAWG_mem(awg1,2,wH2,SRATE,v_low,v_high,nbursts,"BUS"); pause(0.5);
    % configAWG_mem(awg2,1,wH3,SRATE,v_low,v_high,nbursts,"EXT"); pause(0.5);
    % configAWG_mem(awg2,2,wV1,SRATE,v_low,v_high,nbursts,"EXT"); pause(0.5);
    % configAWG_mem(awg3,1,wV2,SRATE,v_low,v_high,nbursts,"EXT"); pause(0.5);
    % configAWG_mem(awg3,2,wV3,SRATE,v_low,v_high,nbursts,"EXT");
    % fprintf('Upload complete.\n');

    %%  Plots
    % Overview: show both forward and reverse halves
    bounds_fwd = cumsum([n_fh,n_hf,n_si,n_rep,n_rt,n_rh]);
    bounds_rev = n_fwd + (n_fwd - fliplr(bounds_fwd));
    bounds_all = [bounds_fwd, n_fwd, bounds_rev];
    plotOverview(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,v_low,v_high, ...
        [bounds_fwd, n_fwd, n_fwd+bounds_fwd], ...
        {'Fwd H','Hndff','Slow','Rpts','Ret','RevH','<-->','RevH','Ret','Rpts','Slow','Hndff','Rev H'});

    % Zoom: forward horizontal start
    plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,v_low,v_high, ...
        1, 8*SPG_SLOW, 'Zoom: forward horizontal');

    % Zoom: first slow->fast transition
    idx_st1 = n_fh + n_hf + n_si;
    plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,v_low,v_high, ...
        idx_st1 - 3*SPG_SLOW, idx_st1 + SPG_SLOW + 12*SPG_FAST, ...
        'Zoom: first slow->fast transition');

    % Zoom: first fast->slow transition
    n_fast_block = (N_FAST_PIX*3 - 1) * SPG_FAST;
    idx_fs1 = idx_st1 + SPG_SLOW + n_fast_block;
    plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,v_low,v_high, ...
        idx_fs1 - 12*SPG_FAST, idx_fs1 + 4*SPG_SLOW, ...
        'Zoom: first fast->slow transition');

    % Zoom: turnaround point (end of forward rev-H, start of reverse fwd-H)
    idx_turn = n_fwd;
    plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,v_low,v_high, ...
        idx_turn - 4*SPG_SLOW, idx_turn + 4*SPG_SLOW, ...
        'Zoom: turnaround (fwd rev-H -> rev fwd-H)');

    % Zoom: return transition (forward half)
    idx_rt = n_fh + n_hf + n_si + n_rep;
    plotZoom(wH1,wH2,wH3,wV1,wV2,wV3,SRATE,v_low,v_high, ...
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