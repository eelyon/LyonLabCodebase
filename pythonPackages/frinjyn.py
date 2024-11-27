#FRINJYN, V 1.0

#import statements

import math
import numpy as np

def g(d):
    #HELPER FUNCTION: g
    #
    #This function calculates the distnace at which edge depreciaiton
    #starts as a function of distance from the metal.
    #
    #Input(s):
    #-----d: the distance of the electron from the surface of the metal when the
    #        electron is fully over the metal
    #
    #Output:
    #-----g: the distance offset at the edge of the metal at which the voltage and
    #        field felt by the electron 
    #
    
    return(0.94877 * d) #relation found via simulation

def sparter(d):
    #HELPER FUNCTION: sparter
    #
    #This function calculates the distnace at which the reduced voltage is 300.
    #
    #Input(s):
    #-----d: the distance of the electron from the surface of the metal when the
    #        electron is fully over the metal
    #
    #Output:
    #-----the distance at which the reduced voltage is 300 for an input distance
    #
    
    return((np.power(10, 1.9240172)) * np.power(d, 0.66735539)) #relation found via simulation

def frinjer(d, l):
    #FUNCTION: frinjer
    #
    #This function calculates the reduced voltage as a function of position up until a milimeter
    #from the metalic piece in quesiton using a crude series of linear approximations and then
    #multiplies the reduced voltage by the correct distance to obtain the voltage felt by the
    #electron as it transports.
    #
    #This approximation is up to 95% accurate up to length scales of 10 microns and 70% accurate
    #up to length scales of 100 microns.
    #
    #Input(s):
    #-----d: the distance of the electron from the surface of the metal when the
    #        electron is fully over the metal
    #-----l: The length scale of the block in the direction of transport. The block is assumed
    #        to be negligably large in the other directions
    #
    #Outputs:
    #-----span: This function is a vector to match the distance in the transport direction of
    #           the electron to the voltage
    #-----volt: The voltage model calculated for the electron as it transports as a function of
    #           distance
    #
    
    distInterp = []
    fieldInterp = []
    
    #Initializing
    
    #These points initialize the reduced voltage of the electron when directly over the plate
    #in order to set a baseline
    
    distInterp.append(0)
    fieldInterp.append(360)
    
    distInterp.append((l / 2) - g(d))
    fieldInterp.append(360)
    
    #end section-----
    
    #The edge
    
    #The following points take care of the edge effects that happen as the electron just transports
    #off of the metal
    
    distInterp.append((l / 2))
    fieldInterp.append((360 + 2 * 269.70444) / 3)
    
    distInterp.append((l / 2) + g(d))
    fieldInterp.append(269.70444)
    
    distInterp.append((l / 2) + sparter(d))
    fieldInterp.append(300)
    
    #end section-----
    
    #Large-distance interpolation
    
    #The following points take care of the long-distance behavior of the electron field. It should
    #be noted that the approximation here is not the best, but will do for simple calculations. Improvements
    #can be made if necessary.
    
    distInterp.append(1e4 + (l / 2))
    fieldInterp.append((np.power(10, 1.73972)) * np.power(1e4, 0.19031))
    
    distInterp.append(1e6 + (l / 2))
    fieldInterp.append((np.power(10, 1.73972)) * np.power(1e6, 0.19031))
    
    #end section-----
    
    #Interpolation
    
    #The preceeding sections simply put points one the chart as reference points. The following code
    #does simply linear interpolations between those points in order to give more data inbetween each point
    #in the model. This will help when interpolating other distance vectors in order to be worked with more
    #easily.
    
    span = np.linspace(min(distInterp), max(distInterp), num = int(1e6 + (l / 2) + 1))
    field = np.interp(span, distInterp, fieldInterp)
    
    #end section-----
    
    #Voltage divination
    
    #Per some previous investigations, the reduced voltage here is transferred to a regular voltage by
    #multiplication by the position work function.
    
    posWork = np.subtract(span, l / 2)
    posWorkDist = (posWork + abs(posWork)) / 2
    rVec = np.sqrt(np.add(np.square(posWorkDist), np.square(d)))
    
    volt = np.divide(field, rVec)
    
    #end section-----
    
    #Flipping across the axis
    
    #This next part assumes that the piece of metal the electron is transport over is symmetric and will flip
    #the voltage over to the negative side of the metal in order to capture this
    
    backSpan = list(reversed(list(-1 * span[1:-1])))
    backVolt = list(reversed(list(volt[1:-1])))
    
    span = backSpan + list(span)
    volt = backVolt + list(volt)
    
    #end section-----
    
    return(span, volt)

def dataScrapper_ICS(fileName):
    #FUNCTION: dataScrapper_ICS
    #
    #This function imports the ICS data into two arrays for easier usage
    #
    #Input(s):
    #-----fileName: the filename from which to extract the data
    #
    #Outputs:
    #-----pos: This function is a vector to match the distance in the transport direction of
    #          the electron to the voltage from the simulation
    #-----volt: The voltage model calculated for the electron as it transports as a function of
    #           distance from the simulation
    #
    
    ics = open(fileName, "r")
    icsStr = ics.read()
    icsArr = icsStr.split('\n')
    pos = []
    volt = []

    for pair in icsArr[2:-1]:
        splitPair = pair.split('\t')
        pos.append(float(splitPair[0]))
        volt.append(float(splitPair[1]))

    ics.close()
    
    return(pos, volt)

def frinjerData(sweep, d, l):
    #FUNCTION: frinjerData
    #
    #This function imports the ICS data into two arrays and then coalates a model with the simulation.
    #Mostly intended for testiing the model.
    #
    #Input(s):
    #-----sweep: the filename from which to extract the data
    #-----d: the distance of the electron from the surface of the metal when the
    #        electron is fully over the metal
    #-----l: The length scale of the block in the direction of transport. The block is assumed
    #        to be negligably large in the other directions
    #
    #Outputs:
    #-----posReal: This function is a vector to match the distance in the transport direction of
    #              the electron to the voltage from the simulation
    #-----voltReal: The voltage model calculated for the electron as it transports as a function of
    #               distance from the simulation
    #-----posSim: This function is a vector to match the distance in the transport direction of
    #             the electron to the voltage
    #-----voltSim: The voltage model calculated for the electron as it transports as a function of
    #              distance
    #
    
    posReal, voltReal = dataScrapper_ICS(sweep)
    posSim, voltSim = frinjer(d, l)
    voltSim = np.interp(posReal, posSim, voltSim)
    posSim = posReal
    return(posSim, voltSim, posReal, voltReal)

def frinjerPosLine(posReal, d, l):
    #FUNCTION: frinjerPosLine
    #
    #This function imports a position array and then coalates a model with the simulation.
    #
    #Input(s):
    #-----posReal: This function is a vector to match the distance in the transport direction of
    #              the electron to the voltage desired by the user
    #-----d: the distance of the electron from the surface of the metal when the
    #        electron is fully over the metal
    #-----l: The length scale of the block in the direction of transport. The block is assumed
    #        to be negligably large in the other directions
    #
    #Outputs:
    #-----posReal: This function is a vector to match the distance in the transport direction of
    #              the electron to the voltage desired by the user
    #-----posSim: This function is a vector to match the distance in the transport direction of
    #             the electron to the voltage
    #-----voltSim: The voltage model calculated for the electron as it transports as a function of
    #              distance
    #
    
    posSim, voltSim = frinjer(d, l)
    voltSim = np.interp(posReal, posSim, voltSim)
    posSim = posReal
    return(posSim, voltSim, posReal)