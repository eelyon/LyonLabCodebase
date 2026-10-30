classdef DACMonitorGUI < handle
    %DACMONITORGUI  Monitor window for a QDAC or a baselDAC.
    %
    %   Same idea as sigDACGUI: a grid of channels, 8 per column, showing the
    %   DAC object's cached state from the base workspace. Voltages are
    %   display-only. Channel SETTINGS can be changed after pressing
    %   "Unlock settings":
    %     QDAC      range (+/-10 V, +/-2 V) and filter (DC/MED/HIGH)
    %     baselDAC  status (ON/OFF) and bandwidth (LBW/HBW)
    %   Every change asks for confirmation. While unlocked, the coloured
    %   cells become drop-downs and auto-refresh is paused.
    %
    %   Columns per channel
    %     QDAC      gate/channel | voltage | range (+/-10 V, +/-2 V) | filter (DC/MED/HIGH)
    %     baselDAC  gate/channel | voltage | status (ON/OFF)         | bandwidth (LBW/HBW)
    %     other     gate/channel | voltage   (e.g. sigDAC)
    %
    %   USAGE
    %     gq = DACMonitorGUI('qDAC');                         % name of the variable in base
    %     gq = DACMonitorGUI(qDAC);                           % or the object itself
    %     gb = DACMonitorGUI('baselDAC', 'Pinout', 'pinout_sandia_roic.m');
    %     gq = DACMonitorGUI('qDAC', 'Pinout', 'pinout', 'AutoRefresh', true, 'Period', 2);
    %
    %   Name-value options
    %     'Pinout'       pinout struct, name of a struct variable in the base
    %                    workspace, or a pinout script given AS TEXT, with or
    %                    without .m, on the path or as a full path (run in the
    %                    base workspace; it must define a variable 'pinout').
    %                    Unquoted, MATLAB would try to run the script as a
    %                    function before the GUI is even called.
    %     'AutoRefresh'  re-read the cache periodically (default false)
    %     'Period'       auto-refresh period [s] (default 2)
    %     'ReadOnOpen'   read the instrument once on opening. Default: true
    %                    for baselDAC (its cache holds placeholders until
    %                    baselDACGetConfig runs), false otherwise.
    %
    %   BUTTONS
    %     Update All     show the cached values (no instrument traffic)
    %     Read instrument  QDACRefresh / baselDACGetConfig, then show.
    %                    Use it if settings were changed outside the class
    %                    methods, or to see the true output after a ramp
    %                    started without 'Wait' (the cache holds targets).
    %     Load pinout...   choose a pinout script; gate names replace ch1, ch2, ...
    %     Plot           bar chart of all channel voltages, labelled by gate
    %     Unlock settings / Lock settings
    %                    toggles editing of range/filter or status/bandwidth.
    %                    Changes go through the class methods (setQDACRange,
    %                    setQDACLowPass, baselDACSetStatus, baselDACSetBandwidth),
    %                    so the cache, and therefore your scripts, stay in sync.
    %                    Avoid changing a channel while a script is using it:
    %                    the change takes effect between the script's commands.
    %
    %   PINOUT FORMAT (as in pinout_sandia_roic.m)
    %     pinout.<gate>.device = <DAC object>   (or its variable name as text)
    %     pinout.<gate>.port   = <channel>
    %   Entries for other DACs are ignored. A gate is matched to this DAC by
    %   object identity, or - if the DAC object was re-created after the
    %   pinout was built - by the same class and IP address / COM port.
    %
    %   Auto-refresh only reads the cached properties: it never sends a
    %   command to the instrument, so it cannot interleave with a script
    %   that is talking to the DAC.

    % =====================================================================
    properties (SetAccess = private)
        UIFigure                        % matlab.ui.Figure
        instrumentName                  % variable name in the base workspace
        dacClass                        % 'QDAC' | 'baselDAC' | other class name
        numChannels
        gateNames                       % 1 x N cellstr, '' = no gate on that channel
        pinoutSource = ''               % description of the loaded pinout
    end

    properties (Access = private)
        titleLabel
        infoLabel
        statusLabel
        legendLabel
        pinoutVarField
        showNamesBox
        autoBox
        periodField
        nameLabels                      % 1 x N uilabel
        voltFields                      % 1 x N numeric edit fields (read-only)
        attrLabels                      % N x 2 uilabel   (shown while locked)
        attrDrops                       % N x 2 uidropdown (shown while unlocked)
        lockButton                      % state button
        lockDefaultColor
        locked = true
        resumeAuto = false              % restart auto-refresh when re-locked
        refreshTimer
    end

    properties (Constant, Access = private)
        % ---- display settings: edit here ---------------------------------
        CHANNEL_PREFIX = 'ch'           % label for channels without a gate: ch1, ch2, ...
        VOLT_FORMAT    = '%+.3f'        % voltage display: 3 decimals = 1 mV
        % ------------------------------------------------------------------
        ROWS_PER_COL = 8
        C_PLAIN  = [0.96 0.96 0.96]
        C_AMBER  = [1.00 0.84 0.50]     % QDAC LOW range, baselDAC HBW
        C_BLUE   = [0.72 0.85 1.00]     % QDAC FILTer DC
        C_GREEN  = [0.75 0.93 0.75]     % QDAC FILTer MED, baselDAC ON
        C_GREY   = [0.80 0.80 0.80]     % baselDAC OFF
        C_RED    = [1.00 0.70 0.70]     % unknown / error
        C_DUPL   = [1.00 0.90 0.60]     % two gates on one channel
        C_UNLOCK = [1.00 0.62 0.55]     % lock button while settings are editable
    end

    % =====================================================================
    %  CONSTRUCTION / DESTRUCTION
    % =====================================================================
    methods
        function app = DACMonitorGUI(instrumentName, opts)
            arguments
                instrumentName = 'qDAC'          % variable name (text) or the DAC object
                opts.Pinout = []
                opts.AutoRefresh (1,1) logical = false
                opts.Period (1,1) double {mustBePositive} = 10
                opts.ReadOnOpen = []
            end
            if isobject(instrumentName)
                % Object passed directly: find which base variable holds it.
                nm = DACMonitorGUI.findBaseVariable(instrumentName);
                if isempty(nm)
                    error('DACMonitorGUI:notInBase', ...
                        ['This DAC object is not stored in a base-workspace variable. ' ...
                         'Create it at the command line, then pass its name, e.g. ' ...
                         'DACMonitorGUI(''qDAC'').']);
                end
                instrumentName = nm;
            end
            app.instrumentName = char(instrumentName);
            dac = app.getDAC();
            app.dacClass    = class(dac);
            app.numChannels = dac.numChannels;
            app.gateNames   = repmat({''}, 1, app.numChannels);

            app.createComponents(dac);

            if ~isempty(opts.Pinout)
                app.loadPinout(opts.Pinout);
            end

            readOnOpen = opts.ReadOnOpen;
            if isempty(readOnOpen)
                readOnOpen = strcmp(app.dacClass, 'baselDAC');
            end
            if readOnOpen
                app.readInstrument();
            else
                app.updateDACGUI();
            end

            if opts.AutoRefresh
                app.periodField.Value = opts.Period;
                app.autoBox.Value = true;
                app.setAutoRefresh(true);
            end
        end

        function delete(app)
            app.stopTimer();
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end

    % =====================================================================
    %  PUBLIC API (same names as sigDACGUI, so scripts can trigger updates)
    % =====================================================================
    methods
        function updateDACGUI(app)
            % UPDATEDACGUI  Show the cached state of all channels.
            app.refreshFromCache(1:app.numChannels);
        end

        function updateDACGUIChan(app, channels)
            % UPDATEDACGUICHAN  Show the cached state of selected channels.
            app.refreshFromCache(channels);
        end

        function readInstrument(app)
            % READINSTRUMENT  Query the instrument, then show the result.
            dac = app.getDAC();
            try
                switch app.dacClass
                    case 'QDAC',     QDACRefresh(dac);
                    case 'baselDAC', baselDACGetConfig(dac);
                    otherwise
                        app.setStatus('This DAC type has no read-back; showing the cache.');
                end
                app.refreshFromCache(1:app.numChannels);
                app.setStatus(sprintf('Instrument read at %s', datestr(now, 'HH:MM:SS')));
            catch ME
                app.setStatus(['Read failed: ' ME.message]);
                uialert(app.UIFigure, ME.message, 'Read instrument failed');
            end
        end

        function loadPinout(app, src)
            % LOADPINOUT  Use gate names from a pinout.
            %   src: pinout struct | name of a base-workspace variable |
            %        path to a pinout .m script (run in the base workspace)
            varName = strtrim(app.pinoutVarField.Value);
            if isempty(varName), varName = 'pinout'; end
            if isstruct(src)
                p = src;
                label = 'struct';
            else
                s = strtrim(char(src));
                % A script name without .m (on the MATLAB path) unless a
                % workspace variable of that name exists.
                isVar = isvarname(s) && evalin('base', sprintf('exist(''%s'', ''var'')', s));
                if ~isVar && ~endsWith(s, '.m', 'IgnoreCase', true) && exist(s, 'file') == 2
                    s = which(s);
                end
                if endsWith(s, '.m', 'IgnoreCase', true)
                    if ~isfile(s)
                        error('DACMonitorGUI:noFile', 'Pinout script "%s" not found.', s);
                    end
                    % Run in base: the script needs the DAC variables there and
                    % leaves 'pinout' there for your own scripts as well.
                    evalin('base', sprintf('run(''%s'');', strrep(s, '''', '''''')));
                    [~, f, e] = fileparts(s);
                    label = [f e];
                else
                    varName = s;
                    label = s;
                end
                if ~evalin('base', sprintf('exist(''%s'', ''var'')', varName))
                    error('DACMonitorGUI:noPinout', ...
                        'No variable "%s" in the base workspace after loading the pinout.', varName);
                end
                p = evalin('base', varName);
            end

            [names, msgs] = DACMonitorGUI.mapPinout(p, app.getDAC(), ...
                app.instrumentName, app.numChannels);
            app.gateNames = names;
            app.pinoutSource = label;
            app.showNamesBox.Value = true;
            app.refreshNames();

            nMapped = sum(~cellfun(@isempty, names));
            txt = sprintf('Pinout %s: %d of %d channels named.', label, nMapped, app.numChannels);
            if nMapped == 0
                txt = [txt ' No entries for this DAC - was the pinout built for another object?'];
            end
            app.setStatus(txt);
            if ~isempty(msgs)
                uialert(app.UIFigure, strjoin(msgs, newline), 'Pinout notes', 'Icon', 'warning');
            end
        end

        function fig = plotState(app)
            % PLOTSTATE  Bar chart of the cached voltages, labelled by gate.
            %   QDAC bars are coloured by range, baselDAC bars by status.
            dac = app.getDAC();
            n   = app.numChannels;
            v   = dac.channelVoltages(1:n);
            labels = arrayfun(@(c) app.channelText(c), 1:n, 'UniformOutput', false);
            colors = zeros(n, 3);
            for c = 1:n
                [~, bg] = app.attrDisplay(dac, c, 1);
                colors(c, :) = bg;
            end
            fig = figure('Name', sprintf('%s voltages', app.instrumentName), 'Color', 'w');
            b = bar(1:n, v, 'FaceColor', 'flat', 'EdgeColor', [0.3 0.3 0.3]);
            b.CData = colors;
            set(gca, 'XTick', 1:n, 'XTickLabel', labels, 'TickLabelInterpreter', 'none');
            xtickangle(60);
            ylabel('Voltage (V)');
            grid on;
            hdr = app.attrHeaders();
            ttl = sprintf('%s (%s), cached values', app.instrumentName, app.dacClass);
            if ~isempty(hdr)
                ttl = sprintf('%s - bar colour = %s', ttl, lower(hdr{1}));
            end
            title(ttl, 'Interpreter', 'none');
            for c = 1:n
                text(c, v(c), sprintf('%+.3f', v(c)), 'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', ifelse(v(c) >= 0, 'bottom', 'top'), 'FontSize', 7);
            end
        end
    end

    % =====================================================================
    %  DISPLAY
    % =====================================================================
    methods (Access = private)
        function refreshFromCache(app, channels)
            dac = app.getDAC();
            channels = channels(:).';                                  % row: for-loop over elements
            channels = channels(channels >= 1 & channels <= app.numChannels);
            v = dac.channelVoltages;
            for c = channels
                if c <= numel(v)
                    app.voltFields(c).Value = v(c);
                end
                app.voltFields(c).Tooltip = app.voltTooltip(dac, c);
                for k = 1:2
                    [txt, bg, tip] = app.attrDisplay(dac, c, k);
                    app.attrLabels(c, k).Text = txt;
                    app.attrLabels(c, k).BackgroundColor = bg;
                    app.attrLabels(c, k).Tooltip = tip;
                    d = app.attrDrops(c, k);
                    if isa(d, 'matlab.ui.control.DropDown')
                        code = app.attrCode(dac, c, k);
                        if any(strcmp(code, d.ItemsData))
                            d.Value = code;
                        end
                        d.BackgroundColor = bg;
                        d.Tooltip = tip;
                    end
                end
            end
            app.setStatus(sprintf('Cache shown at %s%s', datestr(now, 'HH:MM:SS'), ...
                app.pinoutSuffix()));
        end

        function refreshNames(app)
            for c = 1:app.numChannels
                app.nameLabels(c).Text = app.channelText(c);
                nm = app.gateNames{c};
                if isempty(nm)
                    app.nameLabels(c).Tooltip = sprintf('%s channel %d (no gate in pinout)', app.dacClass, c);
                else
                    app.nameLabels(c).Tooltip = sprintf('%s channel %d: %s', app.dacClass, c, nm);
                end
                if app.showNamesBox.Value && contains(nm, '/')
                    app.nameLabels(c).BackgroundColor = DACMonitorGUI.C_DUPL;
                else
                    app.nameLabels(c).BackgroundColor = DACMonitorGUI.C_PLAIN;
                end
            end
        end

        function txt = channelText(app, c)
            nm = app.gateNames{c};
            if app.showNamesBox.Value && ~isempty(nm)
                txt = sprintf('%s (%d)', nm, c);
            else
                txt = sprintf('%s%d', DACMonitorGUI.CHANNEL_PREFIX, c);
            end
        end

        function items = attrItems(app)
            % {displayed items, stored values} for the two settings columns.
            switch app.dacClass
                case 'QDAC'
                    items = {{[char(177) '10 V'], [char(177) '2 V']}, {'HIGH', 'LOW'}; ...
                             {'HIGH', 'MED', 'DC'},                   {'HIGH', 'MED', 'DC'}};
                case 'baselDAC'
                    items = {{'ON', 'OFF'}, {'ON', 'OFF'}; ...
                             {'LBW', 'HBW'}, {'LBW', 'HBW'}};
                otherwise
                    items = {};
            end
        end

        function hdr = attrHeaders(app)
            switch app.dacClass
                case 'QDAC',     hdr = {'Range', 'Filter'};
                case 'baselDAC', hdr = {'Status', 'BW'};
                otherwise,       hdr = {};
            end
        end

        function code = attrCode(app, dac, c, k)
            % Cached setting k of channel c as the class stores it.
            props = struct('QDAC', {{'channelRange', 'channelFilter'}}, ...
                           'baselDAC', {{'channelStatus', 'channelBW'}});
            code = '';
            if isfield(props, app.dacClass)
                code = DACMonitorGUI.cellAt(dac, props.(app.dacClass){k}, c);
            end
        end

        function [txt, bg, tip] = attrDisplay(app, dac, c, k)
            % Text, background colour and tooltip of attribute k of channel c.
            txt = ''; bg = DACMonitorGUI.C_PLAIN; tip = '';
            switch app.dacClass
                case 'QDAC'
                    if k == 1
                        r = DACMonitorGUI.cellAt(dac, 'channelRange', c);
                        switch r
                            case 'HIGH', txt = char([177 '10 V']); bg = DACMonitorGUI.C_GREY; tip = 'HIGH range, +/-10 V';
                            case 'LOW',  txt = char([177 '2 V']);  tip = 'LOW range, +/-2 V';
                                bg = DACMonitorGUI.C_AMBER;
                            otherwise,   txt = '?'; bg = DACMonitorGUI.C_RED; tip = 'Range unknown';
                        end
                    else
                        f = DACMonitorGUI.cellAt(dac, 'channelFilter', c);
                        switch f
                            case 'DC',   txt = 'DC';   bg = DACMonitorGUI.C_AMBER;
                                tip = ['DC filter (~10 Hz): FIXed mode only, no sweeps/AWG; ' ...
                                       'ramps are stepped from MATLAB'];
                            case 'MED',  txt = 'MED';  bg = DACMonitorGUI.C_BLUE;
                                tip = 'MED filter (~10 kHz)';
                            case 'HIGH', txt = 'HIGH'; bg = DACMonitorGUI.C_GREY; tip = 'HIGH filter (~230 kHz), default';
                            otherwise,   txt = '?'; bg = DACMonitorGUI.C_RED; tip = 'Filter unknown';
                        end
                    end
                case 'baselDAC'
                    if k == 1
                        s = DACMonitorGUI.cellAt(dac, 'channelStatus', c);
                        switch s
                            case 'ON',  txt = 'ON';  bg = DACMonitorGUI.C_GREEN; tip = 'Output on';
                            case 'OFF', txt = 'OFF'; bg = DACMonitorGUI.C_GREY;
                                tip = 'Output off: pulled to AGND via 1 MOhm || 22 nF';
                            otherwise,  txt = '?';   bg = DACMonitorGUI.C_RED;  tip = 'Status unknown';
                        end
                    else
                        b = DACMonitorGUI.cellAt(dac, 'channelBW', c);
                        switch b
                            case 'LBW', txt = 'LBW'; bg = DACMonitorGUI.C_AMBER; tip = 'Low bandwidth (100 Hz)';
                            case 'HBW', txt = 'HBW'; bg = DACMonitorGUI.C_GREY;
                                tip = 'High bandwidth (100 kHz)';
                            otherwise,  txt = '?';   bg = DACMonitorGUI.C_RED; tip = 'Bandwidth unknown';
                        end
                    end
            end
        end

        function tip = voltTooltip(app, dac, c)
            tip = sprintf('%s channel %d', app.dacClass, c);
            if ~isempty(app.gateNames{c})
                tip = sprintf('%s - %s', tip, app.gateNames{c});
            end
            if strcmp(app.dacClass, 'QDAC')
                if isprop(dac, 'channelSlew') && numel(dac.channelSlew) >= c
                    s = dac.channelSlew(c);
                    if isinf(s), sTxt = 'unlimited'; else, sTxt = sprintf('%g V/s', s); end
                    tip = sprintf('%s\nDC slew: %s', tip, sTxt);
                end
                ir = DACMonitorGUI.cellAt(dac, 'channelCurrentRange', c);
                if ~isempty(ir)
                    tip = sprintf('%s\nCurrent range: %s', tip, ir);
                end
                tip = sprintf('%s\n(cache: target of the last set/ramp)', tip);
            end
        end

        function setStatus(app, txt)
            if ~isempty(app.statusLabel) && isvalid(app.statusLabel)
                app.statusLabel.Text = txt;
            end
        end

        function s = pinoutSuffix(app)
            if isempty(app.pinoutSource), s = ''; else, s = ['  |  pinout: ' app.pinoutSource]; end
        end

        function dac = getDAC(app)
            name = app.instrumentName;
            if ~evalin('base', sprintf('exist(''%s'', ''var'')', name))
                error('DACMonitorGUI:noDAC', ...
                    'No variable "%s" in the base workspace. Connect the DAC first.', name);
            end
            dac = evalin('base', name);
            if ~isobject(dac) || ~isprop(dac, 'channelVoltages') || ~isprop(dac, 'numChannels')
                error('DACMonitorGUI:notDAC', '"%s" is not a DAC object.', name);
            end
        end
    end

    % =====================================================================
    %  AUTO-REFRESH
    % =====================================================================
    methods (Access = private)
        function setAutoRefresh(app, on)
            app.stopTimer();
            if ~app.locked                       % paused while settings are editable
                app.resumeAuto = on;
                return
            end
            if ~on, return; end
            period = max(0.2, app.periodField.Value);
            app.refreshTimer = timer('Name', ['DACMonitor_' app.instrumentName], ...
                'ExecutionMode', 'fixedSpacing', 'Period', period, 'BusyMode', 'drop', ...
                'TimerFcn', @(~, ~) app.timerTick());
            start(app.refreshTimer);
        end

        function timerTick(app)
            if isempty(app.UIFigure) || ~isvalid(app.UIFigure)
                app.stopTimer();
                return
            end
            try
                app.updateDACGUI();
            catch ME
                app.setStatus(['Auto-refresh paused: ' ME.message]);
                app.autoBox.Value = false;
                app.stopTimer();
            end
        end

        function stopTimer(app)
            if ~isempty(app.refreshTimer) && isvalid(app.refreshTimer)
                stop(app.refreshTimer);
                delete(app.refreshTimer);
            end
            app.refreshTimer = [];
        end
    end

    % =====================================================================
    %  CALLBACKS
    % =====================================================================
    methods (Access = private)
        function setLocked(app, locked)
            % Swap coloured labels and drop-downs; pause auto-refresh while unlocked.
            if ~locked
                app.resumeAuto = app.autoBox.Value;
                app.stopTimer();
                app.refreshFromCache(1:app.numChannels);   % drop-downs show current state
            end
            app.locked = locked;
            for c = 1:app.numChannels
                for k = 1:2
                    app.attrLabels(c, k).Visible = locked;
                    if isa(app.attrDrops(c, k), 'matlab.ui.control.DropDown')
                        app.attrDrops(c, k).Visible = ~locked;
                    end
                end
            end
            app.lockButton.Value = ~locked;
            if locked
                app.lockButton.Text = 'Unlock settings';
                app.lockButton.BackgroundColor = app.lockDefaultColor;
                app.refreshFromCache(1:app.numChannels);
                if app.resumeAuto
                    app.setAutoRefresh(true);
                end
            else
                app.lockButton.Text = 'Lock settings';
                app.lockButton.BackgroundColor = DACMonitorGUI.C_UNLOCK;
                app.setStatus('Settings UNLOCKED - auto-refresh paused. Lock again when done.');
            end
        end

        function onAttrChanged(app, c, k, src, evt)
            % A settings drop-down was changed: confirm, apply, show result.
            newVal = evt.Value;
            oldVal = evt.PreviousValue;
            if app.locked || isequal(newVal, oldVal)
                src.Value = oldVal;
                return
            end
            gate = app.channelText(c);
            [what, question] = app.describeChange(c, k, oldVal, newVal);
            sel = uiconfirm(app.UIFigure, question, ['Change ' what], ...
                'Options', {'Change', 'Cancel'}, 'DefaultOption', 2, ...
                'CancelOption', 2, 'Icon', 'warning');
            if ~strcmp(sel, 'Change')
                src.Value = oldVal;
                return
            end
            try
                dac = app.getDAC();
                switch sprintf('%s_%d', app.dacClass, k)
                    case 'QDAC_1',     setQDACRange(dac, c, newVal);
                    case 'QDAC_2',     setQDACLowPass(dac, c, newVal);
                    case 'baselDAC_1', baselDACSetStatus(dac, c, newVal);
                    case 'baselDAC_2', baselDACSetBandwidth(dac, c, newVal);
                end
                app.refreshFromCache(c);
                app.setStatus(sprintf('%s: %s %s -> %s at %s', gate, what, ...
                    oldVal, newVal, datestr(now, 'HH:MM:SS')));
            catch ME
                src.Value = oldVal;
                app.refreshFromCache(c);
                uialert(app.UIFigure, ME.message, sprintf('%s not changed', what));
            end
        end

        function [what, q] = describeChange(app, c, k, oldVal, newVal)
            % Name of the setting and a confirmation question with consequences.
            gate = app.channelText(c);
            switch sprintf('%s_%d', app.dacClass, k)
                case 'QDAC_1'
                    what = 'range';
                    lbl = struct('HIGH', [char(177) '10 V'], 'LOW', [char(177) '2 V']);
                    q = sprintf(['Change the range of %s from %s to %s?\n\n' ...
                        'Only allowed at 0 V. The output is set to 0 V again ' ...
                        'after the change.'], gate, lbl.(oldVal), lbl.(newVal));
                case 'QDAC_2'
                    what = 'filter';
                    q = sprintf('Change the output filter of %s from %s to %s?', gate, oldVal, newVal);
                    if strcmp(newVal, 'DC')
                        q = [q sprintf(['\n\nDC filter: ~10 Hz bandwidth, 25-bit resolution, ' ...
                            'FIXed mode only - no hardware sweeps or AWG; ramps on this ' ...
                            'channel are then stepped from MATLAB.'])];
                    end
                case 'baselDAC_1'
                    what = 'status';
                    q = sprintf('Switch %s %s?', gate, newVal);
                    if strcmp(newVal, 'OFF')
                        q = [q sprintf(['\n\nThe output is disconnected and pulled to ' ...
                            'ground via 1 MOhm || 22 nF.'])];
                    end
                case 'baselDAC_2'
                    what = 'bandwidth';
                    q = sprintf(['Change the bandwidth of %s from %s to %s?\n\n' ...
                        'To avoid a glitch, a channel that is ON is switched OFF ' ...
                        'during the change and back ON afterwards - the gate is ' ...
                        'briefly pulled to ground.'], gate, oldVal, newVal);
                otherwise
                    what = 'setting';
                    q = sprintf('Change %s from %s to %s?', gate, oldVal, newVal);
            end
        end

        function onUpdateBlock(app, channels)
            try
                app.refreshFromCache(channels);
            catch ME
                uialert(app.UIFigure, ME.message, 'Update failed');
            end
        end

        function onLoadPinout(app)
            [f, p] = uigetfile({'*.m', 'Pinout script (*.m)'}, 'Choose a pinout script');
            figure(app.UIFigure);                       % bring the GUI back to front
            if isequal(f, 0), return; end
            try
                app.loadPinout(fullfile(p, f));
            catch ME
                uialert(app.UIFigure, ME.message, 'Pinout not loaded');
            end
        end

        function onPinoutVar(app)
            name = strtrim(app.pinoutVarField.Value);
            if isempty(name), return; end
            try
                app.loadPinout(name);
            catch ME
                uialert(app.UIFigure, ME.message, 'Pinout not loaded');
            end
        end

        function onClose(app)
            sel = uiconfirm(app.UIFigure, sprintf('Close the %s monitor?', app.instrumentName), ...
                'Close', 'Options', {'Yes', 'No'}, 'DefaultOption', 1, 'CancelOption', 2);
            if strcmp(sel, 'Yes')
                delete(app);
            end
        end
    end

    % =====================================================================
    %  LAYOUT
    % =====================================================================
    methods (Access = private)
        function createComponents(app, dac)
            n     = app.numChannels;
            nRows = DACMonitorGUI.ROWS_PER_COL;
            nCols = ceil(n / nRows);
            hdr   = app.attrHeaders();
            hasAttr = ~isempty(hdr);
            colW  = 215 + 110 * hasAttr;

            app.UIFigure = uifigure('Visible', 'off', ...
                'Name', sprintf('%s monitor (%s)', app.instrumentName, app.dacClass), ...
                'Position', [100 100 max(1040, nCols * colW + 40) 440]);
            app.UIFigure.CloseRequestFcn = @(~, ~) app.onClose();

            main = uigridlayout(app.UIFigure, [5 1]);
            main.RowHeight = {34, 28, '1x', 22, 22};
            main.RowSpacing = 6;

            % --- title ----------------------------------------------------
            top = uigridlayout(main, [1 2]);
            top.ColumnWidth = {'1x', '1x'};
            top.Padding = [0 0 0 0];
            app.titleLabel = uilabel(top, 'Text', sprintf('%s  -  %s', app.dacClass, app.instrumentName), ...
                'FontSize', 22, 'FontWeight', 'bold', 'Interpreter', 'none');
            idn = '';
            if isprop(dac, 'identifier'), idn = char(dac.identifier); end
            addr = DACMonitorGUI.endpoint(dac);
            app.infoLabel = uilabel(top, 'Text', strtrim(sprintf('%s   %s', addr, idn)), ...
                'HorizontalAlignment', 'right', 'FontColor', [0.4 0.4 0.4], 'Interpreter', 'none');

            % --- controls -------------------------------------------------
            ctl = uigridlayout(main, [1 12]);
            ctl.ColumnWidth = {95, 115, 105, 70, 80, 120, 95, 45, 15, 50, 120, '1x'};
            ctl.Padding = [0 0 0 0];
            uibutton(ctl, 'Text', 'Update All', 'FontWeight', 'bold', ...
                'Tooltip', 'Show cached values (no instrument traffic)', ...
                'ButtonPushedFcn', @(~, ~) app.onUpdateBlock(1:n));
            uibutton(ctl, 'Text', 'Read instrument', ...
                'Tooltip', 'Query the instrument (QDACRefresh / baselDACGetConfig), then show', ...
                'ButtonPushedFcn', @(~, ~) app.readInstrument());
            uibutton(ctl, 'Text', 'Load pinout...', ...
                'Tooltip', 'Run a pinout.m script in the base workspace and use its gate names', ...
                'ButtonPushedFcn', @(~, ~) app.onLoadPinout());
            uilabel(ctl, 'Text', 'Pinout var', 'HorizontalAlignment', 'right');
            app.pinoutVarField = uieditfield(ctl, 'text', 'Value', 'pinout', ...
                'Tooltip', 'Name of the pinout struct in the base workspace (Enter to load)', ...
                'ValueChangedFcn', @(~, ~) app.onPinoutVar());
            app.showNamesBox = uicheckbox(ctl, 'Text', 'Show gate names', 'Value', false, ...
                'ValueChangedFcn', @(~, ~) app.refreshNames());
            app.autoBox = uicheckbox(ctl, 'Text', 'Auto every', 'Value', false, ...
                'Tooltip', 'Periodically show the cached values (never queries the instrument)', ...
                'ValueChangedFcn', @(src, ~) app.setAutoRefresh(src.Value));
            app.periodField = uieditfield(ctl, 'numeric', 'Value', 2, 'Limits', [0.2 3600], ...
                'ValueDisplayFormat', '%g', ...
                'ValueChangedFcn', @(~, ~) app.setAutoRefresh(app.autoBox.Value));
            uilabel(ctl, 'Text', 's');
            uibutton(ctl, 'Text', 'Plot', 'ButtonPushedFcn', @(~, ~) app.plotState());
            app.lockButton = uibutton(ctl, 'state', 'Text', 'Unlock settings', ...
                'FontWeight', 'bold', 'Value', false, ...
                'Tooltip', 'Allow changing range/filter (QDAC) or status/bandwidth (baselDAC)', ...
                'ValueChangedFcn', @(src, ~) app.setLocked(~src.Value));
            app.lockButton.Layout.Column = 11;
            app.lockDefaultColor = app.lockButton.BackgroundColor;
            if ~hasAttr
                app.lockButton.Enable = 'off';
            end
            items = app.attrItems();

            % --- channel grid ---------------------------------------------
            body = uigridlayout(main, [1 nCols]);
            body.ColumnWidth = repmat({'1x'}, 1, nCols);
            body.Padding = [0 0 0 0];
            body.ColumnSpacing = 18;

            app.nameLabels = gobjects(1, n);
            app.voltFields = gobjects(1, n);
            app.attrLabels = gobjects(n, 2);
            app.attrDrops  = gobjects(n, 2);
            for col = 1:nCols
                chans = (col - 1) * nRows + 1 : min(col * nRows, n);
                g = uigridlayout(body, [nRows + 1, 4]);
                g.RowHeight = [{16}, repmat({24}, 1, nRows)];
                if hasAttr
                    g.ColumnWidth = {'1x', 100, 50, 50};
                else
                    g.ColumnWidth = {'1x', 100, 0, 0};
                end
                g.Padding = [0 0 0 0];
                g.RowSpacing = 6;
                g.ColumnSpacing = 4;

                heads = [{'Gate (ch)', 'Voltage (V)'}, hdr];
                for h = 1:numel(heads)
                    lh = uilabel(g, 'Text', heads{h}, 'FontSize', 10, ...
                        'FontColor', [0.35 0.35 0.35], 'HorizontalAlignment', 'center');
                    lh.Layout.Row = 1; lh.Layout.Column = h;
                end

                for r = 1:numel(chans)
                    c = chans(r);
                    app.nameLabels(c) = uilabel(g, 'Text', ...
                        sprintf('%s%d', DACMonitorGUI.CHANNEL_PREFIX, c), ...
                        'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                        'BackgroundColor', DACMonitorGUI.C_PLAIN, 'Interpreter', 'none');
                    app.nameLabels(c).Layout.Row = r + 1; app.nameLabels(c).Layout.Column = 1;

                    app.voltFields(c) = uieditfield(g, 'numeric', 'Editable', 'off', ...
                        'ValueDisplayFormat', DACMonitorGUI.VOLT_FORMAT, ...
                        'HorizontalAlignment', 'right');
                    app.voltFields(c).Layout.Row = r + 1; app.voltFields(c).Layout.Column = 2;

                    for k = 1:2
                        app.attrLabels(c, k) = uilabel(g, 'Text', '', ...
                            'HorizontalAlignment', 'center', 'FontWeight', 'bold', ...
                            'BackgroundColor', DACMonitorGUI.C_PLAIN);
                        app.attrLabels(c, k).Layout.Row = r + 1;
                        app.attrLabels(c, k).Layout.Column = 2 + k;
                        if hasAttr
                            % Same grid cell as the label; visible only when unlocked.
                            d = uidropdown(g, 'Items', items{k, 1}, 'ItemsData', items{k, 2}, ...
                                'Visible', 'off', 'FontWeight', 'bold', ...
                                'ValueChangedFcn', @(src, evt) app.onAttrChanged(c, k, src, evt));
                            d.Layout.Row = r + 1;
                            d.Layout.Column = 2 + k;
                            app.attrDrops(c, k) = d;
                        end
                    end
                end
            end

            % --- legend and status ----------------------------------------
            switch app.dacClass
                case 'QDAC'
                    leg = ['Range: amber = LOW ' char(177) '2 V, grey = HIGH ' char(177) '10 V.   Filter: amber = DC (FIX only, 10 Hz), ' ...
                           'blue = MED (10 kHz), grey = HIGH (230 kHz).   Hover a voltage for slew rate and current range.'];
                case 'baselDAC'
                    leg = 'Status: green = ON, grey = OFF.   BW: grey = HBW (100 kHz), amber = LBW (100 Hz).';
                otherwise
                    leg = '';
            end
            app.legendLabel = uilabel(main, 'Text', leg, 'FontSize', 10, 'FontColor', [0.35 0.35 0.35]);
            app.statusLabel = uilabel(main, 'Text', '', 'FontSize', 10, 'Interpreter', 'none');

            app.UIFigure.Visible = 'on';
        end
    end

    % =====================================================================
    %  STATIC HELPERS (pinout mapping is testable without a GUI)
    % =====================================================================
    methods (Static)
        function [names, msgs] = mapPinout(pinout, dac, dacName, n)
            % MAPPINOUT  Gate names per channel of 'dac' from a pinout struct.
            %   names: 1 x n cellstr ('' where no gate); gates sharing a
            %   channel are joined with '/'. msgs: notes for the user.
            names = repmat({''}, 1, n);
            msgs  = {};
            if ~isstruct(pinout)
                error('DACMonitorGUI:badPinout', 'The pinout must be a struct.');
            end
            gates = fieldnames(pinout);
            for k = 1:numel(gates)
                e = pinout.(gates{k});
                if ~isstruct(e) || ~isfield(e, 'device') || ~isfield(e, 'port')
                    continue
                end
                if ~DACMonitorGUI.sameDevice(e.device, dac, dacName)
                    continue
                end
                p = e.port;
                if ~isnumeric(p) || ~isscalar(p) || mod(p, 1) ~= 0 || p < 1 || p > n
                    msgs{end+1} = sprintf('"%s": port %s is not a channel 1-%d; ignored.', ...
                        gates{k}, mat2str(p), n); %#ok<AGROW>
                    continue
                end
                if isempty(names{p})
                    names{p} = gates{k};
                else
                    names{p} = [names{p} '/' gates{k}];
                    msgs{end+1} = sprintf('Channel %d is assigned to several gates: %s.', ...
                        p, names{p}); %#ok<AGROW>
                end
            end
        end

        function tf = sameDevice(d, dac, dacName)
            % Gate's device is this DAC: identical object, its variable name
            % given as text, or the same class at the same IP address / port
            % (DAC object re-created after the pinout was built).
            if ischar(d) || isstring(d)
                tf = strcmp(char(d), dacName);
                return
            end
            tf = false;
            if ~isobject(d) || ~strcmp(class(d), class(dac))
                return
            end
            try
                tf = isequal(size(d), [1 1]) && (d == dac);
            catch
                tf = false;
            end
            if ~tf
                a = DACMonitorGUI.endpoint(d);
                tf = ~isempty(a) && strcmp(a, DACMonitorGUI.endpoint(dac));
            end
        end

        function name = findBaseVariable(obj)
            % Name of the base-workspace variable holding handle 'obj' ('' if none).
            name = '';
            vars = evalin('base', 'whos');
            for k = 1:numel(vars)
                if ~strcmp(vars(k).class, class(obj)), continue; end
                v = evalin('base', vars(k).name);
                if ~isscalar(v), continue; end
                try
                    same = (v == obj);                 % handle identity (MATLAB)
                catch
                    a = DACMonitorGUI.endpoint(obj);   % fallback: same instrument
                    same = ~isempty(a) && strcmp(a, DACMonitorGUI.endpoint(v));
                end
                if same
                    name = vars(k).name;
                    return
                end
            end
        end

        function a = endpoint(dac)
            % IP address or COM port of a DAC object ('' if unknown).
            a = '';
            for p = {'IPAddress', 'comPort'}
                if isprop(dac, p{1})
                    v = dac.(p{1});
                    if isstring(v), v = char(v); end
                    if ischar(v) && ~isempty(strtrim(v))
                        a = strtrim(v);
                        return
                    end
                end
            end
        end

        function s = cellAt(dac, prop, c)
            % Upper-case text of cell property 'prop' at channel c ('' if absent).
            s = '';
            if isprop(dac, prop)
                v = dac.(prop);
                if iscell(v) && numel(v) >= c && ~isempty(v{c})
                    s = upper(strtrim(char(v{c})));
                end
            end
        end
    end
end

% -------------------------------------------------------------------------
function out = ifelse(cond, a, b)
    if cond, out = a; else, out = b; end
end