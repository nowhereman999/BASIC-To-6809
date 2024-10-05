; Play command
; Start of PLAY commands is at _StrVar_PF00 and terminated with a zero
;
; Variables used
OCTAVE      RMB 1
VOLHI       RMB 1
VOLLOW      RMB 1
NOTELN      RMB 1
TEMPO       RMB 1
PLYTMR      RMB 2
DOTVAL      RMB 1
VD5         RMB 1       Note Duration
VD7         RMB 1       TEMPORARY VALUE
VD8         RMB 1       Length of Play command
VD9         RMB 2       Start of play string
IRQAddress  RMB 2       IRQ pointer address will be stored here when the program is first run

; Restore IRQ back to normal
EndPlayCommand:
        LDD     #BASIC_IRQ      ; Get Regular IRQ address
        STD     [IRQAddress]    ; Restore address of IRQ JMP location back to normal
        BRA     AnalogMuxOff    ; DISABLE ANA MUX AND RETURN

Play:
        LDX     #_StrVar_PF00+1 ; Get the start of the play command string
        LDU     #_StrVar_IFRight+1 ; Set the start of the play command string
        LDB     _StrVar_PF00    ; Get the string length in B
        STB     _StrVar_IFRight ; Save the string length
!       LDA     ,X+             ; Get the next character
        STA     ,U+             ; Save the byte
@Skip:  DECB                    ; Decrement the string length
        BNE     <
        CMPA    #';'            ; check if last value is a semi colon
        BEQ     >               ; Skip ahead if so
        LDA     #';'            ; A= ;
        STA     ,U
        INC     _StrVar_IFRight ; Added a semi colon to the end of the PLAY string
!
; PLAY command, From BASIC ROM (tweaked)
;PLAY
        LDX     #$0000          ; DEFAULT VALUES FOR LENGTH OF PLAY COMMAND AND ADDRESS
        LDB     #$01            ; OF START OF PLAY STRING IF USED FOR PLAY (NULL STRING)
        PSHS    B,X             ; SAVE DEFAULT VALUES
;       JSR     >LB156          ; EVALUATE EXPRESSION
        CLRB                    ;
        JSR     Select_AnalogMuxer ; SET UP DA TO PASS THROUGH ANA MUX
        JSR     AnalogMuxOn     ; ENABLE ANA MUX
;L9A32  JSR     >LB654          ; POINT X TO START OF PLAY STRING AND PUT LENGTH
; OF STRING INTO ACCB
; Enable the Timer & PLAY IRQ while PLAYing
        LDD     #PLAY_IRQ       ; Get PLAY IRQ address
        STD     [IRQAddress]    ; Set address of IRQ JMP location to the PLAY IRQ

        LDX     #_StrVar_IFRight+1 ; Point X at the start of the play command string
        LDB     _StrVar_IFRight
        DECB
        PSHS    B,X             ; Save the length of the play string and Pointer of the Play string on the stack
;        BRA     L9A39           ; Skip ahead
L9A37   PULS    B,X             ; GET PLAY STRING START AND LENGTH
L9A39   STB     VD8             ; LENGTH OF PLAY COMMAND
        BEQ     L9A37           ; GET NEW STRING DATA IF LENGTH = 0
        STX     VD9             ; START OF PLAY STRING
        BEQ     EndPlayCommand  ; Resstore the IRQ and return if X = 0
L9A43   TST     VD8             ; SEE IF LENGTH OF STRING = 0
        BEQ     L9A37           ; GET NEW DATA IF SO
        JSR     L9B98           ; GET A COMMAND CHARACTER IF NOT
        CMPA    #';'            ; SUB COMMAND TERMINATED
        BEQ     L9A43           ; IGNORE SEMICOLONS
        CMPA    #'''            ; CHECK FOR APOSTROPHE
        BEQ     L9A43           ; IGNORE THEM TOO
        CMPA    #'X'            ; CHECK FOR AN EXECUTABLE SUBSTRING (should never get these as Compiler expands strings to there own PLAY command)
        LBEQ    L9C0A           ; GO PROCESS SUB COMMAND
        BSR     L9A5C           ; CHECK FOR OTHER COMMANDS
        BRA     L9A43           ; KEEP GOING THROUGH INTERPRETATION LOOP
; OCTAVE
L9A5C   CMPA    #'O'            ; ADJUST OCTAVE?
        BNE     L9A6D           ; NO - Check for Volume command next
        LDB     OCTAVE          ; GET CURRENT OCTAVE
        INCB                    ;  LEGAL VALUES ARE 1-5 BUT INTERNALLY THE COMPUTER USES 0-4
        BSR     L9AC0           ; MODIFIER CHECK
        DECB                    ;  COMPENSATE FOR INCB ABOVE
        CMPB    #$04            ; MAXIMUM VALUE OF 4
        BHI     L9ACD           ; FC ERROR
        STB     OCTAVE          ; SAVE NEW VALUE OF OCTAVE
        RTS
; VOLUME
L9A6D   CMPA    #'V'            ; ADJUST VOLUME?
        BNE     L9A8B           ; NO - Check for Note Length next
        LDB     VOLHI           ; GET CURRENT HIGH VOLUME LIMIT
        LSRB                    ;  SHIFT 2 BITS TO RIGHT DA IS ONLY 6 BITS (BIT 2 - BIT 7) -
        LSRB                    ;  TO MANIPULATE THE DATA IT MUST BE IN BITS 0-5
        SUBB    #31             ; SUBTRACT OUT MID VALUE OFFSET
        BSR     L9AC0           ; MODIFIER CHECK
        CMPB    #31             ; MAXIMUM ALLOWED RANGE IS 31
        BHI     L9ACD           ; FC ERROR
        ASLB                    ;
        ASLB                    ;  MOVE NEW VALUE BACK TO BITS 2-7
        PSHS    B               ; SAVE NEW VOLUME ON THE STACK
        LDD     #$7E7E          ; PUT MID VALUE IN HIGH AND LOW LIMIT
        ADDA    ,S              ; ADD NEW VOLUME TO HIGH LIMIT
        SUBB    ,S+             ; SUBTR NEW VOLUME FROM LOW LIMIT
        STD     VOLHI           ; SAVE NEW VOLUME LIMITS
        RTS
; NOTE LENGTH
L9A8B   CMPA    #'L'            ; SET NOTE LENGTH?
        BNE     L9AB2           ; NO - Check tempo next
        LDB     NOTELN          ; GET CURRENT LENGTH
        BSR     L9AC0           ; MODIFIER CHECK
        TSTB                    ;
        BEQ     L9ACD           ; FC ERROR IF LENGTH = 0
        STB     NOTELN          ; SAVE NEW NOTE LENGTH
        CLR     DOTVAL          ; RESET NOTE TIMER SCALE FACTOR
L9A9A   BSR     L9A9F           ; CHECK FOR A DOTTED NOTE
        BCC     L9A9A           ; BRANCH IF DOTTED NOTE
        RTS
; SCALE FACTOR - DOTTED NOTE
L9A9F   TST     VD8             ; CHECK COMMAND LENGTH
        BEQ     L9AAD           ; ITS EMPTY
        JSR     L9B98           ; GET COMMAND CHARACTER
        CMPA    #'.'            ; CHECK FOR DOTTED NOTE
        BEQ     L9AAF           ; BRANCH ON DOTTED NOTE AND CLEAR CARRY FLAG
        JSR     L9BE2           ; MOVE COMMAND STRING POINTER BACK ONE AND ADD ONE TO
; LENGTH
L9AAD   COMA                    ;  SET CARRY FLAG
        RTS
L9AAF   INC     DOTVAL          ; ADD ONE TO NOTE TIMER SCALE FACTOR
        RTS
; TEMPO
L9AB2   CMPA    #'T'            ; MODIFY TEMPO?
        BNE     L9AC3           ; NO - Check for Pause next
        LDB     TEMPO           ; GET CURRENT TEMPO
        BSR     L9AC0           ; EVALUATE MODIFIER
        TSTB                    ;  SET FLAGS
        BEQ     L9ACD           ; FC ERROR IF ITS 0
        STB     TEMPO           ; SAVE NEW TEMPO
        RTS
L9AC0   JMP     L9BAC           ; EVALUATE THE >,<,+,-,= OPERATORS
; Convert Deciaml value to D'
PlayDecimalToD:
        PSHS    X,U             ; Save X & U
        LDX     VD9             ; Get the pointer to the string
        LDU     #DecNumber      ; Point a Decimal # start
!       LDA     ,X+             ; Get the character
        CMPA    #';'            ; is it a semicolon?
        BEQ     >
        DEC     VD8
        CMPA    #'0'            ; Is it a zero or higher?
        BLO     >               ; if not then skip ahead
        CMPA    #'9'            ; is it a nine or lower?
        BHI     >               ; if not then skip ahead
        STA     ,U+             ; save the number in U, increment U
        BRA     <               ; get another character
!       CLR     ,U              ; Clear the end of the pointer (flag as end)
        STX     VD9             ; update the pointer
        JSR     DecToD          ; Convert a decimal string of numbers to a signed integer in D
        PULS    X,U,PC          ; Restore X & U and return
; Clear carry if numeric
L90AA   CMPA    #'0'            ; ASCII ZERO
        BLO     >               ; RETURN IF ACCA < ASCII 0
        SUBA    #'9'+1
        SUBA    #-('9'+1)       ; CARRY CLEAR IF NUMERIC
!       RTS

; PAUSE
L9AC3   CMPA    #'P'            ; PAUSE COMMAND?
        BNE     L9AEB           ; NO - Check for Note next
        JSR     PlayDecimalToD  ; EVALUATE A DECIMAL COMMAND STRING VALUE
        TSTB                    ; CHECK FOR LEGAL EXPRESSION AND
        BNE     L9AD0           ; BRANCH IF PAUSE VALUE <> 0
L9ACD   JMP     L9BEB           ; FC ERROR IF PAUSE = 0
L9AD0   LDA     DOTVAL          ; SAVE CURRENT VALUE OF VOLUME AND NOTE
        LDX     VOLHI           ; TIMER SCALE
        PSHS    X,A             ;
        LDA     #$7E            ; MID VALUE OF DA CONVERTER
        STA     VOLHI           ; SET VOLUME = 0
        STA     VOLLOW          ;
        CLR     DOTVAL          ; RESET NOTE TIMER SCALE FACTOR
        BSR     L9AE7           ; GO PLAY A NOTE OF 0 VOLUME
        PULS    A,X             ;
        STA     DOTVAL          ; RESTORE VALUE OF VOLUME
        STX     VOLHI           ; AND NOTE TIMER SCALE
        RTS
L9AE7   CLR     ,-S             ; PUSH NOTE NUMBER 0 ONTO STACK
        BRA     L9B2B           ; GO PLAY IT
; NOTE
L9AEB   CMPA    #'N'            ; LETTER N BEFORE THE NUMBER OF A NOTE?
        BNE     L9AF2           ; NO - ITS OPTIONAL
        JSR     >L9B98          ; GET NEXT COMMAND CHARACTER
L9AF2   CMPA    #'A'            ; CHECK FOR NOTE A
        BLO     L9AFA           ; BELOW
        CMPA    #'G'            ; CHECK FOR NOTE B
        BLS     L9AFF           ; FOUND NOTE A-G
L9AFA   JSR     >L9BBE          ; EVALUATE DECIMAL NUMERIC EXPRESSION IN COMMAND STRING
        BRA     L9B22           ; PROCESS NOTE VALUE
; PROCESS A NOTE HERE
L9AFF   SUBA    #'A'            ; MASK OFF ASCII
        LDX     #L9C5B          ; LOAD X WITH NOTE JUMP TABLE
        LDB     A,X             ; GET NOTE
        TST     VD8             ; ANY COMMAND CHARACTERS LEFT?
        BEQ     L9B22           ; NO
        JSR     >L9B98          ; GET COMMAND CHARACTER
        CMPA    #'#'            ; SHARP NOTE?
        BEQ     L9B15           ; YES
        CMPA    #'+'            ; SHARP NOTE?
        BNE     L9B18           ; NO
L9B15   INCB                    ;  ADD 1 TO NOTE NUMBER (SHARP)
        BRA     L9B22           ; PROCESS NOTE
L9B18   CMPA    #'-'            ; FLAT NOTE?
        BNE     L9B1F           ; NO
        DECB                    ;  SUBTR 1 FROM NOTE NUMBER (FLAT)
        BRA     L9B22           ; PROCESS NOTE
L9B1F   JSR     >L9BE2          ; MOVE COMMAND STRING PTR BACK ONE AND ADD ONE
; TO COMMAND LENGTH CTR
L9B22   DECB                    ;  =ADJUST NOTE NUMBER, BASIC USES NOTE NUMBERS 1-12, INTERNALLY
; =COMPUTER USES 0-11
        CMPB    #12-1           ; MAXIMUM NOTE VALUE
        BHI     L9ACD           ; FC ERROR IF > 11
        PSHS    B               ; SAVE NOTE VALUE
        LDB     NOTELN          ; GET NOTE LENGTH
L9B2B   LDA     TEMPO           ; GET TEMPO
        MUL                     ;  CALCULATE NOTE DURATION
        STD     VD5             ; SAVE NOTE DURATION
; THE IRQ INTERRUPT IS USED TO PROVIDE A MASTER TIMING REFERENCE FOR
; THE PLAY COMMAND. WHEN A NOTE IS DONE, THE IRQ SERVICING
; ROUTINE WILL RETURN CONTROL TO THE MAIN PLAY COMMAND INTERPRETATION LOOP
        LEAU    $01,S           ; LOAD U W/CURRENT VALUE OF (STACK POINTER+1) SO THAT THE STACK
; POINTER WILL BE PROPERLY RESET WHEN IRQ VECTORS
; YOU OUT OF THE PLAY TIMING ROUTINES BELOW
        LDA     OCTAVE          ; GET CURRENT OCTAVE
        CMPA    #$01            ;
        BHI     L9B64           ; BRANCH IF OCTAVE > 1
; OCTAVES 1 AND 2 USE A TWO BYTE DELAY TO SET THE PROPER FREQUENCY
        LDX     #L9C62          ; POINT TO DELAY TABLE
        LDB     #2*12           ; 24 BYTES DATA/OCTAVE
        MUL                     ;  CALC OCTAVE TABLE OFFSET
        ABX                     ;  POINT TO CORRECT OCTAVE TABLE
        PULS    B               ; GET NOTE VALUE BACK
        ASLB                    ;  X 2 - 2 BYTES/NOTE
        ABX                     ;  POINT TO CORRECT NOTE
        LEAY    ,X              ; GET POINTER TO Y REG (TFR X,Y)
        BSR     L9B8C           ; CALCULATE NOTE TIMER VALUE
        STD     PLYTMR          ; SAVE IT
; MAIN SOUND GENERATION LOOP - ONLY THE IRQ SERVICE WILL GET YOU OUT
; OF THIS LOOP (OCTAVES 1 AND 2)
L9B49   BSR     L9B57           ; MID VALUE TO DA AND WAIT
        LDA     VOLHI           ; GET HIGH VALUE
        BSR     L9B5A           ; STORE TO DA AND WAIT
        BSR     L9B57           ; MID VALUE TO DA AND WAIT
        LDA     VOLLOW          ; GET LOW VALUE
        BSR     L9B5A           ; STORE
        BRA     L9B49           ; KEEP LOOPING
L9B57   LDA     #$7E            ; DA MID VALUE AND RS 232 MARKING
        NOP                     ;  DELAY SOME - FINE TUNE PLAY FREQUENCY
L9B5A   STA     PIA1            ; STORE TO DA CONVERTER
        LDX     ,Y              ; GET DELAY FROM OCTAVE TABLE
L9B5F   LEAX    -1,X            ;
        BNE     L9B5F           ; COUNT X TO ZERO - PROGRAMMABLE DELAY
        RTS
; OCTAVES 3,4 AND 5 USE A ONE BYTE DELAY TO SET THE PROPER FREQUENCY
L9B64   LDX     #L9C92-2*12     ; POINT TO DELAY TABLE
        LDB     #12             ; 12 BYTES DATA PER OCTAVE
        MUL                     ;  CALC OCTAVE TABLE OFFSET
        ABX                     ;  POINT TO CORRECT OCTAVE TABLE
        PULS    B               ; GET NOTE VALUE BACK
        ABX                     ;  POINT TO CORRECT NOTE
        BSR     L9B8C           ; CALCULATE NOTE TIMER VALUE
        STD     PLYTMR          ; SAVE IT
L9B72   BSR     L9B80           ; MID VALUE TO DA AND WAIT
        LDA     VOLHI           ; GET HIGH VALUE
        BSR     L9B83           ; STORE TO DA AND WAIT
        BSR     L9B80           ; MID VALUE TO DA AND WAIT
        LDA     VOLLOW          ; GET LOW VALUE
        BSR     L9B83           ; STORE TO DA AND WAIT
        BRA     L9B72           ; KEEP GOING
; PUT MID VALUE TO DA CONVERTER AND WAIT A WHILE
L9B80   LDA     #$7E            ; DA CONVERTER MID VALUE AND KEEP RS 232 OUTPUT MARKING
        NOP                     ;  DELAY SOME - FINE TUNE PLAY FREQUENCY
L9B83   STA     PIA1            ; STORE IN DA CONVERTER
        LDA     ,X              ; GET DELAY VALUE FROM OCTAVE TABLE
L9B88   DECA                    ;  COUNT ACCA TO ZERO - TIME DELAY
        BNE     L9B88           ; COUNT ACCA TO ZERO - TIME DELAY
        RTS
; CALCULATE NOTE TIMER VALUE - RETURN WITH VALUE IN ACCD -
; THE LARGER ACCD IS, THE LONGER THE NOTE WILL PLAY
L9B8C   LDB     #$FF            ; NOTE TIMER BASE VALUE
        LDA     DOTVAL          ; GET NOTE TIMER SCALE FACTOR
        BEQ     L9B97           ; USE DEFAULT VALUE IF 0
        ADDA    #$02            ; ADD IN CONSTANT TIMER SCALE FACTOR
        MUL                     ;  MULTIPLY SCALE FACTOR BY BASE VALUE
        LSRA                    ;  DIVIDE ACCD BY TWO - EACH INCREMENT OF DOTVAL
        RORB                    ;  WILL INCREASE NOTE TIMER BY 128
L9B97   RTS
; GET NEXT COMMAND - RETURN VALUE IN ACCA
L9B98:  PSHS    X               ; SAVE X REGISTER
L9B9A:  TST     VD8             ; CHECK COMMAND COUNTER
        BEQ     L9BEB           ; FC ERROR IF NO COMMAND DATA LEFT
        LDX     VD9             ; GET COMMAND ADDR
        LDA     ,X+             ; GET COMMAND
        STX     VD9             ; SAVE NEW ADDRESS
        DEC     VD8             ; DECREMENT COMMAND CTR
        CMPA    #' '            ; CHECK FOR BLANK
        BEQ     L9B9A           ; IGNORE BLANKS
        PULS    X,PC            ; RESTORE X RESISTER AND RETURN
; EVALUATE THE >,<,+,-,= OPERATORS - ENTER WITH THE VALUE TO
; BE OPERATED ON IN ACCB, RETURN NEW VALUE IN SAME
L9BAC   BSR     L9B98           ; GET A COMMAND CHARACTER
        CMPA    #'+'            ; ADD ONE?
        BEQ     L9BEE           ; YES
        CMPA    #'-'            ; SUBTRACT ONE?
        BEQ     L9BF2           ; YES
        CMPA    #'>'            ; MULTIPLY BY TWO?
        BEQ     L9BFC           ; YES
        CMPA    #'<'            ; DIVIDE BY TWO?
        BEQ     L9BF7           ; YES
L9BBE   CMPA    #'='            ; CHECK FOR VARIABLE EQUATE - BRANCH IF SO; ACCB WILL BE
;        BEQ     L9C01           ; SET TO THE VALUE OF THE BASIC VARIABLE IN THE COMMAND
        BEQ     PlayDecimalToD


; STRING WHICH MUST BE NUMERIC, LESS THAN 256
; AND THE VARIABLE MUST BE FOLLOWED BY A SEMICOLON.
        JSR     L90AA           ; CLEAR CARRY IF NUMERIC
        BLO     L9BEB           ; FC ERROR IF NON NUMERIC
        CLRB                    ;  UNITS DIGIT = 0
; STRIP A DECIMAL ASCII VALUE OFF OF THE COMMAND STRING
; AND RETURN BINARY VALUE IN ACCB
L9BC8   SUBA    #'0'            ; MASK OFF ASCII
        STA     VD7             ; SAVE VALUE TEMPORARILY
        LDA     #10             ; BASE 10
        MUL                     ;  MULT BY DIGIT
        TSTA                    ;
        BNE     L9BEB           ; FC ERROR IF RESULT > 255
        ADDB    VD7             ; GET TEMPORARY VALUE
        BLO     L9BEB           ; FC ERROR IF RESULT > 255
        TST     VD8             ;
        BEQ     L9BF1           ; RETURN IF NO COMMANDS LEFT
        JSR     >L9B98          ; GET ANOTHER COMMAND
        JSR     L90AA           ; CLEAR CARRY IF NUMERIC
        BCC     L9BC8           ; BRANCH IF MORE NUMERIC DATA
L9BE2   INC     VD8             ; ADD ONE TO COMMAND COUNTER AND
        LDX     VD9             ; MOVE COMMAND STRING BACK ONE
        LEAX    -1,X            ;
        STX     VD9             ;
        RTS
L9BEB:                    ; FC ERROR
; PRINT"ERROR WITH PLAY STRING"
        BSR     >               ; Skip over string value
        FCB     $0D             ; Do a Line Feed/Carriage Return
        FCB     $45             ; E
        FCB     $52             ; R
        FCB     $52             ; R
        FCB     $4F             ; O
        FCB     $52             ; R
        FCB     $20             ;  
        FCB     $57             ; W
        FCB     $49             ; I
        FCB     $54             ; T
        FCB     $48             ; H
        FCB     $20             ;  
        FCB     $50             ; P
        FCB     $4C             ; L
        FCB     $41             ; A
        FCB     $59             ; Y
        FCB     $20             ;  
        FCB     $53             ; S
        FCB     $54             ; T
        FCB     $52             ; R
        FCB     $49             ; I
        FCB     $4E             ; N
        FCB     $47             ; G
!       LDB     #23             ; Length of this string
        LDU     ,S++            ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+             ; Get the string data
        JSR     PrintA_On_Screen   ; Go print A on screen
        DECB                    ; decrement the string length counter
        BNE     <               ; If not counted down to zero then loop
        BRA     *               ; Loop forever
L9BEE   INCB                    ;  ADD ONE TO PARAMETER
        BEQ     L9BEB           ; FC ERROR IF ADDING 1 TO 255
L9BF1   RTS
L9BF2   TSTB                    ;
        BEQ     L9BEB           ; FC ERROR IF TRYING TO DECREMENT 0
        DECB                    ;  SUBTRACT ONE FROM PARAMETER
        RTS
L9BF7   TSTB                    ;
        BEQ     L9BEB           ; FC ERROR IF DIVIDING BY ZERO
        LSRB                    ;  DIVIDE BY TWO
        RTS
L9BFC   TSTB                    ;
        BMI     L9BEB           ; FC ERROR IF RESULT WOULD BE > 255
        ASLB                    ;  MULTIPLY BY TWO
        RTS
L9C01:
        BRA     *
; SET TO THE VALUE OF THE BASIC VARIABLE IN THE COMMAND
;L9C01   PSHS    U,Y             ; SAVE U,Y REGISTERS
;        BSR     L9C1B           ; INTERPRET COMMAND STRING AS IF IT WERE A BASIC VARIABLE
;        JSR     >LB70E          ; CONVERT FPA0 TO AN INTEGER VALUE IN ACCB
;        PULS    Y,U,PC          ; RESTORE U,Y REGISTERS AND RETURN

; X - means another string is here
; Figure out how to handle more strings...
L9C0A:
        BRA     *

;L9C0A   JSR     >L9C1B          ; EVALUATE AN EXPRESSION IN THE COMMAND STRING
;        LDB     #2
;        JSR     >LAC33          ; =ROOM FOR 4 BYTES ON STACK?
;        LDB     VD8             ; GET THE CURRENT COMMAND LENGTH AND POINTER AND
;        LDX     VD9             ; SAVE THEM ON THE STACK
;        PSHS    X,B             ;
;        JMP     >L9A32          ; GO INTERPRET AND PROCESS THE NEW PLAY SUB COMMAND
; INTERPRET THE PRESENT COMMAND STRING AS IF IT WERE A BASIC VARIABLE
;L9C1B   LDX     VD9             ; GET COMMAND POINTER
;        PSHS    X               ; SAVE IT
;        JSR     >L9B98          ; GET A COMMAND CHARACTER
;        JSR     >LB3A2          ; SET CARRY IF NOT ALPHA
;        BLO     L9BEB           ; FC ERROR IF NOT ALPHA - ILLEGAL VARIABLE NAME
;L9C27   JSR     >L9B98          ; GET A COMMAND CHARACTER
;        CMPA    #';'            ; CHECK FOR SEMICOLON - COMMAND SEPARATOR
;        BNE     L9C27           ; BRANCH UNTIL FOUND
;        PULS    X               ; GET SAVED COMMAND POINTER
;        LDU     CHARAD          ; GET BASICS INPUT POINTER
;        PSHS    U               ; SAVE IT
;        STX     CHARAD          ; PUT PLAY COMMAND POINTER IN PLACE OF BASICS INPUT POINTER
;        JSR     >LB284          ; EVALUATE AN ALPHA EXPRESSION P GET NEW STRING DESCRIPTOR
;        PULS    X               ; RESTORE BASICS INPUT POINTER
;        STX     CHARAD          ;
;        RTS

; TABLE OF NUMERICAL NOTE VALUES FOR LETTER NOTES
L9C5B   FCB     10,12,1,3,5,6,8 ; NOTES A,B,C,D,E,F,G
; TABLE OF DELAYS FOR OCTAVE 1
L9C62   FDB     $01A8,$0190,$017A ; DELAYS FOR OCTAVE 1
        FDB     $0164,$0150,$013D
        FDB     $012B,$011A,$010A
        FDB     $00FB,$00ED,$00DF
; TABLE OF DELAYS FOR OCTAVE 2
L9C7A   FDB     $00D3,$00C7,$00BB ; DELAYS FOR OCTAVE 2
        FDB     $00B1,$00A6,$009D
        FDB     $0094,$008B,$0083
        FDB     $007C,$0075,$006E
; TABLE OF DELAYS FOR OCTAVES 3,4,5
L9C92   FCB     $A6,$9C,$93,$8B,$83,$7B ; DELAYS FOR OCTAVES 3,4,5
        FCB     $74,$6D,$67,$61,$5B,$56
        FCB     $51,$4C,$47,$43,$3F,$3B
        FCB     $37,$34,$31,$2E,$2B,$28
        FCB     $26,$23,$21,$1F,$1D,$1B
        FCB     $19,$18,$16,$14,$13,$12
        