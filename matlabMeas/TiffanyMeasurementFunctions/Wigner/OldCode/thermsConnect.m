
    obj1 = instrfind('Type', 'serial', 'Port', 'COM1', 'Tag', '');
    if isempty(obj1)
        obj1 = serial('COM1');
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
    fopen(obj1);
    SIM900 = obj1;



obj1 = instrfind('Type', 'gpib', 'BoardIndex', 1, 'PrimaryAddress', 8, 'Tag', '');
   if isempty(obj1)
        obj1 = gpib('CONTEC', 1, 8);
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
    fopen(obj1);
    VmeasE = obj1;

    obj1 = instrfind('Type', 'gpib', 'BoardIndex', 1, 'PrimaryAddress', 23, 'Tag', '');
    if isempty(obj1)
        obj1 = gpib('CONTEC', 1, 23);
    else
        fclose(obj1);
        obj1 = obj1(1);
    end
    fopen(obj1);
    Rtemp = obj1;
    fprintf(Rtemp,'*RST');
    fprintf(Rtemp,'CONF:FRES 1000000,1');
    fprintf(Rtemp,'TRIG:SOUR IMM');


obj1 = instrfind('Type', 'gpib', 'BoardIndex', 1, 'PrimaryAddress', 30, 'Tag', '');
if isempty(obj1)
    obj1 = gpib('NI', 1, 30);
else
    fclose(obj1);
    obj1 = obj1(1);
end
fopen(obj1);
    Rtemp2 = obj1;
    fprintf(Rtemp2,'*RST');
    fprintf(Rtemp2,'CONF:VOLT');
    fprintf(Rtemp2,'TRIG:SOUR IMM');
