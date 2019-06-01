; return a non zero value in r16 if daylight savings changes were made
logic_daylight_savings:
	logic_daylight_savings_april:
	rcall getMonth
	cpi r16, 4
	brne logic_daylight_savings_october
	rcall getDay
	cpi r16, 1
	brne logic_daylight_savings_end_no_change
	rcall getHour
	cpi r16, 2
	brne logic_daylight_savings_end_no_change

	rcall getState
	sbrc r16, 4
	rjmp logic_daylight_savings_end_no_change

	push r17
	ldi r17, (1<<4)
	or r16, r17
	pop r17
	rcall setState

	ldi r16, 1
	rjmp logic_daylight_savings_end
	logic_daylight_savings_october:
	cpi r16, 10
	brne logic_daylight_savings_end_no_change
	rcall getDay
	cpi r16, 1
	brne logic_daylight_savings_end_no_change
	rcall getHour
	cpi r16, 1
	brne logic_daylight_savings_end_no_change

	ldi r16, 3
	rcall setHour

	ldi r16, 2
	rjmp logic_daylight_savings_end
	logic_daylight_savings_end_no_change:
	clr r16
	logic_daylight_savings_end:
	ret

logic_daylight_savings_reset_state:
	push r16
	push r17
	rcall getState
	ldi r17, 0xFF - (1<<4)
	and r16, r17
	rcall setState
	pop r17
	pop r16
	ret