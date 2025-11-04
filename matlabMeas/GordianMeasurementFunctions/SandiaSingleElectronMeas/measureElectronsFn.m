function [] = measureElectronsFn(pinout,sensor)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Sweep vload and measure sense 1
vstart = 0;
vstop = -0.7;
vstep = 0.01;

filter = 3;
tc = 0.2;
drat = 13e3;
poll = 1;

cap1 = 3.16e-12;
gain1 = 24*0.92;

cap2 = 2.78e-12;
gain2 = 19;

if sensor == 1
    [~,~,x,y,~,~,stdx,stdy] = MFLISweep1D({'Guard1'},vstart,vstop,vstep,'dev32021',pinout.guard1_l.device,pinout.guard1_l.port,0, ...
    'filter_order',filter,'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,5,1100) % reset guard
    
    mag = correct_mag(x,y);
    numE = calc_electrons(mag,cap1,gain1,0.52); % Calc. tot. no. of electrons
    fprintf(['numE = ',num2str(numE),'\n'])

elseif sensor == 2
    [~,~,x,y,~,~,stdx,stdy] = MFLISweep1D({'Guard2'},vstart,vstop,vstep,'dev32061',pinout.guard2_l.device,pinout.guard2_l.port,0, ...
    'filter_order',filter,'time_constant',tc,'demod_rate',drat,'poll_duration',poll);
    sigDACRamp(pinout.guard1_l.device,pinout.guard1_l.port,0,5,1100) % reset guard
    
    mag = correct_mag(x,y);
    numE = calc_electrons(mag,cap2,gain2,0.52); % Calc. tot. no. of electrons
    fprintf(['numE = ',num2str(numE),'\n'])
end

% Replot data
fig = figure();
vguard = vstop:vstep:vstart;
stdm = sqrt(stdx.^2 + stdy.^2); % Calc. standard deviation of magnitude
errorbar(vguard,mag(end:-1:1)*1e6,stdm(end:-1:1)*1e6,'.-','MarkerSize',14,'DisplayName',['corrected R, n = ',num2str(round(numE,1))]);
% set(gca,'FontSize',13)
xlabel('V_{guard} [V]')
ylabel('R [\mu V_{rms}]')
legend('Location','best');
saveData(fig, ['CorrectedSensor',num2str(sensor)]);
end