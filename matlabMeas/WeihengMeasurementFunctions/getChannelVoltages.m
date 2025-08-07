function currentVoltages = getChannelVoltages(dac)
% GETCHANNELVOLTAGES Retrieves and displays all channel voltages for the electron on liquid helium experiment
%
% Parameters:
%   dac - The sigDAC object used to control voltages
%
% Returns:
%   currentVoltages - Structure with all voltage information
%
% Channel mapping:
%   Channel 5: NBSI middle low
%   Channel 10: NBSI middle high
%   Channel 7: NBSI side low
%   Channel 9: NBSI side high
%   Channel 8: Dots

    % Define channel mapping
    channels = [5, 10, 7, 9, 8]; % NBSI middle low, middle high, side low, side high, dots
    channelNames = {'NBSI Middle Low', 'NBSI Middle High', 'NBSI Side Low', 'NBSI Side High', 'Dots'};
    
    % Get current voltages
    voltages = zeros(1, length(channels));
    for i = 1:length(channels)
        voltages(i) = sigDACQueryVoltage(dac, channels(i));
    end
    
    % Calculate differences and gradients
    middleGradient = voltages(2) - voltages(1);
    sideGradient = voltages(4) - voltages(3);
    sideMiddleLowDiff = voltages(3) - voltages(1);
    sideMiddleHighDiff = voltages(4) - voltages(2);
    dotsHighDiff = voltages(5) - voltages(2);
    
    % Display current voltages
    fprintf('\n=== CURRENT CHANNEL VOLTAGES ===\n');
    for i = 1:length(channels)
        fprintf('  %s (Ch %d): %.3f V\n', channelNames{i}, channels(i), voltages(i));
    end
    
    % Display relationships
    fprintf('\n=== VOLTAGE RELATIONSHIPS ===\n');
    fprintf('  Middle strip gradient: %.3f V\n', middleGradient);
    fprintf('  Side strip gradient: %.3f V\n', sideGradient);
    fprintf('  Side-Middle difference (low end): %.3f V\n', sideMiddleLowDiff);
    fprintf('  Side-Middle difference (high end): %.3f V\n', sideMiddleHighDiff);
    fprintf('  Dots-Middle High difference: %.3f V\n', dotsHighDiff);
    
    % Check safety condition for dots
    if abs(dotsHighDiff) > 1
        fprintf('\nWARNING: Dots voltage differs from NBSI Middle High by %.3f V\n', dotsHighDiff);
        fprintf('This exceeds the 1V safety threshold and may risk shorting the dielectric!\n');
    end
    
    % Prepare return structure if requested
    if nargout > 0
        currentVoltages = struct();
        currentVoltages.channels = channels;
        currentVoltages.channelNames = channelNames;
        currentVoltages.voltages = voltages;
        currentVoltages.middleGradient = middleGradient;
        currentVoltages.sideGradient = sideGradient;
        currentVoltages.sideMiddleLowDiff = sideMiddleLowDiff;
        currentVoltages.sideMiddleHighDiff = sideMiddleHighDiff;
        currentVoltages.dotsHighDiff = dotsHighDiff;
    end
end