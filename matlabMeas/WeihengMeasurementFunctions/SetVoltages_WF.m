Filament_backing = [15];
Top_metal = [6];
Gates_no_st = [1,2,3,4,5,7,8,9,10,11]; % gates other than sommer tanner l,m,r and top metal and backing
Gates_st = [12,16,14];

% for emission
backing_voltage = -1.5;
gates_voltage = -3;
st_voltage = 0;
tm_voltage = -0.7;
sigDACRampVoltage(DAC,Filament_backing,backing_voltage,200);
sigDACRampVoltage(DAC,Top_metal,tm_voltage,200);
for i = 1:length(Gates_no_st)
      sigDACRampVoltage(DAC,Gates_no_st(i),gates_voltage,200);
end
for i = 1:length(Gates_st)
      sigDACRampVoltage(DAC,Gates_st(i),st_voltage,200);
end

% for cleaning
backing_voltage = 3;
negative_bias = -2;
positive_bias = 2;
sigDACRampVoltage(DAC,Top_metal,positive_bias,200);
pause(0.5);
for i = 1:length(Gates_no_st)
      sigDACRampVoltage(DAC,Gates_no_st(i),negative_bias,200);
end
pause(5);
for i = 1:length(Gates_st)
      sigDACRampVoltage(DAC,Gates_st(i),negative_bias,200);
end
pause(5);
sigDACRampVoltage(DAC,Filament_backing,backing_voltage,200);
pause(5);
sigDACRampVoltage(DAC,Top_metal,negative_bias,200);

% for ccding electrons from twiddle sense to sommer tanner
sigDACRampVoltage(DAC,[6,12,13,14],[-0.7,0.5,0.3,0.1],200);
sigDACRampVoltage(DAC,[1,2,3,4],[1,1,0,-1],200);
pause(1);
sigDACRampVoltage(DAC,[1,2,3,4],[1,0,-1,-1],200);
pause(1);
sigDACRampVoltage(DAC,[1,2,3,4],[0,-1,-1,-1],200);
pause(1);
sigDACRampVoltage(DAC,[1,2,3,4],[-1,-1,-1,-1],200);
pause(1);
sigDACRampVoltage(DAC,[1,2,3,4],[-1,0,0,-1],200);
pause(1);

% for ccding electrons from twiddle sense to channel
sigDACRampVoltage(DAC,[5,6,7],[1,-1.5,0.3],200);
sigDACRampVoltage(DAC,[2,3,4],[0,0,0],200);
pause(0.5);
sigDACRampVoltage(DAC,[2,3,4],[-1,0,0],200);
pause(0.5);
sigDACRampVoltage(DAC,[2,3,4],[-1,-1,0],200);
pause(0.5);
sigDACRampVoltage(DAC,[2,3,4],[-1,-1,-1],200);
pause(0.5);
sigDACRampVoltage(DAC,[2,3,4],[0,0,-1],200);

% for ccding electrons from channel to sommer tanner
loop_var = 0;
while (loop_var <= 20)
    sigDACRampVoltage(DAC,[1,4],[-1,0],200);
    pause(1);
    sigDACRampVoltage(DAC,[1,4],[-1,-1],200);
    pause(0.2);
    sigDACRampVoltage(DAC,[5,6,7],[-1,-1.5,-1.3],200);
    pause(1);
    sigDACRampVoltage(DAC,[1,2,3],[0,0,0],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[1,2,3],[0,0,-1],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[1,2,3],[0,-1,-1],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[1,2,3],[-1,-1,-1],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[1,2,3],[-1,0,0],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[5,6,7],[1,-1.5,0.3],200);
    pause(1);
    loop_var = loop_var +1;
end


% for ccding electrons from channel to sommer tanner - more extreme version
loop_var = 0;
sigDACRampVoltage(DAC,[5,6,7],[1,-1.5,0.3],200);
while (loop_var <= 40)
    sigDACRampVoltage(DAC,[1,4],[0,0],200);
    pause(0.2);
    sigDACRampVoltage(DAC,[1,4],[0,2],200);
    pause(0.2);
    sigDACRampVoltage(DAC,[1,2,3,4],[0,0,2,0],200);
    pause(0.2);
    sigDACRampVoltage(DAC,[1,2,3,4],[0,2,0,2],200);
    pause(0.2);
    sigDACRampVoltage(DAC,[1,2,3,4],[2,0,2,0],200);
    pause(0.2);
    sigDACRampVoltage(DAC,[1,2,3,4],[0,2,0,0],200);
    pause(0.2);
    sigDACRampVoltage(DAC,[1,2,3,4],[2,0,0,0],200);
    pause(0.2);
    loop_var = loop_var +1;
end

% for getting rid of last bit of electrons left in nbsi channel
% for ccding electrons from twiddle sense to sommer tanner
loop_var = 0;
while (loop_var <= 20)
    sigDACRampVoltage(DAC,[6,12,13,14],[-0.7,0.5,0.3,0.1],200);
    sigDACRampVoltage(DAC,[4,5,7],[0,-0.2,-1],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[1,2,3,4],[0,0,0,-1],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[4,5,7],[-1,-1,-1],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[1,2,3],[0,0,-1],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[1,2,3],[0,-1,-1],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[1,2,3],[-1,-1,-1],200);
    pause(0.5);
    sigDACRampVoltage(DAC,[1,2,3],[-1,0,0],200);
    pause(0.5);
    loop_var = loop_var +1;
end