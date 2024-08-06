x = [];
y = [];
for i=1:20
     x = [x SR830queryDisplay1(SR830Twiddle)];
     y = [y SR830queryDisplay2(SR830Twiddle)];
end

avgx = mean(x);
avgy = mean(y);
fprintf(['(', num2str(avgx), ',', num2str(avgy), ')\n'])

