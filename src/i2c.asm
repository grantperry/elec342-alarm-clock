i2c_init:
	; cli

	cli DDRD, SDA
	cli DDRD, SCL

	lds r16, PRR
	andi r16, 0b01101111
	sts PRR, r16

	call delay1msec

	; set TWSR(Two Wire Status Register) to 0 to put it in an idle state and 1* divisor
	ldi r16, 0x0
	sts TWSR, r16

	; set TWBR(Two Wire Bit Rate) reg to 0 as this sets the clock to 100kHz
	ldi r16, 0x4A ; 16000000 / (16 + 2 * 73 * 1)
	sts TWBR, r16

	; enable TW and clear the interupt
	ldi r16, (1<<TWINT)|(1<<TWEN)
	sts TWCR, r16

	; _i2c_init_wait:
	; lds r16, TWCR
	; sbrs r16, TWINT ; if TWINT is set continue, else loop back to _wait
	; rjmp _i2c_init_wait

	; sei
	ret


i2c_start:
	; TWCR => Control Register
 	; TWINT => Clear interupt flag
	; TWSTA => put TW into start mode(As in send the start of frame)
	; TWEN => Enable TWI/I2C
	ldi r16, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN) 
	sts TWCR, r16

	_i2c_start_wait:
	lds r16, TWCR
	sts 0x20+PORTD, r16
	lds r16, TWCR
	sbrs r16, TWINT ; if TWINT is set continue, else loop back to _wait
	rjmp _i2c_start_wait

	ldi r16, 0xc0
	sts 0x20+PORTD, r16


	lds r16, TWSR
	andi r16, 0b11111000
	cpi r16, (1<<4) ; 0x08
	breq end ; error if 0x08 is not in the status register

	ret


i2c_stop:
	; TWCR => Control Register
 	; TWINT => Clear interupt flag
	; TWSTA => put TW into STOP mode(As in send the end of frame)
	; TWEN => Enable TWI/I2C
	ldi r16, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN)
	sts TWCR, r16

	; check to make sure no more data is transmitting on the bus
	_check:
	lds r16, TWCR
	andi r16, 0b00010000
	brne _check
	ret



i2c_write:
