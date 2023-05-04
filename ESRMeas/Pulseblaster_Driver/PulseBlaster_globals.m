function PulseBlaster_globals

global clock_freq;
global MIL;


clock_freq = 100; % in MHz.
MIL = 100;%70;   % minimal instruction length (5*1/100Mz) [in ns]

global TRIG_Agilent;
global TRIG_ZTO;
global TRIG_Alazar;
global TRIG_LED;
global TRIG_Stark;
global TRIG_RF;


TRIG_Agilent = 2^16;
TRIG_ZTO = 2^18;
TRIG_Alazar = 2^17; 
%TRIG_Alazar = 2^17; 
TRIG_LED = 2^19;
TRIG_Stark = 2^20;
%TRIG_Stark = 2^17;
TRIG_RF = 2^18;


global Agilent_TriggerLength;
global ZTO_TriggerLength;
global Alazar_TriggerLength;
global LED_TriggerLength;
global Stark_TriggerLength;
global RF_TriggerLength;

Agilent_TriggerLength = MIL;    % [in ns]
ZTO_TriggerLength = MIL*10;        % [in ns]
Alazar_TriggerLength = MIL*10;  % [in ns]
LED_TriggerLength = MIL*10;        % [in ns]
Stark_TriggerLength = MIL;
RF_TriggerLength = MIL*10;        % [in ns]
