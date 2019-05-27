;
; Initialisation strings for the LCD panel
;

LCD_init_String0:
	.DB		0x0C,0x01		; turn on display, cursor and blink					+		clear display, return cursor to home position
LCD_init_Msg:
	.DB		" ", 0x00

;
; LCD Position - set the write poswition in the DRAM
; r24 holds the LCD I2C address
; r25 holds the address (0-127)
; r17 holds the lower 4 bits
;
LCD_Position:
	call	sendTWI_Start
	brne	LCD_serror

	mov		r16,r24			; use this address
	add		r16,r16			; and move over the r/w bit
	call	sendTWI_SLA
	brne	LCD_serror

	mov		r16,r25
	ori		r16,0x80		; set DDRAM address command
	ldi		r17,8			; backlight
	call	sendTWI_Byte
	
	rjmp	sendTWI_Stop
	
;
; LCD Clear - Clears the LCD and places the cursor at location 0
; r24 holds the LCD I2C address
; r17 holds the lower 4 bits
;
LCD_Clear:
	call	sendTWI_Start
	brne	LCD_serror

	mov		r16,r24			; use this address
	add		r16,r16			; and move over the r/w bit
	call	sendTWI_SLA
	brne	LCD_serror

	ldi		r16,0x01		; set DDRAM address command
	ldi		r17,8			; backlight
	call	sendTWI_Byte
	
	rjmp	sendTWI_Stop
;
; LCD_Text - send a null terminated string to the LCD for displaying
; Z points to the string,
; r24 is the address of the LCD
LCD_Text:
	call	sendTWI_Start
	brne	LCD_serror

	mov		r16,r24			; use this address
	add		r16,r16			; and move over the r/w bit
	call	sendTWI_SLA
	brne	LCD_serror

	ldi		r17,(1<<3)|(1<<0)			; backlight[3] + data byte[0]
LCD_Text_loop:
	lpm		r16,Z+
	tst r16 ; test for null terminator
	breq LCD_Text_done
	call	sendTWI_Byte
	brne	LCD_serror
	rjmp	LCD_Text_loop

LCD_Text_done:
LCD_Number_done:
LCD_serror:
	rjmp	sendTWI_Stop


LCD_Number:
	push r16
	push r19
	cpi r16, 100
	brge LCD_Number_3dig
	cpi r16, 10
	brge LCD_Number_2dig

	push r16

	ldi r19, 0
	rcall LCD_Digit

	pop r16
	cpi r16, 0
	breq LCD_Number_zero

	rjmp LCD_Number_2dig

	LCD_Number_3dig:
	ldi r16, '-'
	rcall LCD_Char
	ldi r16, '-'
	rcall LCD_Char
	rjmp LCD_Number_end

	LCD_Number_2dig:

	ldi ZL, LOW(BCD_MEM)
	ldi ZH, HIGH(BCD_MEM)
	clr rBin1H
	mov rBin1L, r16
	rcall Bin2ToBcd

	LCD_Number_loop:
	ld r19, Z+
	rcall LCD_Digit
	dec r0
	brne LCD_Number_loop
	rjmp LCD_Number_end

	LCD_Number_zero:
	ldi r19, 0
	rcall LCD_Digit

	LCD_Number_end:
	pop r19
	pop r16
	ret

LCD_Digit:
	; push r16
	; push r17

	call	sendTWI_Start
	brne	LCD_serror

	mov		r16,r24			; use this address
	add		r16,r16			; and move over the r/w bit
	rcall	sendTWI_SLA
	brne	LCD_serror

	ldi		r17, 9			; backlight + data byte
	
	ldi r16, '0'
	add r16, r19
	
	rcall	sendTWI_Byte
	brne	LCD_serror

	rjmp	sendTWI_Stop

	; pop r17
	; pop r16
	ret

LCD_Char:
	call	sendTWI_Start
	brne	LCD_serror

	mov		r16,r24			; use this address
	add		r16,r16			; and move over the r/w bit
	rcall	sendTWI_SLA
	brne	LCD_serror

	ldi		r17, 9			; backlight + data byte

	mov r16, r19
	
	rcall	sendTWI_Byte
	brne	LCD_serror

	rjmp	sendTWI_Stop

	; pop r17
	; pop r16
	ret

;
; LCDSetup - setup the LCD display connected at I2C port in r16
;
LCD_Setup:
	call	sendTWI_Start						; send start bit
	breq	LCD_Setup_0
	jmp		LCD_Setup_Err
LCD_Setup_0:
	mov		r16,r24
	add		r16,r16
	call	sendTWI_SLA
	breq	LCD_Setup_1
	jmp		LCD_Setup_Err
LCD_Setup_1:
	clr		r18
	clr		r19
	call	sendTWI_Nibble
	call	sendTWI_Stop

	ldi		r18,LOW(5)
	ldi		r19,HIGH(5)
;	call	delay_ms							; wait 5 ms
	
;
; Send the first of three 0x30 to the display
;

	call	sendTWI_Start						; send start bit
	breq	LCD_Setup_2
	jmp		LCD_Setup_Err
LCD_Setup_2:
	mov		r16,r24
	add		r16,r16
	call	sendTWI_SLA
	breq	LCD_Setup_3
	jmp		LCD_Setup_Err
LCD_Setup_3:
	ldi		r18,0x30
	clr		r19
	call	sendTWI_Nibble
	call	sendTWI_Stop

	ldi		r18,LOW(5)
	ldi		r19,HIGH(5)
;	call	delay_ms							; wait 5 ms
	
;
; Send the second of three 0x30 to the display
;

	call	sendTWI_Start						; send start bit
	brne	LCD_Setup_Err
	mov		r16,r24
	add		r16,r16
	call	sendTWI_SLA
	brne	LCD_Setup_Err
	ldi		r18,0x30
	clr		r19
	call	sendTWI_Nibble
	call	sendTWI_Stop

	ldi		r18,LOW(5)
	ldi		r19,HIGH(5)
;	call	delay_ms							; wait 5 ms
	
;
; Send the third of three 0x30 to the display
;

	call	sendTWI_Start						; send start bit
	brne	LCD_Setup_Err
	mov		r16,r24
	add		r16,r16
	call	sendTWI_SLA
	brne	LCD_Setup_Err
	ldi		r18,0x30
	clr		r19
	call	sendTWI_Nibble
	call	sendTWI_Stop

	
;
; Send 0x28 to the display to reset to 4 bit mode
;

	call	sendTWI_Start						; send start bit
	brne	LCD_Setup_Err
	mov		r16,r24
	add		r16,r16
	call	sendTWI_SLA
	brne	LCD_Setup_Err
	ldi		r18,0x28
	clr		r19
	call	sendTWI_Nibble
	call	sendTWI_Stop

	
	ldi		ZL,LOW(LCD_init_String0*2)
	ldi		ZH,HIGH(LCD_init_String0*2)
	ldi		r25,2								; all 2 bytes
	ldi		r17,8								; lower 4 bits zero (Backlight on)
	call	SendTWI_Data
	ret

LCD_Setup_Err: