function [] = resVsTime(ENA,timeBetweenPoints,pHandle)

    i=1;
    startTime = now();
    cleanupObj = onCleanup(@()cleanMeUp(pHandle));
    time = [];
    frequency = [];
    while 1
        time(i) = (now()-startTime)*86400/60;

        
        
        % Function that sets VNA measurement and plots data
        E5071SetPower(ENA,5); % in dBm
        E5071SetStartFreq(ENA,2120); % in MHz
        E5071SetStopFreq(ENA,2140); % in MHz
        
        fprintf(ENA,':INIT1'); % Set trigger value - for continuous set: ':INIT:CONT ON'
        fprintf(ENA,':TRIG:SOUR BUS'); % Set trigger source to "Bus Trigger"
        fprintf(ENA,':TRIG:SING'); % Trigger ENA to start sweep cycle
        query(ENA,'*OPC?'); % Execute *OPC? command and wait until command return 1
        
        % Get mag (log) and phase (deg) data
        tag = 'freqSweep';
        [fdata,mag,phase] = E5071GetData(ENA,tag);
        fres = fdata(find(mag==min(mag))); % min point

        frequency(i) = fres;
        pHandle.YData = frequency;
        pHandle.XData = time;
        title(['f_{res}=' num2str(frequency(i)) 'GHz']);
        i = i+1;
        refreshdata;
        drawnow;
        pause(timeBetweenPoints)
    end
        function cleanMeUp(handle)
            disp('Operation Terminated, saving data');
            saveData(handle,'fresVsTime');
        end
end