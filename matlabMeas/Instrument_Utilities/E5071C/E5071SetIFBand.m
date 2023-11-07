function [] = E5071SetIFBand(ENA,IFBandInKHz)
 command = [':SENS1:BAND ',num2str(IFBandInKHz*1000)];
 fprintf(ENA,command);
end