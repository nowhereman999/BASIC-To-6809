' Enter with LeftType set, RightType set & LargestType set
NumFunctionAdd:
Z$ = "; Doing ADD:": GoSub AO
If Largesttype < 5 Then GoTo AddSameType1 ' Both are a byte size of 1
If (LeftType = 5 Or LeftType = 6) And (RightType = 5 Or RightType = 6) Then GoTo AddSameType2 ' Both are a byte size of 2
If LeftType < 7 And RightType < 7 Then GoTo AddMaxType2 ' One is 1 byte the other is 2 byte
If (LeftType = 7 Or LeftType = 8) And (RightType = 7 Or RightType = 8) Then GoTo AddSameType4 ' Both are a byte size of 4
If (LeftType = 9 Or LeftType = 10) And (RightType = 9 Or RightType = 10) Then GoTo AddSameType8 ' Both are a byte size of 8
If LeftType = 11 And RightType = 11 Then GoTo AddSameFFP ' Both are FP 3 bytes
If LeftType = 12 And RightType = 12 Then GoTo AddSameFP8 ' Both are FP 8 bytes

' Otherwise Types are not the same
Z$ = "; Makeboth the same type": GoSub AO
GoSub ScaleSmallNumberOnStack ' Convert smaller of LeftType or RightType type to the largest type
Select Case Largesttype
    Case 7, 8 ' Same 4 byte values
        GoTo AddSameType4
    Case 9, 10 ' Same 8 byte values
        GoTo AddSameType8
    Case 11 ' Same FFP values
        GoTo AddSameFFP
    Case 12 'Same Double values
        GoTo AddSameFP8
End Select

' Both are 1 byte
AddSameType1:
' Both are 1 byte (8 bits)
A$ = "PULS": B$ = "B": C$ = "Left value is 8 bits": GoSub AO
A$ = "ADDB": B$ = ",S+": C$ = "Right is an 8 bit value, save the stack": GoSub AO
A$ = "PSHS": B$ = "B": C$ = "Save the new 8 bit right side value": GoSub AO
Return

'       right        left
' ; A = B (Integer) - C (byte)
' Pushed on the stack    Left, Right
' On the stack we have Value2, Value1
'
' One is 1 byte, the other is 2 bytes
AddMaxType2:
If LeftType < 5 Then
    ' Left is 1 byte and right is 2 bytes
        A$ = "PULS": B$ = "B": C$ = "Get the left 8 bit value": GoSub AO
    If LeftType = 1 Or LeftType = 3 Then
        'Signed
        A$ = "SEX": C$ = "Sign Extend B into D": GoSub AO
    Else
    ' Unsigned
        A$ = "CLRA": C$ = "MSB = 0": GoSub AO
    End If
    A$ = "ADDD": B$ = ",S++": C$ = "Add left 16 bit value, fix the stack the stack": GoSub AO
    A$ = "PSHS": B$ = "D": C$ = "Save the new 16 bit value": GoSub AO
Else
    ' Left is 2 bytes and right is 1 byte
    If RightType = 1 Or RightType = 3 Then
    'Signed
        A$ = "LDB": B$ = "2,S": C$ = "Get the right 8 bit value": GoSub AO
        A$ = "SEX": C$ = "Sign Extend B into D": GoSub AO
        A$ = "ADDD": B$ = ",S+": C$ = "Add left 16 bit value, move the stack": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Save the new 16 bit value": GoSub AO
    Else
    ' Unsigned
        A$ = "LDB": B$ = "2,S": C$ = "Get the right 8 bit value": GoSub AO
        A$ = "CLRA": C$ = "Clear MSB": GoSub AO
        A$ = "ADDD": B$ = ",S+": C$ = "Add left 16 bit value, move the stack": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Save the new 16 bit value": GoSub AO
    End if
End If
Return

' Both are 2 bytes
AddSameType2:
A$ = "PULS": B$ = "D": C$ = "D = left 16 bit value, move the stack": GoSub AO
A$ = "ADDD": B$ = ",S++": C$ = "D=D+ right 16 bit value, fix the stack": GoSub AO
A$ = "PSHS": B$ = "D": C$ = "Save the new 16 bit right side value": GoSub AO
Return

' Both are 4 bytes
AddSameType4: '
A$ = "JSR": B$ = "Add_4ByteTo4Byte": C$ = "Do 4 byte Add on the stack and adjust the stack": GoSub AO
Return

' Both are 8 bytes
AddSameType8:
A$ = "JSR": B$ = "Add_8ByteTo8Byte": C$ = "Do 8 byte Add on the stack and adjust the stack": GoSub AO
Return

' Both are FP 3 bytes in FFP format
AddSameFFP:
A$ = "JSR": B$ = "FFP_ADD": C$ = "Adds 3 byte Float @ ,S with 3 byte Float @ 3,S does S=S+3 with result @ ,S": GoSub AO
Return

' Both are FP 8 bytes
AddSameFP8:
A$ = "JSR": B$ = "DoFPDouble_Add_ForCompiler": C$ = "Do FP 8 byte (IEEE_754) Add on the stack and adjust the stack": GoSub AO
Return

' Enter with LeftType set, RightType set & LargestType set
NumFunctionSubtract:
Z$ = "; Doing Subtraction": GoSub AO
If Largesttype < 5 Then GoTo SubSameType1 ' Both are a byte size of 1
If (LeftType = 5 Or LeftType = 6) And (RightType = 5 Or RightType = 6) Then GoTo SubSameType2 ' Both are a byte size of 2
If LeftType < 7 And RightType < 7 Then GoTo SubMaxType2 ' One is 1 byte the other is 2 byte
If (LeftType = 7 Or LeftType = 8) And (RightType = 7 Or RightType = 8) Then GoTo SubSameType4 ' Both are a byte size of 4
If (LeftType = 9 Or LeftType = 10) And (RightType = 9 Or RightType = 10) Then GoTo SubSameType8 ' Both are a byte size of 8
If LeftType = 11 And RightType = 11 Then GoTo SubSameFFP ' Both are FP 3 bytes
If LeftType = 12 And RightType = 12 Then GoTo SubSameFP8 ' Both are FP 8 bytes

' Otherwise Types are not the same
Z$ = "; Makeboth the same type": GoSub AO
GoSub ScaleSmallNumberOnStack ' Convert smaller of LeftType or RightType type to the largest type
Select Case Largesttype
    Case 7, 8 ' Same 4 byte values
        GoTo SubSameType4
    Case 9, 10 ' Same 8 byte values
        GoTo SubSameType8
    Case 11 ' Same FFP values
        GoTo SubSameFFP
    Case 12 'Same Double values
        GoTo SubSameFP8
End Select

' Both are 1 byte
SubSameType1:
' Both are 1 byte (8 bits)
' on the stack we have: Value2, Value1
A$ = "LDB": B$ = "1,S": C$ = "value1 is 8 bits": GoSub AO
A$ = "SUBB": B$ = ",S++": C$ = "Subtract value1 from Value2, Fix the stack": GoSub AO
A$ = "PSHS": B$ = "B": C$ = "Push the result on the stack": GoSub AO
Return

'       right        left
' ; A = B (Integer) - C (byte)
' Pushed on the stack    Left, Right
' On the stack we have Value2, Value1
'
' One is 1 byte, the other is 2 bytes
SubMaxType2:
If LeftType < 5 Then
    ' Left is 1 byte and right is 2 bytes
    If LeftType = 1 Or LeftType = 3 Then
        'Signed
        A$ = "LDB": B$ = ",S": C$ = "Get the left 8 bit value": GoSub AO
        A$ = "SEX": C$ = "Sign Extend B into D": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Save the MSB on the stack": GoSub AO
    Else
    ' Unsigned
        A$ = "CLR": B$ = ",-S": C$ = "MSB = 0": GoSub AO
    End If
    A$ = "LDD": B$ = "2,S": C$ = "Get the right 16 bit value": GoSub AO
    A$ = "SUBD": B$ = ",S++": C$ = "Subtract left 16 bit value, move the stack": GoSub AO
Else
    ' Left is 2 bytes and right is 1 byte
    If RightType = 1 Or RightType = 3 Then
    'Signed
        A$ = "LDB": B$ = "2,S": C$ = "Get the right 8 bit value": GoSub AO
        A$ = "SEX": C$ = "Sign Extend B into D": GoSub AO
        A$ = "SUBD": B$ = ",S+": C$ = "Subtract left 16 bit value, move the stack": GoSub AO
    Else
    ' Unsigned
        A$ = "LDB": B$ = "2,S": C$ = "Get the right 8 bit value": GoSub AO
        A$ = "CLRA": C$ = "Clear MSB": GoSub AO
        A$ = "SUBD": B$ = ",S+": C$ = "Subtract left 16 bit value, move the stack": GoSub AO
    End if
End If
A$ = "STD": B$ = ",S": C$ = "Save the new 16 bit value": GoSub AO
Return

' Both are 2 bytes
SubSameType2:
A$ = "LDD": B$ = "2,S": C$ = "value1 is 16 bits": GoSub AO
A$ = "SUBD": B$ = ",S++": C$ = "D = D - 16 bit value2, move the stack": GoSub AO
A$ = "STD": B$ = ",S": C$ = "Save the new 16 bit value": GoSub AO
Return

' Both are 4 bytes
SubSameType4: '
A$ = "JSR": B$ = "Subtract_4ByteFrom4Byte": C$ = "Do 4 byte Subtract on the stack and adjust the stack": GoSub AO
Return

' Both are 8 bytes
SubSameType8:
A$ = "JSR": B$ = "Subtract_8ByteFrom8Byte": C$ = "Do 8 byte Subtract on the stack and adjust the stack": GoSub AO
Return

' Both are FP 3 bytes in FFP format
SubSameFFP:
A$ = "JSR": B$ = "FFP_SUB": C$ = "Subtract 3 byte float @ 3,S from ,S does S=S+3 with result @ ,S": GoSub AO
Return

' Both are FP 8 bytes
SubSameFP8:
A$ = "JSR": B$ = "DoFPDouble_Subtract_ForCompiler": C$ = "Do FP 10 byte (IEEE_754) Subtract on the stack and adjust the stack": GoSub AO
Return

' Enter with LeftType set, RightType set & LargestType set
NumFunctionMultiply:
Z$ = "; Doing Multiply, Largest is:" + Str$(Largesttype): GoSub AO
Z$ = "; LeftType" + Str$(LeftType): GoSub AO
Z$ = "; RightType=" + Str$(RightType): GoSub AO
If Largesttype < 5 Then GoTo Mul1ByteInt ' Both are a byte size of 1
If (LeftType = 5 Or LeftType = 6) And (RightType = 5 Or RightType = 6) Then GoTo Mul2ByteInt ' Both are a byte size of 2
If (LeftType = 7 Or LeftType = 8) And (RightType = 7 Or RightType = 8) Then GoTo Mul4ByteInt ' Both are a byte size of 4
If (LeftType = 9 Or LeftType = 10) And (RightType = 9 Or RightType = 10) Then GoTo Mul8ByteInt ' Both are a byte size of 8
If LeftType = 11 And RightType = 11 Then GoTo MulFFP ' Both are FP 3 bytes
If LeftType = 12 And RightType = 12 Then GoTo Mul10ByteFloat ' Both are FP 8 bytes

' Otherwise Types are not the same
Z$ = "; Makeboth the same type": GoSub AO
GoSub ScaleSmallNumberOnStack ' Convert smaller of LeftType or RightType type to the largest type

Select Case Largesttype
    Case 5, 6 ' Same 2 byte value
        GoTo Mul2ByteInt
    Case 7, 8 ' Same 4 byte values
        GoTo Mul4ByteInt
    Case 9, 10 ' Same 8 byte values
        GoTo Mul8ByteInt
    Case 11 ' Same FFP values
        GoTo MulFFP
    Case 12 'Same Double values
        GoTo Mul10ByteFloat
End Select

' Both are 1 byte (8 bits)
Mul1ByteInt:
A$ = "LDD": B$ = ",S++": C$ = "A = value1 an 8 bit unsigned, B = value2 an 8 bit unsigned, fix the stack": GoSub AO
A$ = "MUL": C$ = "D = A * B": GoSub AO
A$ = "PSHS": B$ = "D": C$ = "Save the new 8 bit value": GoSub AO
Largesttype=Largesttype+2
Return
' Both are 2 bytes (16 bits)
Mul2ByteInt:
A$ = "JSR": B$ = "MUL16": C$ = "Unsigned 16 bit multiply, ,S * 2,S then S=S+2, Low 16 bits are on the stack, D = high 16 bits": GoSub AO
' A$ = "PSHS": B$ = "D": C$ = "Save the high 16 bits on the stack, this is now a 32 bit number on the stack": GoSub AO
' Largesttype=Largesttype+2
Return
' Both are 4 bytes (32 bits)
Mul4ByteInt:
If (LeftType And 1) = 1 Then
    ' Value2 is signed
    If (RightType And 1) = 1 Then
        ' Both are signed
        A$ = "JSR": B$ = "Mul_Signed_Both_32": C$ = "Do FP 4 byte (IEEE_754) Multiply (both signed) on the stack and adjust the stack": GoSub AO
    Else
        'Value2 is signed, Value1 is unsigned
        A$ = "JSR": B$ = "Mul_MultiplierSigned_32": C$ = "Do FP 4 byte (IEEE_754) Multiply (Value2 signed) on the stack and adjust the stack": GoSub AO
    End If
Else
    ' Value 2 is unsigned
    If (RightType And 1) = 1 Then
        ' Value1 is signed
        A$ = "JSR": B$ = "Mul_MultiplicandSigned_32": C$ = "Do FP 4 byte (IEEE_754) Multiply (Value1 signed) on the stack and adjust the stack": GoSub AO
    Else
        ' Value 2 is unsigned, Value1 is unsigned
        A$ = "JSR": B$ = "Mul_UnSigned_Both_32": C$ = "Do FP 4 byte (IEEE_754) Multiply (both unsigned) on the stack and adjust the stack": GoSub AO
    End If
End If
Return
' Both are 8 bytes (64 bits)
Mul8ByteInt:
If (LeftType And 1) = 1 Then
    ' Value2 is signed
    If (RightType And 1) = 1 Then
        ' Both are signed
        A$ = "JSR": B$ = "Mul_Signed_Both_64": C$ = "Do FP 8 byte (IEEE_754) Multiply (both signed) on the stack and adjust the stack": GoSub AO
    Else
        'Value2 is signed, Value1 is unsigned
        A$ = "JSR": B$ = "Mul_MultiplierSigned_64": C$ = "Do FP 8 byte (IEEE_754) Multiply (Value2 signed) on the stack and adjust the stack": GoSub AO
    End If
Else
    ' Value 2 is unsigned
    If (RightType And 1) = 1 Then
        ' Value1 is signed
        A$ = "JSR": B$ = "Mul_MultiplicandSigned_64": C$ = "Do FP 8 byte (IEEE_754) Multiply (Value1 signed) on the stack and adjust the stack": GoSub AO
    Else
        ' Value 2 is unsigned, Value1 is unsigned
        A$ = "JSR": B$ = "Mul_UnSigned_Both_64": C$ = "Do FP 8 byte (IEEE_754) Multiply (both unsigned) on the stack and adjust the stack": GoSub AO
    End If
End If
Return
' Both are FP 3 bytes in FFP format
MulFFP:
A$ = "JSR": B$ = "FFP_MUL": C$ = "Multiply 3,S * ,S then S=S+3 result is @ ,S": GoSub AO
Return
' Both are FP 10 bytes
Mul10ByteFloat:
A$ = "JSR": B$ = "DB_MUL": C$ = "Do FP 8 byte (IEEE_754) Multiply on the stack and adjust the stack": GoSub AO
Return

' Enter with LeftType set, RightType set & LargestType set
NumFunctionDivide:
Z$ = "; Doing Divide, Largest is:" + Str$(Largesttype): GoSub AO
Z$ = "; LeftType" + Str$(LeftType): GoSub AO
Z$ = "; RightType=" + Str$(RightType): GoSub AO
Z$ = "; Makeboth the same": GoSub AO
' Make Types the same
Z$ = "; Makeboth the same type": GoSub AO
GoSub ScaleSmallNumberOnStack ' Convert smaller of LeftType or RightType type to the largest type
Z$ = "; Doing Division, Left & right are already the same size": GoSub AO

'       right        left
' ; A = B (Integer) - C (byte)
' Pushed on the stack    Left, Right
' On the stack we have Value2, Value1
'
Select Case Largesttype
    Case 1, 3 ' Both are 1 byte (8 bits)
        A$ = "PULS": B$ = "D": C$ = "Prep 8 bit division": GoSub AO
        A$ = "JSR": B$ = "S8_DIVMOD_ROUND": C$ = "Signed 8 bit division: B = B/A, A = remainder": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save result on the stack": GoSub AO
    Case 2, 4 ' Both are 1 byte (8 bits)
        A$ = "PULS": B$ = "D": C$ = "Prep 8 bit division": GoSub AO
        A$ = "JSR": B$ = "U8_DIVMOD_ROUND": C$ = "Unsigned 8 bit division: B = B/A, A = remainder": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save result on the stack": GoSub AO
    Case 5 ' Both are 2 bytes (16 bits)
        A$ = "JSR": B$ = "DIV_S16_Rounding": C$ = "Signed 16 bit division: ,S / 2,S ; Stack moved forward and ,S = result, remainder in D": GoSub AO
    Case 6 ' Both are 2 bytes (16 bits)
        A$ = "JSR": B$ = "DIV_U16_Rounding": C$ = "Unsigned 16 bit division: ,S / 2,S ; Stack moved forward and ,S = result, remainder in D": GoSub AO
    Case 7, 8 ' Both are 4 bytes (32 bits)
        If (LeftType And 1) = 1 Then
            ' Value2 is signed
            If (RightType And 1) = 1 Then
                ' Both are signed
                A$ = "JSR": B$ = "Div_Signed_Both_Rounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            Else
                'Value2 is signed, Value1 is unsigned
                A$ = "JSR": B$ = "Div_DivisorSigned_Rounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            End If
        Else
            ' Value 2 is unsigned
            If (RightType And 1) = 1 Then
                ' Value1 is signed
                A$ = "JSR": B$ = "Div_DividendSigned_Rounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            Else
                ' Value 2 is unsigned, Value1 is unsigned
                A$ = "JSR": B$ = "Div_UnSigned_Rounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            End If
        End If
    Case 9, 10 ' Both are 8 bytes (64 bits)
        If (LeftType And 1) = 1 Then
            ' Value2 is signed
            If (RightType And 1) = 1 Then
                ' Both are signed
                A$ = "JSR": B$ = "Div_Signed_Both_Rounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            Else
                'Value2 is signed, Value1 is unsigned
                A$ = "JSR": B$ = "Div_DivisorSigned_Rounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            End If
        Else
            ' Value 2 is unsigned
            If (RightType And 1) = 1 Then
                ' Value1 is signed
                A$ = "JSR": B$ = "Div_DividendSigned_Rounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            Else
                ' Value 2 is unsigned, Value1 is unsigned
                A$ = "JSR": B$ = "Div_UnSigned_Rounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            End If
        End If
    Case 11 ' Both are FP 3 bytes in FFP format
        A$ = "JSR": B$ = "FFP_DIV": C$ = "Do FFP division, Divide 3,S / ,S then S=S+3 result is @ ,S": GoSub AO
    Case 12 ' Both are FP 10 bytes
        A$ = "JSR": B$ = "DB_DIV": C$ = "Do FP 8 byte (IEEE_754) Division on the stack and adjust the stack": GoSub AO
End Select
Return



' Enter with LeftType set, RightType set & LargestType set
' Value1 & Value2 are on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
NumFunctionExponent:
Z$ = "; Doing Exponents, Left & right are already the same size": GoSub AO
' Make Types the same
Z$ = "; Makeboth the same type": GoSub AO
Value1Type = LeftType
Value2Type = RightType
GoSub ScaleSmallNumberOnStack ' Convert smaller of Value1Type(Leftside) or Value2Type(Rightside) type to the largest type
' LargestType = Both LeftType & RightType have been scaled to match this Largest Numeric Size
NVTExponent = Largesttype
Select Case Largesttype
    Case 1, 3
        GoTo Exp1ByteSignInt
    Case 2, 4
        GoTo Exp1ByteUInt
    Case 5
        GoTo Exp2ByteSignInt
    Case 6
        GoTo Exp2ByteUInt
    Case 7
        GoTo Exp4ByteInt
    Case 8
        GoTo Exp4ByteUInt
    Case 9
        GoTo Exp8ByteInt
    Case 10
        GoTo Exp8ByteUInt
    Case 11
        GoTo Exp3ByteFloat
    Case 12
        GoTo Exp10ByteFloat
End Select
Exp1ByteSignInt:
' Both are signed 1 byte (8 bits) each
A$ = "PULS": B$ = "A": C$ = "Get the left number (value 1) off the stack": GoSub AO
A$ = "STA": B$ = "SwapTypes": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Single ' Convert number to FFP
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
A$ = "LDA": B$ = "SwapTypes": GoSub AO
A$ = "PSHS": B$ = "A": C$ = "Put the left number on the stack": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Single ' Convert number to FFP
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Z$ = "; Doing Exponents, Left & Right are FFP": GoSub AO
A$ = "JSR": B$ = "FFP_POW": C$ = "Compute Power 3,S ^ ,S Then S=S+3 result @ ,S": GoSub AO
LastType = NT_Single ' FFP number on the stack
NVT = NT_Byte ' Convert number to Signed 8 bit number
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Return
Exp1ByteUInt:
' Both are unsigned 1 byte (8 bits) each
A$ = "PULS": B$ = "A": C$ = "Get the left number (value 1) off the stack": GoSub AO
A$ = "STA": B$ = "SwapTypes": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Single ' Convert number to FFP
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
A$ = "LDA": B$ = "SwapTypes": GoSub AO
A$ = "PSHS": B$ = "A": C$ = "Put the left number on the stack": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Single ' Convert number to FFP
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Z$ = "; Doing Exponents, Left & Right are FFP": GoSub AO
A$ = "JSR": B$ = "FFP_POW": C$ = "Compute Power 3,S ^ ,S Then S=S+3 result @ ,S": GoSub AO
LastType = NT_Single ' FFP number on the stack
NVT = NT_UByte ' Convert number to Unsigned 8 bit number
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Return
Exp2ByteSignInt:
A$ = "PULS": B$ = "D": C$ = "Get the left number (value 1) off the stack": GoSub AO
A$ = "STD": B$ = "SwapTypes": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
A$ = "LDD": B$ = "SwapTypes": GoSub AO
A$ = "PSHS": B$ = "D": C$ = "Put the left number on the stack": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Z$ = "; Doing Exponents, Left & right are Double": GoSub AO
A$ = "JSR": B$ = "DB_POW": C$ = "Compute Power 10,S ^ ,S Then S=S+10 result @ ,S": GoSub AO
LastType = NT_Double ' Double number on the stack
NVT = NT_Int16 ' Convert number to signed 16 bit number
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Return
Exp2ByteUInt:
A$ = "PULS": B$ = "D": C$ = "Get the left number (value 1) off the stack": GoSub AO
A$ = "STD": B$ = "SwapTypes": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
A$ = "LDD": B$ = "SwapTypes": GoSub AO
A$ = "PSHS": B$ = "D": C$ = "Put the left number on the stack": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Z$ = "; Doing Exponents, Left & right are Double": GoSub AO
A$ = "JSR": B$ = "DB_POW": C$ = "Compute Power 10,S ^ ,S Then S=S+10 result @ ,S": GoSub AO
LastType = NT_Double ' Double number on the stack
NVT = NT_UInt16 ' Convert number to Unsigned 16 bit number
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Return
Exp4ByteInt:
' Both are signed 4 byte (32 bits) each
A$ = "PULS": B$ = "D,X": C$ = "Get the left number (value 1) off the stack": GoSub AO
A$ = "STD": B$ = "SwapTypes": GoSub AO
A$ = "STX": B$ = "SwapTypes+2": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
A$ = "LDD": B$ = "SwapTypes": GoSub AO
A$ = "LDX": B$ = "SwapTypes+2": GoSub AO
A$ = "PSHS": B$ = "D,X": C$ = "Put the left number on the stack": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Z$ = "; Doing Exponents, Left & right are Double": GoSub AO
A$ = "JSR": B$ = "DB_POW": C$ = "Compute Power 10,S ^ ,S Then S=S+10 result @ ,S": GoSub AO
LastType = NT_Double ' Double number on the stack
NVT = NT_Int32 ' Convert number to signed 32 bit number
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Return
Exp4ByteUInt:
' Both are signed 4 byte (32 bits) each
A$ = "PULS": B$ = "D,X": C$ = "Get the left number (value 1) off the stack": GoSub AO
A$ = "STD": B$ = "SwapTypes": GoSub AO
A$ = "STX": B$ = "SwapTypes+2": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
A$ = "LDD": B$ = "SwapTypes": GoSub AO
A$ = "LDX": B$ = "SwapTypes+2": GoSub AO
A$ = "PSHS": B$ = "D,X": C$ = "Put the left number on the stack": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Z$ = "; Doing Exponents, Left & right are Double": GoSub AO
A$ = "JSR": B$ = "DB_POW": C$ = "Compute Power 10,S ^ ,S Then S=S+10 result @ ,S": GoSub AO
LastType = NT_Double ' Double number on the stack
NVT = NT_UInt32 ' Convert number to signed 32 bit number
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Return
Exp8ByteInt:
' Both are signed 8 byte (64 bits) each
A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the left number (value 1) off the stack": GoSub AO
A$ = "STU": B$ = "SwapTypes+6": GoSub AO
A$ = "LDU": B$ = "#SwapTypes+6": GoSub AO
A$ = "PSHU": B$ = "D,X,Y": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
A$ = "LDU": B$ = "#SwapTypes": GoSub AO
A$ = "PULU": B$ = "D,X,Y": GoSub AO
A$ = "LDU": B$ = ",U": GoSub AO
A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put the left number on the stack": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Z$ = "; Doing Exponents, Left & right are Double": GoSub AO
A$ = "JSR": B$ = "DB_POW": C$ = "Compute Power 10,S ^ ,S Then S=S+10 result @ ,S": GoSub AO
LastType = NT_Double ' Double number on the stack
NVT = NT_Int64 ' Convert number to signed 32 bit number
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Return
Exp8ByteUInt:
' Both are signed 8 byte (64 bits) each
A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the left number (value 1) off the stack": GoSub AO
A$ = "STU": B$ = "SwapTypes+6": GoSub AO
A$ = "LDU": B$ = "#SwapTypes+6": GoSub AO
A$ = "PSHU": B$ = "D,X,Y": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
A$ = "LDU": B$ = "#SwapTypes": GoSub AO
A$ = "PULU": B$ = "D,X,Y": GoSub AO
A$ = "LDU": B$ = ",U": GoSub AO
A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Put the left number on the stack": GoSub AO
LastType = NVTExponent ' Type that is on the stack
NVT = NT_Double ' Convert number to Double
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Z$ = "; Doing Exponents, Left & right are Double": GoSub AO
A$ = "JSR": B$ = "DB_POW": C$ = "Compute Power 10,S ^ ,S Then S=S+10 result @ ,S": GoSub AO
LastType = NT_Double ' Double number on the stack
NVT = NT_UInt64 ' Convert number to signed 32 bit number
' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
GoSub ConvertLastType2NVT
Return
Exp3ByteFloat:
Z$ = "; Doing Exponents, Left & right are FFP": GoSub AO
A$ = "JSR": B$ = "FFP_POW": C$ = "Compute Power 3,S ^ ,S Then S=S+3 result @ ,S": GoSub AO
Return
Exp10ByteFloat:
' In order to use the routines below we have to swap the Value2 & Value1 locations on the stack
Z$ = "; Doing Exponents, Left & right are Double": GoSub AO
A$ = "JSR": B$ = "DB_POW": C$ = "Compute Power 10,S ^ ,S Then S=S+10 result @ ,S": GoSub AO
Return

' Enter with LeftType set, RightType set & LargestType set
NumFunctionAnd:
' Make Types the same
Z$ = "; Makeboth the same type": GoSub AO
GoSub ScaleSmallNumberOnStack ' Convert smaller of LeftType or RightType type to the largest type
Z$ = "; Doing AND": GoSub AO
Select Case Largesttype
    Case 1, 2, 3, 4
        ' Both are 1 byte (8 bits)
        A$ = "PULS": B$ = "B": C$ = "value1 is 8 bits, move the stack": GoSub AO
        ' Right is an 8 bit value
        A$ = "ANDB": B$ = ",S": C$ = "ANDB with value2": GoSub AO
        A$ = "STB": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
    Case 5, 6
        ' Both are 2 bytes
        A$ = "PULS": B$ = "D": C$ = "D = 16 bit value1, move the stack": GoSub AO
        A$ = "ANDA": B$ = ",S": C$ = "ANDA with value2": GoSub AO
        A$ = "ANDB": B$ = "1,S": C$ = "ANDB with value2": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
    Case 7, 8
        A$ = "LEAX": B$ = "4,S": C$ = "X=Stack + 4 bytes so it points at value2": GoSub AO
        A$ = "LDB": B$ = "#4": C$ = "4 bytes to AND (32 bits)": GoSub AO
        Z$ = "!": A$ = "LDA": B$ = ",S+": C$ = "A = Value1 bytes, move the stack": GoSub AO
        A$ = "ANDA": B$ = ",X": C$ = "AND with Value2 bytes": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Save new value, move to the next byte": GoSub AO
        A$ = "DECB": C$ = "Decrement counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until we reach 0": GoSub AO
    Case 9, 10 ' 8 byte variable
        A$ = "LEAX": B$ = "8,S": C$ = "X=Stack + 8 bytes so it points at value2": GoSub AO
        A$ = "LDB": B$ = "#8": C$ = "8 bytes to AND (64 bits)": GoSub AO
        Z$ = "!": A$ = "LDA": B$ = ",S+": C$ = "A = Value1 bytes, move the stack": GoSub AO
        A$ = "ANDA": B$ = ",X": C$ = "AND with Value2 bytes": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Save new value, move to the next byte": GoSub AO
        A$ = "DECB": C$ = "Decrement counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until we reach 0": GoSub AO
    Case 11
        ' Both are FP 3 bytes in FFP format
        Z$ = "; Write code to handle AND with FFP values on the stack": GoSub AO
        A$ = "LEAS": B$ = "3,S": C$ = "For now just keeping value 2 as the result": GoSub AO
    Case 12
        ' Both are FP 10 bytes
        Z$ = "; Write code to handle AND with Double values on the stack": GoSub AO
        A$ = "LEAS": B$ = "10,S": C$ = "For now just keeping value 2 as the result": GoSub AO
End Select
Return

' Enter with LeftType set, RightType set & LargestType set
NumFunctionOr:
' Make Types the same
Z$ = "; Makeboth the same type": GoSub AO
GoSub ScaleSmallNumberOnStack ' Convert smaller of LeftType or RightType type to the largest type
Z$ = "; Doing OR": GoSub AO
Select Case Largesttype
    Case 1, 2, 3, 4
        ' Both are 1 byte (8 bits)
        A$ = "PULS": B$ = "B": C$ = "value1 is 8 bits, move the stack": GoSub AO
        ' Right is an 8 bit value
        A$ = "ORB": B$ = ",S": C$ = "ORB with value2": GoSub AO
        A$ = "STB": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
    Case 5, 6
        ' Both are 2 bytes
        A$ = "PULS": B$ = "D": C$ = "D = 16 bit value1, move the stack": GoSub AO
        A$ = "ORA": B$ = ",S": C$ = "ORA with value2": GoSub AO
        A$ = "ORB": B$ = "1,S": C$ = "ORB with value2": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
    Case 7, 8 ' 4 byte variable
        A$ = "LEAX": B$ = "4,S": C$ = "X=Stack + 4 bytes so it points at value2": GoSub AO
        A$ = "LDB": B$ = "#4": C$ = "4 bytes to OR (32 bits)": GoSub AO
        Z$ = "!": A$ = "LDA": B$ = ",S+": C$ = "A = Value1 bytes, move the stack": GoSub AO
        A$ = "ORA": B$ = ",X": C$ = "OR with Value2 bytes": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Save new value, move to the next byte": GoSub AO
        A$ = "DECB": C$ = "Decrement counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until we reach 0": GoSub AO
    Case 9, 10 ' 8 byte variable
        A$ = "LEAX": B$ = "8,S": C$ = "X=Stack + 8 bytes so it points at value2": GoSub AO
        A$ = "LDB": B$ = "#8": C$ = "8 bytes to OR (64 bits)": GoSub AO
        Z$ = "!": A$ = "LDA": B$ = ",S+": C$ = "A = Value1 bytes, move the stack": GoSub AO
        A$ = "ORA": B$ = ",X": C$ = "OR with Value2 bytes": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Save new value, move to the next byte": GoSub AO
        A$ = "DECB": C$ = "Decrement counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until we reach 0": GoSub AO
    Case 11
        ' Both are FP 3 bytes in FFP format
        Z$ = "; Write code to handle OR with FFP values on the stack": GoSub AO
        A$ = "LEAS": B$ = "3,S": C$ = "For now just keeping value 2 as the result": GoSub AO
    Case 12
        ' Both are FP 10 bytes
        Z$ = "; Write code to handle OR with Double values on the stack": GoSub AO
        A$ = "LEAS": B$ = "10,S": C$ = "For now just keeping value 2 as the result": GoSub AO
End Select
Return

' Enter with LeftType = type on the stack
NumFunctionNEG:
Z$ = "; Doing Function Neg": GoSub AO
Z$ = "; LeftType=" + Str$(LeftType): GoSub AO
Select Case LeftType
    Case Is < 5 ' One byte variable
        A$ = "NEG": B$ = ",S": C$ = "Negate value on the stack": GoSub AO
    Case 5, 6 ' Two byte variable
        A$ = "LDD": B$ = ",S": GoSub AO: C$ = "Get the value off the stack": GoSub AO
        A$ = "NEGA": C$ = "Negate A": GoSub AO
        A$ = "NEGB": C$ = "Negate B": GoSub AO
        A$ = "SBCA": B$ = "#0": C$ = "Add carry to A": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Store negative value back on the stack": GoSub AO
    Case 7, 8 ' 4 byte variable
        A$ = "LDB": B$ = "#3": C$ = "3 bytes + 1 byte to negate (32 bits)": GoSub AO
        A$ = "CLRA": C$ = "Clear the initial carry": GoSub AO
        Z$ = "!": A$ = "LDA": B$ = "#0": C$ = "A = 0 (Doesn't modify the carry bit)": GoSub AO
        A$ = "SBCA": B$ = "B,S": C$ = "A = 0 - byte - Carry": GoSub AO
        A$ = "STA": B$ = "B,S": C$ = "Save new value": GoSub AO
        A$ = "DECB": C$ = "Decrement counter": GoSub AO
        A$ = "BPL": B$ = "<": C$ = "Loop until we reach -1": GoSub AO
    Case 9, 10 ' 8 byte variable
        A$ = "LDB": B$ = "#7": C$ = "7 bytes + 1 byte to negate (64 bits)": GoSub AO
        A$ = "CLRA": C$ = "Clear the initial carry": GoSub AO
        Z$ = "!": A$ = "LDA": B$ = "#0": C$ = "A = 0 (Doesn't modify the carry bit)": GoSub AO
        A$ = "SBCA": B$ = "B,S": C$ = "A = 0 - byte - Carry": GoSub AO
        A$ = "STA": B$ = "B,S": C$ = "Save new value": GoSub AO
        A$ = "DECB": C$ = "Decrement counter": GoSub AO
        A$ = "BPL": B$ = "<": C$ = "Loop until we reach -1": GoSub AO
    Case 11 ' 3 byte variable
        A$ = "LDB": B$ = ",S": GoSub AO: C$ = "Get the Sign & Exponent byte off the stack": GoSub AO
        A$ = "EORB": B$ = "#%10000000": C$ = "Flip bit 7 (Negate)": GoSub AO
        A$ = "STB": B$ = ",S": GoSub AO: C$ = "Save the Sign & Exponent byte off the stack": GoSub AO
    Case 12 ' 10 byte variable
        A$ = "LDB": B$ = ",S": GoSub AO: C$ = "Get the Sign byte off the stack": GoSub AO
        A$ = "EORB": B$ = "#%10000000": C$ = "Flip bit 7 (Negate)": GoSub AO
        A$ = "STB": B$ = ",S": GoSub AO: C$ = "Save the Sign byte off the stack": GoSub AO
End Select
Return

' Enter with LeftType set, RightType set & LargestType set
NumFunctionXor:
' Make Types the same
Z$ = "; Makeboth the same type": GoSub AO
GoSub ScaleSmallNumberOnStack ' Convert smaller of LeftType or RightType type to the largest type
Z$ = "; Doing XOR": GoSub AO
Z$ = "; Largesttype = "+hex$(Largesttype): GoSub AO
Select Case Largesttype
    Case 1, 2, 3, 4
        ' Both are 1 byte (8 bits)
        A$ = "PULS": B$ = "B": C$ = "value1 is 8 bits, move the stack": GoSub AO
        ' Right is an 8 bit value
        A$ = "EORB": B$ = ",S": C$ = "EORB with value2": GoSub AO
        A$ = "STB": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
    Case 5, 6
        ' Both are 2 bytes
        A$ = "PULS": B$ = "D": C$ = "D = 16 bit value1, move the stack": GoSub AO
        A$ = "EORA": B$ = ",S": C$ = "EORA with value2": GoSub AO
        A$ = "EORB": B$ = "1,S": C$ = "EORB with value2": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
    Case 7, 8 ' 4 byte variable
        A$ = "LEAX": B$ = "4,S": C$ = "X=Stack + 4 bytes so it points at value2": GoSub AO
        A$ = "LDB": B$ = "#4": C$ = "4 bytes to OR (32 bits)": GoSub AO
        Z$ = "!": A$ = "LDA": B$ = ",S+": C$ = "A = Value1 bytes, move the stack": GoSub AO
        A$ = "EORA": B$ = ",X": C$ = "EOR with Value2 bytes": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Save new value, move to the next byte": GoSub AO
        A$ = "DECB": C$ = "Decrement counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until we reach 0": GoSub AO
    Case 9, 10 ' 8 byte variable
        A$ = "LEAX": B$ = "8,S": C$ = "X=Stack + 8 bytes so it points at value2": GoSub AO
        A$ = "LDB": B$ = "#8": C$ = "8 bytes to OR (64 bits)": GoSub AO
        Z$ = "!": A$ = "LDA": B$ = ",S+": C$ = "A = Value1 bytes, move the stack": GoSub AO
        A$ = "EORA": B$ = ",X": C$ = "EOR with Value2 bytes": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Save new value, move to the next byte": GoSub AO
        A$ = "DECB": C$ = "Decrement counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until we reach 0": GoSub AO
    Case 11
        ' Both are FP 3 bytes in FFP format
        Z$ = "; Write code to handle EOR with FFP values on the stack": GoSub AO
        A$ = "LEAS": B$ = "3,S": C$ = "For now just keeping value 2 as the result": GoSub AO
    Case 12
        ' Both are FP 10 bytes
        Z$ = "; Write code to handle EOR with Double values on the stack": GoSub AO
        A$ = "LEAS": B$ = "10,S": C$ = "For now just keeping value 2 as the result": GoSub AO
End Select
Return

' Enter with LeftType = type on the stack
NumFunctionNot:
Z$ = "; Doing Function Not": GoSub AO
Z$ = "; LeftType=" + Str$(LeftType): GoSub AO
Select Case LeftType
    Case 1 ' _Bit (boolean-style)
        A$ = "LDA": B$ = "#$FF": C$ = "Default to TRUE (-1)": GoSub AO
        A$ = "LDB": B$ = ",S": C$ = "Test value": GoSub AO
        A$ = "BEQ": B$ = ">": C$ = "If 0 keep -1": GoSub AO
        A$ = "CLRA": C$ = "Else 0": GoSub AO
        Z$ = "!": GoSub AO
        A$ = "STA": B$ = ",S": C$ = "Store": GoSub AO
    Case 2 ' _Unsigned _Bit (0/1)
        A$ = "LDA": B$ = "#$01": C$ = "Default to 1": GoSub AO
        A$ = "LDB": B$ = ",S": C$ = "Test value": GoSub AO
        A$ = "BEQ": B$ = ">": C$ = "If 0 keep 1": GoSub AO
        A$ = "CLRA": C$ = "Else 0": GoSub AO
        Z$ = "!": GoSub AO
        A$ = "STA": B$ = ",S": C$ = "Store": GoSub AO
    Case 3, 4 ' 1 byte
        A$ = "COM": B$ = ",S": C$ = "Bitwise NOT 8-bit": GoSub AO
    Case 5, 6 ' 2 bytes
        A$ = "COM": B$ = ",S": C$ = "NOT high byte": GoSub AO
        A$ = "COM": B$ = "1,S": C$ = "NOT low byte": GoSub AO
    Case 7, 8 ' 4 byte variable
        A$ = "COM": B$ = ",S": C$ = "Compliment value on the stack": GoSub AO
        A$ = "COM": B$ = "1,S": C$ = "Compliment value on the stack": GoSub AO
        A$ = "COM": B$ = "2,S": C$ = "Compliment value on the stack": GoSub AO
        A$ = "COM": B$ = "3,S": C$ = "Compliment value on the stack": GoSub AO
    Case 9, 10 ' 8 bytes
        A$ = "LDB": B$ = "#7": C$ = "8 bytes (0..7)": GoSub AO
        Z$ = "!": A$ = "COM": B$ = "B,S": C$ = "NOT byte": GoSub AO
        A$ = "DECB": C$ = "Decrement the counter": GoSub AO
        A$ = "BPL": B$ = "<": C$ = "loop": GoSub AO
    Case Else
        Print "Error: NOT unsupported type "; LeftType; " on";: GoTo FoundError
End Select
Return




' Enter with LeftType set, RightType set & LargestType set
NumFunctionMod:
Z$ = "; Doing Divide, Largest is:" + Str$(Largesttype): GoSub AO
Z$ = "; LeftType" + Str$(LeftType): GoSub AO
Z$ = "; RightType=" + Str$(RightType): GoSub AO
Z$ = "; Makeboth the same": GoSub AO
' Make Types the same
Z$ = "; Makeboth the same type": GoSub AO
GoSub ScaleSmallNumberOnStack ' Convert smaller of LeftType or RightType type to the largest type
Z$ = "; Doing Mod, Left & right are already the same size": GoSub AO

'       right        left
' ; A = B (Integer) - C (byte)
' Pushed on the stack    Left, Right
' On the stack we have Value2, Value1
'
Select Case Largesttype
    Case 1, 3 ' Both are 1 byte (8 bits)
        A$ = "PULS": B$ = "D": C$ = "Prep 8 bit division": GoSub AO
        A$ = "JSR": B$ = "S8_DIVMOD_ROUND": C$ = "Signed 8 bit division: B = B/A, A = remainder": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Save remainder on the stack": GoSub AO
    Case 2, 4 ' Both are 1 byte (8 bits)
        A$ = "PULS": B$ = "D": C$ = "Prep 8 bit division": GoSub AO
        A$ = "JSR": B$ = "U8_DIVMOD_ROUND": C$ = "Unsigned 8 bit division: B = B/A, A = remainder": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Save remainder on the stack": GoSub AO
    Case 5 ' Both are 2 bytes (16 bits)
        A$ = "JSR": B$ = "DIV_S16": C$ = "Signed 16 bit division: ,S / 2,S ; Stack moved forward and ,S = result, remainder in D": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Save the remiander on the stack": GoSub AO
    Case 6 ' Both are 2 bytes (16 bits)
        A$ = "JSR": B$ = "DIV_U16": C$ = "Unsigned 16 bit division: ,S / 2,S ; Stack moved forward and ,S = result, remainder in D": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Save the remiander on the stack": GoSub AO
    Case 7, 8 ' Both are 4 bytes (32 bits)
        If (LeftType And 1) = 1 Then
            ' Value2 is signed
            If (RightType And 1) = 1 Then
                ' Both are signed
                A$ = "JSR": B$ = "Div_Signed_Both_Rounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            Else
                'Value2 is signed, Value1 is unsigned
                A$ = "JSR": B$ = "Div_DivisorSigned_Rounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            End If
        Else
            ' Value 2 is unsigned
            If (RightType And 1) = 1 Then
                ' Value1 is signed
                A$ = "JSR": B$ = "Div_DividendSigned_Rounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            Else
                ' Value 2 is unsigned, Value1 is unsigned
                A$ = "JSR": B$ = "Div_UnSigned_Rounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            End If
        End If
        A$ = "LDD": B$ = "Remainder+2": C$ = "Get the Remiander LS Word": GoSub AO
        A$ = "STD": B$ = "2,S": C$ = "Save it on the stack": GoSub AO
        A$ = "LDD": B$ = "Remainder": C$ = "Get the Remiander MS Word": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Save it on the stack": GoSub AO
    Case 9, 10 ' Both are 8 bytes (64 bits)
        If (LeftType And 1) = 1 Then
            ' Value2 is signed
            If (RightType And 1) = 1 Then
                ' Both are signed
                A$ = "JSR": B$ = "Div_Signed_Both_Rounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            Else
                'Value2 is signed, Value1 is unsigned
                A$ = "JSR": B$ = "Div_DivisorSigned_Rounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            End If
        Else
            ' Value 2 is unsigned
            If (RightType And 1) = 1 Then
                ' Value1 is signed
                A$ = "JSR": B$ = "Div_DividendSigned_Rounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            Else
                ' Value 2 is unsigned, Value1 is unsigned
                A$ = "JSR": B$ = "Div_UnSigned_Rounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            End If
        End If
        A$ = "LDB": B$ = "#6": C$ = "8 bytes to copy": GoSub AO
        A$ = "LDX": B$ = "#Remainder": C$ = "Point at the Remiander": GoSub AO
        Z$ = "!": A$ = "LDU": B$ = "B,X": C$ = "Get bytes": GoSub AO
        A$ = "STU": B$ = "B,S": C$ = "Save bytes": GoSub AO
        A$ = "SUBB": B$ = "#2": C$ = "Decrement the pointer by two": GoSub AO
        A$ = "BPL": B$ = "<": C$ = "Loop": GoSub AO
    Case 11 ' Both are FP 3 bytes in FFP format
        A$ = "JSR": B$ = "FFP_MOD": C$ = "Compute the remainder of division using dividend is @ 3,S and the divisor is @ ,S then S=S+3 result is @ ,S": GoSub AO
    Case 12 ' Both are FP 10 bytes
        A$ = "JSR": B$ = "DB_MOD": C$ = "Compute the remainder of division using dividend is @ 10,S and the divisor is @ ,S then S=S+10 result is @ ,S": GoSub AO
End Select
Return

NumFunctionDivr:
Return

' Integer division (no remainder)
' Enter with LeftType set, RightType set & LargestType set
NumFunctionIntDiv:
Z$ = "; Doing Integer Division, Largest is:" + Str$(Largesttype): GoSub AO
Z$ = "; LeftType" + Str$(LeftType): GoSub AO
Z$ = "; RightType=" + Str$(RightType): GoSub AO
Z$ = "; Makeboth the same": GoSub AO
' Make Types the same
Z$ = "; Makeboth the same type": GoSub AO
GoSub ScaleSmallNumberOnStack ' Convert smaller of LeftType or RightType type to the largest type
Z$ = "; Doing Division, Left & right are already the same size": GoSub AO

'       right        left
' ; A = B (Integer) - C (byte)
' Pushed on the stack    Left, Right
' On the stack we have Value2, Value1
'
Select Case Largesttype
    Case 1, 3 ' Both are 1 byte (8 bits)
        A$ = "PULS": B$ = "D": C$ = "Prep 8 bit division": GoSub AO
        A$ = "JSR": B$ = "S8_DIVMOD_TRUNC": C$ = "Signed 8 bit division: B = B/A, A = remainder": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save result on the stack": GoSub AO
    Case 2, 4 ' Both are 1 byte (8 bits)
        A$ = "PULS": B$ = "D": C$ = "Prep 8 bit division": GoSub AO
        A$ = "JSR": B$ = "U8_DIVMOD_TRUNC": C$ = "Unsigned 8 bit division: B = B/A, A = remainder": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save result on the stack": GoSub AO
    Case 5 ' Both are 2 bytes (16 bits)
        A$ = "JSR": B$ = "DIV_S16": C$ = "Signed 16 bit division: ,S / 2,S ; Stack moved forward and ,S = result, remainder in D": GoSub AO
    Case 6 ' Both are 2 bytes (16 bits)
        A$ = "JSR": B$ = "DIV_U16": C$ = "Unsigned 16 bit division: ,S / 2,S ; Stack moved forward and ,S = result, remainder in D": GoSub AO
    Case 7, 8 ' Both are 4 bytes (32 bits)
        If (LeftType And 1) = 1 Then
            ' Value2 is signed
            If (RightType And 1) = 1 Then
                ' Both are signed
                A$ = "JSR": B$ = "Div_Signed_Both_NoRounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            Else
                'Value2 is signed, Value1 is unsigned
                A$ = "JSR": B$ = "Div_DivisorSigned_NoRounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            End If
        Else
            ' Value 2 is unsigned
            If (RightType And 1) = 1 Then
                ' Value1 is signed
                A$ = "JSR": B$ = "Div_DividendSigned_NoRounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            Else
                ' Value 2 is unsigned, Value1 is unsigned
                A$ = "JSR": B$ = "Div_UnSigned_NoRounding_32": C$ = "64 bit division: 4,S / ,S ; Stack moved forward and ,S = result, 32 bit remainder @ Remainder": GoSub AO
            End If
        End If
    Case 9, 10 ' Both are 8 bytes (64 bits)
        If (LeftType And 1) = 1 Then
            ' Value2 is signed
            If (RightType And 1) = 1 Then
                ' Both are signed
                A$ = "JSR": B$ = "Div_Signed_Both_NoRounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            Else
                'Value2 is signed, Value1 is unsigned
                A$ = "JSR": B$ = "Div_DivisorSigned_NoRounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            End If
        Else
            ' Value 2 is unsigned
            If (RightType And 1) = 1 Then
                ' Value1 is signed
                A$ = "JSR": B$ = "Div_DividendSigned_NoRounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            Else
                ' Value 2 is unsigned, Value1 is unsigned
                A$ = "JSR": B$ = "Div_UnSigned_NoRounding_64": C$ = "64 bit division: 8,S / ,S ; Stack moved forward and ,S = result, 64 bit remainder @ Remainder": GoSub AO
            End If
        End If
    Case 11 ' Both are FP 3 bytes in FFP format
        A$ = "JSR": B$ = "FFP_DIV": C$ = "Do FFP division, Divide 3,S / ,S then S=S+3 result is @ ,S": GoSub AO
        A$ = "JSR": B$ = "FFP_FLOOR": C$ = "Compute floor(x) x is @ ,S return with FFP value @,S which is the INTeger value of ,S": GoSub AO
    Case 12 ' Both are FP 10 bytes
        A$ = "JSR": B$ = "DB_DIV": C$ = "Do FP 8 byte (IEEE_754) Division on the stack and adjust the stack": GoSub AO
        A$ = "JSR": B$ = "DB_FLOOR": C$ = "Compute INT(x) x is @ ,S return with Double value @,S which is the INTeger vale of ,S": GoSub AO
End Select
Return

