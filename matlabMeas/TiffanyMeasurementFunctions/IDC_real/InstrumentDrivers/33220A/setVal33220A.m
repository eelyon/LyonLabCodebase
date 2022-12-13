function [] = setVal33220A( Filament,Port )

    if strcmp(Port,'LOW')
        fprintf(Filament,['VOLT:LOW' ' ' num2str(Value)]); 
    elseif strcmp(Port,'HIGH')
        fprintf(Filament,['VOLT:HIGH' ' ' num2str(Value)]);
    elseif strcmp(Port,'WIDT')
        fprintf(Filament,['PULS:WIDT' ' ' num2str(Value)]);
    elseif strcmp(Port,'PER')
        fprintf(Filament,['PULS:PER' ' ' num2str(Value)]);
    else 
        fprintf('\nUnknown Port\n')
        errorFlag = -3;
    end
end