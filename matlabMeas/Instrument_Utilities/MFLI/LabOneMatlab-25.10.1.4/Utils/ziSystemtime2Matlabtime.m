function matlabtime = ziSystemtime2Matlabtime(systemtime)
% ziSystemtime2Matlabtime convert the LabOne systemtime to Matlab time
%
% matlabtime = ziSystemtime2Matlabtime(systemtime)
%
%  Convert the LabOne data header systemtime field (UINT64,
%  microseconds since unix epoch) to a Matlab serial date number.
%
%   Example:
%
%      datestr(ziSystemtime2Matlabtime(1501843049172000), 'yyyy-mm-dd HH:MM:SS.FFF')

  % https://ch.mathworks.com/matlabcentral/newsreader/view_thread/163194
  matlabtime = (systemtime / 86.4e9) + 719529;

end
