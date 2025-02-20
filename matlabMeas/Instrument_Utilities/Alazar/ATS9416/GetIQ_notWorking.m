%% Code for getting I and Q
Fs = 10e6;
Ts = 1/Fs;
L = 10000;

% t = (0:L-1)*Ts;
% S = 0.2*sin(2*pi*1e6*t);
% S_fft = fft(S);

% Create sine and cosine waves
N = floor(L/2);
t = (0:N-1)*Ts;
ftbase = (0:N) * Fs/L; % Fs*(0:tstep:N);

Vs = sqrt(2)*1*cos(2*pi*1e6*t+theta)+0.02*randn(1,N);

imix0 = zeros(2, N);
cosine = cos(2*pi*ftbase*1e6);
sine = sin(2*pi*ftbase*1e6);

for i = 1:N
    imix0(1,i) = cosine(i);
    imix0(2,i) = sine(i);
end

% hann = zeros(1, N);
% 
% for i = 1:N
%     hann(i) = 0.5*(1-cos(2*pi*i/N));
% end

% imix0 = imix0.*hann;

filter = zeros(1,N);

for i = 1:N
    filter(i) = LPF(i*Fs/N,0.1,1);
end

qmix0 = zeros(2, N);
qmix0(1,:) = imix0(2,:).*(-1);
qmix0(2,:) = imix0(1,:);

imix = reshape(imix0,2*N,1);
qmix = reshape(qmix0,2*N,1);

iqout = zeros(1,L);

for j = 1:L
    Imix = sum(Vs(j).*imix);
    Qmix = sum(Vs(j).*qmix);
    iqout(j) = complex(Imix,Qmix);
end

figure
plot(t,iqout)

% for f = (-N/2:N/2-1)*Fs/N
%     X(col) = ifft(X_fft(col).*((1/(1i*2*pi*f*tau))^n));
%     Y(col) = ifft(Y_fft(col).*((1/(1i*2*pi*f*tau))^n));
%     col = col+1;
% end
% 
% figure
% plot(sqrt(ifft(real(iqout)).^2+ifft(imag(iqout)).^2))

function lowPass = LPF(f,tau,n)
    lowPass = (1/(1i*2*pi*f*tau))^n;
end