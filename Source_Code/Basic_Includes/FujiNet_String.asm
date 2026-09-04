; Shared stack-string helper for FujiNet functions that send BASIC strings.
; Included only for functions that need it. The compiler's existing
; _StrVar_PF00 scratch string is reused, so this allocates no extra buffer.

; Consume a compiler [length][characters] stack string into _StrVar_PF00.
FN_CopyStackString:
        PULS    Y
        LDX     #_StrVar_PF00
        LDB     ,S+
        STB     ,X+
        BEQ     FN_CopyStackStringDone
FN_CopyStackStringLoop:
        LDA     ,S+
        STA     ,X+
        DECB
        BNE     FN_CopyStackStringLoop
FN_CopyStackStringDone:
        JMP     ,Y

; Variants used by FujiNet calls with more than one string argument.  The
; compiler always provides three 256-byte scratch strings, so these helpers
; avoid adding permanent buffers to the optional FujiNet modules.
FN_CopyStackStringPF01:
        PULS    Y
        LDX     #_StrVar_PF01
        BRA     FN_CopyStackStringToX

FN_CopyStackStringIFRight:
        PULS    Y
        LDX     #_StrVar_IFRight

FN_CopyStackStringToX:
        LDB     ,S+
        STB     ,X+
        BEQ     FN_CopyStackStringToXDone
FN_CopyStackStringToXLoop:
        LDA     ,S+
        STA     ,X+
        DECB
        BNE     FN_CopyStackStringToXLoop
FN_CopyStackStringToXDone:
        JMP     ,Y

; Tail-call this routine after building a length-prefixed result in PF00.
; It converts that scratch value into the compiler's expression-stack string
; representation and returns directly to the compiled BASIC program.
FN_ReturnScratchString:
        PULS    Y
        LDB     _StrVar_PF00
        BEQ     FN_ReturnScratchLength
        LDX     #_StrVar_PF00+1
        ABX
FN_ReturnScratchLoop:
        LDA     ,-X
        PSHS    A
        DECB
        BNE     FN_ReturnScratchLoop
FN_ReturnScratchLength:
        LDB     _StrVar_PF00
        PSHS    B
        JMP     ,Y
