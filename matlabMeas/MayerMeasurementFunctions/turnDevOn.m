function [] = turnDevOn(device)
    if strcmp(device.identifier,'33622AA')
        set33622AOutput(device,1,1);
        set33622AOutput(device,2,1);
    elseif strcmp(device.identifier,'33220A')
        set33220Output(device,1);
    end
end

