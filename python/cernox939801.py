#for calibration report 939801

from python.helpers.cernoxThermom import cernoxThermom

ZL = 2.68491328511
ZU = 3.88972245339
A = [5.649284,
     -6.496949,
     2.795808,
     -0.969290,
     0.271303,
     -0.056705,
     0.005340,
     0.002012,
     -0.001516,
     0.000707]

def cernox939801Thermom():
     return(cernoxThermom(ZL, ZU, A))


