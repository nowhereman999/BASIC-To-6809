' Start writing to the .asm file
Open OutName$ For Append As #1

' Main process loop

' Tokens for variables types and Commands
' F0 = Numeric Array Variable
' F1 = String Array Variable
' F2 = Regular Numeric Variable
' F3 = Regular String Variable
' F5 = + EOL($0D) or + Colon($3A)
' FC = Operator Command
' FD = String Command
' FE = Numeric Command
' FF = General Command
x = 0
vOld = 0
DoAnotherLine:
If Array(x) = TK_SpecialChar Then
    x = x + 2 ' Skip past Colon or EOL
End If
If vOld <> Asc(":") Then
    ' We are still on the same line, don't check for a label or line number
    v = Array(x): x = x + 1
Else
    v = 0
End If
While x < Filesize
    ' Do if we didn't just process a colon otherwise we're still on the same line so don't look for a label or line number
    ' Every Tokenized BASIC line starts with a byte that is the length of the Line number/Label
    ' If it's zero there is no line number or label on this line
    OldLineLabel$ = linelabel$
    linelabel$ = ""
    If v = 0 Then
        linelabel$ = OldLineLabel$ + "b"
        GoTo SkipLabel ' Skip getting a line number or label from lines that don't have them
    End If
    For L = 1 To v
        v = Array(x): x = x + 1
        linelabel$ = linelabel$ + Chr$(v)
    Next L
    If Verbose > 1 And linelabel$ <> "" Then Print "Working on Line: "; linelabel$
    Print #1, "_L"; linelabel$
    SkipLabel:
    ' Decode line so we can print it as normal in the .asm file
    C$ = ""
    Start = x ' Save where we are
    v = Array(x): x = x + 1
    If v = TK_SpecialChar And Array(x) = TK_EOL Then vOld = TK_EOL: v = Array(x): x = x + 1: GoTo DoAnotherLine
    Do Until v = TK_SpecialChar And (Array(x) = TK_EOL Or Array(x) = TK_Colon) ' Is it the end of a line? or colon?
        If v >= &HF0 Then
            Lastv = v
            GoSub DecodeToken ' return with decoded command/variable in Temp$
            C$ = C$ + Temp$
            If Lastv = TK_GeneralCommand Then C$ = C$ + " " ' Add a space after a general command
            v = 0
        Else
            If v < 32 Then v = 32 ' If unprintable ascii code then print a space
            C$ = C$ + Chr$(v)
        End If
        v = Array(x): x = x + 1
    Loop
    v = Array(x): x = x + 1
    vOld = v ' Save it as we might have reached a colon
    ' Print the line we are working on to the .asm file
    If C$ <> "" And C$ <> "ELSE " Then Print #1, "; "; C$: C$ = ""
    x = Start ' Restore where to start (new line or after a colon)
    'Check if this line starts with a REM or '

    'Check for REM or '
    If Array(x) = TK_GeneralCommand Then
        v = (Array(x + 1)) * 256 + Array(x + 2)
        If v = REM_CMD Or v = REM_Apostraphe_CMD Then
            ' this line starts with a REM, handle it
            x = x + 3
            GoSub DoREM ' Go handle a new line that starts with a REM or '
            GoTo DoAnotherLine
        End If
    End If
    ' Check for a REMarks on the rest of this line, and modify line so the REMarks are skipped

    RemStart = 0
    Check1 = REM_CMD \ 256: Check2 = REM_CMD And 255
    Check3 = REM_Apostraphe_CMD \ 256: Check4 = REM_Apostraphe_CMD And 255
    GoSub GetGenExpression ' Returns with single expression in GenExpression$
    Do Until GenExpression$ = Chr$(TK_SpecialChar) + Chr$(TK_EOL) Or GenExpression$ = Chr$(TK_SpecialChar) + Chr$(TK_Colon)
        If GenExpression$ = Chr$(TK_GeneralCommand) + Chr$(Check1) + Chr$(Check2) Or GenExpression$ = Chr$(TK_GeneralCommand) + Chr$(Check3) + Chr$(Check4) Then
            ' This line has a REM, copy stuff before the REM to the end of the line and move x pointer to the start of actual commands
            RemStart = x - 3: Exit Do
        Else
            Expression$ = Expression$ + GenExpression$
        End If
        GoSub GetGenExpression ' Returns with single expression in GenExpression$
    Loop
    If RemStart > 0 Then
        Do Until Array(x) = TK_SpecialChar And Array(x + 1) = TK_EOL: x = x + 1: Loop
        ' this line has remarks to be ignored
        Endx = x
        AmountToCopy = RemStart - Start
        Difference = Endx - RemStart
        For ii = Endx - 1 To Endx - AmountToCopy Step -1
            Array(ii) = Array(ii - Difference)
        Next ii
        Start = Endx - AmountToCopy
    End If
    If Verbose > 1 Then Print "Got to line "; linelabel$
    ' Handle the actual line here:
    x = Start ' Restore where to start (new line or after a colon)
    ' Figure out what type of token we have and deal with it
    v = Array(x): x = x + 1 ' get the token
    If v < &HF0 And v > &HF3 And v <> TK_GeneralCommand Then
        Print "Error on or just after "; linelabel; " Needs either a variable or a General command, but found ";
        If v = TK_OperatorCommand Then Print "Operator Command": System
        If v = TK_StringCommand Then Print "String Command": System
        If v = TK_NumericCommand Then Print "Numeric Command": System
        Print "Bad syntax on";: GoTo FoundError
    End If
    If v = TK_GeneralCommand Then
        ' Found a general command
        v = Array(x) * 256 + Array(x + 1): x = x + 2
        If v = LET_CMD Then
            'We have the LET command, ignore this
            v = Array(x): x = x + 1 ' get the variable to handle
        Else
            If Verbose > 3 Then Print "Found a General command: "; GeneralCommands$(v)
            GoSub JumpToGeneralCommand
            GoTo DoAnotherLine ' Jump to the general command pointed at by V, Ends with a RETURN
        End If
    End If
    'Print "v="; Hex$(v)
    If v = TK_NumericArray Then
        GoSub HandleNumericArray
        GoTo DoAnotherLine
    End If
    If v = TK_StrArray Then GoSub HandleStringArray: GoTo DoAnotherLine
    If v = TK_NumericVar Then GoSub HandleNumericVariable: GoTo DoAnotherLine
    If v = TK_StringVar Then GoSub HandleStringVariable: GoTo DoAnotherLine
Wend

