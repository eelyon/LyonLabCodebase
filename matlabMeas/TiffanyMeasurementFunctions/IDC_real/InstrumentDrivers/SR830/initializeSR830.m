function [ SR830 ] = initializeSR830(remoteHost)
    SR830 = connectInstrumentTCPIP(remoteHost);
end