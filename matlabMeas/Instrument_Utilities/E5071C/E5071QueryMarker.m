function [ markerVal ] = E5071QueryMarker(ENA,markerNum,xOrY)
% Function returns the x or the y value of a marker numbered by markerNum.
% 
% Arguments
% 
% ENA: TCPIP object that defines the E5071C.
%
% markerNum: integer defining the marker number in question.
%
% xOrY: string value either 'X' or 'Y'. No other values allowed.
  validInput = {'X','Y'};
  if ~any(strcmp(validInput,xOrY))
    fprintf(['Invalid input: ', xOrY, '. Input must be X or Y\n']);
    return
  end
  cmd = [':CALC1:MARK',num2str(markerNum),':',xOrY,'?'];
  markerValArr = str2double(query(ENA,cmd));
  markerVal = markerValArr(1);
end

