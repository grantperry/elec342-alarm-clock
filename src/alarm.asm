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

	; sbrc r16, 0
	; rjmp alarm_play_low

	; alarm_play_high: ; set the timer freq high
	; ldi r16, 10
	; rcall timer_set0A
	; rjmp alarm_runtime_logic_end

	; alarm_play_low: ; set the timer freq low
	; ldi r16, 71
	; rcall timer_set0A
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

	rcall getSPIButtons

	cpi r16, 1
	brne alarm_remote_button_end



	clr r16
	rcall setAlarmCounter

	alarm_remote_button_end:
	pop r16
	ret

MUSIC_PROGRAM_1:
	.DB		50,255,50,45,45,50,50,37,37,40,40,40,40,50,255,50,45,45,50,50,33,33,37,37,37,37,50,255,50,24,24,30,30,37,37,40,40,45,45,28,255,28,30,30,37,37,33,33,37,37,37,37,255,0

alarm_music_tick:
	push r16
	
	push r25
	ldi r25, 0x4A
	rcall LCD_Position
	pop r25
	
	rcall getAlarmCounter
	tst r16
	breq alarm_music_tick_end

	rcall getMusicCounter
	push r16
	ldi		ZL,LOW(MUSIC_PROGRAM_1*2)
	ldi		ZH,HIGH(MUSIC_PROGRAM_1*2)
	add ZL, r16
	ldi r16, 0
	adc ZH, r16
	lpm r16, z
	; rcall LCD_Number
	tst r16
	breq alarm_music_tick_reset
	cpi r16, 255
	breq alarm_music_tick_silent
	rcall timer_set0A
	pop r16

	rcall timer_enable0A
	alarm_music_tick_action_end:
	inc r16
	rcall setMusicCounter

	alarm_music_tick_end:
	pop r16
	ret

	alarm_music_tick_reset:
	clr r16
	rcall setMusicCounter
	pop r16
	rjmp alarm_music_tick_end
	
	alarm_music_tick_silent:
	rcall timer_disable0A
	pop r16
	rjmp alarm_music_tick_action_end
