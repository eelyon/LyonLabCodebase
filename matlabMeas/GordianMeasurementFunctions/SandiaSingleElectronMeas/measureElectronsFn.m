function [numE,numErr] = measureElectronsFn(pinout,sensor,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Sweep vload and measure sense 1

p = inputParser;
isnonneg = @(x) isnumeric(x) && isscalar(x) && (x > 0);
% Sweep parameters
p.addParameter('vstart', 0, @isnumeric);
p.addParameter('vstop', -0.7, @isnumeric);
p.addParameter('vstep', 0.01, @isnumeric);
p.addParameter('v_on', -0.3, @isnumeric);
p.addParameter('v_off', -0.6, @isnumeric);
% Filter order
p.addParameter('filter_order', 2, isnonneg);
% Filter time constant
p.addParameter('time_constant', 0.5, @isnumeric);
% Demodulation/sampling rate of demodulated data
p.addParameter('demod_rate', 10e3, @isnumeric);
p.addParameter('poll', 10, isnonneg);
p.addParameter('sweep', 1, @isnumeric);
p.addParameter('onoff', 1, @isnumeric);
% Circuit parameters
p.addParameter('dalpha', 0.503, @isnumeric);
p.addParameter('cin', 5.1e-12, @isnumeric);
p.addParameter('gain', 22.7*0.86, @isnumeric);
p.parse(varargin{:});

tc = p.Results.time_constant;
filter = p.Results.filter_order;
drat = p.Results.demod_rate;
poll = p.Results.poll;

vstart = p.Results.vstart;
vstop = p.Results.vstop;
vstep = p.Results.vstep;
v_on = p.Results.v_on;
v_off = p.Results.v_off;

dalpha = p.Results.dalpha; % Change in alpha
cin = p.Results.cin; % HEMT input capacitance
gain = p.Results.gain; % Amplifier gain

if sensor == 1
    if p.Results.sweep == 1
        [~,~,x,y] = MFLISweep1D_getSample({'Guard1'},vstart,vstop,vstep,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
        'filter_order',filter,'time_constant',tc,'demod_rate',drat);
        sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,5,1100); delay(1); % reset guard
    end
    if p.Results.onoff == 1
        [avgx,avgy,stdx,stdy] = MFLISweep1D_poll({'Guard1'},v_on,v_off,(v_off-v_on),'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
            'filter_order',filter,'time_constant',tc,'poll_duration',poll,'demod_rate',drat);
        sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,5,1100); delay(1); % reset guard
    
        corrx = avgx-avgx(2);
        corry = avgy-avgy(2);
        corrmag = sqrt(corrx.^2 + corry.^2);
        numE = (cin*2*sqrt(2) * (corrmag(1)-corrmag(2))) / (1.602e-19*gain*dalpha);
        
        stdm = sqrt(stdx.^2 + stdy.^2);
        numErr = (cin*2*sqrt(2) * (stdm(1)+stdm(2))) / (1.602e-19*gain*dalpha);
    end

elseif sensor == 2
    if p.Results.sweep == 1
        [~,~,x,y] = MFLISweep1D_getSample({'Guard2'},vstart,vstop,vstep,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
        'filter_order',filter,'time_constant',tc,'demod_rate',drat);
        sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,5,1100); delay(1); % reset guard
    end
    if p.Results.onoff == 1
        [avgx,avgy,stdx,stdy] = MFLISweep1D_poll({'Guard2'},v_on,v_off,(v_off-v_on),'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
            'filter_order',filter,'time_constant',tc,'poll_duration',poll,'demod_rate',drat);
        sigDACRamp(pinout.guard2_l.device,pinout.guard2_l.port,0,5,1100); delay(1); % reset guard
    
        corrx = avgx-avgx(2);
        corry = avgy-avgy(2);
        corrmag = sqrt(corrx.^2 + corry.^2);
        numE = (cin*2*sqrt(2) * (corrmag(1)-corrmag(2))) / (1.602e-19*gain*dalpha);
        
        stdm = sqrt(stdx.^2 + stdy.^2);
        numErr = (cin*2*sqrt(2) * (stdm(1)+stdm(2))) / (1.602e-19*gain*dalpha);
    end
end

if p.Results.sweep == 1 && p.Results.onoff == 1
    corrx_mag = x-avgx(2);
    corry_mag = y-avgy(2);
    mag = sqrt(corrx_mag.^2 + corry_mag.^2);
    
    % Replot data
    figure();
    vguard = vstart:vstep:vstop;
    plot(vguard,mag*1e6,'.-','MarkerSize',14,'DisplayName',['corrected R, n_{e}= ',num2str(numE,'%.2f'),'\pm',num2str(numErr,'%.2f')]);
    % stdm = sqrt(stdx.^2 + stdy.^2); % Calc. standard deviation of magnitude
    % errorbar(vguard,mag(end:-1:1)*1e6,stdm(end:-1:1)*1e6,'.-','MarkerSize',14,'DisplayName',['corrected R, n = ',num2str(round(numE,1))]);
    % set(gca,'FontSize',13)
    xlabel('V_{guard} [V]')
    ylabel('R [\mu V_{rms}]')
    legend('Location','best');
    % saveData(fig, ['CorrectedSensor',num2str(sensor)]);
end
end