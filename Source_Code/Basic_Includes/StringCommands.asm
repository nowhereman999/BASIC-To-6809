; String Commands used by the BASIC compiler

StrComTemp  FCB   $00   ; String Command Temp space

; StrCommandINSTR
; Input values are on the stack as:
; ,S = startPos then thingToFind$ then stringToSearch$
StrCommandINSTR:
      PULS  D
      STD   @Return+1
      LEAX  2,S         ; X points at string data of the thingToFind$
      LEAU  ,X          ; U now points at the start of thingToFind$
      LDB   1,S         ; Get the length of the thingToFind$
      BEQ   @ReturnZero ; If size of string is zero then return with a zero
      STB   StrComTemp  ; Save number of bytes to match for comparison
      ABX               ; X points at the start of the stringToSearch$
      LDB   ,X+         ; Get the size of the stringToSearch$
      BEQ   @ReturnZero ; If size of string is zero then return with a zero
      CMPB  ,S          ; Compare the length of the stringToSearch$ with the starting point to test at
      BLO   @ReturnZero ; If B is < than the start length then we are done return with a value of zero
      CLRA
      LEAY  D,X         ; Y is the end of the stringToSearch$
      LDB   ,S          ; Get the position to start search from
      DECB
      PSHS  X,Y         ; Save the start address of the stringToSearch$ & The end address of stringToSearch$ on the stack
      ABX               ; X now points at the position to start searching from
@MainLoop:
      PSHS  U           ; Save the search start location on the stack
      LDA   ,U          ; Get the first byte to search for
@DidWeMatchLoop:
      CMPA  ,X+
      BEQ   @FoundFirst
      CMPX  4,S         ; Have we reached the end of the stringToSearch$ address
      BNE   @DidWeMatchLoop
      BRA   @ReturnZeroStack
@FoundFirst:
      PSHS  X           ; Save X pointer (pointing to the next value)
      LDB   StrComTemp
      LEAU  1,U         ; start checking at the 2nd character
!     DECB
      BEQ   @Done       ; We found a match :)
      CMPX  6,S         ; Have we reached the end of the stringToSearch$ address
      BEQ   @EndWhileMatching
      LDA   ,U+
      CMPA  ,X+
      BEQ   <
      PULS  X
      LDU   ,S          ; Restore U
      BRA   @DidWeMatchLoop
@Done:
      LDD   ,S          ; D = start of match address + 1
      SUBD  4,S         ; D = (start of match address + 1) - (start address + 1)
      TFR   B,A         ; A = location in the string where the match started
      LEAX  9,S
      BRA   @Out        ; Clear up the stack and save A on the stack
@ReturnZero:
      CLRA
      LEAX  1,S         ; X points at the thingToFind$
      BRA   @Out  
@ReturnZeroStack:
      CLRA
      BRA   @GotA
; If we get here fix the stack then return zero
@EndWhileMatching:
      CLRA
      LEAS  2,S         ; Move the stack past Temp X
@GotA:
      LEAX  7,S         ; X points at the thingToFind$
@Out:
      LDB   ,X+         ; Get the size of thingToFind$
      ABX               ; move past the thingToFind$
      LDB   ,X          ; Get the size of stringToSearch$
      ABX               ; move to the last byte of the stringToSearch$
      LEAS  ,X          ; Fix the stack
      STA   ,S          ; Save the length in A on the stack
@Return
      JMP   >$FFFF

; StrCommandLeft
; ,S = length of new string
; 1,S = String to copy from
; Destination string will be at ,S with the first byte being the length of the new string
StrCommandLeft:
      PULS  Y           ; Get the return address off the stack
      LDD   ,S++        ; A = the new length, B = Current length, move the stack
      STA   @SeldMod+1  ; Save new length
      LEAX  ,S          ; X points at the start of the original string
      ABX               ; X points at the end of the string
      TFR   A,B         ; B = # of bytes to copy
      CLRA
      LEAU  D,S         ; U = end of bytes to copy
!     LDA   ,-U         ; Get a source byte, move up
      STA   ,-X         ; Write a destination byte
      DECB              ; Decrement the counter
      BNE   <           ; Loop
@SeldMod:
      LDB   #$FF        ; Restore length of new string
      STB   ,-X         ; Save new value
      LEAS  ,X          ; Fix the stack
@Return:
      JMP   ,Y          ; Return

; StrCommandMid2Arg
; ,S = Start of string to copy from
; 1,S = String to copy from
; Destination string will be at ,S with the first byte being the length of the new string
StrCommandMid2Arg:
      PULS  Y                 ; Get the return address off the stack
      LDB   1,S               ; B = Length of original string
      SUBB  ,S+               ; B = Length of original string - mid point = amount to keep
      INCB
      BRA   @UseRightCode     ; reuse the rest of the RIGHT$ code
; StrCommandRight
; ,S = length of new string
; 1,S = String to copy from
; Destination string will be at ,S with the first byte being the length of the new string
StrCommandRight:
      PULS  Y                 ; Get the return address off the stack
      LDB   ,S+               ; Get the new length, move the stack
@UseRightCode:
      STB   @SeldMod+1        ; Save new length
      SUBB  ,S
      CLRA
      NEGB
      LEAS  D,S
@SeldMod:
      LDB   #$FF              ; Restore length of new string
      STB   ,S                ; Save new value, move the stack
@Return:
      JMP   ,Y          ; Return

; StrCommandMid
; ,S = length of new string
; 1,S = Start of string to copy from
; 2,S = String to copy from
; Destination string will be at ,S with the first byte being the length of the new string
StrCommandMid:
      PULS  Y                 ; Get the return address off the stack
      LDD   ,S++            ; A = the new length, B = Mid point start, move the stack
      STA   @SeldMod+1      ; Save new length
      STB   @SelfMod2+1     ; Save the mid point
      LDB   ,S+             ; Get the length of the string
      LEAX  ,S
      ABX                     ; X points just past the string, ready to be copied too
@SelfMod2:
      ADDA  #$FF            ; A = Length + Mid point
      TFR   A,B
      DECB
      CLRA
      LEAU  D,S             ; U = source location
      LDB   @SeldMod+1      ; Get new length
!     LDA   ,-U             ; Get a source byte, move up
      STA   ,-X             ; Write a destination byte
      DECB                    ; Decrement the counter
      BNE   <               ; Loop
@SeldMod:
      LDB   #$FF            ; Restore length of new string
      STB   ,-X             ; Save new value
      LEAS  ,X              ; Fix the stack
@Return:
      JMP   ,Y          ; Return

; StrCommandRTrim
; ,S = String to remove spaces from the end of the string
; Destination string will be at ,S with the first byte being the length of the new string
StrCommandRTrim:
      PULS  Y                 ; Get the return address off the stack
        LDB     ,S+
        CLRA
        LEAX    D,S             ; X = point just after the string
        BRA     @TrimRight
;
; StrCommandTrim
; ,S = String to remove spaces from the beginning and end of the string
; Destination string will be at ,S with the first byte being the length of the new string
StrCommandTrim:
      PULS  Y                 ; Get the return address off the stack
        LDB     ,S+
        CLRA
        LEAX    D,S             ; X = point just after the string
!       LDA     ,S+
        CMPA    #' '            ; Is it a space?
        BNE     @TrimRight
        DECB    
        BNE     <
        CLR     ,-S
        BRA     @Return         ; New string is empty
@TrimRight:
        LEAU    ,X              ; U = X
!       LDA     ,-U
        CMPA    #' '            ; Is it a space?
        BNE     >
        DECB    
        BNE     <
        LEAS    ,X
        CLR     ,-S
        BRA     @Return         ; New string is empty
!       LEAU    1,U
        STB     @SelfMod+1      ; Save the length of the new string
!       LDA     ,-U
        STA     ,-X
        DECB
        BNE     <
@SelfMod:
        LDB     #$FF
        STB     ,-X             ; Save new value
        LEAS    ,X              ; Fix the stack
@Return:
      JMP   ,Y          ; Return

; StrCommandLTrim
; ,S = String to remove spaces from the beginning of the string
; Destination string will be at ,S with the first byte being the length of the new string
StrCommandLTrim:
      PULS  Y                 ; Get the return address off the stack
        LDB     ,S+
        CLRA
        LEAX    D,S             ; X = point just after the string
        LEAU    ,X              ; U = X
!       LDA     ,S+
        CMPA    #' '            ; Is it a space?
        BNE     >
        DECB    
        BNE     <
        CLR     ,-S
        BRA     @Return         ; New string is empty
!       STB     ,--S             ; Save new value
@Return:
      JMP   ,Y          ; Return

; StrString
; Copy ,S copies of the string @ 1,S
StrString:
      PULS  Y                 ; Get the return address off the stack
      LDD   ,S
      MUL
      CMPD  #255      ; If the new string is going to be
      BLO   >           ; If it's lower than 255 then it's good
      LEAS  1,S         ; Otherwise just keep one string on the stack
      BRA   @Return
!     STB   @SelfMod+1  ; Save the new string length
      LDD   ,S++        ; A = repeat count, B = length of the current string
      DECA              ; Leave the first string as is, so one less to copy
      STA   StrComTemp  ; Save the repeat counter
      STB   @SelfMod1+1 ; Self mod string length
      CLRA
      LEAX  D,S         ; X points at the end of the string
@SelfMod1:
      LDB   #$FF        ; Self mod string length
!     LDA   ,-X
      STA   ,-S
      DECB
      BNE   <
      DEC   StrComTemp
      BNE   @SelfMod1
@SelfMod:
      LDB   #$FF
      STB   ,-S
@Return:
      JMP   ,Y          ; Return
;
; StrStringASCIIcode
; Copy ,S copies of the chraacter @ 1,S
StrStringASCIIcode:
      PULS  Y                 ; Get the return address off the stack
      LDD   ,S++            ; A = the count, B = ASCII character to repeat
      STA   @SelfMod+1      ; Self mode this will be the new length of the string
!     STB   ,-S
      DECA
      BNE   <
      BRA   @SelfMod

; HexString
; Convert binary number on the stack to a Hex string on the stack
; Enter with:
; B = number of bytes to convert to a hex string
; number is @ ,S
HexString:
      PULS  Y                 ; Get the return address off the stack
      STB   _Var_PF00   ; Save the length of bytes to convert to hex
      LDX   #_Var_PF00+1  ; Temp storage
; Ignore zeros
!     LDA   ,S+
      BNE   >
      DECB
      BNE   <           ; If not zero then we have at least one byte to convert to hex
      LDD   #1*$100+'0' ; A = 1 (length of string), B = '0' 
      PSHS  D
      BRA   @Return
!     STA   ,X+         ; Save First good byte
      STB   _Var_PF00   ; Save updated count
      DECB
      BEQ   @GotValue
; Copy the rest
!     LDA   ,S+
      STA   ,X+
      DECB
      BNE   <
@GotValue:
      LDB   _Var_PF00   ; Get updated count
@Loop1:
      LDA   ,-X
      ANDA  #%00001111  ; Keep the LSNibble
      CMPA    #10       ; Is it 9 or lower?
      BLO     >         ; If so we are good as it is
      ADDA    #-10+$11  ; if it's 10 or more then we need to show 10 as A, 11 as B, etc
!     ADDA    #'0'      ; make it the ASCII value
      PSHS  A           ; Save it on the stack
      LDA   ,X          ; Get the MSNibble
      LSRA
      LSRA
      LSRA
      LSRA              ; MSNibble is now LSNibble
      BNE   >           ; If last nibble is a zero, then we ignore it, otherwise continue
      CMPB  #1
      BEQ   @Done_Minus1       
!     CMPA  #10         ; Is it 9 or lower?
      BLO     >         ; If so we are good as it is
      ADDA  #-10+$11    ; if it's 10 or more then we need to show 10 as A, 11 as B, etc
!     ADDA  #'0'        ; make it the ASCII value
      PSHS  A           ; Save it on the stack
      DECB              ; Decrement number of digits to process
      BNE   @Loop1      ; Keep looping
      LDB   _Var_PF00   ; Length of bytes to convert
      LSLB              ; Two bytes per hex values
@Done:
      PSHS  B           ; Save the length of the string
@Return:
      JMP   ,Y          ; Return
@Done_Minus1:
      LDB   _Var_PF00
      LSLB
      DECB              ; Minus 1 from the total
      BRA   @Done       ; Save length and return

; ===== Direct-page temps (fast) =====
TMP_N       RMB 2      ; current n
TMP_Q10     RMB 2      ; q*10
TMP_CNT     RMB 1      ; digit count (1..5)
TMP_SIGN    RMB 1      ; ' ' or '-'
TMP_BUF     RMB 5      ; digits LSD-first (ASCII)

; ------------------------------------------------------------
; S16_TO_DECSTR
;   Input : signed 16-bit value is on stack at ,S (caller did PSHS D)
;   Output: replaces it with: ,S=len, 1,S=' ' or '-', 2,S..digits
; ------------------------------------------------------------
S16_TO_DECSTR:
      PULS  Y                 ; Get the return address off the stack
      PULS    D           ; pop input value into D
      TSTA
        BPL     @S_Pos
        COMA
        COMB
        ADDD    #1          ; abs (handles $8000 -> 32768)
        TFR     D,X         ; X = magnitude
        LDA     #'-'
        STA     TMP_SIGN
        BRA     @S_AbsDone
@S_Pos:
        TFR     D,X         ; X = magnitude
        LDA     #' '
        STA     TMP_SIGN
@S_AbsDone:
        BRA     U16_CORE     ; reuse shared core

; ------------------------------------------------------------
; U16_TO_DECSTR
;   Input : unsigned 16-bit value is on stack at ,S (caller did PSHS D)
;   Output: replaces it with: ,S=len, 1,S=' ', 2,S..digits
; ------------------------------------------------------------
U16_TO_DECSTR:
      PULS  Y                 ; Get the return address off the stack
      PULS  X                 ; pop input value into X = magnitude (0..65535)
        LDA     #' '
        STA     TMP_SIGN

; ------------------------------------------------------------
; U16_CORE  (shared)
;   Entry : U=return addr, TMP_SIGN set, X=magnitude (unsigned)
;   Exit  : pushes [len][sign][digits...] on stack, returns via JMP ,U
;   Uses  : MUL16 (clobbers D,X only per your note)
; ------------------------------------------------------------
U16_CORE:
        CLR     TMP_CNT
        LDU     #TMP_BUF
@Loop:
      STX   TMP_N       ; save n
        ; ---- q = (n * $CCCD) >> 19  => q = (high16(product) >> 3) ----
        PSHS      Y     ; Save Y as MUL16 kills Y
        PSHS    X           ; one operand = n
        LDD     #$CCCD      ; other operand = magic reciprocal for /10
        PSHS    D
        JSR     MUL16       ; D=high16, X=low16, and low16 also at ,S
;        LEAS    2,S         ; discard low16 left on stack by MUL16
        PULS      X,Y   ; Ingore X, restore Y
        ; q = D >> 3
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB
        TFR     D,X         ; X = q  (next n)
        ; ---- q*10 = q*8 + q*2 ----
        TFR     X,D
        LSLB
        ROLA                ; D = q*2
        STD     TMP_Q10
        TFR     X,D
        LSLB
        ROLA
        LSLB
        ROLA
        LSLB
        ROLA                ; D = q*8
        ADDD    TMP_Q10     ; D = q*10
        STD     TMP_Q10
        ; ---- r = old_n - q*10  (0..9) ----
        LDD     TMP_N
        SUBD    TMP_Q10
        TFR     B,A         ; remainder in B (0..9)
        ADDA    #'0'        ; ASCII digit
        ; store digit LSD-first
        LDB     TMP_CNT
        STA     B,U           ;TMP_BUF,B
      INC   TMP_CNT
        ; loop until q == 0
        CMPX    #0
        BNE     @Loop
        ; ---- push digits so they appear MSD->LSD in memory ----
        LDB     TMP_CNT
;        LDX     #TMP_BUF
@PushDigits:
        LDA     ,U+         ; pushes LSD first -> ends up MSD first in memory
        PSHS    A
        DECB
        BNE     @PushDigits
        ; sign then length
        LDA     TMP_SIGN
        PSHS    A
        LDA     TMP_CNT
        INCA                ; length = digits + 1(sign)
        PSHS    A
      JMP   ,Y          ; Return

; ------------------------------------------------------------
; StrCompare: Compare two strings on the stack to see if they are equal
; String 1 @ ,S
; String 2 after first string
; On EXIT:
; B always = $FF (Default of true)
; Removes strings from the stack and returns with the following value in A and on the stack
; Flags based on value of A is set
; -1 if string 1 is less than string 2
; 0 if they are the same
; 1 if string 1 is greater than string 2
; Clobbers all
; ------------------------------------------------------------
StrCompare:
      PULS  Y           ; Get the return address off the stack
      LEAX  1,S         ; X = Stack +1
      LEAU  ,S          ; U = S 
      LDB   ,U+         ; B = string 1 length
      ABX               ; X points at the 2nd string
; B = min(len1,len2)
      CMPB  ,X+         ; compare len1 vs len2
      BLS   >           ; If len1 <= len2, keep B=len1
      LDB   -1,X        ; Else B = len2
!     TSTB
      BEQ   @LenCompare ; min==0 => skip char loop
@Loop:
      LDA   ,U+         ; Get C1
      CMPA  ,X+         ; Compare to C2
      BLO   @Less
      BHI   @Greater
      DECB
      BNE   @Loop
@LenCompare:
      LDB   ,S          ; A = len1
      LEAX  1,S
      ABX
      CMPB  ,X          ; Cmompare Len1 vs Len2
      BLO   @Less
      BHI   @Greater
@Equal:
      CLRA              ; equal
      BRA   @Done
@Less:
      LDA   #$FF
      BRA   @Done
@Greater:
      LDA   #$01
@Done:
      LDB   ,S          ; Get 1 string length
      LEAX  1,S         ; X = Stack +1
      ABX               ; X points at the length of string 2
      LDB   ,X          ; Get the length of string 2
      ABX               ; X = X + length of string 2
      LEAS  1,X         ; S = the last character of string 2
      LDB   #$FF        ; Make B default of true
      TSTA              ; Save result on the stack and set CC Flags
      JMP   ,Y          ; Return

; StrConcat concat 2 strings on the stack into one string on the stack
; Strings are on the stack as String2 ,String1
; Destination string will be at ,S with the first byte being the length of the new string
StrConcat2:
      PULS  U           ; Get the return address off the stack
      STU   @Return+1
      LDU   #_StrVar_PF00
      LDB   ,S+         ; B = string 2 length, set the final stack position
      LEAY  ,S          ; Y = the stack end pointer
      STB   ,U+
!     LDA   ,Y+
      STA   ,U+
      DECB
      BNE   <           ; Copy string 2 to _StrVar_PF00
      LDB   ,Y          ; B = length of string 1 
      LEAU  ,S          ; U points at the start of the concat string
      ADDB  _StrVar_PF00      ; B = length of new concat string
      STB   ,U+
      LDB   ,Y+         ; B = length of string 1
!     LDA   ,Y+
      STA   ,U+
      DECB
      BNE   <           ; Copy string 1 to first on the stack
      LDX   #_StrVar_PF00 ; Get string 2
      LDB   ,X+         ; B = length of string 1
!     LDA   ,X+
      STA   ,U+
      DECB
      BNE   <           ; Copy string 2 2nd on the stack
@Return
      JMP   >$FFFF      ; Return