% ziDAQ : The LabOne Matlab API for interfacing with Zurich Instruments Devices
%
% FILES
%   bash.env        - Bash environment file
%   Contents.m      - This file
%   README.txt      - A README briefly describing how to get started with ziDAQ
%   ziAddPath.m     - Add the LabOne Matlab API drivers, utilities to Matlab's
%                     Search Path for the current session
%
% DIRECTORIES
%   Driver/    - Contains Matlab driver for interfacing with Zurich Instruments
%                devices
%   Utils/     - Contains some utility functions for common tasks
%
% DRIVER
%   Driver/ziDAQ.m          - ziDAQ command reference documentation.
%   Driver/ziDAQ.mex*       - ziDAQ API driver
%
% EXAMPLES/HF2-MF-UHF/MATLAB - Examples that will run on HF2, MF and UHF devices
%   example_connect                     - A simple example to demonstrate how to
%                                         connect to a Zurich Instruments device
%   example_connect_config              - Connect to and configure a Zurich
%                                         Instruments device
%   example_data_acquisition_continuous - Record data continuously using the
%                                         DAQ Module
%   example_data_acquisition_edge       - Record bursts of demodulator data upon
%                                         a rising edge using the DAQ Module
%   example_data_acquisition_fft        - Record the FFT of demodulator data
%                                         using the DAQ Module
%   example_data_acquisition_grid       - Record bursts of demodulator data
%                                         and align the data in a 2D array.
%   example_data_acquisition_grid_average - Record bursts of demodulator data
%                                         and align and average the data
%                                         row-wise in a 2D array.
%   example_multidevice_data_acquisition - Acquire data from 2 synchronized
%                                         devices using the DAQ Module
%   example_multidevice_sweep           - Perform a sweep on 2 synchronized
%                                         devices using the Sweeper Module
%   example_pid_advisor_pll             - Setup and optimize a PID for internal
%                                         PLL mode
%   example_poll                        - Record demodulator data using
%                                         ziDAQServer's synchronous poll function
%   example_save_device_settings_expert - Save and load device settings
%                                         asynchronously with ziDAQ's
%                                         devicesettings module
%   example_save_device_settings_simple - Save and load device settings
%                                         synchronously using ziDAQ's utility
%                                         functions
%   example_scope                       - Record scope data using ziDAQServer's
%                                         synchronous poll function
%   example_sweeper                     - Perform a frequency sweep using ziDAQ's
%                                         sweep module
%   example_sweeper_rstddev_fixedbw     - Perform a frequency sweep plotting the
%                                         stddev in demodulator output R using
%                                         ziDAQ's sweep module
%   example_sweeper_two_demods          - Perform a frequency sweep saving data
%                                         from 2 demodulators using ziDAQ's sweep
%                                         module
%
% EXAMPLES/HDAWG/MATLAB - Examples specific to the HDAWG Series
%   hdawg_example_awg_commandtable      - Demonstrate how to use the command
%                                         table feature of HDAWG.
%   hdawg_example_awg_grouped_mode      - Demonstrate how to connect to a Zurich
%                                         Instruments HDAWG and run it in grouped mode.
%
% EXAMPLES/HF2/MATLAB - Examples specific to the HF2 Series
%   hf2_example_autorange               - Determine and set an appropriate range
%                                         for a sigin channel
%   hf2_example_pid_advisor_pll         - Setup and optimize a PLL using the PID
%                                         Advisor
%   hf2_example_poll_hardware_trigger   - Poll demodulator data in combination
%                                         with a HW trigger
%   hf2_example_scope                   - Record scope data using ziDAQServer's
%                                         synchronous poll function
%   hf2_example_zsync_poll              - Synchronous demodulator sample timestamps
%                                         from multiple HF2s via the Zsync feature
%
% EXAMPLES/MF/MATLAB - Examples specific to the MF Series
%   example_autoranging_impedance       - Demonstrate how to perform a manually
%                                         triggered autoranging for impedance
%                                         while working in manual range mode
%   example_poll_impedance              - Record impedance data using
%                                         ziDAQServer's synchronous poll function
%
% EXAMPLES/UHF/MATLAB - Examples specific to the UHF Series
%   uhf_example_awg                     - Demonstrate different methods to
%                                         create waveforms and compile and
%                                         upload a SEQC program to the AWG
%   uhf_example_awg_sourcefile          - Demonstrate how to compile/upload a
%                                         SEQC from file.
%   uhf_example_boxcar                  - Record boxcar data using ziDAQServer's
%                                         synchronous poll function
%
% EXAMPLES/SHFLI/MATLAB - Examples specific to the SHFLI Series
%   example_shfli_poll_data             - Demonstrate how to poll data from an
%                                         SHFLI demodulator.
%   example_shfli_sweeper               - Demonstrate how to obtain a Bode plot
%                                         using the Sweeper module for the SHFLI
%                                         Lock-in Amplifier.
%   example_shfli_triggered_data_acquisition  - Demonstrate how to acquire triggered
%                                         demodulator data using the DAQ module for
%                                         the SHFLI Lock-in Amplifier.
%
% EXAMPLES/GHFLI/MATLAB - Examples specific to the GHFLI Series
%   example_ghfli_poll_data             - Demonstrate how to poll data from a
%                                         GHFLI demodulator.
%   example_ghfli_sweeper               - Demonstrate how to obtain a Bode plot
%                                         using the Sweeper module for the GHFLI
%                                         Lock-in Amplifier.
%   example_ghfli_triggered_data_acquisition  - Demonstrate how to acquire triggered
%                                         demodulator data using the DAQ module for
%                                         the GHFLI Lock-in Amplifier.
%
% UTILS
%   ziAPIServerVersionCheck - Check the versions of API and Data Server match
%   ziAutoConnect      - Create a connection to a Zurich Instruments
%                        server (Deprecated: See ziCreateAPISession).
%   ziAutoDetect       - Return the ID of a connected device (if only one
%                        device is connected)
%   ziBW2TC            - Convert demodulator 3dB bandwidth to timeconstant
%   ziCheckPathInData  - Check whether a node is present in data and non-empty
%   ziCreateAPISession - Create an API session for the specified device with
%                        the correct Data Server.
%   ziDevices          - Return a cell array of connected Zurich Instruments
%                        devices
%   ziDisableEverything - Disable all functional units and streaming nodes
%   ziGetDefaultSettingsPath - Get the default settings file path from the
%                        ziDeviceSettings ziCore module
%   ziGetDefaultSigoutMixerChannel - return the default output mixer channel
%   ziLoadSettings     - Load instrument settings from file
%   ziSaveSettings     - Save instrument settings to file
%   ziSiginAutorange   - Activate the device's autorange functionality
%   ziSystemtime2Matlabtime - Convert the LabOne system time to Matlab time
%   ziTC2BW            - Convert demodulator timeconstants to 3 dB Bandwidth
