HEMT1Channels = [0,1,2];    
%turnOnHEMT(hDAC,HEMT1Channels,2.2)
turnOffHEMT(hDAC,HEMT1Channels)

function [] = turnOnHEMT(DAC,channels,endVoltage)
    VtomV = 1e3;
    Vg_voltages = [0.3,0.5];
    for i = Vg_voltages
        for j = channels
            SetDAC(DAC,j,i*VtomV)
        end
    end
    
    Vbias_voltages = 0.6:0.2:2;
    for i = Vbias_voltages
        for j = channels(2:3)
            SetDAC(DAC,j,i*VtomV)
        end
    end
    SetDAC(DAC,channels(end),endVoltage*VtomV)
end


function []= turnOffHEMT(DAC,channels)
    VtomV = 1e3;
    SetDAC(DAC,channels(end),2*VtomV)
    Vbias_voltages = 2:-0.2:0.6;
    for i = Vbias_voltages
        for j = channels(2:3)
            SetDAC(DAC,j,i*VtomV)
        end
    end
    Vg_voltages = [0.5,0.3,0];
    for i = Vg_voltages
        for j = channels
            SetDAC(DAC,j,i*VtomV)
        end
    end
end