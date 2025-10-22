LabOne MATLAB Driver and Utilities
© Zurich Instruments AG

This folder contains the necessary files to perform measurements with your
Zurich Instruments device under MATLAB. It contains the following
subfolders and files:

- "README.txt", this file
- "bash.env", Bash environment file
- "Contents.m", a MATLAB script showing the driver's contents
- "ziAddPath.m", a MATLAB function that adds the "Driver" and "Utils"
  subdirectories to MATLAB's Search Path for the current MATLAB session
- "Driver", a subfolder containing the MATLAB driver interface (MEX file)
   and the help file "ziDAQ.m"
- "Utils", a subfolder containing some ziDAQ-based utility functions
- "Examples", a subfolder containing many example functions and scripts

* Requirements

For supported platforms please see:
- https://www.zhinst.com/labone/compatibility

* Accessing the examples

The Examples for the MATLAB API can be found in our public GitHub repository,
https://github.com/zhinst/labone-api-examples. For convenience, the examples are
also included with the installer and can be found in the "Examples" subfolder.

* Getting help

You may use "help ziDAQ" or "doc ziDAQ" in MATLAB Command Prompt to get more 
information on the commands.

Please refer to the LabOne API User Manual for more information, it is
available at:
- https://docs.zhinst.com/labone_api_user_manual/
