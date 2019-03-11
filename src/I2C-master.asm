init_twi:
	cbi	DDRC,4		; set as inputs
	cbi	DDRC,5
	sbi	PORTC,4		; and turn on pullup resistors
	sbi	PORTC,5

	ldi		r16,193		; setup TWI frequency scaling
	sts		TWBR,r16
	ldi		r16,0x00
	sts		TWSR,r16
	ret
;
; Send TWI start address.
; On return Z flag is set if completed correctly
; r15 and r16 destroyed
sendTWI_Start:
	ldi		r16,(1<<TWINT) | (1<<TWSTA) | (1<<TWEN)
	sts		TWCR,r16

	call	waitTWI

	lds		r16,TWSR
	andi	r16,0xf8		; mask out 
	cpi		r16,0x08		; TWSR = START (0x08)
	ret
;
; Send TWI slave address. Address is in r16
; On return Z flag is set if completed correctly
; r15 and r16 destroyed
sendTWI_SLA:
	sts		TWDR,r16
	ldi		r16,(1<<TWINT) | (1<<TWEN)
	sts		TWCR,r16

	call	waitTWI
	
	lds		r16,TWSR
	andi	r16,0xf8		; mask out 
	cpi		r16,0x18		; TWSR = SLA+W sent, ACK received (0x18)
	ret
;
; Send 8 bits of data as two 4 bit nibbles.
; The data is in r16, the lower 4 bits are in r17
; we assume the TWI operation is waiting for data to be sent.
; r15, r18 and r19 all destroyed
sendTWI_Byte:
	mov		r18,r16
	andi	r18,0xF0
	or		r18,r17
	call	sendTWI_Nibble
	mov		r18,r16
	swap	r18
	andi	r18,0xF0
	or		r18,r17
	call	sendTWI_Nibble
	ret

;
; send 4 bits of data, changing the enable bit as we send it.
; data is in r18. r15, r18 and r19 are destroyed
;
sendTWI_Nibble:
	ori		r18,0x04
	sts		TWDR,r18
	ldi		r19,(1<<TWINT) | (1<<TWEN)
	sts		TWCR,r19

	call	waitTWI			; destroys r15
	
	lds		r19,TWSR
	andi	r19,0xf8		; mask out 
	cpi		r19,0x28		; TWSR = data sent, ACK received (0x28)
	brne	sendTWI_Nibble_exit

	andi	r18,0xFB		; set enable bit low
	
	sts		TWDR,r18
	ldi		r19,(1<<TWINT) | (1<<TWEN)
	sts		TWCR,r19

	call	waitTWI
	
	lds		r19,TWSR
	andi	r19,0xf8		; mask out 
	cpi		r19,0x28		; TWSR = data sent, ACK received (0x28)
sendTWI_Nibble_exit:
	ret

;
;	Send the data pointed to by the Z register to the TWI interface.
;	r25 contains the number of bytes to send
;	r24 contains the address of the I2C controller
;	r17 contains the lower 4 bits of each nibble to send
;
SendTWI_Data:
	call	sendTWI_Start
	brne	serror

	mov		r16,r24			; use this address
	add		r16,r16			; and move over the r/w bit
	call	sendTWI_SLA
	brne	serror

	cpi		r25,0x00		; any bytes left?
	breq	sendTWI_done	; if not all done
	
sendTWI_loop:
	lpm		r16,Z+
	call	sendTWI_Byte
	brne	serror

	dec		r25
	brne	sendTWI_loop

sendTWI_done:
serror:
;
; send stop bit and we're done
;
sendTWI_Stop:
	ldi		r16,(1<<TWINT) | (1<<TWEN) | (1<<TWSTO)		; and send stop
	sts		TWCR,r16
	ldi		r16,0
sendTWI_Delay:
	dec		r16
	brne	sendTWI_Delay
	ret
;
; Wait until the TWI (I2C) interface has sent the byte and received an ack/nak
; destroys r15
;
waitTWI:
	lds	r15,TWCR
	sbrs	r15,TWINT		; wait until transmitted
	rjmp	waitTWI
	ret