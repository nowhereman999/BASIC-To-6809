$ScreenHide
$Console
_Dest _Console
Verbose = 0

Dim Array(270000) As _Unsigned _Byte
Dim INArray(270000) As _Unsigned _Byte
Dim DataArray(270000) As _Unsigned _Byte
Dim DataArrayCount As Integer

Dim LabelName$(100000)
Dim NumericVariable$(100000)
Dim NumericVariableCount As Integer
Dim StringVariable$(100000)
Dim StringVariableCounter As Integer
Dim NumericArrayVariables$(100000), NumericArrayDimensions(100000) As Integer, NumericArrayDimensionsVal$(100000)
Dim StringArrayVariables$(100000), StringArrayDimensions(100000) As Integer, StringArrayDimensionsVal$(100000)

Dim GeneralCommands$(2000)
Dim GeneralCommandsCount As Integer
Dim NumericCommands$(2000)
Dim NumericCommandsCount As Integer
Dim StringCommands$(2000)
Dim StringCommandsCount As Integer
Dim OperatorCommands$(2000)
Dim OperatorCommandsCount As Integer

Dim GeneralCommandsFound$(2000)
Dim GeneralCommandsFoundCount As Integer
Dim NumericCommandsFound$(2000)
Dim NumericCommandsFoundCount As Integer
Dim StringCommandsFound$(2000)
Dim StringCommandsFoundCount As Integer

Dim IncludeList$(10000)

Dim DefLabel$(10000)
Dim DefVar(1000) As Integer
DefLabelCount = 0
DefVarCount = 0

Dim Signed16bit As Integer

Open "Basic_Commands/BasTo6809_CommandsGeneral.dat" For Input As #1
GeneralCommandsCount = 0
While EOF(1) = 0
    Line Input #1, i$
    GeneralCommandsCount = GeneralCommandsCount + 1
    GeneralCommands$(GeneralCommandsCount) = i$
Wend
Close #1
Open "Basic_Commands/BasTo6809_CommandsNumeric.dat" For Input As #1
NumericCommandsCount = 0
While EOF(1) = 0
    Line Input #1, i$
    NumericCommandsCount = NumericCommandsCount + 1
    NumericCommands$(NumericCommandsCount) = i$
Wend
Close #1
Open "Basic_Commands/BasTo6809_CommandsString.dat" For Input As #1
StringCommandsCount = 0
While EOF(1) = 0
    Line Input #1, i$
    StringCommandsCount = StringCommandsCount + 1
    StringCommands$(StringCommandsCount) = i$
Wend
Close #1
Open "Basic_Commands/BasTo6809_CommandsOperators.dat" For Input As #1
OperatorCommandsCount = 0
While EOF(1) = 0
    Line Input #1, i$
    i$ = Right$(i$, Len(i$) - 1)
    i$ = Left$(i$, InStr(i$, ",") - 2)
    OperatorCommandsCount = OperatorCommandsCount + 1
    OperatorCommands$(OperatorCommandsCount) = i$
Wend
Close #1

Check$ = "IF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_IF = ii
Check$ = "THEN": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_THEN = ii
Check$ = "ELSE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_ELSE = ii
Check$ = "GOTO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_GOTO = ii
Check$ = "END": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_END = ii
Check$ = "REM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_REM = ii
Check$ = "'": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_APOSTROPHE = ii
Check$ = "DIM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_DIM = ii
Check$ = "DATA": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_DATA = ii
Check$ = "REM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_REM = ii
Check$ = "'": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_REMApostrophe = ii

' Handle command line options
FI = 0
count = _CommandCount
If count = 0 Then
    Print "Compiler has no options given to it"
    System
End If
nt = 0: newp = 0: endp = 0: BranchCheck = 0: StringArraySize = 255
Optimize = 2 ' Default to optimize level 2
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 2)) = "-c" Then BASICMode = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-s" Then StringArraySize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-o" Then Optimize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-b" Then BranchCheck = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-v" Then Verbose = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-p" Then ProgramStart$ = Right$(N$, Len(N$) - 2): GoTo CheckNextCMDOption
    ' check if we got a file name yet if so then the next filename will be output
    OutName$ = N$
    CheckNextCMDOption:
Next check

' Fill the Array() with the preformatted BASIC text file
Fname$ = "BASIC_Text.bas"
Open Fname$ For Append As #1
length = LOF(1)
Close #1
If length < 1 Then Print "Error file: "; Fname$; " is 0 bytes. Or doesn't exist.": Kill Fname$: End
If Verbose > 0 Then Print "Length of Input file in bytes:"; length
Open Fname$ For Binary As #1
Get #1, , Array()
Close #1
Array(length) = &H0D: length = length + 1 ' add one last EOL

' Get the line Labels first so we can recognize them if there is a forward reference to a Label we haven't come across yet
NumericVariableCount = 0 ' Numeric variable name count
NumericVariable$(NumericVariableCount) = "Timer" ' Make the first variable the TIMER
NumericVariableCount = NumericVariableCount + 1 ' Numeric variable name count

x = 0
INx = 0
lc = 0
LineCount = 0
StringVariableCounter = 0 ' String variable name count
CommandsUsedCounter = 0 ' Counter for unique commmands used
NumArrayVarsUsedCounter = 0 ' Counter for number of NumericArrays used
StringArrayVarsUsedCounter = 0 ' Counter for number of String Array Variables used

Check$ = "REM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_REM = ii
While x < length - 1 ' Loop until we've processed the entire BASIC program
    ' Start of new line
    ' Searching for Inline assembly -  read a full line
    y = x
    Temp$ = ""
    v = Array(x): x = x + 1
    While x <= length - 1 And v <> &H0D
        Temp$ = Temp$ + Chr$(v)
        v = Array(x): x = x + 1
    Wend
    P = InStr(Temp$, "ADDASSEM")
    If P > 0 Then
        ' We found the start of some inline assembly
        ' Ignore any labels found here...
        'copy lines unaltered until we get a ENDASSEM
        REM_AddCodeAlpha0:
        Temp$ = ""
        v = Array(x): x = x + 1
        While v <> &H0D
            Temp$ = Temp$ + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        Temp$ = Temp$ + Chr$(&H0D)
        ' Check if this line is the last
        P = InStr(Temp$, "ENDASSEM")
        If P = 0 Then
            For ii = 1 To Len(Temp$)
                '  INArray(INx) = Asc(Mid$(Temp$, ii, 1)): INx = INx + 1
            Next ii
            GoTo REM_AddCodeAlpha0
        End If
    Else
        x = y
    End If
    CheckLineSpaces0:
    v = Array(x): x = x + 1
    If v = &H20 Then GoTo CheckLineSpaces0 ' Skip spaces at the beginning of a line
    If v = &H0D Or v = &H0A Then GoTo GotLabel ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
    Tokenized$ = ""
    CurrentLine$ = ""
    'Figure out if we have a line number or a label:
    If v >= Asc("0") And v <= Asc("9") Then ' Check if line starts with a number
        'Does start with a number
        LineCount = LineCount + 1
        While v >= Asc("0") And v <= Asc("9") ' is it a number?
            LabelName$(LineCount) = LabelName$(LineCount) + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        If Verbose > 0 Then Print "Scanning line "; LabelName$(LineCount)
        CurrentLine$ = LabelName$(LineCount)
        If IsNumber(LabelName$(LineCount)) = 0 Then Print "Error: There's something wrong with the Line number or Label "; LabelName$(LineCount): System
        If v = &H0D Then
            ' this is a number line only
            GoTo GotLabel ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
        End If
    Else
        'Not a line number, figure out if this line starts with a BASIC command
        T = Asc(UCase$(Chr$(v)))
        If T >= Asc("A") And T <= Asc("Z") Then
            'Maybe found a label
            Check$ = ""
            y = x - 1
            While v <> Asc(":") And v <> &H0D And v <> &H0A And v <> Asc(" ")
                Check$ = Check$ + Chr$(v)
                v = Array(x): x = x + 1
            Wend
            CheckLC$ = Check$
            If v = Asc(":") Then
                'Could be a label or a general command with a colon after it
                ' Check for a General command
                Found = 0
                For c = 1 To GeneralCommandsCount
                    Temp$ = UCase$(GeneralCommands$(c))
                    Check$ = UCase$(Check$)
                    If Temp$ = Check$ Then
                        'Found a General Command
                        Found = 1: Exit For
                    End If
                Next c
                If Found = 0 Then
                    ' It is a label
                    LineCount = LineCount + 1
                    LabelName$(LineCount) = CheckLC$
                    CurrentLine$ = LabelName$(LineCount)
                    If Verbose > 0 Then Print "Scanning line "; LabelName$(LineCount); ":"
                    Tokenized$ = ""
                    GoTo GotLabel
                End If
            End If
            x = y

        End If
    End If
    v = Array(x): x = x + 1
    While v <> &H0D
        v = Array(x): x = x + 1
    Wend
    GotLabel:
Wend

' Get commands and variables used in program
' Tokenize the text version of the BASIC program to make it easier to handle parsing expressions
If Verbose > 0 Then Print "Doing Pass 1 - Finding commands and variables used"
x = 0
INx = 0
lc = 0
LineCountB = 0
If Verbose > 1 Then Print "Done scanning for labels"; LineCount
While x < length - 1 ' Loop until we've processed the entire BASIC program
    ' Start of new line
    ' Searching for Inline assembly -  read a full line
    y = x
    Temp$ = ""
    v = Array(x): x = x + 1
    While x <= length - 1 And v <> &H0D
        Temp$ = Temp$ + Chr$(v)
        v = Array(x): x = x + 1
    Wend
    P = InStr(Temp$, "ADDASSEM")
    If P > 0 Then
        ' We found the start of some inline assembly
        ' Copy the line number or label
        '    Tokenized$ = Chr$(Len(CurrentLine$)) + CurrentLine$ + Tokenized$ + Chr$(&HF5) + Chr$(&H0D) ' Line ends with $F50D
        CurrentLine$ = ""
        If Asc(Left$(Temp$, 1)) >= &H30 And Asc(Left$(Temp$, 1)) <= &H39 Then
            For ii = 1 To Len(Temp$)
                If Mid$(Temp$, ii, 1) = Chr$(&H20) Then Exit For
                CurrentLine$ = CurrentLine$ + Mid$(Temp$, ii, 1)
            Next ii
        End If
        Num = C_REM: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
        Temp$ = Chr$(Len(CurrentLine$)) + CurrentLine$ + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB) + " ADDASSEM:" + Chr$(&HF5) + Chr$(&H0D)
        For ii = 1 To Len(Temp$)
            INArray(INx) = Asc(Mid$(Temp$, ii, 1)): INx = INx + 1
        Next ii
        ' Copy lines unaltered until we get a ENDASSEM
        REM_AddCode0:
        Temp$ = ""
        v = Array(x): x = x + 1
        While v <> &H0D
            Temp$ = Temp$ + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        Temp$ = Temp$ + Chr$(&H0D)
        ' Check if this line is the last
        P = InStr(Temp$, "ENDASSEM")
        If P = 0 Then
            For ii = 1 To Len(Temp$)
                INArray(INx) = Asc(Mid$(Temp$, ii, 1)): INx = INx + 1
            Next ii
            GoTo REM_AddCode0
        End If
        Num = C_REM: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
        Temp$ = Chr$(0) + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB) + " ENDASSEM:" + Chr$(&HF5) + Chr$(&H0D)
        For ii = 1 To Len(Temp$)
            INArray(INx) = Asc(Mid$(Temp$, ii, 1)): INx = INx + 1
        Next ii
        GoTo ScanNextLine ' Skip to the bottom
    Else
        x = y
    End If
    v = Array(x): x = x + 1
    If v = &H20 Then GoTo ScanNextLine ' Skip spaces at the beginning of a line
    If v = &H0D Then GoTo ScanNextLine ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
    Tokenized$ = ""
    CurrentLine$ = ""
    'Figure out if we have a line number or a label:
    If v >= Asc("0") And v <= Asc("9") Then ' Check if line starts with a number
        'Does start with a number
        LineCountB = LineCountB + 1
        While v >= Asc("0") And v <= Asc("9") ' is it a number?
            '  LabelName$(LineCountB) = LabelName$(LineCountB) + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        If Verbose > 0 Then Print "Scanning line "; LabelName$(LineCount)
        CurrentLine$ = LabelName$(LineCountB)
        If IsNumber(LabelName$(LineCountB)) = 0 Then
            Print "There's something wrong with the Line number or Label "; LabelName$(LineCountB): System
        End If
        If v = &H0D Then
            ' this is a number line only
            GoTo ScanNextLine ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
        End If
    Else
        'Not a line number, figure out if this line starts with a BASIC command
        T = Asc(UCase$(Chr$(v)))
        If T >= Asc("A") And T <= Asc("Z") Then
            'Maybe found a label
            Check$ = ""
            Start = x - 1
            While v <> Asc(":") And v <> &H0D And v <> Asc(" ")
                Check$ = Check$ + Chr$(v)
                v = Array(x): x = x + 1
            Wend
            If v = Asc(":") Then
                'Could be a label or a general command with a colon after it
                ' Check for a General command
                Found = 0
                For c = 1 To GeneralCommandsCount
                    Temp$ = UCase$(GeneralCommands$(c))
                    Check$ = UCase$(Check$)
                    If Temp$ = Check$ Then
                        'Found a General Command
                        Found = 1
                    End If
                Next c
                If Found = 0 Then
                    ' It is a label
                    LineCountB = LineCountB + 1
                    CurrentLine$ = LabelName$(LineCountB)
                    If Verbose > 0 Then Print "Scanning line "; LabelName$(LineCountB); ":"
                    Tokenized$ = ""
                    GoTo LabelOnlyLine
                End If
            End If
            x = Start
            v = Array(x): x = x + 1
        End If
    End If
    ' Get the first argument/command
    ' No line number or label
    GetFirstArg:
    Expression$ = ""
    ColonCount = 0
    If v = &H20 Then v = Array(x): x = x + 1 ' skip past the first space on the line
    'Get the rest of this line as it is
    While v <> &H0D And x < length
        If v = &H22 Then ' is it a quote"
            Expression$ = Expression$ + Chr$(v)
            v = Array(x): x = x + 1
            ' Yes deal with text in quotes, copy all until we get an end quote or RETURN
            While v <> &H22 And v <> &H0D
                Expression$ = Expression$ + Chr$(v)
                v = Array(x): x = x + 1
            Wend
            If v = &H0D Then
                ' we got the end of the line without an end quote, let's add one
                Expression$ = Expression$ + Chr$(&H22)
                GoTo DoneGetFirstArg
            End If
            If v = &H22 Then ' did we get the end quote?
                'Yes got the end quote
                Expression$ = Expression$ + Chr$(v)
                GoTo GetMoreArgs
            End If
        Else
            ' Not inside a quote
            If v = Asc(":") Then
                Expression$ = Expression$ + Chr$(&HF5) ' flag colons as special characters $F53A
                While Array(x) = Asc(" ")
                    x = x + 1 ' skip the spaces after a ":"
                Wend
            End If
            If v = Asc("?") Then ' Change ? to a PRINT command
                Expression$ = Expression$ + "PRINT "
            Else
                Expression$ = Expression$ + Chr$(v)
            End If
        End If
        GetMoreArgs:
        v = Array(x): x = x + 1
    Wend
    DoneGetFirstArg:
    If InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") > 0 Then
        ' Fix THEN :ELSE to be THEN ELSE
        While InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") > 0
            Expression$ = Left$(Expression$, InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") + 4) + Right$(Expression$, Len(Expression$) - InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") - 6)
        Wend
    End If
    GoSub TokenizeExpression ' Go tokenize Expression$
    LabelOnlyLine:
    Tokenized$ = Chr$(Len(CurrentLine$)) + CurrentLine$ + Tokenized$ + Chr$(&HF5) + Chr$(&H0D) ' Line ends with $F50D
    For ii = 1 To Len(Tokenized$)
        INArray(INx) = Asc(Mid$(Tokenized$, ii, 1)): INx = INx + 1
    Next ii
    ScanNextLine:
Wend

If Verbose > 0 Then
    ' Print the commands used and variables used by this BASIC program
    Print "General Commands Used:"
    For ii = 0 To GeneralCommandsFoundCount - 1
        Print GeneralCommandsFound$(ii)
    Next ii
    Print "Numeric Commands Used:"
    For ii = 0 To NumericCommandsFoundCount - 1
        Print NumericCommandsFound$(ii)
    Next ii
    Print "String Commands Used:"
    For ii = 0 To StringCommandsFoundCount - 1
        Print StringCommandsFound$(ii)
    Next ii
    Print "Numeric Variables Used:"
    For ii = 0 To NumericVariableCount - 1
        Print NumericVariable$(ii)
    Next ii
    Print "String Variables Used:"
    For ii = 0 To StringVariableCounter - 1
        Print StringVariable$(ii)
    Next ii
    Print "Numeric Arrays Used:"
    For ii = 0 To NumArrayVarsUsedCounter - 1
        Print NumericArrayVariables$(ii); " which has"; NumericArrayDimensions(ii); "Dimensions"
    Next ii
    Print "String Arrays Used:"
    For ii = 0 To StringArrayVarsUsedCounter - 1
        Print StringArrayVariables$(ii); " which has"; StringArrayDimensions(ii); "Dimensions"
    Next ii
End If

' Write tokenized data to file
' Copy array to output file first byte of the array is 0
' Example: array(0),array(1),array(2),...,array(length)
filesize = INx - 1
c = 0
For Op = 0 To filesize
    Array(c) = INArray(Op): c = c + 1
Next Op

' Re-format IF statements that are only one line and don't end with an ENDIF just an EOL to end with and ENDIF (so all IF's can be handled the same)
If Verbose > 0 Then Print "Doing Pass 2 - Changing single line IF commands to IF/THEN/ELSE/END IF, multiple lines"
c = 0
x = 0
While x <= filesize
    v = Array(x): x = x + 1 ' get a byte
    INArray(c) = v: c = c + 1 'write byte to ouput array
    If v = &HFF And Array(x) * 256 + Array(x + 1) = C_IF Then
        'It is an IF command
        v = Array(x): x = x + 1 ' get the command to do
        INArray(c) = v: c = c + 1 ' write byte to ouput array
        v = Array(x): x = x + 1 ' get the command to do
        INArray(c) = v: c = c + 1 ' write byte to ouput array
        'Make sure it wasn't part of an END IF
        'END IF = FF xx xx FF xx xx F5 0D
        If x > 6 Then
            ' check for an END IF
            If Array(x - 6) = &HFF And Array(x - 5) * 256 + Array(x - 4) = C_END Then
                'It is part of an END IF
                GoTo PartOfENDIF
            End If
        End If
        'Otherwise it is a regular IF
        ' Find the THEN command for this IF
        Do Until v = &HFF And (Array(x) * 256 + Array(x + 1) = C_THEN Or Array(x) * 256 + Array(x + 1) = C_GOTO) ' If we come across a GOTO instead of a THEN, make it a THEN
            v = Array(x): x = x + 1 ' get a byte
            INArray(c) = v: c = c + 1 ' write byte to ouput array
        Loop 'loop until we find a THEN or GOTO command
        ' Just in case we found a GOTO instead of a THEN, change it to a THEN
        ' Make it a THEN even if it was a GOTO
        Num = C_THEN: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
        x = x + 2 ' skip forward past command number
        ' Print "Checking for stuff after the THEN"
        v = Array(x): x = x + 1 ' get a byte
        While v = &HF5 And Array(x) = &H3A: v = Array(x): x = x + 1: Wend ' consume any colons directly after the THEN
        If v = (&HF5 And Array(x) = &H0D) Or (v = &HFF And Array(x) * 256 + Array(x + 1) = C_REM) Or (v = &HFF And Array(x) * 256 + Array(x + 1) = C_APOSTROPHE) Then ' After THEN do we have an EOL, or REMarks?
            ' if so this is already an IF/THEN/ELSE/ELSEIF/ENDIF so don't need to change it to be a multi line IF
            INArray(c) = v: c = c + 1 ' write byte to ouput array
            If v = &HF5 And Array(x) = &H0D Then INArray(c) = &H0D: c = c + 1: x = x + 1
        Else
            ' Print "not a multi line IF"
            ' This is a one line IF/THEN/ELSE command that ends with a $F5 $0D
            ' Make it a multi line IF THEN ELSE
            ' We've copied everything upto the and including the THEN
            ' Make the byte after the THEN an EOL
            IfCounter = 1
            INArray(c) = &HF5: c = c + 1 ' Add EOL
            INArray(c) = &H0D: c = c + 1 ' Add EOL
            INArray(c) = 0: c = c + 1 ' start of next line - line label length of zero
            'Check for a number could be IF THEN 50
            FoundLineNumber:
            If v >= Asc("0") And v <= Asc("9") Then
                ' Found a line number, change it to a new line with GOTO linenumber
                INArray(c) = &HFF: c = c + 1 ' General command
                Num = C_GOTO: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
                While v >= Asc("0") And v <= Asc("9")
                    INArray(c) = v: c = c + 1 ' write line number
                    v = Array(x): x = x + 1 ' copy the line number
                Wend
                While v = &HF5 And Array(x) = &H3A: v = Array(x): x = x + 1: Wend ' consume any colons
                If v = &HF5 And Array(x) = &H0D Then INArray(c) = &HF5: c = c + 1: GoTo FixedGoto ' The &H0D will be added below
            End If
            ' Not a line number after the THEN
            x = x - 1
            Do Until v = &HF5 And Array(x) = &H0D
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 ' write byte to ouput array
                If v = &HFF Then
                    If Array(x) * 256 + Array(x + 1) = C_IF Then
                        ' Found an IF
                        IfCounter = IfCounter + 1
                        c = c - 1 ' Don't keep the &HFF it just wrote
                        INArray(c) = &HF5: c = c + 1 ' add EOL instead of the IF Command
                        INArray(c) = &H0D: c = c + 1 ' add EOL
                        INArray(c) = &H00: c = c + 1 ' line label length of zero
                        INArray(c) = &HFF: c = c + 1 ' Add the command Token
                        v = Array(x): x = x + 1 ' Get the IF Command #MSB
                        INArray(c) = v: c = c + 1 ' Write the IF Command #MSB
                        v = Array(x): x = x + 1 ' Get the IF Command #LSB
                        INArray(c) = v: c = c + 1 ' Write the IF Command #LSB
                    End If
                    If Array(x) * 256 + Array(x + 1) = C_THEN Or Array(x) * 256 + Array(x + 1) = C_ELSE Then
                        ' Found THEN or ELSE
                        c = c - 1 ' Don't keep the &HFF it just wrote
                        INArray(c) = &HF5: c = c + 1 ' add EOL
                        INArray(c) = &H0D: c = c + 1 ' add EOL
                        INArray(c) = 0: c = c + 1 ' line label length
                        INArray(c) = &HFF: c = c + 1 ' write &HFF command byte to ouput array
                        v = Array(x): x = x + 1 ' get the THEN or ELSE command # MSB
                        INArray(c) = v: c = c + 1 ' write byte to ouput array
                        v = Array(x): x = x + 1 ' get the THEN or ELSE command # LSB
                        INArray(c) = v: c = c + 1 ' write byte to ouput array
                        v = Array(x): x = x + 1 ' get the next byte
                        If v = &HF5 And Array(x) = &H3A Then
                            ' We have a colon
                            While v = &HF5 And Array(x) = &H3A: v = Array(x): x = x + 1: Wend ' consume any colons
                            x = x - 1 ' point at this byte again
                        End If
                        If v >= Asc("0") And v <= Asc("9") Then GoTo FoundLineNumber
                        INArray(c) = &HF5: c = c + 1 ' Add EOL
                        INArray(c) = &H0D: c = c + 1 ' Add EOL
                        INArray(c) = 0: c = c + 1 ' line label length of zero
                    End If
                End If
            Loop
            FixedGoto:
            v = Array(x): x = x + 1 ' get a byte the $0D
            INArray(c) = v: c = c + 1 ' write byte to ouput array
            For i = 1 To IfCounter
                'END IF = FF xx xx FF xx xx F5 0D
                INArray(c) = 0: c = c + 1 ' line label length of zero
                INArray(c) = &HFF: c = c + 1
                Num = C_END: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
                INArray(c) = &HFF: c = c + 1
                Num = C_IF: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
                INArray(c) = &HF5: c = c + 1 ' Add EOL
                INArray(c) = &H0D: c = c + 1 ' EOL
            Next i
        End If
    End If
    PartOfENDIF:
Wend

' Tokens for variables type:
' &HF0 = Numeric Arrays           (4 Bytes)
' &HF1 = String Arrays            (3 Bytes)
' &HF2 = Regular Numeric Variable (3 Bytes)
' &HF3 = Regular String Variable  (3 Bytes)
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets    (2 Bytes)

' &HFB = DEF FN Function
' &HFC = Operator Command (2 Bytes)
' &HFD = String Command  (3 Bytes)
' &HFE = Numeric Command (3 Bytes)
' &HFF = General Command (3 Bytes)

' Change Variable _Var_Timer = to command TIMER =
Check$ = "TIMER": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_TIMER = ii
CheckForTimer:
While Op <= filesize
    v = INArray(Op): Op = Op + 1
    If v < &HF0 Then GoTo CheckForTimer
    'We have a Token
    Select Case v
        Case &HF0, &HF1: ' Found a Numeric or String array
            Op = Op + 3
        Case &HF2: ' Found a numeric variable
            If INArray(Op) * 256 + INArray(Op + 1) = 0 Then
                If INArray(Op + 2) = &HFC Then
                    If INArray(Op + 3) = &H3D Then ' Check for =
                        ' Found "_Var_Timer =" as a variable
                        INArray(Op - 1) = &HFF ' Make it a General command
                        Num = C_TIMER: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        INArray(Op) = MSB: INArray(Op + 1) = LSB ' write command to ouput array
                        Op = Op + 2
                    End If
                End If
            End If
        Case &HF3: ' Found a string variable
            Op = Op + 2
        Case &HF5 ' Found a special character
            Op = Op + 1
        Case &HFB: ' Found a DEF FN Function
            Op = Op + 2
        Case &HFC: ' Found an Operator
            Op = Op + 1
        Case &HFD, &HFE, &HFF: 'Found String,Numeric or General command
            Op = Op + 2
    End Select
Wend

' Copy array INArray() to Array()
filesize = c - 1
c = 0
For Op = 0 To filesize
    Array(c) = INArray(Op): c = c + 1
Next Op

ReDim LastOutArray(filesize) As _Unsigned _Byte
c = 0
For Op = 0 To filesize
    LastOutArray(c) = Array(Op): c = c + 1
Next Op
If _FileExists("BasicTokenizedB4Pass2.bin") Then Kill "BasicTokenizedB4Pass2.bin"
If Verbose > 0 Then Print "Writing to file "; "BasicTokenizedB4Pass2.bin"
Open "BasicTokenizedB4Pass2.bin" For Binary As #1
Put #1, , LastOutArray()
Close #1

' Decided to not skip it just in case someone select the -coco option even though they truly are using -ascii
'If BASICMode = 1 Then GoTo SkipCheckingForElseIF ' CoCo BASIC won't have ELSEIF

' Change any ElseIf to ELSE/IF
c = 0
x = 0
AddENDIF = 0
ElseIfCheckPartOfENDIF:
While x <= filesize
    v = Array(x): x = x + 1 ' get a byte
    INArray(c) = v: c = c + 1 'write byte to ouput array
    If v > &HEF Then
        'We have a Token
        Select Case v
            Case &HF0, &HF1: ' Found a Numeric or String array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HF2, &HF3: ' Found a numeric or string variable
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HF5 ' Found a special character
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HFB: ' Found a DEF FN Function
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HFC: ' Found an Operator
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HFD, &HFE: 'Found String or Numeric command
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HFF: ' Found a General command
                Temp1 = Array(x): x = x + 1 ' get a byte
                INArray(c) = Temp1: c = c + 1 'write byte to ouput array
                Temp2 = Array(x): x = x + 1 ' get a byte
                INArray(c) = Temp2: c = c + 1 'write byte to ouput array
                v = Temp1 * 256 + Temp2
                If v = C_ELSE Then
                    ' Found an Else, check for IF
                    If Array(x) = &HFF And Array(x + 1) * 256 + Array(x + 2) = C_IF Then
                        ' We found an ELSE IF
                        ' Change ELSEIF to ELSE - EOL
                        INArray(c) = &HF5: c = c + 1: INArray(c) = &H0D: c = c + 1 ' EOL
                        INArray(c) = 0: c = c + 1 ' line label length of zero
                    End If
                End If
        End Select
    End If
Wend

filesize = c - 1
ReDim LastOutArray(filesize) As _Unsigned _Byte
c = 0
For Op = 0 To filesize
    Array(c) = INArray(Op)
    LastOutArray(c) = INArray(Op): c = c + 1
Next Op
If _FileExists("BasicTokenized.bin") Then Kill "BasicTokenized.bin"
If Verbose > 0 Then Print "Writing to file "; "BasicTokenized.bin"
Open "BasicTokenized.bin" For Binary As #1
Put #1, , LastOutArray()
Close #1

If Verbose > 0 Then Print "Doing Pass 3 - Figuring out Arrays sizes, within the DIM commands..."
x = 0
While x < filesize
    v = Array(x): x = x + 1 ' get the command to do
    If v = &HFF Then ' Found a command
        v = Array(x) * 256 + Array(x + 1): x = x + 2
        If v = C_DIM Then ' Is it the DIM command?
            ' Found a DIM command, go setup the array sizes
            GoSub DoDim
        End If
    End If
Wend

Open "NumericVariablesUsed.txt" For Output As #1
For i = 0 To NumericVariableCount - 1
    Print #1, NumericVariable$(i)
Next i
Close #1
Open "StringVariablesUsed.txt" For Output As #1
For i = 0 To StringVariableCounter - 1
    Print #1, StringVariable$(i)
Next i
Close #1
Open "GeneralCommandsFound.txt" For Output As #1
For i = 0 To GeneralCommandsFoundCount - 1
    Print #1, GeneralCommandsFound$(i)
Next i
Close #1
Open "StringCommandsFound.txt" For Output As #1
For i = 0 To StringCommandsFoundCount - 1
    Print #1, StringCommandsFound$(i)
Next i
Close #1
Open "NumericCommandsFound.txt" For Output As #1
For i = 0 To NumericCommandsFoundCount - 1
    Print #1, NumericCommandsFound$(i)
Next i
Close #1
Open "NumericArrayVarsUsed.txt" For Output As #1
For i = 0 To NumArrayVarsUsedCounter - 1
    Print #1, NumericArrayVariables$(i)
    Print #1, NumericArrayDimensions(i)
Next i
Close #1
Open "StringArrayVarsUsed.txt" For Output As #1
For i = 0 To StringArrayVarsUsedCounter - 1
    Print #1, StringArrayVariables$(i)
    Print #1, StringArrayDimensions(i)
Next i
Close #1
Open "DefFNUsed.txt" For Output As #1
For i = 0 To DefLabelCount - 1
    Print #1, DefLabel$(i)
Next i
Close #1
Open "DefVarUsed.txt" For Output As #1
For i = 0 To DefVarCount - 1
    Print #1, DefVar(i)
Next i
Close #1

'See if we should need to use Disk access
For ii = 0 To GeneralCommandsFoundCount - 1
    Temp$ = UCase$(GeneralCommandsFound$(ii))
    If Temp$ = "LOADM" Then
        Disk = 1 ' Flag that we use Disk access
    End If
Next ii

' Start writing to the .asm file
Open OutName$ For Output As #1
DirectPage$ = ProgramStart$
DirectPage = Val("&H" + DirectPage$)
DirectPage = DirectPage / 256
DirectPage$ = Hex$(DirectPage)
T1$ = "    ": T2$ = T1$ + T1$
If BranchCheck > 0 Then
    ' User wants all branches checked for minimum size
    A$ = "PRAGMA": B$ = "noforwardrefmax": C$ = "This option is necessary for auto branch size feature to work properly, makes lwasm REALLY slow, but code will be smaller and faster": GoSub AssemOut
End If
A$ = "PRAGMA": B$ = "autobranchlength": C$ = "Tell LWASM to automatically use long branches if the short branch is too small, see compiler docs for option -b1 to make this work properly": GoSub AssemOut
Print #1, "; Program reserves $100 bytes before the starting location below for stack space"
A$ = "ORG": B$ = "$" + ProgramStart$: C$ = "Program code starts here": GoSub AssemOut
A$ = "SETDP": B$ = "$" + DirectPage$: C$ = "Direct page is setup here": GoSub AssemOut
Print #1, "Seed1           RMB     1     ; Random number seed location"
Print #1, "Seed2           RMB     1     ; Random number seed location"
Print #1, "RNDC            RMB     1     ; Used by Random number generator"
Print #1, "RNDX            RMB     1     ; Used by Random number generator"
Print #1, "StartClearHere:" ' This is the start address of variables that will all be cleared to zero when the program starts
' Save space for 10 temporary 16 bit numbers
Print #1, "; Temporary Numbers:"
For Num = 0 To 10
    GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    Print #1, "_Var_PF"; Num$; T1$; "RMB "; T1$; "2"
Next Num
Print #1, "; Numeric Variables Used:"; NumericVariableCount
For ii = 0 To NumericVariableCount - 1
    Print #1, "_Var_"; NumericVariable$(ii); T1$; "RMB "; T1$; "2"
Next ii
Print #1, "Temp1           RMB     1     ; Temporary byte used for many routines"
Print #1, "Temp2           RMB     1     ; Temporary byte used for many routines"
Print #1, "Temp3           RMB     1     ; Temporary byte used for many routines"
Print #1, "Temp4           RMB     1     ; Temporary byte used for many routines"
Print #1, "Denominator     RMB     2     ; Denominator, used in division"
Print #1, "Numerator       RMB     2     ; Numerator, used in division"
Print #1, "DATAPointer     RMB     2     ; Variable that points to the current DATA location"
Print #1, "EveryCasePointer  RMB   2     ; Pointer at the table to keep track of the CASE/EVERYCASE Flags"
Print #1, "EveryCaseStack  RMB     10*2  ; Space Used for nested Cases"
Print #1, "SoundTone       RMB     1     ; SOUND Tone value"
Print #1, "SoundDuration   RMB     2     ; SOUND Command duration value"
Print #1, "CASFLG          RMB     1     ; Case flag for keyboard output $FF=UPPER (normal), 0=LOWER"
Print #1, "OriginalIRQ     RMB     3     ; We save the original branch and location of the IRQ here, restored before we exit"
Print #1, "_NumVar_IFRight RMB     2     ; Temp bytes for IF Compares"
' Add temp string space
For Num = 0 To 1
    GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    Print #1, "_StrVar_PF"; Num$; T1$; "RMB "; T1$; "256     ; Temp String Variable"
Next Num
' Add temp IF string space
Print #1, "_StrVar_IFRight"; T1$; "RMB "; T1$; "256     ; Temp String Variable for IF Compares"

' Add the String Variables used
Print #1, "; String Variables Used:"; StringVariableCounter
For ii = 0 To StringVariableCounter - 1
    Z$ = "_StrVar_" + StringVariable$(ii): GoSub AssemOut
    A$ = "RMB": B$ = "1": C$ = "String Variable " + StringVariable$(ii) + " length (0 to 255) initialized to 0": GoSub AssemOut
    A$ = "RMB": B$ = "255": C$ = "255 bytes available for string variable " + StringVariable$(ii): GoSub AssemOut
Next ii
Print #1, "; Numeric Arrays Used:"; NumArrayVarsUsedCounter
If NumArrayVarsUsedCounter > 0 Then
    For ii = 0 To NumArrayVarsUsedCounter - 1
        Temp$ = "2*" 'Two bytes (16 bits) per element
        For D1 = 0 To NumericArrayDimensions(ii) - 1
            Num = Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            Temp$ = Temp$ + Num$ + "*"
        Next D1
        Temp$ = Left$(Temp$, Len(Temp$) - 1) ' Remove the extra '*'
        Print #1, "_ArrayNum_"; NumericArrayVariables$(ii)
        Print #1, "; Reserve bytes per element size, set with the DIM command"
        For D1 = 0 To NumericArrayDimensions(ii) - 1
            Num = Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            A$ = "FCB": B$ = Num$: C$ = "Default size of each array element is 11 (0 to 10), changed with the DIM command": GoSub AssemOut
        Next D1
        A$ = "RMB": B$ = Temp$: C$ = "Two bytes (16 bits) per element": GoSub AssemOut
    Next ii
End If

Print #1, "; String Arrays Used:"; StringArrayVarsUsedCounter
If StringArrayVarsUsedCounter > 0 Then
    For ii = 0 To StringArrayVarsUsedCounter - 1
        StringArrayReserveSize = StringArraySize + 1 ' Need an extra byte for the actual string size value
        Num = StringArrayReserveSize
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        'Temp$ = "256*" '256 bytes per element
        Temp$ = Num$ + "*" '# of bytes per element
        For D1 = 0 To StringArrayDimensions(ii) - 1
            Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            Temp$ = Temp$ + Num$ + "*"
        Next D1
        Temp$ = Left$(Temp$, Len(Temp$) - 1) ' Remove the extra '*'
        Print #1, "_ArrayStr_"; StringArrayVariables$(ii)
        Print #1, "; Reserve bytes per element size, set with the DIM command"
        For D1 = 0 To StringArrayDimensions(ii) - 1
            Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            A$ = "FCB": B$ = Num$: C$ = "Default size of each array element is 11 (0 to 10), changed with the DIM command": GoSub AssemOut
        Next D1
        A$ = "RMB": B$ = Temp$: C$ = "Reserve " + Temp$ + " bytes per element": GoSub AssemOut
    Next ii
End If
Print #1, "EndClearHere:" ' This is the end address of variables that will all be cleared to zero when the program starts

Print #1, "; General Commands Used:"; GeneralCommandsFoundCount
For ii = 0 To GeneralCommandsFoundCount - 1
    Print #1, "; " + GeneralCommandsFound$(ii)
Next ii

Print #1, "; Numeric Commands Used:"; NumericCommandsFoundCount
For ii = 0 To NumericCommandsFoundCount - 1
    Print #1, "; " + NumericCommandsFound$(ii)
Next ii

Print #1, "; String Commands Used:"; StringCommandsFoundCount
For ii = 0 To StringCommandsFoundCount - 1
    Print #1, "; " + StringCommandsFound$(ii)
Next ii

For c = 0 To vc - 1
    If Right$(var$(c), 3) <> "Str" Then Print #1, "_Var_"; var$(c); T1$; "FDB "; T1$; "$0000"
Next c

For c = 0 To vc - 1
    If Right$(var$(c), 3) = "Str" Then
        Print #1, "_StrVar_"; var$(c); T1$; "FCB "; T1$; "$00     ; String Variable "; var$(c); " length (0 to 255) initialized to 0"
        A$ = "RMB": B$ = "255": C$ = "255 bytes available for string variable " + var$(c): GoSub AssemOut
    End If
Next c

If Verbose > 0 Then Print "Adding the required Libraries..."
' Need to tweak code so we only include code that we need in our program
'Add includes that are necessary

' List of includes needs to be added, only if it's not already in the list
Print #1, "; Section of necessary included code:"
For ii = 0 To GeneralCommandsFoundCount - 1
    Temp$ = UCase$(GeneralCommandsFound$(ii))
    If Temp$ = "AUDIO" Then
        Temp$ = "Audio_Muxer": GoSub AddIncludeTemp ' Add code for Selecting the audio muxer and to turn it on or off
    End If
    If Temp$ = "CLS" Then
        Temp$ = "CLS": GoSub AddIncludeTemp ' Add code for clearing the screen
    End If
    If Temp$ = "DRAW" Then
        Temp$ = "GraphicCommandDraw": GoSub AddIncludeTemp ' Add code for Doing the DRAW command
        Temp$ = "DecimalStringToD": GoSub AddIncludeTemp ' Add commands for converting decimal numbers to D
    End If
    If Temp$ = "GETJOYD" Then
        Temp$ = "GetJoyD": GoSub AddIncludeTemp ' Add code to quickly get the Joystick values and set the values of 0,31 or 63
    End If
    If Temp$ = "INPUT" Then
        Temp$ = "KeyboardInput": GoSub AddIncludeTemp
        Temp$ = "INPUTCode": GoSub AddIncludeTemp
        Temp$ = "DecimalStringToD": GoSub AddIncludeTemp ' Add commands for converting decimal numbers to D
    End If
    If Temp$ = "LOADM" Then
        Temp$ = "Disk_Commands": GoSub AddIncludeTemp ' Add code for Disk commands
    End If
    If Temp$ = "PMODE" Then
        Temp$ = "GraphicSetup": GoSub AddIncludeTemp ' Add code for the setting different Graphics PMODES and SCREENs
        Temp$ = "GraphicCommands": GoSub AddIncludeTemp ' Add code to handle graphics commands
    End If
    If Temp$ = "SET" Or Temp$ = "RESET" Then
        Temp$ = "SetResetPoint": GoSub AddIncludeTemp
    End If
    If Temp$ = "SOUND" Then
        Temp$ = "Sound": GoSub AddIncludeTemp ' Add code for the sound command
        Temp$ = "Audio_Muxer": GoSub AddIncludeTemp 'SOUND routine also requires the Muxer to be turned on
    End If
Next ii
For ii = 0 To StringCommandsFoundCount - 1
    Temp$ = UCase$(StringCommandsFound$(ii))
    If Temp$ = "INKEY$" Then
        Temp$ = "Inkey": GoSub AddIncludeTemp ' Add the Inkey library
    End If
    If Temp$ = "STR$" Then
        Temp$ = "D_to_String": GoSub AddIncludeTemp ' Add the D_to_String library
    End If
Next ii
For ii = 0 To NumericCommandsFoundCount - 1
    Temp$ = UCase$(NumericCommandsFound$(ii))
    If Temp$ = "BUTTON" Then
        Temp$ = "JoyButton": GoSub AddIncludeTemp 'Add code to handle reading the joystick buttons
    End If
    If Temp$ = "JOYSTK" Then
        Temp$ = "Joystick": GoSub AddIncludeTemp 'Add code to handle analog Joystick input
        Temp$ = "Audio_Muxer": GoSub AddIncludeTemp 'Joystick routine also requires the Muxer to be turned off
    End If
    If Temp$ = "POINT" Then
        Temp$ = "SetResetPoint": GoSub AddIncludeTemp
    End If
    If Temp$ = "RND" Or Temp$ = "RNDZ" Or Temp$ = "RNDL" Then
        Temp$ = "Random": GoSub AddIncludeTemp ' Add the code to do a Random number
    End If
    If Temp$ = "VAL" Then
        Temp$ = "DecimalStringToD": GoSub AddIncludeTemp
        Temp$ = "HexStringToD": GoSub AddIncludeTemp
    End If
Next ii

' Libraries always included, other libraries use them, so they are needed
Temp$ = "Equates": GoSub AddIncludeTemp
Temp$ = "Print": GoSub AddIncludeTemp
Temp$ = "Print_Serial": GoSub AddIncludeTemp
Temp$ = "D_to_String": GoSub AddIncludeTemp
Temp$ = "DHex_to_String": GoSub AddIncludeTemp
Temp$ = "Mulitply16x16": GoSub AddIncludeTemp
Temp$ = "Divide16with16": GoSub AddIncludeTemp
Temp$ = "SquareRoot": GoSub AddIncludeTemp

GoSub WriteIncludeListToFile ' Write all the INCLUDE files needed to the .ASM file

If Disk = 0 Then
    ' Sound and Timer 60 Hz IRQ
    Z$ = "; Sound and Timer 60hz IRQ ": GoSub AssemOut
    Z$ = "BASIC_IRQ:": GoSub AssemOut
    A$ = "LDA": B$ = "$FF03": C$ = "CHECK FOR 60HZ INTERRUPT": GoSub AssemOut
    A$ = "BPL": B$ = "Not60Hz": C$ = "RETURN IF 63.5 MICROSECOND INTERRUPT": GoSub AssemOut
    A$ = "LDA": B$ = "$FF02": C$ = "RESET PIA0, PORT B INTERRUPT FLAG": GoSub AssemOut
    A$ = "LDX": B$ = "SoundDuration": C$ = "Get the new Sound duration value": GoSub AssemOut
    A$ = "BEQ": B$ = ">": C$ = "RETURN IF TIMER = 0": GoSub AssemOut
    A$ = "LEAX": B$ = "-1,X": C$ = "DECREMENT TIMER IF NOT = 0": GoSub AssemOut
    A$ = "STX": B$ = "SoundDuration": C$ = "Save the new Sound duration value": GoSub AssemOut
    Z$ = "!"
    A$ = "INC": B$ = "_Var_Timer+1": C$ = "Increment the LSB of the Timer Value": GoSub AssemOut
    A$ = "BNE": B$ = "Not60Hz": C$ = "Skip ahead if not zero": GoSub AssemOut
    A$ = "INC": B$ = "_Var_Timer": C$ = "Increment the MSB of the Timer Value": GoSub AssemOut
    Z$ = "Not60Hz"
    A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AssemOut
Else
    ' DISK controller Interrupts
    '; NMI SERVICE
    Z$ = "DNMISV:"
    A$ = "LDA": B$ = "NMIFLG": C$ = "GET NMI FLAG": GoSub AssemOut
    A$ = "BEQ": B$ = "LD8AE": C$ = "RETURN IF NOT ACTIVE": GoSub AssemOut
    A$ = "LDX": B$ = "DNMIVC": C$ = "GET NEW RETURN VECTOR": GoSub AssemOut
    A$ = "STX": B$ = "10,S": C$ = "STORE AT STACKED PC SLOT ON STACK": GoSub AssemOut
    A$ = "CLR": B$ = "NMIFLG": C$ = "RESET NMI FLAG": GoSub AssemOut
    Z$ = "LD8AE"
    A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AssemOut
    '; Disk IRQ SERVICE and Sound and Timer 60 Hz IRQ
    Z$ = "BASIC_IRQ:"
    A$ = "LDA": B$ = "$FF03": C$ = "63.5 MICRO SECOND OR 60 HZ INTERRUPT?": GoSub AssemOut
    A$ = "BPL": B$ = "LD8AE": C$ = "RETURN IF 63.5 MICROSECOND": GoSub AssemOut
    A$ = "LDA": B$ = "$FF02": C$ = "RESET 60 HZ PIA INTERRUPT FLAG": GoSub AssemOut
    A$ = "LDA": B$ = "RDYTMR": C$ = "GET TIMER": GoSub AssemOut
    A$ = "BEQ": B$ = "LD8CD": C$ = "BRANCH IF NOT ACTIVE": GoSub AssemOut
    A$ = "DECA": C$ = "DECREMENT THE TIMER": GoSub AssemOut
    A$ = "STA": B$ = "RDYTMR": C$ = "SAVE IT": GoSub AssemOut
    A$ = "BNE": B$ = "LD8CD": C$ = "BRANCH IF NOT TIME TO TURN OFF DISK MOTORS": GoSub AssemOut
    A$ = "LDA": B$ = "DRGRAM": C$ = "GET DSKREG IMAGE": GoSub AssemOut
    A$ = "ANDA": B$ = "#$B0": C$ = "TURN ALL MOTORS AND DRIVE SELECTS OFF": GoSub AssemOut
    A$ = "STA": B$ = "DRGRAM": C$ = "PUT IT BACK IN RAM IMAGE": GoSub AssemOut
    A$ = "STA": B$ = "DSKREG": C$ = "SEND TO CONTROL REGISTER (MOTORS OFF)": GoSub AssemOut
    Z$ = "LD8CD"
    A$ = "LDX": B$ = "SoundDuration": C$ = "Get the new Sound duration value": GoSub AssemOut
    A$ = "BEQ": B$ = ">": C$ = "RETURN IF TIMER = 0": GoSub AssemOut
    A$ = "LEAX": B$ = "-1,X": C$ = "DECREMENT TIMER IF NOT = 0": GoSub AssemOut
    A$ = "STX": B$ = "SoundDuration": C$ = "Save the new Sound duration value": GoSub AssemOut
    Z$ = "!"
    A$ = "INC": B$ = "_Var_Timer+1": C$ = "Increment the LSB of the Timer Value": GoSub AssemOut
    A$ = "BNE": B$ = "Not60Hz": C$ = "Skip ahead if not zero": GoSub AssemOut
    A$ = "INC": B$ = "_Var_Timer": C$ = "Increment the MSB of the Timer Value": GoSub AssemOut
    Z$ = "Not60Hz"
    A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AssemOut
End If


Print #1, "* Main Program"
Print #1, "START:"
A$ = "PSHS": B$ = "CC,D,DP,X,Y,U": C$ = "Save the original BASIC Register values": GoSub AssemOut
A$ = "STS": B$ = "RestoreStack+2": C$ = "save the original BASIC stack pointer value (try to Return at the end of the program) (self modify code)": GoSub AssemOut
A$ = "LDS": B$ = "#$0400": C$ = "Set up the stack pointer": GoSub AssemOut
A$ = "ORCC": B$ = "#$50": C$ = "Turn off the interrupts": GoSub AssemOut
A$ = "LDA": B$ = "#$" + DirectPage$: GoSub AssemOut
A$ = "TFR": B$ = "A,DP": C$ = "Setup the Direct page to use our variable location": GoSub AssemOut

'Z$ = "* This code masks off the two low bits written to $FF20": GoSub AssemOut
'Z$ = "* So you can send the PCM Unsigned 8 Bit sample as is, no masking needed": GoSub AssemOut
'A$ = "LDA": B$ = "$FF21": C$ = "* PIA1_Byte_1_IRQ      * $FF21": GoSub AssemOut
'A$ = "PSHS": B$ = "A": C$ = "": GoSub AssemOut
'A$ = "ANDA": B$ = "#%00110011": C$ = "* FORCE BIT2 LOW": GoSub AssemOut
'A$ = "STA": B$ = "$FF21": C$ = "* PIA1_Byte_1_IRQ * $FF21": GoSub AssemOut
'A$ = "LDA": B$ = "#%11111100": C$ = "* OUTPUT ON DAC, INPUT ON RS-232 & CDI": GoSub AssemOut
'A$ = "STA": B$ = "$FF20": C$ = "* PIA1_Byte_0_IRQ * $FF20 NOW DATA DIRECTION REGISTER": GoSub AssemOut
'A$ = "PULS": B$ = "A": C$ = "": GoSub AssemOut
'A$ = "STA": B$ = "$FF21": C$ = "* PIA1_Byte_1_IRQ * $FF21": GoSub AssemOut

Z$ = "* Enable 6 Bit DAC output": GoSub AssemOut
A$ = "LDA": B$ = "$FF23": C$ = "* PIA1_Byte_3_IRQ_Ct_Snd * $FF23 GET PIA": GoSub AssemOut
A$ = "ORA": B$ = "#%00001000": C$ = "* SET 6-BIT SOUND ENABLE": GoSub AssemOut
A$ = "STA": B$ = "$FF23": C$ = "* PIA1_Byte_3_IRQ_Ct_Snd * $FF23 STORE": GoSub AssemOut

A$ = "BRA": B$ = "SkipClear": C$ = "On startup skip ahead and do a BSR to this section to clear the variables, as CLEAR will use this code": GoSub AssemOut
' Clear variable RAM  (make this a routine as the CLEAR command will use it to erase all the variables
Z$ = "ClearVariables:": GoSub AssemOut
A$ = "LDX": B$ = "#StartClearHere": C$ = "Set the start address of the variables that will be cleared to zero when the program starts": GoSub AssemOut
A$ = "CLRA": C$ = "Clear Accumulator A": GoSub AssemOut
Z$ = "!"
A$ = "STA": B$ = ",X+": C$ = "Clear the variable space, move pointer forward": GoSub AssemOut
A$ = "CMPX": B$ = "#EndClearHere": C$ = "Compare the current address to the end of the variables that will be cleared to zero when the program starts": GoSub AssemOut
A$ = "BNE": B$ = "<": C$ = "Loop until all cleared": GoSub AssemOut

' Restore sizes of numeric arrays
Lastnum$ = ""
If NumArrayVarsUsedCounter > 0 Then
    Print #1, "; Restore sizes of numeric array Elements"
    For ii = 0 To NumArrayVarsUsedCounter - 1
        A$ = "LDX": B$ = "#_ArrayNum_" + NumericArrayVariables$(ii): C$ = "Set the base pointer": GoSub AssemOut
        Lastnum$ = ""
        For D1 = 0 To NumericArrayDimensions(ii) - 1
            Num = Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 '+1 because it's zero based
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If Num$ <> Lastnum$ Then
                A$ = "LDA": B$ = "#" + Num$: C$ = "Element size set with the DIM command": GoSub AssemOut
                Lastnum$ = Num$
            End If
            A$ = "STA": B$ = ",X+": GoSub AssemOut
        Next D1
    Next ii
End If
' Clear String Array RAM
' Restore sizes of string arrays
If StringArrayVarsUsedCounter > 0 Then
    Print #1, "; Restore sizes of string array Elements"
    For ii = 0 To StringArrayVarsUsedCounter - 1
        A$ = "LDX": B$ = "#_ArrayStr_" + StringArrayVariables$(ii): C$ = "Set the base pointer": GoSub AssemOut
        For D1 = 0 To StringArrayDimensions(ii) - 1
            Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 '+1 because it's zero based
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If Num$ <> Lastnum$ Then
                A$ = "LDA": B$ = "#" + Num$: C$ = "Element size set with the DIM command": GoSub AssemOut
                Lastnum$ = Num$
            End If
            A$ = "STA": B$ = ",X+": GoSub AssemOut
        Next D1
    Next ii
End If
A$ = "LDD": B$ = "#DataStart": C$ = "Get the Address where DATA starts": GoSub AssemOut
A$ = "STD": B$ = "DATAPointer": C$ = "Save it in the DATAPointer variable": GoSub AssemOut
A$ = "LDD": B$ = "#EveryCaseStack-2": C$ = "Table for nested CASE's, -2 because we add 2 everytime we come across a SELECT CASE/EVERYCASE": GoSub AssemOut
A$ = "STD": B$ = "EveryCasePointer": C$ = "Set the CASEpointer for keeping track of nested SELECT CASE commands": GoSub AssemOut
A$ = "RTS": C$ = "Return from clearing the variables": GoSub AssemOut

Z$ = "SkipClear:": GoSub AssemOut
A$ = "BSR": B$ = "ClearVariables": C$ = "Go clear the all the variables": GoSub AssemOut
A$ = "DEC": B$ = "CASFLG": C$ = "set the case flag to $FF = Normal uppercase": GoSub AssemOut
A$ = "LDD": B$ = ">$0112": C$ = "Get the Extended BASIC's TIMER value": GoSub AssemOut
A$ = "STD": B$ = "_Var_Timer": C$ = "Use Basic's Timer as a starting point for the TIMER value, just in case someone uses it for Randomness": GoSub AssemOut
A$ = "STD": B$ = "Seed1": C$ = "Save TIMER value as the Random number seed value": GoSub AssemOut

' Address    Interrupt    CoCo 2 Vector    CoCo 3 Vector
' $FFF2      SWI3         $100             $FEEE
' $FFF4      SWI2         $103             $FEF1
' $FFF6      FIRQ         $10F             $FEF4    * Make it an RTI ($3B)
' $FEF8      IRQ          $10C             $FEF7    * Go to our BASIC_IRQ
' $FFFA      SWI          $106             $FEFA
' $FFFC      NMI          $109             $FEFD    * Go to our Disk controller IRQ
' $FFFE      RESET        $A027            $8C1B

' Setup IRQ jump address
A$ = "LDX": B$ = "$FFFE": C$ = "Get the RESET location": GoSub AssemOut
A$ = "CMPX": B$ = "#$8C1B": C$ = "Check if it's a CoCo 3": GoSub AssemOut
A$ = "BNE": B$ = "SaveCoCo1": C$ = "Setup IRQ, using CoCo 1 IRQ Jump location": GoSub AssemOut
A$ = "LDX": B$ = "#$FEF7": C$ = "X = Address for the COCO 3 IRQ JMP": GoSub AssemOut
A$ = "LDY": B$ = "#$FEFD": C$ = "Y = Address for the COCO 3 NMI JMP": GoSub AssemOut
A$ = "BRA": B$ = ">": C$ = "Skip ahead": GoSub AssemOut
Z$ = "SaveCoCo1": GoSub AssemOut
A$ = "LDX": B$ = "#$010C": C$ = "X = Address for the COCO 1 IRQ JMP": GoSub AssemOut
A$ = "LDY": B$ = "#$0109": C$ = "Y = Address for the COCO 1 NMI JMP": GoSub AssemOut
Z$ = "!"
' Save the original IRQ jump address so we can restore it once done
A$ = "LDU": B$ = "#OriginalIRQ": C$ = "U=Address of the IRQ": GoSub AssemOut
A$ = "LDA": B$ = ",X": C$ = "A = Branch Instruction": GoSub AssemOut
A$ = "STA": B$ = ",U": C$ = "Save Branch Instruction": GoSub AssemOut
A$ = "LDD": B$ = "1,X": C$ = "D = Address": GoSub AssemOut
A$ = "STD": B$ = "1,U": C$ = "Backup the Address of the IRQ": GoSub AssemOut
' Use our IRQ address
A$ = "LDA": B$ = "#$7E": C$ = "JMP instruction": GoSub AssemOut
A$ = "STA": B$ = ",X": C$ = "A = JMP Instruction": GoSub AssemOut
A$ = "LDU": B$ = "#BASIC_IRQ": C$ = "D=Address of the our IRQ": GoSub AssemOut
A$ = "STU": B$ = "1,X": C$ = "D=Address of the IRQ": GoSub AssemOut
If Disk = 1 Then
    ' Add our NMI
    A$ = "STA": B$ = ",Y": C$ = "A = JMP Instruction": GoSub AssemOut
    A$ = "LDU": B$ = "#DNMISV": C$ = "D=Address of the our NMIRQ": GoSub AssemOut
    A$ = "STU": B$ = "1,Y": C$ = "D=Address of the IRQ": GoSub AssemOut
End If
' Make FIRQ an RTI
A$ = "LDA": B$ = "#$3B": C$ = "RTI instruction": GoSub AssemOut
A$ = "STA": B$ = "$010F": C$ = "Save instruction for the CoCo1": GoSub AssemOut
A$ = "STA": B$ = "$FEF4": C$ = "Save instruction for the CoCo3": GoSub AssemOut
' Start the IRQ
Z$ = "* This is where we enable the IRQ": GoSub AssemOut
A$ = "ANDCC": B$ = "#%11101111": C$ = "= %11101111 this will Enable the IRQ to start": GoSub AssemOut

Z$ = "; *** User's Program code starts here ***": GoSub AssemOut

System

' Tokens for variables type:
' &HF0 = Numeric Arrays
' &HF1 = String Arrays
' &HF2 = Regular Numeric Variable
' &HF3 = Regular String Variable
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets

' &HFB = DEF FN Function
' &HFC = Operator Command
' &HFD = String Command
' &HFE = Numeric Command
' &HFF = General Command

TokenizeExpression:
If Verbose > 1 Then Print "Expression to tokenize is:"; Expression$
' Go through command list and see if we match any, replacing any matches with tokens
Tokenized$ = ""
i = 1
GetNextToken:
While i <= Len(Expression$)
    i$ = Mid$(Expression$, i, 1)
    ' Check for  Special characters like a comma, semi colon, quote , brackets
    If i$ = Chr$(&H22) Then
        Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' Tokenize the first quote
        i = i + 1 'Move past it
        i$ = Mid$(Expression$, i, 1)
        While i$ <> Chr$(&H22) ' keep copying until we get an end quote
            If i$ = Chr$(&H0D) Then Print "Error1: something is wrong getting the charcters in quotes at";: GoTo FoundError
            Tokenized$ = Tokenized$ + i$ ' Copy the data inside the quotes
            i = i + 1
            i$ = Mid$(Expression$, i, 1)
        Wend
        Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' make the end quote also tokenized
        i = i + 1
        GoTo GetNextToken ' go handle stuff in quotes
    End If
    ' Check for a General command
    For c = 1 To GeneralCommandsCount
        Temp$ = UCase$(GeneralCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - i + 1))
        If Temp$ = "TIMER" Then Temp$ = "Ignore" ' Don't change TIMER commands to commands here, as they need to be left as variable names, they get fixed as TIMER= afterwards
        If InStr(BaseString$, Temp$) = 1 Then
            'Found a General Command
            If i > 1 Then
                ' Check for a space before the start of this command
                If Mid$(Expression$, i - 1, 1) = " " Or Mid$(Expression$, i - 1, 1) = ":" Then LeftSpace = 1 Else LeftSpace = 0
            Else
                LeftSpace = 1
            End If
            ' It could be a General command, check for a space after the found command
            If i + Len(Temp$) <= Len(Expression$) Then
                ' check if we have a space or special character or a number after the found command
                If Mid$(Expression$, i + Len(Temp$), 1) = " " Or Mid$(Expression$, i + Len(Temp$), 1) = chr$(&HF5) or Mid$(Expression$, i + Len(Temp$), 1)=chr$(&H22) _
                or (asc(Mid$(Expression$, i + Len(Temp$), 1)) >= &H30 and asc(Mid$(Expression$, i + Len(Temp$), 1)) <= &H39) Then
                    RightSpace = 1
                Else
                    RightSpace = 0
                End If
            Else
                RightSpace = 1
            End If
            ' Make changes for General commands that have bracket values, otherwise they will be picked up as numeric array variables
            If Temp$ = "SET" Then
                ' Found 3 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 4, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "PSET" Then
                ' Found 4 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 5, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "LINE" Then
                ' Found 4 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 5, 1) = "(" Or Mid$(BaseString$, 5, 1) = "-" Then
                    'This general command does have an open bracket or -
                    RightSpace = 1
                End If
            End If
            If Temp$ = "PRINT" Then
                ' Found 5 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 6, 1) = "@" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "RESET" Then
                ' Found 5 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 6, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "PAINT" Then
                ' Found 5 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 6, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "CIRCLE" Then
                ' Found 6 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 7, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "PRESET" Then
                ' Found 6 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 7, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If LeftSpace = 1 And RightSpace = 1 Then
                GoSub AddToGeneralCommandList ' Add General Command Temp$ to the general command list
                Num = c: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                Tokenized$ = Tokenized$ + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB) 'Token &HFF is for General Commands
                ' Check for a REM or '
                If c = 3 Or c = 4 Then
                    'We found a REM or ' - copy the rest of this line
                    i = i + Len(Temp$) ' move pointer forward
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1)
                        Tokenized$ = Tokenized$ + i$
                        i = i + 1
                    Wend
                    GoTo TokenAdded0
                End If
                ' Find the DATA Token
                Check$ = "DATA": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
                ' Check for a DATA
                If c = ii Then
                    'We found a DATA command - copy the rest of this line
                    i = i + Len(Temp$) ' move pointer forward past "DATA" command
                    While i <= Len(Expression$) And i$ <> Chr$(&HF5)
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        If i$ = Chr$(&H22) Then
                            Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' Tokenize the first quote
                            i$ = Mid$(Expression$, i, 1): i = i + 1
                            While i$ <> Chr$(&H22) ' keep copying until we get an end quote
                                Tokenized$ = Tokenized$ + i$ ' Copy the data inside the quotes
                                i$ = Mid$(Expression$, i, 1): i = i + 1
                            Wend
                            Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' make the end quote also tokenized
                        Else
                            Tokenized$ = Tokenized$ + i$
                        End If
                    Wend
                    If i$ = Chr$(&HF5) Then
                        'Found a control Token, copy the next byte
                        i$ = Mid$(Expression$, i, 1)
                        Tokenized$ = Tokenized$ + i$
                        i = i + 1
                    End If
                    GoTo TokenAdded0
                End If
                ' Find the DEF Token
                Check$ = "DEF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
                ' Check for a DEF
                If c = ii Then
                    'We found a DEF command, we need to handle the FNx()=...  part
                    i = i + Len(Temp$) + 3 ' move pointer forward so it now points at the FN label
                    Temp$ = ""
                    ' Get the FN variable name in Temp$
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1)
                        If i$ = "(" Then Exit While
                        Temp$ = Temp$ + i$
                        i = i + 1
                    Wend
                    DefLabel$(DefLabelCount) = Temp$
                    Num = DefLabelCount: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                    Tokenized$ = Tokenized$ + Chr$(&HFB) + Chr$(MSB) + Chr$(LSB) ' Flag this as an FN #, and the value of this FN label
                    DefLabelCount = DefLabelCount + 1
                    GoTo TokenAdded0
                End If
                i = i + Len(Temp$) ' move pointer forward
                GoTo TokenAdded0
            End If
        End If
    Next c
    ' Check for a Numeric command
    For c = 1 To NumericCommandsCount
        Temp$ = UCase$(NumericCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - i + 1))
        If InStr(BaseString$, Temp$) = 1 Then
            'Found a Numeric Command
            If i > 1 Then
                ' Check for a stuff before the start of this command
                If Mid$(Expression$, i - 1, 1) = " " Or Mid$(Expression$, i - 1, 1) = "(" Or Mid$(Expression$, i - 1, 1) = "=" Then LeftSpace = 1 Else LeftSpace = 0
            Else
                LeftSpace = 1
            End If
            ' It could be a General command, check for a space after the found command
            If i + Len(Temp$) < Len(Expression$) Then
                ' check if we have a space or ( after the found command
                If Mid$(Expression$, i + Len(Temp$), 1) = " " Or Mid$(Expression$, i + Len(Temp$), 1) = "(" Then RightSpace = 1 Else RightSpace = 0
            Else
                RightSpace = 1
            End If
            ' Check for a FN
            If Temp$ = "FN" And LeftSpace = 1 Then
                'We found an FN command, ignore the variablename before the (
                Temp$ = ""
                i = i + 2 ' skip past FN
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1)
                    If i$ = "(" Then Exit While
                    Temp$ = Temp$ + i$
                    i = i + 1
                Wend
                'Find the FN Label number that matches and write it to the Tokenized file
                For ii = 0 To DefLabelCount
                    If DefLabel$(ii) = Temp$ Then
                        Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        Tokenized$ = Tokenized$ + Chr$(&HFB) + Chr$(MSB) + Chr$(LSB) ' Flag this as an FN #, and the value of this FN label
                        Exit For
                    End If
                Next ii
            End If
            If LeftSpace = 1 And RightSpace = 1 Then
                GoSub AddToNumericCommandList
                Num = c: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                Tokenized$ = Tokenized$ + Chr$(&HFE) + Chr$(MSB) + Chr$(LSB) 'Token $FE is for Numeric Commands
                i = i + Len(Temp$) ' move pointer forward
                GoTo TokenAdded0
            End If
        End If
    Next c
    ' Check for a String command
    For c = 1 To StringCommandsCount
        Temp$ = UCase$(StringCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - i + 1))
        If InStr(BaseString$, Temp$) = 1 Then
            'Found a String Command
            GoSub AddToStringCommandList
            Num = c: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
            Tokenized$ = Tokenized$ + Chr$(&HFD) + Chr$(MSB) + Chr$(LSB) 'Token $FD is for String Commands
            i = i + Len(Temp$) ' move pointer forward
            GoTo TokenAdded0
        End If
    Next c
    ' Check for an Operator command
    For c = 1 To OperatorCommandsCount
        Temp$ = UCase$(OperatorCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - i + 1))
        If InStr(BaseString$, Temp$) = 1 Then
            'Found an Operator Command
            If Temp$ = "NOT" Then
                If InStr(UCase$(Expression$), "IF") > 0 Then
                    ' Found NOT and IF so flag as NOT is a real operator
                    LeftSpace = 1
                    RightSpace = 1
                End If
            End If
            Tokenized$ = Tokenized$ + Chr$(&HFC) + Chr$(c) 'Token &HFC is for Operator Commands
            i = i + Len(Temp$) ' move pointer forward
            GoTo TokenAdded0
        End If
    Next c
    AddTokenAsIs0:
    Tokenized$ = Tokenized$ + i$
    i = i + 1
    TokenAdded0:
    If Temp$ = "DRAW" Then ' Found a Draw command, change any ;X inside a quote to ":DRAW (whatever before the next semi colon" : DRAW" the rest
        Temp$ = Right$(Expression$, Len(Expression$) - i)
        Expression$ = Left$(Expression$, i)
        EndString = InStr(Temp$, Chr$(&HF5)) ' Mark end at a Colon
        If EndString = 0 Then
            EndString = Len(Temp$) ' If no colons then end is the end of string
            EndPart$ = ""
        Else
            EndPart$ = Right$(Temp$, Len(Temp$) - EndString + 1)
            Temp$ = Left$(Temp$, EndString - 1)
        End If
        While Right$(Temp$, 1) = " ": Temp$ = Left$(Temp$, Len(Temp$) - 1): Wend
        ' Remove spaces in quoted parts
        Temp1$ = ""
        qc = 0
        For T1 = 1 To Len(Temp$)
            T1$ = Mid$(Temp$, T1, 1)
            If T1$ = Chr$(&H22) Then qc = qc + 1
            If (qc And 1) = 1 Then
                If T1$ <> " " Then
                    Temp1$ = Temp1$ + T1$
                End If
            Else
                Temp1$ = Temp1$ + T1$
            End If
        Next T1
        Temp$ = Temp1$
        Temp1$ = ""
        T1 = 1
        While T1 < Len(Temp$) - 1
            If UCase$(Mid$(Temp$, T1, 2)) <> ";X" Then
                Temp1$ = Temp1$ + Mid$(Temp$, T1, 1)
            Else
                Temp1$ = Temp1$ + Chr$(&H22) + " " ' add end quote & a space
                Temp1$ = Temp1$ + Chr$(&HF5) + ":DRAW " 'add : DRAW
                T1 = T1 + 2
                While Mid$(Temp$, T1, 1) <> ";"
                    Temp1$ = Temp1$ + Mid$(Temp$, T1, 1)
                    T1 = T1 + 1
                Wend
                Temp1$ = Temp1$ + " " ' add end quote   & a space
                Temp1$ = Temp1$ + Chr$(&HF5) + ":DRAW " + Chr$(&H22) 'add : DRAW
                T1 = T1 - 1
            End If
            T1 = T1 + 1
        Wend
        If T1 < Len(Temp$) Then Temp1$ = Temp1$ + Right$(Temp$, Len(Temp$) - T1 + 1)
        ReplaceCount = Replace(Temp1$, "DRAW " + Chr$(&H22) + ";", "DRAW " + Chr$(&H22)) '  Replace(text$, old$, new$)  ' Change DRAW "; to DRAW "
        ReplaceCount = Replace(Temp1$, "DRAW " + Chr$(&H22) + Chr$(&H22), "") '  Replace(text$, old$, new$)  ' Remove null Draw commands
        ReplaceCount = Replace(Temp1$, Chr$(&HF5) + ": " + Chr$(&HF5) + ":", Chr$(&HF5) + ":") '  Replace(text$, old$, new$)  ' Remove null Draw commands
        Expression$ = Expression$ + Temp1$ + " " + EndPart$
    End If
Wend
If Verbose > 1 Then
    Print "1st:"
    For i = 1 To Len(Tokenized$)
        A = Asc(Mid$(Tokenized$, i, 1))
        If A < 16 Then Print "0";
        Print Hex$(Asc(Mid$(Tokenized$, i, 1)));
    Next i
    Print
End If
' Special commands that need manual tweaking
' LINE may or may not have ,B or BF at the end which might get turned into variable below
' Change the Tokenized$ command so it will have
' after ,PSET or ,PRESET we will have
' ,0,0 - No Box or Box Fill
' ,1,0 - Draw a Box
' ,1,1 - Draw a box and fill it
Temp$ = ""
i = 1
' Find the LINE Token
Check$ = "LINE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
If Found = 1 Then
    ' We do have a LINE command
    Num = ii
    GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
    While InStr(i, Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0
        Start = i
        ' This line of code has the LINE command in it
        i = InStr(i, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFF)) ' Find the ", " + PSET or   ", " + PRESET
        If i = 0 Then Print "Error: LINE command doesn't have ,PSET or ,PRESET on";: GoTo FoundError 'Can't find the ,PSET or ,PRESET
        i = i + 5 ' Move past the PSET or PRESET
        Temp$ = Temp$ + Mid$(Tokenized$, Start, i - Start)
        If Mid$(Tokenized$, i, 1) = Chr$(&H20) And Mid$(Tokenized$, i + 1, 1) = Chr$(&H2C) Then
            ' We have a comma associated with this PSET/PRESET, figure out if it's a B or BF
            i = i + 3 ' Move after the comma
            If Mid$(Tokenized$, i, 1) <> "B" Then Print "Error: LINE command doesn't have a ,B after ,PSET or ,PRESET on";: GoTo FoundError 'Can't find the ,B
            Temp$ = Temp$ + ",1" ' Add the box flag
            i = i + 1 ' move past the B
            ' Check for F after the B
            If Mid$(Tokenized$, i, 1) = "F" Then
                Temp$ = Temp$ + ",1" ' Add the fill flag
                i = i + 1 ' moce past the F
            Else
                Temp$ = Temp$ + ",0" ' No fill value
            End If
        Else
            ' No box or fill command
            Temp$ = Temp$ + ",0,0" ' Add the no box and no fill values
        End If
    Wend
    If Temp$ <> "" Then
        ' We found a LINE command
        Tokenized$ = Temp$ + Right$(Tokenized$, Len(Tokenized$) - i + 1)
    End If
End If

' Tokens for variables type:
' &HF0 = Numeric Arrays
' &HF1 = String Arrays
' &HF2 = Regular Numeric Variable
' &HF3 = Regular String Variable
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets

' &HFB = DEF FN Function
' &HFC = Operator Command
' &HFD = String Command
' &HFE = Numeric Command
' &HFF = General Command

' Expression has now been tokenized with commands:
' Found $FB,FC,FD,FE,FF

' Next tokenize Numeric Arrays & String Arrays
' Find Numeric & String Arrays
Expression$ = Tokenized$
Tokenized$ = ""
i = 1
GetNextToken1:
While i <= Len(Expression$)
    i$ = Mid$(Expression$, i, 1): i = i + 1
    If Asc(i$) > &HEF Then
        ' We hit a token, copy it
        Tokenized$ = Tokenized$ + i$
        Select Case Asc(i$)
            Case &HF5:
                'We have a special character tokenized already
                i$ = Mid$(Expression$, i, 1): i = i + 1 ' Get the Special character
                Tokenized$ = Tokenized$ + i$ ' Copy it
                If i$ = Chr$(&H22) Then
                    ' Found a quote, so copy all until we get the end tokenized quote
                    i$ = Mid$(Expression$, i, 1): i = i + 1 ' Get a byte
                    While i$ <> Chr$(&H22) ' keep copying until we find the end quote
                        Tokenized$ = Tokenized$ + i$ ' Copy the byte
                        i$ = Mid$(Expression$, i, 1): i = i + 1 ' Get a byte
                    Wend
                    Tokenized$ = Tokenized$ + i$ ' Copy the end quote
                End If
                GoTo GetNextToken1
            Case &HFB:
                ' DEF FN Function?
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                GoTo GetNextToken1
            Case &HFC:
                ' Operator?
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                GoTo GetNextToken1
            Case &HFD:
                ' String Command?
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                GoTo GetNextToken1
            Case &HFE:
                ' Numeric Command?
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                'skip forward until after the open and close brackets
                GoTo GetNextToken1
            Case &HFF:
                ' General Command?
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                v = Asc(i$) * 256
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                v = v + Asc(i$)
                If v = C_REM Then
                    ' Found a REM, copy the rest of the expression as is, no more tokenizing needed
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$

                    Wend
                    GoTo DoneGettingExpression
                End If
                If v = C_REMApostrophe Then
                    ' Found an apostrophe ' copy the rest of the expression as is, no more tokenizing needed
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                    Wend
                    GoTo DoneGettingExpression
                End If
                ' Check for a DATA
                If v = C_DATA Then
                    'We found a DATA command - copy the rest of this line upto a colon or the end
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&HF5) Then
                            i$ = Mid$(Expression$, i, 1): i = i + 1
                            Tokenized$ = Tokenized$ + i$
                            If i$ = Chr$(&H3A) Then Exit While
                        End If
                    Wend
                End If
                GoTo GetNextToken1
        End Select
    End If
    CheckStart = i - 1 ' This is as far back as we can go looking for an array label
    ' Find an open bracket, which could be part of an array variable
    For ii = CheckStart + 1 To Len(Expression$)
        If Mid$(Expression$, ii, 1) = "(" Then
            ' Found an open bracket
            ' Might be the start of an array variable
            ' Test for $ or a letter before the "("
            Check$ = UCase$(Mid$(Expression$, ii - 1, 1))
            If Check$ = "$" Then ' Is it a string array?
                'We found a string array to tokenize
                Start = ii - 1 ' start points at the character before the "("
                While Start >= CheckStart
                    If Mid$(Expression$, Start, 1) = " " Or Mid$(Expression$, Start, 1) = "(" Or Mid$(Expression$, Start, 1) = ":" Then Exit While
                    Start = Start - 1
                Wend
                LabelStart = Start + 1
                If LabelStart <> CheckStart Then GoTo CopyOtherBytes 'We missed some bytes before this array, go deal with them first
                Temp$ = Mid$(Expression$, LabelStart, ii - LabelStart - 1) '-1 as we don't want the $
                'Count the dimensions in the array
                BracketStart = ii
                Start = ii + 1 ' Start after the open bracket
                Dimensions = 1: Bracket = 1
                While Bracket > 0
                    If Start > Len(Expression$) Then Print "Need a close bracket on";: GoTo FoundError
                    If Bracket = 1 And Mid$(Expression$, Start, 1) = "," Then Dimensions = Dimensions + 1
                    If Mid$(Expression$, Start, 1) = "(" Then Bracket = Bracket + 1
                    If Mid$(Expression$, Start, 1) = ")" Then Bracket = Bracket - 1
                    Start = Start + 1
                Wend
                GoSub AddToStringArrayVariableList ' Add variable Temp$ to the String array variable List and the number of dimensions the String array has
                If Found = 1 Then
                    Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                    Tokenized$ = Tokenized$ + Chr$(&HF1) + Chr$(MSB) + Chr$(LSB) + Chr$(Dimensions)
                Else
                    Num = StringArrayVarsUsedCounter - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                    Tokenized$ = Tokenized$ + Chr$(&HF1) + Chr$(MSB) + Chr$(LSB) + Chr$(Dimensions)
                End If
                ' Copy the rest of the array to tokenized$
                For y = BracketStart To Start - 1
                    Tokenized$ = Tokenized$ + Mid$(Expression$, y, 1)
                Next y
                i = Start ' Update i's position
                GoTo GetNextToken1
            Else ' Not a string array, check for Numeric array
                If (Asc(Check$) >= Asc("A") And Asc(Check$) <= Asc("Z")) Or (Asc(Check$) >= Asc("0") And Asc(Check$) <= Asc("9")) Or _
                  (Asc(Check$) >= Asc("a") And Asc(Check$) <= Asc("z")) Then ' Is it a letter or number?
                    ' It is part of a Numeric array variable name
                    Start = ii - 1 ' start points at the character before the "("
                    While Start >= CheckStart
                        If Mid$(Expression$, Start, 1) = " " Or Mid$(Expression$, Start, 1) = "(" Or Mid$(Expression$, Start, 1) = ":" Then Exit While
                        Start = Start - 1
                    Wend
                    LabelStart = Start + 1
                    If LabelStart <> CheckStart Then GoTo CopyOtherBytes 'We missed some bytes before this array, go deal with them first
                    Temp$ = Mid$(Expression$, LabelStart, ii - LabelStart)
                    'Count the dimensions in the array
                    BracketStart = ii
                    Start = ii + 1 ' Start after the open bracket
                    Dimensions = 1: Bracket = 1
                    While Bracket > 0
                        If Start > Len(Expression$) Then Print "Need a close bracket on";: GoTo FoundError
                        If Bracket = 1 And Mid$(Expression$, Start, 1) = "," Then Dimensions = Dimensions + 1
                        If Mid$(Expression$, Start, 1) = "(" Then Bracket = Bracket + 1
                        If Mid$(Expression$, Start, 1) = ")" Then Bracket = Bracket - 1
                        Start = Start + 1
                    Wend
                    GoSub AddToNumArrayVariableList ' Add variable Temp$ to the Numeric array variable List and the number of dimensions the String array has
                    If Found = 1 Then
                        Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        Tokenized$ = Tokenized$ + Chr$(&HF0) + Chr$(MSB) + Chr$(LSB) + Chr$(Dimensions)
                    Else
                        Num = NumArrayVarsUsedCounter - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        Tokenized$ = Tokenized$ + Chr$(&HF0) + Chr$(MSB) + Chr$(LSB) + Chr$(Dimensions)
                    End If
                    ' Copy the rest of the array to tokenized$
                    For y = BracketStart To Start - 1
                        Tokenized$ = Tokenized$ + Mid$(Expression$, y, 1)
                    Next y
                    i = Start ' Update i's position
                    GoTo GetNextToken1
                Else
                    ' Not an array break out of the FOR Next loop
                    GoTo CopyOtherBytes
                End If
            End If
        End If
    Next ii
    CopyOtherBytes:
    If i$ = "&" And i < Len(Expression$) Then
        ' Might be hex value "&H"
        Tokenized$ = Tokenized$ + i$ ' output the "&"
        i$ = Mid$(Expression$, i, 1): i = i + 1
        If i$ = "H" Then
            ' We found "&H"
            Tokenized$ = Tokenized$ + i$ ' copy the H to the output
            ' Get the first hex value
            While i <= Len(Expression$)
                i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
                If (Asc(i$) >= Asc("A") And Asc(i$) <= Asc("F")) Or (Asc(i$) >= Asc("0") And Asc(i$) <= Asc("9")) Then
                    Tokenized$ = Tokenized$ + i$
                Else
                    i = i - 1
                    Exit While
                End If
            Wend
            GoTo GetNextToken1
        End If
    End If
    Tokenized$ = Tokenized$ + i$
Wend
If Verbose > 1 Then
    Print "2nd:"
    For i = 1 To Len(Tokenized$)
        A = Asc(Mid$(Tokenized$, i, 1))
        If A < 16 Then Print "0";
        Print Hex$(Asc(Mid$(Tokenized$, i, 1)));
    Next i
    Print
End If

' Tokenize Special Characters
Expression$ = Tokenized$
Tokenized$ = ""
i = 1
GetNextToken2:
While i <= Len(Expression$)
    v = Asc(Mid$(Expression$, i, 1)): i = i + 1
    If v < &HF0 Then
        If v = &H23 Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(v): GoTo GetNextToken2 ' Found #
        If v = &H28 Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(v): GoTo GetNextToken2 ' Found open bracket
        If v = &H29 Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(v): GoTo GetNextToken2 ' Found close bracket
        If v = &H2C Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(v): GoTo GetNextToken2 ' Found comma
        If v = &H3B Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(v): GoTo GetNextToken2 ' Found semi colon
        Tokenized$ = Tokenized$ + Chr$(v): GoTo GetNextToken2 ' copy other values
    End If
    'We have a Token
    Tokenized$ = Tokenized$ + Chr$(v) 'copy the token
    Select Case v
        Case &HF0, &HF1: ' Found a Numeric or String array
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of Array ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of Array ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy # of dimensions
        Case &HF2, &HF3: ' Found a numeric or string variable
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of variable ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of variable ID
        Case &HF5 ' Found a special character
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy Special character
            'We have a special character tokenized already
            If v = &H22 Then
                ' Found a quote, so copy all until we get the end tokenized quote
                i$ = Mid$(Expression$, i, 1) ' Get a byte
                While i$ <> Chr$(&H22) ' keep skipping until we find the end quote
                    Tokenized$ = Tokenized$ + i$ ' Copy the byte
                    i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get a byte
                Wend
            End If
        Case &HFB: ' Found a DEF FN Function
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of FN ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of FN ID
        Case &HFC: ' Found an Operator
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy Operator
        Case &HFD, &HFE: 'Found String,Numeric command
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of command ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of command ID
        Case &HFF: 'Found General command
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of command ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of command ID
            ' Check for a DATA command
            v = Asc(Mid$(Expression$, i - 2, 1)) * 256 + Asc(Mid$(Expression$, i - 1, 1))
            If v = C_DATA Then
                'We found a line with the DATA command, copy it all as it is, don't add extra control characters
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1): i = i + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo GetNextToken2
            End If
            If v = C_REM Or v = C_REMApostrophe Then
                'We found a line with the REM command, copy it all as it is, don't add extra control characters
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1): i = i + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo GetNextToken2
            End If
    End Select
    GoTo GetNextToken2
Wend
' Tokens for variables type:
' &HF0 = Numeric Arrays
' &HF1 = String Arrays
' &HF2 = Regular Numeric Variable
' &HF3 = Regular String Variable
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets

' &HFC = Operator Command
' &HFD = String Command
' &HFE = Numeric Command
' &HFF = General Command

' Find Numeric & String Variables
Expression$ = Tokenized$
Tokenized$ = ""
i = 1
GetNextToken3:
While i <= Len(Expression$)
    i$ = Mid$(Expression$, i, 1)
    If Asc(i$) > &HEF Then ' Test if we hit a token
        If i$ = Chr$(&HF5) Then
            Tokenized$ = Tokenized$ + i$ ' copy the &HF5
            'We have a special character tokenized already
            i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the Special character
            Tokenized$ = Tokenized$ + i$ ' Copy it
            If i$ = Chr$(&H22) Then
                ' Found a quote, so copy all until we get the end tokenized quote
                i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get a byte
                While Mid$(Expression$, i, 1) <> Chr$(&H22) ' keep skipping until we find the end quote
                    Tokenized$ = Tokenized$ + i$ ' Copy the byte
                    i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get a byte
                Wend
                GoTo GetNextToken3
            End If
            i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get a byte
            GoTo GetNextToken3
        End If
        ' This needs to account for 16 bit numbers now
        If Asc(i$) = &HF0 Or Asc(i$) = &HF1 Then
            ' Copy the token plus 3 more values (array , # of dimensions)
            Tokenized$ = Tokenized$ + i$ ' copy the token
            i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the array MSB
            Tokenized$ = Tokenized$ + i$ ' Copy
            i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the array LSB
            Tokenized$ = Tokenized$ + i$ ' Copy
            i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the # of dimensions in the array
            Tokenized$ = Tokenized$ + i$ ' Copy
            i = i + 1
            GoTo GetNextToken3
        Else
            ' Check for a REM or '
            Check$ = "REM": GoSub FindGenCommandInExpression 'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
            If Found = 1 Then
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1)
                    Tokenized$ = Tokenized$ + i$
                    i = i + 1
                Wend
                GoTo GetNextToken3
            End If
            ' Check for a an apostrophe '
            Check$ = "'": GoSub FindGenCommandInExpression 'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
            If Found = 1 Then
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1)
                    Tokenized$ = Tokenized$ + i$
                    i = i + 1
                Wend
                GoTo GetNextToken3
            End If
            ' Check for a DATA
            Check$ = "DATA": GoSub FindGenCommandInExpression 'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
            If Found = 1 Then
                'We found a DATA command - copy the rest of this line
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1): i = i + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo GetNextToken3
            End If
            If Asc(i$) = &HFC Then
                ' Hit an operator, copy only one value after
                Tokenized$ = Tokenized$ + i$ ' copy the token
                i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the operator
                Tokenized$ = Tokenized$ + i$ ' Copy
                i = i + 1
                GoTo GetNextToken3
            Else
                ' We hit a token, copy it
                Tokenized$ = Tokenized$ + i$ ' copy the token
                i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the array MSB
                Tokenized$ = Tokenized$ + i$ ' Copy
                i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the array LSB
                Tokenized$ = Tokenized$ + i$ ' Copy
                i = i + 1
                GoTo GetNextToken3
            End If
        End If
    Else
        If i$ = "&" And i < Len(Expression$) Then
            ' Might be hex value "&H"
            Tokenized$ = Tokenized$ + i$ ' output the "&"
            i = i + 1 ' move past the "&"
            i$ = Mid$(Expression$, i, 1)
            If i$ = "H" Then
                ' We found "&H"
                Tokenized$ = Tokenized$ + i$ ' copy the H to the output
                i = i + 1
                ' Get the first hex value
                i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
                While i <= Len(Expression$)
                    If (Asc(i$) >= Asc("A") And Asc(i$) <= Asc("F")) Or (Asc(i$) >= Asc("0") And Asc(i$) <= Asc("9")) Then
                        Tokenized$ = Tokenized$ + i$
                        i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
                    Else
                        Exit While
                    End If
                Wend
                i = i - 1
            End If
        Else
            ' Check for a variable
            If Asc(UCase$(i$)) >= Asc("A") And Asc(UCase$(i$)) <= Asc("Z") Then ' Is it a letter?
                ' It is part of a variable name, we don't know if it's numeric or string at the moment
                ' Get the variable name
                Start = i ' start points at the 2nd character of the variable
                While Start <= Len(Expression$)
                    If Mid$(Expression$, Start, 1) = " " Or Mid$(Expression$, Start, 1) = Chr$(&HF5) Or Mid$(Expression$, Start, 1) = Chr$(&HFC) _
                    Or Mid$(Expression$, Start, 1) = "$" or Mid$(Expression$, Start, 1) = "=" Then Exit While
                    Start = Start + 1
                Wend
                If Mid$(Expression$, Start, 1) = "$" Then Start = Start + 1
                Temp$ = Mid$(Expression$, i, Start - i)
                If Right$(Temp$, 1) = "$" Then
                    'We found a string variable to tokenize
                    GoSub AddStringVariable ' Add variable Temp$ to the String variable List
                    If Found = 1 Then
                        Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        Tokenized$ = Tokenized$ + Chr$(&HF3) + Chr$(MSB) + Chr$(LSB)
                    Else
                        Num = StringVariableCounter - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        Tokenized$ = Tokenized$ + Chr$(&HF3) + Chr$(MSB) + Chr$(LSB)
                    End If
                    i = i + Len(Temp$) ' move pointer forward
                    GoTo GetNextToken3
                Else
                    'Test if Temp$ is a label instead of a variable name, write it as is if it is a LABEL
                    LabelCheck$ = Temp$
                    FoundL = 0
                    For ii1 = 1 To LineCount
                        If LabelCheck$ = LabelName$(ii1) Then FoundL = 1
                    Next ii1
                    If FoundL = 0 Then
                        ' We have a numeric variable to tokenize
                        Test$ = UCase$(Temp$) ' Make it all capital letters
                        If Test$ = "TIMER" Then Temp$ = "Timer" ' make sure the Timer variable is always the same
                        GoSub AddNumericVariable ' Add variable Temp$ to the Numeric variable List
                        If Found = 1 Then
                            Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                            Tokenized$ = Tokenized$ + Chr$(&HF2) + Chr$(MSB) + Chr$(LSB)
                        Else
                            Num = NumericVariableCount - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                            Tokenized$ = Tokenized$ + Chr$(&HF2) + Chr$(MSB) + Chr$(LSB)
                        End If
                    Else
                        ' We found a label, write it out as is
                        For ii1 = 1 To Len(LabelCheck$)
                            Tokenized$ = Tokenized$ + Mid$(LabelCheck$, ii1, 1)
                        Next ii1
                    End If
                    i = i + Len(Temp$) ' move pointer forward
                    GoTo GetNextToken3
                End If
            End If
        End If
    End If
    Tokenized$ = Tokenized$ + i$
    i = i + 1
Wend
' Remove all spaces that aren't in a quote or DATA statement
Expression$ = Tokenized$
Tokenized$ = ""
i = 1

LoopFindSpaces:
While i <= Len(Expression$)
    v = Asc(Mid$(Expression$, i, 1)): i = i + 1
    If v < &HF0 Then
        If v <> &H20 Then Tokenized$ = Tokenized$ + Chr$(v) ' If not a space then copy it
        GoTo LoopFindSpaces
    End If
    'We have a Token
    Tokenized$ = Tokenized$ + Chr$(v) 'copy the token
    Select Case v
        Case &HF0, &HF1: ' Found a Numeric or String array
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of Array ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of Array ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy # of dimensions
        Case &HF2, &HF3: ' Found a numeric or string variable
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of variable ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of variable ID
        Case &HF5 ' Found a special character
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy Special character
            'We have a special character tokenized already
            If v = &H22 Then
                ' Found a quote, so copy all until we get the end tokenized quote
                i$ = Mid$(Expression$, i, 1) ' Get a byte
                While i$ <> Chr$(&H22) ' keep skipping until we find the end quote
                    Tokenized$ = Tokenized$ + i$ ' Copy the byte
                    i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get a byte
                Wend
            End If
        Case &HFB: ' Found a DEF FN Function
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of FN ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of FN ID
        Case &HFC: ' Found an Operator
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy Operator
        Case &HFD, &HFE: 'Found String,Numeric command
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of command ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of command ID
        Case &HFF: 'Found General command
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of command ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of command ID
            v = Asc(Mid$(Expression$, i - 2, 1)) * 256 + Asc(Mid$(Expression$, i - 1, 1))
            ' Check for a REM or '
            If v = C_REM Or v = C_REMApostrophe Then
                'We found a line with the REM command, copy it all as it is, don't add extra control characters
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1): i = i + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo LoopFindSpaces
            End If
            ' Check for a DATA command
            If v = C_DATA Then
                'We found a line with the DATA command
                MoreDataToCheck:
                If i > Len(Expression$) Then GoTo LoopFindSpaces ' we have reached the end of the expression
                v = Asc(Mid$(Expression$, i, 1)): i = i + 1 'Ge the first byte after the command DATA or after a comma
                If v = Asc(" ") Then
                    If i <= Len(Expression$) Then
                        GoTo MoreDataToCheck ' skip extra spaces after a comma or after the command DATA
                    Else
                        GoTo LoopFindSpaces ' we have reached the end of the expression
                    End If
                End If
                If v = &H2C Then
                    'Found a comma, leave it as it is
                    Tokenized$ = Tokenized$ + Chr$(v) ' copy the comma
                    GoTo MoreDataToCheck ' check next value
                End If
                If (v >= Asc("0") And v <= Asc("9")) Then
                    'We have a number to copy, so we can erase any spaces we find until a comma or end of Expression$
                    Do Until v = &H2C Or i > Len(Expression$)
                        If v = &HF5 Then
                            If Asc(Mid$(Expression$, i, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        If v <> Asc(" ") Then Tokenized$ = Tokenized$ + Chr$(v)
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                    Loop
                    Tokenized$ = Tokenized$ + Chr$(v)
                    If v = &HF5 Then
                        ' We found a colon on this line
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                        Tokenized$ = Tokenized$ + Chr$(v) ' Copy the colon
                        GoTo LoopFindSpaces ' look for more commands after the colon
                    End If
                    If i > Len(Expression$) Then GoTo LoopFindSpaces ' we are at the end
                    GoTo MoreDataToCheck ' Handle more data
                End If
                If v = Asc("&") And Mid$(Expression$, i, 1) = "H" Then
                    'it's a hex number get it all and convert it to a number
                    Temp$ = ""
                    i = i + 1 ' skip past the "H"
                    v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                    Do Until v = &H2C Or i > Len(Expression$)
                        If v = &HF5 Then
                            If Asc(Mid$(Expression$, i, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        Temp$ = Temp$ + Chr$(v)
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                    Loop
                    If v = &HF5 Then
                        ' We found a colon on this line
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                        Tokenized$ = Tokenized$ + Chr$(v) ' Copy the colon
                        GoTo LoopFindSpaces ' look for more commands after the colon
                    End If
                    If v = &H2C Then
                        ' Not the end of the Expression yet
                        Signed16bit = Val("&H" + Temp$)
                        Temp$ = Str$(Signed16bit)
                        Tokenized$ = Tokenized$ + Temp$ + Chr$(v) ' add the converted number and the comma
                        GoTo MoreDataToCheck ' Handle more data
                    Else
                        Temp$ = Temp$ + Chr$(v)
                        Signed16bit = Val("&H" + Temp$)
                        Temp$ = Str$(Signed16bit)
                        If Left$(Temp$, 1) = " " Then Temp$ = Right$(Temp$, Len(Temp$) - 1)
                        ' at the end of the Expression$
                        Tokenized$ = Tokenized$ + Temp$ ' add the converted number
                        GoTo LoopFindSpaces ' We've reached the end of the line
                    End If
                End If
                'Otherwise it's a string copy spaces in the string
                DataString:
                If v = &HF5 And Asc(Mid$(Expression$, i, 1)) = &H22 Then
                    ' Found a quote
                    Tokenized$ = Tokenized$ + Chr$(v) ' Copy &HF5
                    v = Asc(Mid$(Expression$, i, 1)): i = i + 1 ' Get the quote
                    ' inside quoted text ignore commas
                    Do Until (v = &HF5 And Asc(Mid$(Expression$, i, 1)) = &H22) Or i > Len(Expression$) ' copy until we get a close quote or End of line
                        If v = &HF5 Then
                            If Asc(Mid$(Expression$, i, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        Tokenized$ = Tokenized$ + Chr$(v)
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                    Loop
                    Tokenized$ = Tokenized$ + Chr$(v)
                    If v = &HF5 And Asc(Mid$(Expression$, i, 1)) = &H22 Then
                        ' We found an end quote
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                        Tokenized$ = Tokenized$ + Chr$(v)
                        GoTo MoreDataToCheck ' Handle more data
                    End If
                    If v = &HF5 And Asc(Mid$(Expression$, i, 1)) = &H3A Then
                        ' We found a colon on this line
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                        Tokenized$ = Tokenized$ + Chr$(v) ' Copy the colon
                        GoTo LoopFindSpaces ' look for more commands after the colon
                    End If
                    GoTo LoopFindSpaces ' look for more commands
                Else
                    ' Not a quote, copy as is until we get a comma, Colon or EOL
                    Do Until v = &H2C Or i > Len(Expression$)
                        If v = &HF5 Then
                            If Asc(Mid$(Expression$, i, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        Tokenized$ = Tokenized$ + Chr$(v)
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                    Loop
                    ' Make sure right most byte is not a space
                    If i > Len(Expression$) Then
                        'Got to EOL
                        Tokenized$ = Tokenized$ + Chr$(v)
                        Tokenized$ = Left$(Tokenized$, Len(Tokenized$) - 1)
                        While Right$(Tokenized$, 1) = " ": Tokenized$ = Left$(Tokenized$, Len(Tokenized$) - 1): Wend ' make sure there isn't a space before the end
                        If Chr$(v) <> " " Then Tokenized$ = Tokenized$ + Chr$(v) ' Add last byte if it's not a space
                        GoTo MoreDataToCheck ' Handle more data
                    Else
                        While Right$(Tokenized$, 1) = " ": Tokenized$ = Left$(Tokenized$, Len(Tokenized$) - 1): Wend ' make sure there isn't a space before the end
                        Tokenized$ = Tokenized$ + Chr$(v) ' Write the &HF5 or comma
                        If v = &HF5 Then
                            ' We found a colon on this line
                            v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                            Tokenized$ = Tokenized$ + Chr$(v) ' Copy the colon
                            GoTo LoopFindSpaces ' look for more commands after the colon
                        End If
                        ' Found a comma
                        GoTo MoreDataToCheck ' Handle more data
                    End If
                End If
            End If
    End Select
Wend
' Get the DEF FN variable's used (If any)
' Find the DEF Token
Check$ = "DEF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
If Found = 1 Then
    Num = ii
    GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
    i = 1
    While i <= Len(Tokenized$)
        v = Asc(Mid$(Tokenized$, i, 1))
        If v = &HFF Then
            If Asc(Mid$(Tokenized$, i + 1, 1)) = MSB And Asc(Mid$(Tokenized$, i + 2, 1)) = LSB Then
                ' Found a DEF FN, let's get the Variable type and number
                DefVar(DefVarCount) = Asc(Mid$(Tokenized$, i + 9, 1)) * 256 + Asc(Mid$(Tokenized$, i + 10, 1))
                DefVarCount = DefVarCount + 1
            End If
        End If
        i = i + 1
    Wend
End If
DoneGettingExpression:
If Verbose > 1 Then
    Print "3rd:"
    For i = 1 To Len(Tokenized$)
        A = Asc(Mid$(Tokenized$, i, 1))
        If A < 16 Then Print "0";
        Print Hex$(Asc(Mid$(Tokenized$, i, 1)));
    Next i
    Print
End If
Return
' Get General Expression
' Returns with single expression in GenExpression$
GetGenExpression:
v = Array(x): x = x + 1
GenExpression$ = Chr$(v)
If v < &HF0 Then Return ' Copy single byte, as is
'We have a Token
Select Case v
    Case &HF0, &HF1: ' Found a Numeric or String array
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of Array ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of Array ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy # of dimensions
    Case &HF2, &HF3: ' Found a numeric or string variable
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of variable ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of variable ID
    Case &HF5 ' Found a special character
        v = Array(x): x = x + 1
        GenExpression$ = GenExpression$ + Chr$(v) ' Copy special character
    Case &HFB: ' Found a DEF FN Function
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of FN ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of FN ID
    Case &HFC: ' Found an Operator
        v = Array(x): x = x + 1
        GenExpression$ = GenExpression$ + Chr$(v) ' Operator character
    Case &HFD, &HFE, &HFF: 'Found String,Numeric or General command
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of command ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of command ID
End Select
Return
' Found a numeric variable, add it to the list
AddNumericVariable:
Found = 0
For ii = 0 To NumericVariableCount
    If NumericVariable$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
NumericVariable$(NumericVariableCount) = Temp$
NumericVariableCount = NumericVariableCount + 1
Return
' Found a string variable, add it to the list
AddStringVariable:
Found = 0
For ii = 0 To StringVariableCounter
    If StringVariable$(ii) = Left$(Temp$, Len(Temp$) - 1) Then
        Found = 1
        Return
    End If
Next ii
StringVariable$(StringVariableCounter) = Left$(Temp$, Len(Temp$) - 1)
StringVariableCounter = StringVariableCounter + 1
Return
' Add variable Temp$ to the Numeric array variable List and the number of dimensions the Numeric array has
AddToNumArrayVariableList:
Found = 0
For ii = 0 To NumArrayVarsUsedCounter
    If NumericArrayVariables$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
NumericArrayVariables$(NumArrayVarsUsedCounter) = Temp$
NumericArrayDimensions(NumArrayVarsUsedCounter) = Dimensions
' Default each array element to 11 (0 to 10)
NumericArrayDimensionsVal$(NumArrayVarsUsedCounter) = ""
For D1 = 1 To Dimensions: NumericArrayDimensionsVal$(NumArrayVarsUsedCounter) = NumericArrayDimensionsVal$(NumArrayVarsUsedCounter) + "000B": Next D1
NumArrayVarsUsedCounter = NumArrayVarsUsedCounter + 1
Return

' Add variable Temp$ to the String array variable List and the number of dimensions the String array has
AddToStringArrayVariableList:
Found = 0
For ii = 0 To StringArrayVarsUsedCounter
    If StringArrayVariables$(ii) = Left$(Temp$, Len(Temp$) - 1) Then
        Found = 1
        Return
    End If
Next ii
StringArrayVariables$(StringArrayVarsUsedCounter) = Left$(Temp$, Len(Temp$) - 1)
StringArrayDimensions(StringArrayVarsUsedCounter) = Dimensions
' Default each array element to 11 (0 to 10)
StringArrayDimensionsVal$(StringArrayVarsUsedCounter) = ""
For D1 = 1 To Dimensions: StringArrayDimensionsVal$(StringArrayVarsUsedCounter) = StringArrayDimensionsVal$(StringArrayVarsUsedCounter) + "0002": Next D1
StringArrayVarsUsedCounter = StringArrayVarsUsedCounter + 1
Return

' Add General Command Temp$ to the general command list
AddToGeneralCommandList:
Found = 0
For ii = 0 To GeneralCommandsFoundCount
    If GeneralCommandsFound$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
GeneralCommandsFound$(GeneralCommandsFoundCount) = Temp$
GeneralCommandsFoundCount = GeneralCommandsFoundCount + 1
Return
' Add String Command Temp$ to the string command list
AddToStringCommandList:
Found = 0
For ii = 0 To StringCommandsFoundCount
    If StringCommandsFound$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
StringCommandsFound$(StringCommandsFoundCount) = Temp$
StringCommandsFoundCount = StringCommandsFoundCount + 1
Return
' Add Numeric Command Temp$ to the Numeric command list
AddToNumericCommandList:
Found = 0
For ii = 0 To NumericCommandsFoundCount
    If NumericCommandsFound$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
NumericCommandsFound$(NumericCommandsFoundCount) = Temp$
NumericCommandsFoundCount = NumericCommandsFoundCount + 1
Return


' To calculate the maximum RAM required for an array:
' Default arrays are 0 to 10 = 11 elements
' 4 dimension, Numeric array would be calculated with
' Ram required = (11 * 11 * 11 * 11) * 2
' A 2 dimension, String array would be calculated with
' Ram required = (11 * 11) * 256
DoDim:
v = Array(x): x = x + 1
' Get the tokenized array
' F0 = Numeric Arrays
' F1 = String Arrays
If v = &HF0 Then
    'Set the size of a numeric array
    ii = Array(x) * 256 + Array(x + 1): x = x + 2 ' Get the array identifier value
    NumericArrayDimensionsVal$(ii) = "" ' clear the # of Element values per dimension
    NumOfDims = Array(x): x = x + 1 ' Get the number of dimensions for the arrays
    ' Get the number of elements per dimension
    ' These values will be before a comma
    v = Array(x): x = x + 2 ' consume the $F5 & open bracket
    For T1 = 1 To NumOfDims
        Temp$ = ""
        v = Array(x): x = x + 1 ' get the first value
        While v <> &HF5 ' comma will be &HF5 &H2C and close bracket will be &HF5 &H29
            Temp$ = Temp$ + Chr$(v)
            v = Array(x): x = x + 1 ' Get the next digit of the number
        Wend
        v = Array(x): x = x + 1 ' consume the comma or close bracket
        DimVal$ = Hex$(Val(Temp$)) ' Make the value a hex string
        DimVal$ = Right$("0000" + DimVal$, 4) ' Make sure the value is four digits
        NumericArrayDimensionsVal$(ii) = NumericArrayDimensionsVal$(ii) + DimVal$
    Next T1
Else
    If v = &HF1 Then
        'Set the size of a string array
        ii = Array(x) * 256 + Array(x + 1): x = x + 2 ' Get the array identifier value
        StringArrayDimensionsVal$(ii) = "" ' clear the # of Element values per dimension
        NumOfDims = Array(x): x = x + 1 ' Get the number of dimensions for the arrays
        ' Get the number of elements per dimension
        ' These values will be before a comma
        v = Array(x): x = x + 2 ' consume the $F5 & open bracket
        For T1 = 1 To NumOfDims
            Temp$ = ""
            v = Array(x): x = x + 1 ' get the first value
            While v <> &HF5 ' comma will be &HF5 &H2C and close bracket will be &HF5 &H29
                Temp$ = Temp$ + Chr$(v)
                v = Array(x): x = x + 1 ' Get the next digit of the number
            Wend
            v = Array(x): x = x + 1 ' consume the comma or close bracket
            DimVal$ = Hex$(Val(Temp$)) ' Make the value a hex string
            DimVal$ = Right$("0000" + DimVal$, 4) ' Make sure the value is four digits
            StringArrayDimensionsVal$(ii) = StringArrayDimensionsVal$(ii) + DimVal$
        Next T1
    End If
End If
If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then v = Array(x): x = x + 1: Return ' We are done with the DIM command
If v = &HFF Then
    v = Array(x) * 256 + Array(x + 1)
    If v = C_REM Or v = C_REMApostrophe Then
        ' we have a REMark
        GoTo ConsumeCommentsAndEOL ' Consume any comments and the EOL and Return
    End If
End If
GoTo DoDim ' Set the next array values

ConsumeCommentsAndEOL:
If v = &H0D Or v = &H3A Then Return
Do Until v = &HF5 And Array(x) = &H0D 'consume any comments and the EOL
    v = Array(x): x = x + 1
Loop
v = Array(x): x = x + 1
Return

' Send assembly instructions out to .asm file
AssemOut:
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

AddIncludeTemp:
Found = 0
For AI = 1 To IncludeCount
    If IncludeList$(AI) = Temp$ Then Found = 1: Exit For
Next AI
If Found = 0 Then
    'Add the new include to the list
    IncludeCount = IncludeCount + 1
    IncludeList$(IncludeCount) = Temp$
End If
Return
WriteIncludeListToFile:
For AI = 1 To IncludeCount
    Print #1, T2$; "INCLUDE     ./Basic_Includes/"; IncludeList$(AI); ".asm"
Next AI
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

FoundError:
Print " line "; linelabel$: System

' For testing show the length and bytes in the string Show$, IF input=1 then system
show:
Print "Working on line "; linelabel$
Print "Length of "; show$; " is"; Len(show$)
For ii = 1 To Len(show$)
    Print ii, Hex$(Asc(Mid$(show$, ii, 1)))
Next ii
Input q
If q = 1 Then System
Return

' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
NumToMSBLSBString:
MSB = Int(Num / 256)
LSB = Num - MSB * 256
MSB$ = Str$(MSB)
LSB$ = Str$(LSB)
Return

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

'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
FindGenCommandInExpression:
Found = 0
If Asc(Mid$(Expression$, i, 1)) = &HFF Then
    For ii = 0 To GeneralCommandsCount
        If GeneralCommands$(ii) = Check$ Then
            Exit For
        End If
    Next ii
    If Asc(Mid$(Expression$, i + 1, 1)) * 256 + Asc(Mid$(Expression$, i + 2, 1)) = ii Then
        Found = 1
    End If
End If
Return

'Test if a string contains a number or a variable
Function IsNumber (s$)
    If Val(s$) <> 0 Or (Val(s$) = 0 And Left$(s$, 1) = "0") Then
        IsNumber = 1 ' It's a number
    Else
        IsNumber = 0 ' It's not a number, hence a variable
    End If
End Function

Function Replace (text$, old$, new$) 'can also be used as a SUB without the count assignment
    Do
        find = InStr(start + 1, text$, old$) 'find location of a word in text
        If find Then
            count = count + 1
            first$ = Left$(text$, find - 1) 'text before word including spaces
            last$ = Right$(text$, Len(text$) - (find + Len(old$) - 1)) 'text after word
            text$ = first$ + new$ + last$
        End If
        start = find
    Loop While find
    Replace = count 'function returns the number of replaced words. Comment out in SUB
End Function

