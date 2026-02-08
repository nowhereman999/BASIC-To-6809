; Convert ascii text number to FFP format
; ============================================================
; Mul10AddDigit32_MUL_StackCarry
;   U -> 4-byte unsigned accumulator (big-endian):
;       0,U MSB ... 3,U LSB
;   A2F_DIGIT = 0..9
;   acc = acc*10 + digit
;   Uses stack byte at ,S for carry
;   Clobbers: A,B,D,CC
;
; Stack usage:
;   pushes 1 byte (carry) and pops it before return
; ============================================================

Mul10AddDigit32_MUL_StackCarry:
        CLR     ,-S            ; (stack) carry = 0
        ; ---- byte 3 (LSB) ----
        LDB     #10            ; B = 10  (MUST reload before each MUL!)
        LDA     3,U            ; A = acc byte 3
        MUL                     ; D = A*B  (A=high, B=low)
        ADDB    ,S             ; add carry into low byte
        ADCA    #0             ; propagate carry into high byte
        STB     3,U            ; store new byte 3
        STA     ,S             ; carry = high byte of result
        ; ---- byte 2 ----
        LDB     #10            ; B = 10  (reload)
        LDA     2,U            ; A = acc byte 2
        MUL
        ADDB    ,S
        ADCA    #0
        STB     2,U
        STA     ,S
        ; ---- byte 1 ----
        LDB     #10            ; B = 10  (reload)
        LDA     1,U            ; A = acc byte 1
        MUL
        ADDB    ,S
        ADCA    #0
        STB     1,U
        STA     ,S
        ; ---- byte 0 (MSB) ----
        LDB     #10            ; B = 10  (reload)
        LDA     0,U            ; A = acc byte 0
        MUL
        ADDB    ,S
        ADCA    #0
        STB     0,U            ; keep low 8 bits (32-bit wrap if overflow)
        ; ---- add digit into LSB, propagate carry ----
        LDA     3,U
        ADDA    A2F_DIGIT
        STA     3,U
        BCC     @Done
        INC     2,U
        BNE     @Done
        INC     1,U
        BNE     @Done
        INC     0,U
@Done:
        PULS    A,PC           ; pop carry byte into A (don't care), return

; ============================================================
; ASCII_To_FFP
;  In : X = pointer to ASCII text (e.g. "1.345", "0.005", "-.2")
;  Out: pushes 3-byte FFP on stack (A,X)  [ ,S = sign/exp, 1,S..2,S = mantissa ]
;       X advanced to first non-parsed char (terminator, space, etc.)
;
;  Uses: U32_To_FFP, FFP_DIV, FFP_ADD
;  Clobbers: A,B,D,X,U,CC  (preserves nothing)
; ============================================================

ASCII_To_FFP:
        PULS    U
        STU     @RET+1
; ---- init ----
        CLR     A2F_SIGN1
        CLR     A2F_FRACDIG
        CLR     A2F_INT_HI
        CLR     A2F_INT_HI+1
        CLR     A2F_INT_LO
        CLR     A2F_INT_LO+1
        CLR     A2F_FRAC_HI
        CLR     A2F_FRAC_HI+1
        CLR     A2F_FRAC_LO
        CLR     A2F_FRAC_LO+1
        CLR     A2F_SEEN_DOT
; ---- skip leading spaces ----
@SKIPSP:
        LDA     ,X
        CMPA    #' '
        BNE     @SIGNCHK
        LEAX    1,X
        BRA     @SKIPSP
; ---- optional sign ----
@SIGNCHK:
        LDA     ,X
        CMPA    #'-'
        BNE     @PLUSCHK
        LDA     #$80
        STA     A2F_SIGN1
        LEAX    1,X
        BRA     @PARSE
@PLUSCHK:
        CMPA    #'+'
        BNE     @PARSE
        LEAX    1,X
; ---- parse digits and optional dot ----
@PARSE:
        LDA     ,X
        CMPA    #','
        BEQ     @DONEPARSE         ; Terminated with a comma
        CMPA    #'.'
        BNE     @DIGIT
        ; dot
        LDA     A2F_SEEN_DOT
        BNE     @DONEPARSE         ; 2nd dot => stop
        LDA     #1
        STA     A2F_SEEN_DOT
        LEAX    1,X
        BRA     @PARSE
@DIGIT:
        CMPA    #'0'
        BLO     @DONEPARSE
        CMPA    #'9'
        BHI     @DONEPARSE
        ; digit -> B = 0..9
        SUBA    #'0'
        STA     A2F_DIGIT          ; save digit safely (so helper can trash regs)
        LDA     A2F_SEEN_DOT
        BEQ     @ADDINT
        ; ---- fractional digit ----
        LDA     A2F_FRACDIG
        CMPA    #9
        BHS     @SKIPFRACDIG       ; ignore extra frac digits (still consume char)
        INC     A2F_FRACDIG
        LDU     #A2F_FRAC_HI       ; U -> 4-byte accumulator
        JSR     Mul10AddDigit32_MUL_StackCarry
@SKIPFRACDIG:
        LEAX    1,X
        BRA     @PARSE
@ADDINT:
        LDU     #A2F_INT_HI
        JSR     Mul10AddDigit32_MUL_StackCarry
        LEAX    1,X
        BRA     @PARSE
@DONEPARSE:
; ============================================================
; If int==0 and frac==0 => return +0.0 (000000) quickly
; ============================================================
; Update Temp3 location just after the comma
!       LDA     ,X+                     ; Get the value (we might have exited with a non comma)
        CMPA    #','                    ; Is it a comma?
        BNE     <                       ; If not a comma, keep checking
        STX     Temp3                   ; Save the start address of the next entry in Temp3
;
        LDD     A2F_INT_HI
        ORA     A2F_INT_HI+1
        ORB     #0              ; (keep flags sane)
        BNE     @HAVE_SOMETHING
        LDD     A2F_INT_LO
        BNE     @HAVE_SOMETHING
        LDD     A2F_FRAC_HI
        BNE     @HAVE_SOMETHING
        LDD     A2F_FRAC_LO
        BNE     @HAVE_SOMETHING
        ; push canonical zero
        CLRA
        LDX     #$0000
        PSHS    A,X
        JMP     @APPLYSIGN_RETURN  ; will re-canonicalize to +0
@HAVE_SOMETHING:
; ============================================================
; Convert integer part to FFP -> A2F_TMP_INT (3 bytes)
; ============================================================
        ; push U32 (big-endian) onto stack: [hi word][lo word]
        LDD     A2F_INT_LO
        PSHS    D
        LDD     A2F_INT_HI
        PSHS    D
        JSR     U32_To_FFP          ; leaves 3-byte FFP at ,S
        PULS    A,X
        STA     A2F_TMP_INT
        STX     A2F_TMP_INT+1
; ============================================================
; If no fractional digits or frac accumulator==0 => result = int
; ============================================================
        LDA     A2F_FRACDIG
        BEQ     @RESULT_IS_INT
        LDD     A2F_FRAC_HI
        BNE     @DO_FRAC
        LDD     A2F_FRAC_LO
        BEQ     @RESULT_IS_INT
@DO_FRAC:
; ============================================================
; Convert frac accumulator to FFP -> A2F_TMP_FRACINT
; ============================================================
        LDD     A2F_FRAC_LO
        PSHS    D
        LDD     A2F_FRAC_HI
        PSHS    D
        JSR     U32_To_FFP
        PULS    A,X
        STA     A2F_TMP_FRACINT
        STX     A2F_TMP_FRACINT+1
; ============================================================
; pow10 = 10^fracDigits (U32), convert to FFP -> A2F_TMP_POW
; ============================================================
        LDB     A2F_FRACDIG         ; 0..9
        LDX     #Pow10_U32_Table
        ; offset = B*4
        LSLB
        LSLB
        ABX
        LDD     0,X                 ; hi word
        STD     A2F_POW_HI
        LDD     2,X                 ; lo word
        STD     A2F_POW_LO
        LDD     A2F_POW_LO
        PSHS    D
        LDD     A2F_POW_HI
        PSHS    D
        JSR     U32_To_FFP
        PULS    A,X
        STA     A2F_TMP_POW
        STX     A2F_TMP_POW+1
; ============================================================
; fracFFP = fracIntFFP / powFFP
;   stack order for FFP_DIV: value1 at 3,S, value2 at ,S
;   => push fracInt first, then pow
; ============================================================
        LDA     A2F_TMP_FRACINT
        LDX     A2F_TMP_FRACINT+1
        PSHS    A,X                 ; fracInt
        LDA     A2F_TMP_POW
        LDX     A2F_TMP_POW+1
        PSHS    A,X                 ; pow
        JSR     FFP_DIV             ; result frac at ,S
        PULS    A,X
        STA     A2F_TMP_FRAC
        STX     A2F_TMP_FRAC+1
; ============================================================
; result = int + frac
; stack order for FFP_ADD: value1 at 3,S, value2 at ,S
; => push int first, then frac
; ============================================================
        LDA     A2F_TMP_INT
        LDX     A2F_TMP_INT+1
        PSHS    A,X
        LDA     A2F_TMP_FRAC
        LDX     A2F_TMP_FRAC+1
        PSHS    A,X
        JSR     FFP_ADD             ; result at ,S
        BRA     @APPLYSIGN_RETURN
@RESULT_IS_INT:
        LDA     A2F_TMP_INT
        LDX     A2F_TMP_INT+1
        PSHS    A,X
; ============================================================
; Apply sign, but keep canonical +0 (000000)
; ============================================================
@APPLYSIGN_RETURN:
        ; if mantissa==0 => force 000000 regardless of sign
        LDD     1,S
        BEQ     @CANON_ZERO
        LDA     A2F_SIGN1
        BEQ     @RET
        LDA     ,S
        EORA    #$80
        STA     ,S
        BRA     @RET
@CANON_ZERO:
        CLR     ,S                 ; exp/sign = 0
        CLR     1,S
        CLR     2,S
@RET:
        JMP     >$FFFF

; ============================================================
; Data / temporaries
; ============================================================

A2F_DIGIT       RMB     1
A2F_SIGN1        RMB 1
A2F_SEEN_DOT    RMB 1
A2F_FRACDIG     RMB 1

A2F_INT_HI      RMB 2
A2F_INT_LO      RMB 2
A2F_FRAC_HI     RMB 2
A2F_FRAC_LO     RMB 2

A2F_POW_HI      RMB 2
A2F_POW_LO      RMB 2

A2F_TMP_INT     RMB 3
A2F_TMP_FRACINT RMB 3
A2F_TMP_POW     RMB 3
A2F_TMP_FRAC    RMB 3

A2F_TMPA_HI     RMB 2
A2F_TMPA_LO     RMB 2
A2F_TMPB_HI     RMB 2
A2F_TMPB_LO     RMB 2

; 10^n for n=0..9 (U32 big-endian)
Pow10_U32_Table:
        FDB $0000,$0001    ; 10^0  = 1
        FDB $0000,$000A    ; 10^1  = 10
        FDB $0000,$0064    ; 10^2  = 100
        FDB $0000,$03E8    ; 10^3  = 1000
        FDB $0000,$2710    ; 10^4  = 10000
        FDB $0001,$86A0    ; 10^5  = 100000
        FDB $000F,$4240    ; 10^6  = 1000000
        FDB $0098,$9680    ; 10^7  = 10000000
        FDB $05F5,$E100    ; 10^8  = 100000000
        FDB $3B9A,$CA00    ; 10^9  = 1000000000

; ============================================================
; ASCII_To_S32_IntPart_Stack
;   In : X -> ASCII number (comma-terminated), e.g. "50000", "-123.45", "  +77.9"
;   Out: pushes signed 32-bit integer (big-endian) onto stack:
;         ,S..3,S = MSB..LSB
;        X stops at '.' (X points to '.'), or at first non-digit / NUL
;
;   Uses: Mul10AddDigit32_MUL_StackCarry
;         A2F_DIGIT (0..9)
;
;   Clobbers: A,B,D,U,CC  (and whatever your helper clobbers)
; ============================================================

A2I_ACC   RMB 4      ; 32-bit accumulator (big-endian): 0=MSB ... 3=LSB
A2I_NEG   RMB 1      ; $80 if negative else 0
; A2F_DIGIT must exist already (you already have it in your ASCII_To_FFP code)
ASCII_To_S32_IntPart_Stack:
        PULS    U                       ; pull return address into U
        STU     @Return+1               ; self-modify JMP target
        CLR     A2I_NEG                 ; assume positive
        CLR     A2I_ACC                 ; acc = 0
        CLR     A2I_ACC+1
        CLR     A2I_ACC+2
        CLR     A2I_ACC+3
; ---- skip leading spaces ----
@SkipSp:
        LDA     ,X                      ; A = current char
        CMPA    #' '                    ; space?
        BNE     @SignChk                ; no => sign check
        LEAX    1,X                     ; X++
        BRA     @SkipSp                 ; loop
; ---- optional sign ----
@SignChk:
        LDA     ,X                      ; A = current char
        CMPA    #'-'                    ; minus?
        BNE     @PlusChk
        LDA     #$80                    ; mark negative
        STA     A2I_NEG
        LEAX    1,X                     ; consume '-'
        BRA     @Parse
@PlusChk:
        CMPA    #'+'                    ; plus?
        BNE     @Parse
        LEAX    1,X                     ; consume '+'
; ---- parse digits until '.', NUL, or non-digit ----
@Parse:
        LDA     ,X                      ; A = current char
        CMPA    #','                    ; Is it a comma?
        BEQ     @Finish                 ; Found a comma => done
        CMPA    #'.'                    ; decimal point?
        BEQ     @Finish                 ; stop at '.', leave X pointing at '.'
        CMPA    #'0'                    ; below '0'?
        BLO     @Finish                 ; stop
        CMPA    #'9'                    ; above '9'?
        BHI     @Finish                 ; stop
        SUBA    #'0'                    ; A = digit 0..9
        STA     A2F_DIGIT               ; store digit for helper
        LDU     #A2I_ACC                ; U -> 4-byte accumulator
        JSR     Mul10AddDigit32_MUL_StackCarry ; acc = acc*10 + digit
        LEAX    1,X                     ; consume digit
        BRA     @Parse                  ; loop
; ---- apply sign (two's complement if negative) ----
@Finish:
; Update Temp3 location just after the comma
!       LDA     ,X+                     ; Get the value (we might have exited with a non comma)
        CMPA    #','                    ; Is it a comma?
        BNE     <                       ; If not a comma, keep checking
        STX     Temp3                   ; Save the start address of the next entry in Temp3
;
        LDA     A2I_NEG                 ; negative?
        BEQ     @PushResult             ; no => push as-is
        COM     A2I_ACC+3               ; invert bytes (two's complement)
        COM     A2I_ACC+2
        COM     A2I_ACC+1
        COM     A2I_ACC
        LDA     A2I_ACC+3               ; +1 to low byte
        ADDA    #1
        STA     A2I_ACC+3
        BCC     @PushResult             ; no carry => done
        INC     A2I_ACC+2               ; propagate carry
        BNE     @PushResult
        INC     A2I_ACC+1
        BNE     @PushResult
        INC     A2I_ACC                ; final carry into MSB
; ---- push 32-bit big-endian onto stack at ,S ----
@PushResult:
        LDD     A2I_ACC+2               ; D = low word (bytes 2..3)
        PSHS    D                       ; push low word first (ends up at 2,S..3,S)
        LDD     A2I_ACC                 ; D = high word (bytes 0..1)
        PSHS    D                       ; push high word (ends up at ,S..1,S)
@Return:
        JMP     >$FFFF                  ; self-modified return

; ============================================================
; Optional tiny wrappers (very small, but not required)
; ============================================================
ASCII_To_S8_Stack:
        LDB     #1
        BRA     ASCII_To_SIntN_Stack
ASCII_To_S16_Stack:
        LDB     #2
        BRA     ASCII_To_SIntN_Stack
ASCII_To_S32_Stack:
        LDB     #4
        BRA     ASCII_To_SIntN_Stack
ASCII_To_S64_Stack:
        LDB     #8
        BRA     ASCII_To_SIntN_Stack

; ============================================================
; ASCII_To_SIntN_Stack
;   Convert ASCII integer text at ,X into signed N-byte integer.
;
;   In:
;     X  = pointer to NUL-terminated ASCII text (may have spaces, +/-)
;     B  = width in BYTES: 1,2,4,8
;
;   Parsing:
;     - skips leading spaces
;     - optional '+' or '-'
;     - consumes digits '0'..'9'
;     - STOPS at '.' (does NOT consume it) OR any non-digit OR NUL
;
;   Out:
;     pushes signed integer (two's complement) big-endian onto stack:
;       width=1:  ,S
;       width=2:  ,S..1,S
;       width=4:  ,S..3,S
;       width=8:  ,S..7,S
;     X points at the stop char ('.', NUL, or non-digit)
;
;   Notes:
;     - overflow wraps modulo 2^(8*B)
;     - clobbers A,B,D,U,Y,CC (X returned advanced)
;
;   Calls helper:
;     Mul10AddDigitN_MUL_StackCarry  (uses stack carry byte internally)
; ============================================================

ASCII_To_SIntN_Stack:
        PULS    U               ; pull return address
        STU     @Return+1       ; self-mod return
        LDY     #$0000          ; Y=0 => positive (Y nonzero => negative)
; ---- skip leading spaces ----
@SkipSp:
        LDA     ,X              ; A = current char
        CMPA    #' '            ; space?
        BNE     @SignChk        ; if not space, go check sign
        LEAX    1,X             ; X++
        BRA     @SkipSp         ; loop
; ---- optional sign ----
@SignChk:
        LDA     ,X              ; A = current char
        CMPA    #'-'            ; minus?
        BNE     @PlusChk
        LDY     #$0080          ; mark negative (any nonzero is fine)
        LEAX    1,X             ; consume '-'
        BRA     @AllocAcc
@PlusChk:
        CMPA    #'+'            ; plus?
        BNE     @AllocAcc
        LEAX    1,X             ; consume '+'
; ---- allocate B bytes on stack for accumulator, initialize to 0 ----
@AllocAcc:
        TFR     B,A             ; A = width (byte count)
@ClrLoop:
        CLR     ,-S             ; push one zero byte
        DECA
        BNE     @ClrLoop
        TFR     S,U             ; U -> accumulator base (MSB at 0,U)
; ---- parse digits until '.', NUL, or non-digit ----
@Parse:
        LDA     ,X              ; A = char
        CMPA    #','            ; is it a comma?
        BEQ     @DoneParse      ; comma => done
        CMPA    #'.'            ; decimal point?
        BEQ     @DoneParse      ; stop at '.' (leave X pointing at '.')
        CMPA    #'0'            ; below '0'?
        BLO     @DoneParse
        CMPA    #'9'            ; above '9'?
        BHI     @DoneParse
        SUBA    #'0'            ; A = digit 0..9
        JSR     Mul10AddDigitN_MUL_StackCarry  ; acc = acc*10 + digit
        LEAX    1,X             ; consume digit char
        BRA     @Parse
; ---- apply sign (two's complement in-place) ----
@DoneParse:
; Update Temp3 location just after the comma
!       LDA     ,X+                     ; Get the value (we might have exited with a non comma)
        CMPA    #','                    ; Is it a comma?
        BNE     <                       ; If not a comma, keep checking
        STX     Temp3                   ; Save the start address of the next entry in Temp3
;
        CMPY    #0              ; negative?
        BEQ     @Return         ; if positive, done
        ; ---- invert all bytes: acc = ~acc ----
        TFR     B,A             ; A = width
@InvLoop:
        COM     ,U+             ; invert one byte
        DECA
        BNE     @InvLoop        ; loop width times
        ; U now points one past end of accumulator
        ; ---- add 1 to LSB, propagate carry toward MSB ----
        TFR     B,A             ; A = width
@IncLoop:
        LEAU    -1,U            ; move toward LSB/MSB as we propagate
        INC     ,U              ; +1 (or carry)
        BNE     @Return         ; if no wrap, done
        DECA
        BNE     @IncLoop        ; keep propagating if wrapped
; ---- return, leaving accumulator on stack at ,S ----
@Return:
        JMP     >$FFFF          ; self-modified by entry

; ============================================================
; Mul10AddDigitN_MUL_StackCarry  (SAFE / FIXED)
;   acc = acc*10 + digit
;
; In:
;   U -> accumulator bytes (big-endian): 0,U (MSB) .. (B-1),U (LSB)
;   B = width in bytes: 1,2,4,8
;   A = digit 0..9
;
; Uses:
;   local carry byte at ,S (pushed), removed before return
;
; Preserves:
;   U
; Restores:
;   B (width) on exit
; ============================================================

Mul10AddDigitN_MUL_StackCarry:
        PSHS    D,X,Y,U         ; Digit, Width, Save X, Save Y, Save U
        CLR     ,-S             ; local carry byte at 0,S = 0
        ; Stack layout now:
        ;   0,S = carry
        ;   1,S = saved digit
        ;   2,S = saved width
        ;   3,S..4,S = saved Y
        ;   ... return address below
        ; ----------------------------------------------------
        ; Compute X = U + (width-1)  (point X at LSB)
        ; ----------------------------------------------------
        LDB     2,S             ; B = width
        TFR     U,X             ; X = base (MSB)
        DECB                    ; width-1
        BEQ     @LSB_OK         ; if width==1, X already LSB
@ADV_LSB:
        LEAX    1,X             ; X++
        DECB
        BNE     @ADV_LSB
@LSB_OK:
        TFR     X,Y             ; save LSB pointer in Y
        ; ----------------------------------------------------
        ; Multiply accumulator by 10 (bytewise), LSB -> MSB
        ; Loop ends when X goes past MSB (X becomes U-1)
        ; ----------------------------------------------------
@MUL10_LOOP:
        LDA     ,X              ; A = current byte
        LDB     #10             ; B = 10  (MUST reload: MUL destroys B)
        MUL                     ; D = A*10  (A=high, B=low)
        ADDB    ,S              ; add carry into low byte
        ADCA    #0              ; add carry-out into high byte
        STB     ,X              ; store new byte
        STA     ,S              ; carry = high byte
        LEAX    -1,X            ; move toward MSB
        CMPX    7,S             ; U               ; are we still >= base?
        BHS     @MUL10_LOOP     ; yes -> keep going
        ; ----------------------------------------------------
        ; Add digit to LSB, propagate carry toward MSB
        ; ----------------------------------------------------
        TFR     Y,X             ; X = LSB again
        LDA     ,X              ; A = LSB
        ADDA    1,S             ; A += saved digit
        STA     ,X              ; store LSB
        BCC     @DONE           ; no carry -> finished
@PROP_CARRY:
        CMPX    7,S             ; U               ; at MSB already?
        BEQ     @DONE           ; carry out of MSB ignored (wrap)
        LEAX    -1,X            ; move to next more-significant byte
        INC     ,X              ; add carry
        BEQ     @PROP_CARRY     ; if wrapped, keep propagating
        ; if non-zero, carry resolved
        BRA     @DONE
@DONE:
        LEAS    1,S             ; drop local carry byte
        PULS    D,X,Y,U,PC      ; restore digit->A (don't care), width->B, Y, return
