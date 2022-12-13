/* expPort.h - header for expPort expansion port library for MCP23016
 *
 * created: Feb 10, 2013 - G. D. Young <jyoung@islandnet.com>
 */


#ifndef expPort_h
#define expPort_h

#include "Arduino.h"
#include "Wire.h"

#define IN 1
#define OUT 0

// class shared state words
static word _iodirState;
static word _gpioState;


class expPort : public TwoWire {

public:

	// constructor - single bit
	expPort( int i2caddr, byte pinNumber );

	// constructor - whole word
	expPort( int i2caddr, word initIODIR, word initGPIO );

	// initial setup
	void begin( void );

	// word access functions
	word getIODIR( void );
	void setIODIR( word iodir );
	word getGPIO( void );
	void setGPIO( word gpioreg );

	// bit access functions
	bool getPin( byte pinNum );
	void setPin( byte pinNum, bool level );

	bool in( );
	void set( bool level );
	void setMode( byte pinMode );

	bool getPinMode( byte pinNum );
	void setPinMode( byte pinNum, byte pinMode );


private:

	int _i2caddr;
	word _pinN;

	const byte iocon = 0x0a;
	const byte iodir = 0x06;
	const byte gpio = 0x00;

	void _begin( void );
	void writei2c( byte portreg, word value );
	word readi2c( byte portreg );

}; // class expPort


#endif

