function [] = monitorIDCs(SR830,timeBetweenPoints,pHandle)

i=1;
startTime = now();
cleanupObj = onCleanup(@()cleanMeUp(pHandle));
time = [];
current = [];
while 1
    time(i) = (now()-startTime)*86400/60;
    current(i) = SR830.SR830queryY();
    pHandle.YData = current;
    pHandle.XData = time;
    title(['Current =' num2str(current(i)) 'nA']);
    i = i+1;
    refreshdata;
    drawnow;
    pause(timeBetweenPoints)
end
    function cleanMeUp(handle)
        disp('Operation Terminated, saving data');
        saveData(handle,'He3IDC');
    end
end
