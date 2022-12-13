/* expansion port library test
 *
 * created: Feb 6, 2013  G. D. Young
 *
 * revised: Feb 10/13 - single-bit objects in, set, setMode
 *
 */


#include <Wire.h>
#include <expPort.h>

#define I2CADDR 0x20
#define PIN11 11
#define PIN15 15


expPort gp11( I2CADDR, PIN11 );  // single pin access
expPort gp15( I2CADDR, PIN15 );  // single pin access

expPort gp( I2CADDR, 0xffff, 0x0000 );  // whole port access

word myport, mydir;
unsigned long timer;

void setup( ) {
  Serial.begin( 9600 );
  gp.begin( );
  gp11.begin( );
  gp15.begin( );
  mydir = gp.getIODIR( );
  myport = gp.getGPIO( );
  Serial.print( "start dir=" );
  Serial.print( mydir, HEX );
  Serial.print( "  port=" );
  Serial.print( myport, HEX );
  gp.setPin( 11, 0 );
//  gp.setPinMode( 11, 0 );
  gp.setIODIR( 0x77ff );
  Serial.print( "  then " );
  myport = gp.getGPIO( );
  Serial.println( myport, HEX );
  timer = millis( ) + 1000;
//  gp11.setMode( 0 );
//  gp15.setMode( 0 );
  gp11.set( 0 );
  gp15.set( !gp11.in( ) );
} // setup


void loop( ) {
  if( timer < millis( ) ) {
    timer += 1000;
    gp11.set( !gp11.in( ) );
    gp15.set( !gp15.in( ) );
    Serial.print( gp15.in( ) );
    Serial.print( " " );
    Serial.println( gp.getPin( 11 ) );
  }
} // loop
