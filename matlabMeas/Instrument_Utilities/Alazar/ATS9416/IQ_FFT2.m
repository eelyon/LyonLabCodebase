%% Code for getting I and Q
Fs = 10e6;
Ts = 1/Fs;

% Create sine and cosine waves
N = 1000;
tstep = Ts;
ftbase = (0:N) * Fs/N; % Fs*(0:tstep:N);

t = (0:N-1)*Ts;
S = sin(2*pi*1e6*t)+0*randn(1,N);
figure
plot(t,S)

% imix0 = zeros(2, N);
sine = sin(2*pi*1e6*t);
cosine = cos(2*pi*1e6*t);

Xmix = S.*sine;
Ymix = S.*cosine;

figure;
plot(t, Xmix);
hold on;
plot(t, Ymix);
hold off;
xlabel('Time');
ylabel('Signal');
legend('Xmix', 'Ymix');

hanning = zeros(1,N);

for i = 1:N
    hanning(i) = 0.5*(1-cos(2*pi*i/N));
end

h = zeros(1,70);

for i = 1:70
    h(i) = 0.5*(1-cos(2*pi*i/70));
end

figure
plot(fft(h))
figure
plot(h)

X = ifft(fft(Xmix).*fft(hanning));
Y = ifft(fft(Ymix).*fft(hanning));

figure;
plot(t, fft(hanning));
% hold on;
% plot(t, ifft(fft(Ymix)));
% hold off;
xlabel('Time');
ylabel('Signal');
% legend('X', 'Y');

R = sqrt(X.^2+Y.^2);
phi = atand(Y./X);

figure;
plot(t, R);
hold on;
plot(t, phi);
hold off;
xlabel('Time');
ylabel('Signal');
legend('R', '\phi');

% for i = 1:N
%     imix0(1,i) = cosine(i);
%     imix0(2,i) = sine(i);
% end
% 
% hann = zeros(1, N);
% 
% for i = 1:N
%     hann(i) = 0.5*(1-cos(2*pi*i/N));
% end
% 
% imix0 = imix0.*hann;
% 
% qmix0 = zeros(2, N);
% qmix0(1,:) = imix0(2,:).*(-1);
% qmix0(2,:) = imix0(1,:);
% 
% imix = reshape(imix0,2*N,1);
% qmix = reshape(qmix0,2*N,1);
% 
% iqout = zeros(1,samplesPerRecord);
% 
% for j = 1:samplesPerRecord
%     I = sum(P2(j).*imix);
%     Q = sum(P2(j).*qmix);
%     iqout(j) = complex(I,Q);
% end
% 
% figure
% plot(real(iqout))