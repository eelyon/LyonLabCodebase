%% Code for getting I and Q
close all
Fs = 20e6; % Sampling rate
Ts = 1/Fs; % Time increment per point
theta = 0;

% Create sine and cosine waves
N = 1000;
tstep = Ts;
ftbase = (0:N) * Fs/N; % Fs*(0:tstep:N);

t = (0:N-1)*Ts;
Vs = sqrt(2)*1*cos(2*pi*1e6*t+theta)+0*randn(1,N);
Vr = sqrt(2)*cos(2*pi*1e6*t)-1i*sqrt(2)*sin(2*pi*1e6*t);
figure
plot(t,Vs)
hold on
plot(t,real(Vr))
hold off
legend('Vs','Vr')

S = 0.5*cos(2*pi*1e6*t)+0.05*randn(1,N);

% figure
% plot((-N/2:N/2-1)*Fs/N,abs(fftshift(fft(S))))

% imix0 = zeros(2, N);
sine = sin(2*pi*1e6*t);
cosine = cos(2*pi*1e6*t);

Xmix = zeros(1,N); % Vs.*real(Vr); % S.*cosine;
Ymix = zeros(1,N); % Vs.*imag(Vr); % S.*sine;

for i = 1:N
    Xmix(i) = fft(Vs(i)).*fft(real(Vr(i)));
    Ymix(i) = fft(Vs(i)).*fft(imag(Vr(i)));
end

figure;
plot(t, ifft(Xmix));
hold on;
plot(t, ifft(Ymix));
hold off;
xlabel('Time');
ylabel('Signal');
legend('Xmix', 'Ymix');

figure
plot((-N/2:N/2-1)*Fs/N,abs(fftshift(fft(Xmix))))
hold on
plot((-N/2:N/2-1)*Fs/N,abs(fftshift(fft(Ymix))))
hold off
legend('fft(Xmix)','fft(Ymix)')

% hanning = zeros(1,N);
% 
% for i = 1:N
%     hanning(i) = 0.5*(1-cos(2*pi*i/N));
% end
% 
% h = zeros(1,70);
% 
% for i = 1:70
%     h(i) = 0.5*(1-cos(1i*2*pi/70));
% end

% X = ifft(fft(Xmix).*fft(hanning));
% Y = ifft(fft(Ymix).*fft(hanning));

tau = 0.1;

n = 1; % Filter stages
X = zeros(1,N);
Y = zeros(1,N);
col = 1;

X_fft = fftshift(fft(Xmix));
Y_fft = fftshift(fft(Ymix));

for f = (-N/2:N/2-1)*Fs/N
    X(col) = ifft(X_fft(col).*((1/(1i*2*pi*f*tau))^n));
    Y(col) = ifft(Y_fft(col).*((1/(1i*2*pi*f*tau))^n));
    col = col+1;
end

figure;
plot(t, abs(X));
hold on;
plot(t, abs(Y));
hold off;
xlabel('Time');
ylabel('Signal');
legend('X', 'Y');

R = sqrt(X.^2+Y.^2);
phi = atand(Y./X);

% figure;
% plot(t, R);
% hold on;
% plot(t, phi);
% hold off;
% xlabel('Time');
% ylabel('Signal');
% legend('R', '\phi');

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