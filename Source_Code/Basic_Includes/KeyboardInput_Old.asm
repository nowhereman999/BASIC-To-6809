* Keyboard input routine
*
* Just do a 'jsr InKey' then check the A register.
* Supports key repeat and features a 255-byte macro buffer
* which you can manually stock with simulated keystrokes.

* local variables (not compatible with read-only memory)
KeysBuffer rmb 256
KeyTim rmb 2
KeyTyp rmb 1
CtrKey rmb 1
PutMac fcb 0
GetMac fcb 0

*-------------------------------------------------------------
* The macro buffer has priority over real keystrokes.
* Manually store to the keyboard buffer to simulate keystrokes
* entry: a=key code to store in macro buffer
*-------------------------------------------------------------
PutKey  pshs    d,x
        inc     PutMac,pcr
        ldb     PutMac,pcr
        leax    KeysBuffer,pcr
        abx
        sta     ,X
        puls    d,x,pc
*-------------------------------------------------------------
* entry registers: none
* exit: a=key pressed
* a=0=nothing returned
* b=>0=was a Control-Key
*-------------------------------------------------------------
InKey   pshs    b,x,u
        clr     KeyTyp,pcr check macro buffer first
        ldb     GetMac,pcr
        cmpb    PutMac,pcr
        beq     @a
        incb
        stb     GetMac,pcr
        leax    KeysBuffer,pcr
        abx
        lda     ,X
        lbra    @exit
@a      clr     $FF02       * scan keyboard
        lda     $FF00       *
        coma
        anda #%01111111
        bne @rep1
        ldd #$FFFF
        std 338
        std 340
        std 342
        std 344
        clra
        clrb
        std KeyTim,pcr
        lbra @exit
@rep1   ldx #338
        ldb #8
@rep2   lda ,X+
        anda #63
        cmpa #63
        bne @rep3           *key being pressed, break the loop
        decb
        bne @rep2
        clra
        clrb
        std KeyTim,pcr
        bra @poll
@rep3   ldd KeyTim,pcr
        addd #1
        std KeyTim,pcr
        cmpd #1000
        blo @poll
        subd #90
        std KeyTim,pcr
        ldx #338
        ldb #8
@rep4   lda ,X
        ora #63             *repeat all but function keys
        sta ,X+
        decb
        bne @rep4
@poll   leas -5,S
        clr 3,S
        ldu #65280
        ldx #338
        lda #$ff
        sta ,S              *column
        sta 2,S             *row mask
@f      lda 2,S
        rola
        lbcc @pdone         * 7 rows done
        sta 2,S
        inc ,S
        lbsr @scan
        sta 1,S
        eora ,X
        anda ,X
        ldb 1,S
        stb ,X+
        incb
        beq @f
        inc 3,S
        tsta
        beq @f
        clrb
@e      lsra
        bcs @e2
        addb #8
        bra @e
@e2     leax @KeyCnv+28,pcr
        addb ,S
        beq @g3
        cmpb #26
        ble @g2
        leax @KeyCnv-54,pcr
        cmpb #32
        ble @g3
        leax @KeyCnv-84,pcr
        cmpb #48
        bge @g3
        lbsr @shift
        cmpb #43
        ble @g
        eora #64
@g      tsta
        bne @final
        addb #16
        bra @final
@g2     orb #64
        lbsr @shift
        ora 282
        bne @final
        orb #32             *shift letter
        bra @final
@g3     aslb
        lbsr @shift
        beq @h
        incb                *shifted code
@h      ldb B,X
@final  tstb
        beq POL300
        bsr @alt
        beq @i
        orb #128
        bra POL300
@i      bsr @ctrl
        beq POL300
        leax @CtrCnv,pcr
CTR010  tst ,X
        beq CTR100
        cmpb ,X
        beq CTR020
        leax 2,X
        bra CTR010
CTR020  ldb 1,X
        bra POL300
CTR100  andb #31
        bra POL300
POL300  stb 4,S
        bsr @w
        lda #255
        bsr @scan
        inca
        bne @pdone
        lda 2,S
        bsr @scan
        cmpa 1,S
        bne @pdone
        cmpb #18
        bne @prts
        com 282
@pdone  clr 4,S
@prts   leas 4,S
        lda ,S+
@exit   ldb CtrKey,pcr
        tsta
        puls b,x,u,pc
@scan   sta 2,U
        lda ,U
        ora #128            *set stop-bit
        rts
@w      ldx #1200
@w2     leax -1,X
        bne @w2
        rts
@alt    lda #$F7
        bsr @shf2
        pshs CC
        lsla 128
        ora KeyTyp,pcr
        sta KeyTyp,pcr
        puls CC,PC
@ctrl lda #$EF
        bsr @shf2
        sta CtrKey,pcr
        rts
@shift  lda #127
@shf2   sta 2,U
        lda ,U
        coma
        anda #64
        rts
*-------------------------------------------------------------
* keys and their shift-key conversion
@KeyCnv fdb $0B5F
        fdb $0A5B
        fdb $087F
        fdb $095D
        fdb $2020
        fdb $3012
        fdb $0D0D
        fdb $0C5C
        fdb $031B
        fdb $0000 alt/shift-alt
        fdb $0000 ctrl/shift-ctrl
        fdb $0000 f1/shift-f1
        fdb $0000 f2/shift-f2
        fdb $0000 shift
        fdb $4013
*-------------------------------------------------------------
* keys and their control-key conversion
@CtrCnv fcb 48,126 TILDE
        fcb 50,12
        fcb 52,124 4=124
        fcc "8["
        fcc "9]"
        fcb 44,123 <
        fcb 46,125 >
        fcb 64,96
        fcc ":"
        fcb 124
        fcc "/"
        fcb 92
        fcb 64,94
        fcc "-"
        fcb 95
        fcb 32,0
        fcb 0
