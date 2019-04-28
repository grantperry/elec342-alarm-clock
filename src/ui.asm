print_time:
	push r16

	push r25
	ldi r25, 0x00
	rcall LCD_Position
	pop r25

	rcall getState
	sbrc r16, 2 ; 2 12/24 hour mode (12:high, 24:low)
	rjmp print_time_12

	print_time_24:
	rcall print_hour
	rcall time_delimiter
	rcall print_minute
	rcall time_delimiter
	rcall print_second

	push r25
	ldi r25, 0x0E
	rcall LCD_Position
	pop r25

	rcall getFlashSelect
	sbrs r16, 5
	rjmp print_time_no_24 ; dont print '24' because its flashing

	ldi r16, 24
	rcall LCD_Number

	print_time_no_24:

	rcall time_blank ; to wipe the '24 from the position'

	rjmp print_time_end

	print_time_12:


	rcall getHour
	cpi r16, 12
	brge print_time_12_pm

	print_time_12_am:
	tst r16		; check if it is 00:00:00 and set the hour to display 12 instead...
	breq print_time_12_00
	rjmp print_time_12_00_end

	print_time_12_00:
	ldi r16, 12		; display 12:**:** at 00:**:**
	print_time_12_00_end:

	rcall LCD_Number

	rcall time_delimiter
	rcall print_minute
	rcall time_delimiter
	rcall print_second

	rcall getFlashSelect
	sbrs r16, 5
	rjmp print_time_12_00_flash ; dont print 'AM' because its flashing

	rcall time_am
	rjmp print_time_end

	print_time_12_00_flash:
	rcall time_blank
	rjmp print_time_end

	print_time_12_pm:
	subi r16, 12

	tst r16		; check if it is 00:00:00 and set the hour to display 12 instead...
	breq print_time_24_00
	rjmp print_time_24_00_end

	print_time_24_00:
	ldi r16, 12		; display 12:**:** at 00:**:**
	print_time_24_00_end:

	rcall LCD_Number
	rcall time_delimiter
	rcall print_minute
	rcall time_delimiter
	rcall print_second

	rcall getFlashSelect
	sbrs r16, 5
	rjmp print_time_24_00_flash ; dont print 'AM' because its flashing

	rcall time_pm

	print_time_24_00_flash:
	rcall time_blank

	print_time_end:
	pop r16
	ret



print_date:
	push r16

	push r25
	ldi r25, 0x40
	rcall LCD_Position
	pop r25

	rcall print_day
	rcall date_delimiter
	rcall print_month
	rcall date_delimiter
	rcall print_year

	pop r16
	ret

time_delimiter:
	push r19

	ldi r19, ':'
	rcall LCD_Char

	pop r19
	ret

time_blank:
	push r19

	ldi r19, ' '
	rcall LCD_Char
	ldi r19, ' '
	rcall LCD_Char

	pop r19
	ret

time_am:
	push r19

	push r25
	ldi r25, 0x0E
	rcall LCD_Position
	pop r25

	ldi r19, 'A'
	rcall LCD_Char
	ldi r19, 'M'
	rcall LCD_Char

	pop r19
	ret

time_pm:
	push r19

	push r25
	ldi r25, 0x0E
	rcall LCD_Position
	pop r25

	ldi r19, 'P'
	rcall LCD_Char
	ldi r19, 'M'
	rcall LCD_Char

	pop r19
	ret

date_delimiter:
	push r19

	ldi r19, '/'
	rcall LCD_Char

	pop r19
	ret

print_second:
	rcall getSeconds
	rcall LCD_Number
	ret

print_minute:
	push r16
	rcall getFlashSelect
	sbrs r16, 1
	rjmp print_minute_end
	pop r16
	rcall getMin
	rcall LCD_Number
	ret
	print_minute_end:
	pop r16
	rcall time_blank
	ret

print_hour:
	push r16
	rcall getFlashSelect
	sbrs r16, 0
	rjmp print_hour_end
	pop r16
	rcall getHour
	rcall LCD_Number
	ret
	print_hour_end:
	pop r16
	rcall time_blank
	ret

print_day:
	push r16
	rcall getFlashSelect
	sbrs r16, 2
	rjmp print_day_end
	pop r16
	rcall getDay
	rcall LCD_Number
	ret
	print_day_end:
	pop r16
	rcall time_blank
	ret

print_month:
	push r16
	rcall getFlashSelect
	sbrs r16, 3
	rjmp print_month_end
	pop r16
	rcall getMonth
	rcall LCD_Number
	ret
	print_month_end:
	pop r16
	rcall time_blank
	ret

print_year:
	push r16
	rcall getFlashSelect
	sbrs r16, 4
	rjmp print_year_end
	pop r16
	rcall getYear
	mov r16, r0
	rcall LCD_Number
	ret
	print_year_end:
	pop r16
	rcall time_blank
	ret

screen_flash:
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