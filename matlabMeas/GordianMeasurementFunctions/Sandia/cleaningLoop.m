for clean = 1:5
    cleanChannelsAndTM;
    fprintf([num2str(clean),'\n']);
end

%% Move electrons onto door gate
sigDACRampVoltage(d4.Device,d4.Port,Vopen,numSteps) % open door
sigDACRamp(d5.Device,d5.Port,Vopen,numStepsRC,waitTimeRC) % open offset
sigDACRampVoltage(d4.Device,d4.Port,Vclose,numSteps) % close door
sigDACRamp(d5.Device,d5.Port,-2,numStepsRC,waitTimeRC) % close offset
delay(1)

MFLISweep1D({'Guard1'},0.2,-1,0.1,'dev32021',guard1_l.Device,guard1_l.Port,0,'time_constant',0.1,'demod_rate',20e3,'poll_duration',0.2);
sigDACRamp(guard1_l.Device,guard1_l.Port,0,numStepsRC,waitTimeRC) % set left shield back
delay(1)