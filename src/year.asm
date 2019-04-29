; ret r16 leap:1 notLeap:0
isLeapYear:
	push r17 ; used as the divisor in div8u
	push r18 ; used as loop counter in div8u
	
	rcall getYear

	; subi r16, 2 ; dividend - 2 (remove two to make the offset correct for 1970)
	ldi r17, 4		;divisor
	rcall div8u

	mov r16, r15		;remainder of year % 4

	pop r18
	pop r17

	tst r16
	breq isLeapYear_leap

	isLeapYear_no_leap:
	ldi r16, 0
	ret

	isLeapYear_leap:
	ldi r16, 1
	ret