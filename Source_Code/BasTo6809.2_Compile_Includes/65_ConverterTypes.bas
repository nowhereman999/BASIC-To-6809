' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
ConvertLastType2NVT:
If LastType = NVT Then Return ' No conversion necessary
Select Case LastType
    Case 1 ' _Bit (signed, -1 to 0)
        Select Case NVT
            Case 2 ' To _Unsigned _Bit (0 to 1)
                ' Conversion: If source = -1, target = 1; else 0
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 3 ' To _Byte (-128 to 127), Sign-extend: 0 to 0; -1 to -1
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECB": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 4 ' (_Unsigned _Byte): Reinterpret/wrap: 0 to 0; -1 ($FF) to 255
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDB": B$ = "#$FF": C$ = "Set value of 255": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 5 ' (Integer): Sign-extend to 16-bit: 0 to 0; -1 to -1
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$FFFF": C$ = "X=0": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 16 bit value": GoSub AO
            Case 6 ' (Unsigned Integer): Wrap: 0 to 0; -1 to 65535 (all 1s)
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$FFFF": C$ = "X=0": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 16 bit value": GoSub AO
            Case 7 ' (Long): Sign-extend to 32-bit: 0 to 0; -1 to -1
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$FFFF": C$ = "X=0": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 32 bit value": GoSub AO
            Case 8 ' (_Unsigned Long): Wrap: 0 to 0; -1 to 4294967295
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$FFFF": C$ = "X=0": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 32 bit value": GoSub AO
            Case 9 ' (_Integer64): Sign-extend to 64-bit: 0 to 0; -1 to -1
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$FFFF": C$ = "X=0": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 10 ' (_Unsigned _Integer64): Wrap: 0 to 0; -1 to 18446744073709551615
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$FFFF": C$ = "X=0": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 11 ' (FFP): Cast to float: 0 to 0.0; -1 to -1.0                       0 = 3 zeros, -1 = $80,$80,$00
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BNE": B$ = "@MinusOne": GoSub AO
                A$ = "LDD": B$ = "#$0000": C$ = "value zero": GoSub AO
                A$ = "STD": B$ = ",-S": C$ = "Move stack, save FFP zero value": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save FFP zero value": GoSub AO
                A$ = "BRA": B$ = ">": GoSub AO
                Z$ = "@MinusOne": GoSub AO: A$ = "LDD": B$ = "#$0000": C$ = "LSB's of value -1": GoSub AO
                A$ = "LDD": B$ = "#$8000": C$ = "LSB's of value -1": GoSub AO
                A$ = "STD": B$ = ",-S": C$ = "Move stack, save FFP -1 value": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save FFP -1 value": GoSub AO
                Z$ = "!": GoSub AO
                Print #1,
            Case 12 ' (Double): Cast to double: 0 to 0.0; -1 to -1.0
                A$ = "LDX": B$ = "#$0000": C$ = "value -1": GoSub AO
                A$ = "LDU": B$ = "#$0000": C$ = "LSB's of value -1": GoSub AO
                A$ = "LDA": B$ = ",S+": C$ = "Get value off the stack, move the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BNE": B$ = "@MinusOne": GoSub AO
                A$ = "LDD": B$ = "#$0000": C$ = "value zero": GoSub AO
                A$ = "PSHS": B$ = "D,X,U": C$ = "Save Double zero on the stack": GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Save Double zero on the stack": GoSub AO
                A$ = "BRA": B$ = ">": GoSub AO
                Z$ = "@MinusOne": GoSub AO
                A$ = "LDD": B$ = "#$0080": C$ = "LSB of normalized exponent and MSB of mantissa of value -1": GoSub AO
                A$ = "LEAY": B$ = ",X": C$ = "value -1": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Save Double -1 on the stack": GoSub AO
                A$ = "LDD": B$ = "#$8000": C$ = "Sign of -1 and MSB of exponent of value -1": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save Double -1 on the stack": GoSub AO
                Z$ = "!": GoSub AO
                Print #1,
            Case Else
                Print "Error: Invalid conversion from _Bit to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 2 ' _Unsigned _Bit (0 to 1), Stored as: 0 ($00) or 1 ($01 or $FF for true).
        Select Case NVT
            Case 1 ' (_Bit): Truncate: 0 to 0; non-zero to -1 (logical)
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECB": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 3 ' (_Byte): Zero-extend: 0 to 0; 1 to 1
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 4 ' (_Unsigned _Byte): Zero-extend: 0 to 0; 1 to 1
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 5 ' (Integer): Zero-extend to 16-bit: 0 to 0; 1 to 1
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$0001": C$ = "X=77tyjtyuttyu": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 16 bit value": GoSub AO
            Case 6 ' (Unsigned Integer): Zero-extend: 0 to 0; 1 to 1
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$0001": C$ = "X=1": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 16 bit value": GoSub AO
            Case 7 ' (Long): Zero-extend to 32-bit: 0 to 0; 1 to 1
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$0001": C$ = "X=1": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 32 bit value": GoSub AO
            Case 8 ' (_Unsigned Long): Zero-extend: 0 to 0; 1 to 1
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$0001": C$ = "X=1": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 32 bit value": GoSub AO
            Case 9 ' (_Integer64): Zero-extend: 0 to 0; 1 to 1
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$0001": C$ = "X=1": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 10 ' (_Unsigned _Integer64): Zero-extend: 0 to 0; 1 to 1
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "LDX": B$ = "#$0001": C$ = "X=1": GoSub AO
                Z$ = "!": A$ = "STX": B$ = ",-S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "LDX": B$ = "#$0000": C$ = "X=0": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STX": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 11 ' (FFP): Cast: 0 to 0.0; 1 to 1.0                              0 = 3 zeros, 1 = $00,$80,$00
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BNE": B$ = "@One": GoSub AO
                A$ = "LDD": B$ = "#$0000": C$ = "value zero": GoSub AO
                A$ = "STD": B$ = ",-S": C$ = "Move stack, save FFP zero value": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save FFP zero value": GoSub AO
                A$ = "BRA": B$ = ">": GoSub AO
                Z$ = "@One": GoSub AO: A$ = "LDD": B$ = "#$0000": C$ = "LSB's of value 1": GoSub AO
                A$ = "LDD": B$ = "#$8000": C$ = "LSB's of value -1": GoSub AO
                A$ = "STD": B$ = ",-S": C$ = "Move stack, save FFP -1 value": GoSub AO
                A$ = "PSHS": B$ = "B": C$ = "Move stack, save FFP -1 value": GoSub AO
                Z$ = "!": GoSub AO
                Print #1,
            Case 12 ' (Double): Cast: 0 to 0.0; 1 to 1.0
                A$ = "LDX": B$ = "#$0000": C$ = "value zero": GoSub AO
                A$ = "LDU": B$ = "#$0000": C$ = "value zero": GoSub AO
                A$ = "LDA": B$ = ",S+": C$ = "Get value off the stack, move the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BNE": B$ = "@One": GoSub AO
                A$ = "LDD": B$ = "#$0000": C$ = "value zero": GoSub AO
                A$ = "PSHS": B$ = "D,X,U": C$ = "Save Double zero on the stack": GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Save Double zero on the stack": GoSub AO
                A$ = "BRA": B$ = ">": GoSub AO
                Z$ = "@One": GoSub AO
                A$ = "LDD": B$ = "#$0080": C$ = "LSB of normalized exponent and MSB of mantissa of value 1": GoSub AO
                A$ = "LEAY": B$ = ",X": C$ = "value 1": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Save Double 1 on the stack": GoSub AO
                A$ = "LDD": B$ = "#$0000": C$ = "Sign of 1 and MSB of exponent of value 1": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save Double 1 on the stack": GoSub AO
                Z$ = "!": GoSub AO
                Print #1,
            Case Else
                Print "Error: Invalid conversion from _Unsigned _Bit to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 3 ' _Byte (Signed, Min -128, Max 127)
        Select Case NVT
            Case 1 ' (_Bit): Truncate: 0 to 0; non-zero to -1 (logical)
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 2 ' (_Unsigned _Bit): Truncate: 0 to 0; non-zero to 1
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 4 ' (_Unsigned _Byte): Wrap if negative: -1 to 255 ($FF); positive unchanged
                ' Just use the same value
            Case 5 ' (Integer): Sign-extend (copy bit 7 to high byte): -128 to -128; 127 to 127; -1 to -1
                A$ = "LDB": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 16 bit value": GoSub AO
            Case 6 ' (Unsigned Integer): Wrap: -1 to 65535; positive zero-extend
                A$ = "LDB": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 16 bit value": GoSub AO
            Case 7 ' (Long): Sign-extend to 32-bit
                A$ = "LDB": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
            Case 8 ' (_Unsigned Long): Wrap negatives to large positive
                A$ = "LDB": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
            Case 9 ' (_Integer64): Sign-extend
                A$ = "LDB": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "Copy extended bits to B": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 10 ' (_Unsigned _Integer64): Wrap
                A$ = "LDB": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "Copy extended bits to B": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 11 ' (FFP): Cast: Exact
                A$ = "PULS": B$ = "B": C$ = "Get value off the stack, and fix stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "JSR": B$ = "S16_To_FFP": C$ = "Convert Signed 16bit integer in D to 3 Byte FFP @ ,S": GoSub AO
            Case 12 ' (Double): Cast: Exact
                A$ = "PULS": B$ = "B": C$ = "Get value off the stack, and fix stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "JSR": B$ = "Int2Double": C$ = "Convert signed 16bit integer in D to IEEE-754 Double @ ,S": GoSub AO
            Case Else
                Print "Error: Invalid conversion from _Byte to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 4 ' _Unsigned _Byte (0 to 255)
        Select Case NVT
            Case 1 ' (_Bit): Truncate: 0 to 0; non-zero to -1 (logical)
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECB": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 2 ' (_Unsigned _Bit): Truncate: 0 to 0; non-zero to 1
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 3 ' (_Byte): Wrap if >127: 255 to -1 ($FF); <=127 unchanged
                ' Just use the same value
            Case 5 ' (Integer): Zero-extend: 0 to 0; 255 to 255
                A$ = "CLR": B$ = ",-S": C$ = "Move stack, save 16 bit value": GoSub AO
            Case 6 ' (Unsigned Integer): Wrap: -1 to 65535; positive zero-extend
                A$ = "CLR": B$ = ",-S": C$ = "Move stack, save 16 bit value": GoSub AO
            Case 7 ' (Long): Zero-extend
                A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 32 bit value": GoSub AO
            Case 8 ' (_Unsigned Long): Zero-extend
                A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 32 bit value": GoSub AO
            Case 9 ' (_Integer64): Zero-extend (positive)
                A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 10 ' (_Unsigned _Integer64): Zero-extend
                A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 11 ' (FFP): Cast: Exact
                A$ = "PULS": B$ = "B": C$ = "Get value off the stack, and fix stack": GoSub AO
                A$ = "CLRA": C$ = "A=0": GoSub AO
                A$ = "JSR": B$ = "U16_To_FFP": C$ = "Convert Unsigned 16bit integer in D to 3 Byte FFP @ ,S": GoSub AO
            Case 12 ' (Double): Cast: Exact
                A$ = "PULS": B$ = "B": C$ = "Get value off the stack, and fix stack": GoSub AO
                A$ = "CLRA": C$ = "A=0": GoSub AO
                A$ = "JSR": B$ = "UnInt2Double": C$ = "Convert Unsigned 16bit integer in D to IEEE-754 Double @ ,S": GoSub AO
            Case Else
                Print "Error: Invalid conversion from _Unsigned _Byte to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 5 ' Integer (-32768 to 32767)
        Select Case NVT
            Case 1 ' (_Bit): Truncate: 0 to 0; non-zero to -1 (logical)
                A$ = "LDD": B$ = ",S+": C$ = "Get value off the stack, move the stack": GoSub AO
                A$ = "CLRA": C$ = "A=0": GoSub AO
                A$ = "BITB": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECA": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 2 ' (_Unsigned _Bit): Truncate: 0 to 0; non-zero to 1
                A$ = "LDD": B$ = ",S+": C$ = "Get value off the stack, move the stack": GoSub AO
                A$ = "CLRA": C$ = "A=0": GoSub AO
                A$ = "BITB": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCA": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 3 ' (_Byte): Keep low byte, sign preserved in 8 bits
                A$ = "PULS": B$ = "B": C$ = "Keep low byte, move the stack": GoSub AO
            Case 4 ' (_Unsigned _Byte): Keep low byte, wrap negatives
                A$ = "PULS": B$ = "B": C$ = "Keep low byte, move the stack": GoSub AO
            Case 6 ' (Unsigned Integer): Wrap negatives (e.g., -1 to 65535)
                ' Leave as it is
            Case 7, 8 ' (Long): Sign-extend to 32-bit
                A$ = "LDB": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                '    A$ = "TFR": B$ = "A,B": C$ = "Copy A to B": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Move stack, save 32 bit value": GoSub AO
                '  Case 8 ' (_Unsigned Long): Wrap to positive
                '   A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                '   A$ = "BMI": B$ = "@MinusOne": C$ = "Skip ahead if negative": GoSub AO
                '   A$ = "LDD": B$ = "#$0000": C$ = "D = $0000": GoSub AO
                '   A$ = "BRA": B$ = ">": C$ = "Skip ahead if positive": GoSub AO
                '   Z$ = "@MinusOne": GoSub AO: A$ = "LDD": B$ = "#$FFFF": C$ = "D = $FFFF": GoSub AO
                '   A$ = "STD": B$ = ",S": C$ = "save 32 bit value": GoSub AO
                '   Z$ = "!": A$ = "STD": B$ = ",--S": C$ = "Move stack, save 32 bit value": GoSub AO
                '   Print #1,
            Case 9, 10 ' (_Integer64): Sign-extend
                A$ = "LDB": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "Copy extended bits to B": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                ' Case 10 ' (_Unsigned _Integer64): Wrap
                '     A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                '     A$ = "TFR": B$ = "A,B": C$ = "Copy A to B": GoSub AO
                '     A$ = "SEX": C$ = "Sign extend": GoSub AO
                '     A$ = "TFR": B$ = "A,B": C$ = "Copy extended bits to B": GoSub AO
                '     A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                '     A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                '     A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 11 ' (FFP): Cast: Exact
                A$ = "PULS": B$ = "D": C$ = "Get value off the stack, and fix stack": GoSub AO
                A$ = "JSR": B$ = "S16_To_FFP": C$ = "Convert Signed 16bit integer in D to 3 Byte FFP @ ,S": GoSub AO
            Case 12 ' (Double): Cast: Exact
                A$ = "PULS": B$ = "D": C$ = "Get value off the stack, and fix stack": GoSub AO
                A$ = "JSR": B$ = "Int2Double": C$ = "Convert signed 16bit integer in D to IEEE-754 Double @ ,S": GoSub AO
            Case Else
                Print "Error: Invalid conversion from Integer to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 6 ' _Unsigned Integer (0 to 65535)
        Select Case NVT
            Case 1 ' (_Bit): Truncate: 0 to 0; non-zero to -1 (logical)
                A$ = "LDD": B$ = ",S+": C$ = "Get value off the stack, move the stack": GoSub AO
                A$ = "CLRA": C$ = "A=0": GoSub AO
                A$ = "BITB": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECA": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 2 ' (_Unsigned _Bit): Truncate: 0 to 0; non-zero to 1
                A$ = "LDD": B$ = ",S+": C$ = "Get value off the stack, move the stack": GoSub AO
                A$ = "CLRA": C$ = "A=0": GoSub AO
                A$ = "BITB": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCA": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 3 ' (_Byte): Keep low byte, sign preserved in 8 bits
                A$ = "PULS": B$ = "B": C$ = "Keep low byte, move the stack": GoSub AO
            Case 4 ' (_Unsigned _Byte): Keep low byte, wrap negatives
                A$ = "PULS": B$ = "B": C$ = "Keep low byte, move the stack": GoSub AO
            Case 5 ' (Integer): Wrap if >32767 (e.g., 65535 to -1)
                ' Leave as it is
            Case 7 ' (Long): Sign-extend to 32-bit
                A$ = "LDD": B$ = "#$0000": C$ = "D = $0000": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 32 bit value": GoSub AO
            Case 8 ' (_Unsigned Long): Wrap to positive
                A$ = "LDD": B$ = "#$0000": C$ = "D = $0000": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 32 bit value": GoSub AO
            Case 9 ' (_Integer64): Sign-extend
                A$ = "LDD": B$ = "#$0000": C$ = "D = $0000": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 10 ' (_Unsigned _Integer64): Wrap
                A$ = "LDD": B$ = "#$0000": C$ = "D = $0000": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 11 ' (FFP): Cast: Exact
                A$ = "PULS": B$ = "D": C$ = "Get value off the stack, and fix stack": GoSub AO
                A$ = "JSR": B$ = "U16_To_FFP": C$ = "Convert Unsigned 16bit integer in D to 3 Byte FFP @ ,S": GoSub AO
            Case 12 ' (Double): Cast: Exact
                A$ = "PULS": B$ = "D": C$ = "Get value off the stack, and fix stack": GoSub AO
                A$ = "JSR": B$ = "UnInt2Double": C$ = "Convert Unsigned 16bit integer in D to IEEE-754 Double @ ,S": GoSub AO
            Case Else
                Print "Error: Invalid conversion from _Unsigned Integer to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 7 ' Long (-2^31 to 2^31-1)
        Select Case NVT
            Case 1 ' (_Bit): Truncate: 0 to 0; non-zero to -1 (logical)
                A$ = "LEAS": B$ = "3,S": C$ = "Move Stack": GoSub AO
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECB": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 2 ' (_Unsigned _Bit): Truncate: 0 to 0; non-zero to 1
                A$ = "LEAS": B$ = "3,S": C$ = "Move Stack": GoSub AO
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 3 ' (_Byte): Keep low byte, sign preserved in 8 bits
                A$ = "LEAS": B$ = "3,S": C$ = "Move Stack": GoSub AO
            Case 4 ' (_Unsigned _Byte): Keep low byte, wrap negatives
                A$ = "LEAS": B$ = "3,S": C$ = "Move Stack": GoSub AO
            Case 5 ' (Integer): Wrap if >32767 (e.g., 65535 to -1)
                A$ = "LEAS": B$ = "2,S": C$ = "Move Stack": GoSub AO
            Case 6 ' (Unsigned Integer): Wrap negatives (e.g., -1 to 65535)
                A$ = "LEAS": B$ = "2,S": C$ = "Move Stack": GoSub AO
            Case 8 ' (_Unsigned Long): Wrap to positive
                ' Leave as it is
            Case 9, 10 ' (_Integer64): Sign-extend
                A$ = "LDB": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "Copy extended bits to B": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 11 ' (FFP): Cast: Exact
                A$ = "JSR": B$ = "S32_To_FFP": C$ = "Convert Signed 32bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
            Case 12 ' (Double): Cast: Exact
                A$ = "JSR": B$ = "S32_To_Double": C$ = "Convert signed 32bit integer @,S to IEEE-754 Double @ ,S": GoSub AO
            Case Else
                Print "Error: Invalid conversion from Long to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 8 ' _Unsigned Long (0 to 2^32-1)
        Select Case NVT
            Case 1 ' (_Bit): Truncate: 0 to 0; non-zero to -1 (logical)
                A$ = "LEAS": B$ = "3,S": C$ = "Move Stack": GoSub AO
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECB": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 2 ' (_Unsigned _Bit): Truncate: 0 to 0; non-zero to 1
                A$ = "LEAS": B$ = "3,S": C$ = "Move Stack": GoSub AO
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 3 ' (_Byte): Keep low byte, sign preserved in 8 bits
                A$ = "LEAS": B$ = "3,S": C$ = "Move Stack": GoSub AO
            Case 4 ' (_Unsigned _Byte): Keep low byte, wrap negatives
                A$ = "LEAS": B$ = "3,S": C$ = "Move Stack": GoSub AO
            Case 5 ' (Integer): Wrap if >32767 (e.g., 65535 to -1)
                A$ = "LEAS": B$ = "2,S": C$ = "Move Stack": GoSub AO
            Case 6 ' (Unsigned Integer): Wrap negatives (e.g., -1 to 65535)
                A$ = "LEAS": B$ = "2,S": C$ = "Move Stack": GoSub AO
            Case 7 ' (_signed Long)
                ' Leave as it is
            Case 9 ' (_Integer64): Sign-extend
                A$ = "LDD": B$ = "#$0000": C$ = "D = $0000": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 10 ' (_Unsigned _Integer64): Wrap
                A$ = "LDD": B$ = "#$0000": C$ = "D = $0000": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
                A$ = "STD": B$ = ",--S": C$ = "Move stack, save 64 bit value": GoSub AO
            Case 11 ' (FFP): Cast: Exact
                A$ = "JSR": B$ = "U32_To_FFP": C$ = "Unsigned 32bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
            Case 12 ' (Double): Cast: Exact
                A$ = "JSR": B$ = "U32_To_Double": C$ = "Convert Unsigned 32bit integer @,S to IEEE-754 Double @ ,S": GoSub AO
            Case Else
                Print "Error: Invalid conversion from _Unsigned Long to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 9 ' _Integer64 (-2^63 to 2^63-1)
        Select Case NVT
            Case 1 ' (_Bit): Truncate: 0 to 0; non-zero to -1 (logical)
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack": GoSub AO
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECB": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 2 ' (_Unsigned _Bit): Truncate: 0 to 0; non-zero to 1
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack": GoSub AO
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 3 ' (_Byte): Keep low byte, sign preserved in 8 bits
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack": GoSub AO
            Case 4 ' (_Unsigned _Byte): Keep low byte, wrap negatives
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack": GoSub AO
            Case 5 ' (Integer): Wrap if >32767 (e.g., 65535 to -1)
                A$ = "LEAS": B$ = "6,S": C$ = "Move Stack": GoSub AO
            Case 6 ' (Unsigned Integer): Wrap negatives (e.g., -1 to 65535)
                A$ = "LEAS": B$ = "6,S": C$ = "Move Stack": GoSub AO
            Case 7 ' (Long): Sign-extend to 32-bit
                A$ = "LEAS": B$ = "4,S": C$ = "Move Stack": GoSub AO
            Case 8 ' (_Unsigned Long): Wrap to positive
                A$ = "LEAS": B$ = "4,S": C$ = "Move Stack": GoSub AO
            Case 10 ' (_Unsigned _Integer64): Wrap
                ' Leave as it is
            Case 11 ' (FFP): Cast: Exact
                A$ = "JSR": B$ = "S64_To_FFP": C$ = "Convert Signed 64 bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
            Case 12 ' (Double): Cast: Exact
                A$ = "JSR": B$ = "S64_To_Double": C$ = "Convert signed 64 bit integer @,S to IEEE-754 Double @ ,S": GoSub AO
            Case Else
                Print "Error: Invalid conversion from _Integer64 to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 10 ' _Unsigned _Integer64 (0 to 2^64-1)
        Select Case NVT
            Case 1 ' (_Bit): Truncate: 0 to 0; non-zero to -1 (logical)
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack": GoSub AO
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECB": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 2 ' (_Unsigned _Bit): Truncate: 0 to 0; non-zero to 1
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack": GoSub AO
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save value on the stack": GoSub AO
            Case 3 ' (_Byte): Keep low byte, sign preserved in 8 bits
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack": GoSub AO
            Case 4 ' (_Unsigned _Byte): Keep low byte, wrap negatives
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack": GoSub AO
            Case 5 ' (Integer): Wrap if >32767 (e.g., 65535 to -1)
                A$ = "LEAS": B$ = "6,S": C$ = "Move Stack": GoSub AO
            Case 6 ' (Unsigned Integer): Wrap negatives (e.g., -1 to 65535)
                A$ = "LEAS": B$ = "6,S": C$ = "Move Stack": GoSub AO
            Case 7 ' (_signed Long)
                A$ = "LEAS": B$ = "4,S": C$ = "Move Stack": GoSub AO
            Case 8 ' (Unsigned Long): Wrap negatives (e.g., -1 to 65535)
                A$ = "LEAS": B$ = "4,S": C$ = "Move Stack": GoSub AO
            Case 9 ' (_Integer64): Sign-extend
                ' Leave as it is
            Case 11 ' (FFP): Cast: Exact
                A$ = "JSR": B$ = "U64_To_FFP": C$ = "Convert Unsigned 64 bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
            Case 12 ' (Double): Cast: Exact
                A$ = "JSR": B$ = "U64_To_Double": C$ = "Convert Unsigned 64 bit integer @,S to IEEE-754 Double @ ,S": GoSub AO
            Case Else
                Print "Error: Invalid conversion from _Unsigned _Integer64 to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 11 ' 3 byte FFP
        Select Case NVT
            Case 1 ' To _Bit
                A$ = "JSR": B$ = "FFP_TO_S16": C$ = "Convert 3 Byte FFP at ,S to 16-bit Signed integer at ,S": GoSub AO
                A$ = "LDD": B$ = ",S+": C$ = "Get value off the stack, move the stack": GoSub AO
                A$ = "CLRA": C$ = "A=0": GoSub AO
                A$ = "BITB": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECA": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save signed bit on the stack": GoSub AO
            Case 2 ' (_Unsigned _Bit): Truncate: 0 to 0; non-zero to 1
                A$ = "JSR": B$ = "FFP_TO_U16": C$ = "Convert 3 Byte FFP at ,S to 16-bit Unsigned integer at ,S": GoSub AO
                A$ = "LDD": B$ = ",S+": C$ = "Get value off the stack, move the stack": GoSub AO
                A$ = "CLRA": C$ = "A=0": GoSub AO
                A$ = "BITB": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCA": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save unsigned bit on the stack": GoSub AO
            Case 3 ' (_Byte): Keep low byte, sign preserved in 8 bits
                A$ = "JSR": B$ = "FFP_TO_S64": C$ = "Convert 3 Byte FFP @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack, this is a signed byte": GoSub AO
            Case 4 ' (_Unsigned _Byte): Keep low byte, wrap negatives
                A$ = "JSR": B$ = "FFP_TO_U64": C$ = "Convert 3 Byte FFP @ ,S to Unsigned 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack, this is an unsigned byte": GoSub AO
            Case 5 ' (Integer)
                A$ = "JSR": B$ = "FFP_TO_S64": C$ = "Convert 3 Byte FFP @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "6,S": C$ = "Move Stack, signed integer": GoSub AO
            Case 6 ' (Unsigned Integer): Wrap negatives (e.g., -1 to 65535)
                A$ = "JSR": B$ = "FFP_TO_U64": C$ = "Convert 3 Byte FFP @ ,S to Unsigned 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "6,S": C$ = "Move Stack, unsigned integer": GoSub AO
            Case 7 ' (Long): Sign-extend to 32-bit
                A$ = "JSR": B$ = "FFP_TO_S64": C$ = "Convert 3 Byte FFP @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "4,S": C$ = "Move Stack, signed 4 byte integer": GoSub AO
            Case 8 ' (_Unsigned Long): Wrap to positive
                A$ = "JSR": B$ = "FFP_TO_U64": C$ = "Convert 3 Byte FFP @ ,S to Unsigned 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "4,S": C$ = "Move Stack, unsigned 4 byte integer": GoSub AO
            Case 9 ' (_Integer64): Sign-extend
                A$ = "JSR": B$ = "FFP_TO_S64": C$ = "Convert 3 Byte FFP @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
            Case 10 ' (_Unsigned _Integer64): Wrap
                A$ = "JSR": B$ = "FFP_TO_U64": C$ = "Convert 3 Byte FFP @ ,S to Unsigned 64-bit Integer @ ,S": GoSub AO
            Case 12 ' To Double
                A$ = "JSR": B$ = "FFP_To_Double": C$ = "Convert FFP at ,S to 10 byte Double at ,S": GoSub AO
            Case Else
                Print "Error: Invalid conversion from FFP to type "; NVT; " on";: GoTo FoundError
        End Select
    Case 12 ' Double (approx -1.8E308 to 1.8E308)
        Select Case NVT
            Case 1 ' To _Bit
                A$ = "JSR": B$ = "DB_TO_S64": C$ = "Convert IEEE-754 Double @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack": GoSub AO
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "DECB": C$ = "Set value of -1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save signed bit on the stack": GoSub AO
            Case 2 ' (_Unsigned _Bit): Truncate: 0 to 0; non-zero to 1
                A$ = "JSR": B$ = "DB_TO_S64": C$ = "Convert IEEE-754 Double @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack": GoSub AO
                A$ = "CLRB": C$ = "B=0": GoSub AO
                A$ = "LDA": B$ = ",S": C$ = "Get value off the stack": GoSub AO
                A$ = "BITA": B$ = "#%00000001": C$ = "Test bit 0": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Skip ahead if zero": GoSub AO
                A$ = "INCB": C$ = "Set value of 1": GoSub AO
                Z$ = "!": A$ = "STB": B$ = ",S": C$ = "Save unsigned bit on the stack": GoSub AO
            Case 3 ' (_Byte): Keep low byte, sign preserved in 8 bits
                A$ = "JSR": B$ = "DB_TO_S64": C$ = "Convert IEEE-754 Double @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack, save signed byte": GoSub AO
            Case 4 ' (_Unsigned _Byte): Keep low byte, wrap negatives
                A$ = "JSR": B$ = "DB_TO_U64": C$ = "Convert IEEE-754 Double @ ,S to Unsigned 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "7,S": C$ = "Move Stack, save unsigned byte": GoSub AO
            Case 5 ' (Integer)
                A$ = "JSR": B$ = "DB_TO_S64": C$ = "Convert IEEE-754 Double @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "6,S": C$ = "Move Stack, save signed integer": GoSub AO
            Case 6 ' (Unsigned Integer): Wrap negatives (e.g., -1 to 65535)
                A$ = "JSR": B$ = "DB_TO_U64": C$ = "Convert IEEE-754 Double @ ,S to Unsigned 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "6,S": C$ = "Move Stack, save unsigned integer": GoSub AO
            Case 7 ' (Long): Sign-extend to 32-bit
                A$ = "JSR": B$ = "DB_TO_S64": C$ = "Convert IEEE-754 Double @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "4,S": C$ = "Move Stack, save signed 4 byte integer": GoSub AO
            Case 8 ' (_Unsigned Long): Wrap to positive
                A$ = "JSR": B$ = "DB_TO_U64": C$ = "Convert IEEE-754 Double @ ,S to Unsigned 64-bit Integer @ ,S": GoSub AO
                A$ = "LEAS": B$ = "4,S": C$ = "Move Stack, save unsigned 4 byte integer": GoSub AO
            Case 9 ' (_Integer64): Sign-extend
                A$ = "JSR": B$ = "DB_TO_S64": C$ = "Convert IEEE-754 Double @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
            Case 10 ' (_Unsigned _Integer64): Wrap
                A$ = "JSR": B$ = "DB_TO_U64": C$ = "Convert IEEE-754 Double @ ,S to Unsigned 64-bit Integer @ ,S": GoSub AO
            Case 11 ' To FFP
                A$ = "JSR": B$ = "Double_To_FFP": C$ = "Convert IEEE-754 Double at ,S to 3 Byte FFP at ,S": GoSub AO
            Case Else
                Print "Error: Invalid conversion from Double to type "; NVT; " on";: GoTo FoundError
        End Select
    Case Else
        Print "Error: Invalid source type "; LastType; " on";: GoTo FoundError
        System
End Select
Return

' Convert smaller of LeftType or RightType type to the largest type
ScaleSmallNumberOnStack:
If LeftType <> RightType Then ' convert smallest type to the largest type
    If LeftType > RightType Then
        GoSub ScaleRight2Left
    End If
    If RightType > LeftType Then
        GoSub ScaleLeft2Right ' Scale the LeftType to match the RightType
    End If
End If
Return

' Scale the LeftType to match the RightType
ScaleLeft2Right:
Select Case RightType
    Case 5, 6 ' Right is 16 bit (signed or unsigned)
        If LeftType = 1 Or LeftType = 3 Then
            ' Right is a 16 bit value, Left is an 8 bit signed value
            ' Sign Extend the left side to be 16 bits
            A$ = "LDB": B$ = ",S": C$ = "Get left value off the stack": GoSub AO
            A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
            A$ = "STA": B$ = ",-S": C$ = "Save the left value back on the stack, making room for a 16 bit value on the right": GoSub AO
        Else
            ' Expand the left side to be 16 bits
            A$ = "CLR": B$ = ",-S": C$ = "Save the left value back on the stack, making room for a 16 bit value on the right": GoSub AO
        End If
    Case 7, 8 ' Right is 32 bit (signed or unsigned)
        Select Case LeftType
            Case 1, 3 ' Left signed 8 bit to 32 bit
                A$ = "LDB": B$ = ",S": C$ = "Get left value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Save the left value back on the stack": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Save the left value back on the stack": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Save the left value back on the stack": GoSub AO
            Case 2, 4 ' Left Unsigned 8 bit to be 32 bits
                A$ = "CLR": B$ = ",-S": C$ = "Save the left value back on the stack": GoSub AO
                A$ = "CLR": B$ = ",-S": C$ = "Save the left value back on the stack": GoSub AO
                A$ = "CLR": B$ = ",-S": C$ = "Save the left value back on the stack": GoSub AO
            Case 5 ' Left signed 16 bit to signed 32 bit value
                A$ = "LDD": B$ = ",S": C$ = "Get left MSW value off the stack": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "B = the MSB": GoSub AO
                A$ = "SEX": C$ = "A now has the sign": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Save the left MSW value back on the stack": GoSub AO
                A$ = "STA": B$ = ",-S": C$ = "Save the left MSW value back on the stack": GoSub AO
            Case 6 ' Left UnSigned 16 bit to 32 bit value
                A$ = "CLR": B$ = ",-S": C$ = "Clear the left MSW value back on the stack": GoSub AO
                A$ = "CLR": B$ = ",-S": C$ = "Clear the left MSW value back on the stack": GoSub AO
        End Select
    Case 9, 10 ' Right is 64 bit (signed or unsigned)
        Select Case LeftType
            Case 1, 3 ' Left signed 8 bit to 64 bit
                A$ = "LDB": B$ = ",S": C$ = "Get left value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "Copy the sign bits to B": GoSub AO
                A$ = "PSHS": B$ = "A": C$ = "Save the new 16 bits Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 32 bit Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 48 bit Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 64 bit Left side value on the stack": GoSub AO
            Case 2, 4 ' Left Unsigned 8 bit to be 64 bits
                A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
                A$ = "PSHS": B$ = "A": C$ = "Save the new 16 bits Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 32 bit Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 48 bit Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 64 bit Left side value on the stack": GoSub AO
            Case 5 ' Left signed 16 bit to signed 64 bit value
                A$ = "LDB": B$ = ",S": C$ = "Get Left 16 bit MSB value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into A": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "Copy the sign bits to B": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 32 bit Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 48 bit Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 64 bit Left side value on the stack": GoSub AO
            Case 6 ' Left UnSigned 16 bit to 64 bit value
                A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 32 bit Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 48 bit Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 64 bit Left side value on the stack": GoSub AO
            Case 7 ' Left signed 32 bit to 64 bit value
                A$ = "LDB": B$ = ",S": C$ = "Get Left 32 bit MSB value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into A": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "D now has the sign bits": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 48 bit Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 64 bit Left side value on the stack": GoSub AO
            Case 8 ' Left Unsigned 32 bit to 64 bit value
                A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 48 bit Left side value on the stack": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the new 64 bit Left side value on the stack": GoSub AO
        End Select
    Case 11 ' Right is 3 byte FFP value
        ' Right is a 3 byte FFP value, Left is an 8,16 or 32 bit value
        Select Case LeftType
            Case 1, 3 ' Signed byte to  3 byte FFP value
                A$ = "PULS": B$ = "B": C$ = "Get the left byte off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
                A$ = "JSR": B$ = "S16_To_FFP": C$ = "Convert Signed 16 bit integer in D to 3 Byte FFP @ ,S": GoSub AO
            Case 2, 4 ' Bit is either 0 or 1 , or unsinged byte
                A$ = "PULS": B$ = "B": C$ = "Get the left byte off the stack": GoSub AO
                A$ = "CLRA": C$ = "MSB = 0": GoSub AO
                A$ = "JSR": B$ = "U16_To_FFP": C$ = "Convert Unsigned 16 bit integer in D to 3 Byte FFP @ ,S": GoSub AO
            Case 5
                ' Signed 16 bit value to  3 byte FFP value
                A$ = "PULS": B$ = "D": C$ = "Get the left bytes off the stack": GoSub AO
                A$ = "JSR": B$ = "S16_To_FFP": C$ = "Convert Signed 16 bit integer in D to 3 Byte FFP @ ,S": GoSub AO
            Case 6
                ' UnSigned 16 bit value to  3 byte FFP value
                A$ = "PULS": B$ = "D": C$ = "Get the left bytes off the stack": GoSub AO
                A$ = "JSR": B$ = "U16_To_FFP": C$ = "Convert Unsigned 16 bit integer in D to 3 Byte FFP @ ,S": GoSub AO
            Case 7 ' Signed 32 bit value to  3 byte FFP value
                A$ = "JSR": B$ = "S32_To_FFP": C$ = "Convert Signed 32 bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
            Case 8 ' UnSigned 32 bit value to  3 byte FFP value
                A$ = "JSR": B$ = "U32_To_FFP": C$ = "Convert Unsigned 32 bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
            Case 9 ' Signed 64 bit value to  3 byte FFP value
                A$ = "JSR": B$ = "S64_To_FFP": C$ = "Convert Signed 64 bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
            Case 10 ' UnSigned 64 bit value to  3 byte FFP value
                A$ = "JSR": B$ = "U64_To_FFP": C$ = "Convert Unsigned 64 bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
        End Select
    Case 12 ' Right is 10 byte Double-Precision Floating-Point value, which requires 10 bytes
        ' Right is an (10 byte) value, Left is an 8,16,32,64 bit integer or 3 byte FFP value
        Select Case LeftType
            Case 1, 3 ' Signed byte to IEEE 754 Double, 64 bit FP number
                A$ = "PULS": B$ = "B": C$ = "Get Left 8 bit signed value off the stack and move the stack pointer": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
                A$ = "JSR": B$ = "Int2Double": C$ = "Convert signed 16 bit integer in D to 10 byte Double @ ,S": GoSub AO
            Case 2, 4 ' Bit is either 0 or 1 , or unsinged byte
                A$ = "PULS": B$ = "B": C$ = "Get Left 8 bit signed value off the stack and move the stack pointer": GoSub AO
                A$ = "CLRA": C$ = "D = B unsigned": GoSub AO
                A$ = "JSR": B$ = "UnInt2Double": C$ = "Convert Unsigned 16 bit integer in D to 10 byte Double @ ,S": GoSub AO
            Case 5
                ' Signed 16 bit value to IEEE 754 Double, 64 bit FP number
                A$ = "PULS": B$ = "D": C$ = "Get Left 16 bit signed value off the stack": GoSub AO
                A$ = "JSR": B$ = "Int2Double": C$ = "Convert signed 16 bit integer in D to 10 byte Double @ ,S": GoSub AO
            Case 6
                ' UnSigned 16 bit value to IEEE 754 Double, 64 bit FP number
                A$ = "PULS": B$ = "D": C$ = "Get Left 16 bit UnSigned value off the stack": GoSub AO
                A$ = "JSR": B$ = "UnInt2Double": C$ = "Convert Unsigned 16 bit integer in D to 10 byte Double @ ,S": GoSub AO
            Case 7 ' Signed 32 bit value to IEEE 754 Double, 64 bit FP number
                A$ = "JSR": B$ = "S32_To_Double": C$ = "Convert signed 32bit integer @,S to 10 byte Double @ ,S": GoSub AO
            Case 8 ' UnSigned 32 bit value to IEEE 754 Double, 64 bit FP number
                A$ = "JSR": B$ = "U32_To_Double": C$ = "Convert Unsigned 32bit integer @,S to 10 byte Double @ ,S": GoSub AO
            Case 9 ' Signed 64 bit value to IEEE 754 Double, 64 bit FP number
                ' Change Left from Signed 64 bit value to 8 byte float value
                A$ = "JSR": B$ = "S64_To_Double": C$ = "Convert signed 64 bit integer @,S to 10 byte Double @ ,S": GoSub AO
            Case 10 ' UnSigned 64 bit value to IEEE 754 Double, 64 bit FP number
                ' Change Left from UnSigned 64 bit value to 8 byte float value
                A$ = "JSR": B$ = "U64_To_Double": C$ = "Convert Unsigned 64 bit integer @,S to 10 byte Double @ ,S": GoSub AO
            Case 11 ' Right is IEEE 754 Double-Precision Floating-Point value, which requires 10 bytes
                ' Change Left from 3 byte FFP value to 10 byte Double Float value
                A$ = "JSR": B$ = "FFP_To_Double": C$ = "Convert FFP at ,S to 10 byte Double at ,S": GoSub AO
                ' For now value of 13 are floating point numbers, with higher precision that code still must be written to handle.
        End Select
End Select
Return

' Scale the RightType to match the LeftType
ScaleRight2Left:
Select Case LeftType
    Case 5, 6 ' Left is 16 bit (signed or unsigned)
        A$ = "LDD": B$ = ",S": C$ = "Get left value off the stack": GoSub AO
        A$ = "STD": B$ = ",-S": C$ = "Save the left value back on the stack, making room for a 16 bit value on the right": GoSub AO
        If RightType = 1 Or RightType = 3 Then
            ' Left is a 16 bit value, Right is an 8 bit signed value
            ' Sign Extend the right side to be 16 bits
            A$ = "LDB": B$ = "3,S": C$ = "Get Right 8 bit value off the stack": GoSub AO
            A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
            A$ = "STA": B$ = "2,S": C$ = "Save the new 16 bit right side value on the stack": GoSub AO
        Else
            ' Expand the right side to be 16 bits
            A$ = "CLR": B$ = "2,S": C$ = "Save the left value back on the stack, making room for a 16 bit value on the right": GoSub AO
        End If
    Case 7, 8 ' Left is 32 bit (signed or unsigned)
        ' Left is a 32 bit value, Right is an 8 bit or 16 bit value
        Select Case RightType
            Case 1, 3 ' Right signed 8 bit to 32 bit
                A$ = "PULS": B$ = "D,X": C$ = "Get the left 32 bit value": GoSub AO
                A$ = "LEAS": B$ = "-3,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Save the left 32 bit value": GoSub AO

                A$ = "LDB": B$ = "7,S": C$ = "Get Right 8 bit value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
                A$ = "STA": B$ = "4,S": C$ = "Save the new 16 bit right side value on the stack": GoSub AO
                A$ = "STA": B$ = "5,S": C$ = "Save the new 24 bit right side value on the stack": GoSub AO
                A$ = "STA": B$ = "6,S": C$ = "Save the new 32 bit right side value on the stack": GoSub AO
            Case 2, 4 ' Right Unsigned 8 bit to be 32 bits
                A$ = "PULS": B$ = "D,X": C$ = "Get the left 32 bit value": GoSub AO
                A$ = "LEAS": B$ = "-3,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Save the left 32 bit value": GoSub AO

                A$ = "CLR": B$ = "4,S": C$ = "Save the left value back on the stack": GoSub AO
                A$ = "CLR": B$ = "5,S": C$ = "Save the left value back on the stack": GoSub AO
                A$ = "CLR": B$ = "6,S": C$ = "Save the left value back on the stack": GoSub AO
            Case 5 ' Right signed 16 bit to signed 32 bit value
                A$ = "PULS": B$ = "D,X": C$ = "Get the left 32 bit value": GoSub AO
                A$ = "LEAS": B$ = "-2,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Save the left 32 bit value": GoSub AO

                A$ = "LDB": B$ = "6,S": C$ = "Get Right 8 bit value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
                A$ = "STA": B$ = "4,S": C$ = "Save the new 32 bit right side value on the stack": GoSub AO
                A$ = "STA": B$ = "5,S": C$ = "Save the new 32 bit right side value on the stack": GoSub AO
            Case 6 ' Right UnSigned 16 bit to 32 bit value
                A$ = "PULS": B$ = "D,X": C$ = "Get the left 32 bit value": GoSub AO
                A$ = "LEAS": B$ = "-2,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Save the left 32 bit value": GoSub AO

                A$ = "CLR": B$ = "4,S": C$ = "Clear the right MSW value": GoSub AO
                A$ = "CLR": B$ = "5,S": C$ = "Clear the right MSW value": GoSub AO
        End Select
    Case 9, 10 ' Left is 64 bit (signed or unsigned)
        ' Left is a 64 bit value, Right is an 8,16 or 32 bit value
        Select Case RightType
            Case 1, 3 ' Right signed 8 bit to 64 bit
                ' Turn RightType from 8 bit into 64 bit value
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 64 bit value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-7,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put 64 bits of Left value on the stack": GoSub AO

                A$ = "LDB": B$ = "15,S": C$ = "Get Right 8 bit value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "Copy the sign bits to B": GoSub AO
                A$ = "STA": B$ = "14,S": C$ = "Save the new 16 bit right side value on the stack": GoSub AO
                A$ = "STD": B$ = "12,S": C$ = "Save the new 32 bit right side value on the stack": GoSub AO
                A$ = "STD": B$ = "10,S": C$ = "Save the new 48 bit right side value on the stack": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save the new 64 bit right side value on the stack": GoSub AO
            Case 2, 4 ' Left Unsigned 8 bit to be 64 bits
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 64 bit value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-7,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put 64 bits of Left value on the stack": GoSub AO

                A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
                A$ = "STA": B$ = "14,S": C$ = "Save the new 16 bit right side value on the stack": GoSub AO
                A$ = "STD": B$ = "12,S": C$ = "Save the new 32 bit right side value on the stack": GoSub AO
                A$ = "STD": B$ = "10,S": C$ = "Save the new 48 bit right side value on the stack": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save the new 64 bit right side value on the stack": GoSub AO
            Case 5 ' Right signed 16 bit to signed 64 bit value
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 64 bit value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-6,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put 64 bits of Left value on the stack": GoSub AO

                A$ = "LDB": B$ = "14,S": C$ = "Get Right 16 bit MSB value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into A": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "Copy the sign bits to B": GoSub AO
                A$ = "STD": B$ = "12,S": C$ = "Save the new 32 bit right side value on the stack": GoSub AO
                A$ = "STD": B$ = "10,S": C$ = "Save the new 48 bit right side value on the stack": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save the new 64 bit right side value on the stack": GoSub AO
            Case 6 ' Right UnSigned 16 bit to 64 bit value
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 64 bit value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-6,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put 64 bits of Left value on the stack": GoSub AO

                A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
                A$ = "STD": B$ = "12,S": C$ = "Save the new 32 bit right side value on the stack": GoSub AO
                A$ = "STD": B$ = "10,S": C$ = "Save the new 48 bit right side value on the stack": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save the new 64 bit right side value on the stack": GoSub AO
            Case 7 ' Right signed 32 bit to 64 bit value
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 64 bit value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-4,S": C$ = "Setup new 64 bit stack pointer": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put 64 bits of Left value on the stack": GoSub AO

                A$ = "LDB": B$ = "12,S": C$ = "Get right 32 bit value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into A": GoSub AO
                A$ = "STA": B$ = "11,S": C$ = "Save the new 40 bit right side value on the stack": GoSub AO
                A$ = "STA": B$ = "10,S": C$ = "Save the new 48 bit right side value on the stack": GoSub AO
                A$ = "STA": B$ = "9,S": C$ = "Save the new 56 bit right side value on the stack": GoSub AO
                A$ = "STA": B$ = "8,S": C$ = "Save the new 64 bit right side value on the stack": GoSub AO
            Case 8 ' Right Unsigned 32 bit to 64 bit value
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 64 bit value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-4,S": C$ = "Setup new 64 bit stack pointer": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put 64 bits of Left value on the stack": GoSub AO

                A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
                A$ = "STA": B$ = "10,S": C$ = "Save the new 48 bit right side value on the stack": GoSub AO
                A$ = "STA": B$ = "8,S": C$ = "Save the new 64 bit right side value on the stack": GoSub AO
        End Select
    Case 11 ' Left is FFP 3 byte floating point value, Right is an 8,16 or 32 bit value
        Select Case RightType
            Case 1, 3 ' Signed byte to FFP 3 byte floating point value
                A$ = "LDB": B$ = "3,S": C$ = "Get right byte value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
                A$ = "JSR": B$ = "S16_To_FFP": C$ = "Convert Signed 16bit integer in D to 3 Byte FFP @ ,S": GoSub AO
                A$ = "PULS": B$ = "A,X": C$ = "Get the new right FFP value": GoSub AO
                A$ = "PULS": B$ = "B,Y": C$ = "Get the old left FFP value": GoSub AO
                A$ = "LEAS": B$ = "1,S": C$ = "Move Stack past old right byte": GoSub AO
                A$ = "PSHS": B$ = "A,X": C$ = "Put the new right FFP value": GoSub AO
                A$ = "PSHS": B$ = "B,Y": C$ = "Put the old left FFP value": GoSub AO
            Case 2, 4 ' Bit is either 0 or 1 , or unsinged byte
                A$ = "LDB": B$ = "3,S": C$ = "Get right byte value off the stack": GoSub AO
                A$ = "CLRA": C$ = "MSB = 0": GoSub AO
                A$ = "JSR": B$ = "U16_To_FFP": C$ = "Convert Unsigned 16bit integer in D to 3 Byte FFP @ ,S": GoSub AO
                A$ = "PULS": B$ = "A,X": C$ = "Get the new right FFP value": GoSub AO
                A$ = "PULS": B$ = "B,Y": C$ = "Get the old left FFP value": GoSub AO
                A$ = "LEAS": B$ = "1,S": C$ = "Move Stack past old right byte": GoSub AO
                A$ = "PSHS": B$ = "A,X": C$ = "Put the new right FFP value": GoSub AO
                A$ = "PSHS": B$ = "B,Y": C$ = "Put the old left FFP value": GoSub AO
            Case 5
                ' Signed 16 bit value to FFP value
                A$ = "LDD": B$ = "3,S": C$ = "Get right byte value off the stack": GoSub AO
                A$ = "JSR": B$ = "S16_To_FFP": C$ = "Convert Signed 16bit integer in D to 3 Byte FFP @ ,S": GoSub AO
                A$ = "PULS": B$ = "A,X": C$ = "Get the new right FFP value": GoSub AO
                A$ = "PULS": B$ = "B,Y": C$ = "Get the old left FFP value": GoSub AO
                A$ = "LEAS": B$ = "2,S": C$ = "Move Stack past old right byte": GoSub AO
                A$ = "PSHS": B$ = "A,X": C$ = "Put the new right FFP value": GoSub AO
                A$ = "PSHS": B$ = "B,Y": C$ = "Put the old left FFP value": GoSub AO
            Case 6
                ' UnSigned 16 bit value to FFP value
                A$ = "LDD": B$ = "3,S": C$ = "Get right byte value off the stack": GoSub AO
                A$ = "JSR": B$ = "U16_To_FFP": C$ = "Convert Unsigned 16bit integer in D to 3 Byte FFP @ ,S": GoSub AO
                A$ = "PULS": B$ = "A,X": C$ = "Get the new right FFP value": GoSub AO
                A$ = "PULS": B$ = "B,Y": C$ = "Get the old left FFP value": GoSub AO
                A$ = "LEAS": B$ = "2,S": C$ = "Move Stack past old right byte": GoSub AO
                A$ = "PSHS": B$ = "A,X": C$ = "Put the new right FFP value": GoSub AO
                A$ = "PSHS": B$ = "B,Y": C$ = "Put the old left FFP value": GoSub AO
            Case 7 ' Signed 32 bit value to FFP value
                ' Left is a 3 byte FFP value, Right is a 32 bit INT value
                A$ = "LDD": B$ = "3,S": C$ = "Get MSB of 32bit Integer": GoSub AO
                A$ = "LDX": B$ = "5,S": C$ = "Get LSB of 32bit Integer": GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Save the 32 bit integer to be converted on the stack": GoSub AO
                A$ = "JSR": B$ = "S32_To_FFP": C$ = "Convert Signed 32bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
                A$ = "PULS": B$ = "A,X": C$ = "Get the new right FFP value": GoSub AO
                A$ = "PULS": B$ = "B,Y": C$ = "Get the old left FFP value": GoSub AO
                A$ = "LEAS": B$ = "4,S": C$ = "Move Stack past old right byte": GoSub AO
                A$ = "PSHS": B$ = "A,X": C$ = "Put the new right FFP value": GoSub AO
                A$ = "PSHS": B$ = "B,Y": C$ = "Put the old left FFP value": GoSub AO
            Case 8 ' UnSigned 32 bit value to FFP value
                ' Left is a 3 byte FFP value, Right is a UnSigned 32 bit INT value
                A$ = "LDD": B$ = "3,S": C$ = "Get MSB of 32bit Integer": GoSub AO
                A$ = "LDX": B$ = "5,S": C$ = "Get LSB of 32bit Integer": GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Save the 32 bit integer to be converted on the stack": GoSub AO
                A$ = "JSR": B$ = "U32_To_FFP": C$ = "Convert Unsigned 32bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
                A$ = "PULS": B$ = "A,X": C$ = "Get the new right FFP value": GoSub AO
                A$ = "PULS": B$ = "B,Y": C$ = "Get the old left FFP value": GoSub AO
                A$ = "LEAS": B$ = "4,S": C$ = "Move Stack past old right byte": GoSub AO
                A$ = "PSHS": B$ = "A,X": C$ = "Put the new right FFP value": GoSub AO
                A$ = "PSHS": B$ = "B,Y": C$ = "Put the old left FFP value": GoSub AO
            Case 9 ' Signed 64 bit value to FFP value
                ' Left is a 3 byte FFP value,  Right is a 64 bit signed value
                A$ = "LEAU": B$ = "3,S": C$ = "U points at the 64 bit number": GoSub AO
                A$ = "PULU": B$ = "D,X,Y": C$ = "Read MS 6 Bytes, move pointer": GoSub AO
                A$ = "LDU": B$ = ",U": C$ = "Get LS Bytes of the 64bit number": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Save the 64bit number on the stack": GoSub AO
                A$ = "JSR": B$ = "S64_To_FFP": C$ = "Convert Signed 64 bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
                A$ = "PULS": B$ = "A,X": C$ = "Get the new right FFP value": GoSub AO
                A$ = "PULS": B$ = "B,Y": C$ = "Get the old left FFP value": GoSub AO
                A$ = "LEAS": B$ = "8,S": C$ = "Move Stack past old right byte": GoSub AO
                A$ = "PSHS": B$ = "A,X": C$ = "Put the new right FFP value": GoSub AO
                A$ = "PSHS": B$ = "B,Y": C$ = "Put the old left FFP value": GoSub AO
            Case 10 ' UnSigned 64 bit value to FFP value
                ' Left is a 3 byte FFP value,  Right is a 64 bit unsigned value
                A$ = "LEAU": B$ = "4,S": C$ = "U points at the 64 bit number": GoSub AO
                A$ = "PULU": B$ = "D,X,Y": C$ = "Read MS 6 Bytes, move pointer": GoSub AO
                A$ = "LDU": B$ = ",U": C$ = "Get LS Bytes of the 64bit number": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Save the 64bit number on the stack": GoSub AO
                A$ = "JSR": B$ = "U64_To_FFP": C$ = "Convert Unsigned 64 bit integer @,S to 3 Byte FFP @ ,S": GoSub AO
                A$ = "PULS": B$ = "A,X": C$ = "Get the new right FFP value": GoSub AO
                A$ = "PULS": B$ = "B,Y": C$ = "Get the old left FFP value": GoSub AO
                A$ = "LEAS": B$ = "8,S": C$ = "Move Stack past old right byte": GoSub AO
                A$ = "PSHS": B$ = "A,X": C$ = "Put the new right FFP value": GoSub AO
                A$ = "PSHS": B$ = "B,Y": C$ = "Put the old left FFP value": GoSub AO
            Case 12 ' 10 byte Double on the Right to FFP value
                ' Left is a 3 byte FFP value, Right is a 10 byte Double
                A$ = "LEAU": B$ = "3,S": C$ = "U points at the 80 bit number": GoSub AO
                A$ = "PULU": B$ = "D,X,Y": C$ = "Read LSB of Exponent and the Mantissa, move pointer": GoSub AO
                A$ = "LDU": B$ = ",U": C$ = "Get LS Bytes of the 80 bit number": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Save the number on the stack": GoSub AO
                A$ = "LDD": B$ = "11,S": C$ = "Get the Sign and MSB of Exponent bytes of the 80 bit number": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save them on the stack": GoSub AO
                A$ = "JSR": B$ = "Double_To_FFP": C$ = "Convert 10 byte Double at ,S to 3 Byte FFP at ,S": GoSub AO
                ' Move the two 3 byte FFP values on the stack to where they need to be
                A$ = "PULS": B$ = "A,X": C$ = "Get the new right FFP value": GoSub AO
                A$ = "PULS": B$ = "B,Y": C$ = "Get the old left FFP value": GoSub AO
                A$ = "LEAS": B$ = "10,S": C$ = "Move Stack past old right byte": GoSub AO
                A$ = "PSHS": B$ = "A,X": C$ = "Put the new right FFP value": GoSub AO
                A$ = "PSHS": B$ = "B,Y": C$ = "Put the old left FFP value": GoSub AO
        End Select
    Case 12 ' Left is 10 byte Double 80 bit Floating-Point value, which requires 10 bytes, Right is an 8,16,32,64 bit integer or FFP 3 Byte value
        Select Case RightType
            Case 1, 3 ' Signed byte to 10 byte Double, 64 bit FP number
                ' First move 10 byte float to make room for the new 10 byte float on the right
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 8 byte value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-9,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put left 8 byte Left value on the stack, leaving room for 8 bytes on the right": GoSub AO
                A$ = "LDD": B$ = "17,S": C$ = "Get last two bytes of left double": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save last two bytes of left double": GoSub AO

                A$ = "LDB": B$ = "19,S": C$ = "Get Right 8 bit signed value off the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend B into D": GoSub AO
                A$ = "JSR": B$ = "Int2Double": C$ = "Convert signed 16bit integer in D to 10 byte Double @ ,S": GoSub AO

                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the first 8 bytes off the stack, move the stack": GoSub AO
                A$ = "STU": B$ = "18,S": C$ = "Save Double Number": GoSub AO
                A$ = "LEAU": B$ = "18,S": C$ = "Address to save Double Number": GoSub AO
                A$ = "PSHU": B$ = "D,X,Y": C$ = "Blast parts of the new double Number": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "Get the last 2 bytes off the stack, move the stack": GoSub AO
                A$ = "STD": B$ = "18,S": C$ = "Save Double Number": GoSub AO
            Case 2, 4 ' Bit is either 0 or 1 , or unsinged byte
                ' First move 10 byte float to make room for the new 10 byte float on the right
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 8 byte value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-9,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put left 8 byte Left value on the stack, leaving room for 8 bytes on the right": GoSub AO
                A$ = "LDD": B$ = "17,S": C$ = "Get last two bytes of left double": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save last two bytes of left double": GoSub AO

                A$ = "LDB": B$ = "19,S": C$ = "Get Right 8 bit signed value off the stack": GoSub AO
                A$ = "CLRA": C$ = "D = B": GoSub AO
                A$ = "JSR": B$ = "UnInt2Double": C$ = "Convert Unsigned 16 bit integer in D to IEEE-754 Double @ ,S": GoSub AO

                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the first 8 bytes off the stack, move the stack": GoSub AO
                A$ = "STU": B$ = "18,S": C$ = "Save Double Number": GoSub AO
                A$ = "LEAU": B$ = "18,S": C$ = "Address to save Double Number": GoSub AO
                A$ = "PSHU": B$ = "D,X,Y": C$ = "Blast parts of the new double Number": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "Get the last 2 bytes off the stack, move the stack": GoSub AO
                A$ = "STD": B$ = "18,S": C$ = "Save Double Number": GoSub AO

            Case 5 ' Right is a Signed 16 bit value to 8 byte float value
                ' First move 10 byte float to make room for the new 10 byte float on the right
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 8 byte value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-8,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put left 8 byte Left value on the stack, leaving room for 8 bytes on the right": GoSub AO
                A$ = "LDD": B$ = "16,S": C$ = "Get last two bytes of left double": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save last two bytes of left double": GoSub AO

                A$ = "LDD": B$ = "18,S": C$ = "Get Right 16 bit signed value off the stack": GoSub AO
                A$ = "JSR": B$ = "Int2Double": C$ = "Convert signed 16bit integer in D to IEEE-754 Double @ ,S": GoSub AO

                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the first 8 bytes off the stack, move the stack": GoSub AO
                A$ = "STU": B$ = "18,S": C$ = "Save Double Number": GoSub AO
                A$ = "LEAU": B$ = "18,S": C$ = "Address to save Double Number": GoSub AO
                A$ = "PSHU": B$ = "D,X,Y": C$ = "Blast parts of the new double Number": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "Get the last 2 bytes off the stack, move the stack": GoSub AO
                A$ = "STD": B$ = "18,S": C$ = "Save Double Number": GoSub AO
            Case 6 ' Right is UnSigned 16 bit value
                ' First move 10 byte float to make room for the new 10 byte float on the right
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 8 byte value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-8,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put left 8 byte Left value on the stack, leaving room for 8 bytes on the right": GoSub AO
                A$ = "LDD": B$ = "16,S": C$ = "Get last two bytes of left double": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save last two bytes of left double": GoSub AO

                A$ = "LDD": B$ = "18,S": C$ = "Get Right 16 bit signed value off the stack": GoSub AO
                A$ = "JSR": B$ = "UnInt2Double": C$ = "Convert Unsigned 16 bit integer in D to IEEE-754 Double @ ,S": GoSub AO

                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the first 8 bytes off the stack, move the stack": GoSub AO
                A$ = "STU": B$ = "18,S": C$ = "Save Double Number": GoSub AO
                A$ = "LEAU": B$ = "18,S": C$ = "Address to save Double Number": GoSub AO
                A$ = "PSHU": B$ = "D,X,Y": C$ = "Blast parts of the new double Number": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "Get the last 2 bytes off the stack, move the stack": GoSub AO
                A$ = "STD": B$ = "18,S": C$ = "Save Double Number": GoSub AO
            Case 7 ' Right is Signed 32 bit value
                ' First move 10 byte float to make room for the new 10 byte float on the right
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 8 byte value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-6,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put left 8 byte Left value on the stack, leaving room for 8 bytes on the right": GoSub AO
                A$ = "LDD": B$ = "14,S": C$ = "Get last two bytes of left double": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save last two bytes of left double": GoSub AO

                A$ = "LDD": B$ = "16,S": C$ = "Get Right 32 bit signed MSW value off the stack": GoSub AO
                A$ = "LDX": B$ = "18,S": C$ = "Get Right 32 bit signed LSW value off the stack": GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Put Right 32 bit value on the stack": GoSub AO
                A$ = "JSR": B$ = "S32_To_Double": C$ = "Convert signed 32 bit integer @,S to IEEE-754 Double @ ,S": GoSub AO

                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the first 8 bytes off the stack, move the stack": GoSub AO
                A$ = "STU": B$ = "18,S": C$ = "Save Double Number": GoSub AO
                A$ = "LEAU": B$ = "18,S": C$ = "Address to save Double Number": GoSub AO
                A$ = "PSHU": B$ = "D,X,Y": C$ = "Blast parts of the new double Number": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "Get the last 2 bytes off the stack, move the stack": GoSub AO
                A$ = "STD": B$ = "18,S": C$ = "Save Double Number": GoSub AO
            Case 8 ' Right is UnSigned 32 bit value
                ' First move 10 byte float to make room for the new 10 byte float on the right
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 8 byte value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-6,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put left 8 byte Left value on the stack, leaving room for 8 bytes on the right": GoSub AO
                A$ = "LDD": B$ = "14,S": C$ = "Get last two bytes of left double": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save last two bytes of left double": GoSub AO

                A$ = "LDD": B$ = "16,S": C$ = "Get Right 32 bit signed MSW value off the stack": GoSub AO
                A$ = "LDX": B$ = "18,S": C$ = "Get Right 32 bit signed LSW value off the stack": GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Put Right 32 bit value on the stack": GoSub AO
                A$ = "JSR": B$ = "U32_To_Double": C$ = "Convert Unsigned 32bit integer @,S to IEEE-754 Double @ ,S": GoSub AO

                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the first 8 bytes off the stack, move the stack": GoSub AO
                A$ = "STU": B$ = "18,S": C$ = "Save Double Number": GoSub AO
                A$ = "LEAU": B$ = "18,S": C$ = "Address to save Double Number": GoSub AO
                A$ = "PSHU": B$ = "D,X,Y": C$ = "Blast parts of the new double Number": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "Get the last 2 bytes off the stack, move the stack": GoSub AO
                A$ = "STD": B$ = "18,S": C$ = "Save Double Number": GoSub AO
            Case 9 ' Right is Signed 64 bit value
                ' First move 10 byte float to make room for the new 10 byte float on the right
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 8 byte value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-2,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put left 8 byte Left value on the stack, leaving room for 8 bytes on the right": GoSub AO
                A$ = "LDD": B$ = "10,S": C$ = "Get last two bytes of left double": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save last two bytes of left double": GoSub AO

                A$ = "LDD": B$ = "12,S": C$ = "Get Right 64 bit signed MSW value off the stack": GoSub AO
                A$ = "LDX": B$ = "14,S": C$ = "Get Right 64 bit signed LSW value off the stack": GoSub AO
                A$ = "LDY": B$ = "16,S": C$ = "Get Right 64 bit signed MSW value off the stack": GoSub AO
                A$ = "LDU": B$ = "18,S": C$ = "Get Right 64 bit signed LSW value off the stack": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put Right 64 bit value on the stack": GoSub AO
                A$ = "JSR": B$ = "S64_To_Double": C$ = "Convert signed 64 bit integer @,S to IEEE-754 Double @ ,S": GoSub AO

                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the first 8 bytes off the stack, move the stack": GoSub AO
                A$ = "STU": B$ = "18,S": C$ = "Save Double Number": GoSub AO
                A$ = "LEAU": B$ = "18,S": C$ = "Address to save Double Number": GoSub AO
                A$ = "PSHU": B$ = "D,X,Y": C$ = "Blast parts of the new double Number": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "Get the last 2 bytes off the stack, move the stack": GoSub AO
                A$ = "STD": B$ = "18,S": C$ = "Save Double Number": GoSub AO

            Case 10 ' Right is UnSigned 64 bit value
                ' First move 10 byte float to make room for the new 10 byte float on the right
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 8 byte value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-2,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put left 8 byte Left value on the stack, leaving room for 8 bytes on the right": GoSub AO
                A$ = "LDD": B$ = "10,S": C$ = "Get last two bytes of left double": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save last two bytes of left double": GoSub AO

                A$ = "LDD": B$ = "12,S": C$ = "Get Right 64 bit signed MSW value off the stack": GoSub AO
                A$ = "LDX": B$ = "14,S": C$ = "Get Right 64 bit signed LSW value off the stack": GoSub AO
                A$ = "LDY": B$ = "16,S": C$ = "Get Right 64 bit signed MSW value off the stack": GoSub AO
                A$ = "LDU": B$ = "18,S": C$ = "Get Right 64 bit signed LSW value off the stack": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put Right 64 bit value on the stack": GoSub AO
                A$ = "JSR": B$ = "U64_To_Double": C$ = "Convert Unsigned 64 bit integer @,S to IEEE-754 Double @ ,S": GoSub AO

                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the first 8 bytes off the stack, move the stack": GoSub AO
                A$ = "STU": B$ = "18,S": C$ = "Save Double Number": GoSub AO
                A$ = "LEAU": B$ = "18,S": C$ = "Address to save Double Number": GoSub AO
                A$ = "PSHU": B$ = "D,X,Y": C$ = "Blast parts of the new double Number": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "Get the last 2 bytes off the stack, move the stack": GoSub AO
                A$ = "STD": B$ = "18,S": C$ = "Save Double Number": GoSub AO

            Case 11 ' 3 byte FFP value to 10 byte Double, 80 bit FP number
                ' Change Right from 3 byte FFP value to 10 byte Double value
                ' First move 10 byte float to make room for the new 10 byte float on the right
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get left 8 byte value off the stack": GoSub AO
                A$ = "LEAS": B$ = "-7,S": C$ = "Move the stack pointer to make room for the new size of the right value": GoSub AO
                A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put left 8 byte Left value on the stack, leaving room for 8 bytes on the right": GoSub AO
                A$ = "LDD": B$ = "15,S": C$ = "Get last two bytes of left double": GoSub AO
                A$ = "STD": B$ = "8,S": C$ = "Save last two bytes of left double": GoSub AO
                A$ = "LEAU": B$ = "17,S": C$ = "Address of the FFP Number": GoSub AO
                A$ = "PULU": B$ = "A,X": C$ = "Get 3 byte FFP Number": GoSub AO
                A$ = "PSHS": B$ = "A,X": C$ = "Put 3 byte value on the stack": GoSub AO
                A$ = "JSR": B$ = "FFP_To_Double": C$ = "Convert FFP at ,S to 10 byte Double at ,S": GoSub AO
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the first 8 bytes off the stack, move the stack": GoSub AO
                A$ = "STU": B$ = "18,S": C$ = "Save Double Number": GoSub AO
                A$ = "LEAU": B$ = "18,S": C$ = "Address to save Double Number": GoSub AO
                A$ = "PSHU": B$ = "D,X,Y": C$ = "Blast parts of the new double Number": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "Get the last 2 bytes off the stack, move the stack": GoSub AO
                A$ = "STD": B$ = "18,S": C$ = "Save Double Number": GoSub AO
                ' For now value of 13 are floating point numbers, with higher precision that code still must be written to handle.
                '      13     ##   _Float '               Min E-4932, Max E+4932
        End Select
End Select
Return