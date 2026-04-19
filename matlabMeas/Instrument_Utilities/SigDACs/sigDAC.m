classdef sigDAC < handle
    %SIGDAC Interface class for the Sigillito/Lyon 20-bit DAC Arduino firmware.
    %
    %   Supports:
    %     - Basic voltage set / query / ramp commands (original)
    %     - 3-phase CCD electron shuttling commands (new)
    %
    %   CCD command methods:
    %     ccdDefine(sigDAC, ccd, ch1, ch2, ch3)
    %     ccdAmplitude(sigDAC, ccd, phase, vmax, vmin)
    %     ccdDwellPerPhase(sigDAC, ccd, phase, time_us)
    %     ccdIntermediateStep(sigDAC, ccd, phase, mode)
    %     ccdShuttleForward(sigDAC, ccd, numSteps)
    %     ccdShuttleBackward(sigDAC, ccd, numSteps)
    %     ccdRoundtrip(sigDAC, ccd, dir, numPixels, repeats)
    %
    %   CCD naming: ccd is a single character 'A'–'F'.
    %   phase is 1, 2, 3, or 'ALL'.
    
    properties
        numChannels {mustBeNumeric}
        identifier
        comPort  
        channelVoltages 
        client
        name
        % ccdConfigs: 1x6 struct array, index 1=CCD A … 6=CCD F.
        % Fields: channels, vHigh, vLow, dwellUs,
        %         intermediateEnabled, currentPhase, configured
        ccdConfigs
    end
    
    methods
        % ================================================================
        %  MAIN METHODS
        % ================================================================
        function sigDAC = sigDAC(comPort, numChannels,name)
            
            sigDAC.comPort = comPort;
            sigDAC.client = serial_Connect(comPort);
            sigDAC.name = name;
            pause(1);
            sigDAC.numChannels = numChannels;
            sigDAC.identifier = query(sigDAC.client,"*IDN?");
            pause(1);
            restarted = input('Did you restart the DAC? (y/n) ',"s");
            if strcmp(restarted,'y')
                sigDACInit(sigDAC);
            end
            for i = 1:numChannels
                sigDAC.channelVoltages(i) = sigDACQueryVoltage(sigDAC,i);
            end

           % Initialise empty CCD config structs
            emptyCCD = struct('channels', [0 0 0], ...
                              'vHigh',    [0 0 0], ...
                              'vLow',     [0 0 0], ...
                              'dwellUs',  [0 0 0], ...
                              'intermediateEnabled', [false false false], ...
                              'currentPhase', 0, ...
                              'configured', false);
            sigDAC.ccdConfigs = repmat(emptyCCD, 1, 6);
        end
        
        function voltage = sigDACQueryVoltage(sigDAC,channel)
                fprintf(sigDAC.client,['CH ' num2str(channel)]);
                pause(0.1);
%                 v = query(sigDAC.client,'VOLT?');
                voltage = str2double(query(sigDAC.client,'VOLT?'));
        end

        function sigDACSetVoltage(sigDAC,channels,voltages)
                for i=1:length(channels)
                    fprintf(sigDAC.client,['CH ' num2str(channels(i))])
                    pause(0.1);
                    fprintf(sigDAC.client,['VOLT ' num2str(voltages(i))])
                    pause(0.1);
                    %sigDAC.channelVoltages(24) = voltages(i);
                    evalin('base',[sigDAC.name '.channelVoltages( ' num2str(channels(i)) ') = ' num2str(voltages(i)) ';']);
                end
                
        end

        function sigDACSetChannels(sigDAC,voltage)
            % Set all channels of DAC to the same voltage
            numSteps = 100;
            for i = 1:sigDAC.numChannels
                sigDACRampVoltage(sigDAC,i,voltage,numSteps);
            end
        end

        function  voltageArr = sigDACGetConfig(sigDAC)
            for channel = 1:sigDAC.numChannels
                sigDAC.channelVoltages(channel) = sigDACQueryVoltage(sigDAC,channel);
            end
            voltageArr = sigDAC.channelVoltages;
        end

        function sigDACRampVoltage(sigDAC,channels,voltages,numSteps)
            calibrate = 0;
            numChans = length(channels);
            numVolts = length(voltages);
    
            if calibrate
                Folder = 'TiffanyMeasurementFunctions\IDC\CalibrateDac\AP24\';
                calvoltList = zeros(1,numel(voltages));
                ctr = 1;
            
                for i=1:length(voltages)
                    channel = channels(i);
                    load([Folder 'CH' num2str(channel) '.mat']);
                    value = voltages(i);
                    vRange = -9.8:0.7:9.8;
                    new = interp1(vRange, vRange*m+b, value);
                    newVolt = (value-new)+value;
                    convert = num2str(newVolt,'%.3f');
                    convertback = str2double(convert);
                    calvoltList(ctr) = convertback;
                    ctr = ctr+1;
                end
        
                str = [numSteps numChans channels calvoltList];
                convertArray = sprintf('%d ', str);
                fprintf(sigDAC.client,['RAMP ' convertArray]);
                delayTime = 1.5*40e-6*numSteps*numChans; % set delay until DAC has run ramp
                delay(delayTime) % previously set to 1.5 times i.e. 60 us

                for i=1:numChans
                    evalin('base',[sigDAC.name '.channelVoltages( ' num2str(channels(i)) ') = ' num2str(voltages(i)) ';']);
                end
           else
                str = [numSteps numChans channels voltages];
                convertArray = sprintf('%d ', str);  % num2str pads the array with space, use sprintf instead!
                fprintf(sigDAC.client,['RAMP ' convertArray]);
                delayTime = 1.5*40e-6*numSteps*numChans; 
                delay(delayTime)

                for i=1:numChans
                    evalin('base',[sigDAC.name '.channelVoltages( ' num2str(channels(i)) ') = ' num2str(voltages(i)) ';']);
                end
           end
        end

        function sigDACRamp(sigDAC,channel,voltage,numSteps,dwellUs)
            % Wait time is in microseconds!
            if dwellUs < 40 % Min. time for ramp is 40e-6 set by Arduino
                error('Error: Wait time cannot be less than 40 microseconds!\n')
            elseif dwellUs > 16383 % Max. accurate delay
                error('Error: Wait time is inaccurate if larger than 16383 microseconds!\n')
            end
            cmd = sprintf('RAMPGF %d %d %d %d', channel, voltage, numSteps, dwellUs-40);
            query(sigDAC.client, cmd);   % blocks until Arduino prints "1\n"
            % fprintf(sigDAC.client,['RAMPGF ' num2str([channel,voltage,numSteps,dwellUs-40])]);
            % delay((1.5*40e-6 + dwellUs*1e-6 - 40e-6)*numSteps); % Give Arduino/Matlab time for communication
            evalin('base',[sigDAC.name '.channelVoltages( ' num2str(channel) ') = ' num2str(voltage) ';']);
        end

        function sigDACInit(sigDAC)
                fprintf(sigDAC.client,'INIT');
        end

        function sigDACDoor(sigDAC, vPort, TauE, TauC)
            DCMap;
            fprintf(sigDAC.client,['DOOR ' num2str([2,DoorEPort,DoorCPort, ...
                             4,vPort,2,0,0,TauE,TauC])]);
        end

        % ================================================================
        %  CCD CLOCKING METHODS
        % ================================================================
        function ccdConfigure(sigDAC, ccd, ch1, ch2, ch3, options)
            % CCDCONFIGURE  One-shot setup for a CCD: define channels, set
            %   amplitudes, dwell time, and intermediate step in a single call.
            %   Required:
            %     ccd       — char 'A'–'F'
            %     ch1,ch2,ch3 — DAC channel numbers for phases 1, 2, 3
            %
            %   Optional name-value pairs (all apply to ALL phases):
            %     vHigh            (default  3.0)  HIGH voltage (attracts electrons)
            %     vLow             (default -1.0)  LOW  voltage (barrier)
            %     dwellUs          (default  200)  settling delay in microseconds
            %     intermediateStep (default 'HALF') 'HALF', 'OFF', or a numeric voltage
 
            arguments
                sigDAC
                ccd          char
                ch1          (1,1) {mustBeInteger, mustBePositive}
                ch2          (1,1) {mustBeInteger, mustBePositive}
                ch3          (1,1) {mustBeInteger, mustBePositive}
                options.vHigh            (1,1) double  = 3.0
                options.vLow             (1,1) double  = -1.0
                options.dwellUs          (1,1) double  = 60
                options.intermediateStep            = 'HALF'
            end
 
            ccdDefine(sigDAC, ccd, ch1, ch2, ch3);
            ccdAmplitude(sigDAC, ccd, 'ALL', options.vHigh, options.vLow);
            ccdDwellPerPhase(sigDAC, ccd, 'ALL', options.dwellUs);
            ccdIntermediateStep(sigDAC, ccd, 'ALL', options.intermediateStep);
 
            fprintf('CCD %s configured: ch=[%d %d %d], vHigh=%.2f V, vLow=%.2f V, dwell=%d us, intermediate=%s\n', ...
                upper(ccd), ch1, ch2, ch3, options.vHigh, options.vLow, ...
                round(options.dwellUs), num2str(options.intermediateStep));
        end

        function ccdDefine(sigDAC, ccd, ch1, ch2, ch3)
            % CCDDEFINE  Assign 3 DAC channels to phases 1, 2, 3 of a CCD.
            %   ccd   — char 'A'–'F'
            %   ch1-3 — DAC channel numbers for phases 1, 2, 3
            %
            %   Must be called before any other CCD command for that CCD.
            %   Resets all amplitudes, dwell times, and intermediate steps
            %   to their defaults (0 V, 0 us, off).

            idx = ccdIndex(ccd);                     % validates letter
            cmd = sprintf('DEFINECCD%s %d %d %d', upper(ccd), ch1, ch2, ch3);
            fprintf(sigDAC.client, cmd);
            pause(0.1);
 
            % Mirror the Arduino reset behaviour in MATLAB
            sigDAC.ccdConfigs(idx).channels            = [ch1, ch2, ch3];
            sigDAC.ccdConfigs(idx).vHigh               = [0, 0, 0];
            sigDAC.ccdConfigs(idx).vLow                = [0, 0, 0];
            sigDAC.ccdConfigs(idx).dwellUs             = [0, 0, 0];
            sigDAC.ccdConfigs(idx).intermediateEnabled = [false, false, false];
            sigDAC.ccdConfigs(idx).currentPhase        = 0;
            sigDAC.ccdConfigs(idx).configured          = true;
        end
 
        function ccdAmplitude(sigDAC, ccd, phase, vmax, vmin)
            % CCDAMPLITUDE  Set the HIGH and LOW voltages for a CCD phase.
            %   ccd   — char 'A'–'F'
            %   phase — 1, 2, 3, or 'ALL'
            %   vmax  — voltage applied when phase is HIGH (attracts electrons)
            %   vmin  — voltage applied when phase is LOW  (barrier)
 
            idx      = ccdIndex(ccd);
            phaseStr = ccdPhaseStr(phase);
            cmd = sprintf('AMPLITUDE %s %s %.6f %.6f', upper(ccd), phaseStr, vmax, vmin);
            fprintf(sigDAC.client, cmd);
            pause(0.1);
 
            % Update local mirror
            if strcmpi(phaseStr, 'ALL')
                sigDAC.ccdConfigs(idx).vHigh = [vmax, vmax, vmax];
                sigDAC.ccdConfigs(idx).vLow  = [vmin, vmin, vmin];
            else
                p = str2double(phaseStr);
                sigDAC.ccdConfigs(idx).vHigh(p) = vmax;
                sigDAC.ccdConfigs(idx).vLow(p)  = vmin;
            end
        end
 
 
        function ccdDwellPerPhase(sigDAC, ccd, phase, time_us)
            % CCDDWELLPERPHASE  Set the settling delay after each DAC write on a phase.
            %   ccd     — char 'A'–'F'
            %   phase   — 1, 2, 3, or 'ALL'
            %   time_us — delay in microseconds (integer)
            %
            %   Examples:
            %     dac.ccdDwellPerPhase('B', 2,     500)
            %     dac.ccdDwellPerPhase('B', 'ALL', 200)
 
            idx      = ccdIndex(ccd);
            phaseStr = ccdPhaseStr(phase);
            cmd = sprintf('DWELLPERPHASE %s %s %d', upper(ccd), phaseStr, round(time_us));
            fprintf(sigDAC.client, cmd);
            pause(0.1);
 
            % Update local mirror
            if strcmpi(phaseStr, 'ALL')
                sigDAC.ccdConfigs(idx).dwellUs = [time_us, time_us, time_us];
            else
                p = str2double(phaseStr);
                sigDAC.ccdConfigs(idx).dwellUs(p) = time_us;
            end
        end
 
        function ccdIntermediateStep(sigDAC, ccd, phase, mode)
            % CCDINTERMEDIATESTEP  Configure (or disable) the intermediate voltage step.
            %   ccd   — char 'A'–'F'
            %   phase — 1, 2, 3, or 'ALL'
            %   mode  — 'HALF'  : intermediate voltage = midpoint of current and target
            %            numeric : fixed intermediate voltage (e.g. 2.5)
            %            'OFF'  : disable the intermediate step
            %
            %   When enabled each transition writes the intermediate voltage,
            %   waits the dwell time, then writes the final voltage, and waits again.
 
            idx      = ccdIndex(ccd);
            phaseStr = ccdPhaseStr(phase);
 
            if isnumeric(mode)
                modeStr = sprintf('%.6f', mode);
            else
                modeStr = upper(mode);
                if ~ismember(modeStr, {'HALF','OFF'})
                    error('mode must be ''HALF'', ''OFF'', or a numeric voltage.');
                end
            end
 
            cmd = sprintf('INTERMEDIATESTEP %s %s %s', upper(ccd), phaseStr, modeStr);
            fprintf(sigDAC.client, cmd);
            pause(0.1);
 
            % Update local mirror
            if strcmpi(phaseStr, 'ALL')
                phases = 1:3;
            else
                phases = str2double(phaseStr);
            end
            for p = phases
                if strcmpi(modeStr, 'OFF')
                    sigDAC.ccdConfigs(idx).intermediateEnabled(p) = false;
                else
                    sigDAC.ccdConfigs(idx).intermediateEnabled(p) = true;
                end
            end
        end
 
 
        function currentPhase = ccdShuttleForward(sigDAC, ccd, numSteps)
            % CCDSHUTTLEFORWARD  Advance electrons forward by numSteps pixels.
            %   ccd      — char 'A'–'F'
            %   numSteps — number of pixel steps to advance
            %
            %   MATLAB pauses for the estimated execution time on the Arduino
            %   before returning, so subsequent commands do not interrupt the
            %   clocking sequence.
            %   RETURNS current phase number
 
            idx = ccdIndex(ccd);
            cmd = sprintf('SHUTTLEFORWARD %s %d', upper(ccd), numSteps);
            resp = query(sigDAC.client, cmd);
            if startsWith(strtrim(resp), 'ERROR')
                error('sigDAC:ccdShuttleForward: Arduino error: %s', strtrim(resp));
            end
 
            % Advance local phase tracker
            sigDAC.ccdConfigs(idx).currentPhase = ...
                mod(sigDAC.ccdConfigs(idx).currentPhase + numSteps, 3);
            currentPhase = sigDAC.ccdConfigs(idx).currentPhase;
        end
 
        function currentPhase = ccdShuttleBackward(sigDAC, ccd, numSteps)
            % CCDSHUTTLEBACKWARD  Retreat electrons backward by numSteps pixels.
            %   ccd      — char 'A'–'F'
            %   numSteps — number of pixel steps to retreat
 
            idx = ccdIndex(ccd);
            cmd = sprintf('SHUTTLEBACKWARD %s %d', upper(ccd), numSteps);
            resp = query(sigDAC.client, cmd);   % blocks until Arduino prints "1\n"
            if startsWith(strtrim(resp), 'ERROR')
                error('sigDAC:ccdShuttleBackward: Arduino error: %s', strtrim(resp));
            end
 
            % Retreat local phase tracker
            sigDAC.ccdConfigs(idx).currentPhase = ...
                mod(sigDAC.ccdConfigs(idx).currentPhase - numSteps, 3);
            currentPhase = sigDAC.ccdConfigs(idx).currentPhase;
        end
 
        function ccdRoundtrip(sigDAC, ccd, dir, numPixels, repeats)
            % CCDROUNDTRIP  Shuttle forward and backward (or vice versa) in a loop.
            %   ccd       — char 'A'–'F'
            %   dir       — 'FB' (forward first) or 'BF' (backward first)
            %   numPixels — pixels to shuttle in each direction per cycle
            %   repeats   — number of complete round-trip cycles
            %
            %   Total pixel steps = 2 × numPixels × repeats.
            %   Phase memory is preserved across all cycles.
 
            dirStr = upper(dir);
            if ~ismember(dirStr, {'FB','BF'})
                error('dir must be ''FB'' (forward-first) or ''BF'' (backward-first).');
            end
 
            cmd = sprintf('ROUNDTRIP %s %s %d %d', upper(ccd), dirStr, numPixels, repeats);
            resp = query(sigDAC.client, cmd);   % blocks until Arduino prints "1\n"
            if startsWith(strtrim(resp), 'ERROR')
                error('sigDAC:ccdRoundtrip: Arduino error: %s', strtrim(resp));
            end
 
            % Phase is unchanged after a full roundtrip (net displacement = 0)
            % No update to currentPhase needed.
        end
    end

end

% ================================================================
%  MODULE-LEVEL HELPERS (not class methods)
% ================================================================
function idx = ccdIndex(ccd)
    % Convert CCD letter 'A'–'F' to 1-based array index.
    if ~ischar(ccd) || numel(ccd) ~= 1
        error('CCD must be a single character ''A''–''F''.');
    end
    idx = upper(ccd) - 'A' + 1;
    if idx < 1 || idx > 6
        error('CCD must be ''A'', ''B'', ''C'', ''D'', ''E'', or ''F''.');
    end
end
 
function phaseStr = ccdPhaseStr(phase)
    % Convert phase argument (1/2/3/'ALL') to the string the Arduino expects.
    if ischar(phase)
        if strcmpi(phase, 'ALL')
            phaseStr = 'ALL';
        else
            error('phase must be 1, 2, 3, or ''ALL''.');
        end
    elseif isnumeric(phase) && isscalar(phase) && ismember(phase, [1 2 3])
        phaseStr = num2str(phase);
    else
        error('phase must be 1, 2, 3, or ''ALL''.');
    end
end