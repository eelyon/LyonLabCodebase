from datetime import datetime

def getDTS():
    return((datetime.now()).strftime("%m-%d-%Y_%Hh%Mm%Ss"))

def stampedName(strIn):
    return(strIn + "__" + getDTS())