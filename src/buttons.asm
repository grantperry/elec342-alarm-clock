buttons_init:
	; clear : set as input
	cbi DDRD, 0
	cbi DDRD, 1

	; set: set as pull up
	sbi PORTD, 0
	sbi PORTD, 1

	;PIND is the input

	;TODO enable interupts on pin change
	ret