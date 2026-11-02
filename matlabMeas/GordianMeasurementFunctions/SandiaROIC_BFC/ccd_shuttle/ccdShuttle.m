classdef ccdShuttle < handle
    %CCDSHUTTLE  One three-phase CCD, clocked by its DAC's on-board sequencer.
    %
    %   ccd = ccdShuttle(name, dac, [chA chB chC], 'Name', value, ...)
    %   ccd = ccdShuttle.fromPinout(name, pinout, {'phi_v_2','phi_v_3','phi_v_1'}, ...)
    %
    %   CHANNEL CONVENTION
    %     Channels = [A B C] in the order the electron travels FORWARD.
    %     The electron is parked under A before and after every move.
    %
    %   MOVING
    %     ccd.park()      ramp to the parking state (A high, B and C low)
    %     ccd.move(n)     move n pixels (n < 0: backward); one pixel = 3 gates.
    %                     = arm(|n|) if needed, then fire(sign(n)).
    %     ccd.arm(n)      all slow work in advance for |n| pixels, BOTH
    %                     directions: checks, upload (only if the waveform
    %                     changed), repetition count, trigger setup
    %     ccd.forward()   = fire(+1): start the armed sequence forward
    %     ccd.backward()  = fire(-1): ... backward
    %
    %   DIRECTION
    %     Backward transport is the time reverse of forward transport:
    %       sine:      phi_j(T - t) = Vmid + Vamp*cos(w*t + 2*pi*j/3)
    %       trapezoid: B up, A down, C up, B down, A up, C down  played
    %                  backwards = C up, A down, B up, C down, A up, B down
    %     QDAC : one LIST per channel serves both directions; backward plays
    %            it with LIST:DIRection DOWN (3 writes to switch, no upload).
    %            The list starts and ends at the parking state; if the
    %            forward period has fewer than 2 rest samples at its end, one
    %            rest sample is added (period N+1 samples; always for sine).
    %     Basel: an AWG plays its memory forward from address 0 only. Phase A
    %            is identical in both directions; B and C exchange waveforms.
    %            A direction change rewrites the B and C memories (SET
    %            commands only, no CONTROL waits) inside fire().
    %     ccd.PixelCount  signed pixels moved since construction / resetCount
    %
    %   A repeated move(n) with unchanged settings skips arm() entirely: it
    %   costs ~2-4 round trips + Period*|n| (+ StatusLatency for Basel runs
    %   too short to be seen running). Changing n re-arms: QDAC ~ms, Basel
    %   3 x ControlWait (Cycles-Set is a CONTROL command).
    %
    %   WAVEFORMS  ('Waveform' property)
    %     'linear'  trapezoid clock, defined like a pulse on a function
    %               generator: every gate is a 50 %-duty trapezoid with
    %                 EdgeTime  rise = fall time (0-100 %, NumSteps levels)
    %                 Dwell     plateau width, HIGH and LOW, edges excluded
    %                 Period    T = 2*(EdgeTime + Dwell)
    %               and neighbouring gates are shifted by T/3 (120 deg).
    %               The NumSteps levels sample the ideal ramp at their centres
    %               ((k-1/2)/NumSteps), so the raw staircase leaves the old
    %               level at the start of the edge, reaches the new one exactly
    %               EdgeTime later, and the flat top/bottom is exactly Dwell.
    %               Requires Dwell >= 2*EdgeTime, so only one gate moves at a
    %               time; all gates are static for (Dwell - 2*EdgeTime)/3
    %               between consecutive edges (at least one sample, so every
    %               period ends in the parking state). Forward edge order:
    %               B up, A down, C up, B down, A up, C down.
    %     'cosine'  as 'linear', each edge a raised cosine (zero end slope).
    %     'sine'    continuous three-phase sinusoid, 120 deg apart:
    %                 phi_j(t) = Vmid + Vamp*cos(2*pi*t/T - 2*pi*j/3),
    %                 j = 0,1,2 for A,B,C;  Vmid = (VH+VL)/2, Vamp = (VH-VL)/2.
    %               Its start state is (VH, (VH+3VL)/4, (VH+3VL)/4). With
    %               SineRest = 'rails' (default) the electron stays parked
    %               at (VH,VL,VL) and move() ramps B and C to the sine start
    %               and back in software (A stays at VH throughout).
    %
    %   TIMING
    %     linear/cosine : Period = 2*(EdgeTime + Dwell); setting Period or
    %                     Frequency sets Dwell = Period/2 - EdgeTime.
    %                     Realisable: EdgeTime in steps of NumSteps*dt,
    %                     Period in steps of 6*dt (Dwell in steps of 3*dt).
    %     sine          : Period = SinePeriod; SinePoints samples per period
    %                     ([] = automatic).
    %     Times are quantised to an integer-us sample period (>= 10 us Basel,
    %     >= 2 us QDAC); summary() shows the realised values.
    %
    %   SIGNAL CHAIN
    %     FilterCutoffHz lists the -3 dB frequencies of the single-pole low-pass
    %     stages between DAC and gate, DAC output filter included ([] = 100 kHz,
    %     the DAC's HBW/HIGH filter alone). It sets the default RC overlay in
    %     plot() and the settling / attenuation checks in summary() and move().
    %
    %   HARDWARE
    %     baselDAC : the board's three AWGs (A/B/E for CH 1-12, C/D/F for
    %                CH 13-24), one period in memory, Cycles-Set = |n|,
    %                started together with "C AWG-ABE START" / "C AWG-CDF START".
    %     QDAC     : DC generator in LIST mode, one period per channel,
    %                LIST:COUNt = |n|, armed on an internal trigger, started
    %                with "TINT k".
    %
    %   See also setupCCDs

    % ===================================================================
    properties
        VHigh     (1,1) double {mustBeReal, mustBeGreaterThanOrEqual(VHigh,-10), mustBeLessThanOrEqual(VHigh,10)} = 2
        VLow      (1,1) double {mustBeReal, mustBeGreaterThanOrEqual(VLow,-10),  mustBeLessThanOrEqual(VLow,10)}  = -1
        Waveform  (1,:) char {mustBeMember(Waveform, {'linear','cosine','sine'})} = 'linear'

        NumSteps  (1,1) double {mustBeInteger, mustBePositive} = 10          % linear/cosine
        EdgeTime  (1,1) double {mustBePositive, mustBeFinite} = 100e-6       % [s] linear/cosine
        Dwell     (1,1) double {mustBeNonnegative, mustBeFinite} = 800e-6    % [s] plateau width, linear/cosine

        SinePeriod (1,1) double {mustBePositive, mustBeFinite} = 1.8e-3      % [s] sine
        SinePoints double = []                                               % sine; [] = auto
        SineRest  (1,:) char {mustBeMember(SineRest, {'rails','sine'})} = 'rails'

        GateNames (1,3) cell = {'A','B','C'}
        FilterCutoffHz double {mustBePositive} = []                          % [Hz] signal chain
        RampSteps     (1,1) double {mustBeInteger, mustBePositive} = 50      % park / sine ramps
        RestTolerance (1,1) double {mustBePositive} = 5e-3                   % [V]
        BaselAWGOnly  (1,1) logical = false     % jitter 500 -> 110 ns, FREEZES rest of the board
        CheckBeforeFire (1,1) logical = true    % 1-2 cheap queries per fire(): parked? idle? mode?
        ControlWait   (1,1) double {mustBeNonnegative} = 0.2   % [s] Basel: pause after CONTROL
                                                % commands during arm (manual: ~200 ms)
        StatusLatency (1,1) double {mustBeNonnegative} = 0.2   % [s] Basel: worst-case delay
                                                % until "AWG S?" reports a started run
        Verbose       (1,1) logical = true
    end

    properties (Dependent)
        Period            % [s] one pixel
        Frequency         % [Hz]
        GateTime          % [s] Period/3
        SampleTime        % [s] quantised sequencer sample period
        PointsPerPeriod
        CutoffHz          % effective FilterCutoffHz
    end

    properties (SetAccess = private)
        Name          char   = ''
        DAC
        Channels      (1,3) double = [NaN NaN NaN]
        Device        char   = ''           % 'basel' | 'qdac'
        PixelCount    double = 0
        TriggerNumber double = NaN          % QDAC internal trigger
        LastRun       struct = struct()
    end

    properties (Access = private)
        regOwner    = struct('name', '', 'id', '')
        regKeys     = {}
        baselGens   = {}
        baselGroup  = ''
        configured  = false
        loadedKey   = ''
        loadedKeys  = {'', '', ''}          % Basel: per-AWG memory content
        loadedDir   = 0                     % Basel: direction in AWG memory
        qdacDir     = 0                     % QDAC: LIST direction set
        loadedCount = NaN
        loadedN     = NaN
        loadedDt    = NaN
        pending     = []
        armed       = []
        qdacArmed   = false
    end

    properties (Constant, Access = private)
        BASEL_DTMIN_US  = 10
        BASEL_MAXPTS    = 65000
        BASEL_MAXCOUNT  = 4e9
        BASEL_SINEPTS   = 2000             % auto cap: upload is point-by-point
        BASEL_LSB       = 838860.74        % codes per volt, as in baselDAC
        QDAC_DTMIN_US   = 2                % SOUR:LIST:DWEL minimum
        QDAC_MAXPTS     = 2097152
        QDAC_MAXCOUNT   = 16777215
        QDAC_SINEPTS    = 100000
        SETTABLE = {'VHigh','VLow','Waveform','NumSteps','EdgeTime','Dwell','SinePeriod', ...
                    'SinePoints','SineRest','GateNames','FilterCutoffHz','RampSteps','RestTolerance', ...
                    'BaselAWGOnly','CheckBeforeFire','ControlWait','StatusLatency','Verbose'}
    end

    % ===================================================================
    methods
        function obj = ccdShuttle(name, dac, channels, varargin)
            if nargin < 3
                error('ccdShuttle:args', 'Usage: ccdShuttle(name, dac, [chA chB chC], ...)');
            end
            obj.Name = char(name);
            if isa(dac, 'baselDAC')
                obj.Device = 'basel';
            elseif isa(dac, 'QDAC')
                obj.Device = 'qdac';
            else
                error('ccdShuttle:dac', 'Unsupported DAC class "%s".', class(dac));
            end
            channels = double(channels(:).');
            if numel(channels) ~= 3 || numel(unique(channels)) ~= 3 || ...
                    any(channels < 1 | mod(channels,1) ~= 0)
                error('ccdShuttle:channels', 'Give three different positive integer channels [A B C].');
            end
            if isprop(dac, 'numChannels') && ~isempty(dac.numChannels) && any(channels > dac.numChannels)
                error('ccdShuttle:channels', 'This DAC has %d channels.', dac.numChannels);
            end
            obj.DAC       = dac;
            obj.Channels  = channels;
            obj.GateNames = arrayfun(@(c) sprintf('CH%d', c), channels, 'UniformOutput', false);
            obj.regOwner  = struct('name', obj.Name, 'id', ccdShuttle.newId(obj.Name));

            % ---- name-value pairs; Period/Frequency applied last -------
            if mod(numel(varargin), 2) ~= 0
                error('ccdShuttle:args', 'Options must be name-value pairs.');
            end
            timing = {}; trig = [];
            for k = 1:2:numel(varargin)
                nm = char(varargin{k}); val = varargin{k+1};
                switch lower(nm)
                    case {'period', 'frequency'}, timing = {nm, val};
                    case 'triggernumber',         trig = val;
                    otherwise
                        idx = find(strcmpi(obj.SETTABLE, nm), 1);
                        if isempty(idx), error('ccdShuttle:args', 'Unknown option "%s".', nm); end
                        obj.(obj.SETTABLE{idx}) = val;
                end
            end
            if ~isempty(timing)
                obj.(regexprep(lower(timing{1}), '^.', '${upper($0)}')) = timing{2};
            end

            % ---- claim sequencer resources ----------------------------
            addr = ccdShuttle.dacAddress(dac);
            switch obj.Device
                case 'basel'
                    if all(channels <= 12)
                        obj.baselGens = {'A','B','E'}; obj.baselGroup = 'ABE';
                    elseif all(channels >= 13)
                        obj.baselGens = {'C','D','F'}; obj.baselGroup = 'CDF';
                    else
                        error('ccdShuttle:boards', ...
                            ['CH %s straddle the two Basel boards (1-12 / 13-24); a synchronous\n' ...
                             'start needs the three AWGs of one board.'], mat2str(channels));
                    end
                    obj.claim(sprintf('basel:%s:AWG-%s', addr, obj.baselGroup));
                case 'qdac'
                    if isempty(trig)
                        for n = 1:14
                            if ccdShuttle.registry('isfree', sprintf('qdac:%s:INT%d', addr, n), obj.regOwner)
                                trig = n; break
                            end
                        end
                        if isempty(trig), error('ccdShuttle:trigger', 'All 14 internal triggers in use.'); end
                    end
                    obj.claim(sprintf('qdac:%s:INT%d', addr, trig));
                    obj.TriggerNumber = trig;
            end
            for ch = channels
                obj.claim(sprintf('%s:%s:CH%d', obj.Device, addr, ch));
            end
            if obj.Verbose, obj.summary(); end
        end

        function delete(obj)
            for k = 1:numel(obj.regKeys)
                ccdShuttle.registry('release', obj.regKeys{k}, obj.regOwner);
            end
        end

        % ---------------------------------------------------------------
        %  Dependent properties
        % ---------------------------------------------------------------
        function T = get.Period(obj)
            if strcmp(obj.Waveform, 'sine'), T = obj.SinePeriod;
            else, T = 2*(obj.EdgeTime + obj.Dwell); end
        end
        function set.Period(obj, T)
            validateattributes(T, {'numeric'}, {'scalar', 'positive', 'finite'});
            if strcmp(obj.Waveform, 'sine')
                obj.SinePeriod = T;
            else
                d = T/2 - obj.EdgeTime;
                if d < 2*obj.EdgeTime*(1 - 1e-9)
                    error('ccdShuttle:shortPeriod', ...
                        'Period %.4g us < 6*EdgeTime = %.4g us (plateau would be shorter than 2 edges).', ...
                        T*1e6, 6*obj.EdgeTime*1e6);
                end
                obj.Dwell = d;
            end
        end
        function f = get.Frequency(obj), f = 1/obj.Period; end
        function set.Frequency(obj, f)
            validateattributes(f, {'numeric'}, {'scalar', 'positive', 'finite'});
            obj.Period = 1/f;
        end
        function t = get.GateTime(obj),        t = obj.Period/3; end
        function t = get.SampleTime(obj),      [dtUs, ~] = obj.grid(); t = dtUs*1e-6; end
        function n = get.PointsPerPeriod(obj), [~, n] = obj.grid(); end
        function f = get.CutoffHz(obj)
            if isempty(obj.FilterCutoffHz), f = 100e3; else, f = obj.FilterCutoffHz(:).'; end
        end

        % ---------------------------------------------------------------
        %  User API
        % ---------------------------------------------------------------
        function park(obj)
            %PARK  Ramp the three gates to the parking state (electron under A).
            obj.waitDone();
            v = obj.parkVoltages();
            obj.rampTo(v);
            obj.say('%s parked: %s', obj.Name, obj.stateString(v));
        end

        function resetCount(obj)
            obj.PixelCount = 0;
        end

        function arm(obj, nPixels)
            %ARM  Prepare |nPixels| pixels in both directions: checks, upload if
            %   the waveform changed, repetition count, trigger. Afterwards
            %   forward()/backward() only start it. On the Basel, sign(nPixels)
            %   decides which direction is put into memory first.
            arguments
                obj
                nPixels (1,1) double {mustBeInteger, mustBeNonzero}
            end
            obj.waitDone();
            if obj.VHigh <= obj.VLow
                error('ccdShuttle:rails', 'VHigh must be above VLow (electrons sit under HIGH gates).');
            end
            count = abs(nPixels); d0 = sign(nPixels);
            switch obj.Device
                case 'basel', maxCnt = obj.BASEL_MAXCOUNT;
                otherwise,    maxCnt = obj.QDAC_MAXCOUNT;
            end
            if count > maxCnt, error('ccdShuttle:count', 'At most %d pixels per move.', maxCnt); end

            [dtUs, N, M] = obj.grid();
            obj.warnQuantised(dtUs, M);
            obj.checkBandwidth(dtUs, M, true);
            obj.ensureConfigured();
            vPark  = obj.parkVoltages();
            vStart = obj.startVoltages();
            obj.checkAt(vPark);

            key = obj.waveKey(dtUs, N);
            switch obj.Device
                case 'basel'
                    obj.baselLoad(obj.playedPeriod(d0, dtUs, N), obj.baselKeys(key, d0), dtUs, count);
                    obj.loadedDir = d0;
                case 'qdac'
                    obj.qdacLoad(obj.playedPeriod(+1, dtUs, N), key);   % direction-independent
                    obj.qdacArm(count, dtUs, true, d0);
            end
            obj.armed = struct('key', key, 'count', count, 'dtUs', dtUs, 'N', N, 'M', M, ...
                               'T', M*dtUs*1e-6*count, 'vStart', vStart, 'vPark', vPark, ...
                               'rampIn', any(vStart ~= vPark));
            obj.say('%s armed: %d pixels either way, %.4g ms', obj.Name, count, 1e3*obj.armed.T);
        end

        function info = fire(obj, direction, opts)
            %FIRE  Start the armed sequence: fire(+1) forward, fire(-1) backward.
            arguments
                obj
                direction (1,1) double {mustBeMember(direction, [-1 1])} = 1
                opts.Wait (1,1) logical = true
            end
            obj.waitDone();
            a = obj.armed;
            if isempty(a)
                error('ccdShuttle:notArmed', '%s: call arm(n) or move(n) first.', obj.Name);
            end
            [dtUs, N] = obj.grid();
            if ~strcmp(a.key, obj.waveKey(dtUs, N))
                error('ccdShuttle:stale', '%s: settings changed since arm(); call arm(n) or move(n).', obj.Name);
            end
            if a.rampIn, obj.rampTo(a.vStart); end           % sine with SineRest = 'rails'
            switch obj.Device
                case 'basel', obj.baselFire(a, direction);
                case 'qdac',  obj.qdacFire(a, direction);
            end
            obj.pending = struct('t0', tic, 'T', a.T, 'count', a.count, 'd', direction, ...
                                 'vStart', a.vStart, 'vPark', a.vPark, 'rampBack', a.rampIn);
            info = struct('nPixels', direction*a.count, 'run', [], 'elapsed', NaN);
            if opts.Wait
                info.run     = obj.waitDone();
                info.elapsed = info.run.elapsed;
            end
        end

        function info = forward(obj, varargin),  info = obj.fire(+1, varargin{:}); end
        function info = backward(obj, varargin), info = obj.fire(-1, varargin{:}); end

        function info = move(obj, nPixels, opts)
            %MOVE  Move nPixels (signed): arm(|nPixels|) unless already armed, then fire.
            arguments
                obj
                nPixels (1,1) double {mustBeInteger}
                opts.Wait (1,1) logical = true
            end
            info = struct('nPixels', nPixels, 'run', [], 'elapsed', 0);
            if nPixels == 0, return; end
            obj.waitDone();
            if ~obj.isArmedFor(nPixels), obj.arm(nPixels); end
            info = obj.fire(sign(nPixels), 'Wait', opts.Wait);
        end

        function r = waitDone(obj)
            %WAITDONE  Block until a non-blocking fire()/move() has finished.
            r = [];
            if isempty(obj.pending), return; end
            pd = obj.pending;
            obj.pending = [];
            try
                switch obj.Device
                    case 'basel', r = obj.baselFinish(pd);
                    case 'qdac',  r = obj.qdacFinish(pd);
                end
            catch ME
                obj.armed = [];
                rethrow(ME);
            end
            if pd.rampBack, obj.rampTo(pd.vPark); end
            obj.PixelCount = obj.PixelCount + pd.d*pd.count;
            obj.LastRun    = r;
        end

        function stop(obj)
            %STOP  Abort a running move. The gates are left mid-cycle.
            switch obj.Device
                case 'basel'
                    obj.ctrl(sprintf('AWG-%s STOP', obj.baselGroup), 0);
                case 'qdac'
                    for ch = obj.Channels
                        fprintf(obj.DAC.client, sprintf('SOUR%d:DC:ABOR', ch));
                        fprintf(obj.DAC.client, sprintf('SOUR%d:DC:MODE FIX', ch));
                    end
                    obj.qdacArmed = false;
            end
            obj.pending = [];
            obj.armed   = [];
            warning('ccdShuttle:stopped', ...
                '%s aborted mid-cycle; charge may be split. move() refuses until park().', obj.Name);
        end

        function invalidate(obj)
            %INVALIDATE  Forget what is loaded/armed (after touching the AWGs/LISTs elsewhere).
            obj.configured  = false;
            obj.loadedKey   = '';
            obj.loadedCount = NaN; obj.loadedN = NaN; obj.loadedDt = NaN;
            obj.loadedKeys  = {'', '', ''}; obj.loadedDir = 0; obj.qdacDir = 0;
            obj.armed       = [];
            obj.qdacArmed   = false;
        end

        function summary(obj)
            [dtUs, N, M] = obj.grid();
            fprintf('\nccdShuttle "%s"  (%s %s)\n', obj.Name, obj.Device, ccdShuttle.dacAddress(obj.DAC));
            fprintf('  travel order  A=%s (CH %d) -> B=%s (CH %d) -> C=%s (CH %d)\n', ...
                obj.GateNames{1}, obj.Channels(1), obj.GateNames{2}, obj.Channels(2), ...
                obj.GateNames{3}, obj.Channels(3));
            fprintf('  rails HIGH %+.4f V, LOW %+.4f V;  parked %s\n', obj.VHigh, obj.VLow, ...
                obj.stateString(obj.parkVoltages()));
            if strcmp(obj.Waveform, 'sine')
                fprintf('  sine: T = %g us (requested %g us), %d points of %d us\n', ...
                    M*dtUs, obj.SinePeriod*1e6, M, dtUs);
                fprintf('        start state %s, SineRest = %s\n', ...
                    obj.stateString(obj.startVoltages()), obj.SineRest);
            else
                nStep = obj.quantise(dtUs);
                [teUs, wUs, gapUs] = obj.realised(dtUs);
                fprintf('  %s: edge %d x %g us = %g us (req. %g), plateau %g us (req. %g)\n', ...
                    obj.Waveform, obj.NumSteps, nStep*dtUs, teUs, obj.EdgeTime*1e6, wUs, obj.Dwell*1e6);
                fprintf('        T = 2*(edge + plateau) = %g us, %d points of %d us\n', M*dtUs, M, dtUs);
                fprintf('        all gates static for %g us between consecutive edges\n', gapUs);
            end
            if M > N
                fprintf('        (+1 rest sample per period so one list serves both directions)\n');
            end
            fprintf('  f = %.5g Hz, gate time %g us, PixelCount %+d\n', 1/(M*dtUs*1e-6), M*dtUs/3, obj.PixelCount);
            obj.checkBandwidth(dtUs, M, false);
            if isempty(obj.armed), fprintf('  not armed\n');
            else, fprintf('  armed for %d pixels, either direction (%.4g ms)\n', obj.armed.count, 1e3*obj.armed.T); end
            switch obj.Device
                case 'basel', fprintf('  Basel AWG-%s\n\n', obj.baselGroup);
                case 'qdac',  fprintf('  QDAC DC LIST, internal trigger %d\n\n', obj.TriggerNumber);
            end
        end

        function fig = plot(obj, nPixels, opts)
            %PLOT  Preview the sequencer output for move(nPixels).
            %   ccd.plot(2)                            DAC filter only (100 kHz)
            %   ccd.plot(2, 'CutoffHz', [100e3 5e3])   + e.g. a 5 kHz loom filter
            arguments
                obj
                nPixels (1,1) double {mustBeInteger, mustBeNonzero} = 2
                opts.CutoffHz double {mustBePositive} = obj.CutoffHz
            end
            [dtUs, N] = obj.grid(); dt = dtUs*1e-6;
            nShow = sign(nPixels)*min(abs(nPixels), 4);
            V1    = obj.playedPeriod(sign(nShow), dtUs, N);              % exactly what is played
            V     = [obj.startVoltages().', repmat(V1, 1, abs(nShow))];   % start sample in front
            M     = size(V1, 2);
            Nt    = size(V, 2);

            tau   = 1 ./ (2*pi*opts.CutoffHz);
            haveF = ~isempty(tau);
            if haveF
                up  = max(1, ceil(dt/(min(tau)/20)));
                up  = min(up, max(1, floor(1e7/Nt)));
                dtF = dt/up; Vf = repelem(V, 1, up);
                for k = 1:numel(tau)
                    a  = exp(-dtF/tau(k));
                    Vf = filter(1 - a, [1 -a], Vf, a*Vf(:,1).', 2);
                end
                tF = (1:size(Vf,2))*dtF*1e6;
            end

            fig  = figure('Name', sprintf('%s: move(%d), %s', obj.Name, nShow, obj.Waveform), 'Color', 'w');
            tl   = tiledlayout(fig, 4, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
            tUs  = (0:Nt)*dtUs;
            cols = lines(3);
            pad  = 0.08*(obj.VHigh - obj.VLow);
            lbl  = strrep(obj.GateNames, '_', '\_');
            ax   = gobjects(4, 1);
            for k = 1:3
                ax(k) = nexttile(tl); hold(ax(k), 'on'); grid(ax(k), 'on'); box(ax(k), 'on');
                stairs(ax(k), tUs, [V(k,:) V(k,end)], 'Color', cols(k,:), 'LineWidth', 1.3, ...
                    'DisplayName', 'sequencer output');
                if haveF
                    plot(ax(k), tF, Vf(k,:), '--', 'Color', 0.3*[1 1 1], 'DisplayName', ...
                        sprintf('RC %s kHz', strjoin(compose('%.3g', opts.CutoffHz/1e3), '+')));
                end
                xline(ax(k), dtUs + (0:3*abs(nShow))*M*dtUs/3, ':', 'Color', 0.6*[1 1 1], ...
                    'HandleVisibility', 'off');                        % gate-time marks
                ylabel(ax(k), sprintf('%s (CH%d) [V]', lbl{k}, obj.Channels(k)));
                ylim(ax(k), [obj.VLow obj.VHigh] + [-pad pad]);
            end
            legend(ax(1), 'Location', 'northeastoutside');

            ax(4) = nexttile(tl);                                      % normalised gate map
            imagesc(ax(4), ((0:Nt-1) + 0.5)*dtUs, 1:3, (V - obj.VLow)/(obj.VHigh - obj.VLow), [0 1]);
            colormap(ax(4), flipud(gray));
            set(ax(4), 'YTick', 1:3, 'YTickLabel', lbl, 'YDir', 'reverse');
            ylabel(ax(4), '(V-V_L)/(V_H-V_L)'); xlabel(ax(4), 'time [\mus]');
            linkaxes(ax, 'x'); xlim(ax(1), [0 tUs(end)]);
            title(tl, sprintf('%s: move(%+d), %s, T = %g \\mus, %d pts \\times %d \\mus', ...
                strrep(obj.Name, '_', '\_'), nShow, obj.Waveform, M*dtUs, M, dtUs), 'FontSize', 9);
        end
    end

    % ===================================================================
    methods (Static)
        function obj = fromPinout(name, pinout, fields, varargin)
            %FROMPINOUT  ccdShuttle from pinout.<field>.device/.port, fields in travel order.
            if numel(fields) ~= 3, error('ccdShuttle:pinout', 'Give three pinout fields.'); end
            dev = pinout.(fields{1}).device;
            for k = 2:3
                o = pinout.(fields{k}).device;
                if ~(strcmp(class(o), class(dev)) && o == dev)
                    error('ccdShuttle:pinout', '%s and %s are on different DACs.', fields{1}, fields{k});
                end
            end
            ch  = cellfun(@(f) double(pinout.(f).port), fields);
            obj = ccdShuttle(name, dev, ch, 'GateNames', fields(:).', varargin{:});
        end
    end

    % ===================================================================
    %  Waveforms and sample grid
    % ===================================================================
    methods (Access = private)
        function v = parkVoltages(obj)
            if strcmp(obj.Waveform, 'sine') && strcmp(obj.SineRest, 'sine')
                v = obj.startVoltages();
            else
                v = [obj.VHigh obj.VLow obj.VLow];
            end
        end

        function v = startVoltages(obj)
            % First (= last) state of one period; identical for both directions.
            if strcmp(obj.Waveform, 'sine')
                v = [obj.VHigh, [1 1]*(obj.VHigh + 3*obj.VLow)/4];
            else
                v = [obj.VHigh obj.VLow obj.VLow];
            end
        end

        function [dtUs, N, M] = grid(obj)
            % N: samples of one forward period; M: samples actually played
            % per period (QDAC: N+1 if one list must serve both directions).
            switch obj.Device
                case 'basel', dtMin = obj.BASEL_DTMIN_US; maxPts = obj.BASEL_MAXPTS; autoPts = obj.BASEL_SINEPTS;
                otherwise,    dtMin = obj.QDAC_DTMIN_US;  maxPts = obj.QDAC_MAXPTS;  autoPts = obj.QDAC_SINEPTS;
            end
            if strcmp(obj.Waveform, 'sine')
                Tus = obj.SinePeriod*1e6;
                if isempty(obj.SinePoints)
                    N = 6*floor(min(floor(Tus/dtMin), autoPts)/6);
                else
                    N = max(6, 6*round(obj.SinePoints/6));         % multiple of 6: exact 120 deg
                end
                if N < 6
                    error('ccdShuttle:sinePeriod', 'SinePeriod %g us < 6 samples of %d us.', Tus, dtMin);
                end
                dtUs = max(dtMin, round(Tus/N));
            else
                if obj.Dwell < 2*obj.EdgeTime*(1 - 1e-9)
                    error('ccdShuttle:dwell', ...
                        ['Dwell (plateau) %g us must be >= 2*EdgeTime = %g us. With the gates 120 deg\n' ...
                         'apart, each plateau has to span the edges of the other two gates; otherwise\n' ...
                         'two gates move at once and the clock never passes the parking state.'], ...
                        obj.Dwell*1e6, 2*obj.EdgeTime*1e6);
                end
                dtUs = obj.chooseDtUs(dtMin, maxPts);
                [~, ~, nSeg] = obj.quantise(dtUs);
                N = 6*nSeg;
            end
            M = N;
            if strcmp(obj.Device, 'qdac')
                if strcmp(obj.Waveform, 'sine')
                    M = N + 1;                                     % sample N-1 is never the start state
                else
                    [~, nGap] = obj.quantise(dtUs);
                    if nGap < 2, M = N + 1; end                    % fewer than 2 rest samples at the end
                end
            end
            if M > maxPts
                error('ccdShuttle:memory', 'One period needs %d samples (max %d).', M, maxPts);
            end
        end

        function V = playedPeriod(obj, d, dtUs, N)
            %PLAYEDPERIOD  One period (3 x M, physical channel order) exactly as
            %   the sequencer plays it in direction d.
            Vr = obj.roleWaveform(dtUs, N);                        % forward, rows A B C
            if strcmp(obj.Device, 'basel')
                roles = mod(d*(0:2), 3) + 1;                       % backward: B <-> C
                V = zeros(3, N); V(roles, :) = Vr;
                return
            end
            % QDAC: list L with L(1) = L(end) = start state. UP plays L, DOWN
            % plays fliplr(L); both repeat seamlessly and end at the start state.
            v0 = obj.startVoltages().';
            if all(abs(Vr(:, N-1) - v0) < 1e-12)
                L = [v0, Vr(:, 1:N-1)];                            % M = N
            else
                L = [v0, Vr];                                      % M = N + 1
            end
            if d > 0, V = L; else, V = fliplr(L); end
        end

        function [nStep, nGap, nSeg] = quantise(obj, dtUs)
            % One period = 6 segments of (edge + gap); plateau W = 2*edge + 3*gap.
            %   nStep: samples per staircase level
            %   nGap : samples with all three gates static between two edges
            nStep = max(1, round(obj.EdgeTime/obj.NumSteps*1e6/dtUs));
            teUs  = obj.NumSteps*nStep*dtUs;
            nGap  = max(1, round((obj.Dwell*1e6 - 2*teUs)/(3*dtUs)));   % >= 1: period ends at rest
            nSeg  = obj.NumSteps*nStep + nGap;
        end

        function [teUs, wUs, gapUs] = realised(obj, dtUs)
            [nStep, nGap] = obj.quantise(dtUs);
            teUs  = obj.NumSteps*nStep*dtUs;
            gapUs = nGap*dtUs;
            wUs   = 2*teUs + 3*gapUs;
        end

        function dtUs = chooseDtUs(obj, dtMin, maxPts)
            % Integer-us sample period best realising EdgeTime and plateau Dwell;
            % among near-ties (0.5 us) the largest dt (fewest points) wins.
            stepUs  = obj.EdgeTime/obj.NumSteps*1e6;
            wUs     = obj.Dwell*1e6;
            gapReq  = max(0, (wUs - 2*obj.EdgeTime*1e6)/3);
            c       = dtMin : min(2e5, max(dtMin, round(max(stepUs, gapReq))));
            nStep   = max(1, round(stepUs./c));
            teR     = obj.NumSteps*nStep.*c;
            nGap    = max(1, round((wUs - 2*teR)./(3*c)));
            wR      = 2*teR + 3*nGap.*c;
            Np      = 6*(obj.NumSteps*nStep + nGap);
            err     = abs(teR - obj.EdgeTime*1e6) + abs(wR - wUs);
            err(Np > maxPts) = Inf;
            if all(isinf(err))
                error('ccdShuttle:memory', 'One clock period does not fit into %d samples.', maxPts);
            end
            ok   = find(err <= min(err) + 0.5);
            dtUs = c(ok(end));
        end

        function V = roleWaveform(obj, dtUs, N)
            %ROLEWAVEFORM  One FORWARD period in role space (rows = A, B, C).
            %   Samples at t_i = i*dt, i = 1..N, so the last sample is the
            %   start state and periods concatenate seamlessly.
            H = obj.VHigh; L = obj.VLow;
            if strcmp(obj.Waveform, 'sine')
                th = 2*pi*(1:N)/N;                                 % omega*t_i
                j  = (0:2).';
                V  = (H+L)/2 + (H-L)/2*cos(th - 2*pi*j/3);         % 3 x N
                return
            end
            [nStep, nDwell, nSeg] = obj.quantise(dtUs);
            x = ((1:obj.NumSteps) - 0.5)/obj.NumSteps;             % ramp sampled at level centres
            switch obj.Waveform
                case 'linear', s = x;
                case 'cosine', s = (1 - cos(pi*x))/2;
            end
            frac = [repelem(s, nStep), ones(1, nDwell)];           % 1 x nSeg, 0 -> 1
            V = zeros(3, N); st = [H; L; L]; seg = 0;
            for g = 1:3                                            % gate g -> g+1
                ph = [mod(g,3)+1, g]; tgt = [H L];                 % raise next, lower current
                for k = 1:2
                    seg = seg + 1; idx = (seg-1)*nSeg + (1:nSeg);
                    V(:, idx) = repmat(st, 1, nSeg);
                    V(ph(k), idx) = st(ph(k)) + (tgt(k) - st(ph(k)))*frac;
                    st(ph(k)) = tgt(k);
                end
            end
        end

        function warnQuantised(obj, dtUs, N)
            if strcmp(obj.Waveform, 'sine')
                e = abs(N*dtUs*1e-6 - obj.SinePeriod)/obj.SinePeriod;
            else
                [teUs, wUs] = obj.realised(dtUs);
                e = max(abs(teUs*1e-6 - obj.EdgeTime)/obj.EdgeTime, abs(wUs*1e-6 - obj.Dwell)/obj.Dwell);
            end
            if e > 0.01
                warning('ccdShuttle:quantised', '%s: timing quantised by %.1f %% (see summary()).', obj.Name, 100*e);
            end
        end

        function ts = settleTime(obj, tol)
            % Step-response settling time of the RC cascade to within tol.
            tau = 1./(2*pi*obj.CutoffHz);
            dtF = min(tau)/50; n = ceil(30*sum(tau)/dtF);
            y = ones(1, n);
            for k = 1:numel(tau)
                a = exp(-dtF/tau(k)); y = filter(1 - a, [1 -a], y);
            end
            ts = find(abs(1 - y) > tol, 1, 'last')*dtF;
            if isempty(ts), ts = 0; end
        end

        function checkBandwidth(obj, dtUs, N, warnOnly)
            % Trapezoid: does a gate settle to 1 % before the next gate moves?
            % Sine: amplitude loss and (common) delay through the chain.
            fc  = obj.CutoffHz;
            tau = 1./(2*pi*fc);
            if strcmp(obj.Waveform, 'sine')
                f    = 1/(N*dtUs*1e-6);
                A    = prod(1./sqrt(1 + (f./fc).^2));
                lag  = sum(atan(f./fc))/(2*pi*f);
                msg  = sprintf('sine at %.4g Hz: amplitude -%.3g %%, delay %.3g us', f, 100*(1-A), lag*1e6);
                bad  = (1 - A) > 0.01;
            else
                [~, ~, gapUs] = obj.realised(dtUs);
                ts1  = obj.settleTime(1e-2);
                msg  = sprintf(['static gap between edges %g us vs. 1 %% settling %.3g us ' ...
                                '(0.1 %%: %.3g us)'], gapUs, ts1*1e6, obj.settleTime(1e-3)*1e6);
                bad  = gapUs*1e-6 < ts1;                       % filtered edges of two gates overlap
            end
            if ~warnOnly
                fprintf('  chain %s kHz (tau %s us): %s\n', strjoin(compose('%.4g', fc/1e3), ' + '), ...
                    strjoin(compose('%.3g', tau*1e6), ' + '), msg);
            elseif bad
                warning('ccdShuttle:bandwidth', '%s: %s.', obj.Name, msg);
            end
        end

        % ---------------------------------------------------------------
        function rampTo(obj, v)
            if strcmp(obj.Device, 'basel'), baselDACGetConfig(obj.DAC); end
            rampDACVolts(obj.DAC, obj.Channels, v, obj.RampSteps);   % blocking
            if strcmp(obj.Device, 'qdac')
                for ch = obj.Channels                                 % SWEep -> FIXed, no jump
                    fprintf(obj.DAC.client, sprintf('SOUR%d:DC:MODE FIX', ch));
                end
                obj.qdacArmed = false;                                % the ramp used the DC generator
            end
        end

        function v = readVoltages(obj)
            % One query for all three outputs, without changing any mode.
            switch obj.Device
                case 'basel'
                    hx = baselDAC.splitList(obj.DAC.rawQuery('ALL V?'));
                    v  = cellfun(@(h) baselDAC.hex2volt(h), hx(obj.Channels));
                case 'qdac'
                    resp = query(obj.DAC.client, sprintf('SOUR:VOLT? (@%d,%d,%d)', obj.Channels));
                    v = str2double(strsplit(strtrim(resp), ','));
                    if numel(v) ~= 3 || any(isnan(v))
                        v = arrayfun(@(ch) str2double(query(obj.DAC.client, ...
                            sprintf('SOUR%d:VOLT?', ch))), obj.Channels);
                    end
            end
            v = v(:).';
        end

        function checkAt(obj, vExp)
            vAct = obj.readVoltages();
            if any(abs(vAct - vExp) > obj.RestTolerance)
                error('ccdShuttle:notParked', ...
                    '%s: outputs %s V, parking state is %s V. Call park() first.', ...
                    obj.Name, mat2str(vAct, 5), mat2str(vExp, 5));
            end
        end

        function tf = isArmedFor(obj, nPixels)
            a  = obj.armed;
            tf = ~isempty(a) && a.count == abs(nPixels);           % direction does not matter
            if tf
                [dtUs, N] = obj.grid();
                tf = strcmp(a.key, obj.waveKey(dtUs, N));
            end
        end

        function key = waveKey(obj, dtUs, N)
            key = sprintf('%s|%.9g|%.9g|%d|%.9g|%.9g|%.9g|%d|%d', obj.Waveform, obj.VHigh, ...
                obj.VLow, obj.NumSteps, obj.EdgeTime, obj.Dwell, obj.SinePeriod, dtUs, N);
        end

        function keys = baselKeys(~, key, d)
            % Content of AWG k: forward A/B/C carry roles 1/2/3, backward 1/3/2.
            r = mod(d*(0:2), 3) + 1;
            keys = arrayfun(@(k) sprintf('%s|role%d', key, r(k)), 1:3, 'UniformOutput', false);
        end

        function s = stateString(obj, v)
            s = sprintf('%s %+.3f / %s %+.3f / %s %+.3f V', obj.GateNames{1}, v(1), ...
                obj.GateNames{2}, v(2), obj.GateNames{3}, v(3));
        end

        function ensureConfigured(obj)
            switch obj.Device
                case 'basel', obj.baselConfigure();
                case 'qdac',  obj.qdacConfigure();
            end
        end

        function claim(obj, key)
            ccdShuttle.registry('claim', key, obj.regOwner);
            obj.regKeys{end+1} = key;
        end

        function say(obj, varargin)
            if obj.Verbose, fprintf([varargin{1} '\n'], varargin{2:end}); end
        end
    end

    % ===================================================================
    %  LNHR DAC IIa: AWG memory holds absolute 24-bit DAC codes
    % ===================================================================
    methods (Access = private)
        function baselConfigure(obj)
            dac = obj.DAC; grp = obj.baselGroup;
            baselDACGetConfig(dac);
            for ch = obj.Channels
                if ~strcmpi(dac.channelStatus{ch}, 'ON'), error('ccdShuttle:off', 'CH %d is OFF.', ch); end
                if ~strcmpi(dac.channelBW{ch}, 'HBW')
                    error('ccdShuttle:lbw', ...
                        ['CH %d is in LBW (100 Hz). Switching to HBW turns the channel OFF\n' ...
                         '(1 MOhm to AGND): do it before loading charge:\n' ...
                         '    baselDACSetBandwidth(dac, %s, ''HBW'')'], ch, mat2str(obj.Channels));
                end
            end
            if obj.configured, return; end
            obj.ctrl(sprintf('AWG-%s STOP', grp));
            obj.ctrl(sprintf('AWG-%s ONLY 0', grp));
            for k = 1:3
                g = obj.baselGens{k}; ch = obj.Channels(k);
                mode = upper(strtrim(baselDACQueryMode(dac, ch)));
                if ~ismember(mode, {'DAC', 'SYN'}), error('ccdShuttle:mode', 'CH %d is in mode %s.', ch, mode); end
                obj.ctrl(sprintf('AWG-%s CH %d', g, ch));             % fixed AWG k <-> Channels(k)
                if str2double(dac.rawQuery(sprintf('C AWG-%s AVA?', g))) ~= 1
                    error('ccdShuttle:busy', 'CH %d not available to AWG-%s.', ch, g);
                end
                obj.ctrl(sprintf('AWG-%s TM 0', g));
                if ismember(g, {'A','B','C','D'})
                    obj.ctrl(sprintf('AWG-%s AS 0', g));
                    obj.ctrl(sprintf('AWG-%s RLD 0', g));
                end
            end
            if obj.BaselAWGOnly
                warning('ccdShuttle:awgOnly', 'AWG Only: other channels on board %s are frozen.', grp);
                obj.ctrl(sprintf('AWG-%s ONLY 1', grp));
            end
            obj.loadedKeys = {'', '', ''}; obj.loadedDir = 0;
            obj.loadedCount = NaN; obj.loadedN = NaN; obj.loadedDt = NaN;
            obj.configured = true;
        end

        function ctrl(obj, cmd, wait)
            % CONTROL command with a configurable settle pause (baselDAC.sendControl
            % always waits 200 ms).
            if nargin < 3, wait = obj.ControlWait; end
            resp = obj.DAC.rawQuery(['C ' cmd]);
            if ~all(strcmp(baselDAC.splitList(resp), '0'))
                error('ccdShuttle:baselCtrl', '"C %s" returned "%s".', cmd, resp);
            end
            if wait > 0, pause(wait); end
        end

        function baselAssertIdle(obj)
            for g = obj.baselGens
                if str2double(obj.DAC.rawQuery(sprintf('C AWG-%s S?', g{1}))) ~= 0
                    error('ccdShuttle:running', 'AWG-%s is running.', g{1});
                end
            end
        end

        function baselLoad(obj, V, key, dtUs, count)
            dac = obj.DAC; N = size(V, 2);
            obj.baselAssertIdle();
            todo = find(~strcmp(key, obj.loadedKeys));                 % key: 1x3 cell, per AWG
            if ~isempty(todo)
                tUp = tic;
                if dtUs ~= obj.loadedDt                               % group write: one command
                    obj.ctrl(sprintf('AWG-%s CP %d', obj.baselGroup, dtUs));
                end
                if N ~= obj.loadedN
                    for g = obj.baselGens, obj.ctrl(sprintf('AWG-%s MS %d', g{1}, N)); end
                end
                for k = todo
                    g = obj.baselGens{k};
                    hexV = obj.volt2hexVec(V(k, :));
                    cmds = cellstr([repmat(sprintf('AWG-%s ', g), N, 1), dec2hex(0:N-1, 4), ...
                                    repmat(' ', N, 1), hexV]);
                    dac.sendMultipleSet(cmds);
                    nChk = min(N, 1000);
                    back = baselDAC.splitList(dac.rawQuery(sprintf('AWG-%s 0000 BLK?', g)));
                    if numel(back) < nChk || ~all(strcmpi(back(1:nChk).', cellstr(hexV(1:nChk, :))))
                        obj.loadedKeys{k} = '';
                        error('ccdShuttle:verify', 'AWG-%s read-back mismatch.', g);
                    end
                    obj.loadedKeys{k} = key{k};
                end
                obj.loadedN = N; obj.loadedDt = dtUs;
                obj.say('  %s: uploaded %d pts x %d AWG in %.3f s', obj.Name, N, numel(todo), toc(tUp));
            end
            if count ~= obj.loadedCount                               % Cycles-Set: no group form
                for g = obj.baselGens, obj.ctrl(sprintf('AWG-%s CS %d', g{1}, count)); end
                obj.loadedCount = count;
            end
        end

        function baselFire(obj, a, d)
            if d ~= obj.loadedDir                                     % rewrite B and C memories
                obj.baselLoad(obj.playedPeriod(d, a.dtUs, a.N), obj.baselKeys(a.key, d), a.dtUs, a.count);
                obj.loadedDir = d;
            end
            if obj.CheckBeforeFire
                v = obj.readVoltages();                                      % 1 query
                if any(abs(v - a.vStart) > obj.RestTolerance)
                    obj.armed = [];
                    error('ccdShuttle:notParked', '%s: outputs %s V, expected %s V. Call park().', ...
                        obj.Name, mat2str(v, 5), mat2str(a.vStart, 5));
                end
                if str2double(obj.DAC.rawQuery(sprintf('C AWG-%s S?', obj.baselGens{1}))) ~= 0
                    error('ccdShuttle:running', '%s: AWGs are still running.', obj.Name);
                end
            end
            obj.ctrl(sprintf('AWG-%s START', obj.baselGroup), 0);           % no settle pause
        end

        function r = baselFinish(obj, pd)
            % Done when S? = 0 after the nominal duration AND the run has been
            % seen running (or StatusLatency has passed, for runs too short to
            % catch): guards against a status flag that lags the START.
            dac = obj.DAC; g = obj.baselGens{1};
            seen = false; tMax = pd.T + obj.StatusLatency + 5;
            while true
                el = toc(pd.t0);
                s  = str2double(dac.rawQuery(sprintf('C AWG-%s S?', g)));
                if s == 1
                    seen = true;
                    pause(max(0.001, pd.T - el));                            % sleep until nominal end
                elseif el >= pd.T && (seen || el >= pd.T + obj.StatusLatency)
                    break
                else
                    pause(min(0.01, max(0.001, pd.T - el)));
                end
                if el > tMax, error('ccdShuttle:timeout', 'AWGs still running after %.1f s.', el); end
            end
            cd = str2double(dac.rawQuery(sprintf('C AWG-%s CD?', g)));      % reset to 0 at START
            if cd ~= pd.count
                obj.armed = [];
                error('ccdShuttle:cycles', 'AWG-%s completed %d cycles, expected %d.', g, cd, pd.count);
            end
            dac.channelVoltages(obj.Channels) = pd.vStart;                   % cache only, no I/O
            r = struct('engine', 'basel-awg', 'pixels', pd.d*pd.count, 'elapsed', toc(pd.t0), ...
                       'seenRunning', seen);
        end

        function hexV = volt2hexVec(obj, v)
            codes = round((v(:) + 10)*obj.BASEL_LSB);
            hexV  = dec2hex(min(max(codes, 0), 16777215), 6);
        end
    end

    % ===================================================================
    %  QDAC-II Compact: DC generator, LIST mode (absolute voltages)
    % ===================================================================
    methods (Access = private)
        function qdacConfigure(obj)
            c = obj.DAC.client;
            for ch = obj.Channels
                rng = upper(strtrim(query(c, sprintf('SOUR%d:RANG?', ch))));
                if startsWith(rng, 'LOW') && max(abs([obj.VHigh obj.VLow])) > 2
                    error('ccdShuttle:range', 'CH %d is in the +/-2 V range.', ch);
                end
            end
            if obj.configured, return; end
            for ch = obj.Channels
                flt = upper(strtrim(query(c, sprintf('SOUR%d:FILT?', ch))));
                if startsWith(flt, 'DC')
                    error('ccdShuttle:filter', ...
                        ['CH %d uses the DC filter (~10 Hz). Select MED or HIGH before loading charge:\n' ...
                         '    setQDACLowPass(qdac, %d, ''HIGH'')'], ch, ch);
                end
                slew = str2double(query(c, sprintf('SOUR%d:VOLT:SLEW?', ch)));
                if isfinite(slew) && slew < 2e7
                    warning('ccdShuttle:slew', 'CH %d DC slew rate %.3g V/s also shapes the LIST edges.', ch, slew);
                end
            end
            obj.loadedKey = ''; obj.configured = true;
        end

        function qdacLoad(obj, V, key)
            c = obj.DAC.client; N = size(V, 2);
            upload = ~strcmp(key, obj.loadedKey);
            if ~upload          % cheap guard against LISTs overwritten elsewhere
                pts = arrayfun(@(ch) str2double(query(c, sprintf('SOUR%d:LIST:POIN?', ch))), obj.Channels);
                upload = any(pts ~= N);
            end
            if ~upload, return; end
            tUp = tic;
            [~, ~, endian] = computer;
            for k = 1:3
                ch = obj.Channels(k);
                u  = single(V(k, :));
                if endian == 'B', u = swapbytes(u); end              % little-endian binary32
                pl  = typecast(u, 'uint8'); nb = numel(pl);
                hdr = sprintf('SOUR%d:LIST:VOLT #%d%d', ch, numel(sprintf('%d', nb)), nb);
                ccdShuttle.writeRawBytes(c, [uint8(hdr), pl, uint8(10)]);
                ccdShuttle.qdacErrors(c, sprintf('LIST upload CH %d', ch));
                if str2double(query(c, sprintf('SOUR%d:LIST:POIN?', ch))) ~= N
                    obj.loadedKey = '';
                    error('ccdShuttle:verify', 'CH %d LIST length mismatch.', ch);
                end
            end
            obj.loadedKey = key;
            obj.qdacArmed = false;
            obj.say('  %s: uploaded %d pts x 3 in %.2f s', obj.Name, N, toc(tUp));
        end

        function qdacArm(obj, count, dtUs, full, d)
            % full: (re)write LIST settings, direction, trigger source and mode
            % (needed after arm/ramps). Otherwise only re-INIT (after a run).
            c = obj.DAC.client;
            dirs = {'DOWN', '', 'UP'};
            if full
                for ch = obj.Channels
                    fprintf(c, sprintf('SOUR%d:LIST:DWEL %.9g', ch, dtUs*1e-6));
                    fprintf(c, sprintf('SOUR%d:LIST:TMOD AUTO', ch));
                    fprintf(c, sprintf('SOUR%d:LIST:DIR %s', ch, dirs{d+2}));
                    fprintf(c, sprintf('SOUR%d:LIST:COUN %d', ch, count));
                    fprintf(c, sprintf('SOUR%d:DC:TRIG:SOUR INT%d', ch, obj.TriggerNumber));
                    fprintf(c, sprintf('SOUR%d:DC:INIT:CONT OFF', ch));
                    fprintf(c, sprintf('SOUR%d:DC:MODE LIST', ch));           % no jump until triggered
                end
                ccdShuttle.qdacErrors(c, 'LIST configuration');
                obj.loadedCount = count;
                obj.qdacDir = d;
            end
            for ch = obj.Channels, fprintf(c, sprintf('SOUR%d:DC:INIT', ch)); end   % arm
            obj.qdacArmed = true;
        end

        function qdacFire(obj, a, d)
            c = obj.DAC.client;
            if ~obj.qdacArmed
                obj.qdacArm(a.count, a.dtUs, true, d);                        % e.g. after a ramp
            elseif d ~= obj.qdacDir                                           % 6 writes, no upload
                dirs = {'DOWN', '', 'UP'};
                for ch = obj.Channels
                    fprintf(c, sprintf('SOUR%d:LIST:DIR %s', ch, dirs{d+2}));
                    fprintf(c, sprintf('SOUR%d:DC:INIT', ch));
                end
                obj.qdacDir = d;
            end
            if obj.CheckBeforeFire                                            % 1 query
                m = upper(query(c, sprintf('SOUR:DC:MODE? (@%d,%d,%d)', obj.Channels)));
                if numel(strfind(m, 'LIST')) < 3
                    obj.qdacArmed = false; obj.armed = [];
                    error('ccdShuttle:modeChanged', ...
                        '%s: DC mode changed outside ccdShuttle ("%s"). Call park(), then move().', ...
                        obj.Name, strtrim(m));
                end
            end
            fprintf(c, sprintf('TINT %d', obj.TriggerNumber));                % fire all three
        end

        function r = qdacFinish(obj, pd)
            c = obj.DAC.client;
            % NCLeft? reads 0 both when idle and when armed-not-yet-triggered,
            % so sleep through the nominal duration before polling.
            pause(max(0, pd.T - toc(pd.t0)) + 0.002);
            while str2double(query(c, sprintf('SOUR%d:LIST:NCL?', obj.Channels(1)))) ~= 0
                if toc(pd.t0) > pd.T + 5
                    error('ccdShuttle:timeout', 'LISTs still running after %.1f s.', toc(pd.t0));
                end
                pause(0.002);
            end
            e = strtrim(query(c, 'SYST:ERR:ALL?'));
            if ~startsWith(e, '0')
                obj.qdacArmed = false; obj.armed = [];
                error('ccdShuttle:qdacError', 'QDAC error after LIST run:\n  %s', e);
            end
            obj.DAC.channelVoltages(obj.Channels) = pd.vStart;
            for ch = obj.Channels, fprintf(c, sprintf('SOUR%d:DC:INIT', ch)); end   % re-arm
            obj.qdacArmed = true;
            r = struct('engine', 'qdac-list', 'pixels', pd.d*pd.count, 'elapsed', toc(pd.t0));
        end
    end

    % ===================================================================
    %  Static helpers
    % ===================================================================
    methods (Static, Access = private)
        function out = registry(op, key, owner)
            % Process-wide claims (AWG group, channels, trigger numbers). A claim
            % by an object of the SAME name is taken over (re-running setupCCDs).
            persistent M
            if isempty(M), M = containers.Map('KeyType', 'char', 'ValueType', 'any'); end
            out = [];
            switch op
                case 'isfree'
                    out = true;
                    if isKey(M, key), cur = M(key); out = strcmp(cur.name, owner.name); end
                case 'claim'
                    if isKey(M, key)
                        cur = M(key);
                        if ~strcmp(cur.name, owner.name)
                            error('ccdShuttle:resourceBusy', '%s is already used by ccdShuttle "%s".', key, cur.name);
                        end
                    end
                    M(key) = owner;
                case 'release'
                    if isKey(M, key)
                        cur = M(key);
                        if strcmp(cur.id, owner.id), remove(M, key); end
                    end
            end
        end

        function id = newId(name)
            persistent k
            if isempty(k), k = 0; end
            k = k + 1; id = sprintf('%s#%d', name, k);
        end

        function a = dacAddress(dac)
            if isprop(dac, 'IPAddress') && ~isempty(dac.IPAddress)
                a = char(string(dac.IPAddress));
            elseif isprop(dac, 'comPort') && ~isempty(dac.comPort)
                a = char(string(dac.comPort));
            else
                a = class(dac);
            end
        end

        function writeRawBytes(client, bytes)
            % QDAC.m uses fprintf/query (legacy tcpip/visa): fwrite is limited
            % to OutputBufferSize per call, so the binary block is chunked.
            if isa(client, 'tcpclient')
                write(client, bytes);
            else
                n = client.OutputBufferSize;
                for k = 1:n:numel(bytes)
                    fwrite(client, bytes(k:min(k+n-1, end)), 'uint8');
                end
            end
        end

        function qdacErrors(client, context)
            e = strtrim(query(client, 'SYST:ERR:ALL?'));
            if ~startsWith(e, '0')
                error('ccdShuttle:qdacError', 'QDAC error after %s:\n  %s', context, e);
            end
        end
    end
end