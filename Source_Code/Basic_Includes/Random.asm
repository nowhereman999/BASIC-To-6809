; Getting a Random # in B where B is a number from 1 to 255 and return with value in B
RandomB:
        INC     Seed4
        LDA     Seed1
        EORA    Seed3
        EORA    Seed4
        STA     Seed1
        ADDA    Seed2
        STA     Seed2
        LSRA
        ADDA    Seed3
        EORA    Seed1
        STA     Seed3
        MUL                   ; A = (Random number of 0 to 255) * B
        INCA                  ; A now is a random number from 1 to B
        TFR     A,B           ; B = A
        RTS

; ------------------------------------------------------------
; RandomD (improved)
; Input : D = max (1..65535) unsigned
; Output: D = random (1..max)
; Uses  : Seed1 (16-bit LFSR state), Seed3 (16-bit Weyl state)
; Calls : MUL16
; Clobbers: X, U, CC
; ------------------------------------------------------------
WEYL_STEP   EQU     $61C8          ; odd constant (good Weyl increment)
RandomD:
      STD   ,--S        ; Save range on the stack
      BNE   @doit
      PULS  D,PC        ; return 0 if max=0 (your choice)
@doit:
; -------- 16-bit Galois LFSR step (poly $B400), right shift --------
      LDD   Seed1
      BNE   @seed_ok
      LDD   #$ACE1      ; never allow seed=0
      STD   Seed1
@seed_ok:
      LSRA
      RORB              ; carry = old LSB
      BCC   @no_xor
      EORA  #$B4        ; XOR $B400 into high byte if feedback=1
@no_xor:
      STD   Seed1       ; Seed1 updated (A=hi,B=lo)
; -------- Weyl add (breaks linearity / removes lattice artifacts) ---
      ADDD  Seed3
      ADDD  #WEYL_STEP  ; weyl += constant
      BNE   @rnd_ok
      ADDD  #$0001
@rnd_ok:
      STD   Seed3
      PSHS  D           ; Save Random value on the stack
      JSR   MUL16       ; D = high16(max*rnd16), low16 left at ,S
      LEAS  2,S         ; discard low16 left by MUL16
      ADDD  #$0001      ; 1..max
      RTS
        
Fast8BitRandCount FCB   $02
; B = Random number from 0 to 255
; Cycles through 4 different seeds (Seed1,2,3,4), so numbers can be repeated
RandomFast8Bit:
      PSHS  A,X
      LDA   Fast8BitRandCount
      LDX   #Seed1
@NextSeed1:
      LDB   A,X         ; Get last Random Number
      BEQ   @DoEOR      ; Handle input of zero
      ASLB              ; Shift it left, clear bit zero
      BEQ   @NoEOR      ; If the input was $80, skip the EOR
      BCC   @NoEOR      ; If the carry is now clear skip the EOR
@DoEOR: 
      EORB  #$1D        ; EOR with magic number %00011101
@NoEOR:
      STB   A,X         ; Save the output as the new seed
      INCA
      ANDA  #%00000011  ; Cycle value from 0 to 3
!     STA   Fast8BitRandCount
      PULS  A,X,PC      ; Restore and Return
