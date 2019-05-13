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