/* expansion port library example - ring counter
 *
 *
 * created: Feb 11, 2013  G. D. Young
 *
 * revised: Feb 12/13 - add async blink bit
 *
 * Illustrate single-bit i/o - advance an ON bit in a ring around
 * the top 4 bits of the port.
 */


#include <Wire.h>
#include <expPort.h>

#define I2CADDR 0x20
#define BIT7 7
#define BIT12 12
#define BIT13 13
#define BIT14 14
#define BIT15 15

#define ON 0
#define OFF 1

// create an object for each bit
expPort gp7( I2CADDR, BIT7 );  // single pin access
expPort gp12( I2CADDR, BIT12 );  // single pin access
expPort gp13( I2CADDR, BIT13 );  // single pin access
expPort gp14( I2CADDR, BIT14 );  // single pin access
expPort gp15( I2CADDR, BIT15 );  // single pin access

// use word access to display whole port word on serial output
expPort gp( I2CADDR, 0xffff, 0x0000 ); // word access object

unsigned long timer, timer2;
word myport;

void setup( ) {
  Serial.begin( 9600 );
  gp7.begin( );
  gp12.begin( );
  gp13.begin( );
  gp14.begin( );
  gp15.begin( );
  gp7.setMode( OUT );
  gp12.setMode( OUT );
  gp13.setMode( OUT );
  gp14.setMode( OUT );
  gp15.setMode( OUT );
  gp12.set( ON );
  gp13.set( OFF );
  gp14.set( OFF );
  gp15.set( OFF );
  myport = gp.getGPIO( );
  Serial.print( "Start.  port=" );
  Serial.println( myport, HEX );
  timer = millis( ) + 1000;
  timer2 = millis( ) + 373;
} // setup

bool lastgp15;

void loop( ) {
  
  if( timer < millis( ) ) {
    timer += 1000;
    lastgp15 = gp15.in( );
    gp15.set( gp14.in( ) );
    gp14.set( gp13.in( ) );
    gp13.set( gp12.in( ) );
    gp12.set( lastgp15 );
    myport = gp.getGPIO( );
    Serial.print( "        port=" );
    Serial.println( myport, HEX );
  } // if timer
  
  if( timer2 < millis( ) ) {
    timer2 += 373;
    gp7.set( !gp7.in( ) );    // blink bit 7
  } // if timer2
  
} // loop
