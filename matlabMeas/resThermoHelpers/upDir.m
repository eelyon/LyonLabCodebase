function [uwd] = upDir(dir);
    uwdArr = split(dir,'\');
    uwd = 'C:';
    for dirIter = 2:(length(uwdArr) - 1)
        uwd = strcat(uwd, '\', uwdArr{dirIter});
    end
end