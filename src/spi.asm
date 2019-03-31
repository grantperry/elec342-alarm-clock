spi_init:
	push r16

	ldi r16, 0b00101111 ; set pin directions
	out DDRB, r16
	sbi PORTB, (1<<1) ; and SS back high
	
	ldi r16, (1<<SPE) | (1<<MSTR) ; set master SPI, (SPI mode 0 operation is 00)
	out SPCR, r16 ; SCK is set fosc/4 => 4MHz
	clr r16 ; clear interrupt flags and oscillator mode.
	out SPSR, r16

	pop r16
	ret

;r17 command
;r16 data
;ret r16 
spi_send:
	cbi	PORTB, 2		; Enable device
	push r16
	ldi	r16, 0x40 ; MCP23S17 write
	call spi_send_byte
	mov	r16, r17
	call spi_send_byte
	pop r16
	call spi_send_byte
	sbi	PORTB, 2		; Disable Device
	ret

;r17 command
;r16 data
;ret r16
spi_read:
	cbi	PORTB, 2		; Enable device
	push r16
	ldi r16, 0x41 ; MCP23S17 read
	call spi_send_byte
	mov r16, r17
	call spi_send_byte
	pop r16
	call spi_send_byte
	sbi	PORTB, 2		; Disable Device
	ret

spi_send_byte:
	out	SPDR,r16

	spi_send_byte_wait:
	in r16, SPSR
	sbrs r16, SPIF
	rjmp spi_send_byte_wait
	in r16, SPDR
	ret