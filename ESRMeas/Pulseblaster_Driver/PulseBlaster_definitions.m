%%% Common Definitions
% Defines for start_programming
PULSE_PROGRAM  = 0;
FREQ_REGS      = 1;

PHASE_REGS     = 2;
TX_PHASE_REGS  = 2;
PHASE_REGS_1   = 2;

RX_PHASE_REGS  = 3;
PHASE_REGS_0   = 3;

% These are names used by RadioProcessor
COS_PHASE_REGS = 51;
SIN_PHASE_REGS = 50;

% For specifying which device in pb_dds_load
DEVICE_SHAPE = hex2dec('099000');
DEVICE_DDS   = hex2dec('099001');

% Defines for enabling analog output
ANALOG_ON = 1;
ANALOG_OFF = 0;
TX_ANALOG_ON = 1;
TX_ANALOG_OFF = 0;
RX_ANALOG_ON = 1;
RX_ANALOG_OFF = 0;

% Defines for different pb_inst instruction types
CONTINUE = 0;
STOP = 1;
LOOP = 2;
END_LOOP = 3;
JSR = 4;
RTS = 5;
BRANCH = 6;
LONG_DELAY = 7;
WAIT = 8;
RTI = 9;

% Defines for using different units of time
ns = 1.0;
us = 1000.0;
ms = 1000000.0;
% This causes problems with some versions of stdio.h
% s = 1000000000.0;

% Defines for using different units of frequency
MHz = 1.0;
kHz = .001;
Hz = .000001;

PARAM_ERROR = -99;

% Variables for max number of registers (Currently the same across models) THIS NEEDS TO BE WEEDED OUT!!! any occurances should be replaced with board[cur_board].num_phase2, etc.
MAX_PHASE_REGS = 16;
MAX_FREQ_REGS = 16;

% SpinPTS Includes & Defines

ERROR_STR_SIZE	    = 25;
 
BCDBYTEMASK			= hex2dec('0F0F0F0F');

ID_MHz100		= hex2dec('0');
ID_MHz10		= hex2dec('1');
ID_MHz1			= hex2dec('2');
ID_kHz100		= hex2dec('3');
ID_kHz10		= hex2dec('4');
ID_kHz1			= hex2dec('5');
ID_Hz100		= hex2dec('6');
ID_Hz10			= hex2dec('7');
ID_Hz1			= hex2dec('8');
ID_pHz			= hex2dec('9');
ID_latch    	= hex2dec('A');
ID_UNUSED		= hex2dec('F');
 
PHASE_INVALID		= hex2dec('100');
FREQ_ORANGE			= hex2dec('101');

DWRITE_FAIL			= hex2dec('200');
DEVICE_OPEN_FAIL	= hex2dec('201');
NO_DEVICE_FOUND		= hex2dec('202');
