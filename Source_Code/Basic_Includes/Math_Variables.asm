; Math Variables
; Used by the following routines:
; Math_Integer64.asm
; Math_FloatingPointLB
; Math_IEEE_754_Double_64bit.asm
;
; Temporary storage (Do not re-arrange the order of these values)
Big8_01   	RMB 10   ; Reserve 10 bytes
Big8_02   	RMB 10   ; Reserve 10 bytes
Big8_03   	RMB 8   ; Reserve 8 bytes
Big8_04   	RMB 8   ; Reserve 8 bytes
Big8_05   	RMB 8   ; Reserve 8 bytes
Big8_06   	RMB 8   ; Reserve 8 bytes
Big8_07   	RMB 8   ; Reserve 8 bytes
Big8_08   	RMB 8   ; Reserve 8 bytes
Medium4_01   	RMB 4   ; Reserve 4 bytes
Medium4_02	RMB 4   ; Reserve 4 bytes
Short1_01	RMB 1	; Reserve 1 byte
Short1_02	RMB 1   ; Reserve 1 byte
Short1_03	RMB 1   ; Reserve 1 byte
Short1_04	RMB 1   ; Reserve 1 byte
Short1_05	RMB 1   ; Reserve 1 byte

; 64 Bit Integer Stuff
Temp_Dividend   EQU Big8_01   ; dividend/multiplicand - Value1
Temp_Divisor    EQU Big8_02   ; divisor/multiplier  - Value2
DividendTemp    EQU Big8_03   ; 8-byte Temp
Quotient        EQU Big8_04   ; 8-byte quotient (16 necessary for 64 bit multiplication, result is 128 bit)
Remainder       EQU Big8_05   ; 8-byte remainder ( Also part of 128 bit result of multiplication)
RoundFlag	EQU Short1_01 ; If = 0 then no rounding will be done
Sign_Dividend 	EQU Short1_02 ; Sign of dividend (0 = positive, 1 = negative)
Sign_Divisor  	EQU Short1_03 ; Sign of divisor (0 = positive, 1 = negative)


; Memory locations for input and output
; Used in FP to 64 bit Signed and FP to UnSigned in LB
UINT64_OUT  	EQU Big8_01   ; 8-byte buffer for unsigned 64-bit integer
SINT64_OUT  	EQU Big8_02   ; 8-byte buffer for signed 64-bit integer

; Memory locations
S64_IN      	EQU Big8_06   ; Signed 64-bit integer input
U64_IN      	EQU Big8_07   ; Unsigned 64-bit integer input
DOUBLE_OUT  	EQU Big8_08   ; IEEE 754 double output (8 bytes)
SHIFT_COUNT 	EQU Short1_04 ; Temporary storage for shift count
mantissa_Overflow EQU Short1_01 ; Temporary storage if we should add one to the exponent while rounding the mantissa

S32_OUT     	EQU Medium4_01   ; Signed 32-bit integer output
U32_OUT     	EQU Medium4_01   ; Unsigned 32-bit integer output

SIGN_TEMP   	EQU Short1_05 ; Temporary storage for sign

;
; Memory locations
;NUM1        	EQU 	Value1   	; 8-byte multiplicand
;NUM2        	EQU 	Value2   	; 8-byte multiplier
RESULT      	EQU 	Big8_01		; 128 bit value used in Integer64 (Multiplying)
I_INDEX     	EQU 	Short1_01 	; Byte for i loop index
J_INDEX     	EQU 	Short1_02 	; Byte for j loop index
;Sign_Value1 	EQU 	Short1_03 	; Sign of Value1 (0 = positive, 1 = negative)
;Sign_Value2  	EQU 	Short1_04 	; Sign of Value2 (0 = positive, 1 = negative)

;LB5_IN      EQU Quotient        ; Lennart Benschop 5-byte float input
;LB5_OUT     EQU Remainder       ; Lennart Benschop 5-byte float output

; Constants
; MAX_EXP     EQU 158      ; Maximum exponent for 32-bit numbers (128 + 30)
; MAX_EXP     EQU 191      ; Maximum exponent for 64-bit numbers (128 + 63)