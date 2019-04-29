buttons_init:
	; clear: set as input
	cbi DDRD, 2
	cbi DDRD, 3

	; set: set as pull up
	sbi PORTD, 2
	sbi PORTD, 3

	cli

	ldi r16, (1<<PCIE2)
	sts PCICR, r16
	
	ldi r16, (1<<PCINT18)|(1<<PCINT19)
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
	ldi r17, (1<<2)|(1<<3)|(1<<1)|(1<<0)
	eor r16, r17
	lsr r16
	lsr r16, 32
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

	rcall button_actions

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

button_actions:
	cpi r16, 0x3
	breq button_action_invalid
	cpi r16, 0x2
	breq button_action_select
	cpi r16, 0x1
	breq button_action_increment
	rjmp button_action_finished

	button_action_select:
	rcall button_select
	rjmp button_action_finished

	button_action_increment:
	rcall button_increment

	button_action_invalid:
	button_action_finished:
	ret

button_select:
	push r16
	rcall getSelect
	tst r16
	breq button_select_no_selected
	
	rol r16
	rjmp button_select_set

	button_select_no_selected:
	ldi r16, 1

	button_select_set:
	rcall setSelect

	ldi r16, 0xFF ; reset the display for all fiels to show.
	rcall setFlashSelect
	pop r16
	ret

button_increment:
	rcall getSelect
	cpi r16, (1<<0)
	breq inc_hour
	cpi r16, (1<<1)
	breq inc_min
	cpi r16, (1<<2)
	breq inc_day
	cpi r16, (1<<3)
	breq inc_month
	cpi r16, (1<<4)
	breq inc_year
	cpi r16, (1<<5)
	breq inc_1224

	inc_min:
	rcall getMin
	inc r16
	cpi r16, 60
	brge inc_min_of
	rjmp inc_min_end

	inc_min_of:
	clr r16

	inc_min_end:
	rcall setMin
	clr r16
	rcall setSeconds
	rjmp inc_end_time

	inc_hour:
	rcall getHour
	inc r16
	cpi r16, 24
	brge inc_hour_of
	rjmp inc_hour_end

	inc_hour_of:
	clr r16

	inc_hour_end:
	rcall setHour
	rjmp inc_end_time
	
	inc_day:
	rcall logic_clock_day_inc
	rjmp inc_end_date

	inc_month:
	rcall getMonth
	inc r16
	cpi r16, 13 ; 12 months resetting to 1
	brge inc_month_of
	rjmp inc_month_end

	inc_month_of:
	ldi r16, 1

	inc_month_end:
	rcall setMonth
	rjmp inc_end_date

	inc_year:
	rcall getYear
	inc r16
	cpi r16, 99
	breq inc_year_of
	rjmp inc_year_end

	inc_year_of:
	clr r16

	inc_year_end:
	rcall setYear
	rjmp inc_end_date

	inc_1224:
	rcall toggleState1224
	rjmp inc_end_time

	inc_end_time:
	rcall print_time
	ret

	inc_end_date:
	rcall print_date
	ret