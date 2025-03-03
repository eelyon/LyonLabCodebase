%% DC pinout for 2019_D_ROIC_QD_ava_DIY die bonded Dec. 2024
%% Sommer-Tanner pinout
STD = pinout(controlDAC,12); % Sommer-Tanner drive
STS = pinout(sim900,8); % Sommer-Tanner sense
STM = pinout(controlDAC,10); % Sommer-Tanner middle gate

TM = pinout(controlDAC,24); % top metal
M2S = pinout(controlDAC,11); % Sommer-Tanner shield on M2
BPG = pinout(controlDAC,23); % bond pad guard

filament = pinout(sim900,4); % filament backing plate

%% 1st twiddle-sense
d1_odd = pinout(supplyDAC,1); % 1st door, uneven channels
d1_even = pinout(controlDAC,13); % 1st door, even channels
d2 = pinout(supplyDAC,4); % 2nd door
d3 = pinout(controlDAC,22); % 3rd door

phi1_1 = pinout(controlDAC,6); % phi 1
phi1_2 = pinout(controlDAC,9); % phi 2
phi1_3 = pinout(controlDAC,5); % phi 3

shield = pinout(supplyDAC,7); % shield underneath twiddle
d4 = pinout(controlDAC,18); % door after phi1 and before offset gate
d5 = pinout(controlDAC,4); % compensation door for 1st twiddle-sense
sense1_l = pinout(sim900,3); % sense gate left of twiddle
guard1_l = pinout(supplyDAC,5); % left shield from twiddle
twiddle1 = pinout(supplyDAC,17); % twiddle gate
guard1_r = pinout(supplyDAC,18); % right gate from twiddle
sense1_r = pinout(controlDAC,16);
d6 = pinout(controlDAC,3);

%% 2nd twiddle-sense
phi_Vdown_1 = pinout(controlDAC,8);
phi_Vdown_2 = pinout(controlDAC,21);
phi_Vdown_3 = pinout(controlDAC,7);

phi_Vup_1 = pinout(supplyDAC,3);
phi_Vup_2 = pinout(supplyDAC,15);
phi_Vup_3 = pinout(supplyDAC,16);

d_Vup_1 = pinout(supplyDAC,2);
d_Vup_2 = pinout(supplyDAC,14);
d_Vup_3 = pinout(controlDAC,19);

d7 = pinout(controlDAC,15); % compensation door for 2nd twiddle-sense
sense2_l = pinout(sim900,1);
guard2_l = pinout(supplyDAC,6);
twiddle2 = pinout(supplyDAC,19);
guard2_r = pinout(supplyDAC,20);
sense2_r = pinout(controlDAC,1);
d8 = pinout(controlDAC,14);

%% Electron trap
d9 = pinout(supplyDAC,8);
phi2_1 = pinout(supplyDAC,21);
phi2_2 = pinout(supplyDAC,9);
phi2_3 = pinout(supplyDAC,22);

trap1 = pinout(supplyDAC,10);
trap2 = pinout(supplyDAC,23);
trap3 = pinout(supplyDAC,11);
trap4 = pinout(supplyDAC,24);
trap5 = pinout(supplyDAC,12);
trap6 = pinout(supplyDAC,13);

%% HEMT control lines
Vcc = pinout(sim900,6); % collector of cascode
Vf = pinout(sim900,7); % emitter follower of cascode

function gate = pinout(Device,Port)
% Creating object that contains DAC and channel
    gate.Device = Device;
    gate.Port = Port;
end