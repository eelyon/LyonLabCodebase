obj1 = instrfind('Type', 'serial', 'Port', 'COM1', 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial('COM1');
else
    fclose(obj1);
    obj1 = obj1(1);
end
fopen(obj1)
SIM900 = obj1;



obj1 = instrfind('Type', 'gpib', 'BoardIndex', 3, 'PrimaryAddress', 8, 'Tag', '');
   if isempty(obj1)
        obj1 = gpib('CONTEC', 3, 8);
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
    fopen(obj1);
    VmeasE = obj1;
    
    obj1 = instrfind('Type', 'gpib', 'BoardIndex', 3, 'PrimaryAddress', 10, 'Tag', '');
   if isempty(obj1)
        obj1 = gpib('CONTEC', 3, 10);
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
    fopen(obj1);
    VmeasC = obj1;
   
    obj1 = instrfind('Type', 'gpib', 'BoardIndex', 3, 'PrimaryAddress', 23, 'Tag', '');
    if isempty(obj1)
        obj1 = gpib('CONTEC', 3, 23);
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
    fopen(obj1);
    Rtemp = obj1;
    fprintf(Rtemp,'*RST')
    fprintf(Rtemp,'CONF:FRES 100000000,100')
  %   fprintf(Rtemp,'CONF:FRES 100000,.1')
    fprintf(Rtemp,'TRIG:SOUR IMM')
    

obj1 = instrfind('Type', 'gpib', 'BoardIndex', 3, 'PrimaryAddress', 4, 'Tag', '');
if isempty(obj1)
    obj1 = gpib('NI', 3, 4);
else
    fclose(obj1);
    obj1 = obj1(1);
end
fopen(obj1);
Vpuls = obj1;
fprintf(Vpuls,'OUTP:STAT OFF')
fprintf(Vpuls,'TRIG:SOUR BUS')
fprintf(Vpuls,'FUNC:SHAP PULS')
fprintf(Vpuls,'OUTP:STAT ON')

% 
%  obj1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0699::0x03A5::C011465::0::INSTR', 'Tag', '');
% 
% if isempty(obj1)
%     obj1 = visa('NI', 'USB0::0x0699::0x03A5::C011465::0::INSTR');
% else
%     fclose(obj1);
%     obj1 = obj1(1);
% end
%     fopen(obj1);
%     eScope = obj1;
%     fclose(eScope);
%     eScope.InputBufferSize = (100000 * 2 + 100) * 2*8;
%     fopen(eScope);
% 
