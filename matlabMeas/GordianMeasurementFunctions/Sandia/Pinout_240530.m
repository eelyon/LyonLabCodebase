%% Pinout for 2019_D_ROIC_QD_ava_DIY die bonded on 30th May, 2024
% Do not change variable names!! Other scripts depend on this!!
s = "supplyDAC";
c = "controlDAC";

%% Sommer-Tanner pinout
STD = [c,20]; % Sommer-Tanner drive
STS = [c,13]; % Sommer-Tanner sense
STM = [s,18]; % Sommer-Tanner middle gate

TM = [c,21]; % top metal
STGuard = [s,5]; % Sommer-Tanner (left) door guard
M2Shield = [c,9]; % Sommer-Tanner shield on M2
BPGuard = [s,24]; % bond pad guard

FilBack = [s,1]; % filament backing plate

%% CCD
d1_ccd = [s,17]; % 1st door, uneven channels
d2_ccd = [c,7]; % 1st door, even channels
d3_ccd = [s,4]; % 2nd door
d4_ccd = [c,11]; % 3rd door

ccd1 = [s,22]; % phi 1
ccd2 = [s,6]; % phi 2
ccd3 = [c,10]; % phi 3

%% Differential measurement/twiddle-sense
d_diff = [s,19]; % door between CCD and diff. meas.
dm1_gl = [c,6]; % left gate from twiddle
dm1_t = [c,18]; % twiddle gate
dm1_gr = [s,22]; % right gate from twiddle
dm1_sl = [c,3]; % sense gate left of twiddle
dm1_ol = [c,1]; % offset gate left of twiddle
shield = [c,5]; % shield underneath twiddle