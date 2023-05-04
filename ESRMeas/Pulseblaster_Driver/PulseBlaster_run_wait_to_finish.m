  calllib('spinapi','pb_reset');  % Reset the program to the 1st instruction
  calllib('spinapi','pb_start');  % Trigger the pulse program (= Soft trigger)

  if (itau == 1) 
    disp('PulseBlaster is READY');
%     pause;
    disp('Pulsing now')
  end;
  
  % wait for program to finish
% % %   istatus = calllib('spinapi','pb_read_status');
% % %   while (mod(istatus,2)==0) % read least significant bit (bit 0); if it's a 1, program has finished
% % %     istatus = calllib('spinapi','pb_read_status');
% % %   end;
