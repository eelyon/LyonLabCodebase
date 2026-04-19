function genCCDPulses(awg1, awg2, awg3, varargin)
% GENCCDPULSES Generate pulse sequence for shuttling on ROIC_n_osc
p = inputParser;
p.addParameter('f_slow',   30e3, @(x) isnumeric(x) && x > 0);
p.addParameter('f_fast',  900e3, @(x) isnumeric(x) && x > 0);
p.addParameter('v_high',    2.0, @(x) isnumeric(x));
p.addParameter('v_low',    -1.0, @(x) isnumeric(x));
p.addParameter('srate',   148.5e6,  @(x) isnumeric(x) && x > 0);
p.addParameter('nbursts',     1, @(x) isnumeric(x) && x >= 1);
p.addParameter('ramp_type', 'COS', @(x) ismember(x, {'COS', 'LIN'}));
p.addParameter('ramp_frac', 0.3, @(x) isnumeric(x) && x>=0 && x<=1);
p.addParameter('loadPulse', 0, @(x) ismember(x, [0 1]));
p.parse(varargin{:});

f_slow    = p.Results.f_slow;
f_fast    = p.Results.f_fast;
v_high    = p.Results.v_high;
v_low     = p.Results.v_low;
SRATE     = getCleanSrate(f_slow,f_fast,p.Results.srate);
nbursts   = p.Results.nbursts;
ramp_frac = p.Results.ramp_frac;
ramp_type = p.Results.ramp_type;

%% Timing
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

RAMP_s = round(HALF_s * ramp_frac);
RAMP_f = round(HALF_f * ramp_frac);

fprintf('=== Slow pulse: T=%d RAMP=%d (%.2f us or %.1f kHz) ===\n', ...
     T_s,RAMP_s,T_s/SRATE*1e6,SRATE/T_s*1e-3);
fprintf('=== Fast pulse: T=%d RAMP=%d (%.3f us or %.1f kHz) ===\n', ...
         T_f,RAMP_f,T_f/SRATE*1e6,SRATE/T_f*1e-3);

fprintf('=== Ramp durations: slow %.2f us | fast %.3f us ===\n', ...
    RAMP_s/SRATE*1e6, RAMP_f/SRATE*1e6);

%% Pulse builder
function r = ramp_up(N)
    if N==0, r=[]; return; end
    t = linspace(0,1,N+2); t = t(2:end-1);
    if strcmp(ramp_type, 'COS')
        r = 0.5*(1 - cos(pi*t));
    else
        r = t;   % linear
    end
end

function r = ramp_down(N)
    if N==0, r=[]; return; end
    t = linspace(0,1,N+2); t = t(2:end-1);
    if strcmp(ramp_type, 'COS')
        r = 0.5*(1 + cos(pi*t));
    else
        r = 1 - t;   % linear
    end
end

function pulse = make_pulse(HALF, RAMP)
    if RAMP >= HALF
        pulse = [ramp_up(HALF), ramp_down(HALF)];
    else
        pulse = [ramp_up(RAMP), ones(1,HALF-RAMP), ...
                 ramp_down(RAMP), zeros(1,HALF-RAMP)];
    end
end

function pulse = make_f2s_pulse()
    % First half  (HALF_f samples): fast rise + fast flat HI
    % Second half (HALF_s samples): half slow HI + slow ramp down + half slow LO
    first_half   = [ramp_up(RAMP_f),  ones(1, HALF_f - RAMP_f)];
    second_half  = [ones(1, HALF_s/2), ramp_down(RAMP_s), zeros(1, HALF_s/2 - RAMP_s)];
    pulse = [first_half, second_half];
end

function pulse = make_s2f_pulse()
    flat_lo     = max(0, HALF_s/2 - RAMP_s);
    first_half  = [zeros(1, flat_lo), ramp_up(RAMP_s), ones(1, HALF_s/2)];
    second_half = [ramp_down(RAMP_f), zeros(1, HALF_f - RAMP_f)];
    pulse       = [first_half, second_half];
end

function pulse = make_pulse_start_hi(HALF, RAMP)
    pulse = [ones(1, HALF), ramp_down(RAMP), zeros(1, HALF - RAMP)];
end

pulse_s_start_hi = make_pulse_start_hi(HALF_s, RAMP_s);
pulse_s   = make_pulse(HALF_s, RAMP_s);
pulse_f   = make_pulse(HALF_f, RAMP_f);
pulse_s2f = make_s2f_pulse();
pulse_f2s = make_f2s_pulse();

% Sentinel T values = actual pulse lengths
T_s2f = length(pulse_s2f);   % HALF_s + HALF_f
T_f2s = length(pulse_f2s);   % HALF_f + HALF_s (same length, diff shape)

%% Gate list
gate_ch   = [];
gate_T    = [];
gate_step = [];
gate_type = {};

function add(ch, T, step, typ)
    gate_ch(end+1)    = ch;
    gate_T(end+1)     = T;
    gate_step(end+1)  = step;
    gate_type{end+1}  = typ;
end

function pulse = get_pulse(g)
    switch gate_type{g}
        case 's',       pulse = pulse_s;
        case 's_hi',   pulse = pulse_s_start_hi;
        case 'f',       pulse = pulse_f;
        case 's2f',     pulse = pulse_s2f;
        case 'f2s',     pulse = pulse_f2s;
    end
end

%% Section helpers
v3_zero_rel = (HALF_s + RAMP_s) - THIRD_s;
STEP_S2F    = max(T_s2f, v3_zero_rel) - T_f;
STEP_F2S = HALF_f + round(HALF_s/2) - SIXTH_s;

function add_slow_h_forward()
    add(1, T_s, THIRD_s, 's_hi');
    for ch = [2 3 1 2] % ch = [1 2 3 1 2]
        add(ch, T_s, THIRD_s, 's');
    end
    add(5, T_s, THIRD_s, 's');
end

function add_slow_init_v()
    add(6, T_s, THIRD_s, 's');
    for i = 1:4
        for ch = [4 5 6]
            add(ch, T_s, THIRD_s, 's');
        end
    end
    add(4, T_s2f, STEP_S2F, 's2f'); % HALF_s - SIXTH_f
end

function add_fast_75px()
    for pix = 1:74
        add(4, T_f, THIRD_f, 'f');
        add(5, T_f, THIRD_f, 'f');
        add(6, T_f, THIRD_f, 'f');
    end
    add(4, T_f, THIRD_f, 'f');
    add(5, T_f, THIRD_f, 'f');
    add(6, T_f2s, STEP_F2S, 'f2s');
end

function add_slow_inter()
    for i = 1:5
        for ch = [4 5 6]
            add(ch, T_s, THIRD_s, 's');
        end
    end
    add(4, T_s2f, STEP_S2F, 's2f'); % HALF_s - SIXTH_f
end

function add_slow_h_reverse()
    for ch = [2 1 3 2 1]
        add(ch, T_s, THIRD_s, 's');
    end
end

%% Assemble pulse sequence
add_slow_h_forward();
add_slow_init_v();
for rep = 1:4
    add_fast_75px();
    add_slow_inter();
end
add_fast_75px();
add(4, T_s, THIRD_s, 's');
add(5, T_s, THIRD_s, 's');
add_slow_h_reverse();

N_GATES_FWD = length(gate_ch);
fprintf('Forward gates: # %d\n', N_GATES_FWD);

%% Rising edges
rises_fwd = zeros(1, N_GATES_FWD);
rises_fwd(1) = 1;
for g = 2:N_GATES_FWD
    rises_fwd(g) = rises_fwd(g-1) + gate_step(g-1);
end

%% Build forward waveform
N_fwd = rises_fwd(end) + gate_T(end) - 1 + SIXTH_s;
waveforms_fwd = zeros(6, N_fwd);

for g = 1:N_GATES_FWD
    ch    = gate_ch(g);
    i1    = rises_fwd(g);
    pulse = get_pulse(g);
    i2    = min(N_fwd, i1 + length(pulse) - 1);
    len   = i2 - i1 + 1;
    waveforms_fwd(ch, i1:i2) = max(waveforms_fwd(ch, i1:i2), pulse(1:len));
end

%% Hold H1 HI through turnaround
last_H1_g   = find(gate_ch == 1, 1, 'last');
H1_peak_end = rises_fwd(last_H1_g) + RAMP_s;
waveforms_fwd(1, H1_peak_end:end) = 1.0;

%% Sanity check
ch_names = {'H1','H2','H3','V1','V2','V3'};
for ch = 1:6
    assert(all(waveforms_fwd(ch,:) >= -1e-9 & waveforms_fwd(ch,:) <= 1+1e-9), ...
           sprintf('Channel %d out of [0,1]',ch));
end

%% Mirror forward sequence
waveforms = [waveforms_fwd, fliplr(waveforms_fwd)];
N_total   = size(waveforms,2);

wH1=waveforms(1,:); wH2=waveforms(2,:); wH3=waveforms(3,:);
wV1=waveforms(4,:); wV2=waveforms(5,:); wV3=waveforms(6,:);

fprintf('Forward: %d samples (%.3f ms) | Total: %d samples (%.3f ms)\n', ...
        N_fwd,N_fwd/SRATE*1e3,N_total,N_total/SRATE*1e3);

%% Plots
plot_all(waveforms, waveforms_fwd, rises_fwd, gate_T, gate_ch, gate_type, ...
         SRATE, v_low, v_high, T_s, T_f, ch_names, N_fwd);

if p.Results.loadPulse == 1
    awg_list = {awg1, awg2, awg3};
    for i = 1:length(awg_list)
        awg = awg_list{i};
        writeline(awg.client, "*CLS");
        writeline(awg.client, "*RST");
        writeline(awg.client, "DATA:VOL:CLE");
        pause(0.5);
        fprintf('Cleared AWG %d\n', i);
    end

    %% Upload waveforms to AWGs
    configAWG(ramp_type,awg1,1,wH1,SRATE,v_low,v_high,nbursts,'BUS'); pause(0.5);
    configAWG(ramp_type,awg1,2,wH2,SRATE,v_low,v_high,nbursts,'BUS'); pause(0.5);
    configAWG(ramp_type,awg2,1,wH3,SRATE,v_low,v_high,nbursts,'EXT'); pause(0.5);
    configAWG(ramp_type,awg2,2,wV1,SRATE,v_low,v_high,nbursts,'EXT'); pause(0.5);
    configAWG(ramp_type,awg3,1,wV2,SRATE,v_low,v_high,nbursts,'EXT'); pause(0.5);
    configAWG(ramp_type,awg3,2,wV3,SRATE,v_low,v_high,nbursts,'EXT');
else
    return
end
end


%% Plotting functions
function plot_all(waveforms, waveforms_fwd, rises_fwd, gate_T, gate_ch, gate_type, ...
              SRATE, vlow, vhigh, T_s, T_f, ch_names, N_fwd)

N_total = size(waveforms,2);
N_GATES = length(gate_ch);
vspan   = vhigh-vlow;
toV     = @(x) x*vspan+vlow;
colors  = {'#0072BD','#D95319','#77AC30','#7E2F8E','#EDB120','#4DBEEE'};
is_fast = strcmp(gate_type,'f');
t_ms    = (0:N_total-1)/SRATE*1e3;
t_turn  = N_fwd/SRATE*1e3;

function shade(ax_h)
    g=1;
    while g<=N_GATES
        bf=is_fast(g); g2=g;
        while g2<N_GATES && is_fast(g2+1)==bf, g2=g2+1; end
        t1=(rises_fwd(g)-1)/SRATE*1e3;
        t2=(rises_fwd(g2)+gate_T(g2)-1)/SRATE*1e3;
        if bf,c=[1.0 .95 .90];else,c=[.93 .96 1.0];end
        patch(ax_h,[t1 t2 t2 t1],[vlow-.5 vlow-.5 vhigh+1.1 vhigh+1.1], ...
              c,'FaceAlpha',.4,'EdgeColor','none');
        r1=t_turn+(t_turn-t2); r2=t_turn+(t_turn-t1);
        patch(ax_h,[r1 r2 r2 r1],[vlow-.5 vlow-.5 vhigh+1.1 vhigh+1.1], ...
              c,'FaceAlpha',.3,'EdgeColor','none');
        g=g2+1;
    end
end

figure('Name','Overview','NumberTitle','off','Position',[40 40 1400 820]);
for k=1:6
    ax=subplot(6,1,k); hold on;
    shade(ax);
    xline(t_turn,'-','Color',[.5 .5 .5],'LineWidth',1.5);
    plot(t_ms,toV(waveforms(k,:)),'Color',colors{k},'LineWidth',1.2);
    yline(vhigh,':r','LineWidth',.7); yline(vlow,':b','LineWidth',.7);
    ylim([vlow-.5,vhigh+1.2]); yticks([vlow vhigh]);
    yticklabels({sprintf('%.0fV',vlow),sprintf('+%.0fV',vhigh)});
    ylabel(ch_names{k},'FontWeight','bold','FontSize',9);
    xlim([0 t_ms(end)]); set(ax,'XTickLabel',[]); grid on; box off;
    if k==1
        text(t_turn*.5, vhigh+.8,'Forward','HorizontalAlignment','center', ...
             'FontSize',9,'FontWeight','bold');
        text(t_turn*1.5,vhigh+.8,'Reverse','HorizontalAlignment','center', ...
             'FontSize',9,'FontWeight','bold');
    end
end
subplot(6,1,6); set(gca,'XTickLabelMode','auto'); xlabel('Time (ms)');
sgtitle(sprintf('CCD round trip — ramped pulse | %.2f MSa/s | slow %.0fkHz | fast %.0fkHz', ...
                SRATE/1e6,SRATE/T_s/1e3,SRATE/T_f/1e3),'FontSize',10);

function zoom_plot(i1_s,i2_s,ttl,mark_s)
    i1=max(1,i1_s); i2=min(N_total,i2_s); idx=i1:i2;
    t_us=(idx-1)/SRATE*1e6;
    figure('Name',ttl,'NumberTitle','off','Position',[80 80 1400 820]);
    for k=1:6
        ax=subplot(6,1,k); hold on;
        plot(t_us,toV(waveforms(k,idx)),'Color',colors{k},'LineWidth',2);
        for ms=mark_s
            if ms>=i1&&ms<=i2
                xline((ms-1)/SRATE*1e6,'-r','LineWidth',1.5);
            end
        end
        yline(vhigh,':r','LineWidth',.7); yline(vlow,':b','LineWidth',.7);
        ylim([vlow-.5,vhigh+.9]); yticks([vlow vhigh]);
        yticklabels({sprintf('%.0fV',vlow),sprintf('+%.0fV',vhigh)});
        ylabel(ch_names{k},'FontWeight','bold','FontSize',9);
        xlim([t_us(1) t_us(end)]); set(ax,'XTickLabel',[]); grid on; box off;
    end
    subplot(6,1,6); set(gca,'XTickLabelMode','auto'); xlabel('Time (µs)');
    sgtitle(ttl,'FontSize',10);
end

n_init     = 6+1+1+4*3+1;
n_fast_blk = 74*3+2+1;
g_f1s = n_init+1;
g_f1e = n_init+n_fast_blk;

zoom_plot(rises_fwd(2)-1, rises_fwd(7)+T_s*2, ...
          'Zoom: slow pulse shape', []);
zoom_plot(rises_fwd(g_f1s)-1, rises_fwd(g_f1s+11)+T_f, ...
          'Zoom: fast pulse shape', []);
zoom_plot(rises_fwd(max(1,g_f1s-3))-1, ...
          rises_fwd(min(N_GATES,g_f1s+6))+T_s, ...
          'Zoom: slow→fast transition', [rises_fwd(g_f1s)]);
zoom_plot(rises_fwd(max(1,g_f1e-6))-1, ...
          rises_fwd(min(N_GATES,g_f1e+5))+T_s*2, ...
          'Zoom: fast→slow transition (V3)', [rises_fwd(g_f1e)]);
zoom_plot(N_fwd-8*T_s, N_fwd+8*T_s, ...
          'Zoom: turnaround', [N_fwd]);
end

function [srate] = getCleanSrate(f_slow, f_fast, max_srate)
    % Find lowest SRATE <= max_srate that gives exact frequencies for both clocks.
    lcm_constraint = lcm(6*f_slow, 6*f_fast);
    k = floor(max_srate / lcm_constraint);
    if k < 1
        error('Cannot satisfy both frequencies within %.0f MSa/s', max_srate/1e6);
    end
    srate = k * lcm_constraint;
    fprintf('Clean SRATE: %.4f MSa/s\n', srate/1e6);
    fprintf('  f_slow actual: %.4f kHz (T=%d samp)\n', srate/round(srate/f_slow)/1e3, round(srate/f_slow));
    fprintf('  f_fast actual: %.4f kHz (T=%d samp)\n', srate/round(srate/f_fast)/1e3, round(srate/f_fast));
end