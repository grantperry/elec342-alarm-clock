button_clock_actions:
	cpi r16, (1<<2)
	breq button_clock_action_inc_display_counter
	cpi r16, (1<<1)
	breq button_clock_action_select
	cpi r16, (1<<0)
	breq button_clock_action_increment
	rjmp button_clock_action_finished

	button_clock_action_inc_display_counter:
	rcall display_inc_counter
	rjmp button_clock_action_finished

	button_clock_action_select:
	rcall button_clock_select
	rjmp button_clock_action_finished

	button_clock_action_increment:
	rcall button_clock_increment

	button_clock_action_invalid:
	button_clock_action_finished:
	ret

button_clock_select:
	push r16
	rcall getSelect
	tst r16
	breq button_clock_select_no_selected
	cpi r16, (1<<5) ; terminate if currently ...10000
	breq button_clock_select_term
	
	clc ; rol uses carry. so clear it.
	rol r16
	rjmp button_clock_select_set

	button_clock_select_no_selected:
	ldi r16, 1
	rjmp button_clock_select_set

	button_clock_select_term:
	clr r16

	button_clock_select_set:
	rcall setSelect

	ldi r16, 0xFF ; reset the display for all fiels to show.
	rcall setFlashSelect
	pop r16
	ret

button_clock_increment:
	rcall getSelect
	cpi r16, (1<<0)
	breq inc_clock_hour
	cpi r16, (1<<1)
	breq inc_clock_min
	cpi r16, (1<<2)
	breq inc_clock_day
	cpi r16, (1<<3)
	breq inc_clock_month
	cpi r16, (1<<4)
	breq inc_clock_year
	cpi r16, (1<<5)
	breq inc_clock_1224
	rjmp inc_clock_end

	inc_clock_min:
	rcall getMin
	inc r16
	cpi r16, 60
	brge inc_clock_min_of
	rjmp inc_clock_min_end

	inc_clock_min_of:
	clr r16

	inc_clock_min_end:
	rcall setMin
	clr r16
	rcall setSeconds
	rjmp inc_clock_end_time

	inc_clock_hour:
	rcall getHour
	inc r16
	cpi r16, 24
	brge inc_clock_hour_of
	rjmp inc_clock_hour_end

	inc_clock_hour_of:
	clr r16

	inc_clock_hour_end:
	rcall setHour
	rjmp inc_clock_end_time
	
	inc_clock_day:
	rcall logic_clock_day_inc
	rjmp inc_clock_end_date

	inc_clock_month:
	rcall getMonth
	inc r16
	cpi r16, 13 ; 12 months resetting to 1
	brge inc_clock_month_of
	rjmp inc_clock_month_end

	inc_clock_month_of:
	ldi r16, 1

	inc_clock_month_end:
	rcall setMonth
	rjmp inc_clock_end_date

	inc_clock_year:
	rcall getYear
	inc r16
	cpi r16, 99
	breq inc_clock_year_of
	rjmp inc_clock_year_end

	inc_clock_year_of:
	clr r16

	inc_clock_year_end:
	rcall setYear
	rjmp inc_clock_end_date

	inc_clock_1224:
	rcall toggleState1224
	rjmp inc_clock_end_time

	inc_clock_end_time:
	inc_clock_end_date:
	inc_clock_end:
	rcall display_update
	ret

toggle_alarm_setter:
	ret