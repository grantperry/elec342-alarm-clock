;
; blink.asm
;
; Created: 3/01/2018 11:24:11 AM
; Author : Grant Perry 45156085
;

.include "./m328Pdef.inc"

.def rBin1H = r2
.def rBin1L = r1
.def rBin2H = r4
.def rBin2L = r3

.DSEG
HOUR:			.BYTE 1
MINUTE:		.BYTE 1
SECOND:		.BYTE 1

DAY:		.BYTE 1
MONTH:		.BYTE 1
YEAR:		.BYTE 4

BCD_MEM:		.BYTE 5

.CSEG
.org		0x0000

; Replace with your application code
start:
	rjmp	main
	jmp UNKNOWN_INT ; IRQ0
	jmp UNKNOWN_INT ; IRQ1
	jmp UNKNOWN_INT ; PCINT0
	jmp UNKNOWN_INT ; PCINT1
	jmp UNKNOWN_INT ; PCINT2
	jmp UNKNOWN_INT ; Watchdog Timeout
	jmp UNKNOWN_INT ; Timer2 CompareA
	jmp UNKNOWN_INT ; Timer2 CompareB
	jmp UNKNOWN_INT ; Timer2 Overflow
	jmp UNKNOWN_INT ; Timer1 Capture
	jmp UNKNOWN_INT ; Timer1 CompareA
	jmp UNKNOWN_INT ; Timer1 CompareB
	jmp UNKNOWN_INT ; Timer1 Overflow
	jmp TIMER0_INT ; Timer0 CompareA
	jmp TIMER0_INT ; Timer0 CompareB
	jmp TIMER0_INT ; Timer0 Overflow
	jmp UNKNOWN_INT ; SPI Transfer Complete
	jmp UNKNOWN_INT ; USART RX Complete
	jmp UNKNOWN_INT ; USART UDR Empty
	jmp UNKNOWN_INT ; USART TX Complete
	jmp UNKNOWN_INT ; ADC Conversion Complete
	jmp UNKNOWN_INT ; EEPROM Ready
	jmp UNKNOWN_INT ; Analog Comparator
	jmp UNKNOWN_INT ; 2-wire Serial
	jmp UNKNOWN_INT ; SPM Ready


;
; Main code goes here.
;
; Firstly, we initialise the I/O ports that we use
;
main:
	; set stack pointer to the top of the RAM. goes down
	ldi	r16,high(RAMEND)
	out	SPH,r16
	ldi	r16,low(RAMEND)
	out	SPL,r16


	; instanciate all memory fields
	call initialiseMem

	call initLED

	; rcall TWI_enable
	call delay1sec

	rcall init_twi

	ldi		r24,0x27	; Setup LCD display at this address (Maybe 0x3f instead)
	rcall	LCD_Setup
	rcall	LCD_Clear

	ldi		ZL,LOW(LCD_init_Msg*2)
	ldi		ZH,HIGH(LCD_init_Msg*2)
	call	LCD_Text

	ldi		r24,0x27	; Setup LCD display at this address (Maybe 0x3f instead)
	rcall	LCD_Setup

	rcall	LCD_Clear
	call delay1msec

	; ldi		ZL,LOW(LCD_init_Msg1*2)
	; ldi		ZH,HIGH(LCD_init_Msg1*2)
	; call	LCD_Text

	; ldi r19, 4
	; rcall LCD_Number

	; clr r0
	

loop:
	rcall getSeconds
	cpi r16, 59
	brge min_term
	inc r16
	rcall setSeconds
	rjmp logic_end

	min_term:
	clr r16
	rcall setSeconds
	
	rcall getMin
	cpi r16, 59
	brge hour_term
	inc r16
	rcall setMin
	rjmp logic_end

	hour_term:
	clr r16
	rcall setMin
	
	rcall getHour
	cpi r16, 23
	brge day_term
	inc r16
	rcall setHour
	rjmp logic_end

	day_term:
	clr r16
	rcall setHour
	
	rcall getDay
	cpi r16, 28 ; this will need to figure out month terminator
	brge month_term
	inc r16
	rcall setDay
	rjmp logic_end

	month_term:
	ldi r16, 1 ; day resets to 1
	rcall setDay

	rcall getMonth
	cpi r16, 12 ; this will need to figure out month terminator
	brge year_term
	inc r16
	rcall setMonth
	rjmp logic_end

	year_term:
	ldi r16, 1 ; Month resets to 1
	rcall setMonth

	rcall getYear
	ldi r16, 1
	add r0, r16
	ldi r16, 0
	adc r1, r16
	adc r2, r16
	adc r3, r16
	rcall setYear
	

	logic_end:

	rcall print_time

	call setLED
	call delay1sec
	call clearLED
	call delay1sec
  jmp	loop

print_time:
	ldi r25, 0x00
	rcall LCD_Position

	rcall getHour
	rcall LCD_Number
	rcall time_delimiter
	rcall getMin
	rcall LCD_Number
	rcall time_delimiter
	rcall getSeconds
	rcall LCD_Number
	
	ldi r25, 0x40
	rcall LCD_Position

	rcall getDay
	rcall LCD_Number
	rcall date_delimiter
	rcall getMonth
	rcall LCD_Number
	rcall date_delimiter
	rcall getYear
	mov r16, r0
	rcall LCD_Number
	ret

time_delimiter:
	ldi r19, ':'
	rcall LCD_Char
	ret

date_delimiter:
	ldi r19, '/'
	rcall LCD_Char
	ret

;
; Delay by the number of instructions in r20/r21/r22 as a 24 bit value * 4
; on a 1 MHz machine a value of 250,000 is 1 second: 0x03 0xd0 0x90
; on a 16 MHz machine a value of (16,000,000/4) = 4,000,000 is 1 second: 0x3d 0x09 0x00
;

.equ	ONE_MSECOND =	(16000000/64)
delay1msec:
	ldi	r20,BYTE3(ONE_MSECOND)
	ldi	r21,HIGH(ONE_MSECOND)
	ldi	r22,LOW(ONE_MSECOND)
	rjmp	_delay

.equ	ONE_SECOND =	(16000000/4)/128
delay1sec:
	ldi	r20,BYTE3(ONE_SECOND)
	ldi	r21,HIGH(ONE_SECOND)
	ldi	r22,LOW(ONE_SECOND)
	rjmp	_delay

_delay:
	subi	r22,0x01
	sbci	r21,0x00
	sbci	r20,0x00
	brne	_delay
	ret

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
	ld r1, z+
	ld r2, z+
	ld r3, z
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
	ret

setYear:
	push ZL
	push ZH
	ldi		ZL,LOW(YEAR*2)
	ldi		ZH,HIGH(YEAR*2)
	st z+, r0
	st z+, r1
	st z+, r2
	st z, r3
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


; Initialize all memory fields
initialiseMem:
	; set Hour, Min and Second to 0
	; clr r16
	ldi r16, 0
	rcall setSeconds
	ldi r16, 59
	rcall setMin
	ldi r16, 23
	rcall setHour

	mov r1, r16
	mov r2, r16
	mov r3, r16
	ldi r16, 49 ; years since 1970
	mov r0, r16
	rcall setYear

	ldi r16, 12
	rcall setMonth
	ldi r16, 28
	rcall setDay
	ret


initLED:
	sbi	DDRB,5
	ret

setLED:
	sbi	PORTB,5	; 1 -> output bit
	ret

clearLED:
	cbi	PORTB,5	; 0 -> output bit
	ret

UNKNOWN_INT:
	sbi PORTD, 7
	jmp end

TIMER0_INT:
	sbi PORTD, 6

end:
	ldi r16, 0xff
	sts 0x20+PORTD, r16
	jmp end

.include "src/I2C-master.asm"
.include "src/LCD.asm"
.include "src/div8u.asm"
.include "src/bin2ascii5.asm"
; .include "src/i2c.asm"