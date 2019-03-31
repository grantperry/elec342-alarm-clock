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
YEAR:		.BYTE 2

A_HOUR:			.BYTE 1
A_MINUTE:		.BYTE 1

STATE:		.BYTE 1 ; 0:alarm_enabled, 1:alarm_snoozed, 2:12_24_mode(12:high, 24:low)

BCD_MEM:		.BYTE 5

SUB_INT_DIV: .BYTE 1

.CSEG
.org		0x0000

; Replace with your application code
start:
	jmp	main ; RESET
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
	jmp TIM1_COMPA ; Timer1 CompareA
	jmp UNKNOWN_INT ; Timer1 CompareB
	jmp UNKNOWN_INT ; Timer1 Overflow
	jmp UNKNOWN_INT ; Timer0 CompareA
	jmp UNKNOWN_INT ; Timer0 CompareB
	jmp UNKNOWN_INT ; Timer0 Overflow
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
	rcall initialiseMem

	rcall init_twi

	ldi		r24,0x27	; Setup LCD display at this address (Maybe 0x3f instead)
	rcall	LCD_Setup
	rcall	LCD_Clear

	rcall spi_init
	rcall spi_extend_init

	rcall timer_enable

	rcall getButtons
	tst r16
	brne sl
	rcall setLED

	sl:
	sleep
	jmp sl

; Initialize all memory fields
initialiseMem:
	; set Hour, Min and Second to 0
	; clr r16
	ldi r16, 57
	rcall setSeconds
	ldi r16, 59
	rcall setMin
	ldi r16, 23
	rcall setHour

	clr r1
	ldi r16, 49 ; years since 1970
	mov r0, r16
	rcall setYear

	ldi r16, 3
	rcall setMonth
	ldi r16, 30
	rcall setDay

	clr r16
	rcall setState

	; rcall toggleState1224
	; rcall toggleState1224
	ret

UNKNOWN_INT:
	sbi PORTD, 7
	jmp end

end:
	jmp end

.include "src/logic_clock.asm"
.include "src/memory_etters.asm"
.include "src/ui.asm"
.include "src/month.asm"
.include "src/year.asm"
.include "src/timer.asm"
.include "src/I2C-master.asm"
.include "src/LCD.asm"
.include "src/div8u.asm"
.include "src/bin2ascii5.asm"
.include "src/spi.asm"
.include "src/spi_extend.asm"