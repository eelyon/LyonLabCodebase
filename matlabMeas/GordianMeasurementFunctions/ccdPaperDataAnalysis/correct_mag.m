function [corr_mag] = correct_mag(real,imag)
%CORRECT_MAG Correct measured magnitude by its background signal.
% Subtracts last value in measurement array from whole array.
    corr_real = real - real(length(real)); % Subtract background from Re
    corr_imag = imag - imag(length(imag)); % Subtract background from Imag
    corr_mag = sqrt(corr_real.^2 + corr_imag.^2); % Calc. magnitude
end