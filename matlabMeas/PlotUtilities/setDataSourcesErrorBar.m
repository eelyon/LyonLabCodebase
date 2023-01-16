function setDataSourcesErrorBar(handle,xName,yName,yError)
% Function links x,y,and yError to a figure graphics handle. See
% setDataSources for list of parameters.
handle.XDataSource = xName;
handle.YDataSource = yName;
handle.YNegativeDeltaSource = yError;
handle.YPositiveDeltaSource = yError;
end