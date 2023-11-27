function  [ Vtf_true ] = voltageTF(Rad, Vtf)
% calculates the voltage just across the TF transport region
% INPUTs: Vtf = voltage (V) applied across entire TF metal
%         Rad = measured resistances (kohms) between A,D TF gates
%     a ----- b
%         |
%         |
%     c ----- d

    Rtf = Rad*(800/865.122);  % proportionality done by counting # of squares
    Vtf_true = Vtf*(Rtf/Rad);
end