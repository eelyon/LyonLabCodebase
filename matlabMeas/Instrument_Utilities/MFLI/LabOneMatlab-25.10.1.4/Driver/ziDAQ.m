%
% Copyright 2009-2024, Zurich Instruments Ltd, Switzerland
% This software is a preliminary version. Function calls and
% parameters may change without notice.
%
% This version of ziDAQ is linked against:
% * Matlab 7.9.0.529, R2009b, Windows,
% * Matlab 8.4.0.145, R2014b, Linux64.
% You can check which version of Matlab you are using Matlab's `ver` command.
% A list of compatible Matlab and ziDAQ versions is available here:
% www.zhinst.com/labone/compatibility
%
% ziDAQ is an interface for communication with Zurich Instruments Data Servers.
%
% Usage: ziDAQ(command, [option1], [option2])
%        command = 'awgModule', 'clear', 'commitHash', 'connect', 'connectDevice',
%                  'dataAcquisitionModule', 'deviceSettings',
%                  'disconnectDevice', 'discoveryFind', 'discoveryGet',
%                  'finished', 'flush', 'get', 'getAsEvent', 'getAuxInSample',
%                  'getByte', 'getComplex', 'getDIO', 'getDouble', 'getInt',
%                  'getString', 'getSample', 'help', 'impedanceModule',
%                  'listNodes', 'listNodesJSON', 'logOn',
%                  'logOff', 'multiDeviceSyncModule', 'pidAdvisor', 'precompensationAdvisor',
%                  'poll', 'pollEvent', 'programRT', 'progress',
%                  'read', 'record', 'revision', 'setByte', 'setComplex', 'setDouble',
%                  'syncSetDouble', 'setInt', 'syncSetInt', 'setString',
%                  'syncSetString', 'subscribe', 'sweep', 'unsubscribe',
%                  'update', 'version', 'zoomFFT'
%
% Preconditions: ZI Server must be running (check task manager)
%
%            ziDAQ('version');
%                  Returns the version of the API.
%
%            ziDAQ('revision');
%                  Returns the revision of the API.
%
%            ziDAQ('commitHash');
%                  Returns a unique key that identifies the source
%                  code used to build the API.
%
%            ziDAQ('connect', [host = '127.0.0.1'], [port = 8005], [apiLevel = 1], [allowVersionMismatch = 0]);
%                  [host] = Server host string (default is localhost)
%                  [port] = Port number (double)
%                           Use port 8005 to connect to the HF2 Data Server
%                           Use port 8004 to connect to the MF or UHF Data Server
%                  [apiLevel] = Compatibility mode of the API interface (int64)
%                           Use API level 1 to use code written for HF2.
%                           Higher API levels are currently only supported
%                           for MF and UHF devices. To get full functionality for
%                           MF and UHF devices use API level 5.
%                  [allowVersionMismatch] = if this option is set to 1, the 
%                           application will connect to the data-server even if
%                           it is on a different version of LabOne. The default
%                           setting is 0, meaning a version mismatch will result
%                           in an error and prevent the connection.
%                           
%                  To disconnect use 'clear ziDAQ'
%
%   result = ziDAQ('getConnectionAPILevel');
%                  Returns ziAPI level used for the active connection.
%
%   result = ziDAQ('discoveryFind', device);
%                  device (string) = Device address string (e.g. 'UHF-DEV2000')
%                  Return the device ID for a given device address.
%
%   result = ziDAQ('discoveryGet', deviceId);
%                  deviceId (string) = Device id string (e.g. DEV2000)
%                  Return the device properties for a given device id.
%
%            ziDAQ('connectDevice', device, interface);
%                  device (string) = Device serial to connect (e.g. 'DEV2000')
%                  interface (string) = Interface, e.g., 'USB', '1GbE'.
%                  Connect with the data server to a specified device over the
%                  specified interface. The device must be visible to the server.
%                  If the device is already connected the call will be ignored.
%                  The function will block until the device is connected and
%                  the device is ready to use. This method is useful for UHF
%                  devices offering several communication interfaces.
%
%            ziDAQ('disconnectDevice', device);
%                  device (string) = Device serial of device to disconnect.
%                  This function will return immediately. The disconnection of
%                  the device may not yet finished.
%
%   result = ziDAQ('listNodes', path, flags);
%                  path (string) = Node path or partial path, e.g.,
%                           '/dev100/demods/'.
%                  flags (int64) = Define which nodes should be returned, set the
%                          following bits to obtain the described behavior:
%                          int64(0) -> ZI_LIST_NODES_ALL 0x00
%                            The default flag, returning a simple
%                            listing of the given node
%                          int64(1) -> ZI_LIST_NODES_RECURSIVE 0x01
%                            Returns the nodes recursively
%                          int64(2) -> ZI_LIST_NODES_ABSOLUTE 0x02
%                            Returns absolute paths
%                          int64(4) -> ZI_LIST_NODES_LEAVESONLY 0x04
%                            Returns only nodes that are leaves,
%                            which means the they are at the
%                            outermost level of the tree.
%                          int64(8) -> ZI_LIST_NODES_SETTINGSONLY 0x08
%                            Returns only nodes which are marked
%                            as setting
%                          int64(16) -> ZI_LIST_NODES_STREAMINGONLY 0x10
%                            Returns only streaming nodes
%                          int64(32) -> ZI_LIST_NODES_SUBSCRIBEDONLY 0x20
%                            Returns only subscribed nodes
%                  Returns a list of nodes with description found at the specified
%                  path. Flags may also be combined, e.g., set flags to bitor(1, 2)
%                  to return paths recursively and printed as absolute paths.
%
%   result = ziDAQ('listNodesJSON', path, flags);
%                  path (string) = Node path or partial path, e.g.,
%                           '/dev100/demods/'.
%                  flags (int64) = Define which nodes should be returned, set the
%                          following bits to obtain the described behavior.
%                          They are the same as for listNodes(), except that
%                          0x01, 0x02 and 0x04 are enforced:
%                          int64(8) -> ZI_LIST_NODES_SETTINGSONLY 0x08
%                            Returns only nodes which are marked
%                            as setting
%                          int64(16) -> ZI_LIST_NODES_STREAMINGONLY 0x10
%                            Returns only streaming nodes
%                          int64(32) -> ZI_LIST_NODES_SUBSCRIBEDONLY 0x20
%                            Returns only subscribed nodes
%                          int64(64) -> ZI_LIST_NODES_BASECHANNEL 0x40
%                            Return only one instance of a node in case of multiple
%                            channels
%                          int64(128) -> ZI_LIST_NODES_GETONLY 0x80
%                            Return only nodes which can be used with the get
%                            command
%                  Returns a list of nodes with description found at the specified
%                  path as a JSON formatted string. HF2 devices do not support
%                  this functionality. Flags may also be combined, e.g., set flags
%                  to bitor(1, 2) to return paths recursively and printed as
%                  absolute paths.
%
%   result = ziDAQ('help', path);
%                  path (string) = Node path or partial path, e.g.,
%                           '/dev100/demods/'.
%                  Returns a formatted description of the nodes in the supplied path.
%                  Only UHF and MF devices support this functionality.
%
%   result = ziDAQ('getSample', path);
%                  path (string) = Node path
%                  Returns a single demodulator sample (including
%                  DIO and AuxIn). For more efficient data recording
%                  use the subscribe and poll functions.
%
%   result = ziDAQ('getAuxInSample', path);
%                  path (string) = Node path
%                  Returns a single auxin sample. Note, the auxin data
%                  is averaged in contrast to the auxin data embedded
%                  in the demodulator sample.
%
%   result = ziDAQ('getDIO', path);
%                  path (string) = Node path.
%                  Returns a single DIO sample.
%
%   result = ziDAQ('getDouble', path);
%                  path (string) = Node path
%
%   result = ziDAQ('getComplex', path);
%                  path (string) = Node path
%
%   result = ziDAQ('getInt', path);
%                  path (string) = Node path
%
%   result = ziDAQ('getByte', path);
%                  path (string) = Node path
%
%   result = ziDAQ('getString', path);
%                  path (string) = Node path
%
%            ziDAQ('set', values);
%                  path (string) = Node path
%                  values (matrix) = Matrix where every row consists of a path
%                                    and a value. The first column is the path
%                                    and the second column is the value.
%                  Set multiple node values at once in a single transaction.
%                  This is more efficient than calling 'set*' multiple times.
%
%            ziDAQ('setDouble', path, value);
%                  path (string) = Node path
%                  value (double) = Setting value
%
%            ziDAQ('setComplex', path, value);
%                  path (string) = Node path
%                  value (complex double) = Setting value
%
%            ziDAQ('syncSetDouble', path, value);
%                  path (string) = Node path
%                  value (double) = Setting value
%                  Since version 25.04, syncSetDouble and setDouble have the 
%                  same behavior. It is recommended to use setDouble instead of
%                  syncSetDouble.
%
%            ziDAQ('setInt', path, value);
%                  path (string) = Node path
%                  value (int64) = Setting value
%
%            ziDAQ('syncSetInt', path, value);
%                  path (string) = Node path
%                  value (int64) = Setting value
%                  Since version 25.04, syncSetInt and setInt have the 
%                  same behavior. It is recommended to use setInt instead of
%                  syncSetInt.
%
%            ziDAQ('setByte', path, value);
%                  path (string) = Node path
%                  value (byte array) = Setting value
%
%            ziDAQ('setString', path, value);
%                  path (string) = Node path
%                  value (string) = Setting value
%
%            ziDAQ('syncSetString', path, value);
%                  path (string) = Node path
%                  value (string) = Setting value
%                  Since version 25.04, syncSetString and setString have the 
%                  same behavior. It is recommended to use setString instead of
%                  syncSetString.
%
%            ziDAQ('asyncSetString', path, value);
%                  path (string) = Node path
%                  value (string) = Setting value
%
%            ziDAQ('setVector', path, value);
%                  path (string) = Vector node path
%                  value (vector of (u)int8, (u)int16, (u)int32, (u)int64,
%                         float, double; or string) = Setting value
%
%            ziDAQ('subscribe', path);
%                  path (string) = Node path
%                  Subscribe to the specified path to receive streaming data
%                  or setting data if changed. Use either 'poll' command to
%                  obtain the subscribed data.
%
%            ziDAQ('unsubscribe', path);
%                  path (string) = Node path
%                  Unsubscribe from the node paths specified via 'subscribe'.
%                  Use a wildcard ('*') to unsubscribe from all data.
%
%            ziDAQ('getAsEvent', path);
%                  path (string) = Node path. Note: Wildcards and paths referring
%                                  to streaming nodes are not permitted.
%                  Triggers a single event on the path to return the current
%                  value. The result can be fetched with the 'poll' or 'pollEvent'
%                  command.
%
%            ziDAQ('update');
%                  Detect HF2 devices connected to the USB. On Windows this
%                  update is performed automatically.
%
%            ziDAQ('get', path, [flags]);
%                  path (string) = Node path
%                  Gets a structure of the node data from the specified
%                  branch. High-speed streaming nodes (e.g. /devN/demods/0/sample)
%                  are not returned. Wildcards (*) may be used.
%                  Note: Flags are ignored for a path that specifies one or
%                        more leaf nodes.
%                  Specifying flags is mandatory if an empty set would be returned
%                  given the default flags (settingsonly).
%                  [flags] (uint32) = Specify which types of node to include
%                  in the result. Allowed:
%                        ZI_LIST_NODES_SETTINGSONLY = 8 (default)
%                        ZI_LIST_NODES_ALL = 0 (all nodes)
%                        Moreover, all flags supported by listNodes() can be used.
%
%            ziDAQ('flush');
%                  Deprecated, see the 'sync' command.
%                  The flush command is identical to the sync command.
%
%            ziDAQ('echoDevice', device);
%                  Deprecated, see the 'sync' command.
%                  device (string) = device serial, e.g. 'dev100'.
%                  Sends an echo command to a device and blocks until
%                  answer is received. This is useful to flush all
%                  buffers between API and device to enforce that
%                  further code is only executed after the device executed
%                  a previous command.
%
%            ziDAQ('sync');
%                  Synchronize all data paths. Ensures that get and poll
%                  commands return data which was recorded after the
%                  setting changes in front of the sync command. This
%                  sync command replaces the functionality of 'flush', and
%                  'echoDevice' commands.
%
%            ziDAQ('programRT', device, filename);
%                  device (string) = device serial, e.g. 'dev100'.
%                  filename (string) = filename of RT program.
%                  HF2 devices only; writes down a real-time program. Requires
%                  the Real time Option must be available for the specified
%                  HF2 device.
%
%   result = ziDAQ('secondsTimeStamp', [timestamps]);
%                  timestamps (uint64) = vector of uint64 device ticks
%                  Deprecated. In order to convert timestamps to seconds divide the
%                  timestamps by the value of the instrument's clockbase device node,
%                  e.g., /dev99/clockbase.
%                  [Converts a timestamp vector of uint64 ticks
%                  into a double vector of timestamps in seconds (HF2 Series).]
%
% Synchronous Interface
%
%            ziDAQ('poll', duration, timeout, [flags]);
%                  duration (double) = Time in [s] to continuously check for value
%                                      changes in subscribed nodes before
%                                      returning
%                  timeout (int64)   = Poll timeout in [ms]; recommended: 10 ms
%                  [flags] (uint32)  = Flags specifying data polling properties
%                            Bit[0] FILL : Fill data loss holes
%                            Bit[2] THROW : Throw if data loss is detected (only
%                                   possible in combination with DETECT).
%                            Bit[3] DETECT: Just detect data loss holes.
%                  Continuously check for value changes (by calling pollEvent) in
%                  all subscribed nodes for the specified duration and return the
%                  data. If no value change occurs in subscribed nodes before
%                  duration + timeout, poll returns no data. This function call is
%                  blocking (it is synchronous). However, since all value changes
%                  are returned since either subscribing to the node or the last
%                  poll (assuming no buffer overflow has occurred on the Data
%                  Server), this function may be used in a quasi-asynchronous
%                  manner to return data spanning a much longer time than the
%                  specified duration. The timeout parameter is only relevant when
%                  communicating in a slow network. In this case it may be set to
%                  a value larger than the expected round-trip time in the
%                  network.
%
%   result = ziDAQ('pollEvent', timeout);
%                  timeout (int64) = Poll timeout in [ms]
%                  Return the value changes that occurred in one single subscribed
%                  node. This is a low-level function. The poll function is better
%                  suited in nearly all cases.
%
%% LabOne API Modules
% Shared Interface (common for all modules)
%
%   result = ziDAQ('listNodes', handle, path, flags);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  path (string) = Module parameter path
%                  flags (int64) = Define which module parameters paths should be
%                          returned, set the following bits to obtain the
%                          described behaviour:
%                  flags = int64(0) -> ZI_LIST_NODES_ALL 0x00
%                            The default flag, returning a simple
%                            listing of the given path
%                          int64(1) -> ZI_LIST_NODES_RECURSIVE 0x01
%                            Returns the paths recursively
%                          int64(2) -> ZI_LIST_NODES_ABSOLUTE 0x02
%                            Returns absolute paths
%                          int64(4) -> ZI_LIST_NODES_LEAVESONLY 0x04
%                            Returns only paths that are leaves,
%                            which means the they are at the
%                            outermost level of the tree.
%                          int64(8) -> ZI_LIST_NODES_SETTINGSONLY 0x08
%                            Returns only paths which are marked
%                            as setting
%                  Flags may also be combined, e.g., set flags to bitor(1, 2)
%                  to return paths recursively and printed as absolute paths.
%
%   result = ziDAQ('listNodesJSON', handle, path, flags);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  path (string) = Module parameter path
%                  flags (int64) = Define which module parameters paths should be
%                          returned, set the following bits to obtain the
%                          described behaviour:
%                  flags = int64(0) -> ZI_LIST_NODES_ALL 0x00
%                            The default flag, returning a simple
%                            listing of the given path
%                          int64(1) -> ZI_LIST_NODES_RECURSIVE 0x01
%                            Returns the paths recursively
%                          int64(2) -> ZI_LIST_NODES_ABSOLUTE 0x02
%                            Returns absolute paths
%                          int64(4) -> ZI_LIST_NODES_LEAVESONLY 0x04
%                            Returns only paths that are leaves,
%                            which means the they are at the
%                            outermost level of the tree.
%                          int64(8) -> ZI_LIST_NODES_SETTINGSONLY 0x08
%                            Returns only paths which are marked
%                            as setting
%                  Returns a list of nodes with description found at the specified
%                  path as a JSON formatted string. Flags may also be combined.
%
%            ziDAQ('help', handle, [path]);
%                  path (string) = Module parameter path
%                  Returns a formatted description of the nodes in the supplied path.
%
%            ziDAQ('subscribe', handle, path);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  path (string) = Node path to process data received from the
%                           device. Use wildcard ('*') to select all.
%                  Subscribe to device nodes. Call multiple times to
%                  subscribe to multiple node paths. After subscription the
%                  processing can be started with the 'execute'
%                  command. During the processing paths can not be
%                  subscribed or unsubscribed.
%
%            ziDAQ('unsubscribe', handle, path);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  path (string) = Node path to process data received from the
%                           device. Use wildcard ('*') to select all.
%                  Unsubscribe from one or several nodes. During the
%                  processing paths can not be subscribed or
%                  unsubscribed.
%
%            ziDAQ('getInt', handle, path);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  path (string) = Path string of the module parameter. Must
%                           start with the module name.
%                  Get integer module parameter. Wildcards are not supported.
%
%            ziDAQ('getDouble', handle, path);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  path (string) = Path string of the module parameter. Must
%                           start with the module name.
%                  Get floating point double module parameter. Wildcards are not
%                  supported.
%
%            ziDAQ('getString', handle, path);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  path (string) = Path string of the module parameter. Must
%                           start with the module name.
%                  Get string module parameter. Wildcards are not supported.
%
%            ziDAQ('get', handle, path);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  path (string) = Path string of the module parameter. Must
%                           start with the module name.
%                  Get module parameters. Wildcards are supported, e.g. 'sweep/*'.
%
%            ziDAQ('set', handle, path, value);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  path (string) = Path string of the module parameter. Must
%                           start with the module name.
%                  value = The value to set the module parameter to, see the list
%                           of module parameters for the correct type.
%                  Set the specified module parameter value. Use 'help' to learn more
%                  about available parameters.
%
%            ziDAQ('execute', handle);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  Start the module thread. Subscription or unsubscription
%                  is not possible until the module is finished.
%
%   result = ziDAQ('finished', handle);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  Returns 1 if the processing is finished, otherwise 0.
%
%   result = ziDAQ('read', handle);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  Read out the recorded data; transfer the module data to
%                  Matlab.
%
%            ziDAQ('finish', handle);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  Stop executing. The thread may be restarted by
%                  calling 'execute' again.
%
%   result = ziDAQ('progress', handle);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  Report the progress of the measurement with a number
%                  between 0 and 1.
%
%            ziDAQ('clear', handle);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the module class.
%                  Stop the module's thread, Release memory and resources. This
%                  command is especially important if modules are created
%                  repetitively in a while or for loop, in order to prevent
%                  excessive memory and resource consumption.
%
%
%% Sweep Module
%
%   handle = ziDAQ('sweep', timeout);
%                  timeout = Poll timeout in [ms] - DEPRECATED, ignored
%                  Creates a sweep class. The thread is not yet started.
%                  Before the thread start subscribe and set command have
%                  to be called. To start the real measurement use the
%                  execute function.
%
%
%% Device Settings Module
%
%   handle = ziDAQ('deviceSettings', timeout);
%                  timeout = Poll timeout in [ms] - DEPRECATED, ignored
%                  Creates a device settings class for saving/loading device
%                  settings to/from a file. Before starting the module, set the path,
%                  filename and command parameters. To run the command, use the
%                  execute function.
%
%
%% PLL Advisor Module, DEPRECATED (use PID Advisor instead)
%
%   The PLL advisor module for the UHF is removed and fully replaced
%   by the generic PID advisor module for all Zurich Instruments devices.
%
%% PID Advisor Module
%
%   handle = ziDAQ('pidAdvisor', timeout);
%                  timeout = Poll timeout in [ms] - DEPRECATED, ignored
%                  Creates a PID Advisor class for simulating the PID in the
%                  device. Before the thread start, set the command parameters,
%                  call execute() and then set the "calculate" parameter to start
%                  the simulation.
%
%
%% AWG Module
%
%   handle = ziDAQ('awgModule');
%                  Creates an AWG compiler class for compiling the AWG sequence and
%                  pattern downloaded to the device .
%
%
%% Impedance Module
%
%   handle = ziDAQ('impedanceModule');
%                  Creates a impedance class for executing a user compenastion.
%
%
%% Scope Module
%
%   handle = ziDAQ('scopeModule');
%                  handle = Matlab handle (reference) specifying an instance of
%                           the DataAcquisitionModule class.
%                  Create an instance of the Scope Module class
%                  and return a Matlab handle with which to access it.
%
%
%% Multi-Device Sync Module
%
%   handle = ziDAQ('multiDeviceSyncModule');
%                  handle = Matlab handle (reference) specifying an instance of
%                           the DataAcquisitionModule class.
%                  Create an instance of the Multi-Device Sync Module class
%                  and return a Matlab handle with which to access it.
%
%
%% Data Acquisition Module
%
%   handle = ziDAQ('dataAcquisitionModule');
%                  handle = Matlab handle (reference) specifying an instance of
%                           the DataAcquisitionModule class.
%                  Create an instance of the Data Acquisition Module class
%                  and return a Matlab handle with which to access it.
%                  Before the thread can actually be started (via 'execute'):
%                  - the desired data to record must be specified via the module's
%                    'subscribe' command,
%                  - the device serial (e.g., dev100) that will be used must be
%                    set.
%                  The real measurement is started upon calling the 'execute'
%                  function. After that the module will start recording data and
%                  verifying for incoming triggers.
%                  Force a trigger to manually record one duration of the
%                  subscribed data.
%
%
%% Precompensation Advisor Module
%
%   handle = ziDAQ('precompensationAdvisor');
%                  handle = Matlab handle (reference) specifying an instance of
%                           the DataAcquisitionModule class.
%                  Create an instance of the Precompensation Advisor Module class
%                  and return a Matlab handle with which to access it.
%
%
%% Debugging Functions
%
%            ziDAQ('setDebugLevel', debuglevel);
%                  debuglevel (int) = Debug level (trace:0, debug:1, info:2,
%                  status:3, warning:4, error:5, fatal:6).
%                  Enables debug log and sets the debug level.
%
%            ziDAQ('writeDebugLog', severity, message);
%                  severity (int) = Severity (trace:0, debug:1, info:2, status:3,
%                  warning:4, error:5, fatal:6).
%                  message (str) = Message to output to the log.
%                  Outputs message to the debug log (if enabled).
%
%            ziDAQ('logOn', flags, filename, [style]);
%                  flags = LOG_NONE:             0x00000000
%                          LOG_SET_DOUBLE:       0x00000001
%                          LOG_SET_INT:          0x00000002
%                          LOG_SET_BYTE:         0x00000004
%                          LOG_SET_STRING:       0x00000008
%                          LOG_SYNC_SET_DOUBLE:  0x00000010
%                          LOG_SYNC_SET_INT:     0x00000020
%                          LOG_SYNC_SET_BYTE:    0x00000040
%                          LOG_SYNC_SET_STRING:  0x00000080
%                          LOG_GET_DOUBLE:       0x00000100
%                          LOG_GET_INT:          0x00000200
%                          LOG_GET_BYTE:         0x00000400
%                          LOG_GET_STRING:       0x00000800
%                          LOG_GET_DEMOD:        0x00001000
%                          LOG_GET_DIO:          0x00002000
%                          LOG_GET_AUXIN:        0x00004000
%                          LOG_GET_COMPLEX:      0x00008000
%                          LOG_LISTNODES:        0x00010000
%                          LOG_SUBSCRIBE:        0x00020000
%                          LOG_UNSUBSCRIBE:      0x00040000
%                          LOG_GET_AS_EVENT:     0x00080000
%                          LOG_UPDATE:           0x00100000
%                          LOG_POLL_EVENT:       0x00200000
%                          LOG_POLL:             0x00400000
%                          LOG_ALL :             0xffffffff
%                  filename = Log file name
%                  [style] = LOG_STYLE_TELNET:  0
%                            LOG_STYLE_MATLAB:  1 (default)
%                            LOG_STYLE_PYTHON:  2
%                            LOG_STYLE_DOTNET:  3
%                            LOG_STYLE_TOOLKIT: 4
%                  Log all API commands sent to the Data Server. This is useful
%                  for debugging.
%
%            ziDAQ('logOff');
%                  Turn of message logging.
%
%
%% SW Trigger Module (this module will be made deprecated in a future release - new
%  users should use the DAQ Module instead).
%
%   handle = ziDAQ('record' duration, timeout);
%                  duration (double) = The module's internal buffersize to use when
%                                      recording data [s]. The recommended size is
%                                      2*/0/duration parameter. Note that
%                                      this can be modified via the
%                                      buffersize parameter.
%                                      DEPRECATED, set 'buffersize' param instead.
%                  timeout (int64) = Poll timeout [ms]. - DEPRECATED, ignored
%                  Create an instance of the ziDAQRecorder and return a Matlab
%                  handle with which to access it.
%                  Before the thread can actually be started (via 'execute'):
%                  - the desired data to record must be specified via the module's
%                    'subscribe' command,
%                  - the device serial (e.g., dev100) that will be used must be
%                    set.
%                  The real measurement is started upon calling the 'execute'
%                  function. After that the trigger will start recording data and
%                  verifying for incoming triggers.
%
%            ziDAQ('trigger', handle);
%                  handle = Matlab handle (reference) specifying an instance of
%                           the ziDAQRecorder class.
%                  Force a trigger to manually record one duration of the
%                  subscribed data.
%
%
%% Spectrum Module (this module will be made deprecated in a future release - new
%  users should use the DAQ Module instead).
%
%   handle = ziDAQ('zoomFFT', timeout);
%                  timeout = Poll timeout in [ms] - DEPRECATED, ignored
%                  Creates a zoom FFT class. The thread is not yet started.
%                  Before the thread start subscribe and set command have
%                  to be called. To start the real measurement use the
%                  execute function.
%
