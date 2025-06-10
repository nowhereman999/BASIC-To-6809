
; Calculates the 8 bit root and 9 bit remainder of a 16 bit unsigned integer in
; Numberl/Numberh. The result is always in the range 0 to 255 and is held in
; Root, the remainder is in the range 0 to 511 and is held in Remh/Reml
;
; partial results are held in temph/templ
;
; This routine is the complement to the integer square program.
;
; Destroys A, X registers.
; Modeified to use B for Root and return with result in B

SqRoot16:
	STD	Numberh		; save number to get the square root
	LDD	#$0000		; clear A & B
	STA	Reml		; clear remainder low byte
	STA	Remh		; clear remainder high byte
;	STA	Root		; clear Root
	LDX	#$08		; 8 pairs of bits to do
Loop
	ASLB			;	Root		; Root = Root * 2

	ASL	Numberl		; shift highest bit of number ..
	ROL	Numberh		;
	ROL	Reml		; .. into remainder
	ROL	Remh		;

	ASL	Numberl		; shift highest bit of number ..
	ROL	Numberh		;
	ROL	Reml		; .. into remainder
	ROL	Remh		;

;	LDA	Root		; copy Root ..
;	STA	templ		; .. to templ
	STB	templ		; .. to templ	
	
;	LDA	#$00		; clear byte
;	STA	temph		; clear temp high byte
	CLR	temph		; clear temp high byte

	ORCC 	#$01       	; SEC			; +1
	ROL	templ		; temp = temp * 2 + 1
	ROL	temph		;

	LDA	Remh		; get remainder high byte
	CMPA	temph		; comapre with partial high byte
	BCS	Next		; skip sub if remainder high byte smaller

	BNE	Subtr		; do sub if <> (must be remainder>partial !)

	LDA	Reml		; get remainder low byte
	CMPA	templ		; comapre with partial low byte
	BCS	Next		; skip sub if remainder low byte smaller

				; else remainder>=partial so subtract then
				; and add 1 to root. carry is always set here
Subtr
	LDA	Reml		; get remainder low byte
	SUBA	templ		; subtract partial low byte
	STA	Reml		; save remainder low byte
	LDA	Remh		; get remainder high byte
	SUBA	temph		; subtract partial high byte
	STA	Remh		; save remainder high byte

;	INC	Root		; increment Root
	INCB
Next
	LEAX  	-1,X		; decrement bit pair count
	BNE	Loop		; loop if not all done
    	CLRA			; clear A
	RTS			; Return with result in D

;Root		FCB 0		; square root
Remh		FCB 0		; remainder low byte
Reml		FCB 0 		; remainder high byte
Numberh		FCB 0		; number to find square root of low byte
Numberl		FCB 0   	; number to find square root of high byte
temph		FCB 0		; temp partial low byte
templ		FCB 0		; temp partial high byte
