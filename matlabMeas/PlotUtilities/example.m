
% Create 35 figures with random data plots
N = 16;
for i = 1:16
figure;
plot(mod(i+1,5)*rand(1,100)*i + mod(i,3)*sin((1:100)*i),'Color',[rand(1,3)]);
end
%%
fprintf('TileFigures; :\n');
tileFigures;
fprintf('press any key to continue...\n');
%pause;
%%
fprintf('TileFigures(1:16,2,2); :\n');
tileFigures(1:16,2,2,[],0.2);
fprintf('press any key to continue...\n');
%pause;
%%
if size(getMonitors(),1) > 1
    fprintf('SpreadFigures; :\n');
    spreadFigures;    
    fprintf('press any key to continue...\n');
    pause;
else
    fprintf('SpreadFigures is ment for a multiple-screens setup, for spreading figures across screens.\n');
    fprintf('For a single-screen setup, use TileFigures.\n');
end
%%
%%
fprintf('SpreadFigures; :\n');
spreadFigures(1:16,2);
fprintf('press any key to continue...\n');
pause;
