function [result] = flashLed(handle, cycleCount, cyclePeriod_sec)
% Flash LED on board's PCI/PCIe mounting bracket

%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2015 AlazarTech, Inc.
%
% AlazarTech, Inc. licenses this software under specific terms and
% conditions. Use of any of the software or derivatives thereof in any
% product without an AlazarTech digitizer board is strictly prohibited.
%
% AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
% EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
% MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no
% guarantee or representations regarding the use of, or the results of the
% use of, the software and documentation in terms of correctness, accuracy,
% reliability, currentness, or otherwise; and you rely on the software,
% documentation and results solely at your own risk.
%
% IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF
% BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL
% DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH%S TOTAL LIABILITY EXCEED
% THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
%
%---------------------------------------------------------------------------

%call mfile with library definitions
AlazarDefs

% set default return code to indicate failure
result = false;

% Turn LED on for half a cycle, then off for half a cycle
halfCycleTime_sec = cyclePeriod_sec / 2;

for cycle = 0 : cycleCount - 1
    for stepInCycle = 0 : 1

        % Set LED state
        if stepInCycle == 0
            state = LED_ON;
        else
            state = LED_OFF;
        end

        % Control LED
        retCode = calllib('ATSApi', 'AlazarSetLED', handle, state);
        if retCode ~= ApiSuccess
            fprintf('Error: AlazarSetLED failed -- %s\n', errorToText(retCode));
            return
        end

        % Pause while LED is on or off
        if halfCycleTime_sec > 0
            pause(halfCycleTime_sec);
        end
    end
end

% Set the return code to indicate success
result = true;

end
