logic_clock:
	rcall getSeconds
	cpi r16, 59				; terminate if seconds >= 59
	brge min_term
	inc r16
	rcall setSeconds
	rjmp logic_clock_end

	min_term:
	clr r16
	rcall setSeconds
	
	rcall getMin
	cpi r16, 59			;terminate if minutes >= 59
	brge hour_term
	inc r16
	rcall setMin
	rjmp logic_clock_end

	hour_term:
	clr r16
	rcall setMin

	rcall getHour
	cpi r16, 23			;terminate if hours >= 23
	brge day_term
	inc r16
	rcall setHour
	rjmp logic_clock_end

	day_term:
	clr r16
	rcall setHour
	
	rcall logic_clock_day_inc
	tst r16
	breq logic_clock_end ; if 0 then end, else continue to incrememnt the month

	rcall getMonth
	cpi r16, 12 			;terminate if month >= 12
	brge year_term
	inc r16
	rcall setMonth
	rjmp logic_clock_end

	year_term:
	ldi r16, 1 ; Month resets to 1
	rcall setMonth

	rcall getYear
	ldi r16, 1
	add r0, r16
	ldi r16, 0
	adc r1, r16
	adc r2, r16
	adc r3, r16
	rcall setYear

	logic_clock_end:
	ret

logic_clock_day_inc:
	; CALCULATE HOW MANY DAYS IN THE CURRENT MONTH FOR THIS YEAR
	rcall getMonth
	rcall getMonthLength
	push r17

	rcall getDay
	pop r17
	cp r16, r17 ; this will need to figure out month terminator
	brge month_term
	inc r16
	rcall setDay
	rjmp logic_clock_day_inc_end
	

	month_term:
	ldi r16, 1 ; day resets to 1
	rcall setDay
	ldi r16, 1
	ret

	logic_clock_day_inc_end:
	clr r16
	ret