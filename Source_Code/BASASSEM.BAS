' compileoptions -s20

' Example how to interface BASIC and assembly code

DIM N AS INTEGER

5 CLS: PRINT @32,
10 INPUT "ENTER A NUMBER FROM -32000 TO 32000"; N
20 PRINT N; "+ 7 IS";
30 GOSUB 1000 ' Goto assembly code and do an add
35 PRINT N
40 INPUT "WHAT IS YOUR NAME"; Name$
50 GOSUB LearnStrings ' Copy the Name$ string to the top of the screen
60 PRINT "NICE NAME "; Name$
70 END

1000 ' Example of some assembly code

' ADDASSEM:
; Comments in assembly code must start with a semicolon or an asterisks
; Comment is BASIC code must use apostrophe or REM
; Let's access the BASIC numeric variable N
; and multiply it by 2
    LDD     _Var_N  ; Get the signed 16 variable N into D
    ADDD    #$0007  ; Add 7
    STD     _Var_N  ; Store the result back into variable N
; Can have the RTS here or use RETURN just past the ENDASSEM:
' ENDASSEM:
RETURN

LearnStrings:
' ADDASSEM:
; Example of how to access a string variable in assembly code
; Copy the string to the top of the text screen
    LDB     _StrVar_Name    ; Get the length of the string
    LDU     #_StrVar_Name+1 ; Point at the actual string data
    LDX     #$400           ; Point at the top left corner of the text screen
!   LDA     ,U+             ; Get the next character
    STA     ,X+             ; Store the character on the screen
    DECB                    ; Decrement the counter
    BNE     <               ; Loop until counter is 0
    RTS
' ENDASSEM:

' The compiler adds a prefix to variables (which you can see at the beginning of the .asm file it genereates)
' numeric variables are prefixed with _Var_ - numeric variables are signed 16 bit numbers
' string variables are prefixed with _StrVar_ - strings are stored beginning at the address of the variable
' the format is - byte 0 is the length of the string, the actual string starts at byte 1
'
