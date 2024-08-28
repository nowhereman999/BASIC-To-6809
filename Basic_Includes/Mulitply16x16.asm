* I made a fix of the original source code,
* Then I tweaked it a little to use LDD and STD where possible
* This code has been tested and does work fine on the 6809

;	Title:		        16-bit multiplication
;	Name:			MUL16
;	Purpose:		Multiply two unsigned 16-bit words and return a 32-bit unsigned product.
;	Entry:			TOP OF STACK
;				High byte of return address
;				Low  byte of return address
;				High byte of multiplier
;				Low  byte of multiplier
;				High byte of multiplicand
;				Low  byte of multiplicand
;
;	Exit:			Product = multiplicand * multiplier
;
;				TOP OF STACK
;				High byte of high word of product
;				Low byte of high word of product
;				High byte of low word of product
;				Low byte of Low word of product
;
;	Time:	Approximately 200 cycles
;
;	Size:	Program	64 bytes
;		Data	2 stack bytes
;
MUL16:
;
; CLEAR PARTIAL PRODUCT IN FOUR STACK BYTES
;
	LDU	,S		; SAVE RETURN ADDRESS
;	CLRA			; CLEAR PARTIAL PRODUCT ON STACK
;	CLRB
        LDD     #$0000
	STD	,S		; USE BYTES OCCUPIED BY RETURN ADDRESS
	PSHS	D		; PLUS 2 EXTRA BYTES ON TOP OF STACK 
;
; MULTIPLY LOW BYTE OF MULTIPLIER TIMES LOW BYTE 
; OF MULTIPLICAND
;
	LDA	5,S		; GET LOW BYTE OF MULTIPLIER
	LDB	7,S		; GET LOW BYTE OF MULTIPLICAND
	MUL			; MULTIPLY BYTES
;	STB	3,S		; STORE LOW BYTE OF PRODUCT
;	STA	2,S		; STORE HIGH BYTE OF PRODUCT
        STD     2,S		; STORE LOW BYTE OF PRODUCT & HIGH BYTE OF PRODUCT
;
; MULTIPLY LOW BYTE OF MULTIPLIER TIMES HIGH BYTE
; OF MULTIPLICAND
;
;	LDA	5,S		; GET LOW BYTE OF MULTIPLIER
;	LDB	6,S		; GET HIGH BYTE OF MULTIPLICAND
        LDD     5,S		; GET LOW BYTE OF MULTIPLIER & HIGH BYTE OF MULTIPLICAND
	MUL			; MULTIPLY BYTES
	ADDB	2,S		; ADD LOW BYTE OF PRODUCT T0 PARTIAL PRODUCT
	STB	2,S		; 
	ADCA	#0		; ADD HIGH BYTE OF PRODUCT PLUS CARRY TO PARTIAL PRODUCT
	STA	1,S		; STORE HIGH BYTE OF PRODUCT
;	
;	MULTIPLY HIGH BYTE OF MULTIPLIER TIMES LOW BYTE
;	OF MULTIPLICAND
;
	LDA	4,S		; GET HIGH BYTE OF MULTIPLIER
	LDB	7,S		; GET LOW BYTE OF MULTIPLICAND
	MUL			; MULTIPLY BYTES
	ADDB	2,S		; ADD LOW BYTE OF PRODUCT T0 PARTIAL PRODUCT
	STB	2,S		; 
	ADCA	1,S		; ADD HIGH BYTE OF PRODUCT PLUS CARRY TO PARTIAL PRODUCT
	STA	1,S		; 
	BCC	>		; BRANCH IF N0 CARRY ELSE INCREMENT MOST SIGNIFICANT
				; BYTE 0F PARTIAL PRODUCT
	INC	,S		; 

;	
;	MULTIPLY HIGH BYTE OF MULTIPLIER TIMES HIGH BYTE
;	OF MULTIPLICAND
;
!	LDA	4,S		; GET HIGH BYTE OF MULTIPLIER
	LDB	6,S		; GET HIGH BYTE OF MULTIPLICAND
	MUL			; MULTIPLY BYTES
	ADDB	1,S		; ADD LOW BYTE OF PRODUCT T0 PARTIAL PRODUCT
	ADCA	,S		; ADD HIGH BYTE OF PRODUCT PLUS CARRY TO PARTIAL PRODUCT

;	HIGH BYTES OF PRODUCT END UP IN D
;	RETURN WITH PRODUCT AT TOP OF STACK
;	SAMPLE EXECUTION
;	GET LOWER 16 BITS OF PRODUCT FROM STACK
;	REMOVE PARAMETERS FROM STACK
;	PUT PRODUCT AT TOP OF STACK
;	EXIT T0 RETURN ADDRESS

* At this point D has the High 16 bits of the product and X has the Low 16 bits of the product
* For the compiler it's best if we just return with the Lowest 16 bits of the product in D
;	LDY	2,S             * for the compiler, we want to use D for the product
        TFR     D,Y             ; Y = Product High 16 bits
	LDD	2,S             ; D = Product Least Significant 16 bits (all compiler needs)
	LEAS	4,S             ; Fix stack pointer
;	PSHS	D,X             ; Save product
	JMP	,U
