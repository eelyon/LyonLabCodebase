%% DC pinout for 2019_D_ROIC_QD die in BFC
if (~exist('qDAC') == 1) || (~exist('baselDAC') == 1)
    error('Error: Not connected to DACs. Please connect!')
end

pinout = [];

%% Sommer-Tanner pinout
pinout.std.device = baselDAC; % Sommer-Tanner drive
pinout.std.port = 21;
pinout.sts.device = qDAC; % Sommer-Tanner sense
pinout.sts.port = 7;
pinout.stm.device = qDAC; % Sommer-Tanner middle gate
pinout.stm.port = 16;

pinout.tm.device = baselDAC; % top metal
pinout.tm.port = 9;
pinout.m2s.device = baselDAC; % Sommer-Tanner shield on M2
pinout.m2s.port = 10;
pinout.bpg.device = baselDAC; % bond pad guard
pinout.bpg.port = 11;

pinout.filament.device = baselDAC;
pinout.filament.port = 13; % filament backing plate

%% 1st twiddle-sense
pinout.d1_1.device = baselDAC;
pinout.d1_1.port = 8; % 1st door, uneven channels
pinout.d1_2.device = baselDAC;
pinout.d1_2.port = 20; % 1st door, even channels
pinout.d2.device = baselDAC;
pinout.d2.port = 19; % 2nd door
pinout.d3.device = qDAC;
pinout.d3.port = 4; % 3rd door

pinout.phi_h1_1.device = qDAC;
pinout.phi_h1_1.port = 18; % phi 1
pinout.phi_h1_2.device = qDAC;
pinout.phi_h1_2.port = 17; % phi 2
pinout.phi_h1_3.device = qDAC;
pinout.phi_h1_3.port = 19; % phi 3

pinout.shield.device = baselDAC;
pinout.shield.port = 4; % shield underneath twiddle
pinout.d4.device = qDAC;
pinout.d4.port = 6; % door after phi1 and before offset gate
pinout.d5.device = qDAC;
pinout.d5.port = 20; % compensation door for 1st twiddle-sense
pinout.sense1_l.device = qDAC;
pinout.sense1_l.port= 5; % sense gate left of twiddle
pinout.guard1_l.device = baselDAC;
pinout.guard1_l.port = 6; % left shield from twiddle
pinout.twiddle1.device = baselDAC;
pinout.twiddle1.port = 18; % twiddle gate
pinout.guard1_r.device = baselDAC;
pinout.guard1_r.port = 5; % right gate from twiddle
pinout.sense1_r.device = qDAC;
pinout.sense1_r.port = 8;
pinout.d6.device = qDAC;
pinout.d6.port = 21;
    
%% 2nd twiddle-sense
pinout.phi_v_1.device = baselDAC;
pinout.phi_v_1.port = 24;
pinout.phi_v_2.device = baselDAC;
pinout.phi_v_2.port = 22;
pinout.phi_v_3.device = baselDAC;
pinout.phi_v_3.port = 23;

pinout.d7.device = qDAC;
pinout.d7.port = 9; % compensation door for 2nd twiddle-sense
pinout.sense2_l.device = qDAC;
pinout.sense2_l.port = 23;
pinout.guard2_l.device = baselDAC;
pinout.guard2_l.port = 17;
pinout.twiddle2.device = baselDAC;
pinout.twiddle2.port = 16;
pinout.guard2_r.device = baselDAC;
pinout.guard2_r.port = 3;
pinout.sense2_r.device = qDAC;
pinout.sense2_r.port = 22;
pinout.d8.device = qDAC;
pinout.d8.port = 10;

%% Electron trap
pinout.d9.device = baselDAC;
pinout.d9.port = 15;
pinout.phi_h2_1.device = baselDAC;
pinout.phi_h2_1.port = 2;
pinout.phi_h2_2.device = baselDAC;
pinout.phi_h2_2.port = 14;
pinout.phi_h2_3.device = baselDAC;
pinout.phi_h2_3.port = 1;

pinout.d10.device = baselDAC;
pinout.d10.port = 7; % Same as 1st door, uneven channels next to ST

pinout.trap1.device = qDAC;
pinout.trap1.port = 13;
pinout.trap2.device = qDAC;
pinout.trap2.port = 12;
pinout.trap3.device = qDAC;
pinout.trap3.port = 11;
pinout.trap4.device = qDAC;
pinout.trap4.port = 24;

% %% HEMT control lines
% pinout.vg1.device = sim900;
% pinout.vg1.port = 3;
% pinout.vc1.device = sim900;
% pinout.vc1.port = 2;
% pinout.vf1.device = sim900;
% pinout.vf1.port = 1;
% 
% pinout.vg2.device = sim900;
% pinout.vg2.port = 8;
% pinout.vc2.device = sim900;
% pinout.vc2.port = 7; % collector of cascode
% pinout.vf2.device = sim900;
% pinout.vf2.port = 6; % emitter follower of cascode