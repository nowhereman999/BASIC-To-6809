
' 0 = False
' $FF & non zero = True
NumFunctionEqual:
Z$ = "; Doing Function Equal": GoSub AO
If Largesttype < 5 Then GoTo EqualSameType1 ' Both are a byte size of 1
If (LeftType = 5 Or LeftType = 6) And (RightType = 5 Or RightType = 6) Then GoTo EqualSameType2 ' Both are a byte size of 2
If LeftType < 7 And RightType < 7 Then GoTo EqualMaxType2 ' One is 1 byte the other is 2 byte
If (LeftType = 7 Or LeftType = 8) And (RightType = 7 Or RightType = 8) Then GoTo EqualSameType4 ' Both are a byte size of 4
If (LeftType = 9 Or LeftType = 10) And (RightType = 9 Or RightType = 10) Then GoTo EqualSameType8 ' Both are a byte size of 8
If LeftType = 11 And RightType = 11 Then GoTo EqualSameFFP ' Both are FP 3 bytes
If LeftType = 12 And RightType = 12 Then GoTo EqualSameFP8 ' Both are FP 8 bytes

' Otherwise Types are not the same
Value1Type = LeftType
Value2Type = RightType
GoSub ScaleSmallNumberOnStack ' Convert smaller of Value1Type(Leftside) or Value2Type(Rightside) type to the largest type

Select Case Largesttype
    Case 7, 8 ' Same 4 byte values
        GoTo EqualSameType4
    Case 9, 10 ' Same 8 byte values
        GoTo EqualSameType8
    Case 11 ' Same FFP values
        GoTo EqualSameFFP
    Case 12 'Same Double values
        GoTo EqualSameFP8
End Select

' Both are 1 byte
EqualSameType1:
' Both are 1 byte (8 bits)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "Right value2 is 8 bits": GoSub AO
' Right is an 8 bit value
A$ = "CMPB": B$ = ",S+": C$ = "Compare Left value1 is an 8 bit value, move stack": GoSub AO
A$ = "BEQ": B$ = ">": C$ = "Skip if Equal": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save result on the stack": GoSub AO
Return

' One is 1 byte, the other is 2 bytes
EqualMaxType2:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
If LeftType < 5 Then
    ' Left is 1 byte and right is 2 bytes                     v1=1,S & 2,S - v2=,S
    A$ = "LDB": B$ = ",S+": C$ = "Get V2 8 bit value, move the stack": GoSub AO
    A$ = "SEX": C$ = "D = B": GoSub AO
    A$ = "SUBD": B$ = ",S": C$ = "Subtract v1 16 bit value, move the stack": GoSub AO
    A$ = "CMPD": B$ = "#$0000": C$ = "TSTD": GoSub AO
Else
    ' Left is 2 bytes and right is 1 byte                      v1=2,S - v2 =,S & 1,S
    A$ = "LDB": B$ = "2,S": C$ = "Get V1 8 bit value": GoSub AO
    A$ = "SEX": C$ = "D = B": GoSub AO
    A$ = "SUBD": B$ = ",S+": C$ = "Subtract v2 16 bit value, move the stack": GoSub AO
    A$ = "CMPD": B$ = "#$0000": C$ = "TSTD": GoSub AO
End If
A$ = "BEQ": B$ = ">": C$ = "Skip if Equal": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return

' Both are 2 bytes
EqualSameType2:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S++": C$ = "D = LEFT 16 bit value1, move stack": GoSub AO
A$ = "CMPX": B$ = ",S+": C$ = "Compare with right 16 bit value2, move the stack": GoSub AO
A$ = "BEQ": B$ = ">": C$ = "Skip if Equal": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save result on the stack": GoSub AO
Return

' Both are 4 bytes
EqualSameType4: '
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left MSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "4,S": C$ = "Compare with right MSWord 32 bit value"
A$ = "BNE": B$ = "@False": C$ = "If Not Equal, Exit with zero": GoSub AO
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "6,S": C$ = "Compare with right MSWord 32 bit value": GoSub AO
A$ = "BEQ": B$ = ">": C$ = "Skip if Equal": GoSub AO
Z$ = "@False:": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "7,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are 8 bytes
EqualSameType8:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left MSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "8,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BNE": B$ = "@False": C$ = "If Not Equal, Exit with zero": GoSub AO
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "10,S": C$ = "Compare with right MSWord 32 bit value": GoSub AO
A$ = "BNE": B$ = "@False": C$ = "If Not Equal, Exit with zero": GoSub AO
A$ = "LDX": B$ = "4,S": C$ = "Get the left MSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "12,S": C$ = "Compare with right MSWord 32 bit value": GoSub AO
A$ = "BNE": B$ = "@False": C$ = "If Not Equal, Exit with zero": GoSub AO
A$ = "LDX": B$ = "6,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "14,S": C$ = "Compare with right MSWord 32 bit value": GoSub AO
A$ = "BEQ": B$ = ">": C$ = "Skip if Equal": GoSub AO
Z$ = "@False:": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "5,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are FP 3 bytes in FFP format
EqualSameFFP:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "FFP_CMP_Stack": C$ = "Compare FFP Value1 @ ,S with Value 2 @ 3,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BEQ": B$ = ">": C$ = "Skip if Equal": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "4,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are FP 10 bytes
EqualSameFP8:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "Double_CMP_Stack": C$ = "Compare Double Value1 @ ,S with Value 2 @ 10,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BEQ": B$ = ">": C$ = "Skip if Equal": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "18,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' 0 = False
' $FF & non zero = True
NumFunctionNotEqual:
Z$ = "; Doing Function NotEqual": GoSub AO
If Largesttype < 5 Then GoTo NotEqualSameType1 ' Both are a byte size of 1
If (LeftType = 5 Or LeftType = 6) And (RightType = 5 Or RightType = 6) Then GoTo NotEqualSameType2 ' Both are a byte size of 2
If LeftType < 7 And RightType < 7 Then GoTo NotEqualMaxType2 ' One is 1 byte the other is 2 byte
If (LeftType = 7 Or LeftType = 8) And (RightType = 7 Or RightType = 8) Then GoTo NotEqualSameType4 ' Both are a byte size of 4
If (LeftType = 9 Or LeftType = 10) And (RightType = 9 Or RightType = 10) Then GoTo NotEqualSameType8 ' Both are a byte size of 8
If LeftType = 11 And RightType = 11 Then GoTo NotEqualSameFFP ' Both are FP 3 bytes
If LeftType = 12 And RightType = 12 Then GoTo NotEqualSameFP8 ' Both are FP 8 bytes

' Otherwise Types are not the same
Value1Type = LeftType
Value2Type = RightType
GoSub ScaleSmallNumberOnStack ' Convert smaller of Value1Type(Rightside) or Value2Type(Leftside) type to the largest type

Select Case Largesttype
    Case 7, 8 ' Same 4 byte values
        GoTo NotEqualSameType4
    Case 9, 10 ' Same 8 byte values
        GoTo NotEqualSameType8
    Case 11 ' Same FFP values
        GoTo NotEqualSameFFP
    Case 12 'Same Double values
        GoTo NotEqualSameFP8
End Select

' Both are 1 byte
NotEqualSameType1:
' Both are 1 byte (8 bits)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "Right value2 is 8 bits": GoSub AO
' Right is an 8 bit value
A$ = "CMPB": B$ = ",S+": C$ = "Compare Left value1 is an 8 bit value, move stack": GoSub AO
A$ = "BNE": B$ = ">": C$ = "Skip if NotEqual": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": GoSub AO
Return

' One is 1 byte, the other is 2 bytes
NotEqualMaxType2:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
If LeftType < 5 Then
    ' Left is 1 byte and right is 2 bytes                     v1=1,S & 2,S - v2=,S
    A$ = "LDB": B$ = ",S+": C$ = "Get V2 8 bit value, move the stack": GoSub AO
    A$ = "SEX": C$ = "D = B": GoSub AO
    A$ = "SUBD": B$ = ",S": C$ = "Subtract v1 16 bit value, move the stack": GoSub AO
    A$ = "CMPD": B$ = "#$0000": C$ = "TSTD": GoSub AO
Else
    ' Left is 2 bytes and right is 1 byte                      v1=2,S - v2 =,S & 1,S
    A$ = "LDB": B$ = "2,S": C$ = "Get V1 8 bit value": GoSub AO
    A$ = "SEX": C$ = "D = B": GoSub AO
    A$ = "SUBD": B$ = ",S+": C$ = "Subtract v2 16 bit value, move the stack": GoSub AO
    A$ = "CMPD": B$ = "#$0000": C$ = "TSTD": GoSub AO
End If
A$ = "BNE": B$ = ">": C$ = "Skip if NotEqual": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return

' Both are 2 bytes
NotEqualSameType2:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S++": C$ = "D = left 16 bit value1": GoSub AO
A$ = "CMPX": B$ = ",S+": C$ = "Compare with right 16 bit value2, move the stack": GoSub AO
A$ = "BNE": B$ = ">": C$ = "Skip if NotEqual": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": GoSub AO
Return

' Both are 4 bytes
NotEqualSameType4: '
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left MSWord 32 bit value": GoSub AO
A$ = "CMPx": B$ = "4,S": C$ = "Compare with right MSWord 32 bit value": GoSub AO
A$ = "BNE": B$ = ">": C$ = "If Not Equal, Exit with True": GoSub AO
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "6,S": C$ = "Compare with right MSWord 32 bit value": GoSub AO
A$ = "BNE": B$ = ">": C$ = "Skip if NotEqual": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "7,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are 8 bytes
NotEqualSameType8:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left MSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "8,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BNE": B$ = ">": C$ = "If Not Equal, Exit with True": GoSub AO
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "10,S": C$ = "Compare with right MSWord 64 bit value": GoSub AO
A$ = "BNE": B$ = ">": C$ = "If Not Equal, Exit with True": GoSub AO
A$ = "LDX": B$ = "4,S": C$ = "Get the left MSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "12,S": C$ = "Compare with right MSWord 64 bit value": GoSub AO
A$ = "BNE": B$ = ">": C$ = "If Not Equal, Exit with True": GoSub AO
A$ = "LDX": B$ = "6,S": C$ = "Get the left LSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "14,S": C$ = "Compare with right MSWord 64 bit value": GoSub AO
A$ = "BNE": B$ = ">": C$ = "Skip if NotEqual": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "15,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are FP 3 bytes in FFP format
NotEqualSameFFP:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "FFP_CMP_Stack": C$ = "Compare FFP Value1 @ 3,S with Value 2 @ ,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BNE": B$ = ">": C$ = "Skip if NotEqual": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "4,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are FP 10 bytes
NotEqualSameFP8:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "Double_CMP_Stack": C$ = "Compare Double Value1 @ 10,S with Value 2 @ ,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BNE": B$ = ">": C$ = "Skip if NotEqual": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "18,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' 0 = False
' $FF & non zero = True
' NumFunctionLessThan:
'Z$ = "; Doing Function LessThan": GoSub AO
'Z$ = "; LeftType=" + Str$(LeftType): GoSub AO
'Z$ = "; RightType=" + Str$(RightType): GoSub AO
' Have to deal with signed and unsigned values when comparing
NumFunctionGreaterThan:
Z$ = "; Doing Function GreaterThan": GoSub AO
Z$ = "; LeftType=" + Str$(LeftType): GoSub AO
Z$ = "; RightType=" + Str$(RightType): GoSub AO
If (LeftType = 1 Or LeftType = 3) And (RightType = 1 Or RightType = 3) Then GoTo LessThanSigned1Byte
If (LeftType = 2 Or LeftType = 4) And (RightType = 2 Or RightType = 4) Then GoTo LessThanUnSigned1Byte
If (LeftType = 2 Or LeftType = 4) And (RightType = 1 Or RightType = 3) Then GoTo LessThanLURS1Byte
If (LeftType = 1 Or LeftType = 3) And (RightType = 2 Or RightType = 4) Then GoTo LessThanLSRU1Byte

If (LeftType = 1 Or LeftType = 3) And RightType = 5 Then GoTo LessThanLS1RS2
If (LeftType = 1 Or LeftType = 3) And RightType = 6 Then GoTo LessThanLS1RU2
If (LeftType = 2 Or LeftType = 4) And RightType = 5 Then GoTo LessThanLU1RS2
If (LeftType = 2 Or LeftType = 4) And RightType = 6 Then GoTo LessThanLU1RU2
If LeftType = 5 And (RightType = 1 Or RightType = 3) Then GoTo LessThanLS2RS1
If LeftType = 5 And (RightType = 2 Or RightType = 4) Then GoTo LessThanLS2RU1
If LeftType = 6 And (RightType = 1 Or RightType = 3) Then GoTo LessThanLU2RS1
If LeftType = 6 And (RightType = 2 Or RightType = 4) Then GoTo LessThanLU2RU1

If LeftType = 5 And RightType = 5 Then GoTo LessThanSigned2Byte
If LeftType = 6 And RightType = 6 Then GoTo LessThanUnSigned2Byte
If LeftType = 6 And RightType = 5 Then GoTo LessThanLURS2Byte
If LeftType = 5 And RightType = 6 Then GoTo LessThanLSRU2Byte

If LeftType = 7 And RightType = 7 Then GoTo LessThanSigned4Byte
If LeftType = 8 And RightType = 8 Then GoTo LessThanUnSigned4Byte
If LeftType = 8 And RightType = 7 Then GoTo LessThanLURS4Byte
If LeftType = 7 And RightType = 8 Then GoTo LessThanLSRU4Byte

If LeftType = 9 And RightType = 9 Then GoTo LessThanSigned8Byte
If LeftType = 10 And RightType = 10 Then GoTo LessThanUnSigned8Byte
If LeftType = 10 And RightType = 9 Then GoTo LessThanLURS8Byte
If LeftType = 9 And RightType = 10 Then GoTo LessThanLSRU8Byte

If LeftType = 11 And RightType = 11 Then GoTo LessThanSameFFP ' Both are FP 3 bytes
If LeftType = 12 And RightType = 12 Then GoTo LessThanSameFP8 ' Both are FP 8 bytes

' Otherwise Types are not the same
Value1Type = LeftType
Value2Type = RightType
GoSub ScaleSmallNumberOnStack ' Convert smaller of Value1Type(Leftside) or Value2Type(Rightside) type to the largest type

Select Case Largesttype
    Case 7 ' Same 4 byte Signed values
        GoTo LessThanSigned4Byte
    Case 8 ' Same 4 byte Unsigned values
        GoTo LessThanUnSigned4Byte
    Case 9 ' Same 8 byte Signed values
        GoTo LessThanSigned8Byte
    Case 10 ' Same 8 byte Unsigned values
        GoTo LessThanUnSigned8Byte
    Case 11 ' Same FFP values
        GoTo LessThanSameFFP
    Case 12 'Same Double values
        GoTo LessThanSameFP8
End Select

LessThanSigned1Byte:
' Left = ,S   Right = 1,S   (both signed 8-bit)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (8-bit) and pop it": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT (signed)": GoSub AO
A$ = "BLT": B$ = ">": C$ = "Skip if LEFT < RIGHT": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
Return
LessThanUnSigned1Byte:
' Left = ,S   Right = 1,S   (both unsigned 8-bit)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (8-bit) and pop it": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT (unsigned)": GoSub AO
A$ = "BLO": B$ = ">": C$ = "Skip if LEFT < RIGHT": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
Return
LessThanLURS1Byte:
' Left = ,S (unsigned)   Right = 1,S (signed)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "Test RIGHT sign (signed)": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "If RIGHT < 0 then LEFT < RIGHT is impossible": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (unsigned) and pop it": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned (RIGHT is 0..127 here)": GoSub AO
A$ = "BLO": B$ = ">": C$ = "Skip if LEFT < RIGHT": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
GoSub AO
Return
LessThanLSRU1Byte:
' Left = ,S (signed)   Right = 1,S (unsigned)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (signed) and pop it": GoSub AO
A$ = "BMI": B$ = ">": C$ = "If LEFT < 0 then LEFT < RIGHT is always True": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned (LEFT is 0..127 here)": GoSub AO
A$ = "BLO": B$ = ">": C$ = "Skip if LEFT < RIGHT": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
Return
LessThanLS1RS2:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get the left 8 bit value, move the stack": GoSub AO
A$ = "SEX": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "TSTD": GoSub AO
A$ = "BLT": B$ = ">": C$ = "Skip if LessThan": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
LessThanLS1RU2:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Pop LEFT signed 8-bit into B": GoSub AO
A$ = "BMI": B$ = "@Store": C$ = "If LEFT<0 then True": GoSub AO
Z$ = "!": A$ = "SEX": C$ = "Zero-extend LEFT into D": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BLO": B$ = "@Store": C$ = "If LEFT<RIGHT keep True": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@Store": A$ = "STX": B$ = ",S+": C$ = "Store result, pop RIGHT(16)": GoSub AO
GoSub AO
Return
LessThanLU1RS2:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "B= LEFT unsigned 8, move the stack": GoSub AO
A$ = "LDA": B$ = ",S": C$ = "Test RIGHT sign (RIGHT16 MSB)": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "If RIGHT<0 then FALSE": GoSub AO
A$ = "CLRA": C$ = "Zero-extend LEFT into D": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BLO": B$ = "@Store": C$ = "If LEFT<RIGHT keep True": GoSub AO
Z$ = "@False": A$ = "LDX": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@Store": A$ = "STX": B$ = ",S+": C$ = "Overwrite RIGHT16, leave 1 byte bool": GoSub AO
GoSub AO
Return
LessThanLU1RU2:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Pop LEFT unsigned 8-bit into B": GoSub AO
A$ = "CLRA": C$ = "Zero-extend LEFT into D": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT unsigned": GoSub AO
A$ = "BLO": B$ = "@Store": C$ = "If LEFT<RIGHT keep True": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@Store": A$ = "STX": B$ = ",S+": C$ = "Store result, pop RIGHT(16)": GoSub AO
GoSub AO
Return
LessThanLS2RS1:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "2,S": C$ = "Get the right 8 bit value": GoSub AO
A$ = "SEX": C$ = "D = B": GoSub AO
A$ = "CMPD": B$ = ",S+": C$ = "Compare the right 16 bit value to the left, move the stack": GoSub AO
A$ = "BGE": B$ = ">": C$ = "Skip if Greater Than or Equal (result is inverse)": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
LessThanLS2RU1:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDD": B$ = ",S+": C$ = "D = signed 16-bit, move stack 1 bytes": GoSub AO
A$ = "BMI": B$ = "@Store": C$ = "If LEFT<0 then TRUE": GoSub AO
A$ = "CLR": B$ = ",S": C$ = "ext=0 for unsigned RIGHT": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BLO": B$ = "@Store": C$ = "If LEFT<RIGHT keep True": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@Store": A$ = "STX": B$ = ",S+": C$ = "Store result, pop RIGHT(16)": GoSub AO
GoSub AO
Return
LessThanLU2RS1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S+": C$ = "X= unsigned 16-bit, move the stack": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "Get the right 8 bit value": GoSub AO
A$ = "BMI": B$ = "@False": GoSub AO
A$ = "SEX": C$ = "D = B": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save the as right 16 bit value": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare the right 16 bit value to the left, move the stack": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "Skip if LessThan": GoSub AO
Z$ = "@False"
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "@True"
A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
LessThanLU2RU1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S+": C$ = "D = Left value, move the stack": GoSub AO
A$ = "CLR": B$ = ",S": C$ = "Clear MSB": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare the left 16 bit value to the right": GoSub AO
A$ = "BLO": B$ = ">": C$ = "Skip if LessThan": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
LessThanSigned2Byte:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S++": C$ = "D = Left 16 bit value1, move the stack": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare with right 16 bit value2, move the stack": GoSub AO
A$ = "BLT": B$ = ">": C$ = "Skip if LessThan": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
LessThanUnSigned2Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S++": C$ = "D = Left 16 bit value1, move the stack": GoSub AO
A$ = "CMPX": B$ = ",S+": C$ = "Compare with right 16 bit value2, move the stack": GoSub AO
A$ = "BLO": B$ = ">": C$ = "Skip if LessThan": GoSub AO
A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
' Both are 2 bytes
LessThanLURS2Byte:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDA": B$ = "2,S": C$ = "Right value2": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Skip if it's ponnegative": GoSub AO
GoTo LessThan2

' Both are 2 bytes
LessThanLSRU2Byte:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Left is signed is 16 bits": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Skip if it's a negative": GoSub AO

LessThan2:
A$ = "LDX": B$ = ",S": C$ = "Left value1": GoSub AO
A$ = "CMPX": B$ = "2,S": C$ = "Compare with left 16 bit value2, move the stack": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "Skip if LessThan": GoSub AO
Z$ = "@False": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "2,S": GoSub AO
A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
' Both are 4 bytes
LessThanSigned4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "CMPX": B$ = "4,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BLT": B$ = "@True": C$ = "If LessThan, Exit with True": GoSub AO
A$ = "BGT": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "6,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "Skip if LessThan": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "7,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
' Both are 4 bytes
LessThanUnSigned4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
GoTo LessThan4

' Both are 4 bytes
LessThanLURS4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "4,S": C$ = "Get the right Word 32 bit value": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Save False": GoSub AO
GoTo LessThan4

' Both are 4 bytes
LessThanLSRU4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Save True": GoSub AO

LessThan4:
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "CMPX": B$ = "4,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessThan, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "6,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "Skip if LessThan": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "7,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are 8 bytes
LessThanSigned8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "8,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLT": B$ = "@True": C$ = "If LessThan, Exit with True": GoSub AO
A$ = "BGT": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "10,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessThan, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "4,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "12,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessThan, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "6,S": C$ = "Get the left LSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "14,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "Skip if LessThan": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "15,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
' Both are 8 bytes
LessThanUnSigned8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
GoTo LessThan8

' Both are 8 bytes
LessThanLURS8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "8,S": C$ = "Get the right Word 64 bit value": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Save False": GoSub AO
GoTo LessThan8

' Both are 8 bytes
LessThanLSRU8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Save True": GoSub AO

LessThan8:
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "8,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessThan, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "10,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessThan, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "4,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "12,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessThan, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "6,S": C$ = "Get the left LSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "14,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "Skip if LessThan": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "15,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are FP 3 bytes in FFP format
LessThanSameFFP:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "FFP_CMP_Stack": C$ = "Compare FFP Value1 @ ,S with Value 2 @ 3,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BGT": B$ = ">": C$ = "Skip if GreaterThan": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "4,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return

' Both are FP 10 bytes
LessThanSameFP8:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "Double_CMP_Stack": C$ = "Compare Double Value1 @ ,S with Value 2 @ 10,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BGT": B$ = ">": C$ = "Skip if GreaterThan": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "18,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return

' 0 = False
' $FF & non zero = True
'NumFunctionGreaterThan:
'Z$ = "; Doing Function GreaterThan": GoSub AO
'Z$ = "; LeftType=" + Str$(LeftType): GoSub AO
'Z$ = "; RightType=" + Str$(RightType): GoSub AO

NumFunctionLessThan:
Z$ = "; Doing Function LessThan": GoSub AO
Z$ = "; LeftType=" + Str$(LeftType): GoSub AO
Z$ = "; RightType=" + Str$(RightType): GoSub AO
' Have to deal with signed and unsigned values when comparing
If (LeftType = 1 Or LeftType = 3) And (RightType = 1 Or RightType = 3) Then GoTo GreaterThanSigned1Byte
If (LeftType = 2 Or LeftType = 4) And (RightType = 2 Or RightType = 4) Then GoTo GreaterThanUnSigned1Byte
If (LeftType = 2 Or LeftType = 4) And (RightType = 1 Or RightType = 3) Then GoTo GreaterThanLURS1Byte
If (LeftType = 1 Or LeftType = 3) And (RightType = 2 Or RightType = 4) Then GoTo GreaterThanLSRU1Byte

If (LeftType = 1 Or LeftType = 3) And RightType = 5 Then GoTo GreaterThanLS1RS2
If (LeftType = 1 Or LeftType = 3) And RightType = 6 Then GoTo GreaterThanLS1RU2
If (LeftType = 2 Or LeftType = 4) And RightType = 5 Then GoTo GreaterThanLU1RS2
If (LeftType = 2 Or LeftType = 4) And RightType = 6 Then GoTo GreaterThanLU1RU2
If LeftType = 5 And (RightType = 1 Or RightType = 3) Then GoTo GreaterThanLS2RS1
If LeftType = 5 And (RightType = 2 Or RightType = 4) Then GoTo GreaterThanLS2RU1
If LeftType = 6 And (RightType = 1 Or RightType = 3) Then GoTo GreaterThanLU2RS1
If LeftType = 6 And (RightType = 2 Or RightType = 4) Then GoTo GreaterThanLU2RU1

If LeftType = 5 And RightType = 5 Then GoTo GreaterThanSigned2Byte
If LeftType = 6 And RightType = 6 Then GoTo GreaterThanUnSigned2Byte
If LeftType = 6 And RightType = 5 Then GoTo GreaterThanLURS2Byte
If LeftType = 5 And RightType = 6 Then GoTo GreaterThanLSRU2Byte

If LeftType = 7 And RightType = 7 Then GoTo GreaterThanSigned4Byte
If LeftType = 8 And RightType = 8 Then GoTo GreaterThanUnSigned4Byte
If LeftType = 8 And RightType = 7 Then GoTo GreaterThanLURS4Byte
If LeftType = 7 And RightType = 8 Then GoTo GreaterThanLSRU4Byte

If LeftType = 9 And RightType = 9 Then GoTo GreaterThanSigned8Byte
If LeftType = 10 And RightType = 10 Then GoTo GreaterThanUnSigned8Byte
If LeftType = 10 And RightType = 9 Then GoTo GreaterThanLURS8Byte
If LeftType = 9 And RightType = 10 Then GoTo GreaterThanLSRU8Byte

If LeftType = 11 And RightType = 11 Then GoTo GreaterThanSameFFP ' Both are FP 3 bytes
If LeftType = 12 And RightType = 12 Then GoTo GreaterThanSameFP8 ' Both are FP 8 bytes

' Otherwise Types are not the same
Value1Type = LeftType
Value2Type = RightType
GoSub ScaleSmallNumberOnStack ' Convert smaller of Value1Type(Leftside) or Value2Type(Rightside) type to the largest type

Select Case Largesttype
    Case 7 ' Same 4 byte Signed values
        GoTo GreaterThanSigned4Byte
    Case 8 ' Same 4 byte Unsigned values
        GoTo GreaterThanUnSigned4Byte
    Case 9 ' Same 8 byte Signed values
        GoTo GreaterThanSigned8Byte
    Case 10 ' Same 8 byte Unsigned values
        GoTo GreaterThanUnSigned8Byte
    Case 11 ' Same FFP values
        GoTo GreaterThanSameFFP
    Case 12 'Same Double values
        GoTo GreaterThanSameFP8
End Select

GreaterThanSigned1Byte:
' Left = ,S   Right = 1,S   (both signed 8-bit)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get left (8-bit) and pop it": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT (signed)": GoSub AO
A$ = "BGT": B$ = ">": C$ = "Skip if LEFT > RIGHT": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
Return
GreaterThanUnSigned1Byte:
' Left = ,S   Right = 1,S   (both unsigned 8-bit)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (8-bit) and pop it": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT (unsigned)": GoSub AO
A$ = "BHI": B$ = ">": C$ = "Skip if LEFT > RIGHT": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
Return
GreaterThanLURS1Byte:
' Left = ,S (unsigned)   Right = 1,S (signed)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "Test RIGHT sign (signed)": GoSub AO
A$ = "BMI": B$ = ">": C$ = "If RIGHT < 0 then LEFT > RIGHT": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Get LEFT (unsigned), move stack": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BHI": B$ = ">": C$ = "Skip if LEFT > RIGHT": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "1,S": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
GoSub AO
Return
GreaterThanLSRU1Byte:
' Left = ,S (signed)   Right = 1,S (unsigned)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (signed), move stack": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "If LEFT < 0 then False": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned (LEFT is 0..127 here)": GoSub AO
A$ = "BHI": B$ = ">": C$ = "Skip if LEFT > RIGHT": GoSub AO
Z$ = "@False": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
GoSub AO
Return
GreaterThanLS1RS2:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get the left 8 bit value, move the stack": GoSub AO
A$ = "SEX": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare left vs right": GoSub AO
A$ = "BGT": B$ = ">": C$ = "Skip if GreaterThan": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
GreaterThanLS1RU2:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "B = LEFT signed 8-bit": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "If LEFT < 0 then False": GoSub AO
A$ = "SEX": C$ = "Sign-extend, D = B": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BHI": B$ = ">": C$ = "If LEFT>RIGHT keep True": GoSub AO
Z$ = "@False": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Store result, move stack": GoSub AO
GoSub AO
Return
GreaterThanLU1RS2:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "B= right signed": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "If RIGHT<0 then True": GoSub AO
A$ = "LDB": B$ = ",S": GoSub AO
A$ = "CLRA": C$ = "D = B": GoSub AO
A$ = "CMPD": B$ = "1,S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If LEFT>RIGHT keep True": GoSub AO
Z$ = "@False": A$ = "LDU": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "1,S": GoSub AO
A$ = "STU": B$ = ",S+": C$ = "Store result, move stack": GoSub AO
GoSub AO
Return
GreaterThanLU1RU2:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Pop LEFT unsigned 8-bit into B": GoSub AO
A$ = "CLRA": C$ = "Zero-extend LEFT into D": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT unsigned": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If LEFT<RIGHT keep True": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@True": A$ = "STU": B$ = ",S+": C$ = "Store result, move stack": GoSub AO
GoSub AO
Return
GreaterThanLS2RS1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "2,S": C$ = "Get the right 8 bit value": GoSub AO
A$ = "SEX": C$ = "D = B": GoSub AO
A$ = "CMPD": B$ = ",S+": C$ = "Compare the right 16 bit value to the left, move the stack": GoSub AO
A$ = "BLE": B$ = "@True": C$ = "Skip if Less Than or Equal (result is inverse)": GoSub AO
Z$ = "@False": A$ = "LDU": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@True": A$ = "STU": B$ = ",S+": C$ = "Store result, move stack": GoSub AO
GoSub AO
Return
GreaterThanLS2RU1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDD": B$ = ",S+": C$ = "D = signed 16-bit, move stack 1 bytes": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "If LEFT<0 then False": GoSub AO
A$ = "CLR": B$ = ",S": C$ = "ext=0 for unsigned RIGHT": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If LEFT>RIGHT keep True": GoSub AO
Z$ = "@False": A$ = "LDU": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@True": A$ = "STU": B$ = ",S+": C$ = "Store result, move stack": GoSub AO
GoSub AO
Return
GreaterThanLU2RS1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S+": C$ = "X= unsigned 16-bit, move the stack": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "Get the right 8 bit value": GoSub AO
A$ = "BMI": B$ = "@True": GoSub AO
A$ = "SEX": C$ = "D = B": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save the as right 16 bit value": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare the right 16 bit value to the left, move the stack": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "Skip if GreaterThan": GoSub AO
Z$ = "@False"
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "@True"
A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
GreaterThanLU2RU1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S+": C$ = "D = Left value, move the stack": GoSub AO
A$ = "CLR": B$ = ",S": C$ = "Clear MSB": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare the left 16 bit value to the right": GoSub AO
A$ = "BHI": B$ = ">": C$ = "Skip if GreaterThan": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
GreaterThanSigned2Byte:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S++": C$ = "D = Left 16 bit value1, move the stack": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare with right 16 bit value2, move the stack": GoSub AO
A$ = "BGT": B$ = ">": C$ = "Skip if GreaterThan": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
GreaterThanUnSigned2Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S++": C$ = "D = Left 16 bit value1, move the stack": GoSub AO
A$ = "CMPX": B$ = ",S+": C$ = "Compare with right 16 bit value2, move the stack": GoSub AO
A$ = "BHI": B$ = ">": C$ = "Skip if GreaterThan": GoSub AO
A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
' Both are 2 bytes
GreaterThanLURS2Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "2,S": C$ = "Right value2": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Skip if it's a negative": GoSub AO
GoTo GreaterThan2

' Both are 2 bytes
GreaterThanLSRU2Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Left is signed is 16 bits": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Skip if it's ponnegative": GoSub AO

GreaterThan2:
A$ = "LDX": B$ = ",S": C$ = "Left value1": GoSub AO
A$ = "CMPX": B$ = "2,S": C$ = "Compare with left 16 bit value2, move the stack": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "Skip if GreaterThan": GoSub AO
Z$ = "@False": GoSub AO
A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "3,S": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
' Both are 4 bytes
GreaterThanSigned4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "CMPX": B$ = "4,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BGT": B$ = "@True": C$ = "If GreaterThan, Exit with True": GoSub AO
A$ = "BLT": B$ = "@False": C$ = "If LowerThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "6,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "Skip if GreaterThan": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "7,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are 4 bytes
GreaterThanUnSigned4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
GoTo GreaterThan4

' Both are 4 bytes
GreaterThanLURS4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "4,S": C$ = "Get the right Word 32 bit value": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Save True": GoSub AO
GoTo GreaterThan4

' Both are 4 bytes
GreaterThanLSRU4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Save False": GoSub AO

GreaterThan4:
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "CMPX": B$ = "4,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterThan, Exit with True": GoSub AO
A$ = "BLO": B$ = "@False": C$ = "If LessThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "6,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "Skip if GreaterThan": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "7,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
' Both are 8 bytes
GreaterThanSigned8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "8,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BGT": B$ = "@True": C$ = "If GreaterThan, Exit with True": GoSub AO
A$ = "BLT": B$ = "@False": C$ = "If LessThan or Equal, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "10,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterThan, Exit with True": GoSub AO
A$ = "BLO": B$ = "@False": C$ = "If LessThan or Same, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "4,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "12,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterThan, Exit with True": GoSub AO
A$ = "BLO": B$ = "@False": C$ = "If LessThan or Same, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "6,S": C$ = "Get the left LSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "14,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "Skip if GreaterThan": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "15,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are 8 bytes
GreaterThanUnSigned8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
GoTo GreaterThan8

' Both are 8 bytes
GreaterThanLURS8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "8,S": C$ = "Get the right Word 64 bit value": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Save True": GoSub AO
GoTo GreaterThan8

' Both are 8 bytes
GreaterThanLSRU8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Save False": GoSub AO

GreaterThan8:
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "8,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterThan, Exit with True": GoSub AO
A$ = "BLS": B$ = "@False": C$ = "If LessThan or Same, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "10,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterThan, Exit with True": GoSub AO
A$ = "BLS": B$ = "@False": C$ = "If LessThan or Same, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "4,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "12,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterThan, Exit with True": GoSub AO
A$ = "BLS": B$ = "@False": C$ = "If LessThan or Same, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "6,S": C$ = "Get the left LSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "14,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "Skip if GreaterThan": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "15,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are FP 3 bytes in FFP format
GreaterThanSameFFP:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "FFP_CMP_Stack": C$ = "Compare FFP Value1 @ ,S with Value 2 @ 3,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BLT": B$ = ">": C$ = "Skip if LessThan": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "4,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return

' Both are FP 10 bytes
GreaterThanSameFP8:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "Double_CMP_Stack": C$ = "Compare Double Value1 @ ,S with Value 2 @ 10,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BLT": B$ = ">": C$ = "Skip if LessThan": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "18,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return

' 0 = False
' $FF & non zero = True
'NumFunctionLessOrEqual:
'Z$ = "; Doing Function LessOrEqual": GoSub AO
'Z$ = "; LeftType=" + Str$(LeftType): GoSub AO
'Z$ = "; RightType=" + Str$(RightType): GoSub AO

NumFunctionGreaterOrEqual:
Z$ = "; Doing Function GreaterOrEqual": GoSub AO
Z$ = "; LeftType=" + Str$(LeftType): GoSub AO
Z$ = "; RightType=" + Str$(RightType): GoSub AO
' Have to deal with signed and unsigned values when comparing
If (LeftType = 1 Or LeftType = 3) And (RightType = 1 Or RightType = 3) Then GoTo LessOrEqualSigned1Byte
If (LeftType = 2 Or LeftType = 4) And (RightType = 2 Or RightType = 4) Then GoTo LessOrEqualUnSigned1Byte
If (LeftType = 2 Or LeftType = 4) And (RightType = 1 Or RightType = 3) Then GoTo LessOrEqualLURS1Byte
If (LeftType = 1 Or LeftType = 3) And (RightType = 2 Or RightType = 4) Then GoTo LessOrEqualLSRU1Byte

If (LeftType = 1 Or LeftType = 3) And RightType = 5 Then GoTo LessOrEqualLS1RS2
If (LeftType = 1 Or LeftType = 3) And RightType = 6 Then GoTo LessOrEqualLS1RU2
If (LeftType = 2 Or LeftType = 4) And RightType = 5 Then GoTo LessOrEqualLU1RS2
If (LeftType = 2 Or LeftType = 4) And RightType = 6 Then GoTo LessOrEqualLU1RU2
If LeftType = 5 And (RightType = 1 Or RightType = 3) Then GoTo LessOrEqualLS2RS1
If LeftType = 5 And (RightType = 2 Or RightType = 4) Then GoTo LessOrEqualLS2RU1
If LeftType = 6 And (RightType = 1 Or RightType = 3) Then GoTo LessOrEqualLU2RS1
If LeftType = 6 And (RightType = 2 Or RightType = 4) Then GoTo LessOrEqualLU2RU1

If LeftType = 5 And RightType = 5 Then GoTo LessOrEqualSigned2Byte
If LeftType = 6 And RightType = 6 Then GoTo LessOrEqualUnSigned2Byte
If LeftType = 6 And RightType = 5 Then GoTo LessOrEqualLURS2Byte
If LeftType = 5 And RightType = 6 Then GoTo LessOrEqualLSRU2Byte

If LeftType = 7 And RightType = 7 Then GoTo LessOrEqualSigned4Byte
If LeftType = 8 And RightType = 8 Then GoTo LessOrEqualUnSigned4Byte
If LeftType = 8 And RightType = 7 Then GoTo LessOrEqualLURS4Byte
If LeftType = 7 And RightType = 8 Then GoTo LessOrEqualLSRU4Byte

If LeftType = 9 And RightType = 9 Then GoTo LessOrEqualSigned8Byte
If LeftType = 10 And RightType = 10 Then GoTo LessOrEqualUnSigned8Byte
If LeftType = 10 And RightType = 9 Then GoTo LessOrEqualLURS8Byte
If LeftType = 9 And RightType = 10 Then GoTo LessOrEqualLSRU8Byte

If LeftType = 11 And RightType = 11 Then GoTo LessOrEqualSameFFP ' Both are FP 3 bytes
If LeftType = 12 And RightType = 12 Then GoTo LessOrEqualSameFP8 ' Both are FP 8 bytes

' Otherwise Types are not the same
Value1Type = LeftType
Value2Type = RightType
GoSub ScaleSmallNumberOnStack ' Convert smaller of Value1Type(Leftside) or Value2Type(Rightside) type to the largest type

Select Case Largesttype
    Case 7 ' Same 4 byte Signed values
        GoTo LessOrEqualSigned4Byte
    Case 8 ' Same 4 byte Unsigned values
        GoTo LessOrEqualUnSigned4Byte
    Case 9 ' Same 8 byte Signed values
        GoTo LessOrEqualSigned8Byte
    Case 10 ' Same 8 byte Unsigned values
        GoTo LessOrEqualUnSigned8Byte
    Case 11 ' Same FFP values
        GoTo LessOrEqualSameFFP
    Case 12 'Same Double values
        GoTo LessOrEqualSameFP8
End Select

LessOrEqualSigned1Byte:
' Left = ,S   Right = 1,S   (both signed 8-bit)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (8-bit) and pop it": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT (signed)": GoSub AO
A$ = "BLE": B$ = ">": C$ = "Skip if LEFT <= RIGHT": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
Return
LessOrEqualUnSigned1Byte:
' Left = ,S   Right = 1,S   (both unsigned 8-bit)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (8-bit) and pop it": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT (unsigned)": GoSub AO
A$ = "BLS": B$ = ">": C$ = "Skip if LEFT <= RIGHT": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
Return
LessOrEqualLURS1Byte:
' Left = ,S (unsigned)   Right = 1,S (signed)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "Test RIGHT sign (signed)": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "If RIGHT < 0 then False": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (unsigned) and pop it": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned (RIGHT is 0..127 here)": GoSub AO
A$ = "BLS": B$ = ">": C$ = "Skip if LEFT <= RIGHT": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
GoSub AO
Return
LessOrEqualLSRU1Byte:
' Left = ,S (signed)   Right = 1,S (unsigned)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (signed) and pop it": GoSub AO
A$ = "BMI": B$ = ">": C$ = "If LEFT < 0 then True": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned (LEFT is 0..127 here)": GoSub AO
A$ = "BLS": B$ = ">": C$ = "Skip if LEFT <= RIGHT": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
Return
LessOrEqualLS1RS2:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get the left 8 bit value, move the stack": GoSub AO
A$ = "SEX": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "TSTD": GoSub AO
A$ = "BLE": B$ = ">": C$ = "Skip if LessOrEqual": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
LessOrEqualLS1RU2:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Pop LEFT signed 8-bit into B": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "If LEFT is <-1 then True": GoSub AO
Z$ = "!": A$ = "SEX": C$ = "Sign extend LEFT into D": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BLS": B$ = "@True": C$ = "If LEFT <= RIGHT keep True": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@True": A$ = "STX": B$ = ",S+": C$ = "Store result, pop RIGHT(16)": GoSub AO
GoSub AO
Return
LessOrEqualLU1RS2:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "B= LEFT unsigned 8, move the stack": GoSub AO
A$ = "LDA": B$ = ",S": C$ = "Test RIGHT sign (RIGHT16 MSB)": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "If RIGHT<0 then FALSE": GoSub AO
A$ = "CLRA": C$ = "Zero-extend LEFT into D": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BLS": B$ = "@Store": C$ = "If LEFT <= RIGHT keep True": GoSub AO
Z$ = "@False": A$ = "LDX": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@Store": A$ = "STX": B$ = ",S+": C$ = "Overwrite RIGHT16, leave 1 byte bool": GoSub AO
GoSub AO
Return
LessOrEqualLU1RU2:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Pop LEFT unsigned 8-bit into B": GoSub AO
A$ = "CLRA": C$ = "Zero-extend LEFT into D": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT unsigned": GoSub AO
A$ = "BLS": B$ = "@Store": C$ = "If LEFT <= RIGHT keep True": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@Store": A$ = "STX": B$ = ",S+": C$ = "Store result, pop RIGHT(16)": GoSub AO
GoSub AO
Return
LessOrEqualLS2RS1:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "2,S": C$ = "Get the right 8 bit value": GoSub AO
A$ = "SEX": C$ = "D = B": GoSub AO
A$ = "CMPD": B$ = ",S+": C$ = "Compare the right 16 bit value to the left, move the stack": GoSub AO
A$ = "BGT": B$ = ">": C$ = "Skip if Greater Than (result is inverse)": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
LessOrEqualLS2RU1:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDD": B$ = ",S+": C$ = "D = signed 16-bit, move stack 1 bytes": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "If LEFT<0 then True": GoSub AO
A$ = "CLR": B$ = ",S": C$ = "ext=0 for unsigned RIGHT": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BLS": B$ = "@True": C$ = "If LEFT <= RIGHT keep True": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@True": A$ = "STX": B$ = ",S+": C$ = "Store result, pop RIGHT(16)": GoSub AO
GoSub AO
Return
LessOrEqualLU2RS1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S+": C$ = "X= unsigned 16-bit, move the stack": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "Get the right 8 bit value": GoSub AO
A$ = "BMI": B$ = "@False": GoSub AO
A$ = "SEX": C$ = "D = B": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save the as right 16 bit value": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare the right 16 bit value to the left, move the stack": GoSub AO
A$ = "BLS": B$ = "@True": C$ = "Skip if LessOrEqual": GoSub AO
Z$ = "@False"
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "@True"
A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
LessOrEqualLU2RU1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S+": C$ = "D = Left value, move the stack": GoSub AO
A$ = "CLR": B$ = ",S": C$ = "Clear MSB": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare the left 16 bit value to the right": GoSub AO
A$ = "BLS": B$ = ">": C$ = "Skip if LessOrEqual": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
LessOrEqualSigned2Byte:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S++": C$ = "D = Left 16 bit value1, move the stack": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare with right 16 bit value2, move the stack": GoSub AO
A$ = "BLE": B$ = ">": C$ = "Skip if LessOrEqual": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
LessOrEqualUnSigned2Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S++": C$ = "D = Left 16 bit value1, move the stack": GoSub AO
A$ = "CMPX": B$ = ",S+": C$ = "Compare with right 16 bit value2, move the stack": GoSub AO
A$ = "BLS": B$ = ">": C$ = "Skip if LessOrEqual": GoSub AO
A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
' Both are 2 bytes
LessOrEqualLURS2Byte:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDA": B$ = "2,S": C$ = "Right value2": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Skip if it's ponnegative": GoSub AO
GoTo LessOrEqual2

' Both are 2 bytes
LessOrEqualLSRU2Byte:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Left is signed is 16 bits": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Skip if it's a negative": GoSub AO

LessOrEqual2:
A$ = "LDX": B$ = ",S": C$ = "Left value1": GoSub AO
A$ = "CMPX": B$ = "2,S": C$ = "Compare with left 16 bit value2, move the stack": GoSub AO
A$ = "BLS": B$ = "@True": C$ = "Skip if LessOrEqual": GoSub AO
Z$ = "@False": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "2,S": GoSub AO
A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
' Both are 4 bytes
LessOrEqualSigned4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "CMPX": B$ = "4,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BLT": B$ = "@True": C$ = "If LessOrEqual, Exit with True": GoSub AO
A$ = "BGT": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "6,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BLS": B$ = "@True": C$ = "Skip if LessOrEqual": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "7,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
' Both are 4 bytes
LessOrEqualUnSigned4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
GoTo LessOrEqual4

' Both are 4 bytes
LessOrEqualLURS4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "4,S": C$ = "Get the right Word 32 bit value": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Save False": GoSub AO
GoTo LessOrEqual4

' Both are 4 bytes
LessOrEqualLSRU4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Save True": GoSub AO

LessOrEqual4:
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "CMPX": B$ = "4,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessOrEqual, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "6,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BLS": B$ = "@True": C$ = "Skip if LessOrEqual": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "7,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are 8 bytes
LessOrEqualSigned8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "8,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLT": B$ = "@True": C$ = "If LessOrEqual, Exit with True": GoSub AO
A$ = "BGT": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "10,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessOrEqual, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "4,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "12,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessOrEqual, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "6,S": C$ = "Get the left LSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "14,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLS": B$ = "@True": C$ = "Skip if LessOrEqual": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "15,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
' Both are 8 bytes
LessOrEqualUnSigned8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
GoTo LessOrEqual8

' Both are 8 bytes
LessOrEqualLURS8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "8,S": C$ = "Get the right Word 64 bit value": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Save False": GoSub AO
GoTo LessOrEqual8

' Both are 8 bytes
LessOrEqualLSRU8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Save True": GoSub AO

LessOrEqual8:
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "8,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessOrEqual, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "10,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessOrEqual, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "4,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "12,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLO": B$ = "@True": C$ = "If LessOrEqual, Exit with True": GoSub AO
A$ = "BHI": B$ = "@False": C$ = "If GreaterThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "6,S": C$ = "Get the left LSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "14,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BLS": B$ = "@True": C$ = "Skip if LessOrEqual": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "15,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are FP 3 bytes in FFP format
LessOrEqualSameFFP:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "FFP_CMP_Stack": C$ = "Compare FFP Value1 @ ,S with Value 2 @ 3,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BGE": B$ = ">": C$ = "Skip if GreaterOrEqual": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "4,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return

' Both are FP 10 bytes
LessOrEqualSameFP8:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "Double_CMP_Stack": C$ = "Compare Double Value1 @ ,S with Value 2 @ 10,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BGE": B$ = ">": C$ = "Skip if GreaterOrEqual": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "18,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return

' 0 = False
' $FF & non zero = True
' NumFunctionGreaterOrEqual:
' Z$ = "; Doing Function GreaterOrEqual": GoSub AO
' Z$ = "; LeftType=" + Str$(LeftType): GoSub AO
' Z$ = "; RightType=" + Str$(RightType): GoSub AO
NumFunctionLessOrEqual:
Z$ = "; Doing Function LessOrEqual": GoSub AO
Z$ = "; LeftType=" + Str$(LeftType): GoSub AO
Z$ = "; RightType=" + Str$(RightType): GoSub AO
' Have to deal with signed and unsigned values when comparing
If (LeftType = 1 Or LeftType = 3) And (RightType = 1 Or RightType = 3) Then GoTo GreaterOrEqualSigned1Byte
If (LeftType = 2 Or LeftType = 4) And (RightType = 2 Or RightType = 4) Then GoTo GreaterOrEqualUnSigned1Byte
If (LeftType = 2 Or LeftType = 4) And (RightType = 1 Or RightType = 3) Then GoTo GreaterOrEqualLURS1Byte
If (LeftType = 1 Or LeftType = 3) And (RightType = 2 Or RightType = 4) Then GoTo GreaterOrEqualLSRU1Byte

If (LeftType = 1 Or LeftType = 3) And RightType = 5 Then GoTo GreaterOrEqualLS1RS2
If (LeftType = 1 Or LeftType = 3) And RightType = 6 Then GoTo GreaterOrEqualLS1RU2
If (LeftType = 2 Or LeftType = 4) And RightType = 5 Then GoTo GreaterOrEqualLU1RS2
If (LeftType = 2 Or LeftType = 4) And RightType = 6 Then GoTo GreaterOrEqualLU1RU2
If LeftType = 5 And (RightType = 1 Or RightType = 3) Then GoTo GreaterOrEqualLS2RS1
If LeftType = 5 And (RightType = 2 Or RightType = 4) Then GoTo GreaterOrEqualLS2RU1
If LeftType = 6 And (RightType = 1 Or RightType = 3) Then GoTo GreaterOrEqualLU2RS1
If LeftType = 6 And (RightType = 2 Or RightType = 4) Then GoTo GreaterOrEqualLU2RU1

If LeftType = 5 And RightType = 5 Then GoTo GreaterOrEqualSigned2Byte
If LeftType = 6 And RightType = 6 Then GoTo GreaterOrEqualUnSigned2Byte
If LeftType = 6 And RightType = 5 Then GoTo GreaterOrEqualLURS2Byte
If LeftType = 5 And RightType = 6 Then GoTo GreaterOrEqualLSRU2Byte

If LeftType = 7 And RightType = 7 Then GoTo GreaterOrEqualSigned4Byte
If LeftType = 8 And RightType = 8 Then GoTo GreaterOrEqualUnSigned4Byte
If LeftType = 8 And RightType = 7 Then GoTo GreaterOrEqualLURS4Byte
If LeftType = 7 And RightType = 8 Then GoTo GreaterOrEqualLSRU4Byte

If LeftType = 9 And RightType = 9 Then GoTo GreaterOrEqualSigned8Byte
If LeftType = 10 And RightType = 10 Then GoTo GreaterOrEqualUnSigned8Byte
If LeftType = 10 And RightType = 9 Then GoTo GreaterOrEqualLURS8Byte
If LeftType = 9 And RightType = 10 Then GoTo GreaterOrEqualLSRU8Byte

If LeftType = 11 And RightType = 11 Then GoTo GreaterOrEqualSameFFP ' Both are FP 3 bytes
If LeftType = 12 And RightType = 12 Then GoTo GreaterOrEqualSameFP8 ' Both are FP 8 bytes

' Otherwise Types are not the same
Value1Type = LeftType
Value2Type = RightType
GoSub ScaleSmallNumberOnStack ' Convert smaller of Value1Type(Leftside) or Value2Type(Rightside) type to the largest type

Select Case Largesttype
    Case 7 ' Same 4 byte Signed values
        GoTo GreaterOrEqualSigned4Byte
    Case 8 ' Same 4 byte Unsigned values
        GoTo GreaterOrEqualUnSigned4Byte
    Case 9 ' Same 8 byte Signed values
        GoTo GreaterOrEqualSigned8Byte
    Case 10 ' Same 8 byte Unsigned values
        GoTo GreaterOrEqualUnSigned8Byte
    Case 11 ' Same FFP values
        GoTo GreaterOrEqualSameFFP
    Case 12 'Same Double values
        GoTo GreaterOrEqualSameFP8
End Select

GreaterOrEqualSigned1Byte:
' Left = ,S   Right = 1,S   (both signed 8-bit)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get left (8-bit) and pop it": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT (signed)": GoSub AO
A$ = "BGE": B$ = ">": C$ = "Skip if LEFT >= RIGHT": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
Return
GreaterOrEqualUnSigned1Byte:
' Left = ,S   Right = 1,S   (both unsigned 8-bit)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (8-bit) and pop it": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT (unsigned)": GoSub AO
A$ = "BHS": B$ = ">": C$ = "Skip if LEFT >= RIGHT": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
Return
GreaterOrEqualLURS1Byte:
' Left = ,S (unsigned)   Right = 1,S (signed)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "Test RIGHT sign (signed)": GoSub AO
A$ = "BMI": B$ = ">": C$ = "If RIGHT < 0 then LEFT >= RIGHT": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Get LEFT (unsigned), move stack": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BHS": B$ = ">": C$ = "Skip if LEFT >= RIGHT": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "1,S": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
GoSub AO
Return
GreaterOrEqualLSRU1Byte:
' Left = ,S (signed)   Right = 1,S (unsigned)
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LEFT (signed), move stack": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "If LEFT < 0 then False": GoSub AO
A$ = "CMPB": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned (LEFT is 0..127 here)": GoSub AO
A$ = "BHS": B$ = ">": C$ = "Skip if LEFT >= RIGHT": GoSub AO
Z$ = "@False": GoSub AO
A$ = "CLRA": C$ = "Flag as false": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Store result over RIGHT": GoSub AO
GoSub AO
Return
GreaterOrEqualLS1RS2:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get the left 8 bit value, move the stack": GoSub AO
A$ = "SEX": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare left vs right": GoSub AO
A$ = "BGE": B$ = ">": C$ = "Skip if GreaterOrEqual": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
GreaterOrEqualLS1RU2:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "B = LEFT signed 8-bit": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "If LEFT < 0 then False": GoSub AO
A$ = "SEX": C$ = "Sign-extend, D = B": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BHS": B$ = ">": C$ = "If LEFT >= RIGHT keep True": GoSub AO
Z$ = "@False": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Store result, move stack": GoSub AO
GoSub AO
Return
GreaterOrEqualLU1RS2:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "B= right signed": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "If RIGHT<0 then True": GoSub AO
A$ = "LDB": B$ = ",S": GoSub AO
A$ = "CLRA": C$ = "D = B": GoSub AO
A$ = "CMPD": B$ = "1,S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BHS": B$ = "@True": C$ = "If LEFT >= RIGHT keep True": GoSub AO
Z$ = "@False": A$ = "LDU": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "1,S": GoSub AO
A$ = "STU": B$ = ",S+": C$ = "Store result, move stack": GoSub AO
GoSub AO
Return
GreaterOrEqualLU1RU2:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Pop LEFT unsigned 8-bit into B": GoSub AO
A$ = "CLRA": C$ = "Zero-extend LEFT into D": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT unsigned": GoSub AO
A$ = "BHS": B$ = "@True": C$ = "If LEFT >= RIGHT keep True": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@True": A$ = "STU": B$ = ",S+": C$ = "Store result, move stack": GoSub AO
GoSub AO
Return
GreaterOrEqualLS2RS1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "2,S": C$ = "Get the right 8 bit value": GoSub AO
A$ = "SEX": C$ = "D = B": GoSub AO
A$ = "CMPD": B$ = ",S+": C$ = "Compare the right 16 bit value to the left, move the stack": GoSub AO
A$ = "BLT": B$ = "@True": C$ = "Skip if Less Than (result is inverse)": GoSub AO
Z$ = "@False": A$ = "LDU": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@True": A$ = "STU": B$ = ",S+": C$ = "Store result, move stack": GoSub AO
GoSub AO
Return
GreaterOrEqualLS2RU1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDD": B$ = ",S+": C$ = "D = signed 16-bit, move stack 1 bytes": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "If LEFT<0 then False": GoSub AO
A$ = "CLR": B$ = ",S": C$ = "ext=0 for unsigned RIGHT": GoSub AO
A$ = "CMPD": B$ = ",S": C$ = "Compare LEFT vs RIGHT as unsigned": GoSub AO
A$ = "BHS": B$ = "@True": C$ = "If LEFT >= RIGHT keep True": GoSub AO
Z$ = "@False": A$ = "LDU": B$ = "#$0000": C$ = "Set False": GoSub AO
Z$ = "@True": A$ = "STU": B$ = ",S+": C$ = "Store result, move stack": GoSub AO
GoSub AO
Return
GreaterOrEqualLU2RS1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S+": C$ = "X= unsigned 16-bit, move the stack": GoSub AO
A$ = "LDB": B$ = "1,S": C$ = "Get the right 8 bit value": GoSub AO
A$ = "BMI": B$ = "@True": GoSub AO
A$ = "SEX": C$ = "D = B": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save the as right 16 bit value": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare the right 16 bit value to the left, move the stack": GoSub AO
A$ = "BHS": B$ = "@True": C$ = "Skip if GreaterOrEqual": GoSub AO
Z$ = "@False"
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "@True"
A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
GreaterOrEqualLU2RU1:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S+": C$ = "D = Left value, move the stack": GoSub AO
A$ = "CLR": B$ = ",S": C$ = "Clear MSB": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare the left 16 bit value to the right": GoSub AO
A$ = "BHS": B$ = ">": C$ = "Skip if GreaterOrEqual": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
GreaterOrEqualSigned2Byte:
A$ = "LDU": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S++": C$ = "D = Left 16 bit value1, move the stack": GoSub AO
A$ = "CMPX": B$ = ",S": C$ = "Compare with right 16 bit value2, move the stack": GoSub AO
A$ = "BGE": B$ = ">": C$ = "Skip if GreaterOrEqual": GoSub AO
A$ = "LDU": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STU": B$ = ",S+": C$ = "Save U and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
GreaterOrEqualUnSigned2Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S++": C$ = "D = Left 16 bit value1, move the stack": GoSub AO
A$ = "CMPX": B$ = ",S+": C$ = "Compare with right 16 bit value2, move the stack": GoSub AO
A$ = "BHS": B$ = ">": C$ = "Skip if GreaterOrEqual": GoSub AO
A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return
' Both are 2 bytes
GreaterOrEqualLURS2Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "2,S": C$ = "Right value2": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Skip if it's a negative": GoSub AO
GoTo GreaterOrEqual2

' Both are 2 bytes
GreaterOrEqualLSRU2Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Left is signed is 16 bits": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Skip if it's ponnegative": GoSub AO

GreaterOrEqual2:
A$ = "LDX": B$ = ",S": C$ = "Left value1": GoSub AO
A$ = "CMPX": B$ = "2,S": C$ = "Compare with left 16 bit value2, move the stack": GoSub AO
A$ = "BHS": B$ = "@True": C$ = "Skip if GreaterOrEqual": GoSub AO
Z$ = "@False": GoSub AO
A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "3,S": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
' Both are 4 bytes
GreaterOrEqualSigned4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "CMPX": B$ = "4,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BGT": B$ = "@True": C$ = "If GreaterOrEqual, Exit with True": GoSub AO
A$ = "BLT": B$ = "@False": C$ = "If LowerThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "6,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BHS": B$ = "@True": C$ = "Skip if GreaterOrEqual": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "7,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are 4 bytes
GreaterOrEqualUnSigned4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
GoTo GreaterOrEqual4

' Both are 4 bytes
GreaterOrEqualLURS4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "4,S": C$ = "Get the right Word 32 bit value": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Save True": GoSub AO
GoTo GreaterOrEqual4

' Both are 4 bytes
GreaterOrEqualLSRU4Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Save False": GoSub AO

GreaterOrEqual4:
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 32 bit value": GoSub AO
A$ = "CMPX": B$ = "4,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterOrEqual, Exit with True": GoSub AO
A$ = "BLO": B$ = "@False": C$ = "If LessThan, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left LSWord 32 bit value": GoSub AO
A$ = "CMPX": B$ = "6,S": C$ = "Compare with right Word 32 bit value": GoSub AO
A$ = "BHS": B$ = "@True": C$ = "Skip if GreaterOrEqual": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "7,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return
' Both are 8 bytes
GreaterOrEqualSigned8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "8,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BGT": B$ = "@True": C$ = "If GreaterOrEqual, Exit with True": GoSub AO
A$ = "BLT": B$ = "@False": C$ = "If LessThan or Equal, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "10,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterOrEqual, Exit with True": GoSub AO
A$ = "BLO": B$ = "@False": C$ = "If LessThan or Same, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "4,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "12,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterOrEqual, Exit with True": GoSub AO
A$ = "BLO": B$ = "@False": C$ = "If LessThan or Same, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "6,S": C$ = "Get the left LSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "14,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHS": B$ = "@True": C$ = "Skip if GreaterOrEqual": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "15,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are 8 bytes
GreaterOrEqualUnSigned8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
GoTo GreaterOrEqual8

' Both are 8 bytes
GreaterOrEqualLURS8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = "8,S": C$ = "Get the right Word 64 bit value": GoSub AO
A$ = "BMI": B$ = "@True": C$ = "Save True": GoSub AO
GoTo GreaterOrEqual8

' Both are 8 bytes
GreaterOrEqualLSRU8Byte:
A$ = "LDA": B$ = "#$FF": C$ = "Default is True": GoSub AO
A$ = "LDB": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "BMI": B$ = "@False": C$ = "Save False": GoSub AO

GreaterOrEqual8:
A$ = "LDX": B$ = ",S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "8,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterOrEqual, Exit with True": GoSub AO
A$ = "BLO": B$ = "@False": C$ = "If LessThan or Same, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "2,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "10,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterOrEqual, Exit with True": GoSub AO
A$ = "BLO": B$ = "@False": C$ = "If LessThan or Same, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "4,S": C$ = "Get the left Word 64 bit value": GoSub AO
A$ = "CMPX": B$ = "12,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHI": B$ = "@True": C$ = "If GreaterOrEqual, Exit with True": GoSub AO
A$ = "BLO": B$ = "@False": C$ = "If LessThan or Same, Exit with False": GoSub AO
' Otherwise the Word is Equal, check the next Word
A$ = "LDX": B$ = "6,S": C$ = "Get the left LSWord 64 bit value": GoSub AO
A$ = "CMPX": B$ = "14,S": C$ = "Compare with right Word 64 bit value": GoSub AO
A$ = "BHS": B$ = "@True": C$ = "Skip if GreaterOrEqual": GoSub AO
Z$ = "@False": A$ = "CLRA": C$ = "Set as False": GoSub AO
Z$ = "@True": A$ = "LEAS": B$ = "15,S": C$ = "Move the stack forward": GoSub AO
A$ = "STA": B$ = ",S": C$ = "Save A and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
GoSub AO
Return

' Both are FP 3 bytes in FFP format
GreaterOrEqualSameFFP:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "FFP_CMP_Stack": C$ = "Compare FFP Value1 @ ,S with Value 2 @ 3,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BLE": B$ = ">": C$ = "Skip if LessOrEqual": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "4,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return

' Both are FP 10 bytes
GreaterOrEqualSameFP8:
A$ = "LDX": B$ = "#$FFFF": C$ = "Default is True": GoSub AO
A$ = "JSR": B$ = "Double_CMP_Stack": C$ = "Compare Double Value1 @ ,S with Value 2 @ 10,S sets the 6809 flags Z, N, and C": GoSub AO
A$ = "BLE": B$ = ">": C$ = "Skip if LessOrEqual": GoSub AO
A$ = "LDX": B$ = "#$0000": C$ = "Set as False": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "18,S": C$ = "Move the stack forward": GoSub AO
A$ = "STX": B$ = ",S+": C$ = "Save X and move the stack forward, we only need to save the result as an 8 bit value": GoSub AO
Return

