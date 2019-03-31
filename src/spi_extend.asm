spi_extend_init:
	push r16
	push r17
	; init RegA as outputs
	ldi r17, 0x00
	ldi r16, 0x00
	rcall spi_send

	;pull up some Breg pins
	ldi r17, 0x0D
	ldi r16, 0xFF ; only pull up GPB0
	rcall spi_send

	ldi r17, 0x14
	ldi r16, 0x00 ; clear all Areg Leds
	rcall spi_send

	pop r17
	pop r16
	ret

setLED:
	push r16
	push r17
	ldi r17, 0x14
	ldi r16, (1<<7) ; only set the A7 LED
	rcall spi_send
	pop r17
	pop r16
	ret

clearLED:
	push r16
	push r17
	ldi r17, 0x14
	ldi r16, 0x00 ; clear all Areg Leds
	rcall spi_send
	pop r17
	pop r16
	ret	

getButtons:
	push r17
	ldi r17, 0x13 ; read the Breg inputs
	rcall spi_read
	pop r17
	ret