function [ y ] = num2num( x )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if abs(x) < 10
        y = ['00',num2str(x)];
    elseif abs(x) < 100
        y = ['0',num2str(x)];
    elseif abs(x) < 1000
        y = num2str(x);
    else
        fprintf('NUMBER TOO LARGE \n')
        y = num2str(x);
    end
end

