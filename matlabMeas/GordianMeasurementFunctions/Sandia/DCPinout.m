%% DC pinout for 2019_D_ROIC_QD die bonded Dec. 2024
%% Sommer-Tanner pinout
STD = pinout(supplyDAC,23); % Sommer-Tanner drive
STS = pinout(controlDAC,6); % Sommer-Tanner sense
STM = pinout(supplyDAC,13); % Sommer-Tanner middle gate

TM = pinout(supplyDAC,11); % top metal
M2S = pinout(supplyDAC,24); % Sommer-Tanner shield on M2
BPG = pinout(supplyDAC,12); % bond pad guard

filament = pinout(sim900,4); % filament backing plate

%% 1st twiddle-sense
d1_odd = pinout(supplyDAC,22); % 1st door, uneven channels
d1_even = pinout(supplyDAC,10); % 1st door, even channels
d2 = pinout(supplyDAC,19); % 2nd door
d3 = pinout(controlDAC,1); % 3rd door

phi1_1 = pinout(controlDAC,17); % phi 1
phi1_2 = pinout(controlDAC,14); % phi 2
phi1_3 = pinout(controlDAC,18); % phi 3

shield = pinout(supplyDAC,4); % shield underneath twiddle
d4 = pinout(controlDAC,5); % door after phi1 and before offset gate
d5 = pinout(controlDAC,19); % compensation door for 1st twiddle-sense
sense1_l = pinout(controlDAC,2); % sense gate left of twiddle
guard1_l = pinout(supplyDAC,6); % left shield from twiddle
twiddle1 = pinout(supplyDAC,18); % twiddle gate
guard1_r = pinout(supplyDAC,5); % right gate from twiddle
sense1_r = pinout(controlDAC,7);
d6 = pinout(controlDAC,20);

%% 2nd twiddle-sense
phi_Vdown_1 = pinout(controlDAC,3);
phi_Vdown_2 = pinout(controlDAC,15);
phi_Vdown_3 = pinout(controlDAC,16);

phi_Vup_1 = pinout(supplyDAC,20);
phi_Vup_2 = pinout(supplyDAC,8);
phi_Vup_3 = pinout(supplyDAC,7);

d_Vup_1 = pinout(supplyDAC,21);
d_Vup_2 = pinout(supplyDAC,9);
d_Vup_3 = pinout(controlDAC,4);

d7 = pinout(controlDAC,8); % compensation door for 2nd twiddle-sense
sense2_l = pinout(controlDAC,22);
guard2_l = pinout(supplyDAC,17);
twiddle2 = pinout(supplyDAC,16);
guard2_r = pinout(supplyDAC,3);
sense2_r = pinout(controlDAC,21);
d8 = pinout(controlDAC,9);

%% Electron trap
d9 = pinout(supplyDAC,15);
phi2_1 = pinout(supplyDAC,2);
phi2_2 = pinout(supplyDAC,14);
phi2_3 = pinout(supplyDAC,1);

d10 = pinout(supplyDAC,22); % Same as 1st door, uneven channels next to ST

trap1_2 = pinout(controlDAC,13);
trap1_1 = pinout(controlDAC,12);
trap2_2 = pinout(controlDAC,24);
trap2_1 = pinout(controlDAC,11);
trap5 = pinout(controlDAC,23);
trap6 = pinout(controlDAC,10);

%% HEMT control lines
Vg1 = pinout(sim900,3);
Vc1 = pinout(sim900,2);
Vf1 = pinout(sim900,1);

Vg2 = pinout(sim900,8);
Vc2 = pinout(sim900,7); % collector of cascode
Vf2 = pinout(sim900,6); % emitter follower of cascode

function gate = pinout(Device,Port)
% Creating object that contains DAC and channel
    gate.Device = Device;
    gate.Port = Port;
end