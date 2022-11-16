#for calibration report 939801
#CR939801

import numpy as np

#CR939801
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

def k(R):
    return(((np.log10(R) - ZL) - (ZU - np.log10(R))) / (ZU - ZL))

def temp(R):
    return(sum(np.multiply(A, np.cos(np.arange(len(A)) * np.arccos(k(R))))))

print(temp(4200))

'''
Rvec = np.linspace(4000, 5000, num = 100)
Tvec = []

for Rv in Rvec:
    Tvec.append(temp(Rv))

import os
import matplotlib.pyplot as plt
awd = os.getcwd()+'/miscCode/'

plt.plot(Rvec, Tvec)
plt.grid()
plt.xlabel(r"Resitance ($\Omega$)")
plt.ylabel("Temperature (K)")
plt.title("TvR Curve between " + str(np.round(min(Rvec), 2)) +r"$\Omega$ and " + str(np.round(max(Rvec), 2)) + r"$\Omega$")
plt.savefig(awd + "tvr.png", dpi = 500)
#'''