DEBDEL       EQU    $045E          CURSOR BLINK DELAY
DEBVAL       EQU    DEBDEL         KEYBOARD DEBOUNCE TIME
KEYBUF       EQU    $0152          KEYBOARD MEMORY BUFFER

; If a key is pressed the string is on the stack, otherwise a zero is on the stack
StrCommandInkey:
        PULS    D
        STD     @Return+1
        BSR     KEYIN     ; This routine Polls the keyboard to see if a key is pressed, returns with value in A, A=0 if no key is pressed
        STA     ,-S       ; Save A on the stack
        BEQ     @Return   ; if A is zero, then that is the size of the string, return
        LDB     #1        ; We have a keypress so set the string length to 1
        STB     ,-S       ; Save 1 for the size on the stack
@Return:
        JMP     >$FFFF

* INKEY$
*
* THIS ROUTINE GETS A KEYSTROKE FROM THE KEYBOARD
* returns with value in A, A=0 if no key is pressed
*
KEYIN        PSHS   B,X            SAVE REGISTERS
             BSR    LA1C8          GET KEYSTROKE
             TSTA                  SET FLAGS
             PULS   B,X,PC         RESTORE REGISTERS
LA1C8        LEAS   -3,S           ALLOCATE 3 STORAGE BYTES ON STACK
             LDX    #KEYBUF        SET X TO KEYBOARD MEMORY BUFFER
             CLR    ,S             RESET COLUMN COUNTER
             LDB    #$FE           COLUMN STROBE DATA, CHECK BIT 0 FIRST
**           A COLUMN IS BEING CHECKED IF THE
**           CORRESPONDING BIT IN THE COLUMN STROBE
**           REGISTER ($FF02) HAS A ZERO IN IT.
             STB    PIA0+2         STORE IN COLUMN STROBE REGISTER
LA1D4        BSR    LA238          GET KEY DATA
             STA    1,S            TEMP STORE KEY DATA
             EORA   ,X             COMPARE WITH KEY MEMORY DATA
             ANDA   ,X             ACCA=0 IF THIS KEY WAS DOWN LAST TIME, TOO
             LDB    1,S            GET NEW KEY DATA
             STB    ,X+            STORE IT IN KEY MEMORY
             TSTA                  WAS A NEW KEY DOWN?
             BNE    LA1ED          YES
             INC    ,S             NO, INCREMENT COLUMN COUNTER
             COMB                  SET CARRY FLAG
             ROL    PIA0+2         ROTATE COLUMN STROBE DATA LEFT ONE BIT
             BCS    LA1D4          ALL COLUMNS CHECKED WHEN ZERO IN THE
*                                  COLUMN STROBE DATA IS ROTATED INTO THE
*                                  CARRY FLAG
             PULS   B,X,PC         RESTORE REGISTERS

LA1ED        LDB    PIA0+2         GET COLUMN STROBE DATA

********************************************************************
** THIS ROUTINE CONVERTS THE KEY DEPRESSION INTO A NUMBER
** FROM 0-50 IN ACCB CORRESPONDING TO THE KEY THAT WAS DOWN
********************************************************************
             STB    2,S            TEMP STORE IT
             LDB    #$F8           TO MAKE SURE ACCB=0 AFTER FIRST ADDB #8
LA1F4        ADDB   #8             ADD 8 FOR EACH ROW OF KEYBOARD
             LSRA                  ACCA CONTAINS THE ROW NUMBER OF THIS KEY
*                                  ADD 8 FOR EACH ROW
             BCC    LA1F4          GO ON UNTIL A ZERO APPEARS IN THE CARRY
             ADDB   ,S             ADD IN THE COLUMN NUMBER
*******************************************************************
** NOW CONVERT THE VALUE IN ACCB INTO ASCII
             BEQ    LA245          THE 'AT SIGN' KEY WAS DOWN
             CMPB   #26            WAS IT A LETTER?
             BHI    LA247          NO
             ORB    #$40           YES, CONVERT TO UPPER CASE ASCII
             BSR    LA22D          CHECK FOR THE SHIFT KEY
             BEQ    LA20E          IT WAS DOWN
             LDA    CASFLG         NOT DOWN, CHECK THE UPPER/LOWER CASE FLAG
             BNE    LA20E          UPPER CASE
             ORB    #$20           CONVERT TO LOWER CASE
LA20E        STB    ,S             TEMP STORE ASCII VALUE
             LDX    #DEBVAL         GET KEYBOARD DEBOUNCE
;             JSR    LA7D3          GO WAIT A WHILE
!            LEAX   -1,X           DECREMENT DEBOUNCE COUNTER
             BNE    <              LOOP UNTIL DEBOUNCE TIME IS UP
             LDB    2,S            GET COLUMN STROBE DATA
             STB    PIA0+2         STORE IT
             BSR    LA238          READ A KEY
             CMPA   1,S            IS IT THE SAME KEY AS BEFORE DEBOUNCE?
             PULS   A              PUT THE ASCII VALUE OF KEY BACK IN ACCA
             BNE    LA22A          NOT THE SAME KEY
             CMPA   #$12           IS SHIFT ZERO DOWN?
             BNE    LA22B          NO
             COM    CASFLG         YES, TOGGLE UPPER/LOWER CASE FLAG
LA22A        CLRA                  SET ZERO FLAG TO INDICATE NO NEW KEY DOWN
LA22B        PULS   X,PC           RESTORE REGISTERS

*** TEST FOR THE SHIFT KEY
LA22D        LDA    #$7F           COLUMN STROBE
             STA    PIA0+2         STORE TO PIA
             LDA    PIA0           READ KEY DATA
             ANDA   #$40           CHECK FOR SHIFT KEY, SET ZERO FLAG IF DOWN
             RTS                   RETURN

*** READ THE KEYBOARD
LA238        LDA    PIA0           READ PIA0, PORT A TO SEE IF KEY IS DOWN
**                                 A BIT WILL BE ZERO IF ONE IS
             ORA    #$80           MASK OFF THE JOYSTICK COMPARATOR INPUT
             TST    PIA0+2         ARE WE STROBING COLUMN 7?
             BMI    LA244          NO
             ORA    #$C0           YES, FORCE ROW 6 TO BE HIGH -THIS WILL
**                                 CAUSE THE SHIFT KEY TO BE IGNORED
LA244        RTS                   RETURN

LA245        LDB    #51            CODE FOR 'AT SIGN'
LA247        LDX    #CONTAB-$36    POINT X TO CONTROL CODE TABLE
             CMPB   #33            KEY NUMBER <33?
             BLO    LA264          YES (ARROW KEYS, SPACE BAR, ZERO)
             LDX    #CONTAB-$54    POINT X TO MIDDLE OF CONTROL TABLE
             CMPB   #48            KEY NUMBER > 48?
             BHS    LA264          YES (ENTER, CLEAR, BREAK, AT SIGN)
             BSR    LA22D          CHECK SHIFT KEY (ACCA WILL CONTAIN STATUS)
             CMPB   #43            IS KEY A NUMBER, COLON OR SEMICOLON?
             BLS    LA25D          YES
             EORA   #$40           TOGGLE BIT 6 OF ACCA WHICH CONTAINS THE
**                                SHIFT DATA ONLY FOR SLASH, HYPHEN, PERIOD, COMMA
LA25D        TSTA                  SHIFT KEY DOWN?
             BEQ    LA20E          YES
             ADDB   #$10           NO, ADD IN ASCII OFFSET CORRECTION
             BRA    LA20E          GO CHECK FOR DEBOUNCE

LA264        ASLB                  MULT ACCB BY 2 - THERE ARE 2 ENTRIES IN
**                                 CONTROL TABLE FOR EACH KEY - ONE SHIFTED,
**                                 ONE NOT
             BSR    LA22D          CHECK SHIFT KEY
             BNE    LA26A          NOT DOWN
             INCB                  ADD ONE TO GET THE SHIFTED VALUE
LA26A        LDB    B,X            GET ASCII CODE FROM CONTROL TABLE
             BRA    LA20E          GO CHECK DEBOUNCE

*
*
* CONTROL TABLE   
*     UNSHIFTED, SHIFTED VALUES
CONTAB  FCB $5E,$5F   UP ARROW
        FCB $0A,$5B   DOWN ARROW
        FCB $08,$15   RIGHT ARROW
        FCB $09,$5D   LEFT ARROW
        FCB $20,$20   SPACE BAR
        FCB $30,$12   ZERO
        FCB $0D,$0D   ENTER
        FCB $0C,$5C   CLEAR
        FCB $03,$03   BREAK
        FCB $40,$13   AT SIGN

