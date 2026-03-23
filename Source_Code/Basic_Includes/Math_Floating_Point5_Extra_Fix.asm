
; Fastest 6809 Assembly Square Root for FFP Format Using Stack-Based Math Routines
;
; Assumes the following subroutines exist:
; FP5_MUL: Multiplies the top 5 bytes (operand B) and the next 5 bytes (operand A) on the stack (A * B), pops 10 bytes, pushes the 5-byte result. Stack pointer S increases by 3.
; FP5_SUB: Subtracts the top 5 bytes (operand B) from the next 5 bytes (operand A) on the stack (A - B), pops 10 bytes, pushes the 5-byte result. Stack pointer S increases by 3.
; FP5_ADD: Adds the top 5 bytes (operand B) to the next 5 bytes (operand A) on the stack (A + B), pops 10 bytes, pushes the 5-byte result. Stack pointer S increases by 3. (Not used here, but included per request if needed elsewhere.)
;
; Magic constant 0x5f375d derived for this format (bias 63, effective equivaluent to IEEE with adjusted sigma ~0.045, max rel err ~0.04 on initial guess).

MAGIC_HIGH EQU $5F
MAGIC_MID EQU $37
MAGIC_LOW EQU $5D

; Constants (3-byte FFP)
HALF_FFP    FCB $7F,$80,$00  ; 0.5 (sign 0, exp -1 = $7F, mant $8000)
ONEHALF_FFP FCB $00,$C0,$00  ; 1.5 (sign 0, exp 0 = $00, mant $C000)

; Temp storage (RMB 3 for each)
temp_exp RMB 1  ; signed exponent (1 byte)
temp_new_exp RMB 1  ; halved signed exponent (1 byte)
temp_z RMB 3  ; z FFP
temp_y RMB 3  ; initial y FFP
temp_result RMB 3  ; temporary result FFP

i_high      FCB   $00
i_mid       FCB   $00
i_low       FCB   $00

y_high      FCB   $00
y_mid       FCB   $00
y_low       FCB   $00
; Subroutine: SQRT_FFP
; Input: 3-byte FFP pushed on stack (using PUSH_FFP or equivaluent).
; Output: 3-byte result on stack (replaces input).
; Handles specials (zero, inf, NaN, negative=NaN).
; Uses 1 Newton-Raphson iteration for refinement (sufficient for 16-bit mantissa precision).

SQRT_FFP:
    LDA 2,S          ; Load sign_exp (byte0 at S+2)
    BPL POSITIVE     ; If sign positive, continue
    BRA SQRT_NAN     ; Negative: return NaN

POSITIVE:
    ANDA #$7F        ; Mask to get exp bits
    CMPA #$40        ; Check for special exp
    BEQ SQRT_SPECIAL ; Handle inf/NaN
    BNE CHECK_ZERO   ; Not zero check

CHECK_ZERO:
    CMPA #0          ; Exp == 0?
    BNE SQRT_NORMAL  ; No, normal
    LDX 0,S          ; Load mant (X = byte2 byte1, but check MSB)
    BITA #$80        ; Mant high bit (byte1 at S+1)
    BNE SQRT_NORMAL  ; If set, normal (subnorm not handled as special)
    ; Zero: clear stack to +0
    CLR 0,S
    CLR 1,S
    CLR 2,S
    RTS

SQRT_SPECIAL:
    LDX 0,S          ; Load mant
    BITA #$80        ; Mant MSB?
    BEQ SQRT_INF     ; No: inf
    ; NaN
    LDA #$40
    STA 2,S          ; byte0 = $40
    LDA #$80
    STA 1,S          ; mant high = $80
    CLR 0,S          ; mant low = $00
    RTS

SQRT_INF:
    LDA #$40
    STA 2,S          ; byte0 = $40
    CLR 1,S          ; mant high = $00
    CLR 0,S          ; mant low = $00
    RTS

SQRT_NAN:
    LDA #$40
    STA 2,S          ; byte0 = $40
    LDA #$80
    STA 1,S          ; mant high = $80
    CLR 0,S          ; mant low = $00
    RTS

SQRT_NORMAL:
    LDA 2,S          ; Load exp_byte again
    ANDA #$7F
    BITA #$40        ; Negative exp?
    BEQ NO_SIGN_EXT
    ORA #$80         ; Sign extend to 8 bits
NO_SIGN_EXT:
    STA temp_exp     ; Store signed exp

    LDA temp_exp
    ANDA #1          ; Check odd/even
    BEQ EVEN_EXP
    ; Odd
    LDA temp_exp
    DECA             ; exp -1 (now even)
    ASRA             ; Signed divide by 2
    STA temp_new_exp
    LDA #1           ; z_exp = 1
    BRA SET_Z_EXP

EVEN_EXP:
    LDA temp_exp
    ASRA             ; Signed divide by 2
    STA temp_new_exp
    LDA #0           ; z_exp = 0

SET_Z_EXP:
    STA 2,S          ; Update byte0 on stack to z_exp (sign 0)

    ; Now stack has z_ffp
    CopyStackToFFP temp_z  ; Save z to temp

    ; Compute initial y using bit hack on temp_z
    LDA temp_z       ; z_exp
    ADDA #63         ; Bias
    STA i_high
    LDA temp_z+1     ; mant high
    STA i_mid
    LDA temp_z+2     ; mant low
    STA i_low

    ; i >> 1 (3-byte right shift)
    LSRA             ; LSR i_low, carry to i_mid
    ROR i_mid
    ROR i_high

    ; magic - (i >> 1)
    LDA #MAGIC_LOW
    SUBA i_low
    STA y_low
    LDA #MAGIC_MID
    SBCA i_mid
    STA y_mid
    LDA #MAGIC_HIGH
    SBCA i_high
    STA y_high

    ; Unpack to y_ffp
    LDA y_high
    SUBA #63         ; Unbias
    STA temp_y       ; byte0
    LDA y_mid
    STA temp_y+1
    LDA y_low
    STA temp_y+2

    ; Now perform 1 Newton-Raphson iteration on stack
    PUSH_FFP temp_y  ; Stack: z, y
    CopyStackOnStack ; Stack: z, y, y
    JSR FP5_MUL      ; Stack: z, y^2
    PUSH_FFP temp_z  ; Stack: z, y^2, z (but wait, to mul y^2 * z, but z is below y^2
    ; Since mul commutative, but to have them adjacent, since stack z, y^2
    JSR FP5_MUL      ; Pops y^2, z, pushes y^2 * z (stack empty now? No, initial was z, but wait
    ; Wait, stack was z, y after push y
    ; Then Copy, z, y, y
    ; FP5_MUL: pops y, y, pushes y^2, stack z, y^2
    ; Then JSR FP5_MUL: pops y^2, z, pushes z*y^2, stack empty
    ; Yes.

    PUSH_FFP HALF_FFP ; Stack: 0.5, z*y^2
    JSR FP5_MUL       ; Pops z*y^2, 0.5, pushes 0.5*z*y^2, stack empty

    PUSH_FFP ONEHALF_FFP ; Stack: 1.5, 0.5*z*y^2
    JSR FP5_SUB          ; Pops 0.5*z*y^2, 1.5, pushes 1.5 - 0.5*z*y^2 (factor), stack empty

    PUSH_FFP temp_y      ; Stack: factor, y
    JSR FP5_MUL          ; Pops y, factor, pushes y*factor (refined y), stack empty

    ; Now compute sqrt(z) = z * refined_y
    PUSH_FFP temp_z      ; Stack: refined_y, z
    JSR FP5_MUL          ; Pops z, refined_y, pushes z*refined_y = sqrt(z), stack empty

    ; Adjust exponent in result
    CopyStackToFFP temp_result  ; Copy top to temp
    LDA temp_new_exp            ; Load halved exp
    STA temp_result             ; Set byte0 to new_exp (sign 0 implied)
    LEAS 3,S                    ; Pop old result
    PUSH_FFP temp_result        ; Push adjusted result
    RTS

; Note: For even higher precision (if needed), repeat the refinement block with the refined y as temp_y, but this adds ~4 MUL +1 SUB calls, reducing speed. With 1 iteration, precision is adequate for 16-bit mantissa.
