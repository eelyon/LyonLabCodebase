function [] = displayFig(date,figName)
    % Displays a figure from a certain date in the /Data path.
    % Inputs:
    %         date - character string with a MM_DD_YY format.
    %         figName - name of figure to plot in the date path (without
    %         the .fig extension).
    dataPath = getDataPath();
    figName = [figName '.fig'];
    dataPath = fullfile(dataPath,date);
    figPath = fullfile(dataPath,figName);
    if exist(figPath,"file")
        openfig(figPath);
    else
        msg = [figPath ' is not a valid path. Cannot open file.'];
        error(msg)
    end
end