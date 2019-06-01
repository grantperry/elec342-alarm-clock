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
	push r16
	
	push r25
	ldi r25, 0x0E
	rcall LCD_Position
	pop r25

	rcall getFlashSelect
	sbrs r16, 5
	rjmp time_m_blank

	ldi r19, 'A'
	rcall LCD_Char
	ldi r19, 'M'
	rcall LCD_Char

	rjmp time_m_end

time_pm:
	push r19
	push r16

	push r25
	ldi r25, 0x0E
	rcall LCD_Position
	pop r25

	rcall getFlashSelect
	sbrs r16, 5
	rjmp time_m_blank

	ldi r19, 'P'
	rcall LCD_Char
	ldi r19, 'M'
	rcall LCD_Char

	time_m_end:
	pop r16
	pop r19
	ret

	time_m_blank:
	rcall time_blank
	rjmp time_m_end

date_delimiter:
	push r19

	ldi r19, '/'
	rcall LCD_Char

	pop r19
	ret