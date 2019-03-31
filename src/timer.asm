timer_enable:
	cli

	;
	; configure timer 1:
	; count to OCR1A and reset,
	; toggle OCR1A output on reset,
	; frequency using /8 prescaler
	;
	ldi	r16,0b01000000	; port A toggle, port B normal, WGRM=0100
	sts	TCCR1A,r16
	ldi	r16,0b00001100	; noise = 0, WGRM=1000, clk = /8
	sts	TCCR1B,r16
	ldi	r16,0b00000101
	sts	TCCR1C,r16
	ori	r18,0b00000010	; interrupt enabled when OCA match (and other interrupts)
	sts	TIMSK1,r18

	;
	; The counter is now running at 16,000,000 HZ / 8
	; = 2,000,000 ticks per second, 1,000,000 cycles per second
	; To calculate the tone frequency
	; num = 1,000,000 / frequency
	; for 100Hz...
	;	1000000/100 = 10000
	ldi	r17,HIGH(625)	; set counter to 10000
	ldi	r16,LOW(625)
	sts	OCR1AH,r17
	sts	OCR1AL,r16

	sei
	ret

TIM1_COMPA:
	rcall increment_sub

	push r16
	rcall get_timer_sub
	cpi r16, 100
	brge sub_sec_100
	; cpi r16, 50
	; brge sub_sec_50
	rjmp TIM1_COMPA_end

	;run on the second once a second
	sub_sec_100:
	clr r16
	rcall set_timer_sub
	
	rcall logic_clock
	
	rcall print_time
	rcall print_date
	rjmp TIM1_COMPA_end

	TIM1_COMPA_end:
	pop r16
	reti

increment_sub:
	push r16
	rcall get_timer_sub
	inc r16
	rcall set_timer_sub
	pop r16
	ret

get_timer_sub:
	push ZL
	push ZH
	ldi		ZL,LOW(SUB_INT_DIV*2)
	ldi		ZH,HIGH(SUB_INT_DIV*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

set_timer_sub:
	push ZL
	push ZH
	ldi		ZL,LOW(SUB_INT_DIV*2)
	ldi		ZH,HIGH(SUB_INT_DIV*2)
	st z, r16
	pop ZH
	pop ZL
	ret