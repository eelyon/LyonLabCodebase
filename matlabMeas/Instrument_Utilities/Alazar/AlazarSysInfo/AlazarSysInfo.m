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
% This sample displays information about AlazarTech digitizers

% Add path to AlazarTech mfiles
addpath('..\Include')

% Call mfile with library definitions
AlazarDefs

% Load driver library
if ~alazarLoadLibrary()
    fprintf('Error: ATSApi.dll not loaded\n');
    return
end

% Display the driver library (ATSApi.dll) version
[retCode, sdkMajor, sdkMinor, sdkRevision] = calllib('ATSApi', 'AlazarGetSDKVersion', 0, 0, 0);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarGetSDKVersion failed -- %s\n', errorToText(retCode));
    return
else
    fprintf('SDK version               = %d.%d.%d\n', sdkMajor, sdkMinor, sdkRevision);
end

% Find the number of board systems detected by the driver library
systemCount = calllib('ATSApi', 'AlazarNumOfSystems');
if systemCount < 1
    fprintf('No systems found\n');
else
    fprintf('System count              = %u\n', systemCount);
end

% Display informataion about each board system detected
fprintf('\n');
for systemId = 1 : systemCount
    if ~displaySystemInfo(systemId)
        fprintf('Error: Display system %u info failed\n', systemId);
        return
    end
end
