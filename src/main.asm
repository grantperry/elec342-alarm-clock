;
; blink.asm
;
; Created: 3/01/2018 11:24:11 AM
; Author : Grant Perry 45156085
;

.include "./m328Pdef.inc"

.DSEG
HOUR:			.BYTE 1
MINUTE:		.BYTE 1
SECOND:		.BYTE 1

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

.equ TWI_CLOCK_DIVISOR = (16000000/100000)

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

	rcall TWI_enable

	rcall i2c_init
	rcall i2c_start
	; rcall i2c_stop

loop:
	call setLED

	call delay1sec


	call clearLED
	call delay1sec
  jmp	loop


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

.equ	ONE_SECOND =	(16000000/4)/4
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



; Initialize all memory fields
initialiseMem:
	; set Hour, Min and Second to 0
	ldi r16, 0x00
	sts HOUR, r16
	sts MINUTE, r16
	sts SECOND, r16
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


;
; enable TWI through the TWCR register
; setting the TXEN or TWEN bits automagically set the pins for their 'alternate function'
; alternate function in this case automatically enables them in the Power Saving register.
;
TWI_enable:
	;set TWCR:TWEN && TWCR:TWIE (MMIO)
	lds r16, TWCR ; load the current TwoWire Register
	ori r16, (1<<TWEN) | (1<<TWIE) ; or the new configuration into the register
	
	sts TWCR, r16	;	write out the new TWI configuration
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

.include "src/i2c.asm"