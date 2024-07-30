%% DC pinout for 2019_D_ROIC_QD_ava_DIY die bonded on 30th May, 2024
%% Sommer-Tanner pinout
STD = pinout(controlDAC,20); % Sommer-Tanner drive
STS = pinout(controlDAC,13); % Sommer-Tanner sense
STM = pinout(supplyDAC,18); % Sommer-Tanner middle gate

TM = pinout(controlDAC,21); % top metal
STG = pinout(supplyDAC,5); % Sommer-Tanner (left) door guard
M2S = pinout(controlDAC,9); % Sommer-Tanner shield on M2
BPG = pinout(controlDAC,24); % bond pad guard

filament = pinout(supplyDAC,10); % filament backing plate

%% CCD
d1_ccd = pinout(supplyDAC,17); % 1st door, uneven channels
d2_ccd = pinout(controlDAC,7); % 1st door, even channels
d3_ccd = pinout(supplyDAC,4); % 2nd door
d4_ccd = pinout(controlDAC,11); % 3rd door

ccd1 = pinout(controlDAC,22); % phi 1
ccd2 = pinout(supplyDAC,9); % phi 2; 6s on PCB, but ch6 is broken on sDAC
ccd3 = pinout(controlDAC,10); % phi 3

%% Differential measurement/twiddle-sense
shield = pinout(controlDAC,5); % shield underneath twiddle
door = pinout(supplyDAC,19); % door after phi1 and before offset gate
offset = pinout(controlDAC,1); % offset gate left of twiddle
sense = pinout(controlDAC,3); % sense gate left of twiddle
shieldl = pinout(controlDAC,6); % left shield from twiddle
twiddle = pinout(controlDAC,18); % twiddle gate
shieldr = pinout(supplyDAC,22); % right gate from twiddle

%% HEMT control lines
Vbb = pinout(supplyDAC,24); % amplifier base
Vcc = pinout(supplyDAC,13); % collector of cascode
Vf = pinout(supplyDAC,7); % emitter follower of cascode

function gate = pinout(Device,Port)
% Creating object that contains DAC and channel
    gate.Device = Device;
    gate.Port = Port;
end