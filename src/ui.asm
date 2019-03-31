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
	rcall getHour
	rcall LCD_Number
	rcall time_delimiter
	rcall getMin
	rcall LCD_Number
	rcall time_delimiter
	rcall getSeconds
	rcall LCD_Number

	push r25
	ldi r25, 0x0E
	rcall LCD_Position
	pop r25
	ldi r16, 24
	rcall LCD_Number

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
	rcall getMin
	rcall LCD_Number
	rcall time_delimiter
	rcall getSeconds
	rcall LCD_Number
	rcall time_am
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
	rcall getMin
	rcall LCD_Number
	rcall time_delimiter
	rcall getSeconds
	rcall LCD_Number
	rcall time_pm

	print_time_end:
	pop r16
	ret



print_date:
	push r16

	push r25
	ldi r25, 0x40
	rcall LCD_Position
	pop r25

	rcall getDay
	rcall LCD_Number
	rcall date_delimiter
	rcall getMonth
	rcall LCD_Number
	rcall date_delimiter
	rcall getYear
	mov r16, r0
	rcall LCD_Number

	pop r16
	ret

time_delimiter:
	push r19

	ldi r19, ':'
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