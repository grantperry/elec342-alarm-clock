i2c_init:
	cli

	cbi DDRC, 4
	cbi DDRC, 5

	sbi PORTC, 4
	sbi PORTC, 5

	lds r16, PRR
	andi r16, 0b01101111
	sts PRR, r16

	call delay1msec

	; set TWSR(Two Wire Status Register) to 0 to put it in an idle state and 1* divisor
	ldi r16, 0x0
	sts TWSR, r16

	; set TWBR(Two Wire Bit Rate) reg to 0 as this sets the clock to 100kHz
	ldi r16, 0xc1 ; 16000000 / (16 + 2 * 193 * 1)
	sts TWBR, r16

	; enable TW and clear the interupt
	ldi r16, (1<<TWINT)|(1<<TWEN)
	sts TWCR, r16

	; _i2c_init_wait:
	; lds r16, TWCR
	; sbrs r16, TWINT ; if TWINT is set continue, else loop back to _wait
	; rjmp _i2c_init_wait

	sei
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
	sbrs r16, TWINT ; if TWINT is set continue, else loop back to _wait
	rjmp _i2c_start_wait

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

	rcall delay1msec
	ret


i2c_write_SLA:
	rcall i2c_write_byte

	lds		r16,TWSR
	andi	r16,0xf8		; mask out 
	cpi		r16,0x18		; TWSR = SLA+W sent, ACK received (0x18)
	ret


i2c_write_byte:
	sts TWDR, r16
	ldi r16, (1<<TWINT) | (1<<TWEN)
	sts TWCR, r16

	rcall i2c_tansmit_wait
	ret


i2c_tansmit_wait:
	lds r16, TWCR
	sbrs r16, TWINT
	rjmp i2c_tansmit_wait
	ret