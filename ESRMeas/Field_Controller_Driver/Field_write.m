function Field_write(B0)

global ER032M;
global B0_center B0_sweep_width B0_wait;

fieldcal = 3103.8/3559.65;
B0_c = B0/fieldcal;
B0_sw = 1; %changed from 1 on 11/4/2022
B0_ss = round(4095/2);

if B0_c < 50
  disp(['B0 < 50, setting B0 to 3500G'])
  B0_c = 3500;
elseif B0_c >9000;
  B0_c = 3500;
end

%B0_SS = round((B0 - B0_center + B0_sweep_width/2) * 4095/B0_sweep_width );
fprintf(ER032M, ['CF' num2str(B0_c)]);
fprintf(ER032M, ['SW' num2str(B0_sw)]);
fprintf(ER032M, ['SS' num2str(B0_ss)]);
pause(B0_wait);
disp(['B0 = ' num2str(B0*fieldcal) ' G']);

% Communicating with instrument object, ERO32M.
% B_current = query(ER032M, 'CF');
