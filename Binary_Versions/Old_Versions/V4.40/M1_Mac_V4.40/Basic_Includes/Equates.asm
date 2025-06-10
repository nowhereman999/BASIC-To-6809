* General Equates for the COCO
CURPOS  	EQU     $0088   ; BASIC's CURSOR position location
KeyBuff 	EQU     $01DA   ; Use BASIC's Casette buffer for the keyboard buffer
PIA0            EQU     $FF00   ; PERIPHERAL INPUT ADAPTER #0
DA		EQU	$FF20	; D/A converter
PIA1            EQU     $FF20   ; PERIPHERAL INPUT ADAPTER #1
SAMREG		EQU     $FFC0	; SAM control register
EXECAddress	EQU	$009D	; EXECute address
SKP2		EQU	$8C	; Used to skip two bytes
CR		EQU 	$0D	; Carriage return
LPTBTD		EQU	$0095	; Baud Rate ($0058 = 600 baud)
LPTLND		EQU	$0097	; Carriage Return Delay (Default is $0001)
LPTWID		EQU	$009B	; Printer Width (Default is $0084 = 132)
LPTPOS		EQU	$009C	; Printer Position
