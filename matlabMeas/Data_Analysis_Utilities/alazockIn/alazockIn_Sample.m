%AlazockIn Sample Usage

% Parameters
fcut = 1e5;
tc = 1 / fcut;
stages = 20;

fL = 10e6;
tfFact = 10;
samples = 100;

% Generate input signals using util_noisyGenInp
[t, sqL] = util_noisyGenInp(fL, samples, tfFact * tc, 150e-3, 0, 1e-3);

fact = 1;
[~, inp] = util_noisyGenInp(fL * fact, samples / fact, tfFact * tc / fact, 1, 90, 3e-2);

% Perform lock-in behavior calculation
[t, psdi, psdq] = lockInBehavior(t, sqL, fL, fcut, stages, inp);

%%{
figure;
plot(t, psdi);
hold on;
plot(t, psdq);
hold off;
xlabel('Time');
ylabel('Signal');
legend('PSDI', 'PSDQ');
title('Lock-in Behavior');
%}