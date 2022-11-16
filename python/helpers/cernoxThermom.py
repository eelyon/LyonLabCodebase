import numpy as np

class cernoxThermom:
     def __init__(self, ZL, ZU, A):
          self.ZL = ZL
          self.ZU = ZU
          self.A = A

     def k(self, R):
          return(((np.log10(R) - self.ZL) - (self.ZU - np.log10(R))) / (self.ZU - self.ZL))

     def temp(self, R):
          return(sum(np.multiply(self.A, np.cos(np.arange(len(self.A)) * np.arccos(self.k(R))))))