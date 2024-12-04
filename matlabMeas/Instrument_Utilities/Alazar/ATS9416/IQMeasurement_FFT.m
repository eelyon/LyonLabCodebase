%% Code for getting I and Q
Fs = 10e6;
Ts = 1/Fs;
L = 1000;

% t = (0:L-1)*Ts;
% S = 0.2*sin(2*pi*1e6*t);
% S_fft = fft(S);

% Create sine and cosine waves
N = floor(samplesPerRecord/2);
tstep = Ts;
ftbase = (0:N) * Fs/L; % Fs*(0:tstep:N);

imix0 = zeros(2, N);
cosine = cos(2*pi*ftbase*1e6);
sine = sin(2*pi*ftbase*1e6);

for i = 1:N
    imix0(1,i) = cosine(i);
    imix0(2,i) = sine(i);
end

hann = zeros(1, N);

for i = 1:N
    hann(i) = 0.5*(1-cos(2*pi*i/N));
end

imix0 = imix0.*hann;

qmix0 = zeros(2, N);
qmix0(1,:) = imix0(2,:).*(-1);
qmix0(2,:) = imix0(1,:);

imix = reshape(imix0,2*N,1);
qmix = reshape(qmix0,2*N,1);

iqout = zeros(1,samplesPerRecord);

for j = 1:samplesPerRecord
    I = sum(P2(j).*imix);
    Q = sum(P2(j).*qmix);
    iqout(j) = complex(I,Q);
end

figure
plot(sqrt(ifft(real(iqout)).^2+ifft(imag(iqout)).^2))