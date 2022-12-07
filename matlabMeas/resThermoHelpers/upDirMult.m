function [uwd] = upDirMult(dir, num);
    uwd = dir;
    for iter = 1:num
        uwd = upDir(uwd);
    end
end