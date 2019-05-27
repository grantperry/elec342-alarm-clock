buttons_init:
	; clear: set as input
	cbi DDRD, 2
	cbi DDRD, 3
	cbi DDRD, 4

	; set: set as pull up
	sbi PORTD, 2
	sbi PORTD, 3
	sbi PORTD, 4

	cli

	ldi r16, (1<<PCIE2)
	sts PCICR, r16
	
	; pin change mask.
	ldi r16, (1<<PCINT18)|(1<<PCINT19)|(1<<PCINT20)
	sts PCMSK2, r16


	sei ; enable interrupts globally

	;PIND is the input

	;TODO enable interupts on pin change
	ret

PCINT2_BUTTONS:
	push r16
	push r17
	rcall button_check_reg
	mov r17, r16
	rcall getButtons
	cp r16, r17
	breq buttons_no_change

	clr r16
	rcall setButtonsCount
	clr r16
	rcall setButtonsStable

	mov r16, r17
	rcall setButtons

	buttons_no_change:

	pop r17
	pop r16
	reti

button_check_reg:
	push r17
	in r16, PIND
	ldi r17, (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)
	eor r16, r17
	lsr r16
	lsr r16
	pop r17
	ret

button_debounce:
	push r16
	rcall getButtons
	tst r16
	breq button_debounce_no_button

	push r16
	rcall getButtonsCount
	cpi r16, 2 ; 3 timer loops of debounce
	pop r16
	brlo button_debounce_early

	push r16

	rcall getButtonsStable
	cpi r16, 1
	pop r16
	breq button_previously_actioned

	rcall button_multiplex

	ldi r16, 0x1
	rcall setButtonsStable
	
	button_previously_actioned:
	button_debounce_early:
	button_debounce_no_button:
	rcall getButtonsCount
	inc r16
	rcall setButtonsCount

	pop r16
	ret

button_multiplex:
	push r16

	rcall getAlarmCounter
	tst r16 ; test if the alarm is currently active

	; do this after we have tested if the alarm was active or not so we can test correcly.
	rcall button_multiplex_all ; always do these actions when any button is pressed.

	brne button_multiplex_not_alarm ; if alarm active, skip all other button actions

	rcall getDisplaySelect
	cpi r16, (1<<0) ; clock
	brne button_multiplex_not_clock

	pop r16
	rcall button_multiplex_clock
	rjmp button_multiplex_end

	button_multiplex_not_clock:
	cpi r16, (1<<1); alarm
	brne button_multiplex_not_alarm

	pop r16
	rcall button_multiplex_alarm
	rjmp button_multiplex_end

	button_multiplex_not_alarm:
	pop r16 ; pop this off it it was none of the above.

	button_multiplex_end:
	ret


button_multiplex_clock:
	rcall button_clock_actions
	ret

button_multiplex_alarm:
	rcall button_alarm_actions
	ret

button_multiplex_all:
	rcall button_always_actions
	ret