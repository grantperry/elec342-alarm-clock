getSeconds:
	push ZL
	push ZH
	ldi		ZL,LOW(SECOND*2)
	ldi		ZH,HIGH(SECOND*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

getMin:
	push ZL
	push ZH
	ldi		ZL,LOW(MINUTE*2)
	ldi		ZH,HIGH(MINUTE*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

getHour:
	push ZL
	push ZH
	ldi		ZL,LOW(HOUR*2)
	ldi		ZH,HIGH(HOUR*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

getYear:
	push ZL
	push ZH
	ldi		ZL,LOW(YEAR*2)
	ldi		ZH,HIGH(YEAR*2)
	ld r0, z+
	ld r1, z
	pop ZH
	pop ZL
	ret

getMonth:
	push ZL
	push ZH
	ldi		ZL,LOW(MONTH*2)
	ldi		ZH,HIGH(MONTH*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

getDay:
	push ZL
	push ZH
	ldi		ZL,LOW(DAY*2)
	ldi		ZH,HIGH(DAY*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

setSeconds:
	push ZL
	push ZH
	ldi		ZL,LOW(SECOND*2)
	ldi		ZH,HIGH(SECOND*2)
	st z, r16
	pop ZH
	pop ZL
	ret

setMin:
	push ZL
	push ZH
	ldi		ZL,LOW(MINUTE*2)
	ldi		ZH,HIGH(MINUTE*2)
	st z, r16
	pop ZH
	pop ZL
	ret

setHour:
	push ZL
	push ZH
	ldi		ZL,LOW(HOUR*2)
	ldi		ZH,HIGH(HOUR*2)
	st z, r16
	pop ZH
	pop ZL
	ret

setYear:
	push ZL
	push ZH
	ldi		ZL,LOW(YEAR*2)
	ldi		ZH,HIGH(YEAR*2)
	st z+, r0
	st z, r1
	pop ZH
	pop ZL
	ret

setDay:
	push ZL
	push ZH
	ldi		ZL,LOW(DAY*2)
	ldi		ZH,HIGH(DAY*2)
	st z, r16
	pop ZH
	pop ZL
	ret

setMonth:
	push ZL
	push ZH
	ldi		ZL,LOW(MONTH*2)
	ldi		ZH,HIGH(MONTH*2)
	st z, r16
	pop ZH
	pop ZL
	ret

setState:
	push ZL
	push ZH
	ldi		ZL,LOW(STATE*2)
	ldi		ZH,HIGH(STATE*2)
	st z, r16
	pop ZH
	pop ZL
	ret

getState:
	push ZL
	push ZH
	ldi		ZL,LOW(STATE*2)
	ldi		ZH,HIGH(STATE*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

setButtons:
	push ZL
	push ZH
	ldi		ZL,LOW(BUTTONS*2)
	ldi		ZH,HIGH(BUTTONS*2)
	st z, r16
	pop ZH
	pop ZL
	ret

getButtons:
	push ZL
	push ZH
	ldi		ZL,LOW(BUTTONS*2)
	ldi		ZH,HIGH(BUTTONS*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

setButtonsStable:
	push ZL
	push ZH
	ldi		ZL,LOW(BUTTONS_STABLE*2)
	ldi		ZH,HIGH(BUTTONS_STABLE*2)
	st z, r16
	pop ZH
	pop ZL
	ret

getButtonsStable:
	push ZL
	push ZH
	ldi		ZL,LOW(BUTTONS_STABLE*2)
	ldi		ZH,HIGH(BUTTONS_STABLE*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

setButtonsCount:
	push ZL
	push ZH
	ldi		ZL,LOW(BUTTONS_COUNT*2)
	ldi		ZH,HIGH(BUTTONS_COUNT*2)
	st z, r16
	pop ZH
	pop ZL
	ret

getButtonsCount:
	push ZL
	push ZH
	ldi		ZL,LOW(BUTTONS_COUNT*2)
	ldi		ZH,HIGH(BUTTONS_COUNT*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

setSelect:
	push ZL
	push ZH
	ldi		ZL,LOW(SELECT*2)
	ldi		ZH,HIGH(SELECT*2)
	st z, r16
	pop ZH
	pop ZL
	ret

getSelect:
	push ZL
	push ZH
	ldi		ZL,LOW(SELECT*2)
	ldi		ZH,HIGH(SELECT*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

setFlashSelect:
	push ZL
	push ZH
	ldi		ZL,LOW(FLASH_SELECT*2)
	ldi		ZH,HIGH(FLASH_SELECT*2)
	st z, r16
	pop ZH
	pop ZL
	ret

getFlashSelect:
	push ZL
	push ZH
	ldi		ZL,LOW(FLASH_SELECT*2)
	ldi		ZH,HIGH(FLASH_SELECT*2)
	ld r16, z
	pop ZH
	pop ZL
	ret

toggleState1224:
	push r16

	rcall getState
	sbrs r16, 2
	rjmp toggleState1223_is24

	toggleState1223_is12:
	cbr r16, (1<<2)
	rjmp toggleState1223_end

	toggleState1223_is24:
	sbr r16, (1<<2)
	
	toggleState1223_end:
	rcall setState

	pop r16
	ret