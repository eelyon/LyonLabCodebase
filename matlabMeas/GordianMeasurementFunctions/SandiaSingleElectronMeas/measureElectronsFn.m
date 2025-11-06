function [numE] = measureElectronsFn(pinout,sensor,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Sweep vload and measure sense 1

% Need to set input capacitance and gain
cap1 = 3.31e-12;
gain1 = 24.2*0.889;

cap2 = 2.89e-12;
gain2 = 20*0.887;

p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
% Sweep parameters
p.addParameter('vstart', 0, @isnumeric);
p.addParameter('vstop', -0.7, @isnumeric);
p.addParameter('vstep', 0.01, @isnumeric);
% Filter order
p.addParameter('filter_order', 2, isnonneg);
% Filter time constant
p.addParameter('time_constant', 0.1, @isnumeric);
% Demodulation/sampling rate of demodulated data
p.addParameter('demod_rate', 1e3, @isnumeric);
% The length of time to accumulate subscribed data (by sleeping) before polling a second time [s].
% p.addParameter('sleep_duration', 1.0, isnonneg);
p.parse(varargin{:});

tc = p.Results.time_constant;
filter = p.Results.filter_order;
drat = p.Results.demod_rate;

vstart = p.Results.vstart;
vstop = p.Results.vstop;
vstep = p.Results.vstep;

if sensor == 1
    [~,~,x,y] = MFLISweep1D_getSample({'Guard1'},vstart,vstop,vstep,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
    'filter_order',filter,'time_constant',tc,'demod_rate',drat);
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,5,1100); delay(1); % reset guard
    mag = correct_mag(x,y);
    numE = calc_electrons(mag,cap1,gain1,0.52); % Calc. tot. no. of electrons

elseif sensor == 2
    [~,~,x,y] = MFLISweep1D_getSample({'Guard2'},vstart,vstop,vstep,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
    'filter_order',filter,'time_constant',tc,'demod_rate',drat);
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,5,1100); delay(1); % reset guard
    mag = correct_mag(x,y);
    numE = calc_electrons(mag,cap2,gain2,0.52); % Calc. tot. no. of electrons
end

% Replot data
fig = figure();
vguard = vstop:vstep:vstart;
plot(vguard,mag(end:-1:1)*1e6,'.-','MarkerSize',14,'DisplayName',['corrected R, n = ',num2str(round(numE,1))]);
% stdm = sqrt(stdx.^2 + stdy.^2); % Calc. standard deviation of magnitude
% errorbar(vguard,mag(end:-1:1)*1e6,stdm(end:-1:1)*1e6,'.-','MarkerSize',14,'DisplayName',['corrected R, n = ',num2str(round(numE,1))]);
% set(gca,'FontSize',13)
xlabel('V_{guard} [V]')
ylabel('R [\mu V_{rms}]')
legend('Location','best');
saveData(fig, ['CorrectedSensor',num2str(sensor)]);
end