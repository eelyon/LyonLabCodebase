function [] = zeroAP24( AP24, chan )
    if chan == 0
        query(AP24, 'ZERO') % outputs words not sure why query doesn't fix it, still get things in buffer
    else
        query(AP24, ['ZERO ' num2str(chan)])
    end
end
