' Gets the General Command number, returns with number in ii, Found=1 if found and Found=0 if not found
FindGenCommandNumber:
Found = 0
For ii = 0 To GeneralCommandsCount
    If GeneralCommands$(ii) = Check$ Then
        Found = 1
        Exit For
    End If
Next ii
Return

' Gets the Numeric Command number, returns with number in ii, Found=1 if found and Found=0 if not found
FindNumCommandNumber:
Found = 0
For ii = 0 To NumericCommandsCount
    If NumericCommands$(ii) = Check$ Then
        Found = 1
        Exit For
    End If
Next ii
Return

' Gets the Numeric Command number, returns with number in ii, Found=1 if found and Found=0 if not found
FindStrCommandNumber:
Found = 0
For ii = 0 To StringCommandsCount
    If StringCommands$(ii) = Check$ Then
        Found = 1
        Exit For
    End If
Next ii
Return

FoundError:
Print " line "; linelabel$: System

' Send assembly instructions out to .asm file
AO:
'Print z$ at the beginning of the line
If Len(Z$) < 8 Then
    Print #1, Left$(Z$ + "        ", 8); Left$(A$ + "        ", 8);
Else
    Print #1, Z$; T2$; Left$(A$ + "        ", 8);
End If
If Len(B$) > 13 Then Print #1, B$; "   "; Else Print #1, Left$(B$ + "              ", 14);
If C$ <> "" Then Print #1, "; "; C$ Else Print #1,
Z$ = "": A$ = "": B$ = "": C$ = "" 'Clear the strings so next entry won't be repeated
Return


' For testing show the length and bytes in the string Show$, IF input=1 then system
show:
Print "Working on line "; linelabel$
Print "Length of "; show$; " is"; Len(show$)
For ii = 1 To Len(show$)
    vi = Asc(Mid$(show$, ii, 1))
    Print ii, Hex$(vi); " ";
    Select Case vi
        Case TK_NumericArray
            Print "TK_NumericArray"
        Case TK_StrArray
            Print "TK_StrArray"
        Case TK_NumericVar
            Print "TK_NumericVar"
        Case TK_StringVar
            Print "TK_StringVar"
        Case TK_SpecialChar
            Print "TK_SpecialChar"
        Case TK_EOL
            Print "TK_EOL"
        Case TK_Quote
            Print "TK_Quote"
        Case TK_Comma
            Print "TK_Comma"
        Case TK_Colon
            Print "TK_Colon"
        Case TK_SemiColon
            Print "TK_SemiColon"
        Case TK_DEFFunction
            Print "TK_DEFFunction"
        Case TK_OperatorCommand
            Print "TK_OperatorCommand"
        Case TK_StringCommand
            Print "TK_StringCommand"
        Case TK_NumericCommand
            Print "TK_NumericCommand"
        Case TK_GeneralCommand
            Print "TK_GeneralCommand"
        Case Else
            Print Chr$(vi)
    End Select
Next ii
SHow1: Input q$: If q$ = "" Then GoTo SHow1
If q$ = "q" Then System
Return

ConsumeCommentsAndEOL:
If v = TK_EOL Or v = TK_Colon Then Return
Do Until v = TK_SpecialChar And Array(x) = TK_EOL 'consume any comments and the EOL
    v = Array(x): x = x + 1
Loop
v = Array(x): x = x + 1
Return

SkipUntilEOLColon:
If v = TK_EOL Or v = TK_Colon Then Return
Do Until v = TK_SpecialChar And (Array(x) = TK_EOL Or Array(x) = TK_Colon) ' skip until we find an EOL or a Colon
    v = Array(x): x = x + 1
Loop
v = Array(x): x = x + 1
Return

SkipToEOLColon:
Do Until Array(x) = TK_SpecialChar And ((Array(x + 1) = TK_EOL) Or (Array(x + 1) = TK_Colon))
    x = x + 1
Loop
x = x + 2
Return

'Convert number in Num to a string without spaces as Num$
NumAsString:
If Num = 0 Then
    Num$ = "0"
Else
    If Num > 0 Then
        'Postive value remove the first space in the string
        Num$ = Right$(Str$(Num), Len(Str$(Num)) - 1)
    Else
        'Negative value we keep the minus sign
        Num$ = Str$(Num)
    End If
End If
Return

CheckForManualType:
Expression$ = ""
While Array(x) <> &HF5 And Array(x + 1) <> &H0D And Array(x + 1) <> &H3A
    Expression$ = Expression$ + Chr$(Array(x)): x = x + 1
Wend
p = Len(Expression$)
If p > 0 Then
    GoSub CheckForSpecialChar 'Return with special character number in ManualType, or if not found then ManualType=0
End If
Return

' Check for special character next
' Return with special character number in ManualType, or if not found then ManualType=0
' If variable Temp$ ends with special tokens which temp change their Type, we must ignore them
CheckForSpecialChar:
' Check for a single special symbol at the end of the variable
If p + 3 <= Len(Expression$) Then
    Select Case Mid$(Expression$, p, 4)
        Case Chr$(&HF5) + "#" + Chr$(&HF5) + "#" '##
            ManualType = NT_Double: p = p + 2: Return
    End Select
End If
If p + 2 <= Len(Expression$) Then
    Select Case Mid$(Expression$, p, 3)
        Case "~%%"
            ManualType = NT_UByte: p = p + 3: Return
        Case "~&&"
            ManualType = NT_UInt64: p = p + 3: Return
    End Select
End If
If p + 1 <= Len(Expression$) Then
    Select Case Mid$(Expression$, p, 2)
        Case "`n"
            ManualType = NT_Byte: p = p + 2: Return
        Case "~`"
            ManualType = NT_UBit: p = p + 2: Return
        Case "%%"
            ManualType = NT_Byte: p = p + 2: Return
        Case "~%"
            ManualType = NT_UInt16: p = p + 2: Return
        Case "~&"
            ManualType = NT_UInt32: p = p + 2: Return
        Case "&&"
            ManualType = NT_Int64: p = p + 2: Return
        Case Chr$(&HF5) + "#"
            ManualType = NT_Double: p = p + 2: Return
    End Select
End If
If p <= Len(Expression$) Then
    Select Case Mid$(Expression$, p, 1)
        Case "`"
            ManualType = NT_Bit: p = p + 1: Return
        Case "%"
            ManualType = NT_Int16: p = p + 1: Return
        Case "&"
            ManualType = NT_Int32: p = p + 1: Return
        Case "!"
            ManualType = NT_Single: p = p + 1: Return
        Case "#"
            ManualType = NT_Double: p = p + 1: Return
        Case "~"
            ManualType = NT_ShortFloat: p = p + 1: Return
    End Select
End If
ManualType = 0
Return
