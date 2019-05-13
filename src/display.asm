display_update:
	rcall getDisplaySelect
	cpi r16, (1<<0) ; clock
	brne display_update_not_clock
	rcall display_update_clock
	rjmp display_update_end

	display_update_not_clock:
	cpi r16, (1<<1); alarm
	brne display_update_not_alarm
	rcall display_update_alarm
	rjmp display_update_end

	display_update_not_alarm:
	display_update_end:
	ret

display_update_clock:
	rcall print_date_time_display
	ret

display_update_alarm:
	rcall print_date_time_alarm_display
	ret

display_inc_counter:
	rcall getDisplaySelect
	rol r16
	cpi r16, (1<<2)
	brne display_inc_counter_under

	ldi r16, (1<<0)

	display_inc_counter_under:
	rcall setDisplaySelect
	rcall LCD_Clear

	; reset the select to none so we arnt editing anything on the next screen
	ldi r16, 0
	rcall setSelect
	ldi r16, 0xff
	rcall setFlashSelect
	ret