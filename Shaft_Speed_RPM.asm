		
			.INCLUDE "M32DEF.INC"

			.ORG $0000
 				RJMP MAIN
			.ORG $0008
				RJMP T2_OV_ISR
			.ORG $0100

	

MAIN:			.def rBin1L=R0
				.def rBin1H=R1
				.def rBin2L=R2
				.def rBin2H=R3
				.def rmp=r25
;========================================================================================================
				.EQU	LCD_PRT = PORTA 	
				.EQU	LCD_DDR = DDRA 		
				.EQU	LCD_PIN = PINA 		
				.EQU	LCD_RS = 0 		
				.EQU	LCD_RW = 1 		
				.EQU	LCD_EN = 2 
;========================================================================================================
		.
				.DEF DIGIT1=R5     ; highest value
				.DEF DIGIT2=R6
				.DEF DIGIT3=R7
				.DEF DIGIT4=R8
				.DEF DIGIT5=R9     ; lowest value

;========================================================================================================

				LDI R16,HIGH(RAMEND)
				OUT SPH,R16
				LDI R16,LOW(RAMEND)
				OUT SPL,R16

				LDI R23,60         ; mohasebeye RPM    
				LDI R24,$FF
				OUT DDRC,R24
				OUT DDRD,R24


				LDI ZH,$00         ; niazmand tabe ASCII
				LDI ZL,$05

;========================================================================================================
	
	
				LDI	R21,0xFF;		
				OUT LCD_DDR, R21
				OUT LCD_DDR, R21
				LDI	 R16,0x33		
	            CALL CMNDWRT		
				CALL DELAY_2ms		
				LDI	 R16,0x32		
				CALL CMNDWRT		
				CALL DELAY_2ms		
				LDI	 R16,0x28		
				CALL CMNDWRT		
				CALL DELAY_2ms		
				LDI	 R16,0x0E		
				CALL CMNDWRT		
				LDI	 R16,0x01		
				CALL CMNDWRT		
				CALL DELAY_2ms		
				LDI	R16,0x06		
				CALL	CMNDWRT	
				LDI R16,$0C
				CALL CMNDWRT	


;========================================================================================================

				LDI R20,(1<<OCIE2)    ; faal kardan timer 2 jahat intrupt dar har 1ms
				OUT TIMSK,R20
				SEI
				LDI R20,127
				OUT OCR2,R20
				LDI R20,$0B
				OUT TCCR2,R20

;========================================================================================================
		
				CBI DDRB,0            ; faal kardan timer 0 jahat shomaresh pulse vurudi
				LDI R17,$06
				OUT TCCR0,R17
				CLR R21
				OUT TCNT0,R21

;========================================================================================================

AGAIN:			IN R20,TCNT0          ; halghe binahayat darhale shomaresh pulse
				IN R17,TIFR
				SBRS R17,TOV0
				RJMP AGAIN
				RJMP HERE

		
;========================================================================================================

T2_OV_ISR:		RCALL RPM 			  ; tabe intrupt --> ferestadan ruye lcd va sefr kardan shomarande
				CLR R21
				OUT TCNT0,R21
				RETI

;========================================================================================================

HERE:			LDI R22,1<<TOV0		  ; darsurat sarriz shomarande --> 0 kardan bit sarriz va shurue mojadad shomaresh
				OUT TIFR,R22
				CLR R22
				OUT TCNT0,R22
				RJMP AGAIN	

;========================================================================================================
				
RPM:			MUL R20,R23
				RCALL Bin2ToAsc5      ; jahat mohasebe code ASCII adad mojud ruye R1:R0
				RCALL LCD             ; ersal adad 5 raghami be LCD  
			                                
				RET									
;========================================================================================================
LCD:			
				MOV R16,DIGIT1
				RCALL DATAWRT
				MOV R16,DIGIT2
				RCALL DATAWRT
				MOV R16,DIGIT3
				RCALL DATAWRT
				MOV R16,DIGIT4
				RCALL DATAWRT
				MOV R16,DIGIT5
				RCALL DATAWRT
				LDI R16,$80
				RCALL CMNDWRT
				RCALL SDELAY
				RCALL SDELAY
				RCALL SDELAY
				RCALL SDELAY
				NOP
				NOP
				NOP
				NOP
				NOP
								
				RET

;-------------------------------------------------------
CMNDWRT:

	MOV	 R27,R16
	ANDI R27,0xF0
	IN	 R26,LCD_PRT
	ANDI R26,0x0F
	OR	 R26,R27
	OUT  LCD_PRT,R26		
	CBI	 LCD_PRT,LCD_RS		
	CBI	 LCD_PRT,LCD_RW		
	SBI	 LCD_PRT,LCD_EN		
	CALL SDELAY				
	CBI	 LCD_PRT,LCD_EN		

	CALL DELAY_100us		

	MOV	 R27,R16
	SWAP R27
	ANDI R27,0xF0
	IN	 R26,LCD_PRT
	ANDI R26,0x0F
	OR	 R26,R27
	OUT  LCD_PRT,R26		
	SBI	 LCD_PRT,LCD_EN		
	CALL SDELAY				
	CBI	 LCD_PRT,LCD_EN		

	CALL DELAY_100us		
	RET

;-------------------------------------------------------
DATAWRT:
	MOV	R27,R16
	ANDI R27,0xF0
	IN	R26,LCD_PRT
	ANDI R26,0x0F
	OR	R26,R27
	OUT LCD_PRT,R26			
	SBI	LCD_PRT,LCD_RS		
	CBI	LCD_PRT,LCD_RW		
	SBI	LCD_PRT,LCD_EN	
	CALL	SDELAY			
	CBI	LCD_PRT,LCD_EN		
	
	MOV	 R27,R16
	SWAP R27
	ANDI R27,0xF0
	IN	 R26,LCD_PRT
	ANDI R26,0x0F
	OR	 R26,R27
	OUT  LCD_PRT,R26		
	SBI	 LCD_PRT,LCD_EN		
	CALL SDELAY				
	CBI	 LCD_PRT,LCD_EN		
	
	CALL DELAY_100us		
	RET

;-------------------------------------------------------
SDELAY:
	NOP
	NOP
	RET

;-------------------------------------------------------
DELAY_100us:
	PUSH	R17
	LDI		R17,60
DR0:CALL	SDELAY
	DEC		R17
	BRNE	DR0
	POP		R17
	RET

;-------------------------------------------------------
DELAY_2ms:
	PUSH	R17
	LDI		R17,20
LDR0:	
	CALL	DELAY_100us
	DEC		R17
	BRNE	LDR0
	POP		R17
	RET


Bin2ToAsc5:rcall Bin2ToBcd5 ; convert binary to BCD
	ldi rmp,4 ; Counter is 4 leading digits
	mov rBin2L,rmp
Bin2ToAsc5a:
	ld rmp,z ; read a BCD digit
	tst rmp ; check if leading zero
	brne Bin2ToAsc5b ; No, found digit >0
	ldi rmp,' ' ; overwrite with blank
	st z+,rmp ; store and set to next position
	dec rBin2L ; decrement counter
	brne Bin2ToAsc5a ; further leading blanks
	ld rmp,z ; Read the last BCD
Bin2ToAsc5b:
	inc rBin2L ; one more char
Bin2ToAsc5c:
	subi rmp,-'0' ; Add ASCII-0
	st z+,rmp ; store and inc pointer
	ld rmp,z ; read next char
	dec rBin2L ; more chars?
	brne Bin2ToAsc5c ; yes, go on
	sbiw ZL,5 ; Pointer to beginning of the BCD
	ret ; done

Bin2ToBcd5:
	push rBin1H ; Save number
	push rBin1L
	ldi rmp,HIGH(10000) ; Start with tenthousands
	mov rBin2H,rmp
	ldi rmp,LOW(10000)
	mov rBin2L,rmp
	rcall Bin2ToDigit ; Calculate digit
	ldi rmp,HIGH(1000) ; Next with thousands
	mov rBin2H,rmp
	ldi rmp,LOW(1000)
	mov rBin2L,rmp
	rcall Bin2ToDigit ; Calculate digit
	ldi rmp,HIGH(100) ; Next with hundreds
	mov rBin2H,rmp
	ldi rmp,LOW(100)
	mov rBin2L,rmp
	rcall Bin2ToDigit ; Calculate digit
	ldi rmp,HIGH(10) ; Next with tens
	mov rBin2H,rmp
	ldi rmp,LOW(10)
	mov rBin2L,rmp
	rcall Bin2ToDigit ; Calculate digit
	st z,rBin1L ; Remainder are ones
	sbiw ZL,4 ; Put pointer to first BCD
	pop rBin1L ; Restore original binary
	pop rBin1H
	ret ; and return


Bin2ToDigit:
	clr rmp ; digit count is zero
Bin2ToDigita:
	cp rBin1H,rBin2H ; Number bigger than decimal?
	brcs Bin2ToDigitc ; MSB smaller than decimal
	brne Bin2ToDigitb ; MSB bigger than decimal
	cp rBin1L,rBin2L ; LSB bigger or equal decimal
	brcs Bin2ToDigitc ; LSB smaller than decimal
Bin2ToDigitb:
	sub rBin1L,rBin2L ; Subtract LSB decimal
	sbc rBin1H,rBin2H ; Subtract MSB decimal
	inc rmp ; Increment digit count
	rjmp Bin2ToDigita ; Next loop
Bin2ToDigitc:
	st z+,rmp ; Save digit and increment
	ret ; done			
