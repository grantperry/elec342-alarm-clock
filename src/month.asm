MonthLengths:
.db 0,31,28,31,30,31,30,31,31,30,31,30,31
; .db 0,1,2,3,4,5,6,7,8,9,10,11,12

; r16 month
; ret r17 length
getMonthLength:
	push ZL
	push ZH
	
	push r16
	push r17
	ldi r25, 0x4E
	rcall LCD_Position
	pop r17


	ldi		ZL,LOW(MonthLengths*2)
	ldi		ZH,HIGH(MonthLengths*2)
	pop r16
	push r16
	add ZL, r16
	ldi r16, 0
	adc ZH, r16

	lpm r17, Z			; the corresponding length is loaded in from the table above


	pop r18
	cpi r18, 2
	breq getMonthLength_Feburary
	rjmp getMonthLength_end

	getMonthLength_Feburary:

	rcall isLeapYear ; ret r16 T/F
	
	tst r16
	breq getMonthLength_end
	inc r17

	getMonthLength_end:

	pop ZH
	pop ZL
	ret