function setChannelBias(dac, nbsiMiddleLow, nbsiMiddleHigh, dotsVoltDiff, sideMiddleDiff, numSteps)
% SETCHANNELBIAS Sets the channel biases for electrons on liquid helium experiment
%
% Parameters:
%   dac - The sigDAC object used to control voltages
%   nbsiMiddleLow - Voltage for NBSI middle lower end (channel 5)
%   nbsiMiddleHigh - Voltage for NBSI middle higher end (channel 10)
%   dotsVoltDiff - Voltage difference between NBSI middle high and dots (channel 8)
%   sideMiddleDiff - Voltage difference between side strips and middle strips
%                    (positive means side strips are higher than middle strips)
%   numSteps - Number of steps for voltage ramping (optional, default 100)
%
% Channel mapping:
%   Channel 5: NBSI middle low
%   Channel 10: NBSI middle high
%   Channel 7: NBSI side low
%   Channel 9: NBSI side high
%   Channel 8: Dots

    % Default number of steps if not provided
    if nargin < 6
        numSteps = 100;
    end

    % Calculate target voltages
    dotsVoltage = nbsiMiddleHigh + dotsVoltDiff;
    nbsiSideLow = nbsiMiddleLow + sideMiddleDiff;
    nbsiSideHigh = nbsiMiddleHigh + sideMiddleDiff;
    
    % Define channel mapping
    channels = [5, 10, 7, 9, 8]; % NBSI middle low, middle high, side low, side high, dots
    channelNames = {'NBSI Middle Low', 'NBSI Middle High', 'NBSI Side Low', 'NBSI Side High', 'Dots'};
    targetVoltages = [nbsiMiddleLow, nbsiMiddleHigh, nbsiSideLow, nbsiSideHigh, dotsVoltage];
    
    % Get current voltages
    currentVoltages = zeros(1, length(channels));
    for i = 1:length(channels)
        currentVoltages(i) = sigDACQueryVoltage(dac, channels(i));
    end
    
    % Display current voltages
    fprintf('\n=== CURRENT VOLTAGES ===\n');
    for i = 1:length(channels)
        fprintf('  %s (Ch %d): %.3f V\n', channelNames{i}, channels(i), currentVoltages(i));
    end
    fprintf('  Current Middle gradient: %.3f V\n', currentVoltages(2) - currentVoltages(1));
    fprintf('  Current Side gradient: %.3f V\n', currentVoltages(4) - currentVoltages(3));
    
    % Display the target voltage configuration
    fprintf('\n=== TARGET VOLTAGES ===\n');
    fprintf('  NBSI Middle Low (Ch 5): %.3f V\n', nbsiMiddleLow);
    fprintf('  NBSI Middle High (Ch 10): %.3f V\n', nbsiMiddleHigh);
    fprintf('  NBSI Side Low (Ch 7): %.3f V  (Middle Low + %.3f V)\n', nbsiSideLow, sideMiddleDiff);
    fprintf('  NBSI Side High (Ch 9): %.3f V  (Middle High + %.3f V)\n', nbsiSideHigh, sideMiddleDiff);
    fprintf('  Dots (Ch 8): %.3f V  (Middle High + %.3f V)\n', dotsVoltage, dotsVoltDiff);
    fprintf('  Target Middle gradient: %.3f V\n', nbsiMiddleHigh - nbsiMiddleLow);
    fprintf('  Target Side gradient: %.3f V\n', nbsiSideHigh - nbsiSideLow);
    fprintf('  Number of ramping steps: %d\n', numSteps);
    
    % Check if dotsVoltDiff is within safe range (within 1V)
    if abs(dotsVoltDiff) > 1
        fprintf('\nWARNING: Dots voltage difference exceeds 1V from NBSI middle high.\n');
        fprintf('This may short the dielectric!\n');
    end
    
    % Ask for confirmation before proceeding
    response = input('\nConfirm these voltage settings? (y/n): ', 's');
    if ~strcmpi(response, 'y')
        fprintf('Operation cancelled.\n');
        return;
    end
    
    % Calculate voltage steps for each channel
    voltageSteps = (targetVoltages - currentVoltages) / numSteps;
    
    % Perform ramping
    fprintf('\nRamping all channels synchronously with %d steps...\n', numSteps);
    for step = 1:numSteps
        % Calculate intermediate voltages for this step
        intermediateVoltages = currentVoltages + voltageSteps * step;
        
        % Set all channels to the intermediate voltages
        for i = 1:length(channels)
            fprintf(dac.client, ['CH ' num2str(channels(i))]);
            pause(0.1);
            fprintf(dac.client, ['VOLT ' num2str(intermediateVoltages(i))]);
            pause(0.1);
        end
    end
    
    % Calculate appropriate delay based on the formula in sigDACRampVoltage
    delayTime = 0.00004 * numSteps * length(channels);
    pause(1.5 * delayTime); % Use the same 1.5x factor as in the original code
    
    % Update the channel voltages in the DAC object
    for i = 1:length(channels)
        evalin('base', [dac.name '.channelVoltages(' num2str(channels(i)) ') = ' num2str(targetVoltages(i)) ';']);
    end
    
    % Verify the voltages were set correctly
    fprintf('\nVerifying set voltages:\n');
    for i = 1:length(channels)
        actual = sigDACQueryVoltage(dac, channels(i));
        fprintf('  %s (Ch %d): Expected %.3f V, Actual %.3f V\n', channelNames{i}, channels(i), targetVoltages(i), actual);
        
        % Check if voltage was set correctly within a tolerance
        if abs(actual - targetVoltages(i)) > 0.01
            fprintf('    WARNING: Channel %d voltage differs from expected value!\n', channels(i));
        end
    end
    
    fprintf('\nVoltage setting complete.\n');
end