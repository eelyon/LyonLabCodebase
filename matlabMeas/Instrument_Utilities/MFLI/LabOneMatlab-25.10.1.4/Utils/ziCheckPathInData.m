function pathExists = ziCheckPathInData(data, path)
% ZICHECKPATHINDATA check whether a node is present in data and non-empty
%
% PATHEXISTS = ZICHECKPATHINDATA(DATA, PATH)
%
% Return true or false, depending whether the PATH from the device node tree
% is present in DATA, where DATA is a structure typically returned by poll()
% or, e.g., sweep.read().
%
% NOTE :
% - Wildcards are not supported.
%
% EXAMPLE :
% ziAutoConnect();
% device = ziAutoDetect();
% path = ['/' device '/demods/0/sample'];
% ziDAQ('unsubscribe', '*');
% ziDAQ('subscribe', path);
% data = ziDAQ('poll', 1.0, 500);
% ziCheckPathInData(data, path) % --> true
% ziCheckPathInData(data, ['/' device '/demods/1/sample']) % --> false

  if nargin < 2
    error('ziCheckPathInData: Two input arguments required, data structure and path (character array).');
  end
  if ~ischar(path)
    error('ziCheckPathInData: Path is not a character array.');
  end
  if path(1) ~= '/'
    error('ziCheckPathInData: The path must start with ''/''.');
  end
  if any(path == '*')
    error('ziCheckPathInData: Wildcards are not supported.');
  end
  path = lower(path);
  validCharacters = isstrprop(path, 'alphanum') | path == '/' | path == '_';
  if ~all(validCharacters)
    error('ziCheckPathInData: Invalid character in path ''%s ''at pos %d', path, find(~validCharacters, 1, 'first'));
  end

% Replace any '/' or '*' that appear more than twice consecutively in path
% with a single instance.
  path = regexprep(path, '/{2, }', '/');
  path = regexprep(path, '*{2, }', '*');

% Split the path into parts.
  matches = strfind(path, '/');
  if path(end) == '/'
    pathParts = cell(length(matches)-1, 1);
  else
    pathParts = cell(length(matches), 1);
    pathParts{end} = path(matches(end)+1:end);
  end
  for i=1:length(matches)-1
    pathParts{i} = path(matches(i)+1:matches(i+1)-1);
  end

  % Note: It is not possible to check for the existence
  % of fields in nested structures, see:
  % http://www.mathworks.com/matlabcentral/answers/103924
  %
  % In order to overcome this the following code creates a string describing
  % the nested struct in DATA, e.g., 'device.demods(1)'. Then we check via
  % eval (unfortunately) whether the current pathPart to process is an index
  % contained in this nested struct or a field of this nested struct.
  %
  % Another method would be to copy the nested struct to a temporary variable
  % that use isfield directly on this. However, this potentially involves
  % copying a large amount of data in every run through the loop. A recursive
  % routine wouldn't help this either.

  if ~isstruct(data)
      pathExists = false;
  end
  subStructString = 'data';

  for i=1:length(pathParts)
    pathPart = pathParts{i};
    if all( isstrprop(pathPart, 'digit'))
      % pathPart is an index branch.
      index = str2double(pathPart) + 1;  % matlab uses 1-based indexing.
      is_in_bounds = eval(['length(' subStructString ') >= ' num2str(index)]);
      if is_in_bounds
        subStructString = [subStructString '(' num2str(index) ')'];
        continue;
      else
        pathExists = false;
        return
      end
    else
      % pathPart is a non-indexed branch. If it exists, it must be a field of the
      % previous pathPart struct.
      is_field = eval(['isfield(' subStructString ', ''' pathPart ''')']);
      if is_field
        is_array = eval(['length(' subStructString ') > 1']);
        if is_array
          % The previous pathPart is indexed, but the current pathPart is not an index
          % e.g. /devP/sigouts/amplitudes (doesn't exist, should be
          % /devP/sigouts{0, 1}/amplitudes)
          pathExists = false;
          return
        end
        subStructString = [subStructString '.' pathPart];
        continue
      else
        pathExists = false;
        return
      end
    end
  end

  % /devP/sigouts/Q/enables/{amplitudes, enables}/R are a special case, the
  % last node is indexed, so they have an additional (artificial) path
  % appended which is called 'value'.
  % If this field is there, set data to be that field for the isempty test.
  is_field = eval(['isfield(' subStructString ', ''value'')']);
  if is_field
    subStructString = [subStructString '.value'];
  end

  % In general, we could be using API Level 4 (or higher) in which case polling
  % int and double nodes return a struct with fields 'value' and 'timestamp'.
  % Again, if this field is there, set data to be that field for the isempty
  % test.
  is_field = eval(['isfield(' subStructString ', ''value'')']);
  if is_field
    subStructString = [subStructString '.value'];
  end

  is_empty = eval(['isempty(' subStructString ')']);
  if is_empty
    pathExists = false;
  else
    pathExists = true;
  end

end
