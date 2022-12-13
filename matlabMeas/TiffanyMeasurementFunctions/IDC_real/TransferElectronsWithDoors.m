Fullwait = 3;
DCMap;

DCConfigs2('Emitting')

fprintf('T = %f\n',CX57781(str2num(query(Rtemp,'READ?'))))
pause(Fullwait)

Extra = 'Clean';
DoubleSweep

input('Flashed?:\n')

Extra = 'Charged';
DoubleSweep

fprintf('T = %f\n',CX57781(str2num(query(Rtemp,'READ?'))))
pause(Fullwait)

DCConfigs2('Transfering')

fprintf('T = %f\n',CX57781(str2num(query(Rtemp,'READ?'))))
pause(Fullwait)

Extra = 'Charged';
DoubleSweep

fprintf('T = %f\n',CX57781(str2num(query(Rtemp,'READ?'))))
pause(Fullwait)

Extra = 'Transferring';
EmitterDoorSweep

pause(Fullwait)

Extra = 'Transferred';
DoubleSweep

