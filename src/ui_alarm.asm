print_date_time_alarm_display:
	rcall print_time_alarm
	rcall print_alarm_status
	ret

print_time_alarm:
	push r16

	push r25
	ldi r25, 0x00
	rcall LCD_Position
	pop r25

	rcall getState
	sbrc r16, 2 ; 2 12/24 hour mode (12:high, 24:low)
	rjmp print_time_alarm_12

	print_time_alarm_24:
	rcall print_hour_alarm
	rcall time_delimiter
	rcall print_minute_alarm

	push r25
	ldi r25, 0x0E
	rcall LCD_Position
	pop r25

	ldi r16, 24
	rcall LCD_Number

	rjmp print_time_alarm_end

	print_time_alarm_12:


	rcall getAlarmHour
	cpi r16, 12
	brge print_time_alarm_12_pm

	print_time_alarm_12_am:
	tst r16		; check if it is 00:00:00 and set the hour to display 12 instead...
	breq print_time_alarm_12_00
	rjmp print_time_alarm_12_00_end

	print_time_alarm_12_00:
	ldi r16, 12		; display 12:**:** at 00:**:**
	print_time_alarm_12_00_end:

	rcall LCD_Number

	rcall time_delimiter
	rcall print_minute_alarm

	rcall getFlashSelect
	sbrs r16, 5
	rjmp print_time_alarm_12_00_flash ; dont print 'AM' because its flashing

	rcall time_am
	rjmp print_time_alarm_end

	print_time_alarm_12_00_flash:
	rcall time_blank
	rjmp print_time_alarm_end

	print_time_alarm_12_pm:
	subi r16, 12

	tst r16		; check if it is 00:00:00 and set the hour to display 12 instead...
	breq print_time_alarm_24_00
	rjmp print_time_alarm_24_00_end

	print_time_alarm_24_00:
	ldi r16, 12		; display 12:**:** at 00:**:**
	print_time_alarm_24_00_end:

	rcall LCD_Number
	rcall time_delimiter
	rcall print_minute_alarm

	rcall getFlashSelect
	sbrs r16, 5
	rjmp print_time_alarm_24_00_flash ; dont print 'AM' because its flashing

	rcall time_pm

	print_time_alarm_24_00_flash:
	rcall time_blank

	print_time_alarm_end:
	pop r16
	ret

print_minute_alarm:
	push r16
	rcall getFlashSelect
	sbrs r16, 1
	rjmp print_minute_alarm_end
	pop r16
	rcall getAlarmMin
	rcall LCD_Number
	ret
	print_minute_alarm_end:
	pop r16
	rcall time_blank
	ret

print_hour_alarm:
	push r16
	rcall getFlashSelect
	sbrs r16, 0
	rjmp print_hour_alarm_end
	pop r16
	rcall getAlarmHour
	rcall LCD_Number
	ret
	print_hour_alarm_end:
	pop r16
	rcall time_blank
	ret

screen_flash_alarm:
	push r16
	push r17
	push r18

	rcall getFlashSelect
	mov r17, r16
	rcall getSelect ; r16
	eor r16, r17

	rcall setFlashSelect

	pop r18
	pop r17
	pop r16
	ret

print_alarm_status:
	push r16
	push r25
	push r19

	ldi r25, 0x4D
	rcall LCD_Position

	rcall getDisplaySelect
	sbrc r16, 0
	rjmp print_alarm_status_skip_flash

	rcall getFlashSelect
	sbrs r16, 2
	rjmp print_alarm_status_flash

	print_alarm_status_skip_flash:
	rcall getState
	sbrs r16, 0
	rjmp print_alarm_status_off

	print_alarm_status_on:
	ldi r19, ' '
	rcall LCD_Char
	ldi r19, 'O'
	rcall LCD_Char
	ldi r19, 'N'
	rcall LCD_Char
	rjmp print_alarm_status_end


	print_alarm_status_off:
	ldi r19, 'O'
	rcall LCD_Char
	ldi r19, 'F'
	rcall LCD_Char
	ldi r19, 'F'
	rcall LCD_Char
	rjmp print_alarm_status_end

	print_alarm_status_flash:
	ldi r19, ' '
	rcall LCD_Char
	ldi r19, ' '
	rcall LCD_Char
	ldi r19, ' '
	rcall LCD_Char
	rjmp print_alarm_status_end

	print_alarm_status_end:
	pop r19
	pop r25
	pop r16
	ret