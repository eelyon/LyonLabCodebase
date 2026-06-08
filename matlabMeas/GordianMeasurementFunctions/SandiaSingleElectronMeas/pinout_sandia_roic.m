%% DC pinout for 2019_D_ROIC_QD die bonded July. 2025
if (~exist('controlDAC') == 1) || (~exist('supplyDAC') == 1) || (~exist('sim900') == 1)
    error('Error: Not connected to DACs. Please connect!')
end

pinout = [];

%% Sommer-Tanner pinout
pinout.std.device = supplyDAC; % Sommer-Tanner drive
pinout.std.port = 23;
pinout.sts.device = controlDAC; % Sommer-Tanner sense
pinout.sts.port = 6;
pinout.stm.device = supplyDAC; % Sommer-Tanner middle gate
pinout.stm.port = 13;

pinout.tm.device = supplyDAC; % top metal
pinout.tm.port = 11;
pinout.m2s.device = supplyDAC; % Sommer-Tanner shield on M2
pinout.m2s.port = 24;
pinout.bpg.device = supplyDAC; % bond pad guard
pinout.bpg.port = 12;

pinout.filament.device = sim900;
pinout.filament.port = 4; % filament backing plate

%% 1st twiddle-sense
pinout.d1_odd.device = supplyDAC;
pinout.d1_odd.port = 22; % 1st door, uneven channels
pinout.d1_even.device = supplyDAC;
pinout.d1_even.port = 10; % 1st door, even channels
pinout.d2.device = supplyDAC;
pinout.d2.port = 19; % 2nd door
pinout.d3.device = controlDAC;
pinout.d3.port = 1; % 3rd door

pinout.phi_h1_1.device = controlDAC;
pinout.phi_h1_1.port = 17; % phi 1
pinout.phi_h1_2.device = controlDAC;
pinout.phi_h1_2.port = 14; % phi 2
pinout.phi_h1_3.device = controlDAC;
pinout.phi_h1_3.port = 18; % phi 3

pinout.shield.device = supplyDAC;
pinout.shield.port = 4; % shield underneath twiddle
pinout.d4.device = controlDAC;
pinout.d4.port = 5; % door after phi1 and before offset gate
pinout.d5.device = controlDAC;
pinout.d5.port = 19; % compensation door for 1st twiddle-sense
pinout.sense1_l.device = controlDAC;
pinout.sense1_l.port= 2; % sense gate left of twiddle
pinout.guard1_l.device = supplyDAC;
pinout.guard1_l.port = 6; % left shield from twiddle
pinout.twiddle1.device = supplyDAC;
pinout.twiddle1.port = 18; % twiddle gate
pinout.guard1_r.device = supplyDAC;
pinout.guard1_r.port = 5; % right gate from twiddle
pinout.sense1_r.device = controlDAC;
pinout.sense1_r.port = 7;
pinout.d6.device = controlDAC;
pinout.d6.port = 20;
    
%% 2nd twiddle-sense
pinout.phi_v1_1.device = controlDAC;
pinout.phi_v1_1.port = 16;
pinout.phi_v1_2.device = controlDAC;
pinout.phi_v1_2.port = 15;
pinout.phi_v1_3.device = controlDAC;
pinout.phi_v1_3.port = 3;

pinout.phi_v2_1.device = supplyDAC;
pinout.phi_v2_1.port = 7;
pinout.phi_v2_2.device = supplyDAC;
pinout.phi_v2_2.port = 8;
pinout.phi_v2_3.device = supplyDAC;
pinout.phi_v2_3.port = 20;

pinout.d_v_1.device = controlDAC;
pinout.d_v_1.port = 4;
pinout.d_v_2.device = supplyDAC;
pinout.d_v_2.port = 9;
pinout.d_v_3.device = supplyDAC;
pinout.d_v_3.port = 21;

pinout.d7.device = controlDAC;
pinout.d7.port = 8; % compensation door for 2nd twiddle-sense
pinout.sense2_l.device = controlDAC;
pinout.sense2_l.port = 22;
pinout.guard2_l.device = supplyDAC;
pinout.guard2_l.port = 17;
pinout.twiddle2.device = supplyDAC;
pinout.twiddle2.port = 16;
pinout.guard2_r.device = supplyDAC;
pinout.guard2_r.port = 3;
pinout.sense2_r.device = controlDAC;
pinout.sense2_r.port = 21;
pinout.d8.device = controlDAC;
pinout.d8.port = 9;

%% Electron trap
pinout.d9.device = supplyDAC;
pinout.d9.port = 15;
pinout.phi_h2_1.device = supplyDAC;
pinout.phi_h2_1.port = 2;
pinout.phi_h2_2.device = supplyDAC;
pinout.phi_h2_2.port = 14;
pinout.phi_h2_3.device = supplyDAC;
pinout.phi_h2_3.port = 1;

pinout.d10.device = supplyDAC;
pinout.d10.port = 22; % Same as 1st door, uneven channels next to ST

pinout.trap1.device = controlDAC;
pinout.trap1.port = 13;
pinout.trap2.device = controlDAC;
pinout.trap2.port = 12;
pinout.trap3.device = controlDAC;
pinout.trap3.port = 24;
pinout.trap4.device = controlDAC;
pinout.trap4.port = 11;
pinout.trap5.device = controlDAC;
pinout.trap5.port = 23;
pinout.trap6.device = controlDAC;
pinout.trap6.port = 10;

%% HEMT control lines
pinout.vg1.device = sim900;
pinout.vg1.port = 3;
pinout.vc1.device = sim900;
pinout.vc1.port = 2;
pinout.vf1.device = sim900;
pinout.vf1.port = 1;

pinout.vg2.device = sim900;
pinout.vg2.port = 8;
pinout.vc2.device = sim900;
pinout.vc2.port = 7; % collector of cascode
pinout.vf2.device = sim900;
pinout.vf2.port = 6; % emitter follower of cascode