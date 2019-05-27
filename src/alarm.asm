alarm_init:
	; set output
	sbi DDRC, 0

	; set off
	cbi PORTC, 0
	ret

alarm_play:
	; set on
	sbi PORTC, 0
	rcall timer_enable0A
	rcall setLED
	ret

alarm_stop:
	; set off
	cbi PORTC, 0
	rcall timer_disable0A
	rcall clearLED
	ret

alarm_runtime_logic:
	rcall getAlarmCounter
	tst r16
	breq alarm_runtime_logic_silence

	dec r16	;	decrement alarm runtime length
	rcall setAlarmCounter ; save it away to mem
	
	rcall alarm_play ; enable the pwm timer

	sbrc r16, 0
	rjmp alarm_play_low

	alarm_play_high: ; set the timer freq high
	ldi r16, 10
	rcall timer_set0A
	rjmp alarm_runtime_logic_end

	alarm_play_low: ; set the timer freq low
	ldi r16, 71
	rcall timer_set0A
	rjmp alarm_runtime_logic_end

	alarm_runtime_logic_silence:
	rcall alarm_stop ; disable the pwm timer.

	alarm_runtime_logic_end:
	ret

logic_alarm:
	rcall getState
	sbrs r16, 0 ; if alarm enabled. skip jump
	jmp logic_alarm_end

	rcall getAlarmHour
	mov r17, r16
	rcall getHour
	cp r16, r17
	brne logic_alarm_end

	; alarm_hour == hour

	rcall getAlarmMin
	mov r17, r16
	rcall getMin
	cp r16, r17
	brne logic_alarm_end

	; min == min

	rcall getSeconds
	cpi r16, 0
	brne logic_alarm_end

	; start of min.

	ldi r16, 60 ;length of alarm in seconds
	rcall setAlarmCounter

	logic_alarm_end:
	ret

alarm_remote_button:
	push r16
	rcall getAlarmCounter
	tst r16
	breq alarm_remote_button_end


	push r25
	ldi r25, 0x4A
	rcall LCD_Position
	pop r25
	ldi r16, 101

	rcall getSPIButtons
	rcall LCD_Number
	; rcall LCD_Number

	cpi r16, 1
	brne alarm_remote_button_end



	clr r16
	rcall setAlarmCounter

	alarm_remote_button_end:
	pop r16
	ret