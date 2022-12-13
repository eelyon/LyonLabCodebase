#include <SPI.h>
#include "CommandLine.h"


 // Here Define pinout, reset, clr, ldac, and sync pins are shared. the chXsync pins are used as the chip select. i.e. the serial commands go to all DACs on the 8 channel board and we select which chip is supposed to read in the data by toggling the sync pins. 
// board 1: channels 1-8
const int ldac1 = 4;
const int clr1 = 5;
const int rst1 = 6;
const int ch1sync = 7;
const int ch2sync = 8;
const int ch3sync = 9;
const int ch4sync = 10;
const int ch5sync = 11;
const int ch6sync = 12;
const int ch7sync = 13;
const int ch8sync = 22;

const int ldac2 = 37;
const int clr2 = 38;
const int rst2 = 39;
const int ch9sync = 36;
const int ch10sync = 34;
const int ch11sync = 35;
const int ch12sync = 31;
const int ch13sync = 33;
const int ch14sync = 29;
const int ch15sync = 32;
const int ch16sync = 30;

const int ldac3 = 53;
const int clr3 = 52;
const int rst3 = 51;
const int ch17sync = 48;
const int ch18sync = 49;
const int ch19sync = 46;
const int ch20sync = 47;
const int ch21sync = 44;
const int ch22sync = 43;
const int ch23sync = 40;
const int ch24sync = 41;

const int syncpin = 55;

const int clockdivider = 84; // due has 84MHz clock, div by 21 gives 4MHz clock rate which is reasonable
const int syncpinout = 15; // SPI requires a sync pin but the due only allows you to initialize up to 3 devices, so we manually set the sync bit and this syncpinout pin is an unnecessary pin that we will ignore.

#define AD5791_NOP 0 // No operation (NOP).
#define AD5791_REG_DAC 1 // DAC register.
#define AD5791_REG_CTRL 2 // Control register.
#define AD5791_REG_CLR_CODE 3 // Clearcode register.
#define AD5791_CMD_WR_SOFT_CTRL 4 // Software control register(Write only).




// define chip resolution based on the dac type. we will be using the AD5791 and AD5781 chips so feel free to hard-code the resolution. Ultimately we will use the 20-bit dacs, but our first prototype will use the 18 bit dacs since they are more readily available and much cheaper.
typedef enum {
ID_AD5760,
ID_AD5780,
ID_AD5781,
ID_AD5790,
ID_AD5791,
} AD5791_type;
 
struct ad5791_chip_info {
unsigned int resolution;
};
static const struct ad5791_chip_info ad5791_chip_info[] = {
[ID_AD5760] = {
.resolution = 16,
},
[ID_AD5780] = {
.resolution = 18,
},
[ID_AD5781] = {
.resolution = 18,
},
[ID_AD5790] = {
.resolution = 20,
},
[ID_AD5791] = {
.resolution = 20,
}
};
 
AD5791_type act_device;
 
/* Maximum resolution */
#define MAX_RESOLUTION 18 // 20 for AD5791, 18 for AD5781
/* Register Map */
#define AD5791_NOP 0 // No operation (NOP). used when reading values
#define AD5791_REG_DAC 1 // DAC register address.
#define AD5791_REG_CTRL 2 // Control register address.
#define AD5791_REG_CLR_CODE 3 // Clearcode register address.
#define AD5791_CMD_WR_SOFT_CTRL 4 // Software control register (Write only).
/* Input Shift Register bit definition. */
#define AD5791_READ (1ul << 23) // there are 24 bits to a command and if the command starts with a 1 we are reading
#define AD5791_WRITE (0ul << 23) // 24 bit command starts with a 0 so we are writing
#define AD5791_ADDR_REG(x) (((unsigned long)(x) & 0x7) << 20) // send 3 bit address shifted over by 20 bits 0x7 = 0b111
/* Control Register bit Definition */
#define AD5791_CTRL_LINCOMP(x) (((x) & 0xF) << 6) // Linearity error compensation. Our reference span is 20V so we eventually want to send 0b1100
#define AD5791_CTRL_SDODIS (0 << 5) // SDO pin enable/disable control.
#define AD5791_CTRL_BIN2SC (1 << 4) // DAC register coding selection.
#define AD5791_CTRL_DACTRI(x) (((x) & 0xF) << 3)  // DAC tristate control. If in tristate, the dac output is grounded (references are disconnected and there is a 6kOhm resistor to ground)
#define AD5791_CTRL_OPGND (1 << 2) // Output ground clamp control.
#define AD5791_CTRL_RBUF (1 << 1) // Output amplifier configuration control. We have an external amplifier on the board so this should be set to 1.
/* Software Control Register bit definition */
#define AD5791_SOFT_CTRL_RESET (1 << 2) // RESET function.
#define AD5791_SOFT_CTRL_CLR (1 << 1) // CLR function.
#define AD5791_SOFT_CTRL_LDAC (1 << 0) // LDAC function.
/* DAC OUTPUT STATES */
#define AD5791_OUT_NORMAL 0x0
#define AD5791_OUT_CLAMPED_6K 0x1
#define AD5791_OUT_TRISTATE 0x2

 
void setup(){

  Serial.begin(9600); // in the end we won't need serial but it is useful for debugging.
  SPI.begin(syncpinout); // begin SPI
  SPI.setClockDivider(syncpinout, clockdivider); // set clock rate
  SPI.setDataMode(SPI_MODE1); // toggle phase between data bits and clock. should be mode 1 for ADI chips
  SPI.setBitOrder(MSBFIRST); // bit ordering for communication.

 // setup pins
  pinMode(rst1, OUTPUT);
  pinMode(clr1  , OUTPUT);
  pinMode(ldac1 , OUTPUT);
  pinMode(rst2, OUTPUT);
  pinMode(clr2  , OUTPUT);
  pinMode(ldac2 , OUTPUT);
   pinMode(rst3, OUTPUT);
  pinMode(clr3  , OUTPUT);
  pinMode(ldac3 , OUTPUT);
  pinMode(syncpin, OUTPUT);
  pinMode(ch1sync, OUTPUT);
  pinMode(ch2sync, OUTPUT);
  pinMode(ch3sync, OUTPUT);
  pinMode(ch4sync, OUTPUT);
  pinMode(ch5sync, OUTPUT);
  pinMode(ch6sync, OUTPUT);
  pinMode(ch7sync, OUTPUT);
  pinMode(ch8sync, OUTPUT);
  pinMode(ch9sync, OUTPUT);
  pinMode(ch10sync, OUTPUT);
  pinMode(ch11sync, OUTPUT);
  pinMode(ch12sync, OUTPUT);
  pinMode(ch13sync, OUTPUT);
  pinMode(ch14sync, OUTPUT);
  pinMode(ch15sync, OUTPUT);
  pinMode(ch16sync, OUTPUT);
  pinMode(ch17sync, OUTPUT);
  pinMode(ch18sync, OUTPUT);
  pinMode(ch19sync, OUTPUT);
  pinMode(ch20sync, OUTPUT);
  pinMode(ch21sync, OUTPUT);
  pinMode(ch22sync, OUTPUT);
  pinMode(ch23sync, OUTPUT);
  pinMode(ch24sync, OUTPUT);


 // reset dac by toggling /clr and /reset bits leaving them in the HIGH state for programming.
  digitalWrite(ldac1,LOW);
  digitalWrite(clr1,LOW);
  digitalWrite(rst1,LOW);
  digitalWrite(clr1,HIGH);
  digitalWrite(rst1,HIGH);
  digitalWrite(ldac2,LOW);
  digitalWrite(clr2,LOW);
  digitalWrite(rst2,LOW);
  digitalWrite(clr2,HIGH);
  digitalWrite(rst2,HIGH);
  digitalWrite(ldac3,LOW);
  digitalWrite(clr3,LOW);
  digitalWrite(rst3,LOW);
  digitalWrite(clr3,HIGH);
  digitalWrite(rst3,HIGH);


 long oldCtrl = (AD5791_CTRL_LINCOMP(3) | AD5791_CTRL_SDODIS | AD5791_CTRL_BIN2SC | AD5791_CTRL_RBUF | AD5791_OUT_NORMAL); // construct command to send
 // on second iteration of code try parallel programming of dac values. should be as simple as defining a program all function that toggles all of the channel select pins. not sure if there will be problems with current draw.
 long status1 = AD5791_SetRegisterValue(1, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status2 = AD5791_SetRegisterValue(2, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status3 = AD5791_SetRegisterValue(3, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status4 = AD5791_SetRegisterValue(4, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status5 = AD5791_SetRegisterValue(5, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status6 = AD5791_SetRegisterValue(6, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status7 = AD5791_SetRegisterValue(7, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status8 = AD5791_SetRegisterValue(8, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status9 = AD5791_SetRegisterValue(9, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status10 = AD5791_SetRegisterValue(10, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status11 = AD5791_SetRegisterValue(11, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status12 = AD5791_SetRegisterValue(12, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status13 = AD5791_SetRegisterValue(13, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status14 = AD5791_SetRegisterValue(14, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status15 = AD5791_SetRegisterValue(15, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status16 = AD5791_SetRegisterValue(16, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status17 = AD5791_SetRegisterValue(17, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status18 = AD5791_SetRegisterValue(18, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status19 = AD5791_SetRegisterValue(19, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status20 = AD5791_SetRegisterValue(20, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status21 = AD5791_SetRegisterValue(21, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status22 = AD5791_SetRegisterValue(22, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status23 = AD5791_SetRegisterValue(23, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
 delay(10);
 long status24 = AD5791_SetRegisterValue(24, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to tdo this the first time we loop.
delay(10);
 
} 

long AD5791_SetRegisterValue(int channel, unsigned char registerAddress, unsigned long registerValue) {
  unsigned char writeCommand[3] = {0, 0, 0};
  unsigned long spiWord = 0;
  char status = 0;
  int cspin = 0;
  switch (channel)
  {
    case 1:
      cspin = ch1sync;
      break;
    case 2:
      cspin = ch2sync;
      break;
    case 3:
      cspin = ch3sync;
      break;
    case 4:
      cspin = ch4sync;
      break;
    case 5:
      cspin = ch5sync;
      break;
    case 6:
      cspin = ch6sync;
      break;
    case 7:
      cspin = ch7sync;
      break;
    case 8:
      cspin = ch8sync;
      break;
    case 9:
      cspin = ch9sync;
      break;
    case 10:
      cspin = ch10sync;
      break;
    case 11:
      cspin = ch11sync;
      break;
    case 12:
      cspin = ch12sync;
      break;
    case 13:
      cspin = ch13sync;
      break;
    case 14:
      cspin = ch14sync;
      break;
    case 15:
      cspin = ch15sync;
      break;
    case 16:
      cspin = ch16sync;
      break;
    case 17:
      cspin = ch17sync;
      break;
    case 18:
      cspin = ch18sync;
      break;
    case 19:
      cspin = ch19sync;
      break;
    case 20:
      cspin = ch20sync;
      break;
    case 21:
      cspin = ch21sync;
      break;
    case 22:
      cspin = ch22sync;
      break;
    case 23:
      cspin = ch23sync;
      break;
    case 24:
      cspin = ch24sync;
      break;
    }
  spiWord = AD5791_WRITE | AD5791_ADDR_REG(registerAddress) | (registerValue & 0xFFFFF); // write is bitshifted over by 23, address is bitshifter by 20

  writeCommand[0] = (spiWord >> 16) & 0x0000FF;
  writeCommand[1] = (spiWord >> 8 ) & 0x0000FF;
  writeCommand[2] = (spiWord >> 0 ) & 0x0000FF;
  
  
  digitalWrite(cspin,LOW); //Here we manually set the CSpin to address the correct dac.
  status = SPI.transfer(writeCommand[0]);
  status = SPI.transfer(writeCommand[1]);
  status = SPI.transfer(writeCommand[2]);
  digitalWrite(cspin,HIGH); //Here we manually release the CS pin to stop addressing the dac.


  // spiWord = ...
  writeCommand[0] = (spiWord >> 16) & 0x0000FF;
  writeCommand[1] = (spiWord >> 8 ) & 0x0000FF;
  writeCommand[2] = (spiWord >> 0 ) & 0x0000FF;
  
 
  return 0;
}



long AD5791_SetAllRegisterValue(unsigned char registerAddress, unsigned long registerValue) {
  unsigned char writeCommand[3] = {0, 0, 0};
  unsigned long spiWord = 0;
  char status = 0;
  int cspin = 0;
  
  spiWord = AD5791_WRITE | AD5791_ADDR_REG(registerAddress) | (registerValue & 0xFFFFF); // write is bitshifted over by 23, address is bitshifter by 20

  writeCommand[0] = (spiWord >> 16) & 0x0000FF;
  writeCommand[1] = (spiWord >> 8 ) & 0x0000FF;
  writeCommand[2] = (spiWord >> 0 ) & 0x0000FF;
  
  
  digitalWrite(ch1sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch2sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch3sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch4sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch5sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch6sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch7sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch8sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch9sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch10sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch11sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch12sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch13sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch14sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch15sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch16sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch17sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch18sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch19sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch20sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch21sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch22sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch23sync,LOW); //Here we manually set the CSpins
  digitalWrite(ch24sync,LOW); //Here we manually set the CSpins
  
  status = SPI.transfer(writeCommand[0]);
  status = SPI.transfer(writeCommand[1]);
  status = SPI.transfer(writeCommand[2]);
  
  digitalWrite(ch1sync,HIGH);
  digitalWrite(ch2sync,HIGH);
  digitalWrite(ch3sync,HIGH);
  digitalWrite(ch4sync,HIGH);
  digitalWrite(ch5sync,HIGH);
  digitalWrite(ch6sync,HIGH);
  digitalWrite(ch7sync,HIGH);
  digitalWrite(ch8sync,HIGH);
  digitalWrite(ch9sync,HIGH);
  digitalWrite(ch10sync,HIGH);
  digitalWrite(ch11sync,HIGH);
  digitalWrite(ch12sync,HIGH);
  digitalWrite(ch13sync,HIGH);
  digitalWrite(ch14sync,HIGH);
  digitalWrite(ch15sync,HIGH);
  digitalWrite(ch16sync,HIGH);
  digitalWrite(ch17sync,HIGH);
  digitalWrite(ch18sync,HIGH);
  digitalWrite(ch19sync,HIGH);
  digitalWrite(ch20sync,HIGH);
  digitalWrite(ch21sync,HIGH);
  digitalWrite(ch22sync,HIGH);
  digitalWrite(ch23sync,HIGH);
  digitalWrite(ch24sync,HIGH);
  
  return 0;
}


 
long AD5791_GetRegisterValue(int channel, unsigned char registerAddress) {
  unsigned char registerWord[3] = {0, 0, 0};
  unsigned long dataRead = 0x0;
  char status = 0;
  registerWord[0] = (AD5791_READ | AD5791_ADDR_REG(registerAddress)) >> 16;
 
  int cspin=0;
   switch (channel) // should add a function getChanPinFromChan
  {
    case 1:
      cspin = ch1sync;
      break;
    case 2:
      cspin = ch2sync;
      break;
    case 3:
      cspin = ch3sync;
      break;
    case 4:
      cspin = ch4sync;
      break;
    case 5:
      cspin = ch5sync;
      break;
    case 6:
      cspin = ch6sync;
      break;
    case 7:
      cspin = ch7sync;
      break;
    case 8:
      cspin = ch8sync;
      break;
    case 9:
      cspin = ch9sync;
      break;
    case 10:
      cspin = ch10sync;
      break;
    case 11:
      cspin = ch11sync;
      break;
    case 12:
      cspin = ch12sync;
      break;
    case 13:
      cspin = ch13sync;
      break;
    case 14:
      cspin = ch14sync;
      break;
    case 15:
      cspin = ch15sync;
      break;
    case 16:
      cspin = ch16sync;
      break;
    case 17:
      cspin = ch17sync;
      break;
    case 18:
      cspin = ch18sync;
      break;
    case 19:
      cspin = ch19sync;
      break;
    case 20:
      cspin = ch20sync;
      break;
    case 21:
      cspin = ch21sync;
      break;
    case 22:
      cspin = ch22sync;
      break;
    case 23:
      cspin = ch23sync;
      break;
    case 24:
      cspin = ch24sync;
      break;
    }
   
  digitalWrite(cspin,LOW);
  status = SPI.transfer(registerWord[0]);
  status = SPI.transfer(registerWord[1]);
  status = SPI.transfer(registerWord[2]);
  digitalWrite(cspin,HIGH);
 
 
  registerWord[0] = 0x00;
  registerWord[1] = 0x00;
  registerWord[2] = 0x00;
  digitalWrite(cspin,LOW);
  registerWord[0] = SPI.transfer(0x00);
  registerWord[1] = SPI.transfer(0x00);
  registerWord[2] = SPI.transfer(0x00);
  digitalWrite(cspin,HIGH);
  dataRead = ((long)registerWord[0] << 16) |
             ((long)registerWord[1] << 8) |
             ((long)registerWord[2] << 0);
  return dataRead;
}

int initDACS() // initializes dac by setting control register and defining a voltage (currently 0 V, may eventually want to reverse command to set voltage first or init to ground)
{
   int channel = 1;
   for(int channel=1;channel<=24;channel++)
      { // loop over the available channels and set the configure the control register
     
      long oldCtrl = (AD5791_CTRL_LINCOMP(12) | AD5791_CTRL_SDODIS | AD5791_CTRL_BIN2SC | AD5791_CTRL_RBUF | AD5791_OUT_NORMAL); // construct command to send
 
      long status = AD5791_SetRegisterValue(channel, AD5791_REG_CTRL, oldCtrl); // here we set the status register of the dac. In the end we probably just want to do this the first time we loop.
      //Serial.println("initializing");
      //Serial.print(channel);
      double voltage = 0; // choose a voltage to init to, this could also be a trig function, etc.
      long int value = 262143*(voltage+9.8)/19.6; // convert voltage to "DAC code" (see page 21 of datasheet)
      value = value << (20-MAX_RESOLUTION); // bitshift depending on whether we are using the 18 or 20 bit dacs.
      status = AD5791_SetRegisterValue(channel, AD5791_REG_DAC, value); // here is where we set and update value of DAC.
      }
      
    return 0;
}

int setDACvoltage(int channel, double voltage) // initializes dac by setting control register and defining a voltage (currently 0 V, may eventually want to reverse command to set voltage first or init to ground)
{
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
  long status = AD5791_SetRegisterValue(channel, AD5791_REG_DAC, value); // here is where we set and update value of DAC.
  return 0;
}




bool firstloop=1;
void loop() {

//Serial.print("\n");
if(firstloop){
  initDACS();
  //Serial.print("DACs initialized. Please enter a command.");
  firstloop=0;
  setDACvoltage(1, 0);
  delay(10);
  setDACvoltage(2, 0);
  delay(10);
  setDACvoltage(3, 0);
  delay(10);
  setDACvoltage(4, 0);
  delay(10);
  setDACvoltage(5, 0);
  delay(10);
  setDACvoltage(6, 0);
  delay(10);
  setDACvoltage(7, 0);
  delay(10);
  setDACvoltage(8, 0);
  delay(10);
  setDACvoltage(9, 0);
  delay(10);
  setDACvoltage(10, 0);
  delay(10);
  setDACvoltage(11, 0);
  delay(10);
  setDACvoltage(12, 0);
  delay(10);
  setDACvoltage(13, 0);
  delay(10);
  setDACvoltage(14, 0);
  delay(10);
  setDACvoltage(15, 0);
  delay(10);
  setDACvoltage(16, 0);
  delay(10);
  setDACvoltage(17, 0);
  delay(10);
  setDACvoltage(18, 0);
  delay(10);
  setDACvoltage(19, 0);
  delay(10);
  setDACvoltage(20, 0);
  delay(10);
  setDACvoltage(21, 0);
  delay(10);
  setDACvoltage(22, 0);
  delay(10);
  setDACvoltage(23, 0);
  delay(10);
  setDACvoltage(24, 0);
}

bool received = getCommandLineFromSerialPort(CommandLine);      //global CommandLine is defined in CommandLine.h
  if (received) DoMyCommand(CommandLine);
  
}   
// Reading from command line. I should probably make this its own function. later.
//char   CommandLine[26]; // assume command line buffer length = 25 

 


  // setDACvoltage(chanInt, argFl);
