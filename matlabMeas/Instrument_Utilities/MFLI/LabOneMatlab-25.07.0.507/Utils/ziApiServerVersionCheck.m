function versionsMatch = ziApiServerVersionCheck()
% ZIAPISERVERVERSIONCHECK check the versions of API and Data Server match
%
% VERSIONSMATCH = ZIAPISERVERVERSIONCHECK()
%
%   Issue a warning and set VERSIONSMATCH to 0 if the release version
%   of the API used in the current session does not have the same
%   release version as the Data Server (that the API is connected
%   to). If the versions match set VERSIONSMATCH to 1.
%
%   From version 25.01, this check is redundant. The compatibility is
%   checked automatically when calling ziDAQ('connect',...).
%
% Copyright 2008-2018 Zurich Instruments AG
%
% See also ZICREATEAPISESSION.

  api_version = ziDAQ('version');
  api_revision = ziDAQ('revision');
  server_version = ziDAQ('getString', '/zi/about/version');
  server_revision = ziDAQ('getInt', '/zi/about/revision');

  if ~strcmp(api_version, server_version)
      message = ['There is a mismatch between the versions of the API ', ...
                 'and Data Server. The API reports version ', api_version, ...
                 ' (revision: ', int2str(api_revision), ') whilst the Data', ...
                 'Server has version ', server_version , ' (revision: ', ...
                 int2str(server_revision), '). See the ``Compatibility'''' ', ...
                 'section in the LabOne Programming Manual for more ', ...
                 'information.'];
      warning(message);
      versionsMatch = 0;
  else
      versionsMatch = 1;
  end

end
