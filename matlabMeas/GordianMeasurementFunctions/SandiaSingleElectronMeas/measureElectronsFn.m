function [numE,numErr] = measureElectronsFn(pinout,sensor,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Sweep vload and measure sense 1

% Need to set input capacitance and gain
alpha = 0.503;
cap1 = 5.79e-12;
gain1 = 27.5*0.877;
cap2 = 4.87e-12;
gain2 = 23*0.838;

p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
% Sweep parameters
p.addParameter('vstart', 0, @isnumeric);
p.addParameter('vstop', -0.7, @isnumeric);
p.addParameter('vstep', 0.01, @isnumeric);
% Filter order
p.addParameter('filter_order', 2, isnonneg);
% Filter time constant
p.addParameter('time_constant', 0.5, @isnumeric);
% Demodulation/sampling rate of demodulated data
p.addParameter('demod_rate', 1e3, @isnumeric);
p.addParameter('poll', 10, isnonneg);
p.addParameter('sweep', 1, @isnumeric);
p.addParameter('onoff', 1, @isnumeric);
% The length of time to accumulate subscribed data (by sleeping) before polling a second time [s].
% p.addParameter('sleep_duration', 1.0, isnonneg);
p.parse(varargin{:});

tc = p.Results.time_constant;
filter = p.Results.filter_order;
drat = p.Results.demod_rate;
poll = p.Results.poll;

vstart = p.Results.vstart;
vstop = p.Results.vstop;
vstep = p.Results.vstep;

if sensor == 1
    v_on = -0.35;
    v_off = -0.9;

if p.Results.sweep == 1
    [~,~,x,y] = MFLISweep1D_getSample({'Guard1'},vstart,vstop,vstep,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
    'filter_order',filter,'time_constant',tc,'demod_rate',drat);
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,5,1100); delay(1); % reset guard
end
if p.Results.onoff == 1
    [avgx,avgy,stdx,stdy] = MFLISweep1D_poll({'Guard1'},v_on,v_off,(v_off-v_on),'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
        'filter_order',filter,'time_constant',0.3,'poll_duration',poll,'demod_rate',drat);
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,5,1100); % reset guard

    corrx = avgx-avgx(2);
    corry = avgy-avgy(2);
    corrmag = sqrt(corrx.^2 + corry.^2);
    numE = (cap1*2*sqrt(2) * (corrmag(1)-corrmag(2))) / (1.602e-19*gain1*alpha)
    
    stdm = sqrt(stdx.^2 + stdy.^2);
    numErr = (cap1*2*sqrt(2) * (stdm(1)+stdm(2))) / (1.602e-19*gain1*alpha)
    
%     corrx_mag = x-avgx(2);
%     corry_mag = y-avgy(2);
%     mag = sqrt(corrx_mag.^2 + corry_mag.^2);
end

elseif sensor == 2
    v_on = -0.3;
    v_off = -0.7;

if p.Results.sweep == 1
    [~,~,x,y] = MFLISweep1D_getSample({'Guard2'},vstart,vstop,vstep,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
    'filter_order',filter,'time_constant',tc,'demod_rate',drat);
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,5,1100); delay(1); % reset guard
end
if p.Results.onoff == 1
    [avgx,avgy,stdx,stdy] = MFLISweep1D_poll({'Guard2'},v_on,v_off,(v_off-v_on),'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
        'filter_order',filter,'time_constant',0.2,'poll_duration',poll,'demod_rate',drat);
    sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,5,1100); % reset guard

    corrx = avgx-avgx(2);
    corry = avgy-avgy(2);
    corrmag = sqrt(corrx.^2 + corry.^2);
    numE = (cap2*2*sqrt(2) * (corrmag(1)-corrmag(2))) / (1.602e-19*gain2*0.52);
    
    stdm = sqrt(stdx.^2 + stdy.^2);
    numErr = (cap2*2*sqrt(2) * (stdm(1)+stdm(2))) / (1.602e-19*gain2*0.52);

    % corrx_mag = x-avgx(2);
    % corry_mag = y-avgy(2);
    % mag = sqrt(corrx_mag.^2 + corry_mag.^2);
end
end

if p.Results.sweep == 1 && p.Results.onoff == 1
    corrx_mag = x-avgx(2);
    corry_mag = y-avgy(2);
    mag = sqrt(corrx_mag.^2 + corry_mag.^2);
    
    % Replot data
    fig = figure();
    vguard = vstart:vstep:vstop;
    plot(vguard,mag*1e6,'.-','MarkerSize',14,'DisplayName',['corrected R, n_{e}= ',num2str(numE,'%.2f'),'\pm',num2str(numErr,'%.2f')]);
    % stdm = sqrt(stdx.^2 + stdy.^2); % Calc. standard deviation of magnitude
    % errorbar(vguard,mag(end:-1:1)*1e6,stdm(end:-1:1)*1e6,'.-','MarkerSize',14,'DisplayName',['corrected R, n = ',num2str(round(numE,1))]);
    % set(gca,'FontSize',13)
    xlabel('V_{guard} [V]')
    ylabel('R [\mu V_{rms}]')
    legend('Location','best');
    saveData(fig, ['CorrectedSensor',num2str(sensor)]);
end
end