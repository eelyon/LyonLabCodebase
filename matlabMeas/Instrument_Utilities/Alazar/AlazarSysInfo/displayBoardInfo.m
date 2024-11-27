function [result] = displayBoardInfo(systemId, boardId)
% Display information about a board

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

% Get a handle to this board
boardHandle = calllib('ATSApi', 'AlazarGetBoardBySystemID', systemId, boardId);
setdatatype(boardHandle, 'voidPtr', 1, 1);
if (boardHandle.Value == 0)
    fprintf('Error: Open systemId %d boardId %u failed\n', systemId, boardId);
    return
end

% Get the board type in this board system
boardTypeId = calllib('ATSApi', 'AlazarGetBoardKind', boardHandle);

% Get on-board memory information
[retCode, boardHandle, samplesPerChannel, bitsPerSample] = calllib('ATSApi', 'AlazarGetChannelInfo', boardHandle, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetChannelInfo failed -- %s\n', errorToText(retCode));
    return
end

% Get FPGA signature
[retCode, boardHandle, asopcType] = calllib('ATSApi', 'AlazarQueryCapability', boardHandle, ASOPC_TYPE, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarQueryCapability failed -- %s\n', errorToText(retCode));
    return
end
fpgaMajor = mod(floor(double(asopcType) / double(2^16)), 256);
fpgaMinor = mod(floor(double(asopcType) / double(2^24)), 16);

% Get CPLD version
[retCode, boardHandle, cpldMajor, cpldMinor] = calllib('ATSApi', 'AlazarGetCPLDVersion', boardHandle, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetCPLDVersion failed -- %s\n', errorToText(retCode));
    return
end

% Get serial number
[retCode, boardHandle, serialNumber] = calllib('ATSApi', 'AlazarQueryCapability', boardHandle, GET_SERIAL_NUMBER, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarQueryCapability failed -- %s\n', errorToText(retCode));
    return
end

% Get calibration information
[retCode, boardHandle, latestCalDate] = calllib('ATSApi', 'AlazarQueryCapability', boardHandle, GET_LATEST_CAL_DATE, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarQueryCapability failed -- %s\n', errorToText(retCode));
    return
end

% Display information about this board
fprintf('System ID                 = %u\n', systemId);
fprintf('Board ID                  = %u\n', boardId);
fprintf('Serial number             = %06d\n', serialNumber);
fprintf('Bits per sample           = %d\n', bitsPerSample);
fprintf('Max samples per channel   = %u\n', samplesPerChannel);
fprintf('CPLD version              = %d.%d\n', cpldMajor, cpldMinor);
fprintf('FPGA version              = %d.%d\n', fpgaMajor, fpgaMinor);
fprintf('ASoPC signature           = 0x%08X\n', asopcType);
fprintf('Latest calibration date   = %d\n', latestCalDate);

% Does this digitizer have a PCI Express host bus interface
if boardTypeId >= ATS9462

    % Get PCI Express link speed
    [retCode, boardHandle, linkSpeed] = calllib('ATSApi', 'AlazarQueryCapability', boardHandle, GET_PCIE_LINK_SPEED, 0, 0);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarQueryCapability failed -- %s\n', errorToText(retCode));
        return
    end

    % Get PCI Express link width
    [retCode, boardHandle, linkWidth] = calllib('ATSApi', 'AlazarQueryCapability', boardHandle, GET_PCIE_LINK_WIDTH, 0, 0);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarQueryCapability failed -- %s\n', errorToText(retCode));
        return
    end

    transfersPerSec = 2.5e9 * double(linkSpeed);
    bytesPerSec = double(linkWidth) * transfersPerSec / 10;

    fprintf('PCIe link speed           = %g Gbps\n', 2.5 * double(linkSpeed));
    fprintf('PCIe link width           = %u lanes\n', linkWidth);
    fprintf('PCIe max transfer rate    = %g MB/s\n', bytesPerSec * 1e-6);

    % Read FPGA temperature
    [retCode, boardHandle, temperature_C] = calllib('ATSApi', 'AlazarGetParameter', boardHandle, CHANNEL_ALL, GET_FPGA_TEMPERATURE, 0);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarQueryCapability failed -- %s\n', errorToText(retCode));
        return
    end

    fprintf('FPGA temperature          = %d C\n', temperature_C);

end

fprintf('\n');

% Flash the LED on the board's PCIe mounting bracket
cycleCount = 2;
cyclePeriod_sec = .2;
if ~flashLed(boardHandle, cycleCount, cyclePeriod_sec)
    return
end

% Set the return code to indicate success
result = true;

end
