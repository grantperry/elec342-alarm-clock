button_always_actions:
	push r16
	clr r16
	rcall setAlarmCounter
	pop r16
	ret