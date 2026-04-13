function genCCDSqrPulse(awg1, awg2, awg3, varargin)
% Full round-trip sequence:
%   FORWARD:
%     Slow init: H1->H2->H3->H1->H2 | V2 handoff | V2->V3 | 4x[V1->V2->V3] | V1 trans
%     x4: [75 fast px (V1->V2->slow V3) | 5x slow[V1->V2->V3] | V1 trans]
%     x1:  75 fast px (V1->V2->slow V3)
%     Final slow: V1->V2 | H2->H1->H3->H2->H1
%   REVERSE:
%     fliplr of forward — exact time mirror, charge returns along same path

    %% --- Parameters ---
    p = inputParser;
    p.addParameter('f_slow',  30e3,  @(x) isnumeric(x) && x > 0);
    p.addParameter('f_fast',  1e6, @(x) isnumeric(x) && x > 0);
    p.addParameter('v_high',  2.0,   @(x) isnumeric(x));
    p.addParameter('v_low',  -1.0,   @(x) isnumeric(x));
    p.addParameter('srate',   90e6,  @(x) isnumeric(x) && x > 0);
    p.addParameter('nbursts', 1,     @(x) isnumeric(x) && x >= 1);
    p.parse(varargin{:});

    f_slow  = p.Results.f_slow;
    f_fast  = p.Results.f_fast;
    v_high  = p.Results.v_high;
    v_low   = p.Results.v_low;
    SRATE   = p.Results.srate;
    nbursts = p.Results.nbursts;

    %% --- Timing ---
    T_s = round(SRATE / f_slow);
    T_s = 6 * round(T_s / 6);
    HALF_s  = T_s / 2;
    THIRD_s = T_s / 3;
    SIXTH_s = T_s / 6;

    T_f = round(SRATE / f_fast);
    T_f = 6 * round(T_f / 6);
    HALF_f  = T_f / 2;
    THIRD_f = T_f / 3;
    SIXTH_f = T_f / 6;

    fprintf('=== Slow: T=%d T/2=%d T/3=%d T/6=%d samp (%.2f us) ===\n', ...
             T_s, HALF_s, THIRD_s, SIXTH_s, T_s/SRATE*1e6);
    fprintf('=== Fast: T=%d T/2=%d T/3=%d T/6=%d samp (%.3f us) ===\n', ...
             T_f, HALF_f, THIRD_f, SIXTH_f, T_f/SRATE*1e6);

    %% --- Gate list ---
    gate_ch   = [];
    gate_half = [];
    gate_step = [];

    function add(ch, half, step)
        gate_ch   = [gate_ch,   ch];
        gate_half = [gate_half, half];
        gate_step = [gate_step, step];
    end

    %% --- Section helpers ---

    function add_slow_h_forward()
        % H1->H2->H3->H1->H2 then V2 handoff
        for ch = [1 2 3 1 2]
            add(ch, HALF_s, THIRD_s);
        end
        add(5, HALF_s, THIRD_s);        % V2 handoff
    end

    function add_slow_init_v()
        % V2->V3 then 4 slow pixels V1->V2->V3, ending with transition V1
        add(6, HALF_s, THIRD_s);
        for i = 1:4
            for ch = [4 5 6]
                add(ch, HALF_s, THIRD_s);
            end
        end
        add(4, HALF_s, HALF_s - SIXTH_f);   % transition V1 into fast
    end

    function add_fast_75px()
        % 74 full fast pixels V1->V2->V3
        for pix = 1:74
            add(4, HALF_f, THIRD_f);
            add(5, HALF_f, THIRD_f);
            add(6, HALF_f, THIRD_f);
        end
        % 75th pixel: fast V1, fast V2, slow V3
        add(4, HALF_f, THIRD_f);
        add(5, HALF_f, THIRD_f);        % step = THIRD_f so slow V3 overlaps by SIXTH_f
        add(6, HALF_s, THIRD_s);        % slow V3 — back on slow clock
    end

    function add_slow_inter()
        % 5 slow pixels V1->V2->V3, then transition V1
        for i = 1:5
            for ch = [4 5 6]
                add(ch, HALF_s, THIRD_s);
            end
        end
        add(4, HALF_s, HALF_s - SIXTH_f);   % transition V1 into next fast block
    end

    function add_slow_h_reverse()
        % V2->H2->H1->H3->H2->H1  (reverse horizontal, charge ends on H1)
        for ch = [2 1 3 2 1]
            add(ch, HALF_s, THIRD_s);
        end
    end

    %% --- Assemble forward half ---
    add_slow_h_forward();
    add_slow_init_v();

    for rep = 1:4
        add_fast_75px();
        add_slow_inter();
    end

    add_fast_75px();            % 5th fast block

    % Final slow vertical + reverse horizontal
    add(4, HALF_s, THIRD_s);   % slow V1
    add(5, HALF_s, THIRD_s);   % slow V2
    add_slow_h_reverse();       % V2->H2->H1->H3->H2->H1

    N_GATES_FWD = length(gate_ch);
    fprintf('Forward gates: %d\n', N_GATES_FWD);

    %% --- Rising edges (forward half) ---
    rises_fwd = zeros(1, N_GATES_FWD);
    rises_fwd(1) = 1;
    for g = 2:N_GATES_FWD
        rises_fwd(g) = rises_fwd(g-1) + gate_step(g-1);
    end

    %% --- Build forward waveform ---
    N_fwd = rises_fwd(end) + gate_half(end) - 1 + SIXTH_s;
    waveforms_fwd = zeros(6, N_fwd);
    for g = 1:N_GATES_FWD
        i1 = rises_fwd(g);
        i2 = i1 + gate_half(g) - 1;
        waveforms_fwd(gate_ch(g), i1:i2) = 1.0;
    end

    % Hold H1 HI from end of last forward gate through to end of forward buffer.
    % This covers the SIXTH_s tail gap so H1 never drops before the reverse starts.
    last_H1_fall = rises_fwd(end) + gate_half(end);   % first sample after last H1 pulse
    waveforms_fwd(1, last_H1_fall:end) = 1.0;

    %% --- Sanity checks (forward half) ---
    ch_names = {'H1','H2','H3','V1','V2','V3'};
    for ch = 1:6
        assert(all(waveforms_fwd(ch,:) >= 0 & waveforms_fwd(ch,:) <= 1), ...
               'Channel %d out of [0,1]', ch);
    end

    fprintf('\nOverlap check forward half (slow T/6=%d, fast T/6=%d):\n', SIXTH_s, SIXTH_f);
    n_mismatch = 0;
    for g = 1:N_GATES_FWD-1
        ov = max(0, (rises_fwd(g) + gate_half(g) - 1) - rises_fwd(g+1) + 1);
        both_slow = (gate_half(g)==HALF_s) && (gate_half(g+1)==HALF_s);
        both_fast = (gate_half(g)==HALF_f) && (gate_half(g+1)==HALF_f);
        if both_slow
            expected = SIXTH_s; label = 'slow-slow';
        elseif both_fast
            expected = SIXTH_f; label = 'fast-fast';
        else
            expected = SIXTH_f; label = 'boundary';
        end
        if ov ~= expected
            fprintf('  Gate%3d(%s)->%3d(%s) [%s]: got %d expected %d *** MISMATCH ***\n', ...
                g, ch_names{gate_ch(g)}, g+1, ch_names{gate_ch(g+1)}, label, ov, expected);
            n_mismatch = n_mismatch + 1;
        end
    end
    if n_mismatch == 0, fprintf('  All overlaps correct.\n'); end

    %% --- Mirror: append time-reversed copy ---
    waveforms = [waveforms_fwd, fliplr(waveforms_fwd)];
    N_total   = size(waveforms, 2);

    wH1 = waveforms(1,:);  wH2 = waveforms(2,:);  wH3 = waveforms(3,:);
    wV1 = waveforms(4,:);  wV2 = waveforms(5,:);  wV3 = waveforms(6,:);

    fprintf('\nForward samples : %d  (%.3f ms)\n', N_fwd,   N_fwd/SRATE*1e3);
    fprintf('Total samples   : %d  (%.3f ms)  [fwd + rev]\n', N_total, N_total/SRATE*1e3);

    %% --- Plots ---
    plot_all(waveforms, waveforms_fwd, rises_fwd, gate_half, gate_ch, ...
             SRATE, v_low, v_high, T_s, T_f, ch_names, N_fwd);

    %% --- Upload ---
    % configAWG_mem(awg1, 1, wH1, SRATE, v_low, v_high, nbursts, 'BUS');
    % configAWG_mem(awg1, 2, wH2, SRATE, v_low, v_high, nbursts, 'BUS');
    % configAWG_mem(awg2, 1, wH3, SRATE, v_low, v_high, nbursts, 'EXT');
    % configAWG_mem(awg2, 2, wV1, SRATE, v_low, v_high, nbursts, 'EXT');
    % configAWG_mem(awg3, 1, wV2, SRATE, v_low, v_high, nbursts, 'EXT');
    % configAWG_mem(awg3, 2, wV3, SRATE, v_low, v_high, nbursts, 'EXT');
end


%% ------------------------------------------------------------------ %%
function plot_all(waveforms, waveforms_fwd, rises_fwd, gate_half, gate_ch, ...
                  SRATE, vlow, vhigh, T_s, T_f, ch_names, N_fwd)

    N_total = size(waveforms, 2);
    N_GATES = length(gate_ch);
    vspan   = vhigh - vlow;
    toV     = @(x) x * vspan + vlow;
    colors  = {'#0072BD','#D95319','#77AC30','#7E2F8E','#EDB120','#4DBEEE'};
    HALF_f  = T_f / 2;
    t_ms    = (0:N_total-1) / SRATE * 1e3;
    is_fast = (gate_half == HALF_f);

    t_turn_ms = N_fwd / SRATE * 1e3;   % turnaround point

    function shade_blocks(ax_h, scale, g_start, g_end, offset_samp)
        % shade contiguous fast/slow blocks within gate range
        g = g_start;
        while g <= g_end
            bf = is_fast(g); g2 = g;
            while g2 < g_end && is_fast(g2+1)==bf, g2=g2+1; end
            t1 = (offset_samp + rises_fwd(g) - 1) / SRATE * scale;
            t2 = (offset_samp + rises_fwd(g2) + gate_half(g2) - 1) / SRATE * scale;
            if bf, c=[1.0 .95 .90]; else, c=[.93 .96 1.0]; end
            patch(ax_h,[t1 t2 t2 t1],[vlow-.5 vlow-.5 vhigh+1.1 vhigh+1.1], ...
                  c,'FaceAlpha',.45,'EdgeColor','none');
            g = g2+1;
        end
    end

    %% Overview: full round trip
    figure('Name','Overview — full round trip','NumberTitle','off', ...
           'Position',[40 40 1400 820]);
    for k = 1:6
        ax = subplot(6,1,k); hold on;
        % Forward shading
        shade_blocks(ax, 1e3, 1, N_GATES, 0);
        % Reverse shading (mirrored positions)
        shade_blocks(ax, 1e3, 1, N_GATES, N_fwd);
        % Turnaround marker
        xline(t_turn_ms, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5, ...
              'Label', 'turnaround');
        stairs(t_ms, toV(waveforms(k,:)), 'Color', colors{k}, 'LineWidth', 1.2);
        yline(vhigh,':r','LineWidth',.7); yline(vlow,':b','LineWidth',.7);
        ylim([vlow-.5,vhigh+1.2]); yticks([vlow vhigh]);
        yticklabels({sprintf('%.0fV',vlow),sprintf('+%.0fV',vhigh)});
        ylabel(ch_names{k},'FontWeight','bold','FontSize',9);
        xlim([0 t_ms(end)]); set(ax,'XTickLabel',[]); grid on; box off;
        if k==1
            text(t_turn_ms/2,        vhigh+.8, 'Forward', ...
                 'HorizontalAlignment','center','FontSize',9,'FontWeight','bold');
            text(t_turn_ms*1.5,      vhigh+.8, 'Reverse (mirror)', ...
                 'HorizontalAlignment','center','FontSize',9,'FontWeight','bold');
        end
    end
    subplot(6,1,6); set(gca,'XTickLabelMode','auto'); xlabel('Time (ms)');
    sgtitle(sprintf('CCD round trip | %.2f MSa/s | slow %.0fkHz | fast %.0fkHz | %.3f ms total', ...
                    SRATE/1e6, SRATE/T_s/1e3, SRATE/T_f/1e3, N_total/SRATE*1e3), ...
            'FontSize',10);

    %% Zoom helper (works on full waveform, µs timescale)
    function zoom_plot(i1_samp, i2_samp, ttl, mark_samp)
        i1  = max(1, i1_samp);
        i2  = min(N_total, i2_samp);
        idx = i1:i2;
        t_us = (idx-1)/SRATE*1e6;
        figure('Name',ttl,'NumberTitle','off','Position',[80 80 1400 820]);
        for k=1:6
            ax=subplot(6,1,k); hold on;
            stairs(t_us, toV(waveforms(k,idx)), 'Color',colors{k},'LineWidth',2);
            for ms = mark_samp
                if ms>=i1 && ms<=i2
                    xline((ms-1)/SRATE*1e6,'-r','LineWidth',1.5);
                end
            end
            xline(t_turn_ms*1e3,'--','Color',[.5 .5 .5],'LineWidth',1,'Label','turn');
            yline(vhigh,':r','LineWidth',.7); yline(vlow,':b','LineWidth',.7);
            ylim([vlow-.5,vhigh+.9]); yticks([vlow vhigh]);
            yticklabels({sprintf('%.0fV',vlow),sprintf('+%.0fV',vhigh)});
            ylabel(ch_names{k},'FontWeight','bold','FontSize',9);
            xlim([t_us(1) t_us(end)]); set(ax,'XTickLabel',[]); grid on; box off;
        end
        subplot(6,1,6); set(gca,'XTickLabelMode','auto'); xlabel('Time (µs)');
        sgtitle(ttl,'FontSize',10);
    end

    % Turnaround zoom: last ~8 slow gates of forward + first ~8 of reverse
    t_turn_samp = N_fwd;
    zoom_plot(t_turn_samp - 8*T_s, t_turn_samp + 8*T_s, ...
              'Zoom: turnaround (fwd end / rev start)', [t_turn_samp]);

    % Forward slow->fast transition 1
    n_init = 6 + 1 + 1 + 4*3 + 1;    % gate count for slow init
    g_f1s  = n_init + 1;
    zoom_plot(rises_fwd(max(1,g_f1s-3)) - 1, ...
              rises_fwd(min(N_GATES,g_f1s+8)) + gate_half(min(N_GATES,g_f1s+8)), ...
              'Zoom: slow→fast transition (fwd block 1)', [rises_fwd(g_f1s)]);

    % Forward fast->slow transition 1
    n_fast_blk = 74*3 + 2 + 1;
    g_f1e = n_init + n_fast_blk;
    zoom_plot(rises_fwd(max(1,g_f1e-8)) - 1, ...
              rises_fwd(min(N_GATES,g_f1e+6)) + gate_half(min(N_GATES,g_f1e+6)) + T_s, ...
              'Zoom: fast→slow transition (fwd block 1)', [rises_fwd(g_f1e)]);
end