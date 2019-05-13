button_alarm_actions:
	cpi r16, (1<<2)
	breq button_alarm_action_inc_display_counter
	cpi r16, (1<<1)
	breq button_alarm_action_select
	cpi r16, (1<<0)
	breq button_alarm_action_increment
	rjmp button_alarm_action_finished

	button_alarm_action_inc_display_counter:
	rcall display_inc_counter
	rjmp button_alarm_action_finished

	button_alarm_action_select:
	rcall button_alarm_select
	rjmp button_alarm_action_finished

	button_alarm_action_increment:
	rcall button_alarm_increment

	button_alarm_action_invalid:
	button_alarm_action_finished:
	ret

button_alarm_select:
	push r16
	rcall getSelect
	tst r16
	breq button_alarm_select_no_selected
	cpi r16, (1<<2) ; terminate if currently ...100
	breq button_alarm_select_term
	
	clc ; rol uses carry. so clear it.
	rol r16
	rjmp button_alarm_select_set

	button_alarm_select_no_selected:
	ldi r16, 1
	rjmp button_alarm_select_set

	button_alarm_select_term:
	clr r16

	button_alarm_select_set:
	rcall setSelect

	ldi r16, 0xFF ; reset the display for all fiels to show.
	rcall setFlashSelect
	pop r16
	ret

button_alarm_increment:
	rcall getSelect
	cpi r16, (1<<0)
	breq inc_alarm_hour
	cpi r16, (1<<1)
	breq inc_alarm_min
	cpi r16, (1<<2)
	breq inc_alarm_enable
	rjmp inc_alarm_end

	inc_alarm_min:
	rcall getAlarmMin
	inc r16
	cpi r16, 60
	brge inc_alarm_min_of
	rjmp inc_alarm_min_end

	inc_alarm_min_of:
	clr r16

	inc_alarm_min_end:
	rcall setAlarmMin
	rjmp inc_alarm_end_time

	inc_alarm_hour:
	rcall getAlarmHour
	inc r16
	cpi r16, 24
	brge inc_alarm_hour_of
	rjmp inc_alarm_hour_end

	inc_alarm_hour_of:
	clr r16

	inc_alarm_hour_end:
	rcall setAlarmHour
	rjmp inc_alarm_end_time

	inc_alarm_enable:
	rcall getState
	push r17
	ldi r17, (1<<0)
	eor r16, r17
	pop r17
	rcall setState

	rjmp inc_alarm_end_time

	inc_alarm_end_time:
	inc_alarm_end:
	rcall display_update
	ret