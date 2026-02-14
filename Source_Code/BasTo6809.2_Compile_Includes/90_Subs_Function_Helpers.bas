Sub ConvertToFP (Num$)
    Dim x As Double
    Dim sign As Integer
    Dim e As Integer
    Dim y As Double
    Dim m As _Integer64

    ' Parse the string to a floating-point number
    x = Val(Num$)

    If x = 0 Then
        ' Special case: number is zero
        Exponent = 0
        Byte1 = 0
        Byte2 = 0
        Byte3 = 0
        Byte4 = 0
    Else
        ' Determine sign and take absolute value
        sign = 0
        If x < 0 Then
            sign = 1
            x = -x
        End If

        ' Calculate exponent: e = floor(log2(x))
        e = Int(Log(x) / Log(2))

        If e < -127 Then
            ' Underflow: set to zero
            Exponent = 0
            Byte1 = 0
            Byte2 = 0
            Byte3 = 0
            Byte4 = 0
        ElseIf e > 127 Then
            ' Overflow: set to zero (could handle differently if needed)
            Exponent = 0
            Byte1 = 0
            Byte2 = 0
            Byte3 = 0
            Byte4 = 0
        Else
            ' Bias exponent by $80 (128)
            Exponent = e + 128

            ' Normalize the number to [1, 2)
            y = x / (2 ^ e)

            ' Compute mantissa as 32-bit integer with hidden bit
            m = Int(y * 2147483648# + 0.5)

            ' Extract mantissa bytes (big-endian)
            Byte4 = m And 255 ' Bits 7-0
            Byte3 = (m \ 256) And 255 ' Bits 15-8
            Byte2 = (m \ 65536) And 255 ' Bits 23-16
            Byte1 = (m \ 16777216) And 255 ' Bits 31-24

            ' Clear hidden bit (MSB of byte1) and set sign bit
            Byte1 = Byte1 And 127
            If sign Then Byte1 = Byte1 Or 128
        End If
    End If
End Sub

Sub ConvertToIEEE32_NoRoundingWell (Num$)
    Dim x1 As Double
    Dim sign As Integer
    Dim e As Integer
    Dim y As Double
    Dim m As Long

    ' Parse the string to a floating-point number
    x1 = Val(Num$)

    If x1 = 0 Then
        ' Special case: number is zero
        Byte1 = 0
        Byte2 = 0
        Byte3 = 0
        Byte4 = 0
    Else
        ' Determine sign and take absolute value
        sign = 0
        If x1 < 0 Then
            sign = 1
            x1 = -x1
        End If

        ' Calculate exponent: e = floor(log2(x1))
        e = Int(Log(x1) / Log(2))

        If e < -127 Then
            ' Underflow: set to zero
            Byte1 = 0
            Byte2 = 0
            Byte3 = 0
            Byte4 = 0
        ElseIf e > 127 Then
            ' Overflow: set to infinity (sign-dependent)
            If sign Then
                Byte1 = &HFF
            Else
                Byte1 = &H7F
            End If
            Byte2 = &H80
            Byte3 = 0
            Byte4 = 0
        Else
            ' Bias exponent by 127
            Exponent = e + 127

            ' Normalize the number to [1, 2)
            y = x1 / (2 ^ e)

            ' Compute mantissa as 23-bit integer (fraction part), with rounding
            m = Int((y - 1) * 8388608# + 0.5) ' 2^23 = 8388608, +0.5 for round-to-nearest

            ' Pack into bytes (big-endian format)
            ' Byte1: sign bit + exponent bits 7-1
            Byte1 = (sign * 128) Or (Exponent \ 2)

            ' Byte2: exponent bit 0 + mantissa bits 22-16
            Byte2 = ((Exponent And 1) * 128) Or ((m \ 65536) And 127)

            ' Byte3: mantissa bits 15-8
            Byte3 = (m \ 256) And 255

            ' Byte4: mantissa bits 7-0
            Byte4 = m And 255
        End If
    End If
End Sub

Sub ConvertToIEEE32 (Num$)
    Dim x As Double
    Dim sign As Integer
    Dim e As Integer
    Dim y As Double
    Dim fraction As Double
    Dim extended_m As _Unsigned _Integer64 ' Use 64-bit for extended precision (23 + extra bits)
    Dim mant As _Unsigned Long
    Dim g As Integer, r As Integer, s As Integer

    ' Parse the string to a floating-point number
    x = Val(Num$)

    If x = 0 Then
        ' Special case: number is zero
        Byte1 = 0
        Byte2 = 0
        Byte3 = 0
        Byte4 = 0
    Else
        ' Determine sign and take absolute value
        sign = 0
        If x < 0 Then
            sign = 1
            x = -x
        End If

        ' Calculate exponent: e = floor(log2(x))
        e = Int(Log(x) / Log(2))

        If e < -127 Then
            ' Underflow: set to zero
            Byte1 = 0
            Byte2 = 0
            Byte3 = 0
            Byte4 = 0
        ElseIf e > 127 Then
            ' Overflow: set to infinity (sign-dependent)
            If sign Then
                Byte1 = &HFF
            Else
                Byte1 = &H7F
            End If
            Byte2 = &H80
            Byte3 = 0
            Byte4 = 0
        Else
            ' Bias exponent by 127
            Exponent = e + 127

            ' Normalize the number to [1, 2)
            y = x / (2 ^ e)

            ' Fraction = y - 1
            fraction = y - 1

            ' Compute extended mantissa with 26 bits for G (bit 23), R (bit 22), S (OR of lower)
            extended_m = Int(fraction * 67108864# + 0.5) ' 2^26 = 67108864

            ' Extract G, R, S
            g = (extended_m And 4) \ 4 ' Bit 2 (G = bit after LSB)
            r = (extended_m And 2) \ 2 ' Bit 1 (R)
            s = extended_m And 1 ' Bit 0 (S; for more bits, OR all lower)

            ' Truncate to 23 bits
            mant = extended_m \ 8 ' Shift right 3 bits (discard G,R,S)

            ' Apply IEEE-754 round to nearest, ties to even
            If r = 1 Then
                If s = 1 Or g = 1 Then
                    mant = mant + 1 ' Round up
                Else
                    ' Tie case, round to even if LSB odd
                    If (mant And 1) = 1 Then
                        mant = mant + 1
                    End If
                End If
            End If

            ' Check for overflow from rounding (mant >= 2^23)
            If mant >= 8388608 Then
                mant = mant \ 2 ' Shift right (normalize back to <2^23)
                Exponent = Exponent + 1 ' Increment exponent
                If Exponent > 254 Then ' Overflow to inf (255)
                    If sign Then
                        Byte1 = &HFF
                    Else
                        Byte1 = &H7F
                    End If
                    Byte2 = &H80
                    Byte3 = 0
                    Byte4 = 0
                    Exit Sub
                End If
            End If

            ' Pack into bytes (big-endian)
            Byte1 = (sign * 128) Or (Exponent \ 2)
            Byte2 = ((Exponent And 1) * 128) Or ((mant \ 65536) And 127)
            Byte3 = (mant \ 256) And 255
            Byte4 = mant And 255
        End If
    End If
End Sub


Sub DoubleToCustomFloat (x As Double) ' , result AS STRING)
    ' result = SPACE$(3)
    Dim ieee As String * 8
    ieee = MKD$(x)
    Dim b(1 To 8) As _Unsigned _Byte
    b(1) = Asc(Mid$(ieee, 1, 1))
    b(2) = Asc(Mid$(ieee, 2, 1))
    b(3) = Asc(Mid$(ieee, 3, 1))
    b(4) = Asc(Mid$(ieee, 4, 1))
    b(5) = Asc(Mid$(ieee, 5, 1))
    b(6) = Asc(Mid$(ieee, 6, 1))
    b(7) = Asc(Mid$(ieee, 7, 1))
    b(8) = Asc(Mid$(ieee, 8, 1))
    Dim int64 As _Integer64
    int64 = b(1) + b(2) * 256 + b(3) * 65536 + b(4) * 16777216
    int64 = int64 + b(5) * 4294967296 + b(6) * 1099511627776 + b(7) * 281474976710656 + b(8) * 72057594037927936
    Dim sign As _Unsigned _Byte
    sign = _IIf(int64 < 0, &H80, 0)
    Dim ieee_exp As Long
    ieee_exp = _ShR(int64, 52) And &H7FF
    Dim Mask52 As _Integer64
    Mask52 = 4503599627370495 ' 2^52 - 1
    Dim mant As _Integer64
    mant = int64 And Mask52
    If ieee_exp = &H7FF Then
        Byte1 = sign Or &H40
        Byte2 = 0
        Byte3 = 0
        If mant <> 0 Then Byte2 = &H80
        Exit Sub
    End If
    If x = 0 Then
        Byte1 = sign: Byte2 = 0: Byte3 = 0
        Exit Sub
    End If
    Dim unbiased_exp As Long
    Dim sig53 As _Integer64
    If ieee_exp = 0 Then
        unbiased_exp = -1022
        sig53 = mant
    Else
        unbiased_exp = ieee_exp - 1023
        sig53 = 4503599627370496 Or mant ' 2^52 OR mant
    End If
    ' Find msb position
    Dim msb As Long
    msb = GetMSB(sig53)
    Dim shift_left As Long
    If msb > 0 Then
        shift_left = 53 - msb
        sig53 = _ShL(sig53, shift_left)
        unbiased_exp = unbiased_exp - shift_left
    End If
    ' Now get sig16 with rounding
    Dim sig16 As _Unsigned Long
    sig16 = _ShR(sig53, 37)
    Dim Mask37 As _Integer64
    Mask37 = 137438953471 ' 2^37 - 1
    Dim remain As _Integer64
    remain = sig53 And Mask37
    Dim guard As Integer, round_bit As Integer, sticky As Integer
    guard = _ShR(remain, 36) And 1
    round_bit = _ShR(remain, 35) And 1
    Dim Mask35 As _Integer64
    Mask35 = 34359738367 ' 2^35 - 1
    sticky = (remain And Mask35) <> 0
    If guard Then
        If round_bit Or sticky Then
            sig16 = sig16 + 1
        Else
            If (sig16 And 1) Then sig16 = sig16 + 1
        End If
    End If
    If sig16 >= 65536 Then
        sig16 = _ShR(sig16, 1)
        unbiased_exp = unbiased_exp + 1
    End If
    If unbiased_exp > 63 Then
        Byte1 = sign Or &H40 ' Mid$(result, 1, 1) = CHR$(sign OR &H40)
        Byte2 = 0 ' Mid$(result, 2, 1) = CHR$(0)
        Byte3 = 0 ' Mid$(result, 3, 1) = CHR$(0)
        Exit Sub
    End If
    If unbiased_exp < -63 Then
        Byte1 = sign: Byte2 = 0: Byte3 = 0 ' Mid$(result, 1, 1) = CHR$(sign)
        Exit Sub
    End If
    Dim exp7 As _Byte
    exp7 = unbiased_exp
    Byte1 = sign Or (exp7 And &H7F)
    Byte2 = _ShR(sig16, 8) And &HFF
    Byte3 = sig16 And &HFF
End Sub


' Returns -1 (true) if the operator is left-associative
' Returns  0 (false) if right-associative
'
' Most operators are left-associative.
' Exponentiation (if you support it) is usually right-associative.

Function IsLeftAssociative% (v As Integer)
    Select Case v
        Case TK_NEG
            IsLeftAssociative% = 0

        Case &H5E ' ^
            ' Right-associative: 2^3^2 = 2^(3^2)
            IsLeftAssociative% = 0

        Case Else
            ' + - * / = AND OR etc. (if they were ASCII, which they aren't)
            IsLeftAssociative% = -1
    End Select

End Function


'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

Function GetPrecedence% (opValue As Integer)
    ' Higher number = higher precedence
    Select Case opValue
        Case &H28 ' (
            GetPrecedence = 90
        Case &H5E ' Exponent
            GetPrecedence = 80
        Case &H14, TK_NEG ' "NOT"     *** Could add unary minus value here (need to identify it maybe use "NEG" with HEX code of $16)
            GetPrecedence = 70 ' unary logical
        Case &H2A, &H2F, &H5C, &H12, &H15 ' "*", "/", "\", "MOD" ,DIVR
            GetPrecedence = 60
        Case &H2B, &H2D ' "+", "-"
            GetPrecedence = 50
        Case &H3D, &H60, &H3C, &H3E, &H61, &H62 ' "=", "<>", "<", ">", "<=", ">="
            GetPrecedence = 40
        Case &H10 ' "AND"
            GetPrecedence = 30
        Case &H13 ' "XOR"
            GetPrecedence = 25
        Case &H11 ' "OR"
            GetPrecedence = 20
        Case Else
            ' Unknown operator
            GetPrecedence = 0
    End Select
End Function

Function IsStringToken% (t$)
    If Len(t$) = 0 Then IsStringToken% = 0: Exit Function
    Dim k As Integer
    k = Asc(Left$(t$, 1))
    If k = TK_StringVar Or k = TK_StrArray Then IsStringToken% = -1: Exit Function
    If k = TK_SpecialChar Then
        If Len(t$) >= 2 And Asc(Mid$(t$, 2, 1)) = TK_Quote Then IsStringToken% = -1: Exit Function
    End If
    If k = &HF9 Then IsStringToken% = -1: Exit Function ' your "string already on 6809 stack" marker
    IsStringToken% = 0
End Function

'===========================================================
' Return -1 (true) if RPNEntry is the LAST AND in this IF
'===========================================================
Function IsLastANDInIF% (CurEntry As Integer)
    Dim i As Integer
    Dim t$
    Dim tag As Integer
    Dim opVal As Integer

    For i = CurEntry + 1 To RPNLast
        t$ = RPNOutput$(i)
        If Len(t$) >= 2 Then
            tag = Asc(Left$(t$, 1))
            If tag = TK_OperatorCommand Then
                opVal = Asc(Mid$(t$, 2, 1))
                If opVal = OP_AND Then
                    IsLastANDInIF% = 0 ' there IS another AND after this
                    Exit Function
                End If
            End If
        End If
    Next i

    ' No more ANDs after this one
    IsLastANDInIF% = -1
End Function

'===========================================================
' Return -1 (true) if RPNEntry is the LAST OR in this IF
'===========================================================
Function IsLastORInIF% (CurEntry As Integer)
    Dim i As Integer
    Dim t$
    Dim tag As Integer
    Dim opVal As Integer

    For i = CurEntry + 1 To RPNLast
        t$ = RPNOutput$(i)
        If Len(t$) >= 2 Then
            tag = Asc(Left$(t$, 1))
            If tag = TK_OperatorCommand Then
                opVal = Asc(Mid$(t$, 2, 1))
                If opVal = OP_OR Then
                    IsLastORInIF% = 0 ' there IS another OR after this
                    Exit Function
                End If
            End If
        End If
    Next i

    ' No more ORs after this one
    IsLastORInIF% = -1
End Function

Function GetMSB& (inputVal As _Integer64)
    If inputVal = 0 Then GetMSB = 0: Exit Function
    Dim bitPos As Long
    bitPos = 0
    Dim t As _Integer64
    t = inputVal
    Do
        bitPos = bitPos + 1
        t = _ShR(t, 1)
    Loop Until t = 0
    GetMSB = bitPos
End Function

' Returns -1 if Expression$ is a STRING expression, 0 if not
FUNCTION ExprIsString% (E$)
    DIM p AS LONG
    DIM t AS INTEGER, c AS INTEGER

    p = 1
    DO WHILE p <= LEN(E$)
        t = ASC(MID$(E$, p, 1))

        ' Direct string starters
        IF t = &HF1 OR t = &HF3 OR t = &HFD THEN
            ExprIsString% = -1
            EXIT FUNCTION
        END IF

        ' Special-char token (F5, next byte is the character)
        IF t = &HF5 THEN
            IF p + 1 > LEN(E$) THEN EXIT DO
            c = ASC(MID$(E$, p + 1, 1))

            ' Skip whitespace and leading parentheses:  F5 ' '  or  F5 '('
            IF c = 32 OR c = 9 OR c = 40 THEN
                p = p + 2
                _CONTINUE
            END IF

            ' Quoted literal starts with: F5 '"'
            IF c = 34 THEN
                ExprIsString% = -1
                EXIT FUNCTION
            END IF

            ' Some other special char: stop scanning
            EXIT DO
        END IF

        ' Anything else: stop scanning
        EXIT DO
    LOOP

    ExprIsString% = 0
END FUNCTION