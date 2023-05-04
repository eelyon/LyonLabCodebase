% Create a serial port object.
global SIM900;

COM_port = 'COM20';
SIM900 = instrfind('Type', 'serial', 'Port', COM_port', 'Tag', '');

% Create the serial port object if it does not exist 
% otherwise use the object that was found.
if isempty(SIM900)
  SIM900 = serial(COM_port);
else
  fclose(SIM900);
  SIM900 = SIM900(1);
end;

% Connect to instrument object 
fopen(SIM900);
% Next two lines is to solve the bug in matlab: 
set(SIM900, 'RequestToSend', 'off') % line is still off 
set(SIM900, 'RequestToSend', 'on')  % line is now on

set(SIM900, 'Terminator', {'CR/LF','CR/LF'}); % Default terminators
IDN = query(SIM900, '*IDN?');
  
% Alternative way of quering from different modules
% "Receive Pass-Through Enable" mode redirects the reply messages from the specified modules 
% fprintf(SIM900, 'RPER 384'); % (256+128=384) for modules #7 and #8

% Assign SRS voltage units
global CF SW VG LED;
% (1) Module #, (2) conversion factor (Gauss per 1~V) 
%CF = struct('module',8,'cal',670.1535,'rate',0.01); 
CF = struct('module',1,'cal',670.1535,'rate',0.01); 
SW = struct('module',5,'cal',33.604,'rate',0.05); %rate in volts per second
%VG = struct('module',3,'rate',0.5);
VG = struct('module',8,'rate',0.5);
LED = struct('module',1,'rate',0.1);
% Turn on/off 
% fprintf(SIM900, ['SNDT ' num2str(CF.addr) ',"OPOF"']); % turn OFF
fprintf(SIM900, ['SNDT ' num2str(CF.module) ',"OPON"']); % turn ON
fprintf(SIM900, ['SNDT ' num2str(SW.module) ',"OPON"']); % turn ON
fprintf(SIM900, ['SNDT ' num2str(VG.module) ',"OPON"']); % turn ON
fprintf(SIM900, ['SNDT ',num2str(LED.module) ',"OPON"']); % turn ON
fprintf(SIM900,'"xyz"'); % Make sure it is not in CONN mode