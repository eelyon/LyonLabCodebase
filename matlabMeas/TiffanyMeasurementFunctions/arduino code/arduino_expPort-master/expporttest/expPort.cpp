#include "Arduino.h"
#include "expPort.h"


// constructor - whole port
expPort::expPort( int i2caddr, word initIODIR, word initGPIO ) {
    _iodirState = initIODIR;
	_gpioState = initGPIO;
	_i2caddr = i2caddr;
} // constructor

// constructor - individual pin
	expPort::expPort( int i2caddr, byte pinNumber ) {
    _iodirState = 0xffff;     // use port power-up initialization values
	_gpioState = 0x0000;
	_i2caddr = i2caddr;
	_pinN = 0x0001<<pinNumber;
} // pin constructor

void expPort::begin( ) {
	TwoWire::begin( );
	_begin( );
} // begin


// word access functions

word expPort::getIODIR( void ) {
	return _iodirState;
} // getIODIR

word expPort::getGPIO( void ) {
	_gpioState = expPort::readi2c( gpio );
	return _gpioState;
} // getGPIO

void expPort::setIODIR( word iodirreg ) {
	_iodirState = iodirreg;
	writei2c( iodir, _iodirState );
} // setIODIR

void expPort::setGPIO( word gpioreg ) {
	_gpioState = gpioreg;
	writei2c( gpio, _gpioState );
} // setGPIO


// bit access functions
bool expPort::getPin( byte pinNum ) {
	_gpioState = expPort::readi2c( gpio );
	word pin = 0x0001<<pinNum;
	if( pin & _gpioState ) {
		return 1;
	} else {
		return 0;
	}
} // getPin - whole port


bool expPort::in( ) {
	_gpioState = expPort::readi2c( gpio );
	if( _pinN & _gpioState ) {
		return 1;
	} else {
		return 0;
	}
} // getPin - individual


void expPort::setPin( byte pinNum, bool level ) {
	word pin = 0x0001<<pinNum;
	if( level ) {
		_gpioState |= pin;
	} else {
		_gpioState &= ~pin;
	}
	writei2c( gpio, _gpioState );
} // setPin

void expPort::set( bool level ) {
	if( level ) {
		_gpioState |= _pinN;
	} else {
		_gpioState &= ~_pinN;
	}
	writei2c( gpio, _gpioState );
} // set - single pin


bool expPort::getPinMode( byte pinNum ) {
	word pin = 0x0001<<pinNum;
	if( pin & _iodirState ) {
		return 1;
	} else {
		return 0;
	}
} // getPinMode

void expPort::setPinMode( byte pinNum, byte pinMode ) {
	word pin = 0x0001<<pinNum;
	if( pinMode ) {
		_iodirState |= pin;
	} else {
		_iodirState &= ~pin;
	}
	writei2c( iodir, _iodirState );
} // setPinMode

void expPort::setMode( byte pinMode ) {
	if( pinMode ) {
		_iodirState |= _pinN;
	} else {
		_iodirState &= ~_pinN;
	}
	writei2c( iodir, _iodirState );
} // setMode


// Initialize MCP23016
// MCP23016 byte registers act in word pairs

void expPort::_begin( void ) {
	TwoWire::beginTransmission( _i2caddr );
	TwoWire::write( iocon ); // set fast mode
	TwoWire::write( 0x01 );
	TwoWire::endTransmission( );
	TwoWire::beginTransmission( _i2caddr );
	TwoWire::write( iodir ); // setup port direction - all inputs to start
	TwoWire::write( lowByte( _iodirState ) );
	TwoWire::write( highByte( _iodirState ) );
	TwoWire::endTransmission( );
	TwoWire::beginTransmission( _i2caddr );
	TwoWire::write( gpio );	//point register pointer to gpio reg
	TwoWire::write( lowByte( _gpioState ) ); // set o/p latch to init values
	TwoWire::write( highByte( _gpioState ) );
	TwoWire::endTransmission( );
} // _begin( )

void expPort::writei2c( byte portreg, word value ) {
	TwoWire::beginTransmission( _i2caddr );
	TwoWire::write( portreg );
	TwoWire::write( lowByte( value ) );
	TwoWire::write( highByte( value ) );
	TwoWire::endTransmission();
	if( portreg == iodir ) {
		_iodirState = value;
		TwoWire::beginTransmission( _i2caddr );	// reset adr pointer to gpio
		TwoWire::write( gpio );
		TwoWire::endTransmission();
	} // if write to direction reg
} // writei2c


word expPort::readi2c( byte portreg ) {
	if( portreg == iodir ) {
		return _iodirState;
	} else {
		TwoWire::requestFrom( _i2caddr, 2 );
		_gpioState = 0;
		_gpioState = TwoWire::read( );
		_gpioState |= (TwoWire::read( )<<8);
		return _gpioState;
	} // if iodir don't read, gpio read
} // read i2c



