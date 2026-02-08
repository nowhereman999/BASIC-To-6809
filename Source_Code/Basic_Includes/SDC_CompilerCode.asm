; the compiler builds string @ ,S but the SDC library expects the filename to be at _StrVar_PF00

; Copy filename off the stack into _StrVar_PF00
SDC_FilenameToStrVar_PF00:
    PULS    Y               ; Get the return address
    LDX     #_StrVar_PF00
    LDB     ,S+             ; Get the length of the string
    STB     ,X+
!   LDA     ,S+
    STA     ,X+
    DECB
    BNE     <
    JMP     ,Y              ; Return
