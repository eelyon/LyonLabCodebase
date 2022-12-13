function [  ] = DCSet( Gate ,Value )

  calibrate = 1;

%% Gate Structure Determines which type of source is used:
% If Gate is an integer, the program assumes the source is one of
% Anthony's Boxes. The Device name is determined in DCMap for now, but
% maybe this functionality will change.
% (Gate = 7)
%
% If Gate is a 2 char string, the program assumes the source is an SR830
% Auxout. The first char should be a letter determining which SR830 and
% the number should relate to which auxout.
% (Gate = 'A4') -> Device = VmeasA, port = Aux4
% (Gate = 'B2') -> Device = VmeasB, port = Aux2
%
% If Gate is a 4 char string, the program assumes the voltage source is an
% SRS Sim9000. The first three chars don't really matter but the last
% char should be a number 1-8 to detrmine the slot.
% (Gate = 'Aux7') -> 7th slot of the Device called Sim900


  %% Determine which voltage source is being used
  if ischar(Gate)
    Device = [];

    if length(Gate) == 2
      %% Gate is from a lock in Aux: e.g Gate = 'A2' or 'B1' : Letter for VmeasA or VmeasB / Number for Aux Port
      Port = Gate(2);
      Device = ['Vmeas' Gate(1)];
      Command = ['fprintf(' Device ',' '''AUXV' Port ',' num2str(Value) ''')'];

    elseif length(Gate) == 4
      %% Gate is from SRS Modular power supply: e.g Gate = 'Aux1' or 'Aux7' : Device name is Sim900 right now
      Port = Gate(end);
      Device = 'Sim900';
      Command = ['fprintf(' Device ',''CONN ' Port ',"xyz"'')'];
      evalin('base',Command)
      Command = ['fprintf(' Device ',''VOLT ' num2str(Value) ''')'];

    else
      %% Improperly formatted string gate
      fprintf('Error: Invalid DCSet Input!')

    end
    %% Write the commands
    evalin('base',Command)
    evalin('base',['flushinput(' Device ')'])
    evalin('base',['flushoutput(' Device ')'])
  else
    %% Gate is from one of Anthony's Suuplys : e.g Gate = 1 or 5  : Device name is Defined in DCMap
    %Check DCMap for the Device
    DCMap;

    %Use calibrated port output if calibrate = True
    if calibrate
      load([Device '/' Device '_' num2str(Gate) '.mat']);
      vRange = -10:.5:10;
      valueSet = interp1(vRange,vRange.*m+b,Value);
    else
      valueSet = Value;
    end

    %Set Channel
    Command = ['fprintf(' Device ',''CH ' num2str(Gate) ''');'];
    evalin('base',Command)

%     %Clear Buffer if necessary
%     if strcmp(Device,'AP16A');
%       Command = ['query(' Device ','''');'];
%       evalin('base',Command)
%     end

    %Set Voltage
    Command = ['fprintf(' Device ',''VOLT ' num2str(valueSet) ''');'];
    evalin('base',Command)

%     %clear buffer if necessary
%     if strcmp(Device,'AP16A');
%       Command = ['query(' Device ','''');'];
%       evalin('base',Command)
%     end

  end
end

