%% Load electrons into twiddle sense region of emitter.
pulseTimes = [500e-6];
for pulseTime = pulseTimes

    display(strcat("Current Pulse Time = ",num2str(pulseTime), " Current Plot Number = ", num2str(getCurrentFileNum())));
% set new agilent pulse time
set33220PulseWidth(DoorRight,pulseTime);

% Open then close Door on emitter side.
rampVal(controlDAC,14,-2.6,-2.3,0.05,0.05);
delay(10);
rampVal(controlDAC,14,-2.3,-2.6,0.05,0.05);
% pulse doors to check transport
send33220Trigger(masterTrigger);
resistance = queryHP34401A(Thermometer);
temperature = Therm.tempFromRes(resistance);
display(strcat("Temperature from Cernox = ",num2str(temperature)));


% Clean Twiddle Sense
sweep1DMeasSR830({'Door'},-0.5,0.25,0.025,3,9,{SR830Twiddle},controlDAC,{11},1,1);

%sweep low side up to 0.45 Volts for cleaning
rampVal(DoorRight,1,-2,2.45,0.05,0.05);
display("Waiting 30 seconds with the door open")
delay(10);
rampVal(DoorRight,1,2.45,-2,0.05,0.05);
SR830Twiddle.SR830queryY() 
numCleans = 0;
while(SR830Twiddle.SR830queryY() > 4e-5)
    
    numCleans = numCleans + 1;
    display(strcat("Cleaning thin film of electrons, Clean#",num2str(numCleans)));
    %Clean by opening door
    rampVal(controlDAC,11,-0.5,0.25,0.05,0.05);
delay(10);
rampVal(controlDAC,11,0.25,-0.5,0.05,0.05);

% Check thin film again
rampVal(DoorRight,1,-2,2.45,0.05,0.05);
display("Waiting 30 seconds with the door open")
delay(10);
rampVal(DoorRight,1,2.45,-2,0.05,0.05);
SR830Twiddle.SR830queryY()
%     
%     % Clean Twiddle Sense
%     sweep1DMeasSR830({'Door'},-0.5,0.25,0.025,3,9,{SR830Twiddle},controlDAC,{11},1,1);
%     % Open Door to double check if electrons exist on thin film
%     rampVal(DoorRight,1,-2,0.25,0.05,0.05);
%     delay(10);
%     rampVal(DoorRight,1,0.25,-2,0.05,0.05);
    
end
end
