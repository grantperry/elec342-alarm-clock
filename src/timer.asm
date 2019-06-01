timer_setup0:
	cli

	sbi DDRD,6
	sbi DDRD,5
	; cBI DDRD,6

	; sbi PORTD, 6
	cbi PORTD, 6
	cbi PORTD, 5


	;
	; configure timer 1:
	; count to OCR1A and reset,
	; toggle OCR1A output on reset,
	; frequency using /8 prescaler
	;
	; rcall timer_enable0A
	ldi	r16,0b00001100	; [-,-,-,-,WGM02,CS02,-,-]
	out	TCCR0B,r16			; SET PRESCALER/DIVIDER TO /256 
	ldi	r16,0b00000000	; interrupt enabled when OCA match (and other interrupts)
	sts	TIMSK0,r16

	;
	; The counter is now running at 16,000,000 HZ / 8
	; = 2,000,000 ticks per second, 1,000,000 cycles per second
	; To calculate the tone frequency
	; num = 1,000,000 / frequency
	; for 100Hz...
	;	1000000/100 = 10000
	ldi r16, 71
	rcall timer_set0A
	; ldi r16, 18
	; out	OCR0B,r16

	; ldi r25, 0x9
	; rcall LCD_Position
	; rcall LCD_Number

	sei
	ret

timer_enable0A:
	push r16
	ldi	r16,0b01000011	; [-,COMP0A0,-,-,-,-,WGM01,WGM00]
	out	TCCR0A,r16			; SET TO FAST PWM MODE 7
	pop r16
	ret

timer_disable0A:
	push r16
	ldi	r16,0b00000011	; [-,COMP0A0,-,-,-,-,WGM01,WGM00]
	out	TCCR0A,r16			; SET TO FAST PWM MODE 7
	pop r16
	ret

timer_set0A:
	out	OCR0A,r16
	ret


timer_setup1:
	cli

	;
	; configure timer 1:
	; count to OCR1A and reset,
	; toggle OCR1A output on reset,
	; frequency using /8 prescaler
	;
	; this toggle the physical output pin as well cause why not. good for debug on timing.
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

TIM0_COMPA:
	; rcall LCD_Number
	reti

TIM1_COMPA:
	rcall increment_sub

	push r16
	rcall get_timer_sub
	cpi r16, 100
	brlo sub_sec_100_end

	rcall sub_sec_100

	sub_sec_100_end:

	ldi r17, 50 ; divisor
	; r16 subject of division
	rcall get_timer_sub
	rcall div8u
	tst r15
	brne sub_sec_50_end

	rcall sub_sec_rep_25

	sub_sec_50_end:

	ldi r17, 10 ; divisor
	; r16 subject of division
	rcall get_timer_sub
	rcall div8u
	tst r15
	brne sub_sec_10_end

	rcall sub_sec_rep_10

	sub_sec_10_end:

	ldi r17, 2 ; divisor
	; r16 subject of division
	rcall get_timer_sub
	rcall div8u
	tst r15
	brne sub_sec_2_end

	rcall sub_sec_rep_02

	sub_sec_2_end:

	rjmp TIM1_COMPA_end

;run on the second once a second
sub_sec_100:
	clr r16
	rcall set_timer_sub
	
	;this must always happen
	rcall logic_clock

	rcall logic_alarm

	rcall alarm_runtime_logic
	
	ret

sub_sec_rep_25: ; called 4 times a second
	rcall screen_flash
	; rcall logic_clock
	rcall display_update
	ret

sub_sec_rep_10: ; called 10 times a second
	ret

sub_sec_rep_02:
	rcall button_debounce
	rcall alarm_remote_button

	ret

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