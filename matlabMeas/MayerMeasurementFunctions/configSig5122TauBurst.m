function [] = configSig5122TauBurst(device,channel,tau)
    set5122PulseWidth(device,tau,channel)
    set5122BurstStateOn(device,1,channel);
end

