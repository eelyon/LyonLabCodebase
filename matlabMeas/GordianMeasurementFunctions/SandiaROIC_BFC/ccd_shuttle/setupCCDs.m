%% setupCCDs.m  -  define every CCD once, then call ccdX.move(nPixels) wherever needed
% Requires: the DAC objects are connected and `pinout` exists, with
% pinout.<gate>.device (baselDAC / QDAC handle) and pinout.<gate>.port.
% Constructing the objects does NOT touch the hardware; the first
% park()/move() checks the channels and loads the sequencer.
%
% Channel order = travel order: {parking gate, next gate, gate after that}.

common = {'VHigh', 2, 'VLow', -1};

%% Vertical CCD: coax (unfiltered), Basel DAC, HBW 100 kHz.
% Electron parks on phi_v_2, travels 2 -> 3 -> 1.
ccdV = ccdShuttle.fromPinout('vertical', pinout, {'phi_v_2', 'phi_v_3', 'phi_v_1'}, ...
    common{:}, 'FilterCutoffHz', 100e3, ...
    'Waveform', 'linear', 'NumSteps', 10, 'EdgeTime', 100e-6, 'Dwell', 800e-6);   % T = 1.8 ms

%% Horizontal CCDs: loom (63.6 kHz RC), QDAC HIGH filter (~100 kHz).
% Electrons park on phi_h*_1, travel 1 -> 2 -> 3.
% Chain tau = 1.59 + 2.50 us; step settles to 1 % in 14.0 us, 0.1 % in 19.8 us.
% Values below are the ELECTRICAL lower limits; the electron transfer itself
% may need slower clocks - start slower and decrease from there.
loom = {'FilterCutoffHz', [100e3 63.6e3]};

% trapezoid: edge 10 levels x 2 us (QDAC LIST minimum), plateau 100 us -> T = 2*(20+100) = 240 us;
% all gates static for (100 - 2*20)/3 = 20 us between edges (> 19.8 us, 0.1 % settling)
ccdH1 = ccdShuttle.fromPinout('horizontal1', pinout, {'phi_h1_1', 'phi_h1_2', 'phi_h1_3'}, ...
    common{:}, loom{:}, 'Waveform', 'cosine', 'NumSteps', 10, 'EdgeTime', 20e-6, 'Dwell', 100e-6);

% sine: 2 kHz -> 250 points x 2 us, amplitude loss 0.07 %, common delay 4.1 us
ccdH2 = ccdShuttle.fromPinout('horizontal2', pinout, {'phi_h2_1', 'phi_h2_2', 'phi_h2_3'}, ...
    common{:}, loom{:}, 'Waveform', 'sine', 'Frequency', 2e3);

%% ---- typical use (not executed by this script) ---------------------------
%   ccdV.park();               % phi_v_2 = +2 V, phi_v_3 = phi_v_1 = -1 V
%   ccdV.move(75);             % 75 pixels forward
%   ccdV.move(-1);             % one pixel back
%
%   ccdV.arm(3);               % slow part once: 3 pixels, both directions
%   for k = 1:100
%       ccdV.forward();        % start command + 3*Period + poll
%       % ... measure ...
%       ccdV.backward();       % QDAC: 6 writes to flip; Basel: rewrites B/C memory
%   end
%   ccdH2.SineRest = 'sine';   % sine without the software ramps on every move
%
%   ccdV.Dwell = 500e-6;       % plateau width; Period = 2*(EdgeTime + Dwell) = 1.2 ms
%   ccdV.Frequency = 1e3;      % or set the period: Dwell = 1/(2f) - EdgeTime = 400 us
%
%   ccdH1.Waveform = 'sine';   % switch shape on the fly ...
%   ccdH1.Frequency = 1e3;     % ... then set the timing (sine uses SinePeriod)
%
%   ccdH1.plot(2);             % preview; RC overlay uses FilterCutoffHz
%   ccdH1.summary();           % realised timing + settling / attenuation check