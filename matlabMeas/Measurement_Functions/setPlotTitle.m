function setPlotTitle(plotHandle,targetValue, value)
    t = get(plotHandle,'Title');
    switch targetValue
        case 'T'
            set(t,'String',strcat(['Temp= ', num2str(value) 'K']));
        case 'C'
            set(t,'String',strcat(['Cap= ', num2str(value*1e12) 'pF']));
        case 'I'
            set(t,'String',strcat(['Current= ', num2str(value*1e9) 'nA']));
    end
end

