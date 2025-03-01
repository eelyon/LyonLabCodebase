function [ret,acqInfo,averagecount] = AlazarConfig(boardHandle,acqinfo,sysinfo,sampleRate,depth,averages,triggerWait,numSeg,cont)
%Config program for use with Bruker ENDOR system
%version 0.0.1  -   June 13, 2012
%Written by: Evan Scot Petersen
%Lyon Lab, Princeton University
ret=1;
AlazarDefs
SamplesPerSec=sampleRate;
samplesPerChannel=depth;
channelMask=CHANNEL_A+CHANNEL_B

if sampleRate~=100e6
    fprintf('sampleRate does not match\n');
    return
end

retCode = ...
    calllib('ATSApi', 'AlazarSetCaptureClock', ...
        boardHandle,		...	% HANDLE -- board handle
        INTERNAL_CLOCK,		...	% U32 -- clock source id
        SAMPLE_RATE_100MSPS,...	% U32 -- sample rate id
        CLOCK_EDGE_RISING,	...	% U32 -- clock edge id
        0					...	% U32 -- clock decimation 
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetCaptureClock failed -- %s\n', errorToText(retCode));
    return
end

retCode = ...
    calllib('ATSApi', 'AlazarInputControl', ...       
        boardHandle,		...	% HANDLE -- board handle
        CHANNEL_A,			...	% U8 -- input channel 
        DC_COUPLING,		...	% U32 -- input coupling id
        INPUT_RANGE_PM_1_V_25, ...	% U32 -- input range id
        IMPEDANCE_50_OHM	...	% U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControl 1 failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select CHB input parameters as required
retCode = ...
    calllib('ATSApi', 'AlazarInputControl', ...       
        boardHandle,		...	% HANDLE -- board handle
        CHANNEL_B,			...	% U8 -- channel identifier
        DC_COUPLING,		...	% U32 -- input coupling id
        INPUT_RANGE_PM_1_V_25,	...	% U32 -- input range id
        IMPEDANCE_50_OHM	...	% U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControl 2 failed -- %s\n', errorToText(retCode));
    return
end

sysinfo.TriggerCount=1;
retCode = ...
    calllib('ATSApi', 'AlazarSetTriggerOperation', ...       
        boardHandle,		...	% HANDLE -- board handle
        TRIG_ENGINE_OP_J,	...	% U32 -- trigger operation 
        TRIG_ENGINE_J,		...	% U32 -- trigger engine id
        TRIG_EXTERNAL,		...	% U32 -- trigger source id
        TRIGGER_SLOPE_POSITIVE,	... % U32 -- trigger slope id
        192,				...	% U32 -- 50% of positive range (must have +/- equal range)
        TRIG_ENGINE_K,		...	% U32 -- trigger engine id
        TRIG_DISABLE,		...	% U32 -- trigger source id for engine K
        TRIGGER_SLOPE_POSITIVE, ...	% U32 -- trigger slope id
        128					...	% U32 -- trigger level from 0 (-range) to 255 (+range)
        );
	if retCode ~= ApiSuccess
		fprintf('Error: AlazarSetTriggerOperation failed -- %s\n', errorToText(retCode));
		return
	end

	% TODO: Select external trigger parameters as required
	retCode = ...
		calllib('ATSApi', 'AlazarSetExternalTrigger', ...       
			boardHandle,		...	% HANDLE -- board handle
			DC_COUPLING,		...	% U32 -- external trigger coupling id
			ETR_5V				...	% U32 -- range: either ETR_5V for +/-5V or ETR_1V for +/-1V
			);
	if retCode ~= ApiSuccess
		fprintf('Error: AlazarSetExternalTrigger failed -- %s\n', errorToText(retCode));
		return
	end

	triggerTimeout_clocks = uint32(floor(triggerWait / 10.e-6 + 0.5));
	retCode = ...
		calllib('ATSApi', 'AlazarSetTriggerTimeOut', ...       
			boardHandle,            ...	% HANDLE -- board handle
			triggerTimeout_clocks	... % U32 -- timeout_sec / 10.e-6 (0 == wait forever)
			);
	if retCode ~= ApiSuccess
		fprintf('Error: AlazarSetTriggerTimeOut failed -- %s\n', errorToText(retCode));
		return
    end
    
if samplesPerChannel > sysinfo.maxSamplesPerRecord
    fprintf('Error: Too many samples per channel %u max %u\n', samplesPerChannel, sysinfo.maxSamplesPerRecord);
    return
end

% Calculate the size of each buffer in bytes
bytesPerSample = floor((double(sysinfo.bitsPerSample) + 7) / double(8));
acqinfo.samplesPerBuffer = samplesPerChannel * 2*averages;
acqinfo.bytesPerBuffer = bytesPerSample * acqinfo.samplesPerBuffer;

% % Find the number of buffers in the acquisition
% % if acquisitionLength_sec > 0 
%     samplesPerAcquisition = uint32(floor((depth*numSeg*averages*2 + 0.5)));
%     buffersPerAcquisition = uint32(floor(((samplesPerAcquisition + samplesPerChannel*averages - 1)) / (samplesPerChannel*averages)));
% % else
% %     buffersPerAcquisition = hex2dec('7FFFFFFF');  % acquire until aborted
% % end

% TODO: Select the number of DMA buffers to allocate.
% The number of DMA buffers must be greater than 2 to allow a board to DMA into
% one buffer while, at the same time, your application processes another buffer.
bufferCount = uint32(16); %change?

% Create an array of DMA buffers 
for j = 1 : bufferCount
    buffers(1, j) = { libpointer('uint16Ptr', 1:acqinfo.samplesPerBuffer) };
end


retCode = calllib('ATSApi', 'AlazarSetRecordSize', boardHandle, 0, samplesPerChannel);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarBeforeAsyncRead failed -- %s\n', errorToText(retCode));
    return
end
% TODO: Select AutoDMA flags as required
% ADMA_CONTINUOUS_MODE - acquire a single gapless record spanning multiple buffers
% ADMA_EXTERNAL_STARTCAPTURE - call AlazarStartCapture to begin the acquisition
admaFlags = ADMA_EXTERNAL_STARTCAPTURE + ADMA_NPT;

% Configure the board to make an AutoDMA acquisition
if cont==0
    retCode = calllib('ATSApi', 'AlazarBeforeAsyncRead', boardHandle, channelMask, 0, samplesPerChannel, averages, averages*numSeg, admaFlags);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarBeforeAsyncRead failed -- %s\n', errorToText(retCode));
        return
    end
else
    retCode = calllib('ATSApi', 'AlazarBeforeAsyncRead', boardHandle, channelMask, 0, samplesPerChannel, averages, hex2dec('7FFFFFFF'), admaFlags);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarBeforeAsyncRead failed -- %s\n', errorToText(retCode));
        return
    end
end

% Post the buffers to the board
for bufferIndex = 1 : bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = calllib('ATSApi', 'AlazarPostAsyncBuffer', boardHandle, pbuffer, acqinfo.bytesPerBuffer);
    if retCode ~= ApiSuccess
        fprintf('Error: AlazarPostAsyncBuffer failed -- %s\n', errorToText(retCode));
        return
    end        
end


pbuffer = buffers{1, 1};
acqinfo.SampleRate = sampleRate;
acqinfo.ExtClock = 0;
acqinfo.TriggerTimeout = triggerWait;
acqinfo.TriggerHoldoff = 0;
acqinfo.TriggerDelay = 0;
acqinfo.TimeStampConfig = 0;
% acqinfo.Mode = mode;
acqinfo.SegmentCount = numSeg; %this would be increased for multiple on-board records, not set up
acqinfo.Depth = depth;
acqinfo.SegmentSize = depth;
acqinfo.buffers = buffers; % added, this is an array of pointers to the buffers that the board writes to
acqinfo.pbuffer = pbuffer; % added, this gets used as a pointer to the current buffer being written to
acqinfo.bufferCount = bufferCount;
    
acqInfo=acqinfo;
averagecount=averages;
% Set the number of averages to do per multiple record segment
% CsMl_SetMulrecAverageCount(boardHandle, averages);
% ret = CsMl_Commit(boardHandle);
% CsMl_ErrorHandler(ret, 1, boardHandle);
% averagecount = CsMl_GetMulrecAverageCount(boardHandle); %checking averages set correctly
% [ret, acqInfo] = CsMl_QueryAcquisition(boardHandle)
