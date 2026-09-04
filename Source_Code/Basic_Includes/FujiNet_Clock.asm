; FujiNet network clock for the CoCo.
; FNTIME$() returns local FujiNet time as "YYYY-MM-DD HH:MM:SS".

FN_CLOCK_GET_TIME         EQU     $23
FN_CLOCK_TIMEOUT_PASSES   EQU     12

FN_TimeRaw                RMB     6       ; year since 1900, month, day, h, m, s

FN_TimeString:
        CLR     FN_LastError
        JSR     FN_DrainInput
        LBCS    FN_TimeError
        LDA     #FN_CLOCK_GET_TIME
        STA     >FN_BECKER_DATA
        LDU     #FN_TimeRaw
        LDA     #6
        STA     _StrVar_PF00             ; temporary receive count
FN_TimeReceiveLoop:
        LDB     #FN_CLOCK_TIMEOUT_PASSES
        JSR     FN_WaitBytePassesB
        LBCS    FN_TimeError
        STA     ,U+
        DEC     _StrVar_PF00
        BNE     FN_TimeReceiveLoop

        LDX     #_StrVar_PF00+1
        LDA     FN_TimeRaw
        CMPA    #100
        BLO     FN_Time19xx
        CMPA    #200
        BLO     FN_Time20xx
        SUBA    #200
        LDB     #'2'
        STB     ,X+
        LDB     #'1'
        STB     ,X+
        BRA     FN_TimeYearSuffix
FN_Time20xx:
        SUBA    #100
        LDB     #'2'
        STB     ,X+
        LDB     #'0'
        STB     ,X+
        BRA     FN_TimeYearSuffix
FN_Time19xx:
        LDB     #'1'
        STB     ,X+
        LDB     #'9'
        STB     ,X+
FN_TimeYearSuffix:
        JSR     FN_TimeAppendTwoDigits
        LDA     #'-'
        STA     ,X+
        LDA     FN_TimeRaw+1
        JSR     FN_TimeAppendTwoDigits
        LDA     #'-'
        STA     ,X+
        LDA     FN_TimeRaw+2
        JSR     FN_TimeAppendTwoDigits
        LDA     #' '
        STA     ,X+
        LDA     FN_TimeRaw+3
        JSR     FN_TimeAppendTwoDigits
        LDA     #':'
        STA     ,X+
        LDA     FN_TimeRaw+4
        JSR     FN_TimeAppendTwoDigits
        LDA     #':'
        STA     ,X+
        LDA     FN_TimeRaw+5
        JSR     FN_TimeAppendTwoDigits
        LDA     #19
        STA     _StrVar_PF00
        JMP     FN_ReturnScratchString

; Append unsigned A as two decimal digits (all clock members are below 100).
FN_TimeAppendTwoDigits:
        CLRB
FN_TimeDigitLoop:
        CMPA    #10
        BLO     FN_TimeDigitsReady
        SUBA    #10
        INCB
        BRA     FN_TimeDigitLoop
FN_TimeDigitsReady:
        ADDB    #'0'
        STB     ,X+
        ADDA    #'0'
        STA     ,X+
        RTS

FN_TimeError:
        STA     FN_LastError
        CLR     _StrVar_PF00
        ORCC    #$01
        JMP     FN_ReturnScratchString
