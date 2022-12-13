#include <Wire.h>
int x = 0;
int io_address =  B100000;
int wait_delay = 50;
void setup()
{
 Wire.begin();        // join i2c bus (address optional for master)
 Serial.begin(9600);  // start serial for output
 io_int();
}

void loop()
{
 write_io(6,0);
 write_io(7,0);
 delay(wait_delay);
 write_io(0,0);  // all off
 write_io(1,0);  // all off
 delay(wait_delay);
 
 write_io(0,255);  // all on
 write_io(1,255);  // all on
 delay(wait_delay);
}

void io_int()
 {  
   write_io(6,0),write_io(7,0); // 6 access IO direction 0: Y access to IODIR1
   write_io(0,0),write_io(1,0); // Command 0 gives access to GP0: Command 1 gives access to 1. Writing 0 gives 
} // end of int_io

int read_io(int cmd_reg)
{
int tmp;  
Wire.beginTransmission(io_address);
Wire.write(cmd_reg); // 0 or 1 -- GP0 or GP1
Wire.endTransmission();
Wire.requestFrom(io_address, 1);
tmp=Wire.read();
return tmp;
}  // end of read_io

void write_io(int cmd_reg, int push_this)
{
 Wire.beginTransmission(io_address);
 Wire.write(cmd_reg),Wire.write(push_this); // reset register pointer then set GP0 to push_this // use (0,??)
 Wire.endTransmission();
} // end of write_io
