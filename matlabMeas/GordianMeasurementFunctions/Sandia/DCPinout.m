%% DC pinout for 2019_D_ROIC_QD_ava_DIY die bonded on 30th May, 2024
%% Sommer-Tanner pinout
STD = pinout(controlDAC,20); % Sommer-Tanner drive
STS = pinout(controlDAC,13); % Sommer-Tanner sense
STM = pinout(supplyDAC,18); % Sommer-Tanner middle gate

TM = pinout(controlDAC,21); % top metal
STG = pinout(supplyDAC,5); % Sommer-Tanner (left) door guard
M2S = pinout(controlDAC,9); % Sommer-Tanner shield on M2
BPG = pinout(controlDAC,24); % bond pad guard

fil = pinout(controlDAC,14); % filament backing plate

%% CCD
d1_ccd = pinout(supplyDAC,17); % 1st door, uneven channels
d2_ccd = pinout(controlDAC,7); % 1st door, even channels
d3_ccd = pinout(supplyDAC,4); % 2nd door
d4_ccd = pinout(controlDAC,11); % 3rd door

ccd1 = pinout(controlDAC,22); % phi 1
ccd2 = pinout(supplyDAC,8); % phi 2; 6s on PCB, but ch6 is broken on sDAC
ccd3 = pinout(controlDAC,10); % phi 3

%% Differential measurement/twiddle-sense
d_diff = pinout(supplyDAC,19); % door between CCD and diff. meas.
dm1_gl = pinout(controlDAC,6); % left gate from twiddle
dm1_t = pinout(controlDAC,18); % twiddle gate
dm1_gr = pinout(supplyDAC,22); % right gate from twiddle
dm1_sl = pinout(controlDAC,3); % sense gate left of twiddle
dm1_ol = pinout(controlDAC,1); % offset gate left of twiddle
shield = pinout(controlDAC,5); % shield underneath twiddle

%% HEMT control lines
Vbb = pinout(supplyDAC,24); % amplifier base
Vcc_amp = pinout(supplyDAC,13); % Vcc of amplifier collector
Vcc_f = pinout(supplyDAC,7); % Vcc of emitter follower

function gate = pinout(Device,Port)
% Creating object that contains DAC and channel
    gate.Device = Device;
    gate.Port = Port;
end