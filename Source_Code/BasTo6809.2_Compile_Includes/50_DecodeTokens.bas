
' Return with decoded command/variable in Temp$
' Tokens for variables type:
' &HF0 = Numeric Arrays           (4 Bytes)
' &HF1 = String Arrays            (3 Bytes)
' &HF2 = Regular Numeric Variable (3 Bytes)
' &HF3 = Regular String Variable  (3 Bytes)
' TK_SpecialChar = Special characters like a EOL, colon, comma, semi colon, quote, brackets    (2 Bytes)

' &HFB = DEF FN Function
' &HFC = Operator Command (2 Bytes)
' &HFD = String Command  (3 Bytes)
' &HFE = Numeric Command (3 Bytes)
' &HFF = General Command (3 Bytes)

DecodeToken:
Temp$ = ""
If v = TK_NumericArray Then 'Numeric Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = NumericArrayVariables$(v)
    T = Array(x): x = x + 1 'T= Type of numeric elements in the array
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = TK_StrArray Then 'String Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = StringArrayVariables$(v) + "$" ' add the $ back in to show it's a string
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = TK_NumericVar Then 'Regular Numeric Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = NumericVariable$(v): Return
    T = Array(x): x = x + 1 'T= Type of numeric variable
End If
If v = TK_StringVar Then 'Regular String Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = StringVariable$(v) + "$" ' add the $ back in to show it's a string
    Return
End If
If v = TK_SpecialChar Then ' Special Characters
    v = Array(x): x = x + 1
    If v = TK_Quote Then
        'We found a quote, copy everything inside the quotes to Temp$
        While v <> TK_SpecialChar ' keep copying until we get an end quote
            Temp$ = Temp$ + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        v = Array(x): x = x + 1
    End If
    Temp$ = Temp$ + Chr$(v)
    Return
End If
If v = TK_StringVar Then ' Pointer for the label of a DEF FN command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = DefLabel$(v): Return
    Return
End If
If v = TK_OperatorCommand Then 'Operator Command
    v = Array(x): x = x + 1
    Temp$ = OperatorCommands$(v): Return
End If
If v = TK_StringCommand Then 'String Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = StringCommands$(v): Return
End If
If v = TK_NumericCommand Then 'Numeric Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = NumericCommands$(v): Return
End If
If v = TK_GeneralCommand Then 'General Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = GeneralCommands$(v)
    If Temp$ = "'" Or Temp$ = "REM" Then
        Temp$ = Temp$ + " "
        Do Until v = TK_EOL And Array(x - 2) = TK_SpecialChar ' keep copying until we get an EOL
            GoSub DecodeInREMark
            Temp$ = Temp$ + Temp1$
        Loop
        Temp$ = Left$(Temp$, Len(Temp$) - 1) 'remove last $0D
        x = x - 2
    End If
    Return
End If
Print " Error decoding line, V= $"; Hex$(v), Hex$(x): System


DecodeInREMark:
Temp1$ = ""
v = Array(x): x = x + 1
If v = TK_NumericArray Then 'Numeric Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = NumericArrayVariables$(v)
    T = Array(x): x = x + 1 'T = Type of numberic elements in the array
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = TK_StrArray Then 'String Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = StringArrayVariables$(v) + "$" ' add the $ back in to show it's a string
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = TK_NumericVar Then 'Regular Numeric Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = NumericVariable$(v): Return
    T = Array(x): x = x + 1 'T = Type of numberic
End If
If v = TK_StringVar Then 'Regular String Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = StringVariable$(v) + "$" ' add the $ back in to show it's a string
    Return
End If
If v = TK_SpecialChar Then ' Special Characters
    v = Array(x): x = x + 1
    If v = TK_Quote Then
        'We found a quote, copy everything inside the quotes to Temp$
        While v <> TK_SpecialChar ' keep copying until we get an end quote
            Temp1$ = Temp1$ + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        v = Array(x): x = x + 1
    End If
    Temp1$ = Temp1$ + Chr$(v)
    Return
End If
If v = TK_StringVar Then ' Pointer for the label of a DEF FN command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = DefLabel$(v): Return
    Return
End If
If v = TK_OperatorCommand Then 'Operator Command
    v = Array(x): x = x + 1
    Temp1$ = OperatorCommands$(v): Return
End If
If v = TK_StringCommand Then 'String Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = StringCommands$(v): Return
End If
If v = TK_NumericCommand Then 'Numeric Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = NumericCommands$(v): Return
End If
If v = TK_GeneralCommand Then 'General Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = GeneralCommands$(v) + " "
    Return
End If
Temp1$ = Temp1$ + Chr$(v)
Return


