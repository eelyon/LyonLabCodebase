#include <string.h>
#include <stdlib.h>

//this following macro is good for debugging, e.g.  print2("myVar= ", myVar);
#define print2(x,y) (Serial.print(x), Serial.println(y))
#define print2d(p1,x,p2,y) (Serial. print(p1), Serial.print(x),Serial.print(p2), Serial.println(y))
#define MAX_RESOLUTION 18 

#define CR '\r'
#define LF '\n'
#define BS '\b'
#define NULLCHAR '\0'
#define SPACE ' '

#ifndef FUNCTIONS_H_INCLUDED
#define FUNCTIONS_H_INCLUDED
  int setDACvoltage(int channel, long int value);  // Function prototype, its declaration
  int setDACvoltageDoor13(int channel, long int value);  // Function prototype, its declaration
  int setDACvoltageDoor15(int channel, long int value);  // Function prototype, its declaration
  double getDACvoltage(int channel);  // Function prototype, its declaration
#endif



#define COMMAND_BUFFER_LENGTH        200                       //length of serial buffer for incoming commands
char   CommandLine[COMMAND_BUFFER_LENGTH + 1];                 //Read commands into this buffer from Serial.  +1 in length for a termination char

int currentchannel;
double newvoltage;
char *commandLineMemory;
const char *delimiters = ", \n:[]";                    //commands can be separated by return, space or comma, :, or []


/*****************************************************************************

  How to Use CommandLine:
    Create a sketch.  Look below for a sample setup and main loop code and copy and paste it in into the new sketch.

   Create a new tab.  (Use the drop down menu (little triangle) on the far right of the Arduino Editor.
   Name the tab CommandLine.h
   Paste this file into it.

  Test:
     Download the sketch you just created to your Arduino as usual and open the Serial Window.  Typey these commands followed by return:
      add 5, 10
      subtract 10, 5

    Look at the add and subtract commands included and then write your own!


*****************************************************************************
  Here's what's going on under the covers
*****************************************************************************
  Simple and Clear Command Line Interpreter

     This file will allow you to type commands into the Serial Window like,
        add 23,599
        blink 5
        playSong Yesterday

     to your sketch running on the Arduino and execute them.

     Implementation note:  This will use C strings as opposed to String Objects based on the assumption that if you need a commandLine interpreter,
     you are probably short on space too and the String object tends to be space inefficient.

   1)  Simple Protocol
         Commands are words and numbers either space or comma spearated
         The first word is the command, each additional word is an argument
         "\n" terminates each command

   2)  Using the C library routine strtok:
       A command is a word separated by spaces or commas.  A word separated by certain characters (like space or comma) is called a token.
       To get tokens one by one, I use the C lib routing strtok (part of C stdlib.h see below how to include it).
           It's part of C language library <string.h> which you can look up online.  Basically you:
              1) pass it a string (and the delimeters you use, i.e. space and comman) and it will return the first token from the string
              2) on subsequent calls, pass it NULL (instead of the string ptr) and it will continue where it left off with the initial string.
        I've written a couple of basic helper routines:
            readNumber: uses strtok and atoi (atoi: ascii to int, again part of C stdlib.h) to return an integer.
              Note that atoi returns an int and if you are using 1 byte ints like uint8_t you'll have to get the lowByte().
            readWord: returns a ptr to a text word

   4)  DoMyCommand: A list of if-then-elses for each command.  You could make this a case statement if all commands were a single char.
      Using a word is more readable.
          For the purposes of this example we have:
              Add
              Subtract
              nullCommand
*/
/******************sample main loop code ************************************

  #include "CommandLine.h"

  void
  setup() {
  Serial.begin(115200);
  }

  void
  loop() {
  bool received = getCommandLineFromSerialPort(CommandLine);      //global CommandLine is defined in CommandLine.h
  if (received) DoMyCommand(CommandLine);
  }

**********************************************************************************/

/*************************************************************************************************************
     your Command Names Here
*/
const char *addCommandToken           = "add";                      //Modify here
const char *subtractCommandToken      = "sub";                      //Modify here
const char *channelCommandToken       = "CH";                       //Used to set channel 
const char *chanreadCommandToken      = "CH?";                      //Used to get channel 
const char *voltageCommandToken       = "VOLT";                     //Used to set voltage
const char *voltreadCommandToken      = "VOLT?";                    //Used to get voltage
const char *testCommandToken          = "TEST";                     //Used to test each DAC channel 
const char *idCommandToken            = "*IDN?";                    //Used to identify device
const char *rampCommandToken          = "RAMP";                     //Used to ramp voltages
const char *zeroCommandToken          = "ZERO";                     //Sets all channels (or specified) to zero voltage
const char *multivoltCommandToken     = "MVOLT";                    //Set multiple channel voltages (for testing)
const char *multivoltreadCommandToken = "MVOLT?";                   //Read multiple channel voltages (for testing)
const char *transferrampCommandToken  = "TRANSFER";                 //Transfer configuration ramp
const char *doorCommandToken          = "DOOR";                     //Open and close the door 

/*************************************************************************************************************
    getCommandLineFromSerialPort()
      Return the string of the next command. Commands are delimited by return"
      Handle BackSpace character
      Make all chars lowercase
*************************************************************************************************************/

bool getCommandLineFromSerialPort(char * commandLine)
{
  static uint8_t charsRead = 0;                      //note: COMMAND_BUFFER_LENGTH must be less than 255 chars long
  //read asynchronously until full command input
  while (Serial.available()) {
    char c = Serial.read();
    switch (c) {
      case CR:      //likely have full command in buffer now, commands are terminated by CR and/or LS
      case LF:
        commandLine[charsRead] = NULLCHAR;       //null terminate our command char array
        if (charsRead > 0)  {
          charsRead = 0;                           //charsRead is static, so have to reset
          //Serial.println(commandLine);
          return true;
        }
        break;
      default:
        // c = tolower(c);
        if (charsRead < COMMAND_BUFFER_LENGTH) {
          commandLine[charsRead++] = c;
        }
        commandLine[charsRead] = NULLCHAR;     //just in case
        break;
    }
  }
  return false;
}


/* ****************************
   readNumber: return a 16bit (for Arduino Uno) signed integer from the command line
   readWord: get a text word from the command line

*/
int readNumber () {
  char * numTextPtr = strtok(NULL, delimiters);         //K&R string.h  pg. 250
  return atoi(numTextPtr);                              //K&R string.h  pg. 251
}

double readFloat () {
  char * numTextPtr = strtok(NULL, delimiters);         //K&R string.h  pg. 250
  return atof(numTextPtr);                              //K&R string.h  pg. 251
}

char * readWord() {
  char * word = strtok(NULL, delimiters);               //K&R string.h  pg. 250
  Serial.println(word); 
  return word;
}

int * readArr(int numVals){                             //Read Array in command line
  int *chArr = new int[numVals]; 
  for(int i = 0; i < numVals; i++){
    chArr[i] = atoi(strtok(NULL,delimiters));
  }
  return chArr;
}

double * readArrdouble(int numVals){                             //Read Array in command line
  double *chArr = new double[numVals]; 
  for(int i = 0; i < numVals; i++){
    chArr[i] = atof(strtok(NULL,delimiters));
  }
  return chArr;
}


void nullCommand(char * ptrToCommandName) {
  print2("Command not found: ", ptrToCommandName);      //see above for macro print2
}



/****************************************************
   Add your commands here
*/

int addCommand() {                                      //Modify here
  int firstOperand = readNumber();
  int secondOperand = readNumber();
  return firstOperand + secondOperand;
}

int subtractCommand() {                                //Modify here
  int firstOperand = readNumber();
  int secondOperand = readNumber();
  return firstOperand - secondOperand;
}

int setchannel() {
  currentchannel = readNumber(); // sets the current channel
  return currentchannel;
}

int setchannelvolt(int voltage, int numChans){
  int * chArr = new int[numChans];              //Sets size of array and fills it with channels
  
  // add conditional here to check voltage value is in range.
  if(voltage > 9.8)
  {
   voltage = 9.8;
  }
  if(voltage < -9.8)
  {
    voltage = -9.8;
  }
  long int value = floor(262143*(voltage+9.8)/19.6); // convert voltage to "DAC code" (see page 21 of datasheet)
  value = value << (20-MAX_RESOLUTION); // bitshift depending on whether we are using the 18 or 20 bit dacs.
  
  for (int i = 0; i < numChans; i++){        
    chArr[i] = i + 1;
  }
  
  for(int i = 0; i < numChans; i++){        //Find voltage for each channel in array
      int currentChannel = chArr[i];
      setDACvoltage(currentChannel,value);
    }
  return currentchannel;
}

int getchannel() {
  return currentchannel;
}

int getchannelvolt(int numChans, int chans){
  if (chans == 0){
    int * chArr = new int[numChans];
    
    for (int i = 0; i < numChans; i++){
      chArr[i] = i + 1;
    }
    for(int i = 0; i < numChans; i++){
        int currentChannel = chArr[i];
        print2d("CH",currentChannel,", V=", getDACvoltage(currentChannel));
      }
    return currentchannel;
  }
  
  else {
    print2d("CH", chans,", V =", getDACvoltage(chans));
      }
    return chans;
  }

int setvoltagecmd() {
  double voltage = readFloat(); // sets the current channel
  if(voltage > 9.8)
  {
   voltage = 9.8;
  }
  if(voltage < -9.8)
  {
    voltage = -9.8;
  }
  long int value = floor(262143*(voltage+9.8)/19.6); // convert voltage to "DAC code" (see page 21 of datasheet)
  value = value << (20-MAX_RESOLUTION); // bitshift depending on whether we are using the 18 or 20 bit dacs.
  setDACvoltage(currentchannel, value);
  return newvoltage;
}

double getvoltagecmd() {
  double voltage = getDACvoltage(currentchannel);
  return voltage;
}

int identvoltagecmd() {
  int numChans = 24;
  double * valueArr = new double[numChans];
  for(int i = 1; i < numChans; i++){
    double voltage = 0.1*i;
    Serial.println(voltage);
    long int value = floor(262143*(voltage+9.8)/19.6); // convert voltage to "DAC code" (see page 21 of datasheet)
    value = value << (20-MAX_RESOLUTION); // bitshift depending on whether we are using the 18 or 20 bit dacs.
    valueArr[i] = value;
    }
     
  for(int i = 1; i < numChans;i++){
    setDACvoltage(i, valueArr[i]);
  }
  return 1;
}


/****************************************************
   DoMyCommand
*/

bool DoMyCommand(char * commandLine) {
  //  print2("\nCommand: ", commandLine);
  int result;
  double resultd;
  commandLineMemory = commandLine;
  
  char * ptrToCommandName = strtok(commandLine, delimiters);
  
  // add command
  if (strcmp(ptrToCommandName, addCommandToken) == 0) 
    {                   //Modify here
    result = addCommand();
    print2(">    The sum is = ", result);
    // subtract command
    } 
  else if (strcmp(ptrToCommandName, subtractCommandToken) == 0) 
    {           //Modify here
      result = subtractCommand();                                       //K&R string.h  pg. 251
      print2(">    The difference is = ", result);
    // change channel command
    } 
  else if (strcmp(ptrToCommandName, channelCommandToken) == 0) {           //Modify here
      result = setchannel();                                       //K&R string.h  pg. 251
      //print2(">   The channel has been set to ", result);
    } 
  else if (strcmp(ptrToCommandName, chanreadCommandToken) == 0) {           //Modify here
      result = getchannel();    
      Serial.println(result);
      //print2(">   The channel has been set to ", result);
    } 
  else if (strcmp(ptrToCommandName, voltageCommandToken) == 0) {           //Modify here
      result = setvoltagecmd();                                  //K&R string.h  pg. 251
    }
  else if (strcmp(ptrToCommandName, voltreadCommandToken) == 0) {           //Modify here
      resultd = getvoltagecmd();                                
      Serial.println(resultd);
    } 
  else if (strcmp(ptrToCommandName, testCommandToken) == 0) {           //Modify here
      result = identvoltagecmd();                                  //K&R string.h  pg. 251
    }
  else if (strcmp(ptrToCommandName, idCommandToken) == 0) {           //Modify here
      Serial.println("AP24");
    }
    
  //RAMP inputs: Number of Steps, number of channels, comma delimited channel list, number of voltages, comma delimited voltage list  
  else if (strcmp(ptrToCommandName, rampCommandToken) == 0) {           
      int numSteps = atoi(strtok(NULL,delimiters));       //Equiv of having readcommand()
      int numChans = atoi(strtok(NULL,delimiters));
      int * chans = readArr(numChans);
      int numVolts = atoi(strtok(NULL,delimiters));
      double * volts = readArrdouble(numVolts);
      
      double * deltaVs = new double[numChans];
      double * startVs = new double[numChans];
      for(int i = 0; i < numChans; i++){
        int currentChannel = chans[i];
        double finalVoltage = volts[i];
        double currentVoltage = getDACvoltage(currentChannel);
        startVs[i] = currentVoltage;
        deltaVs[i] = (finalVoltage - currentVoltage)/numSteps;
        // print2d("CH",currentChannel, ", delV=",deltaVs[i]);
      }
      
      for(int i = 1; i < numSteps+1; i++){
        for(int j = 0; j < numChans; j++){
          int currentChannel = chans[j];
          double currentDelta = deltaVs[j];
          double startVoltage = startVs[j];
          double newV = startVoltage + currentDelta*i;
          
          // add conditional here to check voltage value is in range.
          if(newV > 9.8)
          {
           newV = 9.8;
          }
          if(newV < -9.8)
          {
            newV = -9.8;
          }
          long int value = floor(262143*(newV+9.8)/19.6); // convert voltage to "DAC code" (see page 21 of datasheet)
          value = value << (20-MAX_RESOLUTION); // bitshift depending on whether we are using the 18 or 20 bit dacs.
          setDACvoltage(currentChannel,value);
          
        }
      }
    }

  else if (strcmp(ptrToCommandName, zeroCommandToken) == 0) {
    int numChans = readFloat();
    int volt = 0;
    if (numChans == 0){                        //ZERO for all channels
      int totalChan = 24;
      result = setchannelvolt(volt, totalChan);
    }
    else {                                    //ZERO up to # of channels  
      result = setchannelvolt(volt, numChans);
     }
  }

  else if (strcmp(ptrToCommandName, multivoltCommandToken) == 0){
    int numChans = readFloat();
    int volt = readFloat();
    result = setchannelvolt(volt, numChans);
     }

  else if (strcmp(ptrToCommandName, multivoltreadCommandToken) == 0){
    int numChans = readFloat();
    int * chans = readArr(numChans);
    
    if (numChans == 0){                           //reads voltages of all channels
      int totalChan = 24; 
      result = getchannelvolt(totalChan, 0);
    }
    else if (numChans != 0 and * chans == 0) {                     //reads up to # of channels  
      result = getchannelvolt(numChans, 0);
     }
    else {                                        //reads specific channels
      for(int i = 0; i < numChans; i++){
        int currentChannel = chans[i];
        result = getchannelvolt(numChans, currentChannel);
      }
    }
  }

 else if (strcmp(ptrToCommandName, doorCommandToken) == 0) {  
    int numChans = atoi(strtok(NULL,delimiters));
    int * chans = readArr(numChans);
    int numVolts = atoi(strtok(NULL,delimiters));
    double * volts = readArrdouble(numVolts);
    int numStart = atoi(strtok(NULL,delimiters));
    int * start = readArr(numStart);
    int tauE = atoi(strtok(NULL,delimiters));
    int tauC = atoi(strtok(NULL,delimiters));

    long int * valueArr = new long int[numVolts];
    for(int i = 0; i < numVolts; i++){
      double voltage = volts[i];
      // add conditional here to check voltage value is in range.
      if(voltage > 9.8)
      {
       voltage = 9.8;
      }
      if(voltage < -9.8)
      {
        voltage = -9.8;
      }
      delay(0.1);  // wouldn't work without delay
      long int value = floor(262143*(voltage+9.8)/19.6); // convert voltage to "DAC code" (see page 21 of datasheet)
      value = value << (20-MAX_RESOLUTION); // bitshift depending on whether we are using the 18 or 20 bit dacs.
      valueArr[i] = value;
      }
    
    int stop1 = 0;
    int stop2 = 0;
    int stop3 = 0;
    int stop4 = 0;
    int stop5 = 0;

  
    unsigned long startMicros = micros();  // times are all in microseconds!
    int tick = 0;

    int t1 = tauE;   // end of door 1 pulse
    int t2 = tauC;   // end of door 2 pulse
 
    
    while(tick == 0){ 
      unsigned long currentMicros = micros();
      if ( !stop1 && ((currentMicros-startMicros) > start[0])){
        unsigned long currentMicros = micros();
        setDACvoltageDoor13(13,valueArr[0]); 
        stop1 = 1;                        // this is to stop it after one run!
      }

      if ( !stop2 && ((currentMicros-startMicros) > start[1])){
        unsigned long currentMicros = micros();
        setDACvoltageDoor15(15,valueArr[2]);
        stop2 = 1;                        // this is to stop it after one run!
      }
      
      if ( !stop3 && ((currentMicros-startMicros) > t1) && tauE!=tauC){
        unsigned long currentMicros = micros();
        stop3 = 1;  
        setDACvoltageDoor13(13,valueArr[1]); 
      }
   
      if ( !stop4 && ((currentMicros-startMicros) > t2) && tauE!=tauC){
        unsigned long currentMicros = micros();
        stop4 = 1;  
        setDACvoltageDoor15(15,valueArr[3]); 
        tick = 1;
      }

      if ( !stop5 && ((currentMicros-startMicros) > t1) && tauE == tauC){
        // print2("second end time", currentMicros-startMicros);
        unsigned long currentMicros = micros();
        stop5 = 1;  
        setDACvoltageDoor13(13,volts[1]); 
        setDACvoltageDoor15(15,volts[3]); 
        tick = 1;
      }

      if (tauE > tauC) {
        Serial.println("Error");
        setDACvoltageDoor13(13,volts[1]); 
        setDACvoltageDoor15(15,volts[3]); 
        break; 
     }
     
      if (tick!=0){
        // Serial.println("actually done!");
        break;
      }
      
    }
  }     

  else {
      nullCommand(ptrToCommandName);
    }
}
