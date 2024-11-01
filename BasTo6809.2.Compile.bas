$ScreenHide
$Console
_Dest _Console

' - Now REM's are removed from everyline after the line is sent to the .asm file as it is, so the compiler won't have to deal with them.

Dim Array(270000) As _Unsigned _Byte
Dim DataArray(270000) As _Unsigned _Byte
Dim DataArrayCount As Integer

Dim NumericVariable$(100000)
Dim NumericVariableCount As Integer

Dim FloatVariable$(100000)
Dim FloatVariableCount As Integer

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

Dim DefLabel$(10000)
Dim DefVar(1000) As Integer
DefLabelCount = 0
DefVarCount = 0

' Need to keep track of FOR LOOPs
Dim FORSTack(100)

' Stuff for IF/THEN/ELSE/ENDIF
Dim IFSTack(100) As Integer 'If Stack
Dim ElseStack(100) As Integer ' Else Stack
Dim ELSELocation(100) As Integer 'Flag if the IF has an ELSE

Dim D As Integer
Dim values(100) As Double ' Predefine a large enough array for values
Dim ops(100) As String ' Predefine a large enough array for operators

' Stuff for FP conversion
Dim FloatNum As Double
Dim expo As Integer, sign As _Byte, mant As Long
Dim FPbyte(5) As _Byte


' Handle command line options
FI = 0
count = _CommandCount
If count = 0 Then
    Print "Compiler has no options given to it"
    System
End If
nt = 0: newp = 0: endp = 0: BranchCheck = 0: StringArraySize = 255: KeepTempFiles = 0
Optimize = 2 ' Default to optimize level 2
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 2)) = "-c" Then BASICMode = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-s" Then StringArraySize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-o" Then Optimize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-b" Then BranchCheck = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-v" Then Verbose = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-k" Then KeepTempFiles = 1: GoTo CheckNextCMDOption
    ' check if we got a file name yet if so then the next filename will be output
    OutName$ = N$
    CheckNextCMDOption:
Next check
FName$ = "BasicTokenized.bin"
Open FName$ For Append As #1
length = LOF(1)
Close #1
If length < 1 Then Print "Error file: "; FName$; " is 0 bytes. Or doesn't exist.": Kill FName$: System
If Verbose > 0 Then Print "Length of Input file in bytes:"; length
Open FName$ For Binary As #1
Get #1, , INArray()
Close #1
Filesize = length

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

' Fill the Array() with the Tokenized version of the BASIC program
FName$ = "BasicTokenized.bin"
Open FName$ For Append As #1
length = LOF(1)
Close #1
If length < 1 Then Print "Error file: "; FName$; " is 0 bytes. Or doesn't exist.": Kill FName$: End
If Verbose > 0 Then Print "Length of Input file in bytes:"; length
Open FName$ For Binary As #1
Get #1, , Array()
Close #1

Check$ = "REM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
REM_CMD = ii
Check$ = "'": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
REM_Apostraphe_CMD = ii
Check$ = "STEP": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
STEP_CMD = ii
Check$ = "LET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
LET_CMD = ii
Check$ = "TO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TO_CMD = ii
Check$ = "GOTO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
GOTO_CMD = ii
Check$ = "GOSUB": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
GOSUB_CMD = ii
Check$ = "SELECT": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SELECT_CMD = ii
Check$ = "ON": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
ON_CMD = ii
Check$ = "OFF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
OFF_CMD = ii
Check$ = "PSET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
PSET_CMD = ii
Check$ = "PRESET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
PRESET_CMD = ii
Check$ = "DO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
DO_CMD = ii
Check$ = "FOR": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FOR_CMD = ii
Check$ = "WHILE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
WHILE_CMD = ii
Check$ = "UNTIL": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
UNTIL_CMD = ii
Check$ = "CASE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CASE_CMD = ii
Check$ = "EVERYCASE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
EVERYCASE_CMD = ii
Check$ = "IS": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
IS_CMD = ii
Check$ = "TIMER": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TIMER_CMD = ii
Check$ = "END": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
END_CMD = ii
Check$ = "IF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
IF_CMD = ii
Check$ = "THEN": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
THEN_CMD = ii
Check$ = "ELSE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
ELSE_CMD = ii
Check$ = "TAB": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TAB_CMD = ii
Check$ = "INT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
INT_CMD = ii
Check$ = "FLOATADD": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATADD_CMD = ii
Check$ = "FLOATSUB": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATSUB_CMD = ii
Check$ = "FLOATMUL": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATMUL_CMD = ii
Check$ = "FLOATDIV": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATDIV_CMD = ii
Check$ = "FLOATSQR": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATSQR_CMD = ii
Check$ = "FLOATSIN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATSIN_CMD = ii
Check$ = "FLOATCOS": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATCOS_CMD = ii
Check$ = "FLOATTAN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATTAN_CMD = ii
Check$ = "FLOATATAN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATATAN_CMD = ii
Check$ = "FLOATEXP": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATEXP_CMD = ii
Check$ = "FLOATLOG": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATLOG_CMD = ii
Check$ = "FLOATTOSTR": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATTOSTR_CMD = ii
Check$ = "CMPGT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPGT_CMD = ii
Check$ = "CMPGE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPGE_CMD = ii
Check$ = "CMPEQ": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPEQ_CMD = ii
Check$ = "CMPLE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPLE_CMD = ii
Check$ = "CMPLT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPLT_CMD = ii
Check$ = "STRTOFLOAT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
STRTOFLOAT_CMD = ii


x = 0
INx = 0
lc = 0
LineCount = 0
StringVariableCounter = 0 ' String variable name count
CommandsUsedCounter = 0 ' Counter for unique commmands used
NumArrayVarsUsedCounter = 0 ' Counter for number of NumericArrays used
StringArrayVarsUsedCounter = 0 ' Counter for number of String Array Variables used
' Fill the arrays from files
NumericVariableCount = 0
Open "NumericVariablesUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, NumericVariable$(NumericVariableCount)
    NumericVariableCount = NumericVariableCount + 1
Wend
Close #1
Open "FloatingPointVariablesUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, FloatVariable$(FloatVariableCount)
    FloatVariableCount = FloatVariableCount + 1
Wend
Close #1
StringVariableCounter = 0
Open "StringVariablesUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, StringVariable$(StringVariableCounter)
    StringVariableCounter = StringVariableCounter + 1
Wend
Close #1
GeneralCommandsFoundCount = 0
Open "GeneralCommandsFound.txt" For Input As #1
While EOF(1) = 0
    Input #1, GeneralCommandsFound$(GeneralCommandsFoundCount)
    GeneralCommandsFoundCount = GeneralCommandsFoundCount + 1
Wend
Close #1
StringCommandsFoundCount = 0
Open "StringCommandsFound.txt" For Input As #1
While EOF(1) = 0
    Input #1, StringCommandsFound$(StringCommandsFoundCount)
    StringCommandsFoundCount = StringCommandsFoundCount + 1
Wend
Close #1
NumericCommandsFoundCount = 0
Open "NumericCommandsFound.txt" For Input As #1
While EOF(1) = 0
    Input #1, NumericCommandsFound$(NumericCommandsFoundCount)
    NumericCommandsFoundCount = NumericCommandsFoundCount + 1
Wend
Close #1
NumericArrayVarsUsedCounter = 0
Open "NumericArrayVarsUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, NumericArrayVariables$(NumericArrayVarsUsedCounter)
    Input #1, NumericArrayDimensions(NumericArrayVarsUsedCounter)
    NumericArrayVarsUsedCounter = NumericArrayVarsUsedCounter + 1
Wend
Close #1
StringArrayVarsUsedCounter = 0
Open "StringArrayVarsUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, StringArrayVariables$(StringArrayVarsUsedCounter)
    Input #1, StringArrayDimensions(StringArrayVarsUsedCounter)
    StringArrayVarsUsedCounter = StringArrayVarsUsedCounter + 1
Wend
Close #1
DefLabelCount = 0
Open "DefFNUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, DefLabel$(DefLabelCount)
    DefLabelCount = DefLabelCount + 1
Wend
Close #1
DefVarCount = 0
Open "DefVarUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, DefVar(DefVarCount)
    DefVarCount = DefVarCount + 1
Wend
Close #1
' Start writing to the .asm file
Open OutName$ For Append As #1

' Main process loop

' Found a general command, add it to the list and tokenize it
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
If Array(x) = &HF5 Then
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
    For l = 1 To v
        v = Array(x): x = x + 1
        linelabel$ = linelabel$ + Chr$(v)
    Next l
    If Verbose > 1 And linelabel$ <> "" Then Print "Working on Line: "; linelabel$
    Print #1, "_L"; linelabel$
    SkipLabel:
    ' Decode line so we can print it as normal in the .asm file
    C$ = ""
    Start = x ' Save where we are
    v = Array(x): x = x + 1
    If v = &HF5 And Array(x) = &H0D Then vOld = &H0D: v = Array(x): x = x + 1: GoTo DoAnotherLine
    Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' Is it the end of a line? or colon?
        If v >= &HF0 Then
            Lastv = v
            GoSub DecodeToken ' return with decoded command/variable in Temp$
            C$ = C$ + Temp$
            If Lastv = &HFF Then C$ = C$ + " " ' Add a space after a general command
            v = 0
        Else
            C$ = C$ + Chr$(v)
        End If
        v = Array(x): x = x + 1
    Loop
    v = Array(x): x = x + 1
    vOld = v ' Save it as we might have reached a colon
    ' Print the line we are working on to the .asm file
    If C$ <> "" Then Print #1, "; "; C$: C$ = ""
    x = Start ' Restore where to start (new line or after a colon)
    'Check if this line starts with a REM or '

    'Check for REM or '
    If Array(x) = &HFF Then
        v = (Array(x + 1)) * 256 + Array(x + 2)
        If v = REM_CMD Or v = REM_Apostraphe_CMD Then
            ' this line starts with a REM, handle it
            x = x + 3
            GoSub DoREM ' Go handle a new line that starts with a REM or '
            GoTo DoAnotherLine ' Jump to the general command pointed at by V, Ends with a RETURN
        End If
    End If
    ' Check for a REMarks on the rest of this line, and modify line so the REMarks are skipped

    RemStart = 0
    Check1 = REM_CMD \ 256: Check2 = REM_CMD And 255
    Check3 = REM_Apostraphe_CMD \ 256: Check4 = REM_Apostraphe_CMD And 255
    GoSub GetGenExpression ' Returns with single expression in GenExpression$
    Do Until GenExpression$ = Chr$(&HF5) + Chr$(&H0D) Or GenExpression$ = Chr$(&HF5) + Chr$(&H3A)
        If GenExpression$ = Chr$(&HFF) + Chr$(Check1) + Chr$(Check2) Or GenExpression$ = Chr$(&HFF) + Chr$(Check3) + Chr$(Check4) Then
            ' This line has a REM, copy stuff before the REM to the end of the line and move x pointer to the start of actual commands
            RemStart = x - 4: Exit Do
        Else
            Expression$ = Expression$ + GenExpression$
        End If
        GoSub GetGenExpression ' Returns with single expression in GenExpression$
    Loop
    If RemStart > 0 Then
        ' this line has remarks to be ignored
        ' x points at the start of the next line or just after a colon
        Endx = x - 3 'Ignore the $F5 & $0D or $3A
        AmountToCopy = RemStart - Start
        Difference = Endx - RemStart
        For ii = Endx To Endx - AmountToCopy Step -1
            Array(ii) = Array(ii - Difference)
        Next ii
        Start = Endx - AmountToCopy
    End If
    ' Handle the actual line here:
    x = Start ' Restore where to start (new line or after a colon)
    ' Figure out what type of token we have and deal with it
    v = Array(x): x = x + 1 ' get the token
    If Verbose > 3 Then Print "Token is: "; Hex$(v)
    If v < &HF0 And v > &HF4 And v <> &HFF Then
        Print "Error on or just after "; linelabel; " Needs either a variable or a General command, but found ";
        If v = &HFC Then Print "Operator Command": System
        If v = &HFD Then Print "String Command": System
        If v = &HFE Then Print "Numeric Command": System
        Print "Bad syntax on";: GoTo FoundError
    End If
    If v = &HFF Then
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
    If v = &HF0 Then GoSub HandleNumericArray: GoTo DoAnotherLine
    If v = &HF1 Then GoSub HandleStringArray: GoTo DoAnotherLine
    If v = &HF2 Then GoSub HandleNumericVariable: GoTo DoAnotherLine
    If v = &HF3 Then GoSub HandleStringVariable: GoTo DoAnotherLine
    If v = &HF4 Then GoSub HandleFloatVariable: GoTo DoAnotherLine
Wend
Print #1, "EXITProgram:"
A$ = "ORCC": B$ = "#$50": C$ = "Turn off the interrupts": GoSub AssemOut
' Restore the IRQ jump address
A$ = "LDX": B$ = "$FFFE": C$ = "Get the RESET location": GoSub AssemOut
A$ = "CMPX": B$ = "#$8C1B": C$ = "Check if it's a CoCo 3": GoSub AssemOut
A$ = "BNE": B$ = "RestoreCoCo1": C$ = "Setup IRQ, using CoCo 1 IRQ Jump location": GoSub AssemOut
A$ = "LDX": B$ = "#$FEF7": C$ = "X = Address for the COCO 3 IRQ JMP": GoSub AssemOut
A$ = "BRA": B$ = ">": C$ = "Skip ahead": GoSub AssemOut
Z$ = "RestoreCoCo1": GoSub AssemOut
A$ = "LDX": B$ = "#$010C": C$ = "X = Address for the COCO 1 IRQ JMP": GoSub AssemOut
Z$ = "!"
' Restore it
A$ = "LDU": B$ = "#OriginalIRQ": C$ = "U = Address of the original IRQ": GoSub AssemOut
A$ = "LDA": B$ = ",U": C$ = "A = Branch Instruction": GoSub AssemOut
A$ = "STA": B$ = ",X": C$ = "Save Branch Instruction": GoSub AssemOut
A$ = "LDD": B$ = "1,U": C$ = "D = address": GoSub AssemOut
A$ = "STD": B$ = "1,X": C$ = "Restore the Address of the IRQ": GoSub AssemOut
Print #1, "RestoreStack:"
A$ = "LDS": B$ = "#$0000": C$ = "Selfmodified when this programs starts - this restores S just how BASIC had it": GoSub AssemOut
A$ = "PULS": B$ = "CC,D,DP,X,Y,U,PC": C$ = "Restore the original BASIC Register values and return to BASIC, if it can": GoSub AssemOut

' Add data Table if needed
Print #1, "DataStart:"
If DataArrayCount > 0 Then
    For x = 0 To DataArrayCount - 1 Step 4
        Print #1, "        FQB     $";
        q1$ = Right$("00" + Hex$(DataArray(x)), 2) + Right$("00" + Hex$(DataArray(x + 1)), 2)
        q2$ = Right$("00" + Hex$(DataArray(x + 2)), 2) + Right$("00" + Hex$(DataArray(x + 3)), 2)
        Print #1, q1$; q2$; "   ;";
        Print #1, Right$("0000" + Hex$(x + a), 4); ": ";
        Print #1, Right$("00" + Hex$(DataArray(x)), 2); " "; Right$("00" + Hex$(DataArray(x + 1)), 2); " ";
        Print #1, Right$("00" + Hex$(DataArray(x + 2)), 2); " "; Right$("00" + Hex$(DataArray(x + 3)), 2)
    Next x
End If
A$ = "END": B$ = "START": GoSub AssemOut
Close #1

' Check if we should optimize the program
If Optimize > 0 Then
    ' Optimize it
    ' At this point the program will execute but we can remove extra lines of code as the numeric parser always exits with a STD _Var_PF00
    ' It has been flagged with "*XX We can delete the line above XX*" a line after the last STD _Var_PF00 (that can be erased)
    ' Let's remove those lines below
    Open OutName$ For Input As #1
    Open "Temp.txt" For Output As #2
    CheckForNumericExtra:
    While EOF(1) = 0
        Line Input #1, i$
        While EOF(1) = 0
            Line Input #1, i2$
            If i2$ = "*XX We can delete the line above XX*" Then
                GoTo CheckForNumericExtra
            Else
                Print #2, i$
                i$ = i2$
            End If
        Wend
        Print #2, i$
    Wend
    Close #1
    Close #2
    Kill OutName$ 'Kill the original
    Name "Temp.txt" As OutName$ ' Rename Temp.txt to OutName$
End If
If Optimize > 1 Then
    ' - Add optimize option 2 which will find (similar to):
    '        LDD     xxxx
    '        STD     _Var_PF00
    '        LDD     yyyy
    '        STD     _Var_PF01
    '        LDD     _Var_PF00
    '        ADDD    _Var_PF01
    ' And replace it with:
    '        LDD     xxxx
    '        ADDD    yyyy

    Dim buffer$(6)
    fileName$ = OutName$
    ' Open the input file for reading
    Open fileName$ For Input As #1
    ' Create a temporary output file
    outputFile = FreeFile
    Open "temp.asm" For Output As #2
    Do While Not EOF(1)
        ' Read the next line
        Line Input #1, line$
        ' Shift the buffer
        For I = 1 To 5
            buffer$(I) = buffer$(I + 1)
        Next I
        buffer$(6) = line$
        ' Check if the buffer matches the pattern
        If Left$(buffer$(1), 16) = "        LDD     " AND _
           Left$(buffer$(2), 25) = "        STD     _Var_PF00" AND _
           Left$(buffer$(3), 16) = "        LDD     " AND _
           Left$(buffer$(4), 25) = "        STD     _Var_PF01" AND _
           Left$(buffer$(5), 25) = "        LDD     _Var_PF00" Then
            ' Extract the instruction from the last line
            lastLine$ = buffer$(6)
            lastLine$ = Mid$(lastLine$, 9, InStr(9, lastLine$, " ") - 9)
            ' Write the replacement lines
            Print #2, buffer$(1)
            Print #2, "        "; lastLine$; "    "; Mid$(buffer$(3), 17, Len(buffer$(3)) - 17)
            ' Clear the buffer
            For I = 2 To 6
                Line Input #1, line$
                buffer$(I) = line$
            Next I
        Else
            ' Write the buffered line if it's not part of the pattern
            Print #2, buffer$(1)
        End If
    Loop
    ' Write the remaining lines in the buffer
    For I = 2 To 6
        If buffer$(I) <> "" Then
            Print #2, buffer$(I)
        End If
    Next I
    ' Close the files
    Close #1
    Close #2
    ' Replace the original file with the modified file
    Kill fileName$
    Name "temp.asm" As fileName$
End If

If KeepTempFiles = 0 Then
    'Erase the temp files
    Kill "NumericVariablesUsed.txt"
    Kill "FloatingPointVariablesUsed.txt"
    Kill "StringVariablesUsed.txt"
    Kill "GeneralCommandsFound.txt"
    Kill "StringCommandsFound.txt"
    Kill "NumericCommandsFound.txt"
    Kill "NumericArrayVarsUsed.txt"
    Kill "StringArrayVarsUsed.txt"
    Kill "DefFNUsed.txt"
    Kill "DefVarUsed.txt"
    Kill "BASIC_Text.bas"
    Kill "BasicTokenized.bin"
    Kill "BasicTokenizedB4Pass2.bin"
    Kill "BasicTokenizedB4Pass3.bin"
End If
If Verbose > 0 Then Print "All Done :)"
System 1 ' 1 signifies exit with no errors :)

' Returns with X pointing at the memory location for the Numeric Array, D is unchanged
MakeXPointAtNumericArray:
A$ = "PSHS": B$ = "D": C$ = "Save D": GoSub AssemOut
If Verbose > 3 Then Print "Going to deal with  Numeric array"
v = Array(x) * 256 + Array(x + 1): x = x + 2
NV$ = NumericArrayVariables$(v)
If Verbose > 3 Then Print "Numeric array variable is: "; NV$
NumDims = Array(x): x = x + 3 ' Consume the $F5 & open bracket
If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
If NumDims = 1 Then ' does it only have one dimension? if so it's simpler
    ' Yes just a single dimension array
    If Verbose > 3 Then Print "handling a one dimensional array"
    If Verbose > 3 Then Print #1, "; Started handling the array here:"
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
Else
    ' Handle multi dimensional arrays
    ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)
    If Verbose > 3 Then Print "handling a multi dimensional array"
    A$ = "LDX": B$ = "#_ArrayNum_" + NV$ + "+1": C$ = " X points at the 2nd array Element size": GoSub AssemOut ' X points at the 2nd array Element size
    A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AssemOut
    ' Get d1
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," move pointer past the comma
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AssemOut ' D = d1
    If NumDims = 2 Then GoTo DoNumArrCloseBracket0 ' skip ahead if we only have 2 dimension in the array
    'Get NumElements2
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AssemOut
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut ' LSB of d1
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut ' D=d1* NumElements2
    A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AssemOut ' Save it on the stack
    A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
    A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
    A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
    Z$ = "!": GoSub AssemOut ' Num Element Pointer is now pointing at NumElements3
    'Get d2
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," move pointer past the comma
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    ' Add d2
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
    A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
    If Verbose > 2 Then Print "number of dimensions:"; NumDims
    If NumDims > 3 Then
        For TempNumArray1 = 3 To NumDims - 1 ' Number of dimensions in the array - 1 since last wont have a comma seperating it
            ' Get NumElementsX
            ' Get NumElementsX
            A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
            A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
            A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                        Need 16bit muliply
            A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AssemOut
            A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
            A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
            A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
            Z$ = "!": GoSub AssemOut
            ' Add dX
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," move pointer past the comma
            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
            A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
            A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
        Next TempNumArray1
    End If
    ' Last dimension value ends with a close bracket
    DoNumArrCloseBracket0:
    ' Get NumElementsX
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                                 Need 16bit multiply
    ' Add dX
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
    A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AssemOut
End If
A$ = "LSLB": GoSub AssemOut
A$ = "ROLA": C$ = "D=D*2, 16 bit integers in the numeric array": GoSub AssemOut
num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "D points at the start of the destination mem location in the array": GoSub AssemOut

A$ = "TFR": B$ = "D,X": C$ = "Make X the pointer to where this array is stored in RAM": GoSub AssemOut
A$ = "PULS": B$ = "D": C$ = "Save the memory location to write the value that this array equals": GoSub AssemOut
Return 'X pointing at the memory location for the Numeric Array, D is unchanged

' Exits with a Return
HandleNumericArray:
If Verbose > 3 Then Print "Going to deal with  Numeric array"
v = Array(x) * 256 + Array(x + 1): x = x + 2
NV$ = NumericArrayVariables$(v)
If Verbose > 3 Then Print "Numeric array variable is: "; NV$
NumDims = Array(x): x = x + 3 ' Consume the $F5 & open bracket
If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims

If NumDims = 1 Then ' does it only have one dimension? if so it's simpler
    ' Yes just a single dimension array
    If Verbose > 3 Then Print "handling a one dimensional array"
    If Verbose > 3 Then Print #1, "; Started handling the array here:"
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
Else
    ' Handle multi dimensional arrays
    ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)
    If Verbose > 3 Then Print "handling a multi dimensional array"
    A$ = "LDX": B$ = "#_ArrayNum_" + NV$ + "+1": C$ = "X points at the 2nd array Element size": GoSub AssemOut ' X points at the 2nd array Element size
    A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AssemOut
    ' Get d1
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AssemOut ' D = d1
    If NumDims = 2 Then GoTo DoNumArrCloseBracket1 ' skip ahead if we only have 2 dimension in the array
    'Get NumElements2
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AssemOut
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut ' LSB of d1
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut ' D=d1* NumElements2
    A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AssemOut ' Save it on the stack
    A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
    A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
    A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
    Z$ = "!": GoSub AssemOut ' Num Element Pointer is now pointing at NumElements3
    'Get d2
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    ' Add d2
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
    A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
    If Verbose > 2 Then Print "number of dimensions:"; NumDims
    If NumDims > 3 Then
        For TempNumArray1 = 3 To NumDims - 1 ' Number of dimensions in the array - 1 since last ont have a comma seperating it
            ' Get NumElementsX
            A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
            A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
            A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                        Need 16bit muliply
            A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AssemOut
            A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
            A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
            A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
            Z$ = "!": GoSub AssemOut
            ' Add dX
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
            A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
            A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
        Next TempNumArray1
    End If
    DoNumArrCloseBracket1:

    ' Last dimension value ends with a close bracket
    ' Get NumElementsX
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                                 Need 16bit multiply
    ' Add dX
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
    A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AssemOut
End If
A$ = "LSLB": GoSub AssemOut
A$ = "ROLA": C$ = "D=D*2, 16 bit integers in the numeric array": GoSub AssemOut
num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "D points at the start of the destination string": GoSub AssemOut
A$ = "PSHS": B$ = "D": C$ = "Save the memory location to write the value that this array equals": GoSub AssemOut

v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error, looking for = sign while getting Numeric Array in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error, looking for = sign in while getting Numeric Array in";: GoTo FoundError
'Get an expression that ends with an EOL
GoSub GetExpressionB4EOL ' Get the expression before an End of Line
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "STD": B$ = "[,S++]": C$ = "Save D in the array, and fix the stack": GoSub AssemOut
Return


' Returns with X pointing at the memory location for the String Array, D is unchanged
MakeXPointAtStringArray:
If Verbose > 3 Then Print "Going to deal with String array"
v = Array(x) * 256 + Array(x + 1): x = x + 2
SV$ = StringArrayVariables$(v)
If Verbose > 3 Then Print "String array variable is: "; SV$
NumDims = Array(x): x = x + 3 ' Consume the $F5 & open bracket

If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
If NumDims = 1 Then ' does it only have one dimension? if so it's simpler
    ' Yes just a single dimension array
    If Verbose > 3 Then Print "handling a one dimensional array"
    If Verbose > 3 Then Print #1, "; Started handling the array here:"
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
Else
    ' Handle multi dimensional arrays
    ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)
    If Verbose > 3 Then Print "handling a multi dimensional array"
    A$ = "LDX": B$ = "#_ArrayStr_" + SV$ + "+1": C$ = "X points at the 2nd array Element size": GoSub AssemOut ' X points at the 2nd array Element size
    A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AssemOut
    ' Get d1
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AssemOut ' D = d1
    If NumDims = 2 Then GoTo DoStrArrCloseBracket0 ' skip ahead if we only have 2 dimension in the array
    'Get NumElements2
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AssemOut
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut ' LSB of d1
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut ' D=d1* NumElements2
    A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AssemOut ' Save it on the stack
    A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
    A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
    A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
    Z$ = "!": GoSub AssemOut ' Num Element Pointer is now pointing at NumElements3
    'Get d2
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    ' Add d2
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
    A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
    If Verbose > 2 Then Print "number of dimensions:"; NumDims
    If NumDims > 3 Then
        For TempNumArray1 = 3 To NumDims - 1 ' Number of dimensions in the array - 1 since last wont have a comma seperating it
            ' Get NumElementsX
            A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
            A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
            A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                        Need 16bit muliply
            A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AssemOut
            A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
            A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
            A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
            Z$ = "!": GoSub AssemOut
            ' Add dX
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
            A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
            A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
        Next TempNumArray1
    End If
    ' Last dimension value ends with a close bracket
    DoStrArrCloseBracket0:
    ' Get NumElementsX
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                                 Need 16bit multiply
    ' Add dX
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
    A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AssemOut
End If
' * size of each element
If StringArraySize = 255 Then
    ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
    A$ = "TFR": B$ = "B,A": C$ = "D = B * 256": GoSub AssemOut
    A$ = "CLRB": C$ = Chr$(&H22) + Chr$(&H22): GoSub AssemOut
Else
    ' A little slower but saves RAM
    num = StringArraySize: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    A$ = "LDA": B$ = "#" + Num$ + "+1": C$ = "String Array size requested by the user +1 because first digit is the string length": GoSub AssemOut
    A$ = "MUL": C$ = "D = A * B":: GoSub AssemOut
End If
num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
A$ = "ADDD": B$ = "#_ArrayStr_" + SV$ + "+" + Num$: C$ = "D points at the start of the destination string": GoSub AssemOut
A$ = "TFR": B$ = "D,X": C$ = "Make X the pointer to where this array is stored in RAM": GoSub AssemOut
Return 'X pointing at the memory location for the Numeric Array, D is unchanged

' Exits with a Return
HandleStringArray:
If Verbose > 3 Then Print "Going to deal with String array"
v = Array(x) * 256 + Array(x + 1): x = x + 2
SV$ = StringArrayVariables$(v)
If Verbose > 3 Then Print "String array variable is: "; SV$
NumDims = Array(x): x = x + 3 ' Consume the $F5 & open bracket
If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
If NumDims = 1 Then ' does it only have one dimension? if so it's simpler
    ' Yes just a single dimension array
    If Verbose > 3 Then Print "handling a one dimensional array"
    If Verbose > 3 Then Print #1, "; Started handling the array here:"
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
Else
    ' Handle multi dimensional arrays

    ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)
    If Verbose > 3 Then Print "handling a multi dimensional array"
    A$ = "LDX": B$ = "#_ArrayStr_" + SV$ + "+1": C$ = "X points at the 2nd array Element size": GoSub AssemOut ' X points at the 2nd array Element size
    A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AssemOut
    ' Get d1
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AssemOut ' D = d1
    If NumDims = 2 Then GoTo DoStrArrCloseBracket1 ' skip ahead if we only have 2 dimension in the array
    'Get NumElements2
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AssemOut
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut ' LSB of d1
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut ' D=d1* NumElements2
    A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AssemOut ' Save it on the stack
    A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
    A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
    A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
    Z$ = "!": GoSub AssemOut ' Num Element Pointer is now pointing at NumElements3
    'Get d2
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    ' Add d2
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
    A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
    If Verbose > 2 Then Print "number of dimensions:"; NumDims
    If NumDims > 3 Then
        For TempNumArray1 = 3 To NumDims - 1 ' Number of dimensions in the array - 1 since last wont have a comma seperating it
            ' Get NumElementsX
            A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
            A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
            A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                                 Need 16bit multiply
            A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AssemOut
            A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
            A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
            A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
            Z$ = "!": GoSub AssemOut
            ' Add dX
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
            A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
            A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
        Next TempNumArray1
    End If
    DoStrArrCloseBracket1:
    ' Last dimension value ends with a close bracket
    ' Get NumElementsX
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                                 Need 16bit multiply
    ' Add dX
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
    A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AssemOut
End If
' * size of each element
If StringArraySize = 255 Then
    ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
    A$ = "TFR": B$ = "B,A": C$ = "D = B * 256": GoSub AssemOut
    A$ = "CLRB": C$ = Chr$(&H22) + Chr$(&H22): GoSub AssemOut
Else
    ' A little slower but saves RAM
    num = StringArraySize: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    A$ = "LDA": B$ = "#" + Num$ + "+1": C$ = "String Array size requested by the user +1 because first digit is the string length": GoSub AssemOut
    A$ = "MUL": C$ = "D = A * B":: GoSub AssemOut
End If
num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
A$ = "ADDD": B$ = "#_ArrayStr_" + SV$ + "+" + Num$: C$ = "D = D + Start of this array memory": GoSub AssemOut
A$ = "PSHS": B$ = "D": C$ = "Save it on the stack": GoSub AssemOut

v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error, looking for = sign while getting String Array in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error, looking for = sign while getting String Array in";: GoTo FoundError
GoSub GetExpressionB4EOL ' Get the expression before an End of Line
GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00

' Copy _StrVar_PF00 to String Array variable
A$ = "PULS": B$ = "X": C$ = "X points at the start of the destination string": GoSub AssemOut
A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U points at the start of the source string": GoSub AssemOut
A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AssemOut
A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AssemOut
A$ = "BEQ": B$ = "Done@": C$ = "If the length of the string is zero then don't print it (Skip ahead)": GoSub AssemOut
Z$ = "!"
A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AssemOut
A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
Z$ = "Done@": GoSub AssemOut
Print #1, "" ' Leave a space between sections so Done@ will work for each section
Return

' Exits with a return
HandleNumericVariable:
v = Array(x) * 256 + Array(x + 1): x = x + 2
NV$ = "_Var_" + NumericVariable$(v)
If Verbose > 3 Then Print "Numeric variable is: "; NV$
v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error12, looking for = sign in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error13, looking for = sign in";: GoTo FoundError
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
' Check Expression$ for a variable or numeric commands, if there aren't any, then ExType=0 and NewExpression$ will be the expression without any tokenized characters
FirstChar = Asc(Left$(Expression$, 1))
If FirstChar = &HF4 Then
    ' We found a floating point number
    If Len(Expression$) <> 3 Then
        Print "Something is wrong with the floating point variable being assigned to "; NV; " on";: GoTo FoundError
    End If
    v = Asc(Mid$(Expression$, 2, 1)) * 256 + Asc(Right$(Expression$, 1))
    SourceFPV$ = "_FPVar_" + FloatVariable$(v)
    'Let's round the value by 0.5
    A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AssemOut
    A$ = "LDX": B$ = "#" + SourceFPV$: C$ = "Point X at the floaing point variable": GoSub AssemOut
    A$ = "JSR": B$ = "FPLOD": C$ = "Copy FP NUMBER FROM ADDRESS X AND PUSH ONTO USER STACK": GoSub AssemOut
    A$ = "LDX": B$ = "#FPHALF": C$ = "Point X at the floating point value for 0.5 (part of the FP library)": GoSub AssemOut
    A$ = "JSR": B$ = "FPLOD": C$ = "Copy FP NUMBER FROM ADDRESS X AND PUSH ONTO USER STACK": GoSub AssemOut
    A$ = "JSR": B$ = "FPADD": C$ = "FLOATING POINT ADDITION  (Float @ -10,U + Float @ -5,U, result Float @ -5,U)": GoSub AssemOut
    A$ = "JSR": B$ = "FP2INT": C$ = "Convert FP number at -5,U to a signed 16-bit number in D": GoSub AssemOut
    A$ = "STD": B$ = NV$: C$ = "Save to numeric variable": GoSub AssemOut
Else
    ' Check Expression$ for a variable or numeric commands, if there aren't any, then ExType=0 and NewExpression$ will be the expression without any tokenized characters
    GoSub CheckForVariable
    If ExType = 0 Then
        GoSub EvaluateNewExpression
        num = D: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDD": B$ = "#" + Num$: C$ = "Since we don't have any variables or numeric commands, this is the calculated value": GoSub AssemOut
    Else
        ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
    End If
    A$ = "STD": B$ = NV$: C$ = "Save Numeric variable": GoSub AssemOut
End If
Return

HandleFloatVariable:
v = Array(x) * 256 + Array(x + 1): x = x + 2
FPV$ = "_FPVar_" + FloatVariable$(v)
v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error12, looking for = sign in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error13, looking for = sign in";: GoTo FoundError
Start1 = x
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
EP = 1 'pointer in Expression$
FirstChar = Asc(Mid$(Expression$, EP, 1)): EP = EP + 1
Select Case FirstChar
    Case &HFE
        'Handle numeric/float command
        CheckFloatIF:
        v = Asc(Mid$(Expression$, EP, 1)) * 256 + Asc(Mid$(Expression$, EP + 1, 1)): EP = EP + 2 ' Get numeric command ID
        Select Case v
            Case FLOATADD_CMD
                FloatCMD$ = "FPADD"
                ArgCount = 2
            Case FLOATSUB_CMD
                FloatCMD$ = "FPSUB"
                ArgCount = 2
            Case FLOATMUL_CMD
                FloatCMD$ = "FPMUL"
                ArgCount = 2
            Case FLOATDIV_CMD
                FloatCMD$ = "FPDIV"
                ArgCount = 2
            Case CMPGT_CMD
                FloatCMD$ = "FPCMP"
                ArgCount = 2
                CompType = 1
            Case CMPGE_CMD
                FloatCMD$ = "FPCMP"
                ArgCount = 2
                CompType = 2
            Case CMPEQ_CMD
                FloatCMD$ = "FPCMP"
                ArgCount = 2
                CompType = 3
            Case CMPLE_CMD
                FloatCMD$ = "FPCMP"
                ArgCount = 2
                CompType = 4
            Case CMPLT_CMD
                FloatCMD$ = "FPCMP"
                ArgCount = 2
                CompType = 5
            Case FLOATSQR_CMD
                FloatCMD$ = "FPSQRT"
                ArgCount = 1
            Case FLOATSIN_CMD
                FloatCMD$ = "FPSIN"
                ArgCount = 1
            Case FLOATCOS_CMD
                FloatCMD$ = "FPCOS"
                ArgCount = 1
            Case FLOATTAN_CMD
                FloatCMD$ = "FPTAN"
                ArgCount = 1
            Case FLOATATAN_CMD
                FloatCMD$ = "FPATAN"
                ArgCount = 1
            Case FLOATEXP_CMD
                FloatCMD$ = "FPEXP"
                ArgCount = 1
            Case FLOATLOG_CMD
                FloatCMD$ = "FPLN"
                ArgCount = 1
            Case INT_CMD
                EP = EP + 2 ' consume the open bracket
                Expression$ = Mid$(Expression$, EP, Len(Expression$) - EP - 1)
                ' Check Expression$ for a variable or numeric commands, if there aren't any, then ExType=0 and NewExpression$ will be the expression without any tokenized characters
                GoSub CheckForVariable
                If ExType = 0 Then
                    GoSub EvaluateNewExpression
                    num = D: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDD": B$ = "#" + Num$: C$ = "Since we don't have any variables or numeric commands, this is the calculated value": GoSub AssemOut
                Else
                    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
                End If
                A$ = "LDU": B$ = "#" + FPV$: C$ = "Point U at the beginning of the Floating point variable": GoSub AssemOut
                A$ = "JSR": B$ = "INT2FP": C$ = "Convert signed 16-BIT integer in D to floating point number and store it at U, U=U+5": GoSub AssemOut
                Return
            Case STRTOFLOAT_CMD
                ' Handle String to Float command
                EP = EP + 2 ' consume the open bracket
                Expression$ = Mid$(Expression$, EP, Len(Expression$) - EP - 1)
                GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
                ' Copy _StrVar_PF00 to string variable
                A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X points at the start of the source string": GoSub AssemOut
                A$ = "LDB": B$ = ",X+": C$ = "Get String length, Incrment X": GoSub AssemOut
                A$ = "ABX": C$ = "X=X+B": GoSub AssemOut
                A$ = "CLR": B$ = ",X": C$ = "Clear the end of the string": GoSub AssemOut
                A$ = "LDY": B$ = "#_StrVar_PF00+1": C$ = "Y points at the start of the source string": GoSub AssemOut
                A$ = "LDU": B$ = "#" + FPV$: C$ = "U points at the floating point number": GoSub AssemOut
                A$ = "JSR": B$ = "SCANNUM": C$ = "Convert String at Y to FP number at U": GoSub AssemOut
                Return
            Case Else
                Print "Can't figure out the type of number/expression, maybe it needs to use INT() on";: GoTo FoundError
        End Select
        If Asc(Mid$(Expression$, EP, 1)) = &HF5 And Asc(Mid$(Expression$, EP + 1, 1)) = &H28 Then
            EP = EP + 2 'move past the open bracket
            If ArgCount = 1 Then
                v = Asc(Mid$(Expression$, EP, 1))
                If v = Asc("-") Then
                    negval = 1
                Else
                    negval = 0
                End If
                If (v >= Asc("0") And v <= Asc("9")) Or v = Asc(".") Then
                    ' This is a number value
                    A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AssemOut
                    FPString$ = Mid$(Expression$, EP, Len(Expression$) - EP - 1)
                    GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
                    A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number": GoSub AssemOut
                    A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AssemOut
                    A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number": GoSub AssemOut
                    A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AssemOut
                    A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number": GoSub AssemOut
                    A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AssemOut
                    'If we have a minus sign make this a negative of current value
                    If negval = 1 Then
                        'there is a negative sign
                        A$ = "JSR": B$ = "FPNEG": C$ = "Do FP negation": GoSub AssemOut
                    End If
                    A$ = "JSR": B$ = FloatCMD$: C$ = "Do the FP operation": GoSub AssemOut
                    A$ = "LDD": B$ = "-5,U": C$ = "First two digits of the FP number": GoSub AssemOut
                    A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AssemOut
                    A$ = "LDD": B$ = "-3,U": C$ = "Third and fourth digits of the FP number": GoSub AssemOut
                    A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AssemOut
                    A$ = "LDA": B$ = "-1,U": C$ = "Fifth digit of the FP number": GoSub AssemOut
                    A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AssemOut
                Else
                    If v = &HF4 Then
                        ' We have a FP variable
                        A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AssemOut
                        EP = EP + 1 ' consume the &HF4
                        v = Asc(Mid$(Expression$, EP, 1)) * 256 + Asc(Mid$(Expression$, EP + 1, 1))
                        SourceFPV$ = "_FPVar_" + FloatVariable$(v)
                        A$ = "LDD": B$ = SourceFPV$: C$ = "First two digits of the source FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDD": B$ = SourceFPV$ + "+2": C$ = "Third and fourth digits of source the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDA": B$ = SourceFPV$ + "+4": C$ = "Fifth digit of the source FP number": GoSub AssemOut
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AssemOut
                        'If we have a minus sign make this a negative of current value
                        If negval = 1 Then
                            'there is a negative sign
                            A$ = "JSR": B$ = "FPNEG": C$ = "Do FP negation": GoSub AssemOut
                        End If
                        A$ = "JSR": B$ = FloatCMD$: C$ = "Do the FP operation": GoSub AssemOut
                        A$ = "LDD": B$ = "-5,U": C$ = "First two digits of the FP number": GoSub AssemOut
                        A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AssemOut
                        A$ = "LDD": B$ = "-3,U": C$ = "Third and fourth digits of the FP number": GoSub AssemOut
                        A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AssemOut
                        A$ = "LDA": B$ = "-1,U": C$ = "Fifth digit of the FP number": GoSub AssemOut
                        A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AssemOut
                    Else
                        If v = &HFE Then
                            ' Might have the INT command
                            v = Asc(Mid$(Expression$, EP + 1, 1)) * 256 + Asc(Mid$(Expression$, EP + 2, 1)): EP = EP + 3 ' move past the INT command
                            If v = INT_CMD Then
                                ' Treat it like a normal unsigned integer expession
                                EP = EP + 2 ' consume the open bracket
                                Expression$ = Mid$(Expression$, EP, Len(Expression$) - EP - 3)
                                ' Check Expression$ for a variable or numeric commands, if there aren't any, then ExType=0 and NewExpression$ will be the expression without any tokenized characters
                                GoSub CheckForVariable
                                If ExType = 0 Then
                                    GoSub EvaluateNewExpression
                                    num = D: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                                    A$ = "LDD": B$ = "#" + Num$: C$ = "Since we don't have any variables or numeric commands, this is the calculated value": GoSub AssemOut
                                Else
                                    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
                                End If
                                A$ = "LDU": B$ = "#FPStackspace": C$ = "Point U at the beginning of the Floating point stack": GoSub AssemOut
                                A$ = "JSR": B$ = "INT2FP": C$ = "Convert signed 16-BIT integer in D to floating point number and store it at U, U=U+5": GoSub AssemOut
                                A$ = "JSR": B$ = FloatCMD$: C$ = "Do the FP operation": GoSub AssemOut
                                A$ = "LDD": B$ = "-5,U": C$ = "First two digits of the FP number": GoSub AssemOut
                                A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AssemOut
                                A$ = "LDD": B$ = "-3,U": C$ = "Third and fourth digits of the FP number": GoSub AssemOut
                                A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AssemOut
                                A$ = "LDA": B$ = "-1,U": C$ = "Fifth digit of the FP number": GoSub AssemOut
                                A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AssemOut
                            Else
                                Print "Can't figure out the type of number/expression, maybe it needs to use INT() on";: GoTo FoundError
                            End If
                        End If
                    End If
                End If
            Else
                'Two arguments
                x = Start1 + 5
                If Array(x) = &HFC And Array(x + 1) = Asc("-") Then
                    negval = 1
                    x = x + 2
                Else
                    negval = 0
                End If
                v = Array(x)
                Select Case v
                    Case Asc("0") To Asc("9")
                        ' This is a number value
                        A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AssemOut
                        FPString$ = Chr$(Array(x)): x = x + 1
                        While Array(x) <> &HF5 And Array(x + 1) <> Asc(",")
                            FPString$ = FPString$ + Chr$(Array(x)): x = x + 1
                        Wend
                        x = x + 2 'move past the comma
                        GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
                        A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number": GoSub AssemOut
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AssemOut
                        'If we have a minus sign make this a negative of current value
                        If negval = 1 Then
                            'there is a negative sign
                            A$ = "JSR": B$ = "FPNEG": C$ = "Do FP negation": GoSub AssemOut
                        End If
                    Case Asc(".")
                        ' This is a number value that starts with a decimal
                        A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AssemOut
                        FPString$ = Chr$(Array(x)): x = x + 1
                        While Array(x) <> &HF5 And Array(x + 1) <> Asc(",")
                            FPString$ = FPString$ + Chr$(Array(x)): x = x + 1
                        Wend
                        x = x + 2 'move past the comma
                        GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
                        A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number": GoSub AssemOut
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AssemOut
                        'If we have a minus sign make this a negative of current value
                        If negval = 1 Then
                            'there is a negative sign
                            A$ = "JSR": B$ = "FPNEG": C$ = "Do FP negation": GoSub AssemOut
                        End If
                    Case &HF4
                        ' We have an FP variable
                        A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AssemOut
                        v = Array(x + 1) * 256 + Array(x + 2): x = x + 3 ' Consume the &HF4 and the variable  & the comma
                        SourceFPV$ = "_FPVar_" + FloatVariable$(v)
                        If Array(x) <> &HF5 And Array(x + 1) <> Asc(",") Then Print "Can't find comma with floating point command on";: GoTo FoundError
                        x = x + 2 'move past the comma
                        A$ = "LDD": B$ = SourceFPV$: C$ = "First two digits of the source FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDD": B$ = SourceFPV$ + "+2": C$ = "Third and fourth digits of source the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDA": B$ = SourceFPV$ + "+4": C$ = "Fifth digit of the source FP number": GoSub AssemOut
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AssemOut
                        'If we have a minus sign make this a negative of current value
                        If negval = 1 Then
                            'there is a negative sign
                            A$ = "JSR": B$ = "FPNEG": C$ = "Do FP negation": GoSub AssemOut
                        End If
                    Case &HFE
                        ' Might have the INT command
                        v = Array(x + 1) * 256 + Array(x + 2): x = x + 3 ' move past the INT command
                        If v = INT_CMD Then
                            ' Found INT Command, Get the first expression
                            GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
                            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
                            A$ = "LDU": B$ = "#FPStackspace": C$ = "Point U at the beginning of the Floating point stack": GoSub AssemOut
                            A$ = "JSR": B$ = "INT2FP": C$ = "Convert signed 16-BIT integer in D to floating point number and store it at U, U=U+5": GoSub AssemOut
                        Else
                            Print "Can't figure out the type of number/expression, maybe it needs to use INT() on";: GoTo FoundError
                        End If
                End Select
                If Array(x) = &HFC And Array(x + 1) = Asc("-") Then
                    negval = 1
                    x = x + 2
                Else
                    negval = 0
                End If
                v = Array(x)
                Select Case v
                    Case Asc("0") To Asc("9")
                        ' This is a number value
                        A$ = "LDU": B$ = "#FPStackspace+10": C$ = "Point U at the beginning of the Floating point stack+10": GoSub AssemOut
                        FPString$ = Chr$(Array(x)): x = x + 1
                        While Array(x) <> &HF5 And Array(x + 1) <> Asc(")")
                            FPString$ = FPString$ + Chr$(Array(x)): x = x + 1
                        Wend
                        x = x + 2 'move past the comma
                        GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
                        A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number": GoSub AssemOut
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AssemOut
                    Case Asc(".")
                        ' This is a number value that starts with a decimal
                        A$ = "LDU": B$ = "#FPStackspace+10": C$ = "Point U at the beginning of the Floating point stack+10": GoSub AssemOut
                        FPString$ = Chr$(Array(x)): x = x + 1
                        While Array(x) <> &HF5 And Array(x + 1) <> Asc(")")
                            FPString$ = FPString$ + Chr$(Array(x)): x = x + 1
                        Wend
                        x = x + 2 'move past the comma
                        GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
                        A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number": GoSub AssemOut
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AssemOut
                    Case &HF4
                        ' We have a FP variable
                        A$ = "LDU": B$ = "#FPStackspace+10": C$ = "Point U at the beginning of the Floating point stack+10": GoSub AssemOut
                        v = Array(x + 1) * 256 + Array(x + 2): x = x + 3 ' Consume the &HF4 and the variable & the close bracket
                        SourceFPV$ = "_FPVar_" + FloatVariable$(v)
                        If Array(x) <> &HF5 And Array(x + 1) <> Asc(")") Then Print "Can't find close bracket with floating point command on";: GoTo FoundError
                        x = x + 2 'move past the comma
                        A$ = "LDD": B$ = SourceFPV$: C$ = "First two digits of the source FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDD": B$ = SourceFPV$ + "+2": C$ = "Third and fourth digits of source the FP number": GoSub AssemOut
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AssemOut
                        A$ = "LDA": B$ = SourceFPV$ + "+4": C$ = "Fifth digit of the source FP number": GoSub AssemOut
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AssemOut
                    Case &HFE
                        ' Might have the INT command
                        v = Array(x + 1) * 256 + Array(x + 2): x = x + 3 ' move past the INT command
                        If v = INT_CMD Then
                            ' Found INT Command, Get the 2nd expression
                            GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
                            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
                            A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack": GoSub AssemOut
                            A$ = "JSR": B$ = "INT2FP": C$ = "Convert signed 16-BIT integer in D to floating point number and store it at U, U=U+5": GoSub AssemOut
                        Else
                            Print "Can't figure out the type of number/expression, maybe it needs to use INT() on";: GoTo FoundError
                        End If
                End Select
                'If we have a minus sign make this a negative of current value
                If negval = 1 Then
                    'there is a negative sign
                    A$ = "JSR": B$ = "FPNEG": C$ = "Do FP negation": GoSub AssemOut
                End If
                A$ = "JSR": B$ = FloatCMD$: C$ = "Do the FP operation": GoSub AssemOut
                If FloatCMD$ = "FPCMP" Then
                    'Doing a Float Compare
                    ' returns with a LDD with the result, zero is false, #$FFFF if true
                    Select Case CompType
                        Case 1
                            'CMPGT_CMD
                            A$ = "BGT": B$ = ">": C$ = "Branch if greater than": GoSub AssemOut
                        Case 2
                            'CMPGE_CMD
                            A$ = "BGE": B$ = ">": C$ = "Branch if greater than or Equal": GoSub AssemOut
                        Case 3
                            'CMPEQ_CMD
                            A$ = "BEQ": B$ = ">": C$ = "Branch if Equal": GoSub AssemOut
                        Case 4
                            'CMPLE_CMD
                            A$ = "BLE": B$ = ">": C$ = "Branch if less than or equal": GoSub AssemOut
                        Case 5
                            'CMPLT_CMD
                            A$ = "BLT": B$ = ">": C$ = "Branch if less than": GoSub AssemOut
                    End Select
                    A$ = "LDD": B$ = "#$0000": C$ = "Flag as false": GoSub AssemOut
                    A$ = "BRA": B$ = "@FPComp": C$ = "skip ahead": GoSub AssemOut
                    Z$ = "!"
                    A$ = "LDD": B$ = "#$FFFF": C$ = "Flag as true": GoSub AssemOut
                    Z$ = "@FPComp": GoSub AssemOut
                    Print #1, ' Leave space so @ works correctly
                    Return ' Go back to IF FloatingPoint Compare
                Else
                    A$ = "LDD": B$ = "-5,U": C$ = "First two digits of the FP number": GoSub AssemOut
                    A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AssemOut
                    A$ = "LDD": B$ = "-3,U": C$ = "Third and fourth digits of the FP number": GoSub AssemOut
                    A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AssemOut
                    A$ = "LDA": B$ = "-1,U": C$ = "Fifth digit of the FP number": GoSub AssemOut
                    A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AssemOut
                End If
            End If
        Else
            Print "No bracket after Floatingpoint command on";: GoTo FoundError
        End If
    Case &HF2
        'Integer numeric variable
        v = Asc(Mid$(Expression$, 2, 1)) * 256 + Asc(Right$(Expression$, 1))
        SourceVar$ = "_Var_" + NumericVariable$(v)
        A$ = "LDD": B$ = SourceVar$: C$ = "Get the signed 16 bit number in D": GoSub AssemOut
        A$ = "LDU": B$ = "#" + FPV$: C$ = "Point U at the start of the FP variable": GoSub AssemOut
        A$ = "JSR": B$ = "INT2FP": C$ = "Convert signed 16-BIT integer in D to floating point number and store it at U, U=U+5": GoSub AssemOut
    Case &HF4
        'Floating point variable
        If Len(Expression$) <> 3 Then
            Print "Something is wrong with the floating point variable being assigned to "; FPV$; " on";: GoTo FoundError
        End If
        v = Asc(Mid$(Expression$, 2, 1)) * 256 + Asc(Right$(Expression$, 1))
        SourceFPV$ = "_FPVar_" + FloatVariable$(v)
        A$ = "LDD": B$ = SourceFPV$: C$ = "First two digits of the source FP number": GoSub AssemOut
        A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AssemOut
        A$ = "LDD": B$ = SourceFPV$ + "+2": C$ = "Third and fourth digits of source the FP number": GoSub AssemOut
        A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AssemOut
        A$ = "LDA": B$ = SourceFPV$ + "+4": C$ = "Fifth digit of the source FP number": GoSub AssemOut
        A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AssemOut
    Case Else
        ' A number
        FPString$ = Expression$
        GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
        A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number": GoSub AssemOut
        A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AssemOut
        A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number": GoSub AssemOut
        A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AssemOut
        A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number": GoSub AssemOut
        A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AssemOut
End Select
Return
' Convert numbers to Floating point format
FPConversion:
' Read input from the user
FPString$ = RTrim$(FPString$)

' It's a number, convert it
FloatNum = Val(FPString$)
If FloatNum = 0 Then
    sign = 0
    expo = 0
    mant = 0
Else
    If FloatNum < 0 Then sign = &H80 Else sign = 0
    FloatNum = Abs(FloatNum)
    expo = &H9F

    ' Normalize mantissa
    Do While FloatNum < 2147483648#
        FloatNum = FloatNum * 2
        expo = expo - 1
    Loop
    Do While FloatNum >= 4294967296#
        FloatNum = FloatNum / 2
        expo = expo + 1
    Loop

    mant = Int(FloatNum + 0.5)
End If

' Create the 5-byte floating point representation
FPbyte(0) = expo
FPbyte(1) = (Val("&H" + Left$(Hex$(mant), 2)) And &H7F) Or sign
FPbyte(2) = Val("&H" + Mid$(Hex$(mant), 3, 2))
FPbyte(3) = Val("&H" + Mid$(Hex$(mant), 5, 2))
FPbyte(4) = Val("&H" + Right$(Hex$(mant), 2))
FPBytes$ = Right$("00" + Hex$(FPbyte(0)), 2)
FPBytes$ = FPBytes$ + Right$("00" + Hex$(FPbyte(1)), 2)
FPBytes$ = FPBytes$ + Right$("00" + Hex$(FPbyte(2)), 2)
FPBytes$ = FPBytes$ + Right$("00" + Hex$(FPbyte(3)), 2)
FPBytes$ = FPBytes$ + Right$("00" + Hex$(FPbyte(4)), 2)
Return

CheckForVariable:
' Check Expression$ for a variable or numeric command, if there aren't any, then calculate the expression and use that for a LDD
ExType = 0
NewExpression$ = ""
For ii = 1 To Len(Expression$)
    ChecForVariable2:
    v = Asc(Mid$(Expression$, ii, 1))
    If v = &HF5 Or v = &HFC Then ii = ii + 1: GoTo ChecForVariable2
    If v > &HEF Then ExType = 2: Return
    NewExpression$ = NewExpression$ + Chr$(v)
Next ii
Return

'Exits with a Return
HandleStringVariable:
v = Array(x) * 256 + Array(x + 1): x = x + 2
StringVar$ = "_StrVar_" + StringVariable$(v)
If Verbose > 3 Then Print "String variable is: "; StringVar$
v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error14, looking for = sign in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error15, looking for = sign in";: GoTo FoundError
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$

EP = 1 'pointer in Expression$
FirstChar = Asc(Mid$(Expression$, EP, 1)): EP = EP + 1
If FirstChar = &HFE Then
    'Handle numeric/float command
    v = Asc(Mid$(Expression$, EP, 1)) * 256 + Asc(Mid$(Expression$, EP + 1, 1)): EP = EP + 4 ' Get numeric command ID, move past open bracket
    If v = FLOATTOSTR_CMD Then
        ' Convert floating point number to string
        v = Asc(Mid$(Expression$, EP, 1)): EP = EP + 1
        If v = &HF4 Then
            v = Asc(Mid$(Expression$, EP, 1)) * 256 + Asc(Mid$(Expression$, EP + 1, 1)): EP = EP + 2
            FPV$ = "_FPVar_" + FloatVariable$(v)
            A$ = "LDX": B$ = "#" + FPV$: C$ = "Point X at the beginning of the Floating point number": GoSub AssemOut
            A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AssemOut
            A$ = "JSR": B$ = "FPLOD": C$ = "LOAD FP NUMBER FROM ADDRESS X AND PUSH ONTO FP STACK": GoSub AssemOut
            A$ = "LDY": B$ = "#" + StringVar$: C$ = "Y points at the destination string": GoSub AssemOut
            A$ = "JSR": B$ = "FPSCIENT": C$ = "CONVERT FP NUMBER TO STRING AT ADDRESS Y IN SCIENTIFIC NOTATION": GoSub AssemOut
        Else
            Print "Must only have one floating point variable inside the FLOATTOSTR brackets on";: GoTo FoundError
        End If
    End If
Else
    GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
    ' Copy _StrVar_PF00 to string variable
    A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U points at the start of the source string": GoSub AssemOut
    A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AssemOut
    A$ = "LDX": B$ = "#" + StringVar$: C$ = "X points at the length of the destination string": GoSub AssemOut
    A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AssemOut
    A$ = "BEQ": B$ = "Done@": C$ = "If the length of the string is zero then don't print it (Skip ahead)": GoSub AssemOut
    Z$ = "!"
    A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
    A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AssemOut
    A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
    A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
    Z$ = "Done@": GoSub AssemOut
    Print #1, "" ' Leave a space between sections so Done@ will work for each section
End If
Return

ConsumeCommentsAndEOL:
If v = &H0D Or v = &H3A Then Return
Do Until v = &HF5 And Array(x) = &H0D 'consume any comments and the EOL
    v = Array(x): x = x + 1
Loop
v = Array(x): x = x + 1
Return

SkipUntilEOLColon:
If v = &H0D Or v = &H3A Then Return
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' skip until we find an EOL or a Colon
    v = Array(x): x = x + 1
Loop
v = Array(x): x = x + 1
Return

DoFOR:
FORCount = FORCount + 1
FORStackPointer = FORStackPointer + 1
FORSTack(FORStackPointer) = FORCount
v = Array(x): x = x + 1
If v <> &HF2 Then Print "Error getting variable needed in the FOR command on";: GoTo FoundError
'ForJump(Array(x) * 256 + Array(x + 1)) = FORCount ' Set the numeric variable name/number to this ForJump #
CompVar = Array(x) * 256 + Array(x + 1) ' Comparison Variable
' Change the bytes of the "TO" command to a $F50D so we can use the HandleNumericVariable routine to setup the FOR X=Y  part
Start = x ' Point to the variable before the = sign
Do Until (v = &HFF And Array(x) * 256 + Array(x + 1) = TO_CMD) Or (v = &HF5 And Array(x) = &H0D)
    v = Array(x): x = x + 1
Loop
If v = &HF5 Then v = Array(x): x = x + 1
If v = &H0D Then Print "Error assigning a value to variable in the FOR command on";: GoTo FoundError
' Found the TO command
PointAtTO = x - 1 ' Remember where the TO command is
Array(PointAtTO) = &HF5
Array(PointAtTO + 1) = &H0D ' temporarily change the space before the TO command to a $F50D
x = Start ' Point at the variable before the =
GoSub HandleNumericVariable ' Handle code such as X=Y*3 and returns with value of Y*3 in _Var_X, NV$ has the variable name
A$ = "ROLA": C$ = "Move sign bit to the carry": GoSub AssemOut
A$ = "ROL": B$ = ",-S": C$ = "Save the Start sign bit on the stack": GoSub AssemOut
x = PointAtTO + 3 ' x now points past the TO command
GoSub GetExpressionB4EOLOrCommand 'Handle an expression that ends with a colon or End of a Line or a general command like TO or STEP
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression value is now in D, x now points after the EOL/Colon/$FF
' D now has the value we need to Compare against each time we do a FOR Loop
' Self Mod Code where we compare the value of the variable aggainst what is now D
num = FORCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
A$ = "STD": B$ = "FOR_Check_" + Num$ + "+2": C$ = "Save the value to compare with (self mod below)": GoSub AssemOut
A$ = "ROLA": C$ = "Move sign bit to the carry": GoSub AssemOut
A$ = "ROL": B$ = ",S": C$ = "Save the End sign bit on the stack": GoSub AssemOut

' Check for a STEP command
If Array(x) = &HFF Then
    If Array(x + 1) * 256 + Array(x + 2) = STEP_CMD Then
        'We have a STEP command so get the value of in D
        x = x + 3 ' move to the STEP amount
        GoSub GetExpressionB4EOLOrCommand 'Handle an expression that ends with a colon or End of a Line or another command like TO or STEP
        ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression value is now in D, x now points after the EOL/Colon/$FF
    Else
        Print "Error FOR command has another command instead of a STEP command on";: GoTo FoundError
    End If
Else
    ' No STEP command, default to a STEP value of 1
    A$ = "LDD": B$ = "#$0001": C$ = "No STEP for this FOR so set default step value to 1": GoSub AssemOut
End If
num = FORCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
A$ = "STD": B$ = "FOR_ADD_" + Num$ + "+1": C$ = "Save the value to ADDD for each FOR/NEXT loop (self mod below)": GoSub AssemOut
A$ = "ROLA": C$ = "Move sign bit to the carry": GoSub AssemOut
A$ = "LDA": B$ = ",S+": C$ = "Get the sign bits into A and fix the stack": GoSub AssemOut
A$ = "ROLA": C$ = "Save the STEP sign bit in A": GoSub AssemOut

A$ = "ANDA": B$ = "#%00000111": C$ = "Get only the bits we care about": GoSub AssemOut
A$ = "BNE": B$ = ">": C$ = "If it's not zero thenskip ahead": GoSub AssemOut
A$ = "LDD": B$ = "#$1022": C$ = "opcode for LBHI - FOR X=10 to 1000 Step 1": GoSub AssemOut
A$ = "BRA": B$ = "@ForSelfMod": C$ = "Go save opcode in the FOR compare loop": GoSub AssemOut
Z$ = "!"
A$ = "LDB": B$ = "#$2E": C$ = "Default is BGT opcode": GoSub AssemOut
A$ = "RORA": C$ = "Move step sign into the carry bit": GoSub AssemOut
A$ = "SBCB": B$ = "#$00": C$ = "B=B- carry bit, if carry is a 1 then opcode will be BLT": GoSub AssemOut
A$ = "LDA": B$ = "#$10": C$ = "Make the opcode a Long branch": GoSub AssemOut
num = FORCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
Z$ = "@ForSelfMod": GoSub AssemOut
A$ = "STD": B$ = "FOR_Check_" + Num$ + "+4": C$ = "Save the BRANCH opcode (self mod below)": GoSub AssemOut

A$ = "BRA": B$ = "@SkipFirst": C$ = "Skip past the check, the first time": GoSub AssemOut
' FOR loop starts here
Z$ = "ForLoop_" + Num$: C$ = "Start of FOR Loop": GoSub AssemOut
A$ = "LDD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Get the varible needed for this NEXT command": GoSub AssemOut
Z$ = "FOR_ADD_" + Num$: GoSub AssemOut
A$ = "ADDD": B$ = "#$FFFF": C$ = "Add this amount each iteration of the FOR loop (self modded when the FOR is setup)": GoSub AssemOut
A$ = "STD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Save the updated value of the numeric varible needed for this NEXT command": GoSub AssemOut
Z$ = "FOR_Check_" + Num$: GoSub AssemOut
A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AssemOut
A$ = "LBGT": B$ = ">NEXTDone_" + Num$: C$ = "Branch type (LBLE/LBGE) will be changed depending on a add or subtract with each loop": GoSub AssemOut
Z$ = "@SkipFirst": GoSub AssemOut
Print #1, ""
Return
DoGOTO:
Temp$ = ""
v = Array(x): x = x + 1
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' could be EOL or a colon if it's part of an IF/THEN/ELSE or REMark
    Temp$ = Temp$ + Chr$(v)
    v = Array(x): x = x + 1
Loop
x = x + 1
A$ = "BRA": B$ = "_L" + Temp$: C$ = "GOTO " + Temp$: GoSub AssemOut
Return
DoREM:
DoREMApostrophe:
' Check for special commands in a REM or ' line
Temp$ = ""
v = Array(x): x = x + 1
Do Until v = &HF5 And Array(x) = &H0D
    Temp$ = Temp$ + Chr$(v)
    v = Array(x): x = x + 1
Loop
x = x - 1 ' Point at the $F5 again
If Temp$ = "" Then Return
' Check for commands
p = InStr(Temp$, "ADDASSEM")
If p > 0 Then
    x = x + 2
    ' We have the command ADDASSEM , copy the lines directly out unitl we find the line ' ENDASSEM
    REM_AddCode1:
    Temp$ = ""
    v = Array(x): x = x + 1
    While v <> &H0D
        Temp$ = Temp$ + Chr$(v)
        v = Array(x): x = x + 1
    Wend
    ' Check if this line is the last
    p = InStr(Temp$, "ENDASSEM")
    If p > 0 Then Print #1, "; ' ENDASSEM:": Print #1,: Return
    Print #1, Temp$
    GoTo REM_AddCode1
End If
Return
DoELSE:
num = ElseStack(IFSP): GoSub NumAsString 'num=IFCount associated with this IFProc
If num < 10 Then Num$ = "0" + Num$
A$ = "BRA": B$ = "_IFDone_" + Num$: C$ = "Jump to END IF line": GoSub AssemOut
Z$ = "_ELSE_" + Num$: C$ = "If result is zero = FALSE then jump to ELSE/Next line": GoSub AssemOut
GoTo ConsumeCommentsAndEOL ' Consume any comments and the EOL and Return

DoELSEIF:
' If Process
' IFCount is the global # of IF's in the BASIC program
' IFProc is the number of IF's currently being processed
'
' Everytime we get an IF we:
' IF IFProc>0 then
' Do the evaluation and
' IF ELSELocation(IFProc) >0 then
' BRANCH TO AN ELSE_IFStack(IFProc)_IFPROC
' ELSE
' BRANCH TO AN IFDONE_IFStack(IFProc)_IFPROC
' IFProc=IFProc-1
' Return
' Otherwise if IFProc=0 then do below (We found a new IF)

' IFCount=IFCount+1
' IFProc=IFProc+1

' Push the IFCounter on the IFStack(IFProc)
' ELSELocation(IFProc) = 0
' Scan IF's until we get the END IF associated with our IF
' While looking for our END IF, if we come across another IF then we recursively hit this same IF routine
' IF we come across an ELSE then save it in array ELSELocation(IFProc)=IFProc where it is associated with the IFParse number we are doing
' IF we come across an END IF then we:
'       IFProc=IFProc-1
'       if IFProc is 0 then we found the last END IF and all the nested IFs are found and recorded
'       IF IFProc is not 0 then keep looping
'
' 2nd part of IF (Find if this IF has an ELSE to jump to or an END IF)
' Do the evaluation and
' IF ELSELocation(IFProc) >0 then
' BRANCH TO AN ELSE_IFStack(IFProc)_IFPROC
' ELSE
' BRANCH TO AN IFDONE_IFStack(IFProc)_IFPROC
' IFProc=IFProc-1
' Return


'DoELSE:
'ELSE
' Add label  ELSE_IFStack(IFProc)_IFPROC
' Return

'DoENDIF:
' Add Label  IFDONE_IFStack(IFProc)_IFPROC
' IFProc=IFProc-1


' Found an IF
DoIF:
If ENDIFCheck > 0 Then GoTo IFProcessed ' We've already processed this IF so skip processing again
FirstIFLocation = x ' This is the point where the expression starts
ElseCount = 0

NestedIF:
IFLocation = x ' This is the point where the expression starts
IfCount = IfCount + 1
IFProc = IFProc + 1
IFSTack(IFProc) = IfCount 'If Stack
ElseStack(IFProc) = IfCount ' Else Stack
ELSELocation(IFProc) = 0
ENDIFCheck = 1
FoundELSE = 0
GoSub DoesThisIFHaveAnELSE ' Check if this IF has an ELSE if so FoundELSE will = 1
ELSELocation(IFProc) = FoundELSE

x = IFLocation ' x = the point where the expression starts for the first IF

'Keep checking until we get an END IF that goes with the current IF (adding to IFProc if we find more IFs
ENDIFCheck = 0
FindElses:
If x + 4 > Filesize Then GoTo GotNestedIFs ' Keep checking unless we get to the end of the file
v = Array(x): x = x + 1 'get a byte
If v = &HFF And Array(x) * 256 + Array(x + 1) = END_CMD And Array(x + 2) = &HFF And Array(x + 3) * 256 + Array(x + 4) = IF_CMD Then
    'We found an END IF
    ENDIFCheck = ENDIFCheck - 1
    If ENDIFCheck = 0 Then GoTo GotNestedIFs ' check until we get to the END IF that is associated with our IF
End If
If v = &HFF And Array(x) * 256 + Array(x + 1) = IF_CMD Then
    If Array(x - 4) = &HFF And Array(x - 3) * 256 + Array(x - 2) = END_CMD Then
        'Found an END IF, carry on
    Else
        GoTo NestedIF ' found another real IF
    End If
End If
GoTo FindElses ' Loop until we get the END IF associated with our IF
GotNestedIFs:
ENDIFCheck = IFProc
IfCount = IfCount - IFProc ' Reset the IFCounter to what it was before we got our first IF (not nested IF)
x = FirstIFLocation ' x = the point where the expression starts for the first IF
IFProc = 0
IFSP = 0

' We get here after the IF and nested IFs are processed or a nested IF has just found
IFProcessed:
IFProc = IFProc + 1
IfCount = IfCount + 1
IFSP = IFSP + 1
ElseStack(IFSP) = IfCount

' We are inside a nested IF/THEN/ELSE we've already processed
' x points just past the IF        , ' This is the point where the expression starts
CheckIfTrue$ = ""
SaveIFX = x ' Save this position, just in case we have floating point compares to test for
v = 0
While v <> &HFF ' Keep copying until we get the next command which should be a THEN
    v = Array(x): x = x + 1
    CheckIfTrue$ = CheckIfTrue$ + Chr$(v)
Wend
'(x), Hex$(Array(x)), Hex$(Array(x + 1)), Hex$(Array(x + 2)), Hex$(Array(x + 3))
v = Array(x) * 256 + Array(x + 1): x = x + 2
If v <> THEN_CMD Then Print "Need a THEN after the IF statement on";: GoTo FoundError
CheckIfTrue$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HFF on the end

' Add code to handle
'CMPGT(FP_A,10.432) THEN (do this if >)
'CMPGE(FP_A,10.432) THEN (do this if >=)
'CMPEQ(FP_A,10.432) THEN (do this if = )
'CMPLE(FP_A,10.432) THEN (do this if <=)
'CMPLT(FP_A,10.432) THEN (do this if <)
If Left$(CheckIfTrue$, 1) <> Chr$(&HFE) Then GoTo NotFloatComp 'Skip and handle normal IF conditions
'If we get here then we are doing a floating Point compare
SaveX = x ' save the current position of x
Start1 = SaveIFX ' x points just after the IF statement
x = Start1
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
EP = 2 'pointer in Expression$
GoSub CheckFloatIF ' Go handle Float Compares returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
x = SaveX ' Restore x
GoTo CheckAfterFlotComp
NotFloatComp:
GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
CheckAfterFlotComp:
num = IFSTack(IFProc): GoSub NumAsString 'num=IFCount associated with this IFProc
If num < 10 Then Num$ = "0" + Num$
If ELSELocation(IFProc) > 0 Then
    'There is an ELSE to jump
    A$ = "BEQ": B$ = "_ELSE_" + Num$: C$ = "If result is zero = FALSE then jump to ELSE/Next line": GoSub AssemOut
Else
    ' No Else then jump to the END IF
    A$ = "BEQ": B$ = "_IFDone_" + Num$: C$ = "If result is zero = FALSE then jump to END IF line": GoSub AssemOut
End If
'x = x - 2: v = Array(x)
'GoTo ConsumeCommentsAndEOL ' Consume any comments and the EOL and Return
Return

' Check if this IF has an associated ELSE
DoesThisIFHaveAnELSE:
If x + 3 > Filesize Then GoTo GotNestedIFs ' Keep checking unless we get to the end of the file
v = Array(x): x = x + 1 'get a byte
If v = &HFF And Array(x) * 256 + Array(x + 1) = IF_CMD Then
    If Array(x - 4) = &HFF And Array(x - 3) * 256 + Array(x - 2) = END_CMD Then
        'Found And End IF
    Else
        ENDIFCheck = ENDIFCheck + 1 ' found a real IF
    End If
End If
If v = &HFF And Array(x) * 256 + Array(x + 1) = ELSE_CMD Then
    'We found an ELSE command for the current IF
    If ENDIFCheck = 1 Then
        FoundELSE = 1
        Return
    End If
End If
If v = &HFF And Array(x) * 256 + Array(x + 1) = END_CMD And Array(x + 2) = &HFF And Array(x + 3) * 256 + Array(x + 4) = IF_CMD Then
    'We found an END IF
    ENDIFCheck = ENDIFCheck - 1
    If ENDIFCheck = 0 Then Return ' check until we get to the END IF that is associated with our IF
End If
GoTo DoesThisIFHaveAnELSE
' LOCATE x,y - Sets the cursor at Column x, Row y
DoLOCATE:
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "CMPB": B$ = "#31": C$ = "Check if it's beyond the right side of the screen": GoSub AssemOut
A$ = "BLS": B$ = ">": C$ = "Skip ahead if good": GoSub AssemOut
A$ = "LDB": B$ = "#31": C$ = "If it's beyond the screen, make it the bottom row": GoSub AssemOut
Z$ = "!"
A$ = "ADDD": B$ = "#$E00": C$ = "D = Column + $E00, start of the screen in RAM": GoSub AssemOut
A$ = "TFR": B$ = "D,X": C$ = "Save D = Column in X": GoSub AssemOut
'x in the array will now be pointing just past the ,
'Get value to poke in D (we only use B)
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "CMPB": B$ = "#184": C$ = "Check if it's beyond the bottom of the screen": GoSub AssemOut
A$ = "BLS": B$ = ">": C$ = "Skip ahead if good": GoSub AssemOut
A$ = "LDB": B$ = "#184": C$ = "If it's beyond the screen, make it the bottom row": GoSub AssemOut
Z$ = "!"
A$ = "LDA": B$ = "#32": C$ = "32 bytes per row": GoSub AssemOut
A$ = "MUL": C$ = "Move down the screen B Rows": GoSub AssemOut
A$ = "LEAX": B$ = "D,X": C$ = "X=X+D, which now has the screen location": GoSub AssemOut
A$ = "STX": B$ = "GraphicCURPOS": C$ = "Update the location of the cursor": GoSub AssemOut
Return
' Quickly get the joystick values of 0,31,63 of both joysticks both horizontally and vertically
' Results are stored same place BASIC normally has the Joystick readings:
' LEFT  LEFT   RIGHT RIGHT
' VERT  HORIZ  VERT  HORIZ
' $15A  $15B   $15C  $15D
DoGETJOYD:
A$ = "JSR": B$ = "GetJoyD": C$ = "Read Joystick values and update the memory $15A-$15D": GoSub AssemOut
Return

' Format the characters between the IF and the THEN as:
' ex.  IF ((A*(4+B)=2 AND C=3) OR B=1 OR D=1) AND Z=2 THEN as
' CheckIfTrue$="((A*(4+B)=2 AND C=3) OR B=1 OR D=1) AND Z=2"
' GOSUB GoCheckIfTrue

' Evaluate CheckIfTrue$ and C flag will be zero if False or 1 if True
GoCheckIfTrue:
' Deal with brackets
' Need to turn    CheckIfTrue$="((A*(4+B)=2 AND C=3) OR B=1 OR D=1) AND Z=2"
'Into:   ((EV=2 AND C=3) OR B=1 OR D=1) AND Z=2
'          ((S=EV AND C=3) OR B=1 OR D=1) AND Z=2
'          ((S=EV AND C=3) OR B=1 OR D=1) AND Z=2
'          ((S0 AND EV=3) OR B=1 OR D=1) AND Z=2
'          ((S0 AND S=EV) OR B=1 OR D=1) AND Z=2   ...

' Make sure CheckIfTrue$ has an operator, if not add <>0 to the end of CheckIfTrue$
FoundOperator = 0
I = 1
While I < Len(CheckIfTrue$)
    v = Asc(Mid$(CheckIfTrue$, I, 1)): I = I + 1
    If v > &HEF Then
        'We have a Token
        Select Case v
            Case &HF0, &HF1: ' Found a Numeric or String array
                I = I + 3
            Case &HF2, &HF3: ' Found a numeric or string variable
                I = I + 2
            Case &HF5 ' Found a special character
                I = I + 1
            Case &HFB: ' Found a DEF FN Function
                I = I + 2
            Case &HFC: ' Found an Operator
                ii = Asc(Mid$(CheckIfTrue$, I, 1))
                If ii > &H0F And ii < &H16 Then FoundOperator = 1 'we found an operator to deal with
                If ii > &H3B And ii < &H3F Then FoundOperator = 1 'we found an operator to deal with
                I = I + 1
            Case &HFD, &HFE, &HFF: 'Found String,Numeric or General command
                I = I + 2
        End Select
    End If
Wend
If FoundOperator = 0 Then
    ' No Operator so add "(" at the beginning and ")<>0" to the end
    CheckIfTrue$ = Chr$(&HF5) + Chr$(&H28) + CheckIfTrue$ + Chr$(&HF5) + Chr$(&H29) + Chr$(&HFC) + Chr$(&H3C) + Chr$(&HFC) + Chr$(&H3E) + Chr$(&H30)
End If

EC = 1 'Expression Counter
BracketCount = 0
NewString$ = ""
CheckIfTrue$ = CheckIfTrue$ + Chr$(&HFC) + Chr$(&H3D) + "   " ' Add fake last expression of = so it ends with something
I = 1
Temp$ = ""
BC$ = ""
ExpressionFound$(EC) = ""

'                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

Start = I
While I < Len(CheckIfTrue$)
    v = Asc(Mid$(CheckIfTrue$, I, 1)): I = I + 1
    'Keep track of brackets
    If v = Asc("(") Then BracketCount = BracketCount + 1
    If v = Asc(")") Then BracketCount = BracketCount - 1
    If v > &HEF Then
        'We have a Token
        Select Case v
            Case &HF0, &HF1: ' Found a Numeric or String array
                I = I + 3
            Case &HF2, &HF3: ' Found a numeric or string variable
                I = I + 2
            Case &HF5 ' Found a special character
                I = I + 1
            Case &HFB: ' Found a DEF FN Function
                I = I + 2
            Case &HFC: ' Found an Operator
                v1 = Asc(Mid$(CheckIfTrue$, I, 1))
                If v1 = &H10 Or v1 = &H11 Or v1 = &H13 Or v1 = &H14 Or v1 = &H3C Or v1 = &H3D Or v1 = &H3E Then
                    'we found an operator to deal with
                    GoSub AddNewExpression
                    ' Everything is now copied properly in Newstring$ and ExpressionFound$()
                    Op1 = Asc(Mid$(CheckIfTrue$, I, 1)): I = I + 1 ' Get the first operator, move index past the first operator
                    If Asc(Mid$(CheckIfTrue$, I, 1)) = &HFC Then ' Check for another operator
                        ' We have two operators, so let's combine them
                        Op2 = Asc(Mid$(CheckIfTrue$, I + 1, 1)): I = I + 2 ' get the 2nd operator and move the index past the 2nd operator
                        If Op2 = &H2D Then
                            ' it's a negative on the right side
                            I = I - 2
                            NewOp = Op1
                        End If
                        If Op1 = &H3E And Op2 = &H3D Then NewOp = &H62 '>=
                        If Op1 = &H3D And Op2 = &H3E Then NewOp = &H62 '>=
                        If Op1 = &H3C And Op2 = &H3E Then NewOp = &H60 '<>
                        If Op1 = &H3E And Op2 = &H3C Then NewOp = &H60 '<>
                        If Op1 = &H3C And Op2 = &H3D Then NewOp = &H61 '<=
                        If Op1 = &H3D And Op2 = &H3C Then NewOp = &H61 '<=
                    Else
                        NewOp = Op1
                    End If
                    NewString$ = NewString$ + Chr$(&HFC) + Chr$(NewOp)
                    Start = I
                End If
            Case &HFD, &HFE, &HFF: 'Found String,Numeric or General command
                I = I + 2
        End Select
    End If
Wend
'v = Asc(Mid$(CheckIfTrue$, i, 1)): i = i + 1
'GoSub AddNewExpression ' Add the end of the CheckIfTrue$ to NewString & Expression()
NewString$ = Left$(NewString$, Len(NewString$) - 2) 'remove fake $FC3D
Return

'We found an operator or end of CheckIfTrue$
AddNewExpression:
Select Case BracketCount
    Case 0:
        ' Copy everything from Start to i as is to ExpressionFound$()
        ExpressionFound$(EC) = ""
        NewString$ = NewString$ + Chr$(0) + Chr$(EC) ' Add the expression token to NewString$
        For ii = Start To I - 2 ' -2 because we don't want to include the operator
            ExpressionFound$(EC) = ExpressionFound$(EC) + Mid$(CheckIfTrue$, ii, 1)
        Next ii
        EC = EC + 1
    Case Is > 0:
        ' We have more open brackets than close brackets
        BC = BracketCount
        While BracketCount > 0
            NewString$ = NewString$ + "(": BracketCount = BracketCount - 1
        Wend
        ExpressionFound$(EC) = ""
        NewString$ = NewString$ + Chr$(0) + Chr$(EC) ' Add the expression token to NewString$
        For ii = Start + BC To I - 2 ' -2 because we don't want to include the operator
            ExpressionFound$(EC) = ExpressionFound$(EC) + Mid$(CheckIfTrue$, ii, 1)
        Next ii
        EC = EC + 1
    Case Is < 0:
        ' We have more close brackets than open brackets
        BC = BracketCount
        ExpressionFound$(EC) = ""
        NewString$ = NewString$ + Chr$(0) + Chr$(EC) ' Add the expression token to NewString$
        For ii = Start To I + BC - 2 ' -2 because we don't want to include the operator
            ExpressionFound$(EC) = ExpressionFound$(EC) + Mid$(CheckIfTrue$, ii, 1)
        Next ii
        EC = EC + 1
        While BracketCount < 0
            NewString$ = NewString$ + ")": BracketCount = BracketCount + 1
        Wend
End Select
Return

' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
EvaluateNewString:
valueStackTop = 0
operatorStackTop = 0
Eval = 1
HandledV:
Do While Eval <= Len(NewString$)
    v = Asc(Mid$(NewString$, Eval, 1)): Eval = Eval + 1
    If v = 0 Then
        ' Compare Operand found
        v = Asc(Mid$(NewString$, Eval, 1)): Eval = Eval + 1 ' v is the pointer to the stored expression
        valueStackTop = valueStackTop + 1
        valueStack(valueStackTop) = v
        GoTo HandledV
    End If
    If v = &HFC Then
        ' Found an operator
        v = Asc(Mid$(NewString$, Eval, 1)): Eval = Eval + 1 ' v is the operator type
        Do While operatorStackTop > 0
            operator = operatorStack(operatorStackTop)
            GoSub GetOperatorPrecedence ' Input is operator, output OperatorPrecedence, depending on the value of "OR"=1, "AND"=2, "=<>"=3 return with value in OperatorPrecedence
            ' with # from 0 to 3 with 0 being any other operator
            GoSub GetTokenPrecedence ' Input v output TokenPrecedence, depending on the value of "OR"=1, "AND"=2, "=<>"=3
            ' 0 being any other Token
            If OperatorPrecedence >= TokenPrecedence Then
                GoSub ProcessTopOperator
            Else
                Exit Do
            End If
        Loop
        operatorStackTop = operatorStackTop + 1
        operatorStack(operatorStackTop) = v ' Save the type of operation to do
        GoTo HandledV
    End If
    ' Found a "parenthesis"
    If v = &H28 Or v = &H29 Then ' Is it an open or closed bracket?
        'Yes deal with them
        If v = Asc("(") Then
            'Found an Open Bracket
            operatorStackTop = operatorStackTop + 1
            operatorStack(operatorStackTop) = Asc("(")
        Else
            'Found a Closed Bracket
            Do While operatorStack(operatorStackTop) <> Asc("(")
                GoSub ProcessTopOperator
            Loop
            operatorStackTop = operatorStackTop - 1
        End If
    End If
Loop
Do While operatorStackTop > 0
    GoSub ProcessTopOperator
Loop
A$ = "LDD": B$ = ",S++": C$ = "Set the condition codes and fix the stack": GoSub AssemOut
Return ' All done

ProcessTopOperator:
rightOperand = valueStack(valueStackTop)
valueStackTop = valueStackTop - 1
If rightOperand = 0 Then ' it's time to compare the value of the stack
    A$ = "PULS": B$ = "D": C$ = "Get the Right value off the stack": GoSub AssemOut
    A$ = "STD": B$ = "_NumVar_IFRight": C$ = "Save the Right Operand value": GoSub AssemOut
Else
    Expression$ = ExpressionFound$(rightOperand)
    FoundStringR = 0
    If Asc(Mid$(Expression$, 1, 1)) = &HF1 Then FoundStringR = 1 'First token a String Array?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HF3 Then FoundStringR = 1 'First token a String variable?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HFD Then FoundStringR = 1 'First token a String command?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HF5 Then
        If Asc(Mid$(Expression$, 2, 1)) = &H22 Then FoundStringR = 1 'First token a Quote so it's a String to compare with
    End If
    If FoundStringR = 1 Then
        ' Deal with a string expression
        GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
        ' Copy String from _StrVar_PF00 to _StrVar_IFRight
        Print #1, "; copying String from _StrVar_PF00 to _StrVar_IFRight"
        A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U points at the start of the source string": GoSub AssemOut
        A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AssemOut
        A$ = "LDX": B$ = "#_StrVar_IFRight": C$ = "X points at the length of the destination string": GoSub AssemOut
        A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AssemOut
        A$ = "BEQ": B$ = "Done@": C$ = "If B=0 then no need to copy the string": GoSub AssemOut
        Z$ = "!"
        A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
        A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AssemOut
        A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
        A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
        Print #1, "Done@": Print #1,
        Print #1, "" ' Leave a space between sections so Done@ will work for each section
    Else
        'Handle Numeric Expression
        ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
        '  A$ = "PSHS": B$ = "D": C$ = "Save the Right Operand value on the stack": GoSub AssemOut
        A$ = "STD": B$ = "_NumVar_IFRight": C$ = "Save the Right Operand value": GoSub AssemOut
    End If
End If

leftOperand = valueStack(valueStackTop)
valueStackTop = valueStackTop - 1

If leftOperand = 0 Then ' it's time to compare the value of the stack
    '  A$ = "PULS": B$ = "D": C$ = "Get the Right value off the stack": GoSub AssemOut
    A$ = "LDD": B$ = ",S++": C$ = "Get the Left value in D, fix the stack": GoSub AssemOut
Else
    Expression$ = ExpressionFound$(leftOperand)
    FoundStringL = 0
    If Len(Expression$) = 0 Then
        If operatorStack(operatorStackTop) = 13 Then ' "NOT"
            A$ = "LDD": B$ = "_NumVar_IFRight": GoSub AssemOut
            A$ = "COMA": C$ = "Flip the bits": GoSub AssemOut
            A$ = "COMB": C$ = "Flip the bits": GoSub AssemOut
            A$ = "PSHS": B$ = "D": C$ = "Save the NOT version on the stack": GoSub AssemOut
            GoTo SkipLeft
        Else
            Print "Length of Left Operand is zero, something is wrong doing the IF on";: GoTo FoundError
        End If
    End If
    If Asc(Mid$(Expression$, 1, 1)) = &HF1 Then FoundStringL = 1 'First token a String Array?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HF3 Then FoundStringL = 1 'First token a String variable?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HFD Then FoundStringL = 1 'First token a String command?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HF5 Then
        If Asc(Mid$(Expression$, 2, 1)) = &H22 Then FoundStringL = 1 'First token a Quote so it's a String to compare with
    End If
    If FoundStringL <> FoundStringR Then Print "Error, the comparison of the IF values is comparing a string with a numeric on";: GoTo FoundError
    If FoundStringL = 1 Then
        ' Deal with a string expression
        GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
        ' Copy String from _StrVar_PF00 to _StrVar_IFRight
        Print #1, "; String _StrVar_PF00 has the left value"
    Else
        'Handle Numeric Expression
        ExType = 0: GoSub ParseNumericExpression ' D now has the LeftOperand value
    End If
End If

If operatorStack(operatorStackTop) = &H10 Then ' "AND"
    result = leftOperand And rightOperand
    A$ = "ANDA": B$ = "_NumVar_IFRight": C$ = "A=A AND first byte off the Stack": GoSub AssemOut
    A$ = "ANDB": B$ = "_NumVar_IFRight+1": C$ = "D now = D AND the stack": GoSub AssemOut
    A$ = "PSHS": B$ = "D": C$ = "Save the Result on the stack": GoSub AssemOut
End If
If operatorStack(operatorStackTop) = &H11 Then ' "OR"
    result = leftOperand Or rightOperand
    A$ = "ORA": B$ = "_NumVar_IFRight": C$ = "A=A OR first byte off the Stack": GoSub AssemOut
    A$ = "ORB": B$ = "_NumVar_IFRight+1": C$ = "D now = D OR the stack": GoSub AssemOut
    A$ = "PSHS": B$ = "D": C$ = "Save the Result on the stack": GoSub AssemOut
End If

If operatorStack(operatorStackTop) = &H13 Then ' "XOR"
    result = leftOperand Or rightOperand
    A$ = "EORA": B$ = "_NumVar_IFRight": C$ = "A=A XOR first byte off the Stack": GoSub AssemOut
    A$ = "EORB": B$ = "_NumVar_IFRight+1": C$ = "D now = D XOR the stack": GoSub AssemOut
    A$ = "PSHS": B$ = "D": C$ = "Save the Result on the stack": GoSub AssemOut
End If

If FoundStringL + FoundStringR = 0 Then
    'We are dealing with numeric expressions that is already in D and the Stack
    If (operatorStack(operatorStackTop) > &H3B And operatorStack(operatorStackTop) < &H3F) Or (operatorStack(operatorStackTop) > &H5F And operatorStack(operatorStackTop) < &H63) Then
        A$ = "LDX": B$ = "#$FFFF": C$ = "Default is Result = -1, True": GoSub AssemOut
        '     A$ = "CMPD": B$ = ",S++": C$ = "Compare D with the value on the stack, fix the stack": GoSub AssemOut
        A$ = "CMPD": B$ = "_NumVar_IFRight": C$ = "Compare D with the value on the right": GoSub AssemOut
    End If
    If operatorStack(operatorStackTop) = &H3E Then ' ">" ' BGT
        A$ = "BGT": B$ = ">": C$ = "If Greater than, then skip ahead": GoSub AssemOut
    End If
    If operatorStack(operatorStackTop) = &H3D Then ' "=" ' BEQ
        A$ = "BEQ": B$ = ">": C$ = "If They are Equal then skip ahead": GoSub AssemOut
    End If
    If operatorStack(operatorStackTop) = &H3C Then ' "<" ' BLT
        A$ = "BLT": B$ = ">": C$ = "If Less than, then skip ahead": GoSub AssemOut
    End If
    If operatorStack(operatorStackTop) = &H60 Then ' "<>" ' BNE
        A$ = "BNE": B$ = ">": C$ = "If They are Not Equal then skip ahead": GoSub AssemOut
    End If
    If operatorStack(operatorStackTop) = &H61 Then ' "<=" ' BLE
        A$ = "BLE": B$ = ">": C$ = "If They are Less Than or Equal then skip ahead": GoSub AssemOut
    End If
    If operatorStack(operatorStackTop) = &H62 Then ' ">=" ' BGE
        A$ = "BGE": B$ = ">": C$ = "If They are Greater than or Equal then skip ahead": GoSub AssemOut
    End If
    ' PSHS    result
    If (operatorStack(operatorStackTop) > &H3B And operatorStack(operatorStackTop) < &H3F) Or (operatorStack(operatorStackTop) > &H5F And operatorStack(operatorStackTop) < &H63) Then
        A$ = "LDX": B$ = "#$0000": C$ = "Make the Result zero, False": GoSub AssemOut
        Z$ = "!"
        A$ = "PSHS": B$ = "X": C$ = "Save the result on the stack": GoSub AssemOut
    End If
Else
    '                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
    ' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

    '                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
    ' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

    If (operatorStack(operatorStackTop) > &H3B And operatorStack(operatorStackTop) < &H3F) Or (operatorStack(operatorStackTop) > &H5F And operatorStack(operatorStackTop) < &H63) Then
        ' We are comparing string values
        '   D=U= _StrVar_PF00         copare with X= _StrVar_IFRight
        A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U = the Left String": GoSub AssemOut
        A$ = "LDX": B$ = "#_StrVar_IFRight": C$ = "X = the Right String": GoSub AssemOut
        If operatorStack(operatorStackTop) = &H3E Then ' ">" ' BGT
            Print #1, "; Checking if Strings are >"
            A$ = "LDB": B$ = ",U": C$ = "Get the length of the left side": GoSub AssemOut
            A$ = "ADDB": B$ = ",X": C$ = "Add the length of the right side": GoSub AssemOut
            A$ = "BEQ": B$ = "@False": C$ = "If they are both empty they are the same, return with FALSE": GoSub AssemOut
            A$ = "LDB": B$ = ",X": C$ = "Get the length of the Right side": GoSub AssemOut
            A$ = "BEQ": B$ = "@True": C$ = "If only the right side is empty, then the left side is > so return with True": GoSub AssemOut
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the left side, move pointer to the first byte of the string": GoSub AssemOut
            A$ = "BEQ": B$ = "@False": C$ = "If only the left is empty it is not > so return with FALSE": GoSub AssemOut
            ' We now know the size of both the left of the right > 0
            A$ = "CMPB": B$ = ",X+": C$ = "Compare the left size with the length of the right side, move pointer to the first byte of the string": GoSub AssemOut
            A$ = "BLS": B$ = "@BLowest": C$ = "Use B size for compare": GoSub AssemOut
            A$ = "LDB": B$ = "-1,X": C$ = "Use the size of the right side as the compare as it has less digits": GoSub AssemOut
            Z$ = "@BLowest"
            A$ = "TFR": B$ = "D,Y": C$ = "Backup B (string size to check) in Y": GoSub AssemOut
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AssemOut
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AssemOut
            A$ = "BLO": B$ = "@False": C$ = "If Left is < the right then it's FALSE": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AssemOut
            ' If we get here then the left are all Higher or the same, so check again and see if they are all the same and exit False if they are the same
            A$ = "LDU": B$ = "#_StrVar_PF00" + "+1": C$ = "U = the Left String": GoSub AssemOut
            A$ = "LDX": B$ = "#_StrVar_IFRight" + "+1": C$ = "X = the Right String": GoSub AssemOut
            A$ = "TFR": B$ = "Y,D": C$ = "Restore B (string size to check)": GoSub AssemOut
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AssemOut
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AssemOut
            A$ = "BHI": B$ = "@True": C$ = "If Left is > the right then return TRUE": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AssemOut
            Print #1, "; If we get here then the strings are the same this far, so TRUE if Left is longer then the Right"
            A$ = "LDB": B$ = "_StrVar_PF00": C$ = "B= the Length of the Left String": GoSub AssemOut
            A$ = "CMPB": B$ = "_StrVar_IFRight": C$ = "Compare it with the length of the Right String": GoSub AssemOut
            A$ = "BLS": B$ = "@False": C$ = "If left is lower or the same size as the right then return FALSE": GoSub AssemOut
        End If
        If operatorStack(operatorStackTop) = &H3D Then ' "="   -  If the coparison is an EQUALS then we can quickly check the length of both strings
            Print #1, "; Checking if Strings are ="
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the string, move pointer to the first byte of the string": GoSub AssemOut
            A$ = "CMPB": B$ = ",X+": C$ = "Are they the same length? , move pointer to the first byte of the string": GoSub AssemOut
            A$ = "BNE": B$ = "@False": C$ = "If They are Not Equal then return a false": GoSub AssemOut
            Print #1, "; If we get here then the length is the same, check if all characters are the same"
            A$ = "TSTB": C$ = "Check if the strings are empty": GoSub AssemOut
            A$ = "BEQ": B$ = "@True": C$ = "If they are both empty they are the same": GoSub AssemOut
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AssemOut
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the byte of the right string, move pointer forward": GoSub AssemOut
            A$ = "BNE": B$ = "@False": C$ = "If They are Not Equal then return a false": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AssemOut
            Print #1, "; If we get here then the strings are the same"
        End If
        If operatorStack(operatorStackTop) = &H3C Then ' "<" ' BLT
            Print #1, "; Checking if Strings are <"
            A$ = "LDB": B$ = ",U": C$ = "Get the length of the left side": GoSub AssemOut
            A$ = "ADDB": B$ = ",X": C$ = "Add the length of the right side": GoSub AssemOut
            A$ = "BEQ": B$ = "@False": C$ = "If they are both empty they are the same, which is not < so return with FALSE": GoSub AssemOut
            A$ = "LDB": B$ = ",X": C$ = "Get the length of the Right side": GoSub AssemOut
            A$ = "BEQ": B$ = "@False": C$ = "If only the right side is empty, then the left side is > so return with FALSE": GoSub AssemOut
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the left side, move pointer to the first byte of the string": GoSub AssemOut
            A$ = "BEQ": B$ = "@True": C$ = "If only the left is empty it is < so return with TRUE": GoSub AssemOut
            ' We now know the size of both the left of the right > 0
            A$ = "CMPB": B$ = ",X+": C$ = "Compare the left size with the length of the right side, move pointer to the first byte of the string": GoSub AssemOut
            A$ = "BLS": B$ = "@BLowest": C$ = "Use B size for compare": GoSub AssemOut
            A$ = "LDB": B$ = "-1,X": C$ = "Use the size of the right side as the compare as it has less digits": GoSub AssemOut
            Z$ = "@BLowest"
            A$ = "TFR": B$ = "D,Y": C$ = "Backup B (string size to check) in Y": GoSub AssemOut
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AssemOut
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AssemOut
            A$ = "BHI": B$ = "@False": C$ = "If Left is > the right then it's FALSE": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AssemOut
            ' If we get here then the right are all Higher or the same as the left, so check again and see if they are all the same and exit False if they are the same
            A$ = "LDU": B$ = "#_StrVar_PF00" + "+1": C$ = "U = the Left String": GoSub AssemOut
            A$ = "LDX": B$ = "#_StrVar_IFRight" + "+1": C$ = "X = the Right String": GoSub AssemOut
            A$ = "TFR": B$ = "Y,D": C$ = "Restore B (string size to check)": GoSub AssemOut
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AssemOut
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AssemOut
            A$ = "BLO": B$ = "@True": C$ = "If Left is < the right then return TRUE": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AssemOut
            Print #1, "; If we get here then the strings are the same this far, so TRUE if Left is shorter then the Right"
            A$ = "LDB": B$ = "_StrVar_PF00": C$ = "B= the Length of the Left String": GoSub AssemOut
            A$ = "CMPB": B$ = "_StrVar_IFRight": C$ = "Compare it with the length of the Right String": GoSub AssemOut
            A$ = "BHS": B$ = "@False": C$ = "If left is higher or the same size as the right then return FALSE": GoSub AssemOut
        End If
        If operatorStack(operatorStackTop) = &H60 Then ' "<>" ' BNE
            Print #1, "; Checking if Strings are <>"
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the string, move pointer to the first byte of the string": GoSub AssemOut
            A$ = "CMPB": B$ = ",X+": C$ = "Are they the same length? , move pointer to the first byte of the string": GoSub AssemOut
            A$ = "BNE": B$ = "@True": C$ = "If They are Not Equal then return True": GoSub AssemOut
            Print #1, "; If we get here then the length is the same, check if all characters are the same"
            A$ = "TSTB": C$ = "Check if the strings are empty": GoSub AssemOut
            A$ = "BEQ": B$ = "@False": C$ = "If they are both empty they are the same, return with FALSE": GoSub AssemOut
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AssemOut
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the byte of the right string, move pointer forward": GoSub AssemOut
            A$ = "BNE": B$ = "@True": C$ = "If They are Not Equal then return True": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AssemOut
            Print #1, "; If we get here then the strings are the same"
            A$ = "BRA": B$ = "@False": C$ = "If They are Equal then return a False": GoSub AssemOut
        End If
        If operatorStack(operatorStackTop) = &H61 Then ' "<=" ' BLE
            Print #1, "; Checking if Strings are <="
            A$ = "LDB": B$ = ",U": C$ = "Get the length of the left side": GoSub AssemOut
            A$ = "ADDB": B$ = ",X": C$ = "Add the length of the right side": GoSub AssemOut
            A$ = "BEQ": B$ = "@True": C$ = "If they are both empty they are the same, return with TRUE": GoSub AssemOut
            A$ = "LDB": B$ = ",X": C$ = "Get the length of the Right side": GoSub AssemOut
            A$ = "BEQ": B$ = "@False": C$ = "If only the right side is empty, then the left side is > so return with FALSE": GoSub AssemOut
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the left side, move pointer to the first byte of the string": GoSub AssemOut
            A$ = "BEQ": B$ = "@True": C$ = "If only the left is empty it is < so return with TRUE": GoSub AssemOut
            ' We now know the size of both the left of the right > 0
            A$ = "CMPB": B$ = ",X+": C$ = "Compare the left size with the length of the right side, move pointer to the first byte of the string": GoSub AssemOut
            A$ = "BLS": B$ = "@BLowest": C$ = "Use B size for compare": GoSub AssemOut
            A$ = "LDB": B$ = "-1,X": C$ = "Use the size of the right side as the compare as it has less digits": GoSub AssemOut
            Z$ = "@BLowest"
            A$ = "TFR": B$ = "D,Y": C$ = "Backup B (string size to check) in Y": GoSub AssemOut
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AssemOut
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AssemOut
            A$ = "BHI": B$ = "@False": C$ = "If Left is > the right then it's FALSE": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AssemOut
            ' If we get here then the right are all Higher or the same as the left, so check again and see if they are all the same and exit False if they are the same
            A$ = "LDU": B$ = "#_StrVar_PF00" + "+1": C$ = "U = the Left String": GoSub AssemOut
            A$ = "LDX": B$ = "#_StrVar_IFRight" + "+1": C$ = "X = the Right String": GoSub AssemOut
            A$ = "TFR": B$ = "Y,D": C$ = "Restore B (string size to check)": GoSub AssemOut
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AssemOut
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AssemOut
            A$ = "BLO": B$ = "@True": C$ = "If Left is < the right then return TRUE": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AssemOut
            Print #1, "; If we get here then the strings are the same this far, so TRUE if Left is shorter then the Right"
            A$ = "LDB": B$ = "_StrVar_PF00": C$ = "B= the Length of the Left String": GoSub AssemOut
            A$ = "CMPB": B$ = "_StrVar_IFRight": C$ = "Compare it with the length of the Right String": GoSub AssemOut
            A$ = "BHI": B$ = "@False": C$ = "If left is higher or the same size as the right then return FALSE": GoSub AssemOut
        End If
        If operatorStack(operatorStackTop) = &H62 Then ' ">=" ' BGE
            Print #1, "; Checking if Strings are >="
            A$ = "LDB": B$ = ",U": C$ = "Get the length of the left side": GoSub AssemOut
            A$ = "ADDB": B$ = ",X": C$ = "Add the length of the right side": GoSub AssemOut
            A$ = "BEQ": B$ = "@True": C$ = "If they are both empty they are the same, return with TRUE": GoSub AssemOut
            A$ = "LDB": B$ = ",X": C$ = "Get the length of the Right side": GoSub AssemOut
            A$ = "BEQ": B$ = "@True": C$ = "If only the right side is empty, then the left side is > so return with True": GoSub AssemOut
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the left side, move pointer to the first byte of the string": GoSub AssemOut
            A$ = "BEQ": B$ = "@False": C$ = "If only the left is empty it is not > so return with FALSE": GoSub AssemOut
            ' We now know the size of both the left of the right > 0
            A$ = "CMPB": B$ = ",X+": C$ = "Compare the left size with the length of the right side, move pointer to the first byte of the string": GoSub AssemOut
            A$ = "BLS": B$ = "@BLowest": C$ = "Use B size for compare": GoSub AssemOut
            A$ = "LDB": B$ = "-1,X": C$ = "Use the size of the right side as the compare as it has less digits": GoSub AssemOut
            Z$ = "@BLowest"
            A$ = "TFR": B$ = "D,Y": C$ = "Backup B (string size to check) in Y": GoSub AssemOut
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AssemOut
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AssemOut
            A$ = "BLO": B$ = "@False": C$ = "If Left is < the right then it's FALSE": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AssemOut
            ' If we get here then the left are all Higher or the same, so check again and see if they are all the same and exit False if they are the same
            A$ = "LDU": B$ = "#_StrVar_PF00" + "+1": C$ = "U = the Left String": GoSub AssemOut
            A$ = "LDX": B$ = "#_StrVar_IFRight" + "+1": C$ = "X = the Right String": GoSub AssemOut
            A$ = "TFR": B$ = "Y,D": C$ = "Restore B (string size to check)": GoSub AssemOut
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AssemOut
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AssemOut
            A$ = "BHI": B$ = "@True": C$ = "If Left is > the right then return TRUE": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AssemOut
            Print #1, "; If we get here then the strings are the same this far, so TRUE if Left is longer then the Right"
            A$ = "LDB": B$ = "_StrVar_PF00": C$ = "B= the Length of the Left String": GoSub AssemOut
            A$ = "CMPB": B$ = "_StrVar_IFRight": C$ = "Compare it with the length of the Right String": GoSub AssemOut
            A$ = "BLO": B$ = "@False": C$ = "If left is lower than the right then return FALSE": GoSub AssemOut
        End If
        ' Done all compares
        Z$ = "@True"
        A$ = "LDX": B$ = "#$FFFF": C$ = "Result = -1, True": GoSub AssemOut
        A$ = "BRA": B$ = "@SaveX": C$ = "If They are Not Equal then return a false": GoSub AssemOut
        Z$ = "@False"
        A$ = "LDX": B$ = "#$0000": C$ = "Make the Result zero, False": GoSub AssemOut
        Z$ = "@SaveX"
        A$ = "PSHS": B$ = "X": C$ = "Save the result on the stack": GoSub AssemOut
        Print #1, ""
    End If
End If
SkipLeft:
operatorStackTop = operatorStackTop - 1
valueStackTop = valueStackTop + 1
valueStack(valueStackTop) = 0
Return

' Input is operator, depending on the value of "OR"=1, "AND"=2, "=<>"=3 return with value in OperatorPrecedence
' with # from 0 to 3 with 0 being any other operator
'                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

GetOperatorPrecedence:
OperatorPrecedence = 0
If operator = &H13 Then OperatorPrecedence = 1 ' XOR
If operator = &H11 Then OperatorPrecedence = 2 ' "OR"
If operator = &H10 Then OperatorPrecedence = 3 '"AND"
If operator = &H14 Then OperatorPrecedence = 4 ' NOT
If (operator > &H3B And operator < &H3F) Or operator = &H12 Then OperatorPrecedence = 5 ' "=", "<", ">","MOD"
If operator > &H5F And operator < &H63 Then OperatorPrecedence = 5 ' "<>","<=",">="
If operator = &H15 Then OperatorPrecedence = 5 ' DIVR
Return

' Input Token(CurrentToken) output TokenPrecedence, depending on the value of "OR"=1, "AND"=2, "=<>"=3
' 0 being any other Token
GetTokenPrecedence:
TokenPrecedence = 0
If v = &H13 Then TokenPrecedence = 1 ' XOR
If v = &H11 Then TokenPrecedence = 2 ' "OR"
If v = &H10 Then TokenPrecedence = 3 '"AND"
If v = &H14 Then TokenPrecedence = 4 ' NOT
If (v > &H3B And v < &H3F) Or v = &H12 Then TokenPrecedence = 5 ' "=", "<", ">","MOD"
If v > &H5F And v < &H63 Then TokenPrecedence = 5 ' "<>","<=",">="
If v = &H15 Then TokenPrecedence = 5 ' DIVR
Return

DoDATA:
' Add the data on this line to the DataArray, keeping track of the location/size with DataArrayCount
' DATA lines are special lines that may conatin spaces
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)
    v = Array(x): x = x + 1
    If v = &H2C Then
        ' Found a comma, check for another comma in a row
        v = Array(x): x = x + 1
        If v = &H2C Then
            DataArray(DataArrayCount) = 0: DataArrayCount = DataArrayCount + 1 ' Length of string
            GoTo DoDATA
        End If
        If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then
            DataArray(DataArrayCount) = 0: DataArrayCount = DataArrayCount + 1 ' Length of string
            GoTo DoDATA
        End If
    End If
    If v = &HF5 And Array(x) = &H22 Then
        'We found a quote, copy string inside quotes
        StartPos = x + 1 ' Got the start pos of the string
        v = Array(x): x = x + 1 ' get the value after the quote
        Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A Or Array(x) = &H22) ' get end will be when we reach an EOL or another quote
            v = Array(x): x = x + 1
        Loop
        EndPos = x - 2
        DataArray(DataArrayCount) = EndPos - StartPos + 1: DataArrayCount = DataArrayCount + 1 ' Length of string
        For I = StartPos To EndPos
            DataArray(DataArrayCount) = Array(I): DataArrayCount = DataArrayCount + 1 'copy the string
        Next I
        If Array(x) = &H22 Then
            x = x + 1 'Consume the quote
            If Array(x) = &HF5 And (Array(x + 1) = &H0D Or Array(x + 1) = &H3A) Then
                v = Array(x): x = x + 1 ' Get ready to exit
            End If
        End If
        GoTo DoDATA
    End If
    If v >= Asc("0") And v <= Asc("9") Then
        'We have a number to copy
        Temp$ = ""
        Do Until (v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)) Or v = &H2C ' copy until we reach an EOL or comma
            Temp$ = Temp$ + Chr$(v)
            v = Array(x): x = x + 1
        Loop
        T1 = Val(Temp$)
        If T1 > 32767 Then T1 = 32767
        If T1 < -32768 Then T1 = -32768
        D0 = Int(T1 / 256)
        D1 = T1 - Int(T1 / 256) * 256
        DataArray(DataArrayCount) = D0: DataArrayCount = DataArrayCount + 1
        DataArray(DataArrayCount) = D1: DataArrayCount = DataArrayCount + 1
        If Array(x) = &H2C Then x = x - 1 ' if a comma then point at it again
        GoTo DoDATA
    Else
        'Otherwise copy a string until we reach a comma or EOL/Colon
        StartPos = x - 1 ' Got the start pos of the string
        Do Until (v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)) Or v = &H2C ' copy until we reach an EOL or comma
            v = Array(x): x = x + 1
        Loop
        EndPos = x - 2
        DataArray(DataArrayCount) = EndPos - StartPos + 1: DataArrayCount = DataArrayCount + 1 ' Length of string
        For I = StartPos To EndPos
            DataArray(DataArrayCount) = Array(I): DataArrayCount = DataArrayCount + 1 'copy the string
        Next I
        If Array(x) = &H2C Then x = x - 1 ' if a comma then point at it again
    End If
Loop
v = Array(x): x = x + 1
Return
' Prints in quotes, enter with x pointing at the first character after the open quote
PrintInQuotes:
Y = x
PrintQGetCount:
v = Array(x): x = x + 1: 'Get next byte
If v = &HF5 Then GoTo PrintQGotCount ' end quote
GoTo PrintQGetCount
PrintQGotCount:
c = x - Y - 1
If c = 0 Then GoTo PrintQDone 'an empty string
' string has a value
x = Y
If c > 5 Then
    A$ = "BSR": B$ = ">": C$ = "Skip over string value": GoSub AssemOut
    PrintQGetChars:
    v = Array(x): x = x + 1: 'Get next byte
    If v = &HF5 Then GoTo PrintQGotQuote ' end quote
    A$ = "FCB": B$ = "$" + Hex$(v): C$ = Chr$(v): GoSub AssemOut
    GoTo PrintQGetChars
    PrintQGotQuote:
    x = x + 1 ' Point past the quote
    Z$ = "!"
    A$ = "LDB": B$ = "#" + Right$(Str$(c), Len(Str$(c)) - 1): C$ = "Length of this string": GoSub AssemOut
    A$ = "LDU": B$ = ",S++": C$ = "Load U with the string start location off the stack and fix the stack": GoSub AssemOut
    Z$ = "!"
    A$ = "LDA": B$ = ",U+": C$ = "Get the string data": GoSub AssemOut
    A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AssemOut
    A$ = "DECB": C$ = "decrement the string length counter": GoSub AssemOut
    A$ = "BNE": B$ = "<": C$ = "If not counted down to zero then loop": GoSub AssemOut
Else
    'LDA and print A directly - it's faster if it's a short bit of text
    For c = 1 To c
        v = Array(x): x = x + 1: 'Get next byte
        A$ = "LDA": B$ = "#$" + Hex$(v): C$ = "A = Byte to print, " + Chr$(v): GoSub AssemOut
        A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AssemOut
    Next c
    x = x + 2 ' skip past the end quote
End If
PrintQDone:
Return

DoPRINT:
PrintD$ = "PRINT_D": PrintA$ = "PrintA_On_Screen": PrintDev$ = " on screen"
' Parse parts of it, upto a ";" print it, then do the next part
' Figure out what we need to print...
GetSectionToPrint:
v = Array(x): x = x + 1
'Print #1, "; GetSectionToPrint, v=$"; Hex$(v)

' Could optimize printing strings if you process the values of each character ahead of time
' When writing the FCB's below and then just write them to the screen intead of calling the PrintA_On_Screen routine, and once done
' update the screen pointer
' Also would need to make sure a scroll won't be necessary...
If v >= Asc("0") And v <= Asc("9") Or (v = Asc("&") And Array(x) = Asc("H")) Then ' Printing a number, PRINT 10*20
    x = x - 1 ' make sure to inlcude the first Numeric variable
    GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
    A$ = "JSR": B$ = PrintD$: C$ = "Go print D" + PrintDev$: GoSub AssemOut
    GoTo GetSectionToPrint
End If

If v = &HF0 Then ' Printing a Numeric Array variable, PRINT A(5)
    x = x - 1 ' make sure to inlcude the first Numeric array variable
    GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
    A$ = "JSR": B$ = PrintD$: C$ = "Go print D" + PrintDev$: GoSub AssemOut
    GoTo GetSectionToPrint
End If

If v = &HF1 Then ' Printing a String Array variable, PRINT A$(6)
    x = x - 1 ' make sure to inlcude the first String Array variable
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get an Expression before a close bracket, skip past $F5 and close bracket
    Expression$ = Expression$ + Chr$(&HF5) + Chr$(&H29) 'add the close bracket for parsing
    GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
    ' Copy _StrVar_PF00 to string variable
    A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U points at the start of the source string": GoSub AssemOut
    A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AssemOut
    A$ = "BEQ": B$ = "Done@": C$ = "If the length of the string is zero then don't print it (Skip ahead)": GoSub AssemOut
    Z$ = "!"
    A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
    A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AssemOut
    A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
    A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
    Z$ = "Done@": GoSub AssemOut
    Print #1, "" ' Leave a space between sections so Done@ will work for each section
    GoTo GetSectionToPrint
End If

If v = &HF2 Then ' Printing a Regular Numeric Variable, PRINT A
    x = x - 1 ' make sure to inlcude the first Numeric variable
    GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
    A$ = "JSR": B$ = PrintD$: C$ = "Go print D" + PrintDev$: GoSub AssemOut
    GoTo GetSectionToPrint
End If
If v = &HF3 Then ' Printing a Regular String Variable, PRINT A$
    x = x - 1 ' make sure to inlcude the first String variable
    GoSub GetExpressionB4SemiPlusComQ_EOL ' Get an Expression before a semi colon, a Plus, a comma, a quote or an EOL
    GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
    ' Copy _StrVar_PF00 to string variable
    A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U points at the start of the source string": GoSub AssemOut
    A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AssemOut
    A$ = "BEQ": B$ = "Done@": C$ = "If the length of the string is zero then don't print it (Skip ahead)": GoSub AssemOut
    Z$ = "!"
    A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
    A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AssemOut
    A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
    A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
    Z$ = "Done@": GoSub AssemOut
    Print #1, "" ' Leave a space between sections so Done@ will work for each section
    GoTo GetSectionToPrint
End If
If v = &HF4 Then ' Printing a Floating Point Variable, PRINT FP_A
    v = Array(x) * 256 + Array(x + 1): x = x + 2 ' Get the Floating Point Variable
    FPV$ = "_FPVar_" + FloatVariable$(v)
    A$ = "LDX": B$ = "#" + FPV$: C$ = "Point at FP number": GoSub AssemOut
    A$ = "LDU": B$ = "#FPStackspace": C$ = "Point at FP stack start": GoSub AssemOut
    A$ = "JSR": B$ = "FPLOD": C$ = "LOAD FP NUMBER FROM ADDRESS X AND PUSH ONTO FP STACK": GoSub AssemOut
    A$ = "LDY": B$ = "CURPOS": C$ = "Get cursor position in Y": GoSub AssemOut
    A$ = "JSR": B$ = "FPSCIENT": C$ = "CONVERT FP NUMBER TO STRING AT ADDRESS Y IN SCIENTIFIC NOTATION": GoSub AssemOut
    A$ = "STY": B$ = "CURPOS": C$ = "update the cursor position": GoSub AssemOut
    GoTo GetSectionToPrint
End If
If v = &HF5 Then
    ' Found a special character
    v = Array(x): x = x + 1
    If v = &H0D Or v = &H3A Then ' Do a carriage return/Line feed
        If Array(x - 4) = &HF5 And (Array(x - 3) = &H2C Or Array(x - 3) = &H3B) Then
            Return 'if we previously did a comma or semicolon then Return
        Else
            A$ = "LDA": B$ = "#$0D": C$ = "Do a Line Feed/Carriage Return": GoSub AssemOut
            A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AssemOut
            Return ' we have reached the end of the line return
        End If
    End If
    If v = &H22 Then ' Printing characters in quotes, PRINT "HELLO"
        GoSub PrintInQuotes ' Prints in quotes, x points after the end quote
        GoTo GetSectionToPrint
    End If
    If v = &H23 Then ' Printing # somewhere other than the text screen , PRINT #-2,"Hello, World!"
        v = Array(x): x = x + 1
        If v = &H30 Then
            v = Array(x): x = x + 1
            If v = &HF5 Then
                v = Array(x): x = x + 1
                If v <> &H2C Then
                    Print "Can't print the value after # on";: GoTo FoundError
                Else
                    ' If it is Print #0, then print to text screen
                    PrintD$ = "Print_D": PrintA$ = "PrintA_On_Screen": PrintDev$ = " on screen"
                    GoTo GetSectionToPrint
                End If
            End If
        End If
        If v = &HFC Then
            v = Array(x): x = x + 1
            If v = &H2D Then
                ' Printing #-
                v = Array(x): x = x + 1
                If v = &H32 Then
                    ' Print #-2
                    v = Array(x): x = x + 1
                    If v = &HF5 Then
                        v = Array(x): x = x + 1
                        If v <> &H2C Then
                            Print "Print command should have a comma after # on";: GoTo FoundError
                        Else
                            PrintD$ = "PRINT_D_Serial": PrintA$ = "AtoSerialPort": PrintDev$ = " to printer"
                            GoTo GetSectionToPrint
                        End If
                    End If
                End If
                If v = &H33 Then
                    ' Print #-3
                    v = Array(x): x = x + 1
                    If v = &HF5 Then
                        v = Array(x): x = x + 1
                        If v <> &H2C Then
                            Print "Print command should have a comma after # on";: GoTo FoundError
                        Else
                            PrintD$ = "PRINT_D_Graphics_Screen": PrintA$ = "AtoGraphics_Screen": PrintDev$ = " to graphic screen"
                            GoTo GetSectionToPrint
                        End If
                    End If
                End If
            End If
        End If
        Print "Can't handle printing to other devices on";: GoTo FoundError
    End If
    If v = &H28 Then ' Check if we have some open brackets to deal with, see if the next character is a string or numeric and deal with it accordingly
        v = Array(x)
        If v = &HF1 Or v = &HF3 Then
            Print "Can't handle Strings in Brackets in";: GoSub FoundError
            ' Write code to handle this: Print ("hey" + A$ + C$)
        Else
            x = x - 2 ' setup X to be just before the first open bracket
            GoSub GetExpressionB4EndBracket: x = x + 2 ' get expression before an end bracket, move past it
            Expression$ = Expression$ + Chr$(&HF5) + Chr$(&H29) ' add close bracket
            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
            A$ = "JSR": B$ = PrintD$: C$ = "Go print D" + PrintDev$: GoSub AssemOut
        End If
        GoTo GetSectionToPrint
    End If
    If v = &H2C Then ' Handle a comma on the print line
        A$ = "LDD": B$ = "CURPOS": C$ = "Handling the comma": GoSub AssemOut
        A$ = "ADDD": B$ = "#16": GoSub AssemOut
        A$ = "ANDB": B$ = "#%11110000": C$ = "force it to be position 0 or 16": GoSub AssemOut
        A$ = "TFR": B$ = "D,X": C$ = "Handle the comma in the PRINT command": GoSub AssemOut
        A$ = "JSR": B$ = "UpdateCursor": GoSub AssemOut
        GoTo GetSectionToPrint 'continue printing on the same line
    End If
    If v = &H3B Then GoTo GetSectionToPrint ' Handle a semi-colon
End If
If v = &HFB Then ' Printing a FN - function
    x = x - 1 ' make sure to inlcude the first Numeric command byte
    GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
    A$ = "JSR": B$ = PrintD$: C$ = "Go print D" + PrintDev$: GoSub AssemOut
    GoTo GetSectionToPrint
End If
If v = &HFC Then
    'Printing an operator command
    If Array(x) = &H2D Then ' Printing a negative number like PRINT -1
        x = x - 1 ' make sure to inlcude the first Numeric variable
        GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
        ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
        A$ = "JSR": B$ = PrintD$: C$ = "Go print D" + PrintDev$: GoSub AssemOut
        GoTo GetSectionToPrint
    Else
        If Array(x) = &H2B Then
            ' Found a Plus, Make sure it's not a number to print
            If Array(x + 1) >= Asc("0") And Array(x + 1) <= Asc("9") Then
                'It is printing a number
                x = x - 1 ' make it start at the +
                GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
                ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
                A$ = "JSR": B$ = PrintD$: C$ = "Go print D" + PrintDev$: GoSub AssemOut
                GoTo GetSectionToPrint
            Else
                '  treat it like a semicolon
                If Array(x + 1) = &HF5 And (Array(x + 2) = &H0D Or Array(x + 2) = &H3A) Then
                    ' Is EOL or COLON next?
                    x = x + 2
                    v = Array(x): x = x + 1 ' consume the &H0D       or colon
                    Return
                End If
                If Array(x + 1) = &HFF Then
                    'it could be printing inside an IF/ELSE line, so return
                    v = Array(x)
                    Return
                Else
                    x = x + 1
                    GoTo GetSectionToPrint 'continue printing on the same line
                End If
            End If
        End If
    End If
End If
If v = &HFD Then ' Printing a String Command, PRINT CHR$(67)
    x = x - 1 ' make sure to inlcude the first String command value
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get an Expression before a close bracket, skip past $F5 and close bracket
    Expression$ = Expression$ + Chr$(&HF5) + Chr$(&H29) 'add the close bracket for parsing
    GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
    ' Copy _StrVar_PF00 to string variable
    A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U points at the start of the source string": GoSub AssemOut
    A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AssemOut
    A$ = "BEQ": B$ = "Done@": C$ = "If the length of the string is zero then don't print it (Skip ahead)": GoSub AssemOut
    Z$ = "!"
    A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
    A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AssemOut
    A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
    A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
    Z$ = "Done@": GoSub AssemOut
    Print #1, "" ' Leave a space between sections so Done@ will work for each section
    GoTo GetSectionToPrint
End If
If v = &HFE Then ' Printing a Numeric Command, PRINT PEEK(10)
    If Array(x) = TAB_CMD Then
        'We just found the TAB() command
        x = x + 2 ' consume the open bracket
        GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
        ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
        A$ = "LDA": B$ = "#$20": C$ = "A = SPACE": GoSub AssemOut
        Z$ = "!"
        A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AssemOut
        A$ = "DECB": C$ = "Decrement the count": GoSub AssemOut
        A$ = "BNE": B$ = "<": C$ = "keep looping": GoSub AssemOut
        GoTo GetSectionToPrint
    Else
        x = x - 1 ' make sure to inlcude the first Numeric command byte
        GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
        ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
        A$ = "JSR": B$ = PrintD$: C$ = "Go print D" + PrintDev$: GoSub AssemOut
        GoTo GetSectionToPrint
    End If
End If
If v = &HFF Then
    'it could be printing inside an IF/ELSE line, so return
    x = x - 1
    v = Array(x)
    A$ = "LDA": B$ = "#$0D": C$ = "Do a Line Feed/Carriage Return": GoSub AssemOut
    A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AssemOut
    Return
End If
If v = &H40 Then
    'Found a PRINT @
    GoSub GetExpressionB4Comma: x = x + 2 ' Handle an expression that ends with a comma , move past the comma
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression value is now in D
    A$ = "ADDD": B$ = "#$400": C$ = "D=D+$400, start of the screen in RAM": GoSub AssemOut
    A$ = "CMPD": B$ = "#$600": C$ = "Compare D with $600": GoSub AssemOut
    A$ = "BLO": B$ = ">": C$ = "Skip ahead if lower than $600": GoSub AssemOut
    A$ = "LDD": B$ = "#$5FF": C$ = "Make D = $5FF (max)": GoSub AssemOut
    A$ = "BRA": B$ = "@StoreD": C$ = "Update the location to print": GoSub AssemOut
    Z$ = "!"
    A$ = "CMPD": B$ = "#$400": C$ = "Compare D with $600": GoSub AssemOut
    A$ = "BHS": B$ = "@StoreD": C$ = "Skip ahead if higher than $600": GoSub AssemOut
    A$ = "LDD": B$ = "#$400": C$ = "Make D = $400 (min)": GoSub AssemOut
    Z$ = "@StoreD"
    A$ = "STD": B$ = "CURPOS": C$ = "Update the location of the cursor": GoSub AssemOut
    Print #1, ""
    GoTo GetSectionToPrint
End If
Print "Error, Not sure how to print the end of line "; linelabel$; " v = $"; Hex$(v), Chr$(v)
Print "x-2 = $"; Hex$(Array(x - 2))
Print "x-1 = $"; Hex$(Array(x - 1))
Print "x   = $"; Hex$(Array(x))
Print "x+1 = $"; Hex$(Array(x + 1))
Print "x+2 = $"; Hex$(Array(x + 2))
Print "x+3 = $"; Hex$(Array(x + 3))
System

DoON:
GoSub GetExpressionB4EOLOrCommand 'Handle an expression that ends with a colon or End of a Line or another command like TO or STEP
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression value is now in D, x now points after the EOL/Colon/$FF
v = Array(x): x = x + 1
If v = &HFF Then
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    If v = GOTO_CMD Or v = GOSUB_CMD Then
        If v = GOTO_CMD Then
            'We have an ON GOTO command
            ONType$ = "JMP"
        End If
        If v = GOSUB_CMD Then
            'We have an ON GOSUB command
            ONType$ = "JSR"
        End If
    Else
        ' Not ON GOTO or ON GOSUB
        Print "Error, Not an ON GOTO or ON GOSUB on";: GoTo FoundError
    End If
Else
    Print "Error, Not an ON GOTO or ON GOSUB on";: GoTo FoundError
End If
DoneOn$ = "@" + ONType$ + "DoneOn" 'Pointer to the code after the Jump/JSR list
A$ = "BRA": B$ = ">": C$ = "Skip past the address list": GoSub AssemOut
Print #1, "@"; ONType$; "List"
A$ = "FDB": B$ = DoneOn$: C$ = "If value is zero we jump to the code after the ON code section": GoSub AssemOut
c = 0
ONLoop1:
c = c + 1
Temp$ = "_L" ' Start of the label
v = Array(x): x = x + 1
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A Or Array(x) = &H2C)
    Temp$ = Temp$ + Chr$(v)
    v = Array(x): x = x + 1
Loop
If v = &HF5 Then v = Array(x): x = x + 1
A$ = "FDB": B$ = Temp$: C$ = "Location for the " + ONType$ + " " + Temp$: GoSub AssemOut
If v = &H2C Then GoTo ONLoop1
' We have the ON value in D, All we need is the value in B as it can't be larger than a 127
num = c: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
Z$ = "!"
A$ = "CMPD": B$ = "#" + Num$: C$ = "See if the value is larger than the number of entries in the list": GoSub AssemOut
A$ = "BHI": B$ = DoneOn$: C$ = "If the value is higher then simply skip to the next line": GoSub AssemOut
A$ = "LSLB": C$ = "B = B*2 Jump Table entries are two bytes each": GoSub AssemOut
A$ = "LDX": B$ = "#@" + ONType$ + "List": C$ = "X points at the begining of the table": GoSub AssemOut
A$ = "ABX": C$ = "X = X+B, X now points at the correct entry": GoSub AssemOut
If ONType$ = "JSR" Then
    A$ = ONType$: B$ = "[,X]": C$ = "GOSUB to the address in the table": GoSub AssemOut
Else
    A$ = ONType$: B$ = "[,X]": C$ = "GOTO to the address in the table": GoSub AssemOut
End If
Z$ = DoneOn$: GoSub AssemOut
Print #1,
Return

DoINPUT:
PrintD$ = "PRINT_D": PrintA$ = "PrintA_On_Screen": PrintDev$ = " on screen" ' Make sure we are printing on the text screen
v = Array(x): x = x + 1
ShowInputCount = ShowInputCount + 1
num = ShowInputCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
ShowInputText$ = "ShowInputText" + Num$
Print #1, ShowInputText$; ":"
If v = &HF5 And Array(x) = &H22 Then ' Printing characters in quotes, PRINT "HELLO"
    x = x + 1
    GoSub PrintInQuotes ' Prints in quotes, x points after the end quote
    x = x + 1: v = Array(x): x = x + 1 ' get the semi-colon
    If v <> Asc(";") Then Print "Error, should have a semi-colon after the text in";: GoTo FoundError
Else
    v = 0: x = x - 1
End If
' Figure out if we have commas for the user input so they can input them all on one line as 5,3,12 <ENTER>  or hit ENTER after each individual number
Start = x
count = 0
Brackets = 0
Do Until Array(x) = &HF5 And (Array(x + 1) = &H0D Or Array(x + 1) = &H3A) ' loop until the end of the line or colon
    If Array(x) = &HF5 And Array(x + 1) = Asc("(") Then Brackets = Brackets + 1: x = x + 1
    If Array(x) = &HF5 And Array(x + 1) = Asc(")") Then Brackets = Brackets - 1: x = x + 1
    If Array(x) = &HF5 And Array(x + 1) = Asc(",") Then
        x = x + 1
        If Brackets = 0 Then count = count + 1
    End If
    x = x + 1
Loop
num = count: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
A$ = "LDA": B$ = "#" + Num$: C$ = "Save the number of commas needed": GoSub AssemOut
A$ = "STA": B$ = "CommaCount": C$ = "Save the number of commas to look for": GoSub AssemOut
x = Start

' Fill the KeyBuff from user input, it will be terminated with a comma
A$ = "JSR": B$ = "GetInput": C$ = "Show ? and get user input in KeyBuff, U points to the end of the buffer, B has # of characters that were input": GoSub AssemOut
A$ = "LDU": B$ = "#KeyBuff": C$ = "U = source starts address": GoSub AssemOut
If count = 0 Then
    ' No commas, just one entry for this INPUT command
    v = Array(x): x = x + 1 ' Get the type of variable
    If v < &HF0 And v > &HF3 Then Print "Error, can't figure out the INPUT variable in";: GoTo FoundError
    ' We got the Enter Key, figure out how to copy the number or string to the variable
    If v = &HF0 Or v = &HF2 Then ' We are getting a numeric value
        ' Make sure buffer is a numeric value between 0 and 65536
        ' Get our numeric variable location
        ' Convert buffer to a number
        A$ = "LDX": B$ = "#DecNumber": C$ = "X points at the start of the table of data to grab each time": GoSub AssemOut
        A$ = "CLRB": GoSub AssemOut
        Z$ = "!"
        A$ = "INCB": GoSub AssemOut
        A$ = "CMPB": B$ = "#7": C$ = "Check the number of decimal places": GoSub AssemOut
        A$ = "BHI": B$ = "@NotANumber": C$ = "If more than 7 then we have a problem": GoSub AssemOut
        A$ = "LDA": B$ = ",U+": GoSub AssemOut
        A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AssemOut
        A$ = "CMPA": B$ = "#',": C$ = "Did we find a comma?": GoSub AssemOut
        A$ = "BNE": B$ = "<": GoSub AssemOut
        A$ = "CLR": B$ = "-1,X": C$ = "flag last byte as 0, so we know that we have reached the end of the string": GoSub AssemOut
        A$ = "JSR": B$ = "DecToD": C$ = "Convert the string in the buffer to a number": GoSub AssemOut
        A$ = "BEQ": B$ = ">": C$ = "Skip forward if conversion went well": GoSub AssemOut
        Z$ = "@NotANumber": GoSub AssemOut
        A$ = "JSR": B$ = "ShowREDO": C$ = "Show ?REDO on screen": GoSub AssemOut
        A$ = "BRA": B$ = ShowInputText$: C$ = "Show input text, if there was some and get the input again": GoSub AssemOut
        Z$ = "!"
        C$ = "D now has the converted number :)": GoSub AssemOut
        Print #1, ""
        If v = &HF2 Then
            ' We are inputting a numeric value
            v = Array(x) * 256 + Array(x + 1): x = x + 2
            A$ = "STD": B$ = "_Var_" + NumericVariable$(v): C$ = "Save D in variable location": GoSub AssemOut
        Else
            ' We are inputting a numeric array
            Print #1, "; Getting the numeric array memory location in X"
            GoSub MakeXPointAtNumericArray ' Enter array() pointing at the Numeric Array Name, Returns with X pointing at the memory location for the Numeric Array, D is unchanged
            A$ = "STD": B$ = ",X": C$ = "Store the number where X points": GoSub AssemOut
            Print "Found something": System
        End If
    Else
        If v = &HF1 Or v = &HF3 Then ' We are getting a string value
            ' B = length of the string
            ' #KeyBuff = start of the keyboard input buffer
            If v = &HF3 Then
                ' We are inputting a string variable
                v = Array(x) * 256 + Array(x + 1): x = x + 2
                Print #1, ""
                A$ = "LDX": B$ = "#_StrVar_" + StringVariable$(v): C$ = "X = destination address": GoSub AssemOut
            Else
                ' We are inputting a string array
                Print #1, "; Getting the String array memory location in X"
                GoSub MakeXPointAtStringArray ' Enter array() pointing at the String Array Name, Returns with X pointing at the memory location for the String Array, D is unchanged
            End If
            A$ = "PSHS": B$ = "X": C$ = "Save X on the stack": GoSub AssemOut
            A$ = "LEAX": B$ = "1,X": C$ = "Move X so it starts at the correct location": GoSub AssemOut
            A$ = "CLRB": C$ = "Clear the counter": GoSub AssemOut
            Z$ = "!"
            A$ = "INCB": C$ = "Increment the counter": GoSub AssemOut
            A$ = "LDA": B$ = ",U+": GoSub AssemOut
            A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AssemOut
            A$ = "CMPA": B$ = "#',": C$ = "Did we find a comma?": GoSub AssemOut
            A$ = "BNE": B$ = "<": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "STB": B$ = "[,S++]": C$ = "Save the length of the string and fix the stack": GoSub AssemOut
        Else
            Print "Error, can't figure out the INPUT variable in";: GoTo FoundError
        End If
    End If
    ' Check for a comma or end of line $0D
    v = Array(x): x = x + 1
    If v <> &HF5 And Array(x) <> &H0D And Array(x) <> &H3A Then Print "Error, with the INPUT command, it didn't end properly in";: GoTo FoundError
    v = Array(x): x = x + 1
    Return 'Done with the INPUT command
End If

' There are commas on the INPUT line handle it a little differently
v = Array(x)
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)
    v = Array(x): x = x + 1 ' Get the type of variable
    If v < &HF0 And v > &HF3 Then Print "Error, can't figure out the INPUT variable in";: GoTo FoundError
    ' We got the Enter Key, figure out how to copy the number or string to the variable
    If v = &HF0 Or v = &HF2 Then ' We are getting a numeric value
        ' Make sure buffer is a numeric value between 0 and 65536
        ' Get our numeric variable location
        ' Convert buffer to a number
        ' Check if input number has too many digits
        A$ = "LDX": B$ = "#DecNumber": C$ = "X points at the start of the table of data to grab each time": GoSub AssemOut
        A$ = "CLRB": GoSub AssemOut
        Z$ = "!"
        A$ = "INCB": GoSub AssemOut
        A$ = "CMPB": B$ = "#7": C$ = "Check the number of decimal places": GoSub AssemOut
        A$ = "BHI": B$ = "@NotANumber": C$ = "If more than 7 then we have a problem": GoSub AssemOut
        A$ = "LDA": B$ = ",U+": GoSub AssemOut
        A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AssemOut
        A$ = "CMPA": B$ = "#',": C$ = "Did we find a comma?": GoSub AssemOut
        A$ = "BNE": B$ = "<": GoSub AssemOut
        A$ = "CLR": B$ = "-1,X": C$ = "flag last byte as 0, so we know that we have reached the end of the string": GoSub AssemOut
        A$ = "JSR": B$ = "DecToD": C$ = "Convert the string in the buffer to a number": GoSub AssemOut
        A$ = "BEQ": B$ = ">": C$ = "Skip forward if conversion went well": GoSub AssemOut
        Z$ = "@NotANumber": GoSub AssemOut
        A$ = "JSR": B$ = "ShowREDO": C$ = "Show ?REDO on screen": GoSub AssemOut
        A$ = "BRA": B$ = ShowInputText$: C$ = "Show input text, if there was some and get the input again": GoSub AssemOut
        Z$ = "!"
        C$ = "D now has the converted number :)": GoSub AssemOut
        Print #1, ""
        If v = &HF2 Then
            ' We are inputting a numeric value
            v = Array(x) * 256 + Array(x + 1): x = x + 2
            A$ = "STD": B$ = "_Var_" + NumericVariable$(v): C$ = "Save D in variable location": GoSub AssemOut
        Else
            ' We are inputting a numeric array
            Print #1, "; Getting the numeric array memory location in X"
            GoSub MakeXPointAtNumericArray ' Enter array() pointing at the Numeric Array Name, Returns with X pointing at the memory location for the Numeric Array, D is unchanged
            A$ = "STD": B$ = ",X": C$ = "Store the number where X points": GoSub AssemOut
        End If
    Else
        If v = &HF1 Or v = &HF3 Then ' We are getting a string value
            ' B = length of the string
            ' #KeyBuff = start of the keyboard input buffer
            If v = &HF3 Then
                ' We are inputting a string variable
                v = Array(x) * 256 + Array(x + 1): x = x + 2
                A$ = "LDX": B$ = "#_StrVar_" + StringVariable$(v): C$ = "X = destination address": GoSub AssemOut
            Else
                ' We are inputting a string array
                Print #1, "; Getting the String array memory location in X"
                GoSub MakeXPointAtStringArray ' Enter array() pointing at the String Array Name, Returns with X pointing at the memory location for the String Array, D is unchanged
            End If
            A$ = "PSHS": B$ = "X": C$ = "Save X on the stack": GoSub AssemOut
            A$ = "LEAX": B$ = "1,X": C$ = "Move X so it starts at the correct location": GoSub AssemOut
            A$ = "CLRB": C$ = "Clear the counter": GoSub AssemOut
            Z$ = "!"
            A$ = "INCB": C$ = "Increment the counter": GoSub AssemOut
            A$ = "LDA": B$ = ",U+": GoSub AssemOut
            A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AssemOut
            A$ = "CMPA": B$ = "#',": C$ = "Did we find a comma?": GoSub AssemOut
            A$ = "BNE": B$ = "<": GoSub AssemOut
            A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "STB": B$ = "[,S++]": C$ = "Save the length of the string and fix the stack": GoSub AssemOut
        Else
            Print "Error, can't figure out the INPUT variable in";: GoTo FoundError
        End If
    End If
    ' Check for a comma or end of line $0D
    v = Array(x): x = x + 1 ' get the &HF5
    If Array(x) = &H2C Then v = Array(x): x = x + 1 ' if found then consume the comma
Loop
v = Array(x): x = x + 1
Return
DoEND:
' Check for END SELECT command
v = Array(x): x = x + 1
If v = &HFF Then
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    If v = IF_CMD Then
        'We found an END IF
        num = ElseStack(IFSP): GoSub NumAsString 'num=IFCount associated with this IFProc
        ElseStack(Temp) = 0 ' flag as used
        If num < 10 Then Num$ = "0" + Num$
        Z$ = "_IFDone_" + Num$: C$ = "END IF line": GoSub AssemOut
        IFSP = IFSP - 1
        ENDIFCheck = ENDIFCheck - 1 ' we completed this IF
        GoTo SkipUntilEOLColon ' Consume any comments and the EOL/colon and Return
    Else
        If v = SELECT_CMD Then
            ' END SELECT
            If CaseElseFlag = 0 Then
                CaseCount(SELECTStackPointer) = CaseCount(SELECTStackPointer) + 1
                num = SELECTSTack(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                CaseNumber$ = Num$
                num = CaseCount(SELECTStackPointer) + 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                NextCaseNumber$ = CaseNumber$ + "_" + Num$
                num = CaseCount(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                CaseNumber$ = CaseNumber$ + "_" + Num$
                Z$ = "_CaseCheck_" + CaseNumber$: C$ = "No more CASEs": GoSub AssemOut
            End If
            num = SELECTSTack(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            Z$ = "_EndSelect_" + Num$: C$ = "This is the end of Select " + Num$: GoSub AssemOut
            CaseCount(SELECTStackPointer) = 0 ' make sure the next CASE in a SELECT starts normally
            SELECTStackPointer = SELECTStackPointer - 1
            A$ = "LDD": B$ = "EveryCasePointer": C$ = "Get the Flag pointer in D": GoSub AssemOut
            A$ = "SUBD": B$ = "#2": C$ = "D=D+2, move the pointer to the next flag": GoSub AssemOut
            A$ = "STD": B$ = "EveryCasePointer": C$ = "Save the new pointer in EveryCasePointer": GoSub AssemOut
            GoTo SkipUntilEOLColon ' Consume any comments and the EOL/colon and Return
        End If
    End If
Else
    ' no SELECT, just END the program
    A$ = "JMP": B$ = "EXITProgram": C$ = "All done, Exit the program": GoSub AssemOut
    GoTo SkipUntilEOLColon ' Consume any comments and the EOL/colon and Return
End If

DoNEXT:
v = Array(x): x = x + 1
If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then
    'No variable for this next given
    v = &HF2: x = x - 1 'Point at the &HF5 again so we can exit cleanly
End If
If v <> &HF2 Then Print "Error getting numeric variable needed in the NEXT command on";: GoTo FoundError
If FORStackPointer = 0 Then Print "Error: Next without FOR in line"; linelabel$: System
num = FORSTack(FORStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
A$ = "BRA": B$ = "ForLoop_" + Num$: C$ = "Goto the FOR loop": GoSub AssemOut
Z$ = "NEXTDone_" + Num$: C$ = "End of FOR/NEXT loop": GoSub AssemOut
FORStackPointer = FORStackPointer - 1
' Check for a Comma or EOL/Colon
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A Or Array(x) = &H2C) ' EOL, Colon or Comma
    v = Array(x): x = x + 1
Loop
v = Array(x): x = x + 1 'return with EOL or Colon, now pointing after the EOL or colon
If v = &H2C Then GoTo DoNEXT ' Check for a comma
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
If v = &HFF And (Array(x) = &H03 Or Array(x) = &H04) Then
    ' we have a REMark
    GoTo ConsumeCommentsAndEOL ' Consume any comments and the EOL and Return
End If
GoTo DoDim ' Set the next array values
DoREAD:
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)
    v = Array(x): x = x + 1
    If v = &HF0 Then
        ' we are reading a numeric array value
        GoSub MakeXPointAtNumericArray ' Returns with X pointing at the memory location for the Numeric Array, D is unchanged
        A$ = "LDU": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AssemOut
        A$ = "LDD": B$ = ",U++": C$ = "Load D with the value, move pointer to the next slot": GoSub AssemOut
        A$ = "STU": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AssemOut
        A$ = "STD": B$ = ",X": C$ = "Save Numeric variable": GoSub AssemOut
        GoTo DoREAD
    End If
    If v = &HF1 Then
        ' we are reading a string array value
        GoSub MakeXPointAtStringArray ' Returns with X pointing at the memory location for the String Array, D is unchanged
        A$ = "LDU": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AssemOut
        A$ = "LDB": B$ = ",U+": C$ = "Load B with the length of this string value, move pointer forward to the string data": GoSub AssemOut
        A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AssemOut
        A$ = "BEQ": B$ = "@Done": C$ = "If B=0 then no need to copy the string": GoSub AssemOut
        Z$ = "!"
        A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
        A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AssemOut
        A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
        A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
        Z$ = "@Done": GoSub AssemOut
        A$ = "STU": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AssemOut
        Print #1, ""
        GoTo DoREAD
    End If
    If v = &HF2 Then
        ' we are reading a numeric value
        v = Array(x) * 256 + Array(x + 1): x = x + 2
        NV$ = "_Var_" + NumericVariable$(v)
        '    GoSub GetExpressionB4SemiComEOL ' Get an Expression before a semi colon, a comma or an EOL
        A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AssemOut
        A$ = "LDD": B$ = ",X++": C$ = "Load D with the value, move pointer to the next slot": GoSub AssemOut
        A$ = "STX": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AssemOut
        A$ = "STD": B$ = NV$: C$ = "Save Numeric variable": GoSub AssemOut
        GoTo DoREAD
    End If
    If v = &HF3 Then
        ' we are reading a string value
        v = Array(x) * 256 + Array(x + 1): x = x + 2
        StringVar$ = "_StrVar_" + StringVariable$(v)
        '   GoSub GetExpressionB4SemiComEOL ' Get an Expression before a semi colon, a comma or an EOL
        A$ = "LDX": B$ = "#" + StringVar$: C$ = "Get the string pointer current value": GoSub AssemOut
        A$ = "LDU": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AssemOut
        A$ = "LDB": B$ = ",U+": C$ = "Load B with the length of this string value, move pointer forward to the string data": GoSub AssemOut
        A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AssemOut
        A$ = "BEQ": B$ = "@Done": C$ = "If B=0 then no need to copy the string": GoSub AssemOut
        Z$ = "!"
        A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
        A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AssemOut
        A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
        A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
        Z$ = "@Done": GoSub AssemOut
        A$ = "STU": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AssemOut
        Print #1, ""
        GoTo DoREAD
    End If
Loop
v = Array(x): x = x + 1
Return
DoRUN:
Color 14
Print "Can't do command RUN yet, found on line "; linelabel$
Color 15
System
DoRESTORE:
A$ = "LDD": B$ = "#DataStart": C$ = "Get the Address where DATA starts": GoSub AssemOut
A$ = "STD": B$ = "DATAPointer": C$ = "Save it in the DATAPointer variable": GoSub AssemOut
GoTo SkipUntilEOLColon ' Skip until we find an EOL or colon then return
DoRETURN:
A$ = "RTS": C$ = "RETURN": GoSub AssemOut
GoTo SkipUntilEOLColon ' Skip until we find an EOL or colon then return
DoSTOP:
A$ = "JMP": B$ = "EXITProgram": C$ = "All done, Exit the program": GoSub AssemOut
GoTo SkipUntilEOLColon ' Skip until we find an EOL or colon then return
DoPOKE:
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "TFR": B$ = "D,X": C$ = "Save D in X as the place to poke memory": GoSub AssemOut
'x in the array will now be pointing just past the ,
'Get value to poke in D (we only use B)
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "STB": B$ = ",X": C$ = "Store B at X": GoSub AssemOut
Return
DoCONT:
Color 14
Print "Can't do command CONT yet, found on line "; linelabel$
Color 15
System
DoLIST:
Color 14
Print "Can't do command LIST yet, found on line "; linelabel$
Color 15
System
DoCLEAR:
' We can ignore the clear commands since the addresses will be different from BASIC
' But the CLEAR command does also clear all the variables so we should do that here

' Get the numeric value before a comma In BASIC this would reserve RAM space for strings
' Get first number in D
GoSub GetExpressionB4SemiComEOL ' Get an Expression before a semi colon, a comma or an EOL
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, result will be in D
If v = &H2C Then
    x = x + 2 ' consume the &HF5 & comma
    'we have a comma so we should get the next value after the comma
    ' In BASIC this value would be where an ML program would be located
    GoSub GetExpressionB4EOL 'Get an expression that ends with a colon or End of a Line in Expression$
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, result will be in D
End If
A$ = "JSR": B$ = "ClearVariables": C$ = "Go clear the variables": GoSub AssemOut
GoTo SkipUntilEOLColon ' Skip until we find an EOL or colon then return
DoNEW:
Color 14
Print "Can't do command NEW yet, found on line "; linelabel$
Color 15
System
DoCLOAD:
Color 14
Print "Can't do command CLOAD yet, found on line "; linelabel$
Color 15
System
DoCSAVE:
Color 14
Print "Can't do command CSAVE yet, found on line "; linelabel$
Color 15
System
DoOPEN:
Color 14
Print "Can't do command OPEN yet, found on line "; linelabel$
Color 15
System
DoCLOSE:
Color 14
Print "Can't do command CLOSE yet, found on line "; linelabel$
Color 15
System
DoLLIST:
Color 14
Print "Can't do command LLIST yet, found on";: GoTo FoundError
Color 15
System
DoSET:
If Array(x) <> &HF5 And Array(x) <> &H28 Then Print "Can't find open bracket for SET command on";: GoTo FoundError
' Get the x co-ordinate
x = x + 2 'move past the open bracket
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 63": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
Z$ = "!"
A$ = "CMPB": B$ = "#63": C$ = "Check if B is > than 63": GoSub AssemOut
A$ = "BLE": B$ = ">": C$ = "If value is 63 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#63": C$ = "Make the max size 63": GoSub AssemOut
Z$ = "!"
A$ = "PSHS": B$ = "B": C$ = "Save the horizontal value on the stack": GoSub AssemOut
' Get the y co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 31": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
Z$ = "!"
A$ = "CMPB": B$ = "#31": C$ = "Check if B is > than 31": GoSub AssemOut
A$ = "BLE": B$ = ">": C$ = "If value is 31 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#31": C$ = "Make the max size 31": GoSub AssemOut
Z$ = "!"
A$ = "JSR": B$ = "GetSRPLocation": C$ = "Get the SET,RESET or POINT screen location, Enter with ,S = HOR COORD (0 to 63), B = VERT COORD (0 to 31)": GoSub AssemOut
A$ = "PSHS": B$ = "X": C$ = "Save the screen location on the stack, just in case X gets blown away getting the color value below from an array or other ways": GoSub AssemOut
' X now has the screen location for this byte
' Get the colour to set on screen
GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 8": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
Z$ = "!"
A$ = "CMPB": B$ = "#8": C$ = "Check if B is > than 8": GoSub AssemOut
A$ = "BLE": B$ = ">": C$ = "If value is 8 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#8": C$ = "Make the max value 8": GoSub AssemOut
Z$ = "!"
A$ = "PULS": B$ = "X": C$ = "Get the screen location off the stack": GoSub AssemOut
A$ = "JSR": B$ = "DoSet": C$ = "Go set the pixel on screen using colour B at X": GoSub AssemOut
GoTo SkipUntilEOLColon ' Skip until we find an EOL or a Colon and return
DoRESET:
If Array(x) <> &HF5 And Array(x) <> &H28 Then Print "Can't find open bracket for SET command on";: GoTo FoundError
' Get the x co-ordinate
x = x + 2 'move past the open bracket
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 63": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
Z$ = "!"
A$ = "CMPB": B$ = "#63": C$ = "Check if B is > than 63": GoSub AssemOut
A$ = "BLE": B$ = ">": C$ = "If value is 63 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#63": C$ = "Make the max size 63": GoSub AssemOut
Z$ = "!"
A$ = "PSHS": B$ = "B": C$ = "Save the horizontal value on the stack": GoSub AssemOut
' Get the y co-ordinate
GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 31": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
Z$ = "!"
A$ = "CMPB": B$ = "#31": C$ = "Check if B is > than 31": GoSub AssemOut
A$ = "BLE": B$ = ">": C$ = "If value is 31 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#31": C$ = "Make the max size 31": GoSub AssemOut
Z$ = "!"
A$ = "JSR": B$ = "GetSRPLocation": C$ = "Get the SET,RESET or POINT screen location, Enter with ,S = HOR COORD (0 to 63), B = VERT COORD (0 to 31)": GoSub AssemOut
A$ = "JSR": B$ = "DoReset": C$ = "Go Reset the pixel on screen": GoSub AssemOut
GoTo SkipUntilEOLColon ' Skip until we find an EOL or a Colon and return
DoCLS:
GoSub GetExpressionB4EOL: x = x + 2 ' Get the expression before an End of Line in Expression$ & move past it
If Expression$ = "" Then
    'No value given, do a standard CLS
    A$ = "LDB": B$ = "#$60": C$ = "B = Default background colour": GoSub AssemOut
    A$ = "JSR": B$ = "CLS_B": C$ = "Fill text screen with value of B": GoSub AssemOut
Else
    ' Get the numeric expression after the CLS in D
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, return with value in D
    A$ = "CMPD": B$ = "#9": C$ = "Compare value with 9": GoSub AssemOut
    A$ = "BLO": B$ = ">": C$ = "If value is lower than 9 then skip ahead": GoSub AssemOut
    A$ = "LDB": B$ = "#$60": C$ = "Otherwise make B = Default background colour": GoSub AssemOut
    A$ = "BRA": B$ = "@DoCLS": C$ = "Fill the screen with colour B": GoSub AssemOut
    Z$ = "!"
    A$ = "TSTB": C$ = "Compare value with 0": GoSub AssemOut
    A$ = "BNE": B$ = ">": C$ = "If value is 1 to 8 we're good, go show it": GoSub AssemOut
    A$ = "LDB": B$ = "#$80": C$ = "Otherwise make B = $80 as Black colour": GoSub AssemOut
    A$ = "BRA": B$ = "@DoCLS": C$ = "Fill the screen with colour B": GoSub AssemOut
    Z$ = "!"
    A$ = "DECB": C$ = "B = 0 to 7": GoSub AssemOut
    A$ = "LSLB": GoSub AssemOut
    A$ = "LSLB": GoSub AssemOut
    A$ = "LSLB": GoSub AssemOut
    A$ = "LSLB": C$ = "B = B * 16": GoSub AssemOut
    A$ = "ORB": B$ = "#%10001111": C$ = "Set bits 7,3,2,1,0": GoSub AssemOut
    Z$ = "@DoCLS:"
    A$ = "JSR": B$ = "CLS_B": C$ = "Fill text screen with value of B": GoSub AssemOut
    Print #1,
End If
Return
DoMOTOR:
v = Array(x): x = x + 1
If v <> &HFF Then Print "Error getting value of MOTOR command (ON/OFF) on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2
If v = ON_CMD Or v = OFF_CMD Then
    If v = ON_CMD Then
        ' MOTOR ON
        A$ = "LDA": B$ = "$FF21": C$ = "READ CRA OF U4": GoSub AssemOut
        A$ = "ORA": B$ = "#%00001000": C$ = "TURN ON BIT 3 WHICH ENABLES MOTOR DELAY": GoSub AssemOut
        A$ = "STA": B$ = "$FF21": C$ = "PUT IT BACK": GoSub AssemOut
    Else
        ' MOTOR OFF
        A$ = "LDA": B$ = "$FF21": C$ = "READ CRA OF U4": GoSub AssemOut
        A$ = "ANDA": B$ = "#%11110111": C$ = "TURN OFF BIT 3": GoSub AssemOut
        A$ = "STA": B$ = "$FF21": C$ = "PUT IT BACK": GoSub AssemOut
    End If
Else
    Print "Can't find ON or OFF for MOTOR command on";: GoTo FoundError
End If
Return
GoTo SkipUntilEOLColon ' Skip until we find an EOL or a Colon and return
DoSOUND:
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression value is now in D
A$ = "STB": B$ = "SoundTone": C$ = "Save the Tone Value": GoSub AssemOut
GoSub GetExpressionB4EOL: x = x + 2 ' Get the expression before an End of Line in Expression$
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression value is now in D
' B has the duration value
A$ = "LDA": B$ = "#$04": C$ = "Match timing of Color BASIC": GoSub AssemOut
A$ = "MUL": C$ = "D now has the proper length": GoSub AssemOut
A$ = "STD": B$ = "SoundDuration": C$ = "Save the length of the sound": GoSub AssemOut
A$ = "JSR": B$ = "PlaySound": C$ = "Go play the SOUND": GoSub AssemOut
Return
DoAUDIO:
v = Array(x): x = x + 1
If v <> &HFF Then Print "Error getting value of AUDIO command (ON/OFF) on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2
If v = ON_CMD Or v = OFF_CMD Then
    If v = ON_CMD Then
        ' Audio ON
        A$ = "LDB": B$ = "#$01": C$ = "Multiplexer setting for cassette input": GoSub AssemOut
        A$ = "JSR": B$ = "Select_AnalogMuxer": C$ = "ROUTE CASSETTE TO SOUND MULTIPLEXER": GoSub AssemOut
        A$ = "JSR": B$ = "AnalogMuxOn": C$ = "ENABLE SOUND MULTIPLEXER": GoSub AssemOut
    Else
        ' Audio OFF
        A$ = "JSR": B$ = "AnalogMuxOff": C$ = "TURN OFF ANALOG MUX": GoSub AssemOut
    End If
Else
    Print "Can't find ON or OFF for AUDIO command on";: GoTo FoundError
End If
Return
DoEXEC:
v = Array(x): x = x + 1
If v >= Asc("0") And v <= Asc("9") Or (v = Asc("&") And Array(x) = Asc("H")) Then ' Printing a number, PRINT 10*20
    x = x - 1 ' make sure to inlcude the first Numeric variable
    GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
    A$ = "TFR": B$ = "D,PC": C$ = "JMP to D": GoSub AssemOut
    Return
End If
If v = &HF0 Then ' Printing a Numeric Array variable, PRINT A(5)
    x = x - 1 ' make sure to inlcude the first Numeric array variable
    GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
    A$ = "TFR": B$ = "D,PC": C$ = "JMP to D": GoSub AssemOut
    Return
End If
If v = &HF2 Then ' Printing a Regular Numeric Variable, PRINT A
    x = x - 1 ' make sure to inlcude the first Numeric variable
    GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
    A$ = "TFR": B$ = "D,PC": C$ = "JMP to D": GoSub AssemOut
    Return
End If
If v = &HF5 Then
    ' Found a special character
    v = Array(x): x = x + 1
    If v = &H0D Or v = &H3A Then ' Execute address in the EXECAddress
        A$ = "JMP": B$ = "[EXECAddress]": C$ = "Jump to address stored at EXECAddress": GoSub AssemOut
        Return ' we have reached the end of the line return
    End If
End If
Print "Error: Can't handle expression after the EXEC command on";: GoTo FoundError
DoSKIPF:
Color 14
Print "Can't do command SKIPF yet, found on line "; linelabel$
Color 15
System
DoTAB:
Color 14
Print "Can't do command TAB yet, found on line "; linelabel$
Color 15
System
DoBUTTON:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
Else
    ' Get the numeric value before a Close bracket
    v = Array(x): x = x + 1 ' skip the open bracket
    ' Get first number in D
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "ANDB": B$ = "#%00000011": C$ = "Make B between zero and 3": GoSub AssemOut
A$ = "JSR": B$ = "BUTTON": C$ = "Go get a button and return with result in D": GoSub AssemOut
Return
DoGOSUB:
Temp$ = ""
v = Array(x): x = x + 1
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' could be EOL or a colon if it's part of an IF/THEN/ELSE or REMark
    Temp$ = Temp$ + Chr$(v)
    v = Array(x): x = x + 1
Loop
x = x + 1
A$ = "BSR": B$ = "_L" + Temp$: C$ = "GOSUB " + Temp$: GoSub AssemOut
Return
DoThen:
Color 14
Print "Can't do command THEN yet, found on line "; linelabel$
Color 15
System
'DoNOT: ' Not is an operator, this was the wrong way to handle it...
'Color 14
'Print "Can't do command NOT yet, found on line "; linelabel$
'Color 15
'System
DoSTEP:
Color 14
Print "Can't do command STEP yet, found on line "; linelabel$
Color 15
System
DoOFF:
Color 14
Print "Can't do command OFF yet, found on line "; linelabel$
Color 15
System
DoTO:
Color 14
Print "Can't do command TO yet, found on line "; linelabel$
Color 15
System
DoDEL:
Color 14
Print "Can't do command DEL yet, found on line "; linelabel$
Color 15
System
DoEDIT:
Color 14
Print "Can't do command EDIT yet, found on line "; linelabel$
Color 15
System
DoTRON:
Color 14
Print "Can't do command TRON yet, found on line "; linelabel$
Color 15
System
DoTROFF:
Color 14
Print "Can't do command TROFF yet, found on line "; linelabel$
Color 15
System
DoDEF:
' DefLabel$(1000)
' DefLabelCount = 0
v = Array(x): x = x + 1: If v <> &HFB Then Print "Something is wrong with the DEF assignment on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2 ' get the label pointer
DefL$ = DefLabel$(v)
A$ = "BRA": B$ = "DefFN_" + DefL$ + "_Done": C$ = "Skip over DEF FN Setup code": GoSub AssemOut
Z$ = "DefFN_" + DefL$: GoSub AssemOut
Do Until v = &HFC And Array(x) = &H3D
    v = Array(x): x = x + 1
Loop
x = x + 1
GoSub GetExpressionB4EOL: x = x + 2 ' Get the expression before an End of Line in Expression$
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "RTS": C$ = "Start of FN function " + DefL$: GoSub AssemOut: C$ = "FN " + DefL$ + " is done.": GoSub AssemOut
Z$ = "DefFN_" + DefL$ + "_Done": GoSub AssemOut
Return
' Will never get here
DoLET:
v = Array(x): x = x + 1 ' Consume the space
v = Asc(":")
Return
DoLINE:
v = Array(x): x = x + 1
ContinueLine = 0
' Add code to handle LINE-(x,y),PSET instead of normal LINE(x,y)-(x1,y1),PSET
If v = &HFC And Array(x) = &H2D Then
    ' Found a hyphen, this is a LINE-(x,y),PSET
    ContinueLine = 1
    x = x - 2 ' Make it point to the same place it needs below
End If
If ContinueLine = 0 And Array(x) <> &H28 Then Print "Can't find open bracket for LINE command on";: GoTo FoundError

' Get the start x co-ordinate
If ContinueLine = 1 Then
    ' Use the old X location from the previous LINE command
    A$ = "LDD": B$ = "endX": C$ = "Use the old X location from the previous LINE command": GoSub AssemOut
Else
    x = x + 1 'move past the open bracket
    GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
End If
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#255": C$ = "Check if B is > than 255": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB0": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
Z$ = "@SaveB0"
A$ = "PSHS": B$ = "B": C$ = "Save the x coordinate value on the stack": GoSub AssemOut
' Get the start y co-ordinate
If ContinueLine = 1 Then
    ' Use the old Y location from the previous LINE command
    A$ = "LDD": B$ = "endY": C$ = "Use the old Y location from the previous LINE command": GoSub AssemOut
Else
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB1": C$ = "If value is 191 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
Z$ = "@SaveB1"
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
Print #1, ' Need a space for @ in assembly
' Make Sure we have a -(
If Array(x + 1) = &H2D And Array(x + 2) = &HF5 And Array(x + 3) = &H28 Then
    ' all is good
    x = x + 4 ' Move past the open bracket
Else
    Print "Can't find minus or open bracket for Line command on";: GoTo FoundError
End If
' Get the destination x co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#255": C$ = "Check if B is > than 255": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB0": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
Z$ = "@SaveB0"
A$ = "PSHS": B$ = "B": C$ = "Save the x coordinate value on the stack": GoSub AssemOut
' Get the destination y co-ordinate
GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB1": C$ = "If value is 191 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
Z$ = "@SaveB1"
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
x = x + 1 ' Skip &HF5
v = Array(x): x = x + 1 ' Get comma
If v <> &H2C Then Print "Can't find comma after the destination x & y co-ordinates on";: GoTo FoundError
' Should have a PSET or PRESET command next
v = Array(x): x = x + 1
If v <> &HFF Then Print "Can't find PSET or RESET after the destination x & y co-ordinates on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2 ' Get PSET or RESET command
If v = PSET_CMD Then
    'Found a PSET - Forground colour
    PsetFlag = 1
Else
    If v = PRESET_CMD Then
        ' Found a PRESET - Background Colour
        PsetFlag = 0
    Else
        Print "Can't find PSET or RESET after the destination x & y co-ordinates on";: GoTo FoundError
    End If
End If
' Other options for Line Command
' after PSET or RESET we will have
' ,0,0 - No Box or Box Fill
' ,1,0 - Draw a Box
' ,1,1 - Draw a box and fill it
x = x + 2 ' consume the F5 & comma
Box = Array(x): x = x + 1 ' get the Box flag
x = x + 2 ' consume the F5 & comma
Fill = Array(x): x = x + 1 ' get the Fill flag
If Box = Asc("0") Then
    ' no box or fill, just draw a line
    If PsetFlag = 1 Then
        A$ = "JSR": B$ = "LINE4": C$ = "Go draw foreground colour line": GoSub AssemOut
    Else
        A$ = "JSR": B$ = "PRESETLINE4": C$ = "Go draw background colour line": GoSub AssemOut
    End If
Else
    'We have a box to draw
    If Fill = Asc("0") Then
        ' Don't fill the box
        If PsetFlag = 1 Then
            A$ = "JSR": B$ = "BOX4": C$ = "Go draw foreground colour box": GoSub AssemOut
        Else
            A$ = "JSR": B$ = "PRESETBOX4": C$ = "Go draw background colour box": GoSub AssemOut
        End If
    Else
        ' Fill the box
        If PsetFlag = 1 Then
            A$ = "JSR": B$ = "BoxFill4": C$ = "Go draw foreground colour box": GoSub AssemOut
        Else
            A$ = "JSR": B$ = "PRESETBoxFill4": C$ = "Go draw background colour box": GoSub AssemOut
        End If
    End If
End If
Print #1,
Return
DoPCLS:
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
If Expression$ = "" Then
    ' No value after the PCLS
    A$ = "LDB": B$ = "BAKCOL": C$ = "GET BACKGROUND COLOR": GoSub AssemOut
Else
    ' convert the Expression to a value in D
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, return with value in D
    A$ = "CMPD": B$ = "#9": C$ = "Compare value with 9": GoSub AssemOut
    A$ = "BLO": B$ = ">": C$ = "If value is lower than 9 then skip ahead": GoSub AssemOut
    A$ = "LDB": B$ = "BAKCOL": C$ = "Otherwise make B = background colour": GoSub AssemOut
    A$ = "BRA": B$ = "@GotB": C$ = "Fill the screen with colour B": GoSub AssemOut
    Z$ = "!"
    A$ = "TSTB": C$ = "Compare value with 0": GoSub AssemOut
    A$ = "BPL": B$ = "@GotB": C$ = "If value is 0 to 8 we're good, go show it": GoSub AssemOut
    A$ = "LDB": B$ = "BAKCOL": C$ = "Otherwise make B = background colour": GoSub AssemOut
    Z$ = "@GotB"
    A$ = "JSR": B$ = "GetColourBCSSA": C$ = "Depending on PMODE return with CSS value in A and Colour Value in B": GoSub AssemOut
End If
A$ = "JSR": B$ = "DoPCLS": C$ = "Go fill the screen, with colour B": GoSub AssemOut
Return
DoPSET:
x = x + 2 'skip the open bracket
If Array(x - 1) <> &H28 Then Print "Can't find open bracket for PSET command on";: GoTo FoundError
' Get the x co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#255": C$ = "Check if B is > than 255": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB0": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
Z$ = "@SaveB0"
A$ = "PSHS": B$ = "B": C$ = "Save the x coordinate value on the stack": GoSub AssemOut
' Get the y co-ordinate
GoSub GetExpressionB4CommaEndBracket: x = x + 2 'Handle an expression that ends with a comma or end bracket skipping extra brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB1": C$ = "If value is 191 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
Z$ = "@SaveB1"
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
If Array(x - 1) = &H2C Then
    ' we got the value before a comma so there is a colour value with this PSET command
    ' Get the colour to set on screen
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
    A$ = "ANDB": B$ = "#%00000001": C$ = "Make tit zero or 1": GoSub AssemOut
    A$ = "BEQ": B$ = ">": C$ = "Make the max size 191": GoSub AssemOut
    A$ = "PULS": B$ = "D": C$ = "Get A=y, B=x coordinates off the stack": GoSub AssemOut
    A$ = "JSR": B$ = "PSET4": C$ = "Go draw the pixel on screen": GoSub AssemOut
    A$ = "BRA": B$ = "@Done": C$ = "Skip to done": GoSub AssemOut
    Z$ = "!"
    A$ = "PULS": B$ = "D": C$ = "Get A=y, B=x coordinates off the stack": GoSub AssemOut
    A$ = "JSR": B$ = "PRESET4": C$ = "Go draw the pixel on screen": GoSub AssemOut
    Z$ = "@Done": GoSub AssemOut
Else
    A$ = "PULS": B$ = "D": C$ = "Get A=y, B=x coordinates off the stack": GoSub AssemOut
    A$ = "JSR": B$ = "PSET4": C$ = "Go draw the pixel on screen": GoSub AssemOut
End If
Print #1,
Return
DoPRESET:
x = x + 2 'skip the open bracket
If Array(x - 1) <> &H28 Then Print "Can't find open bracket for PRESET command on";: GoTo FoundError
' Get the x co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#255": C$ = "Check if B is > than 255": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB0": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
Z$ = "@SaveB0"
A$ = "PSHS": B$ = "B": C$ = "Save the x coordinate value on the stack": GoSub AssemOut
' Get the y co-ordinate
GoSub GetExpressionB4CommaEndBracket: x = x + 2 'Handle an expression that ends with a comma or end bracket skipping extra brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB1": C$ = "If value is 191 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
Z$ = "@SaveB1"
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
If Array(x - 1) = &H2C Then
    ' we got the value before a comma so there is a colour value with this PSET command
    ' Get the colour to set on screen
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
    A$ = "ANDB": B$ = "#%00000001": C$ = "Make tit zero or 1": GoSub AssemOut
    A$ = "BEQ": B$ = ">": C$ = "Make the max size 191": GoSub AssemOut
    A$ = "PULS": B$ = "D": C$ = "Get A=y, B=x coordinates off the stack": GoSub AssemOut
    A$ = "JSR": B$ = "PSET4": C$ = "Go draw the pixel on screen": GoSub AssemOut
    Z$ = "!"
    A$ = "PULS": B$ = "D": C$ = "Get A=y, B=x coordinates off the stack": GoSub AssemOut
    A$ = "JSR": B$ = "PRESET4": C$ = "Go draw the pixel on screen": GoSub AssemOut
Else
    A$ = "PULS": B$ = "D": C$ = "Get A=y, B=x coordinates off the stack": GoSub AssemOut
    A$ = "JSR": B$ = "PRESET4": C$ = "Go draw the pixel on screen": GoSub AssemOut
End If
Print #1,
Return
DoSCREEN:
If Array(x) = &HF5 And Array(x + 1) = &H2C Then x = x + 2: GoTo ColourSet ' No Screen Mode # just the screen number
' Get the numeric value before a comma or EOL or Colon
' Get first number in D
GoSub GetExpressionB4SemiComEOL: x = x + 2 ' Get an Expression before a semi colon, a comma or an EOL, move past them
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
If v = &H0D Or v = &H3A Then
    ' No Comma
    A$ = "LDA": B$ = "#$FF": C$ = "Flag Colour Set should not change": GoSub AssemOut
    A$ = "EXG": B$ = "A,B": C$ = "Screen Mode in A, Screen Flag in B": GoSub AssemOut
    GoTo ScreenSkipColourSet
Else
    A$ = "PSHS": B$ = "B": C$ = "Save Screen Mode # on the stack": GoSub AssemOut
End If
If v <> &H2C Then Print "Should have a Comma in the SCREEN command on";: GoTo FoundError
ColourSet:
'Get the Colour set number in D (we only use B)
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "PULS": B$ = "A": C$ = "Get the Screen Mode off the stack": GoSub AssemOut
ScreenSkipColourSet:
A$ = "JSR": B$ = "DoScreen": C$ = "Go show the screen, A=Screen mode, B= Colour Set": GoSub AssemOut
Return
DoPCLEAR:
Color 14
Print "Can't do command PCLEAR yet, found on line "; linelabel$
Color 15
System
DoCOLOR:
Color 14
Print "Can't do command COLOR yet, found on line "; linelabel$
Color 15
System
DoCIRCLE:
x = x + 2 'skip the open bracket
If Array(x - 1) <> &H28 Then Print "Can't find open bracket for CIRCLE command on";: GoTo FoundError
' Get the x co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#255": C$ = "Check if B is > than 255": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB0": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
Z$ = "@SaveB0"
A$ = "PSHS": B$ = "B": C$ = "Save the x coordinate value on the stack": GoSub AssemOut
' Get the y co-ordinate
GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB1": C$ = "If value is 191 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
Z$ = "@SaveB1"
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
x = x + 2 'move past the &HF5 & comma
If Array(x - 1) <> &H2C Then Print "Can't find comma after CIRCLE command on";: GoTo FoundError
GoSub GetExpressionB4SemiComEOL: x = x + 2 ' Get an Expression before a semi colon, a comma or an EOL
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
A$ = "JSR": B$ = "CIRCLE": C$ = "Go draw a circle": GoSub AssemOut
A$ = "LEAS": B$ = "3,S": C$ = "Fix the stack": GoSub AssemOut
Print #1,
If v = &H0D Or v = &H3A Then Return ' no other values in the CIRCLE command

' Add other options for circle's Colour
Color 14
Print "Can't do extra CIRCLE features yet, found on";: GoTo FoundError
Color 15
System
DoPAINT:
x = x + 2 'skip the open bracket
If Array(x - 1) <> &H28 Then Print "Can't find open bracket for PAINT command on";: GoTo FoundError
' Get the x co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#255": C$ = "Check if B is > than 255": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB0": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
Z$ = "@SaveB0"
A$ = "PSHS": B$ = "B": C$ = "Save the x coordinate value on the stack": GoSub AssemOut
' Get the y co-ordinate
GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB1": C$ = "If value is 191 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
Z$ = "@SaveB1"
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
x = x + 2 'move past the &HF5 & comma
If Array(x - 1) <> &H2C Then Print "Can't find comma after CIRCLE command on";: GoTo FoundError
GoSub GetExpressionB4SemiComEOL: x = x + 2 ' Get an Expression before a semi colon, a comma or an EOL
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "PSHS": B$ = "B": C$ = "Save the colour to PAINT on the stack": GoSub AssemOut
GoSub GetExpressionB4SemiComEOL: x = x + 2 ' Get an Expression before a semi colon, a comma or an EOL
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "PSHS": B$ = "B": C$ = "Save the Border Colour on the stack": GoSub AssemOut
A$ = "LDX": B$ = ",S++": C$ = "Get Border Colour and Paint Colour in X": GoSub AssemOut
A$ = "LDD": B$ = ",S++": C$ = "Get y & x co-ordinate in D": GoSub AssemOut
A$ = "JSR": B$ = "PAINT": C$ = "Go do the PAINT/Flood Fill": GoSub AssemOut
Print #1,
Return
DoGET:
v = Array(x): x = x + 1
If Array(x) <> &H28 Then Print "Can't find open bracket for GET command on";: GoTo FoundError
' Get the start x co-ordinate
x = x + 1 'move past the open bracket
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D

A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#255": C$ = "Check if B is > than 255": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB0": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
Z$ = "@SaveB0"
A$ = "PSHS": B$ = "B": C$ = "Save the x coordinate value on the stack": GoSub AssemOut
' Get the start y co-ordinate
GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression

A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB1": C$ = "If value is 191 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
Z$ = "@SaveB1"
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
Print #1, ' Need a space for @ in assembly
' Make Sure we have a -(
If Array(x + 1) = &H2D And Array(x + 2) = &HF5 And Array(x + 3) = &H28 Then
    ' all is good
    x = x + 4 ' Move past the open bracket
Else
    Print "Can't find minus or open bracket for GET command on";: GoTo FoundError
End If
' Get the destination x co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#255": C$ = "Check if B is > than 255": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB0": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
Z$ = "@SaveB0"
A$ = "PSHS": B$ = "B": C$ = "Save the x coordinate value on the stack": GoSub AssemOut
' Get the destination y co-ordinate
GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB1": C$ = "If value is 191 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
Z$ = "@SaveB1"
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
Print #1, ' make sure to leave a blank line so the @ are all good
x = x + 1 ' Skip &HF5
v = Array(x): x = x + 1 ' Get comma
If v <> &H2C Then Print "Can't find comma after the destination x & y co-ordinates on";: GoTo FoundError
' Should have an array name next
v = Array(x): x = x + 1
If v <> &HF0 Then Print "Can't find Array name after the destination x & y co-ordinates on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2
NV$ = NumericArrayVariables$(v)
NumDims = Array(x): x = x + 1 ' Skip past the number of arrays it's always 2
A$ = "LDU": B$ = "#_ArrayNum_" + NV$: C$ = "U points at the start of the array": GoSub AssemOut
A$ = "JSR": B$ = "GET": C$ = "Go fill the GET buffer that U points at": GoSub AssemOut
Return
DoPUT:
v = Array(x): x = x + 1
If Array(x) <> &H28 Then Print "Can't find open bracket for PUT command on";: GoTo FoundError
' Get the start x co-ordinate
x = x + 1 'move past the open bracket
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D

A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#255": C$ = "Check if B is > than 255": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB0": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
Z$ = "@SaveB0"
A$ = "PSHS": B$ = "B": C$ = "Save the x coordinate value on the stack": GoSub AssemOut
' Get the start y co-ordinate
GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression

A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB1": C$ = "If value is 191 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
Z$ = "@SaveB1"
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
Print #1, ' Need a space for @ in assembly
' Make Sure we have a -(
If Array(x + 1) = &H2D And Array(x + 2) = &HF5 And Array(x + 3) = &H28 Then
    ' all is good
    x = x + 4 ' Move past the open bracket
Else
    Print "Can't find minus or open bracket for PUT command on";: GoTo FoundError
End If
' Get the destination x co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#255": C$ = "Check if B is > than 255": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB0": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
Z$ = "@SaveB0"
A$ = "PSHS": B$ = "B": C$ = "Save the x coordinate value on the stack": GoSub AssemOut
' Get the destination y co-ordinate
GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "TSTA": C$ = "Check if D is a negative": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
A$ = "BLE": B$ = "@SaveB1": C$ = "If value is 191 or < then skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
Z$ = "@SaveB1"
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AssemOut
Print #1, ' make sure to leave a blank line so the @ are all good
x = x + 1 ' Skip &HF5
v = Array(x): x = x + 1 ' Get comma
If v <> &H2C Then Print "Can't find comma after the destination x & y co-ordinates on";: GoTo FoundError
' Should have an array name next
v = Array(x): x = x + 1
If v <> &HF0 Then Print "Can't find Array name after the destination x & y co-ordinates on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2
NV$ = NumericArrayVariables$(v)
A$ = "LDU": B$ = "#_ArrayNum_" + NV$: C$ = "U points at the start of the array": GoSub AssemOut
PutType = Array(x): x = x + 1 ' Get the type of PUT command to execute
' PutType Action
'   0     PSET
'   1     PRESET
'   2     AND
'   3     OR
'   4     NOT
'   5     XOR - New command ' why not
If PutType = 0 Then A$ = "JSR": B$ = "PUT_PSET": C$ = "Go Draw the buffer that U points at on screen": GoSub AssemOut: Return
If PutType = 1 Then A$ = "JSR": B$ = "PUT_PRESET": C$ = "Go Draw the buffer that U points at on screen": GoSub AssemOut: Return
If PutType = 2 Then A$ = "JSR": B$ = "PUT_AND": C$ = "Go Draw the buffer that U points at on screen": GoSub AssemOut: Return
If PutType = 3 Then A$ = "JSR": B$ = "PUT_OR": C$ = "Go Draw the buffer that U points at on screen": GoSub AssemOut: Return
If PutType = 4 Then A$ = "JSR": B$ = "PUT_NOT": C$ = "Go Draw the buffer that U points at on screen": GoSub AssemOut: Return
If PutType = 5 Then A$ = "JSR": B$ = "PUT_XOR": C$ = "Go Draw the buffer that U points at on screen": GoSub AssemOut: Return
Print "Error handling type of PUT on": GoSub FoundError
DoDRAW:
' Copy strings and quotes to a tempstring
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
A$ = "JSR": B$ = "Draw": C$ = "Draw command, will draw the commands in the string _StrVar_PF00": GoSub AssemOut
Return
DoPCOPY:
Color 14
Print "Can't do command PCOPY yet, found on line "; linelabel$
Color 15
System
' For now only do a PMODE 4 screen, ignore all other modes
DoPMODE:
If Array(x) = &HF5 And Array(x + 1) = &H2C Then x = x + 2: GoTo PModeScreen ' No PMODE # just the screen number
' Get the numeric value before a comma or EOL or Colon
' Get first number in D
GoSub GetExpressionB4SemiComEOL: x = x + 2 ' Get an Expression before a semi colon, a comma or an EOL, move past them
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
If v = &H0D Or v = &H3A Then
    ' No Comma
    A$ = "LDA": B$ = "#$FF": C$ = "Flag PMODE screen should not change": GoSub AssemOut
    A$ = "EXG": B$ = "A,B": C$ = "PMODE # in A, Screen Flag in B": GoSub AssemOut
    GoTo PModeSkipScreen
Else
    A$ = "PSHS": B$ = "B": C$ = "Save PMODE # on the stack": GoSub AssemOut
End If
If v <> &H2C Then Print "Should have a Comma in the PMODE command on";: GoTo FoundError
PModeScreen:
'Get the screen number in D (we only use B)
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "PULS": B$ = "A": C$ = "Get the PMODE off the stack": GoSub AssemOut
PModeSkipScreen:
A$ = "JSR": B$ = "DoPMODE": C$ = "Go setup a PMODE screen, A = PMODE # and B is the screen number": GoSub AssemOut
Return
DoPLAY:
' Copy strings and quotes to a tempstring
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
A$ = "JSR": B$ = "Play": C$ = "Play command, will play the commands in the string _StrVar_PF00": GoSub AssemOut
Return
DoSDCPLAY:
' Copy filename to a tempstring
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
' Check the filename to make sure it's OK
A$ = "JSR": B$ = "SDCPLAY": C$ = "Play audio sample where the filename is in _StrVar_PF00": GoSub AssemOut
Return
DoSDCPLAYORCL:
' Copy filename to a tempstring
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
' Check the filename to make sure it's OK
A$ = "JSR": B$ = "SDCPLAYOrcL": C$ = "Play audio sample where the filename is in _StrVar_PF00 on Orc 90/CoCo Flash Left Speaker output": GoSub AssemOut
Return
DoSDCPLAYORCR:
' Copy filename to a tempstring
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
' Check the filename to make sure it's OK
A$ = "JSR": B$ = "SDCPLAYOrcR": C$ = "Play audio sample where the filename is in _StrVar_PF00 on Orc 90/CoCo Flash Right Speaker output": GoSub AssemOut
Return
DoSDCPLAYORCS:
' Copy filename to a tempstring
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
' Check the filename to make sure it's OK
A$ = "JSR": B$ = "SDCPLAYOrcS": C$ = "Play audio sample where the filename is in _StrVar_PF00 on Orc 90/CoCo Flash in Stereo": GoSub AssemOut
Return
DoDLOAD:
Color 14
Print "Can't do command DLOAD yet, found on line "; linelabel$
Color 15
System
DoRENUM:
Color 14
Print "Can't do command RENUM yet, found on line "; linelabel$
Color 15
System
' Enters with v already set
DoFN:
DefFN$ = DefLabel$(v)
DefFNVar$ = NumericVariable$(DefVar(v))
' Get the variable name used in the DEF FN
A$ = "LDX": B$ = "_Var_" + DefFNVar$: C$ = "Get the dummy variable for this function": GoSub AssemOut
A$ = "PSHS": B$ = "X": C$ = "Save it on the stack": GoSub AssemOut
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
Else
    ' Get the numeric value before a Close bracket
    v = Array(x): x = x + 1 ' skip the open bracket
    ' Get first number in D
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "STD": B$ = "_Var_" + DefFNVar$: C$ = "Save it in the dummy variable": GoSub AssemOut
A$ = "JSR": B$ = "DefFN_" + DefFN$: C$ = "Go do the function and return with the value in D": GoSub AssemOut
A$ = "PULS": B$ = "X": C$ = "Get the original value of the dummy variable": GoSub AssemOut
A$ = "STX": B$ = "_Var_" + DefFNVar$: C$ = "Restore dummy variable's value": GoSub AssemOut
Return
DoUSING:
Color 14
Print "Can't do command USING yet, found on line "; linelabel$
Color 15
System
DoDIR:
Color 14
Print "Can't do command DIR yet, found on line "; linelabel$
Color 15
System
DoDRIVE:
Color 14
Print "Can't do command DRIVE yet, found on line "; linelabel$
Color 15
System
DoFIELD:
Color 14
Print "Can't do command FIELD yet, found on line "; linelabel$
Color 15
System
DoFILES:
Color 14
Print "Can't do command FILES yet, found on line "; linelabel$
Color 15
System
DoKILL:
Color 14
Print "Can't do command KILL yet, found on line "; linelabel$
Color 15
System
DoLOAD:
Color 14
Print "Can't do command LOAD, maybe this should be a LOADM, found on line "; linelabel$
Color 15
System
DoLOADM:
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
LoadmAfterFilename:
v = Array(x): x = x + 1
'Print #1, "; GetSectionToLOADM, v=$"; Hex$(v)
If v = &HF5 Then
    ' Found a special character
    v = Array(x): x = x + 1
    If v = &H2C Then ' Handle a comma on the LOADM line
        GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
        ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
        A$ = "STD": B$ = "_Var_PF10": C$ = "Store D at _Var_PF10 as the LOADM offset value": GoSub AssemOut
    Else
        A$ = "CLR": B$ = "_Var_PF10": C$ = "Set _Var_PF10 to zero as the LOADM offset value": GoSub AssemOut
        A$ = "CLR": B$ = "_Var_PF10+1": C$ = "Set _Var_PF10 to zero as the LOADM offset value": GoSub AssemOut
    End If
    If v = &H0D Or v = &H3A Then ' Handle EOL/Colon
        GoTo OpenLoadm ' Do LOADM
    End If
End If
Print "Error, Not sure how to handle LOADM filename on line "; linelabel$; " v = $"; Hex$(v), Chr$(v)
Print "x-2 = $"; Hex$(Array(x - 2))
Print "x-1 = $"; Hex$(Array(x - 1))
Print "x   = $"; Hex$(Array(x))
Print "x+1 = $"; Hex$(Array(x + 1))
Print "x+2 = $"; Hex$(Array(x + 2))
Print "x+3 = $"; Hex$(Array(x + 3))
System
OpenLoadm:
A$ = "JSR": B$ = "FixFileName": C$ = "Format _StrVar_PF00 to proper disk filename format in memory at DNAMBF": GoSub AssemOut
A$ = "LDU": B$ = "#DNAMBF": C$ = "U points at the filename to open": GoSub AssemOut
' Open the the File pointed at by U
' Enter with U pointing at the properly formatted filename (8 character filename badded with spaces) and a 3 character extension
' Exits with X pointing at the filename entry in the disk directory
' Carry flag will be set if it couldn't find the filename, cleared otherwise
A$ = "JSR": B$ = "OpenFileU": C$ = "Go open file": GoSub AssemOut
A$ = "BCS": B$ = "DiskError": C$ = "Error Openning the File": GoSub AssemOut
' Initialize File for reading:
' *** Enter with: X pointing at the filename to open
' Copy the file info to the file control block
' Copy Granule table for the file on the correct drive
' setup the end sector to compare with for this granule
' setup the track to read from
' copy the first 256 bytes of the file into the file buffer
' set the buffer pointer to the beginning of the buffer
' Load the first sector of the file into the file buffer
' At this point the file is ready to be read from by calling either DiskReadByteA or DiskReadWordD
' *** Exit with: Y pointing at the FATBLx associated with the drive DCDRV (preserve Y until file has been closed)
A$ = "JSR": B$ = "InitFile": C$ = "Prep open file for reading": GoSub AssemOut
' Do a LOADM command
' File must already be Initialized
' *** Enter with: Y pointing at the FATBLx associated with the drive DCDRV
' * Loads a  Machine Language file from the disk
' Adds the 16 bit value stored in _Var_PF10 to the Load Address and the EXEC address
A$ = "JSR": B$ = "DiskLOADM": C$ = "Load the ML program": GoSub AssemOut
Return ' we have reached the end of the line return
DoLSET:
Color 14
Print "Can't do command LSET yet, found on line "; linelabel$
Color 15
System
DoMERGE:
Color 14
Print "Can't do command MERGE yet, found on line "; linelabel$
Color 15
System
DoRENAME:
Color 14
Print "Can't do command RENAME yet, found on line "; linelabel$
Color 15
System
DoRSET:
Color 14
Print "Can't do command RSET yet, found on line "; linelabel$
Color 15
System
DoSAVE:
Color 14
Print "Can't do command SAVE yet, found on line "; linelabel$
Color 15
System
DoWRITE:
Color 14
Print "Can't do command WRITE yet, found on line "; linelabel$
Color 15
System
DoVERIFY:
Color 14
Print "Can't do command VERIFY yet, found on line "; linelabel$
Color 15
System
DoUNLOAD:
Color 14
Print "Can't do command UNLOAD yet, found on line "; linelabel$
Color 15
System
DoDSKINI:
Color 14
Print "Can't do command DSKINI yet, found on line "; linelabel$
Color 15
System
DoBACKUP:
Color 14
Print "Can't do command BACKUP yet, found on line "; linelabel$
Color 15
System
DoCOPY:
Color 14
Print "Can't do command COPY yet, found on line "; linelabel$
Color 15
System
DoWPOKE:
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "TFR": B$ = "D,X": C$ = "Save D in X as the place to poke memory": GoSub AssemOut
'x in the array will now be pointing just past the ,
'Get value to poke in D (we only use B)
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "STD": B$ = ",X": C$ = "Store D at X": GoSub AssemOut
Return
DoWHILE:
WhileCount = WhileCount + 1
WhileStackPointer = WhileStackPointer + 1
WHILEStack(WhileStackPointer) = WhileCount
num = WhileCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
WhileLoopNum$ = Num$
Z$ = "WhileLoop_" + WhileLoopNum$: C$ = "Start of WHILE/WEND loop": GoSub AssemOut
CheckIfTrue$ = ""
v = 0
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' Keep copying until we get EOL or Colon
    v = Array(x): x = x + 1
    If v <> Asc(" ") Then CheckIfTrue$ = CheckIfTrue$ + Chr$(v) 'skip spaces
Loop
v = Array(x): x = x + 1
CheckIfTrue$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HF5 on the end
GoSub GoCheckIfTrue ' This parses CheckIfTrue$ get's it ready to be evaluated in the string NewString$
GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
A$ = "BEQ": B$ = "Wend_" + WhileLoopNum$: C$ = "If the result is a false then goto the end of the WHILE/WEND loop": GoSub AssemOut
Return
DoWEND:
If WhileStackPointer = 0 Then Print "Error: WEND without WHILE on";: GoTo FoundError
num = WHILEStack(WhileStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
A$ = "BRA": B$ = "WhileLoop_" + Num$: C$ = "Goto the start of this WHILE/WEND loop": GoSub AssemOut
Z$ = "Wend_" + Num$: C$ = "End of WHILE/WEND loop": GoSub AssemOut
WhileStackPointer = WhileStackPointer - 1
Return
DoEXIT:
v = Array(x): x = x + 1 ' get the EXIT command/Type
If v <> &HFF Then Print "Don't know what kind of EXIT to do on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2
If v = WHILE_CMD Then
    'Do an EXIT WHILE
    num = WHILEStack(WhileStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "BRA": B$ = "Wend_" + Num$: C$ = "End of WHILE/WEND loop": GoSub AssemOut
    Return
End If
If v = FOR_CMD Then
    'Do an EXIT FOR
    num = FORSTack(FORStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "BRA": B$ = "NEXTDone_" + Num$: C$ = "End of FOR/NEXT loop": GoSub AssemOut
    Return
End If
If v = DO_CMD Then
    'Do an EXIT DO
    num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "BRA": B$ = "DoneLoop_" + Num$: C$ = "End of DO/Loop": GoSub AssemOut
    Return
End If
Print "Don't know what kind of EXIT to do on";: GoTo FoundError
DoDO:
DOCount = DOCount + 1
DOStackPointer = DOStackPointer + 1
DOStack(DOStackPointer) = DOCount
num = DOCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
Z$ = "DOStart_" + Num$: C$ = "Start of WHILE/UNTIL loop": GoSub AssemOut
v = Array(x): x = x + 1
If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then
    ' Just a DO command without WHILE or UNTIL
    v = Array(x): x = x + 1
    Return
End If
If v <> &HFF Then Print "Don't know what to do after the DO command on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2 ' The actual type to DO
If v = WHILE_CMD Then
    'DO WHILE - WHILE checks if the condition is true each time before running code.
    CheckIfTrue$ = ""
    v = 0
    Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' Keep copying until we get EOL or Colon
        v = Array(x): x = x + 1
        If v <> Asc(" ") Then CheckIfTrue$ = CheckIfTrue$ + Chr$(v) 'skip spaces
    Loop
    v = Array(x): x = x + 1
    CheckIfTrue$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HF5 on the end
    GoSub GoCheckIfTrue ' This parses CheckIfTrue$ get's it ready to be evaluated in the string NewString$
    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
    num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "BEQ": B$ = "DoneLoop_" + Num$: C$ = "If the result is false then exit the DO/Loop": GoSub AssemOut
    Return
End If
If v = UNTIL_CMD Then
    'Do a DO UNTIL - UNTIL checks if the condition is false each time before running code.
    CheckIfTrue$ = ""
    v = 0
    Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' Keep copying until we get EOL or Colon
        v = Array(x): x = x + 1
        If v <> Asc(" ") Then CheckIfTrue$ = CheckIfTrue$ + Chr$(v) 'skip spaces
    Loop
    v = Array(x): x = x + 1
    CheckIfTrue$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HF5 on the end
    GoSub GoCheckIfTrue ' This parses CheckIfTrue$ get's it ready to be evaluated in the string NewString$
    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
    num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "BNE": B$ = "DoneLoop_" + Num$: C$ = "If the result is a true exit the DO/Loop": GoSub AssemOut
    Return
End If
Print "Don't know what kind of DO command to do on";: GoTo FoundError
DoUNTIL:
Color 14
Print "Shouldn't ever get here, should have found the UNTIL command when handling DO command, on";: GoTo FoundError
Color 15
System
DoLOOP:
v = Array(x): x = x + 1 ' get the Loop command/Type
If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then
    v = Array(x): x = x + 1
    ' Just a LOOP command without WHILE or UNTIL
    If DOStackPointer = 0 Then Print "Error: LOOP without DO in line"; linelabel$: System
    num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "BRA": B$ = "DOStart_" + Num$: C$ = "Go to the start of the DO loop": GoSub AssemOut
    Z$ = "DoneLoop_" + Num$: C$ = "End of DO Loop": GoSub AssemOut
    DOStackPointer = DOStackPointer - 1
    Return
End If
If v <> &HFF Then Print "Don't know what to do after the LOOP command on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2 ' The actual type to Loop
If v = WHILE_CMD Then
    'LOOP WHILE - WHILE checks if the condition is true before running loop code again.
    If DOStackPointer = 0 Then Print "Error: LOOP without DO in line"; linelabel$: System
    CheckIfTrue$ = ""
    v = 0
    Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' Keep copying until we get EOL or Colon
        v = Array(x): x = x + 1
        If v <> Asc(" ") Then CheckIfTrue$ = CheckIfTrue$ + Chr$(v) 'skip spaces
    Loop
    v = Array(x): x = x + 1
    CheckIfTrue$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HF5 on the end
    GoSub GoCheckIfTrue ' This parses CheckIfTrue$ get's it ready to be evaluated in the string NewString$
    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
    num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "BNE": B$ = "DOStart_" + Num$: C$ = "If the result is a true then goto the start of the DO/Loop again": GoSub AssemOut
    Z$ = "DoneLoop_" + Num$: C$ = "End of DO Loop": GoSub AssemOut
    DOStackPointer = DOStackPointer - 1
    Return
End If
If v = UNTIL_CMD Then
    'Do a DO UNTIL - UNTIL checks if the condition is false before running loop code again.
    If DOStackPointer = 0 Then Print "Error: LOOP without DO in line"; linelabel$: System
    CheckIfTrue$ = ""
    v = 0
    Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' Keep copying until we get EOL or Colon
        v = Array(x): x = x + 1
        If v <> Asc(" ") Then CheckIfTrue$ = CheckIfTrue$ + Chr$(v) 'skip spaces
    Loop
    v = Array(x): x = x + 1
    CheckIfTrue$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HF5 on the end
    GoSub GoCheckIfTrue ' This parses CheckIfTrue$ get's it ready to be evaluated in the string NewString$
    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
    num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "BEQ": B$ = "DOStart_" + Num$: C$ = "If the result is a false then goto the start of the DO/Loop": GoSub AssemOut
    Z$ = "DoneLoop_" + Num$: C$ = "End of DO Loop": GoSub AssemOut
    DOStackPointer = DOStackPointer - 1
    Return
End If
Print "Don't know what kind of DO command to do on";: GoTo FoundError
DoSELECT:
SELECTCount = SELECTCount + 1
SELECTStackPointer = SELECTStackPointer + 1
SELECTSTack(SELECTStackPointer) = SELECTCount
CaseElseFlag = 0
v = Array(x): x = x + 1: If v <> &HFF Then Print "Error, SELECT needs a CASE or EVERYCASE command on";: GoTo FoundError
CaseType = Array(x) * 256 + Array(x + 1): x = x + 2 ' Either CASE or EVERYCASE command
If CaseType <> CASE_CMD And CaseType <> EVERYCASE_CMD Then Print "Error, SELECT needs a CASE or EVERYCASE command on";: GoTo FoundError
If CaseType <> EVERYCASE_CMD Then
    EvCase(SELECTStackPointer) = 0
Else
    'We are doing an Everycase
    EvCase(SELECTStackPointer) = 1
End If
' we found a CASE command, Get the test expression
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
MainCase$(SELECTStackPointer) = Expression$ ' MainCase$ is the value that will be compared in all the CASEs
A$ = "LDD": B$ = "EveryCasePointer": C$ = "Get the Flag pointer in D": GoSub AssemOut
A$ = "ADDD": B$ = "#2": C$ = "D=D+2, move the pointer to the next flag": GoSub AssemOut
A$ = "STD": B$ = "EveryCasePointer": C$ = "Save the new pointer in EveryCasePointer": GoSub AssemOut
num = EvCase(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
A$ = "LDD": B$ = "#" + Num$ + "*$100": C$ = "A = The flag if this is an EveryCase=1 or a CASE=0 and clear B": GoSub AssemOut
A$ = "STD": B$ = "[EveryCasePointer]": C$ = "Save the value pointer in the EveryCaseStack": GoSub AssemOut
Return

DoCASE:
' Noraml CASE
CaseCount(SELECTStackPointer) = CaseCount(SELECTStackPointer) + 1
num = SELECTSTack(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
If CaseCount(SELECTStackPointer) > 1 Then
    If EvCase(SELECTStackPointer) = 0 Then
        ' Not an EVERYCASE
        A$ = "BRA": B$ = "_EndSelect_" + Num$: C$ = "Last Case code is complete so ignore the other CASEs": GoSub AssemOut
    End If
End If
CaseNumber$ = Num$
num = CaseCount(SELECTStackPointer) + 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
NextCaseNumber$ = CaseNumber$ + "_" + Num$
num = CaseCount(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
CaseNumber$ = CaseNumber$ + "_" + Num$
Z$ = "_CaseCheck_" + CaseNumber$: C$ = "Start of the next CASE": GoSub AssemOut

' Check for CASE ELSE
If Array(x) = &HFF And Array(x + 1) * 256 + Array(x + 2) = ELSE_CMD Then
    ' CASE ELSE
    CaseElseFlag = 1
    num = SELECTSTack(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    Z$ = "; CASE ELSE Code for SELECT " + Num$: GoSub AssemOut
    GoSub SkipUntilEOLColon ' Skip until we find an EOL or a Colon and return
    A$ = "LDD": B$ = "[EveryCasePointer]": C$ = "A = flag pointer for everycase": GoSub AssemOut
    '    A$ = "TSTA": C$ = "Get the CASE/EVERYCASE Flag": GoSub AssemOut
    '    A$ = "BNE": B$ = "_EndSelect_" + Num$: C$ = "Skip if this is a CASE (EVERYCASE flag = 1)": GoSub AssemOut
    A$ = "TSTB": C$ = "If we are doing an EVERYCASE, Check if we've done at least one CASE": GoSub AssemOut
    A$ = "BNE": B$ = "_EndSelect_" + Num$: C$ = "If we've done more than zero then Skip to the END SELECT": GoSub AssemOut
Else
    ' Check for IS,    DoIS = &H60
    If Array(x) = &HFF And Array(x + 1) * 256 + Array(x + 2) = IS_CMD Then
        ' Found an IS to deal with
        CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(Array(x + 3)) + Chr$(Array(x + 4)) ' Get the <,=,> after IS
        x = x + 5 ' move forward
        GoSub GetExpressionB4EOL: x = x + 2 ' Get the expression before an End of Line or Colon in Expression$ & move past it
        CheckIfTrue$ = CheckIfTrue$ + Expression$
        GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
        GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
        A$ = "BEQ": B$ = "_CaseCheck_" + NextCaseNumber$: C$ = "If result is zero = False then jump to the next case/ELSE Case or END Select": GoSub AssemOut
        If EvCase(SELECTStackPointer) = 1 Then
            ' We are in an EVERYCASE
            A$ = "LDD": B$ = "#$0101": C$ = "flag that we've done at least one CASE": GoSub AssemOut
            A$ = "STD": B$ = "[EveryCasePointer]": C$ = " = flag pointer for everycase": GoSub AssemOut
        End If
    Else
        ' Check for TO after the CASE
        Start = x ' Start is just after the CASE command
        Found = 0
        v = 0
        Do Until v = &HF5 And Array(x) = &H0D
            v = Array(x): x = x + 1
            If v = &HFF And Array(x) * 256 + Array(x + 1) = TO_CMD Then
                ' Found a TO
                Found = 1
                Exit Do
            End If
        Loop
        If v = &HF5 Then v = Array(x): x = x + 1 ' If found then move past EOL
        If Found = 1 Then
            ' We found a TO to deal with
            ' Temporarily change the space before the "TO" command to a $0D so we can use the HandleNumericVariable routine to setup the FOR X=Y  part
            x = Start ' x = Start which is just after the CASE command
            Do Until (v = &HFF And Array(x) * 256 + Array(x + 1) = TO_CMD) Or (v = &HF5 And Array(x) = &H0D)
                v = Array(x): x = x + 1
            Loop
            If v = &HF5 Then v = Array(x): x = x + 1 ' If found then move past EOL
            If v = &H0D Then Print "Error assigning a value to variable in the CASE command that has a TO on";: GoTo FoundError
            PointAtTO = x - 1 ' Keep the value where the TO is
            FixSpot = x - 1 ' Point at the TO
            Temp1 = Array(FixSpot): Temp2 = Array(FixSpot + 1)
            Array(FixSpot) = &HF5
            Array(FixSpot + 1) = &H0D ' temporarily change the space before the TO command to a $F50D
            x = Start ' x = Start which is just after the CASE command
            GoSub GetExpressionB4EOL: x = x + 3 ' Get the expression before an End of Line in Expression$ & move past fake EOL and a bit of the TO command
            Array(FixSpot) = Temp1: Array(FixSpot + 1) = Temp2 ' Restore the array so it's back as it was
            CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3E) + Chr$(&HFC) + Chr$(&H3D) + Expression$ ' MainCase >= Expression$
            GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
            GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
            A$ = "BEQ": B$ = "_CaseCheck_" + NextCaseNumber$: C$ = "If result is zero = False then jump to the next case/ELSE Case or END Select": GoSub AssemOut
            x = PointAtTO + 3 ' Now point at the value just after the TO command
            GoSub GetExpressionB4EOL: x = x + 2 ' Get the expression before an End of Line or COLON in Expression$  & move past EOL/Colon
            CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3C) + Chr$(&HFC) + Chr$(&H3D) + Expression$ ' MainCase <= Expression$
            GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
            GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
            A$ = "BEQ": B$ = "_CaseCheck_" + NextCaseNumber$: C$ = "If result is zero = False then jump to the next case/ELSE Case or END Select": GoSub AssemOut
            If EvCase(SELECTStackPointer) = 1 Then
                ' We are in an EVERYCASE
                A$ = "LDD": B$ = "#$0101": C$ = "flag that we've done at least one CASE": GoSub AssemOut
                A$ = "STD": B$ = "[EveryCasePointer]": C$ = " = flag pointer for everycase": GoSub AssemOut
            End If
        Else
            x = Start ' x = Start which is just after the CASE command
            ' Check for commas in the expression
            GoSub GetExpressionB4EOL: x = x + 2 ' Get the expression before an End of Line or COLON in Expression$& move past it
            ' Find out if there are any commas
            CaseTemp$ = Expression$
            CommaPos = InStr(CaseTemp$, ",")
            If CommaPos > 0 Then
                'this expression has commas
                While CommaPos > 0
                    CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3D) + Left$(CaseTemp$, CommaPos - 2) 'Maincase$=CaseTemp before the comma
                    CaseTemp$ = Right$(CaseTemp$, Len(CaseTemp$) - CommaPos)
                    CommaPos = InStr(CaseTemp$, ",")
                    GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
                    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
                    A$ = "BNE": B$ = "_DOCase_" + CaseNumber$: C$ = "If result is not zero = True so jump to the code after this case": GoSub AssemOut
                Wend
                CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3D) + CaseTemp$ 'Maincase$=CaseTemp
                GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
                GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
                A$ = "BEQ": B$ = "_CaseCheck_" + NextCaseNumber$: C$ = "If result is zero = False then jump to the next case/ELSE Case or END Select": GoSub AssemOut
                Z$ = "_DOCase_" + CaseNumber$: C$ = "Case match, do the code for this CASE": GoSub AssemOut
                If EvCase(SELECTStackPointer) = 1 Then
                    ' We are in an EVERYCASE
                    A$ = "LDD": B$ = "#$0101": C$ = "flag that we've done at least one CASE": GoSub AssemOut
                    A$ = "STD": B$ = "[EveryCasePointer]": C$ = " = flag pointer for everycase": GoSub AssemOut
                End If
            Else
                ' No commas to deal with
                ' No TO, just a regular CASE to compare with
                CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3D) + CaseTemp$ 'Maincase$=CaseTemp
                GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
                GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
                A$ = "BEQ": B$ = "_CaseCheck_" + NextCaseNumber$: C$ = "If result is zero = False then jump to the next case/ELSE Case or END Select": GoSub AssemOut
                If EvCase(SELECTStackPointer) = 1 Then
                    ' We are in an EVERYCASE
                    A$ = "LDD": B$ = "#$0101": C$ = "flag that we've done at least one CASE": GoSub AssemOut
                    A$ = "STD": B$ = "[EveryCasePointer]": C$ = " = flag pointer for everycase": GoSub AssemOut
                End If
            End If
        End If
    End If
End If
Return
DoEVERYCASE: ' &H5F
Color 14
Print "Handled with CASE, this should never been shown EVERYCASE, found on";: GoTo FoundError
Color 15
System
DoIS: ' &H60
Color 14
Print "Can't do command IS yet, found on";: GoTo FoundError
Color 15
System
DoSGN:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
Else
    ' Get the numeric value before a Close bracket
    v = Array(x): x = x + 1 ' skip the open bracket
    ' Get first number in D
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "CMPD": B$ = "#$0000": C$ = "Test the value of D": GoSub AssemOut
A$ = "BEQ": B$ = ">": C$ = "Exit with D = 0": GoSub AssemOut
A$ = "BGT": B$ = "@Positive": C$ = "D is positive": GoSub AssemOut
A$ = "LDD": B$ = "#-1": C$ = "Otherwise D is negative": GoSub AssemOut
A$ = "BRA": B$ = ">": C$ = "Exit with D = -1": GoSub AssemOut
Z$ = "@Positive": GoSub AssemOut
A$ = "LDD": B$ = "#1": C$ = "D is positive": GoSub AssemOut
Z$ = "!": GoSub AssemOut
Print #1,
Return
DoINT:
' Nothing to do here, except return with D as the value inside the INT()
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
Else
    ' Get the numeric value before a Close bracket
    v = Array(x): x = x + 1 ' skip the open bracket
    ' Get first number in D
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
Return ' Return with D = the value in the INT
DoABS:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
Else
    ' Get the numeric value before a Close bracket
    v = Array(x): x = x + 1 ' skip the open bracket
    ' Get first number in D
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "BPL": B$ = ">": C$ = "If positive simply skip over changing D's value": GoSub AssemOut
A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AssemOut
A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AssemOut
A$ = "SUBD": B$ = ",S++": C$ = "D=0-D, fix the stack": GoSub AssemOut
Z$ = "!": GoSub AssemOut
Return
DoUSR:
Color 14
Print "Can't do command USR yet, found on line "; linelabel$
Color 15
System
DoRND:
' Default fast 8 bit Random number from 1 to B
GoSub ParseExpression0FlagErase ' Recursively check the next value
resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
Print #1, "; "; Num$
A$ = "BEQ": B$ = ">": C$ = "If D is zero, return with zero": GoSub AssemOut
A$ = "JSR": B$ = "Random": C$ = "Convert number in B to a Random number in D": GoSub AssemOut ' - Old 8 bit random number generator
Z$ = "!": GoSub AssemOut
Return
DoRNDZ:
' 8 bit Random number from 0 to B
GoSub ParseExpression0FlagErase ' Recursively check the next value
resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
A$ = "BEQ": B$ = ">": C$ = "If D is zero, return with zero": GoSub AssemOut
A$ = "JSR": B$ = "RandomZ": C$ = "Convert number in B to a Random number in D": GoSub AssemOut
Z$ = "!": GoSub AssemOut
Return
DoRNDL:
' 16 Bit Random Number from 1 to D
GoSub ParseExpression0FlagErase ' Recursively check the next value
resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
A$ = "BEQ": B$ = ">": C$ = "If D is zero, return with zero": GoSub AssemOut
A$ = "JSR": B$ = "RandomD": C$ = "Convert unsigned 16 bit interger range in D and return with Random number in D, D=RND(D), Random number from 1 to D": GoSub AssemOut
Z$ = "!": GoSub AssemOut
Return
DoSIN:
Color 14
Print "Can't do command SIN yet, found on";: GoTo FoundError
Color 15
System

DoPEEK:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
Else
    ' Get the numeric value before a Close bracket
    v = Array(x): x = x + 1 ' skip the open bracket
    ' Get first number in D
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "TFR": B$ = "D,X": C$ = "X=D": GoSub AssemOut ' Save Temp_Var_NumParseCount
A$ = "CLRA": C$ = "A=0": GoSub AssemOut ' Save Temp_Var_NumParseCount
A$ = "LDB": B$ = ",X": C$ = "B = Peek(X)": GoSub AssemOut ' Save Temp_Var_NumParseCount
Return
DoLEN:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Get the string value after the first open bracket
    GoSub ParseStringExpression0 ' Recursively get the next string value
    resultP10$(PE10Count) = Parse00_Term$
    num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    StringPointerTemp$ = "_StrVar_PF" + Num$ 'StringPointerTemp$ = the Temp string pointer to use
    A$ = "CLRA": GoSub AssemOut
    A$ = "LDB": B$ = StringPointerTemp$: C$ = "B = the size of original string": GoSub AssemOut
Else
    Print "String commands should always have an ExpressionCount > 0, doing";: GoTo FoundError
End If
Return
DoVAL:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Get the string value after the first open bracket
    GoSub ParseStringExpression0 ' Recursively get the next string value
    resultP10$(PE10Count) = Parse00_Term$
    num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    StringPointerTemp$ = "_StrVar_PF" + Num$ 'StringPointerTemp$ = the Temp string pointer to use
    A$ = "LDU": B$ = "#" + StringPointerTemp$: C$ = "U points at the start of the source string": GoSub AssemOut
    A$ = "LDB": B$ = ",U+": C$ = "B = the length of source string, move pointer to the start of the string": GoSub AssemOut
    A$ = "BEQ": B$ = "@NotANumber": C$ = "If the string size is zero then result is 0": GoSub AssemOut
    A$ = "LDA": B$ = ",U": C$ = "A = the first byte of source string": GoSub AssemOut
    A$ = "CMPA": B$ = "#'&": C$ = "Check if the number is an &, could be hex that starts with &H": GoSub AssemOut
    A$ = "BEQ": B$ = "@ConvertHex": C$ = "If so check for H and then convert Hex to deciaml": GoSub AssemOut
    A$ = "CMPA": B$ = "#'-": C$ = "Check if the number is a negative": GoSub AssemOut
    A$ = "BNE": B$ = "@NotNegative": C$ = "If poistive we can only have a max of 5 numbers": GoSub AssemOut
    A$ = "CMPB": B$ = "#6": C$ = "Check the number of decimal places": GoSub AssemOut
    A$ = "BHI": B$ = "@NotANumber": C$ = "If more than 7 then we have a problem": GoSub AssemOut
    A$ = "BRA": B$ = ">": C$ = "Skip ahead, we are good to go with a negative number this size": GoSub AssemOut
    Z$ = "@NotNegative": GoSub AssemOut
    A$ = "CMPA": B$ = "#'+": C$ = "Check if the user manually used a plus symbol": GoSub AssemOut
    A$ = "BNE": B$ = "@NotPlus": C$ = "If poistive we can only have a max of 5 numbers": GoSub AssemOut
    A$ = "LDA": B$ = "#' '": C$ = "Make a + into a space, so it will be ignored": GoSub AssemOut
    A$ = "STA": B$ = ",U": C$ = "make first byte of source a space": GoSub AssemOut
    A$ = "CMPB": B$ = "#6": C$ = "Check the number of decimal places": GoSub AssemOut
    A$ = "BHI": B$ = "@NotANumber": C$ = "If more than 6 then we have a problem": GoSub AssemOut
    A$ = "BRA": B$ = ">": C$ = "Skip ahead, we are good to go with a positive number this size": GoSub AssemOut
    Z$ = "@NotPlus": GoSub AssemOut
    A$ = "CMPB": B$ = "#5": C$ = "Check the number of decimal places": GoSub AssemOut
    A$ = "BHI": B$ = "@NotANumber": C$ = "If more than 6 then we have a problem": GoSub AssemOut
    Z$ = "!"
    A$ = "LDX": B$ = "#DecNumber": C$ = "X points at the start of the table of data to grab each time": GoSub AssemOut
    Z$ = "!"
    A$ = "LDA": B$ = ",U+": C$ = "Get the source byte": GoSub AssemOut
    A$ = "CMPA": B$ = "#$20": C$ = "Check for a space": GoSub AssemOut
    A$ = "BEQ": B$ = "@SkipSpace": C$ = "Skip if found": GoSub AssemOut
    A$ = "STA": B$ = ",X+": C$ = "Add it to the the buffer": GoSub AssemOut
    Z$ = "@SkipSpace": GoSub AssemOut
    A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
    A$ = "BNE": B$ = "<": C$ = "": GoSub AssemOut
    A$ = "CLR": B$ = ",X": C$ = "Flag last byte as 0, so we know that we have reached the end of the string": GoSub AssemOut
    A$ = "JSR": B$ = "DecToD": C$ = "Convert the string in the buffer to a number": GoSub AssemOut
    A$ = "BEQ": B$ = "@Done": C$ = "Skip to Done if conversion went well": GoSub AssemOut
    Z$ = "@NotANumber": GoSub AssemOut
    A$ = "LDD": B$ = "#$0000": C$ = "": GoSub AssemOut
    A$ = "BRA": B$ = "@Done": C$ = "Skip past the HEX conversion code": GoSub AssemOut
    Z$ = "@ConvertHex": GoSub AssemOut
    A$ = "LDA": B$ = "1,U": C$ = "A = the first byte of source string": GoSub AssemOut
    A$ = "CMPA": B$ = "#'H": C$ = "Check if the value is is an H, could be hex that starts with &H": GoSub AssemOut
    A$ = "BNE": B$ = "@NotNegative": C$ = "If not &H then return with -1": GoSub AssemOut
    ' Convert the rest of the numbers from hex to decimal
    A$ = "LEAX": B$ = "2,U": C$ = "X = U + 2, X now points just past the &H": GoSub AssemOut
    A$ = "SUBB": B$ = "#2": C$ = "Reduce the length of the string by 2 (skip the &H)": GoSub AssemOut
    A$ = "BNE": B$ = ">": C$ = "Skip ahead if size is more than zero": GoSub AssemOut
    A$ = "LDD": B$ = "#$0000": C$ = "Make D zero": GoSub AssemOut
    A$ = "BRA": B$ = "@Done": C$ = "We are done": GoSub AssemOut
    Z$ = "!"
    A$ = "CMPB": B$ = "#4": C$ = "Check the number of HEX digits": GoSub AssemOut
    A$ = "BHI": B$ = "@NotANumber": C$ = "If more than 4 then we have a problem": GoSub AssemOut
    A$ = "JSR": B$ = "HexStringToD": C$ = "Convert the Hex value @ X - Length B to value in D": GoSub AssemOut
    Print #1, "@Done": Print #1,
Else
    Print "String commands should always have an ExpressionCount > 0, doing";: GoTo FoundError
End If
Return
DoASC:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Get the string value after the first open bracket
    GoSub ParseStringExpression0 ' Recursively get the next string value
    resultP10$(PE10Count) = Parse00_Term$
    num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    StringPointerTemp$ = "_StrVar_PF" + Num$ 'StringPointerTemp$ = the Temp string pointer to use
    A$ = "LDB": B$ = StringPointerTemp$: C$ = "B = the size of original string": GoSub AssemOut
    A$ = "BEQ": B$ = ">": C$ = "If the Length is zero then return a value of zero": GoSub AssemOut
    A$ = "LDB": B$ = StringPointerTemp$ + "+1": C$ = "B = the value of the first byte of the string": GoSub AssemOut
    Z$ = "!"
    A$ = "CLRA": GoSub AssemOut
Else
    Print "String commands should always have an ExpressionCount > 0, doing";: GoTo FoundError
End If
Return
DoEOF:
Color 14
Print "Can't do command EOF yet, found on line "; linelabel$
Color 15
System
' Analog joystik reading similar to Color BASIC
DoJOYSTK:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
Else
    ' Get the numeric value before a Close bracket
    v = Array(x): x = x + 1 ' skip the open bracket
    ' Get first number in D
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "CMPD": B$ = "#0": C$ = "Check if the value with zero": GoSub AssemOut
A$ = "BGE": B$ = ">": C$ = "Check if the value is >= to 0": GoSub AssemOut
A$ = "CLRB": C$ = "Make B = 0": GoSub AssemOut
A$ = "BRA": B$ = "@JoyNumGood": C$ = "We have a good value for joystick number, skip ahead": GoSub AssemOut
Z$ = "!"
A$ = "CMPD": B$ = "#3": C$ = "Check if the value is higher than 3": GoSub AssemOut
A$ = "BLE": B$ = "@JoyNumGood": C$ = "If the number is <= 3 skip ahead": GoSub AssemOut
A$ = "LDB": B$ = "#3": C$ = "Make B = 3": GoSub AssemOut
Z$ = "@JoyNumGood": GoSub AssemOut
A$ = "JSR": B$ = "JOYSTK": C$ = "Go handle analog joystick reading return with result in D": GoSub AssemOut
Print #1,
Return
DoPOINT:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    ' Get the x co-ordinate
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
    A$ = "TSTA": B$ = "#$0000": C$ = "Check if D is a negative": GoSub AssemOut
    A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 63": GoSub AssemOut
    A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
    Z$ = "!"
    A$ = "CMPB": B$ = "#63": C$ = "Check if B is > than 63": GoSub AssemOut
    A$ = "BLE": B$ = ">": C$ = "If value is 63 or < then skip ahead": GoSub AssemOut
    A$ = "LDB": B$ = "#63": C$ = "Make the max size 63": GoSub AssemOut
    Z$ = "!"
    A$ = "PSHS": B$ = "B": C$ = "Save the horizontal value on the stack": GoSub AssemOut
    ' test for Comma
    If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) <> Chr$(&HF5) + "," Then Print "Point command can't find a comma in";: GoTo FoundError
    index(ExpressionCount) = index(ExpressionCount) + 2 'skip passed the comma
    ' Get the y co-ordinate
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
    A$ = "TSTA": B$ = "#$0000": C$ = "Check if D is a negative": GoSub AssemOut
    A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 31": GoSub AssemOut
    A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
    Z$ = "!"
    A$ = "CMPB": B$ = "#31": C$ = "Check if B is > than 31": GoSub AssemOut
    A$ = "BLE": B$ = ">": C$ = "If value is 31 or < then skip ahead": GoSub AssemOut
    A$ = "LDB": B$ = "#31": C$ = "Make the max size 31": GoSub AssemOut
    Z$ = "!"
    A$ = "JSR": B$ = "GetSRPLocation": C$ = "Get the SET,RESET or POINT screen location in X, Enter with ,S = HOR COORD (0 to 63), B = VERT COORD (0 to 31)": GoSub AssemOut
    A$ = "JSR": B$ = "DoPoint": C$ = "Get the Point on screen in D": GoSub AssemOut
Else
    Print "Point should be in an expression ";: GoTo FoundError
End If
Return
DoMEM:
Color 14
Print "Can't do command MEM yet, found on line "; linelabel$
Color 15
System
DoATN:
Color 14
Print "Can't do command ATN yet, found on line "; linelabel$
Color 15
System
DoCOS:
Color 14
Print "Can't do command COS yet, found on line "; linelabel$
Color 15
System
DoTAN:
Color 14
Print "Can't do command TAN yet, found on line "; linelabel$
Color 15
System
DoEXP:
Color 14
Print "Can't do command EXP yet, found on line "; linelabel$
Color 15
System
DoFIX:
Color 14
Print "Can't do command FIX yet, found on line "; linelabel$
Color 15
System
DoLOG:
Color 14
Print "Can't do command LOG yet, found on line "; linelabel$
Color 15
System
DoPOS:
Color 14
Print "Can't do command POS yet, found on line "; linelabel$
Color 15
System
DoSQR:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
Else
    ' Get the numeric value before a Close bracket
    v = Array(x): x = x + 1 ' skip the open bracket
    ' Get first number in D
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "JSR": B$ = "SqRoot16": C$ = "Get the square root of D, return with result in D": GoSub AssemOut
Return
DoVARPTR:
Color 14
Print "Can't do command VARPTR yet, found on line "; linelabel$
Color 15
System
' position% = INSTR([start%,] baseString$, searchString$)
DoINSTR:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    Start = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1))
    If Start = &HF0 Or Start = &HF2 Or Start = &HFE Or (Start >= Asc("0") And Start <= Asc("9")) Or Start = Asc("&") Then ' Is it a Numeric Array,Numeric Variable, Numeric command,a number or Hex
        ' First entry is a numberic
        GoSub ParseExpression0FlagErase ' Recursively check the next numeric value
        resultP30(PE30Count) = Parse00_Term ' this will return with the next value
        ' D now has the Starting point to search in the string
        ' to match QB64, If D <1 then D= 1
        A$ = "CMPD": B$ = "#$0001": C$ = "Compare D with 1": GoSub AssemOut
        A$ = "BGE": B$ = ">": C$ = "IF greater than or = to 1 then use D as is": GoSub AssemOut
        index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume the comma
    End If
    'not a number, so we start searching from position 1
    A$ = "LDD": B$ = "#$0001": C$ = "Force D to be 1": GoSub AssemOut
    Z$ = "!": GoSub AssemOut
    A$ = "PSHS": B$ = "D": C$ = "Save the Start location to test at on the stack": GoSub AssemOut
    GoSub ParseStringExpression0 ' Recursively get the next string value
    resultP10$(PE10Count) = Parse00_Term$
    num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    StringPointerTemp$ = "_StrVar_PF" + Num$ 'StringPointerTemp$ = the Temp string pointer to use
    ' Copy _StrVar_PF+ Num$ to _StrVar_PF09, this is what we will use to search through
    A$ = "LDU": B$ = "#" + StringPointerTemp$: C$ = "U points at the start of the source string": GoSub AssemOut
    A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AssemOut
    A$ = "LDX": B$ = "#_StrVar_IFRight": C$ = "X points at the length of the destination string, Use _StrVar_IFRight as a Temp to compare against": GoSub AssemOut
    A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AssemOut
    A$ = "BEQ": B$ = "Done@": C$ = "If B=0 then no need to copy the string": GoSub AssemOut
    Z$ = "!"
    A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
    A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AssemOut
    A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
    A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
    Z$ = "Done@": GoSub AssemOut
    Print #1,
    ' Get the string to search through in "_StrVar_PF" + Num$
    index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume the comma
    GoSub ParseStringExpression0 ' Recursively get the next string value
    resultP10$(PE10Count) = Parse00_Term$
    num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    StringPointerTemp$ = "_StrVar_PF" + Num$ 'StringPointerTemp$ = the Temp string pointer to use
    'Search for "_StrVar_PF" + Num$ in   _StrVar_IFRight
    A$ = "LDX": B$ = "#_StrVar_IFRight": C$ = "X points at the length of the base string": GoSub AssemOut
    A$ = "LDB": B$ = ",X": C$ = "Get the size of the base string, X now points at the beginning of the base string": GoSub AssemOut
    A$ = "CLRA": C$ = "Clear A so D is the correct length to compare with": GoSub AssemOut
    A$ = "CMPD": B$ = ",S": C$ = "Compare the length of the base string with the starting point to test at": GoSub AssemOut
    A$ = "BLT": B$ = "ReturnZero@": C$ = "If D is < than the start length then we are done return with a value of zero": GoSub AssemOut

    A$ = "ADDB": B$ = StringPointerTemp$: C$ = "B=Length of the base string + the length of the search string": GoSub AssemOut
    A$ = "ADCA": B$ = "#$00": C$ = "Add the carry bit to A so D is the correct value": GoSub AssemOut
    A$ = "SUBD": B$ = ",S": C$ = "Compare the length of the base string + the length of the search string with the starting point to test at": GoSub AssemOut
    A$ = "BLT": B$ = "ReturnZero@": C$ = "If D is < than the start length + the length of the search string then we are done return with a value of zero": GoSub AssemOut
    A$ = "STB": B$ = ",S": C$ = "Save the # of bytes to compare on the stack": GoSub AssemOut
    ' Try and find search string in base string starting at the position in the stack
    A$ = "LDB": B$ = "1,S": C$ = "Get the start address in B": GoSub AssemOut
    A$ = "ABX": C$ = "Move X to the correct location to start searching in the base string": GoSub AssemOut
    Z$ = "BigLoop@": GoSub AssemOut
    A$ = "LEAY": B$ = "1,X": C$ = "Y = the next starting point to test at": GoSub AssemOut
    A$ = "LDU": B$ = "#" + StringPointerTemp$: C$ = "U points at the start of the search string": GoSub AssemOut
    A$ = "LDB": B$ = ",U+": C$ = "Get the length of the search string and move U to point to the start of the search string": GoSub AssemOut
    A$ = "INCB": C$ = "B=B+1, because we pre decrement the testloop below": GoSub AssemOut
    Z$ = "!"
    A$ = "DECB": C$ = "B=B-1": GoSub AssemOut
    A$ = "BEQ": B$ = "FoundMatch@": C$ = "If we get to zero then we found the value all test the same": GoSub AssemOut
    A$ = "LDA": B$ = ",U+": C$ = "Get byte to search": GoSub AssemOut
    A$ = "CMPA": B$ = ",X+": C$ = "Is it the same in the Base string here?": GoSub AssemOut
    A$ = "BEQ": B$ = "<": C$ = "Get byte to search": GoSub AssemOut
    A$ = "LEAX": B$ = ",Y": C$ = "X = the next starting point to test at": GoSub AssemOut
    A$ = "DEC": B$ = ",S": C$ = "decrement the counter": GoSub AssemOut
    A$ = "BNE": B$ = "BigLoop@": C$ = "Go try testing some more": GoSub AssemOut
    Z$ = "; If we get here the search string failed"
    Z$ = "ReturnZero@": GoSub AssemOut
    A$ = "LDD": B$ = "#$0000": C$ = "D is zero, = no match": GoSub AssemOut
    A$ = "BRA": B$ = ">": C$ = "Skip ahead": GoSub AssemOut
    Z$ = "FoundMatch@": GoSub AssemOut
    A$ = "LEAX": B$ = "-" + "_StrVar_IFRight" + ",X": C$ = "X = the position": GoSub AssemOut
    A$ = "TFR": B$ = "X,D": C$ = "D = X = starting position": GoSub AssemOut
    A$ = "SUBB": B$ = StringPointerTemp$: C$ = "B=X-Length of the base string": GoSub AssemOut
    Z$ = "!": GoSub AssemOut
    A$ = "LEAS": B$ = "2,S": C$ = "Fix the stack, D has the correct value": GoSub AssemOut
End If
Return
DoTIMER: ' &H62
v = Array(x): x = x + 2 ' Get the command byte in v, consume the &HFC3D "="
If v <> &HFC Or Array(x - 1) <> &H3D Then Print "Error, TIMER needs an Equal sign after it on";: GoTo FoundError
' Get the numeric value after the equal sign
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
A$ = "STD": B$ = "_Var_Timer": C$ = "Store D as the new Timer Value": GoSub AssemOut
Return
DoPPOINT:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    ' Get the x co-ordinate
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
    A$ = "CMPD": B$ = "#$0000": C$ = "Check if D is a negative": GoSub AssemOut
    A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 255": GoSub AssemOut
    A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
    Z$ = "!"
    A$ = "CMPD": B$ = "#255": C$ = "Check if D is > than 255": GoSub AssemOut
    A$ = "BLE": B$ = ">": C$ = "If value is 255 or < then skip ahead": GoSub AssemOut
    A$ = "LDB": B$ = "#255": C$ = "Make the max size 255": GoSub AssemOut
    Z$ = "!"
    A$ = "PSHS": B$ = "B": C$ = "Save the horizontal value on the stack": GoSub AssemOut
    ' test for Comma
    If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) <> Chr$(&HF5) + "," Then Print "PPOINT command can't find a comma in";: GoTo FoundError
    index(ExpressionCount) = index(ExpressionCount) + 2 'skip passed the comma
    ' Get the y co-ordinate
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
    A$ = "CMPD": B$ = "#$0000": C$ = "Check if D is a negative": GoSub AssemOut
    A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > 191": GoSub AssemOut
    A$ = "CLRB": C$ = "Make value zero": GoSub AssemOut
    Z$ = "!"
    A$ = "CMPD": B$ = "#191": C$ = "Check if B is > than 191": GoSub AssemOut
    A$ = "BLE": B$ = ">": C$ = "If value is 31 or < then skip ahead": GoSub AssemOut
    A$ = "LDB": B$ = "#191": C$ = "Make the max size 191": GoSub AssemOut
    Z$ = "!"
    A$ = "TFR": B$ = "B,A": C$ = "A = y co-ordinate": GoSub AssemOut
    A$ = "PULS": B$ = "B": C$ = "Get the x co-ordinate": GoSub AssemOut
    A$ = "JSR": B$ = "PPOINT4": C$ = "Return with the colour value of the PPoint on screen in B": GoSub AssemOut
    A$ = "CLRA": C$ = "D now = B's value": GoSub AssemOut
Else
    Print "PPOINT should be in an expression ";: GoTo FoundError
End If
Return
DoCVN:
Color 14
Print "Can't do command CVN yet, found on line "; linelabel$
Color 15
System
DoFREE:
Color 14
Print "Can't do command FREE yet, found on line "; linelabel$
Color 15
System
DoLOC:
Color 14
Print "Can't do command LOC yet, found on line "; linelabel$
Color 15
System
DoLOF:
Color 14
Print "Can't do command LOF yet, found on line "; linelabel$
Color 15
System
DoWPEEK:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    GoSub ParseExpression0FlagErase ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
Else
    ' Get the numeric value before a Close bracket
    v = Array(x): x = x + 1 ' skip the open bracket
    ' Get first number in D
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "TFR": B$ = "D,X": C$ = "X=D": GoSub AssemOut ' Save Temp_Var_NumParseCount
A$ = "LDD": B$ = ",X": C$ = "D = WPeek(X)": GoSub AssemOut ' Save Temp_Var_NumParseCount
Return
' String commands
DoDSKI:
Color 14
Print "Can't do command DSKI yet, found on line "; linelabel$
Color 15
System
DoDSKO:
Color 14
Print "Can't do command DSKO yet, found on line "; linelabel$
Color 15
System
DoSTR:
GoSub ParseExpression0FlagErase ' Recursively check the next value
' At this point D has the value to be converted to a string
num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the string we want to save our converted value of D in _StrVar_PF" + Num$: GoSub AssemOut
A$ = "JSR": B$ = "D_to_String_at_X": C$ = "Convert value in D to a string where X points": GoSub AssemOut
Return
Color 14
Print "Can't do command STR yet, found on line "; linelabel$
Color 15
System
DoCHR:
GoSub ParseExpression0FlagErase ' Recursively check the next value
num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
'a$ = "LDB": B$ = "_Var_PF" + Num$ + "+1": c$ = "B = value to change to a string": GoSub AssemOut ' Save Temp_Var_NumParseCount
Print #1, "; B will have the value to change to a string"
A$ = "LDA": B$ = "#$01": C$ = "Length of the CHR$ string is one byte": GoSub AssemOut
num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
A$ = "STD": B$ = "_StrVar_PF" + Num$: C$ = "Save Length of the CHR$ string as one byte and that byte in B in _StrVar_PF" + Num$: GoSub AssemOut
Return
DoLEFT:
' Get the string value after the first open bracket
GoSub ParseStringExpression0 ' Recursively get the next string value
num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
StringPointerTemp$ = "_StrVar_PF" + Num$ 'StringPointerTemp$ = the Temp string pointer to use
' Get the numeric value after the comma
index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume the $F5 & comma
GoSub ParseExpression0FlagErase ' Recursively check the next numeric value
' D now has the Length in the LEFT$ command
A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If the Length is > zero then skip ahead": GoSub AssemOut
A$ = "CLRB": C$ = "Make the size of the string zero (NULL)": GoSub AssemOut
A$ = "BRA": B$ = "@StoreB": C$ = "Update the size of the string as zero and exit": GoSub AssemOut
Z$ = "!"
A$ = "CLRA": GoSub AssemOut
A$ = "LDB": B$ = StringPointerTemp$: C$ = "B = the size of original string": GoSub AssemOut
A$ = "CMPD": B$ = ",S": C$ = "Compare the original size with the new size": GoSub AssemOut
A$ = "BLS": B$ = "@Done": C$ = "if the origianl size is <= the new size then leave as is, goto @Done": GoSub AssemOut
A$ = "LDD": B$ = ",S": C$ = "Get The new size in d (really B)": GoSub AssemOut
Z$ = "@StoreB"
A$ = "STB": B$ = StringPointerTemp$: C$ = "Update the new size as B": GoSub AssemOut
Z$ = "@Done"
A$ = "PULS": B$ = "D": C$ = "Fix the Stack": GoSub AssemOut
Print #1, "!"
Print #1, ""
Return
DoRIGHT:
' Get the string value after the first open bracket
GoSub ParseStringExpression0 ' Recursively get the next string value
num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
StringPointerTemp$ = "_StrVar_PF" + Num$ 'StringPointerTemp$ = the Temp string pointer to use
' Get the numeric value after the comma
index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume the $F5 & comma
GoSub ParseExpression0FlagErase ' Recursively check the next numeric value
' D now has the Length in the RIGHT$ command
A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AssemOut
A$ = "BPL": B$ = ">": C$ = "If the Length is > zero then skip ahead": GoSub AssemOut
A$ = "CLRB": C$ = "Make the size of the string zero (NULL)": GoSub AssemOut
A$ = "BRA": B$ = "@StoreB": C$ = "Update the size of the string as zero and exit": GoSub AssemOut
Z$ = "!"
A$ = "CLRA": C$ = "Clear A so we can use D as B (make sure 16 bit numbers are handled correctly)": GoSub AssemOut
A$ = "LDB": B$ = StringPointerTemp$: C$ = "B = the size of original string": GoSub AssemOut
A$ = "SUBD": B$ = ",S": C$ = "Compare the original size with the new size and D = the starting location to copy from": GoSub AssemOut
A$ = "BLS": B$ = "@Done": C$ = "if the original size is <= the new size then leave as is, goto @Done": GoSub AssemOut
A$ = "LDX": B$ = "#" + StringPointerTemp$ + "+1": C$ = "X= Start of the string": GoSub AssemOut
A$ = "ABX": C$ = "Move X to location to start copying from": GoSub AssemOut
A$ = "LDD": B$ = ",S": C$ = "Get The new size in d (really B)": GoSub AssemOut
A$ = "LDU": B$ = "#" + StringPointerTemp$: C$ = "U= Start of the string": GoSub AssemOut
A$ = "STB": B$ = ",U+": C$ = "Save the new length of the string and move the U pointer forward": GoSub AssemOut
Z$ = "!"
A$ = "LDA": B$ = ",X+": C$ = "Read A": GoSub AssemOut
A$ = "STA": B$ = ",U+": C$ = "Save A": GoSub AssemOut
A$ = "DECB": C$ = "Decrement the length to copy counter": GoSub AssemOut
A$ = "BNE": B$ = "<": C$ = "Keep copying, until we've reached zero": GoSub AssemOut
A$ = "BRA": B$ = "@Done": C$ = "All done, fix the stack and exit": GoSub AssemOut
Z$ = "@StoreB"
A$ = "STB": B$ = StringPointerTemp$: C$ = "Update the new size as B": GoSub AssemOut
Z$ = "@Done"
A$ = "PULS": B$ = "D": C$ = "Fix the Stack": GoSub AssemOut
Print #1, "!"
Print #1,
Return
DoMID:
' Get the string value after the first open bracket
GoSub ParseStringExpression0 ' Recursively get the next string value
num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
StringPointerTemp$ = "_StrVar_PF" + Num$ 'StringPointerTemp$ = the Temp string pointer to use

' Get the numeric value after the comma
index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume the $F5 & comma
GoSub ParseExpression0FlagErase ' Recursively check the next numeric value
' D now has the Starting point in the MID$ command

A$ = "PSHS": B$ = "D": C$ = "Save the starting location on the stack": GoSub AssemOut
A$ = "BLE": B$ = "@NullString1": C$ = "If the Starting point is zero or a negative then return with NULL string": GoSub AssemOut
A$ = "LDX": B$ = "#" + StringPointerTemp$: C$ = "X is now pointing at the size of this string": GoSub AssemOut
A$ = "CMPB": B$ = ",X": C$ = "compare B with the length of _StrVar_PF00": GoSub AssemOut
A$ = "BHI": B$ = "@NullString1": C$ = "If the start location is higher than the size of the string, then return with NULL string": GoSub AssemOut
A$ = "ABX": C$ = "Move the pointer to the starting location in the string": GoSub AssemOut

' Get the numeric value after the comma
index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume the $F5 & comma
GoSub ParseExpression0FlagErase ' Recursively check the next numeric value
resultP30(PE30Count) = Parse00_Term ' this will return with the next value
' D now has the Length value in the MID$ command

A$ = "PSHS": B$ = "D": C$ = "Save the length on the stack": GoSub AssemOut
A$ = "BEQ": B$ = "@NullString0": C$ = "If the length is zero then return with a NULL string": GoSub AssemOut
A$ = "ADDD": B$ = "2,S": C$ = "D = Length + starting location": GoSub AssemOut
A$ = "BMI": B$ = "@NullString0": C$ = "If the result is a negative number then return with a NULL string": GoSub AssemOut
A$ = "CMPD": B$ = "#255": C$ = "Is D > 255?": GoSub AssemOut
A$ = "BHI": B$ = "@NullString0": C$ = "If so fix the stack and return with a NULL string": GoSub AssemOut
' B has the length + starting location value
A$ = "CMPB": B$ = StringPointerTemp$: C$ = "compare B with the size of the original string": GoSub AssemOut
A$ = "BLS": B$ = "@GetLengthB": C$ = "If lower then the end of the string then we can use the requested length": GoSub AssemOut
A$ = "LDB": B$ = StringPointerTemp$: C$ = "B = size of the string": GoSub AssemOut
A$ = "SUBB": B$ = "3,S": C$ = "B = size of the string - starting location": GoSub AssemOut
A$ = "INCB": C$ = "B=B+1, so it copies the correct length": GoSub AssemOut
A$ = "BRA": B$ = ">": C$ = "Skip ahead": GoSub AssemOut
Z$ = "@GetLengthB": GoSub AssemOut
A$ = "LDB": B$ = "1,S": C$ = "B = the length the uesr wants to copy": GoSub AssemOut
Z$ = "!"
A$ = "LDU": B$ = "#" + StringPointerTemp$: C$ = "U is now pointing at the size of this string": GoSub AssemOut
A$ = "STB": B$ = ",U+": C$ = "Save the new size of the string, move the pointer": GoSub AssemOut
Z$ = "!"
A$ = "LDA": B$ = ",X+": C$ = "Read A": GoSub AssemOut
A$ = "STA": B$ = ",U+": C$ = "Save A": GoSub AssemOut
A$ = "DECB": C$ = "Decrement the length to copy counter": GoSub AssemOut
A$ = "BNE": B$ = "<": C$ = "Keep copying, until we've reached zero": GoSub AssemOut
A$ = "LEAS": B$ = "4,S": C$ = "Fix the stack": GoSub AssemOut
A$ = "BRA": B$ = ">": C$ = "Skip ahead, we are done": GoSub AssemOut
Z$ = "@NullString0": GoSub AssemOut
A$ = "PULS": B$ = "D": C$ = "Fix the Stack": GoSub AssemOut
Z$ = "@NullString1": GoSub AssemOut
A$ = "PULS": B$ = "D": C$ = "Fix the Stack": GoSub AssemOut
A$ = "CLR": B$ = StringPointerTemp$: C$ = "Make the size of the string zero (NULL)": GoSub AssemOut
Print #1, "!"
Print #1,
Return
DoINKEY:
num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
StringPointerTemp$ = "_StrVar_PF" + Num$ 'StringPointerTemp$ = the Temp string pointer to use
A$ = "LDX": B$ = "#" + StringPointerTemp$: C$ = "X is now pointing at the size of this string": GoSub AssemOut
A$ = "JSR": B$ = "KEYIN": C$ = "This routine Polls the keyboard to see if a key is pressed, returns with value in A, A=0 if no key is pressed": GoSub AssemOut
A$ = "BEQ": B$ = ">": C$ = "Write zero for the size of the string if A is zero": GoSub AssemOut
A$ = "LDB": B$ = "#1": C$ = "We have a keypress so set the string length to 1": GoSub AssemOut
A$ = "STB": B$ = ",X+": C$ = "Save 1 for the size and move X forward to point at data": GoSub AssemOut
Z$ = "!"
A$ = "STA": B$ = ",X": C$ = "Save A at X": GoSub AssemOut
' Since INKEY$ is a string command without brackets we need
' to fix  Expression$(ExpressionCount) so when we return everything flows as normal
Expression$(ExpressionCount) = Left$(Expression$(ExpressionCount), 3) + Chr$(&HF5) + "(" + Chr$(&HF5) + ")" + "    "
' index(ExpressionCount) is fine with a value of 4
Return
DoHEX:
If ExpressionCount > 0 Then ' Check if we are in the middle of an expression
    ' Yes we are in an existing expression
    GoSub ParseExpression0FlagErase ' Recursively check the next numeric value  and return it in D
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value
    num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "Save Length of the CHR$ string as one byte and that byte in B in _StrVar_PF" + Num$: GoSub AssemOut
    A$ = "CLR": B$ = ",X": C$ = "Must clear first byte at X": GoSub AssemOut
    A$ = "JSR": B$ = "DHex_to_String_at_X": C$ = "Convert D to a hex value in RAM where X is pointing": GoSub AssemOut
Else
    Print "String commands should always have an ExpressionCount > 0, doing";: GoTo FoundError
End If
Return
DoSTRING:
GoSub ParseExpression0FlagErase ' Recursively get the next numeric value in D
' D now has the number of times to repeat the string
A$ = "PSHS": B$ = "D": C$ = "Save the # of times to repeat the string on the stack": GoSub AssemOut
index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume the &HFA & comma
' Get the string value after the first open bracket
GoSub ParseStringExpression0 ' Recursively get the next string value
num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If num < 10 Then Num$ = "0" + Num$
StringPointerTemp$ = "_StrVar_PF" + Num$ 'StringPointerTemp$ = the Temp string pointer to use
A$ = "LDX": B$ = "#" + StringPointerTemp$ + "+1": C$ = "X is now pointing at the start of this string": GoSub AssemOut
A$ = "LDD": B$ = ",S": C$ = "Get the count # of times to repeat the string on the stack": GoSub AssemOut
A$ = "BLE": B$ = "@NullString1": C$ = "If the number of copies is zero or a negative then return with NULL string": GoSub AssemOut
A$ = "CMPD": B$ = "#1": C$ = "If D = 1 then exit with the string the way it is": GoSub AssemOut
A$ = "BEQ": B$ = "@Done": C$ = "Exit as it is": GoSub AssemOut
A$ = "DEC": B$ = "1,S": C$ = "Decrement the counter": GoSub AssemOut
A$ = "LDB": B$ = "-1,X": C$ = "Get the length of _StrVar_PF00": GoSub AssemOut
A$ = "ABX": C$ = "Move X to the destination location": GoSub AssemOut
Z$ = "@LoopStart": GoSub AssemOut
A$ = "LDU": B$ = "#" + StringPointerTemp$ + "+1": C$ = "X is now pointing at the start of this string": GoSub AssemOut
A$ = "LDB": B$ = "-1,U": C$ = "B = the length of the string": GoSub AssemOut
Z$ = "!"
A$ = "LDA": B$ = ",U+": C$ = "Get a byte": GoSub AssemOut
A$ = "STA": B$ = ",X+": C$ = "Store a copy": GoSub AssemOut
A$ = "CMPX": B$ = "#" + StringPointerTemp$ + "+256": C$ = "Make sure we don't make the sring longer then 255 bytes": GoSub AssemOut
A$ = "BEQ": B$ = "@CopiedAll": C$ = "Break out of the loop, we've copied all we can": GoSub AssemOut
A$ = "DECB": C$ = "Decrement the length": GoSub AssemOut
A$ = "BNE": B$ = "<": C$ = "Loop until we've copied it all": GoSub AssemOut
A$ = "DEC": B$ = "1,S": C$ = "Decrement the counter": GoSub AssemOut
A$ = "BNE": B$ = "@LoopStart": GoSub AssemOut
Z$ = "@CopiedAll": GoSub AssemOut
A$ = "TFR": B$ = "X,D": C$ = "Copy U to D": GoSub AssemOut
A$ = "SUBD": B$ = "#" + StringPointerTemp$ + "+1": C$ = "D=D-starting address": GoSub AssemOut
A$ = "STB": B$ = StringPointerTemp$: C$ = "Save the new string length": GoSub AssemOut
A$ = "BRA": B$ = "@Done": C$ = "Skip ahead": GoSub AssemOut
Z$ = "@NullString1": GoSub AssemOut
A$ = "CLR": B$ = StringPointerTemp$: C$ = "Make the size of the string zero (NULL)": GoSub AssemOut
Z$ = "@Done"
A$ = "PULS": B$ = "D": C$ = "Fix the Stack": GoSub AssemOut
Print #1,
Return
DoMKN:
Color 14
Print "Can't do command MKN yet, found on";: GoTo FoundError
Color 15
System

' Jump to the general command pointed at by v
JumpToGeneralCommand:
Select Case GeneralCommands$(v)
    Case "AUDIO"
        GoTo DoAUDIO
    Case "BACKUP"
        GoTo DoBACKUP
    Case "CASE"
        GoTo DoCASE
    Case "CIRCLE"
        GoTo DoCIRCLE
    Case "CLEAR"
        GoTo DoCLEAR
    Case "CLOAD"
        GoTo DoCLOAD
    Case "CLOSE"
        GoTo DoCLOSE
    Case "CLS"
        GoTo DoCLS
    Case "COLOR"
        GoTo DoCOLOR
    Case "CONT"
        GoTo DoCONT
    Case "COPY"
        GoTo DoCOPY
    Case "CSAVE"
        GoTo DoCSAVE
    Case "DATA"
        GoTo DoDATA
    Case "DEF"
        GoTo DoDEF
    Case "DEL"
        GoTo DoDEL
    Case "DIM"
        GoTo DoDim
    Case "DIR"
        GoTo DoDIR
    Case "DSKINI"
        GoTo DoDSKINI
    Case "DO"
        GoTo DoDO
    Case "DLOAD"
        GoTo DoDLOAD
    Case "DRAW"
        GoTo DoDRAW
    Case "DRIVE"
        GoTo DoDRIVE
    Case "EDIT"
        GoTo DoEDIT
    Case "ELSE"
        GoTo DoELSE
    Case "ELSEIF"
        GoTo DoELSEIF
    Case "END"
        GoTo DoEND
    Case "EVERYCASE"
        GoTo DoEVERYCASE
    Case "EXEC"
        GoTo DoEXEC
    Case "EXIT"
        GoTo DoEXIT
    Case "FIELD"
        GoTo DoFIELD
    Case "FILES"
        GoTo DoFILES
    Case "FOR"
        GoTo DoFOR
    Case "GET"
        GoTo DoGET
    Case "GETJOYD"
        GoTo DoGETJOYD
    Case "GOSUB"
        GoTo DoGOSUB
    Case "GOTO"
        GoTo DoGOTO
    Case "IF"
        GoTo DoIF
    Case "INPUT"
        GoTo DoINPUT
    Case "IS"
        GoTo DoIS
    Case "KILL"
        GoTo DoKILL
    Case "LET"
        GoTo DoLET
    Case "LINE"
        GoTo DoLINE
    Case "LIST"
        GoTo DoLIST
    Case "LOAD"
        GoTo DoLOAD
    Case "LOCATE"
        GoTo DoLOCATE
    Case "LOOP"
        GoTo DoLOOP
    Case "LSET"
        GoTo DoLSET
    Case "MERGE"
        GoTo DoMERGE
    Case "MOTOR"
        GoTo DoMOTOR
    Case "NEW"
        GoTo DoNEW
    Case "NEXT"
        GoTo DoNEXT
    Case "OFF"
        GoTo DoOFF
    Case "ON"
        GoTo DoON
    Case "OPEN"
        GoTo DoOPEN
    Case "PAINT"
        GoTo DoPAINT
    Case "PCLS"
        GoTo DoPCLS
    Case "PCLEAR"
        GoTo DoPCLEAR
    Case "PCOPY"
        GoTo DoPCOPY
    Case "PLAY"
        GoTo DoPLAY
    Case "SDCPLAY"
        GoTo DoSDCPLAY
    Case "SDCPLAYORCL"
        GoTo DoSDCPLAYORCL
    Case "SDCPLAYORCR"
        GoTo DoSDCPLAYORCR
    Case "SDCPLAYORCS"
        GoTo DoSDCPLAYORCS
    Case "PMODE"
        GoTo DoPMODE
    Case "POKE"
        GoTo DoPOKE
    Case "PRESET"
        GoTo DoPRESET
    Case "PRINT"
        GoTo DoPRINT
    Case "PSET"
        GoTo DoPSET
    Case "PUT"
        GoTo DoPUT
    Case "READ"
        GoTo DoREAD
    Case "RENAME"
        GoTo DoRENAME
    Case "RENUM"
        GoTo DoRENUM
    Case "RESTORE"
        GoTo DoRESTORE
    Case "RETURN"
        GoTo DoRETURN
    Case "REM"
        GoTo DoREM
    Case "REMApostrophe"
        GoTo DoREMApostrophe
    Case "RESET"
        GoTo DoRESET
    Case "RSET"
        GoTo DoRSET
    Case "RUN"
        GoTo DoRUN
    Case "SAVE"
        GoTo DoSAVE
    Case "SCREEN"
        GoTo DoSCREEN
    Case "SELECT"
        GoTo DoSELECT
    Case "SET"
        GoTo DoSET
    Case "SKIPF"
        GoTo DoSKIPF
    Case "SOUND"
        GoTo DoSOUND
    Case "STEP"
        GoTo DoSTEP
    Case "STOP"
        GoTo DoSTOP
    Case "THEN"
        GoTo DoThen
    Case "TIMER"
        GoTo DoTIMER
    Case "TO"
        GoTo DoTO
    Case "TRON"
        GoTo DoTRON
    Case "TROFF"
        GoTo DoTROFF
    Case "UNLOAD"
        GoTo DoUNLOAD
    Case "UNTIL"
        GoTo DoUNTIL
    Case "USING"
        GoTo DoUSING
    Case "VERIFY"
        GoTo DoVERIFY
    Case "WEND"
        GoTo DoWEND
    Case "WHILE"
        GoTo DoWHILE
    Case "WRITE"
        GoTo DoWRITE
    Case "WPOKE"
        GoTo DoWPOKE
    Case "LOADM"
        GoTo DoLOADM
    Case Else
        Print "Unknown General command on";: GoTo FoundError
        System
End Select

' Jump to the numeric command pointed at by v
JumpToNumericCommand:
Select Case NumericCommands$(v)
    Case "ABS"
        GoTo DoABS
    Case "ASC"
        GoTo DoASC
    Case "ATN"
        GoTo DoATN
    Case "BUTTON"
        GoTo DoBUTTON
    Case "COS"
        GoTo DoCOS
    Case "CVN"
        GoTo DoCVN
    Case "EOF"
        GoTo DoEOF
    Case "EXP"
        GoTo DoEXP
    Case "FIX"
        GoTo DoFIX
    Case "FN"
        GoTo DoFN
    Case "FREE"
        GoTo DoFREE
    Case "INSTR"
        GoTo DoINSTR
    Case "INT"
        GoTo DoINT
    Case "JOYSTK"
        GoTo DoJOYSTK
    Case "LEN"
        GoTo DoLEN
    Case "LOC"
        GoTo DoLOC
    Case "LOF"
        GoTo DoLOF
    Case "LOG"
        GoTo DoLOG
    Case "MEM"
        GoTo DoMEM
    Case "PEEK"
        GoTo DoPEEK
    Case "POINT"
        GoTo DoPOINT
    Case "POS"
        GoTo DoPOS
    Case "PPOINT"
        GoTo DoPPOINT
    Case "RND"
        GoTo DoRND
    Case "RNDZ"
        GoTo DoRNDZ
    Case "RNDL"
        GoTo DoRNDL
    Case "SGN"
        GoTo DoSGN
    Case "SIN"
        GoTo DoSIN
    Case "SQR"
        GoTo DoSQR
    Case "TAB"
        GoTo DoTAB
    Case "TAN"
        GoTo DoTAN
    Case "USR"
        GoTo DoUSR
    Case "VAL"
        GoTo DoVAL
    Case "VARPTR"
        GoTo DoVARPTR
    Case "WPEEK"
        GoTo DoWPEEK
    Case Else
        Print "Unknown Numeric command on";: GoTo FoundError
        System
End Select

' Jump to the String command pointed at by v
JumpToStringCommand:
Select Case StringCommands$(v)
    Case "CHR$"
        GoTo DoCHR
    Case "DSKI$"
        GoTo DoDSKI
    Case "DSKO$"
        GoTo DoDSKO
    Case "HEX$"
        GoTo DoHEX
    Case "INKEY$"
        GoTo DoINKEY
    Case "LEFT$"
        GoTo DoLEFT
    Case "MID$"
        GoTo DoMID
    Case "MKN$"
        GoTo DoMKN
    Case "RIGHT$"
        GoTo DoRIGHT
    Case "STR$"
        GoTo DoSTR
    Case "STRING$"
        GoTo DoSTRING
    Case Else
        Print "Unknown String command on";: GoTo FoundError
        System
End Select

' Get the value of a string expression
ParseStringExpression:
'show$ = Expression$: GoSub show
If Verbose > 2 Then Print "Going to parse String: "; Expression$
ExpressionCount = ExpressionCount + 1
Expression$(ExpressionCount) = Expression$ + "    "
index(ExpressionCount) = 1
GoSub ParseStringExpression0
ExpressionCount = ExpressionCount - 1
Return

' handle +
ParseStringExpression0:
GoSub ParseStringExpression10 ' Check for String Quotes, String Variables or String Commands
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC And (Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2B)
    ' Check for +
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then
        'We found the operator token
        index(ExpressionCount) = index(ExpressionCount) + 1 ' point at the actual operator
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H2B Then
            ' We found a +
            StrParseCount = StrParseCount + 1
            index(ExpressionCount) = index(ExpressionCount) + 1 ' Consume the +
            ' Do concatenation
            GoSub ParseStringExpression10 ' Result in Parse00_Term$
            num = StrParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            ' string at StrParseCount-1 = string at StrParseCount-1 + string at StrParseCount
            ' Leave blank so the assembler knows the Loop@ & Done@ are for this bit of code only
            Print #1,
            A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the start of the old string (which is the final Destination)": GoSub AssemOut
            A$ = "LDB": B$ = ",X+": C$ = "B = length of the old string, move X to the first location where data is stored": GoSub AssemOut
            A$ = "ABX": C$ = "X now points at the location to start copying to (Destination is setup)": GoSub AssemOut
            num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "ADDB": B$ = "_StrVar_PF" + Num$: C$ = "Add the length of the new string to the old string": GoSub AssemOut
            A$ = "BEQ": B$ = "Done@": C$ = "Skip ahead if they are both empty": GoSub AssemOut
            A$ = "LDU": B$ = "#_StrVar_PF" + Num$: C$ = "U points at the length of the source string": GoSub AssemOut
            A$ = "LDA": B$ = ",U+": C$ = "A = the length of the source string, move U to the first byte of source data": GoSub AssemOut
            A$ = "BEQ": B$ = "Done@": C$ = "Skip ahead if the source is empty": GoSub AssemOut
            num = StrParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "STB": B$ = "_StrVar_PF" + Num$: C$ = "Update the size of the final Destination string": GoSub AssemOut
            Z$ = "Loop@"
            A$ = "LDB": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
            A$ = "STB": B$ = ",X+": C$ = "Write the destination byte": GoSub AssemOut
            A$ = "DECA": C$ = "Decrement the counter": GoSub AssemOut
            A$ = "BNE": B$ = "Loop@": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
            Print #1, "Done@"
            ' Leave blank so the assembler knows the Loop@ & Done@ are for this bit of code only
            Print #1,
            StrParseCount = StrParseCount - 1
        End If
    End If
Wend
Return

' Check for String Quotes, String Variables or String Commands
ParseStringExpression10:
PE10Count = PE10Count + 1
' Handle String values in quotes
' Print Start, Hex$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)))
If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) = Chr$(&HF5) + Chr$(&H22) Then ' Is it a quote?
    ' We found a quote
    index(ExpressionCount) = index(ExpressionCount) + 2 ' move past the $F5 & quote
    x$ = "" ' Init the variable that will equal to what's in the quotes
    While Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1) <> Chr$(&HF5)
        x$ = x$ + Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)
        index(ExpressionCount) = index(ExpressionCount) + 1 'Move to the next characater in the quotes
    Wend
    index(ExpressionCount) = index(ExpressionCount) + 2 'consume the $F5 & the end quote
    'We exit and index pointer is now at the character after the quote
    If x$ = "" Then 'Is it an empty string?
        ' if it's an empty string then simply, write zero to the size
        num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "CLR": B$ = "_StrVar_PF" + Num$: C$ = "Set size of string as zero bytes": GoSub AssemOut
    Else
        ' Copy the string to the temp string pointer
        A$ = "BSR": B$ = ">": C$ = "Skip over string value and save the string start on the stack": GoSub AssemOut
        For ii = 1 To Len(x$)
            A$ = "FCB": B$ = "$" + Hex$(Asc(Mid$(x$, ii, 1))): C$ = Mid$(x$, ii, 1): GoSub AssemOut 'write the quote text
        Next ii
        Z$ = "!"
        num = Len(x$): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDB": B$ = "#" + Num$: C$ = "Length of this string": GoSub AssemOut
        num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the Temp string variable start location ": GoSub AssemOut ' X points at the Temp string variable start location
        A$ = "STB": B$ = ",X+": C$ = "store the length of the string data": GoSub AssemOut
        A$ = "LDU": B$ = ",S++": C$ = "Stack points to the string start location, remove the return address off the stack": GoSub AssemOut
        Z$ = "!"
        A$ = "LDA": B$ = ",U+": C$ = "Get the string data": GoSub AssemOut
        A$ = "STA": B$ = ",X+": C$ = "write the string data": GoSub AssemOut
        A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
        A$ = "BNE": B$ = "<": C$ = "Loop until string is copied into _StrVar_PF" + Num$: GoSub AssemOut
    End If
Else
    'Check for String variable
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HF3 Then ' F3 = Regular String Variable
        ' Regular String Variable
        index(ExpressionCount) = index(ExpressionCount) + 1
        x$ = StringVariable$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))) ' String Array variable name
        '  Print "Found a String variable: "; x$; " need to deal with this"
        index(ExpressionCount) = index(ExpressionCount) + 2 'consume the string variable
        ' Copy String variable X$ to temp variable  "_StrVar_PF" + Num$
        A$ = "LDU": B$ = "#_StrVar_" + x$: C$ = "U points at the start of the source string": GoSub AssemOut
        A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AssemOut
        num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the length of the destination string": GoSub AssemOut
        A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AssemOut
        A$ = "BEQ": B$ = "Done@": C$ = "If B=0 then no need to copy the string": GoSub AssemOut
        Z$ = "!"
        A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
        A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AssemOut
        A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
        A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
        Z$ = "Done@": GoSub AssemOut
        Print #1, "" ' Leave a space between sections so Done@ will work for each section
    Else
        'Check for String Array variable
        ' String Array token is:
        ' 00  = &HF1 - The String Array identifier
        ' 01  = Pointer to the String Array Name in array StringArrayVariables$()
        ' 02  = Number of dimensions this array has

        '   StringArrayVariables$(200), StringArrayDimensions(200) As Integer, StringArrayDimensionsVal$(200)

        ' Offset = (x * Ny * Nz + y * Nz + z) * E
        ' Where:
        ' Nx = Number of elements in the x dimension (not used directly in calculation)
        ' Ny = Number of elements in the y dimension (10 in your case)
        ' Nz = Number of elements in the z dimension (10 in your case)
        ' E = Size of each element in bytes (2 bytes in your case)

        ' To understand this a little better, what if my array is A(2,3,6,5)
        ' where the first dimension is from 0 to 4 (5)
        ' the 2nd is 0 to 7 (8)
        ' the 3rd is 0 to 8 (9)
        ' and 4th is 0 to 11 (12)
        ' How to calculate the offset?
        ' Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
        ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HF1 Then ' F1 = String Array Variable
            ' String Array variable
            StrArrayParseNum = StrArrayParseNum + 1
            index(ExpressionCount) = index(ExpressionCount) + 1 ' Point at the String array name
            StrArrayNameParseNum$(StrArrayParseNum) = StringArrayVariables$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))) ' String Array variable name
            '  Print "Found a String Array variable: "; StrArrayNameParseNum$(StrArrayParseNum); " need to deal with this"
            index(ExpressionCount) = index(ExpressionCount) + 2 ' Point at the number of dimensions this array has
            StrArrayNameParseNum(StrArrayParseNum) = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) ' Number of dimensions this array has
            index(ExpressionCount) = index(ExpressionCount) + 3 ' consume the # of dimension & the $F5 & open bracket "("
            If StrArrayNameParseNum(StrArrayParseNum) = 1 Then ' does it only have one dimension? if so it's simpler
                ' Yes just a single dimension array
                If Verbose > 3 Then Print "handling a one dimensional array"
                ' Print #1, "; Started handling the array here:"
                GoSub ParseExpression0FlagErase ' Recursively check the next value, this will return with the next value in D
                resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
                ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
                If StringArraySize = 255 Then
                    ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
                    A$ = "TFR": B$ = "B,A": C$ = "D = B * 256": GoSub AssemOut
                    A$ = "CLRB": C$ = Chr$(&H22) + Chr$(&H22): GoSub AssemOut
                Else
                    ' A little slower but saves RAM
                    num = StringArraySize: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDA": B$ = "#" + Num$ + "+1": C$ = "String Array size requested by the user +1 because first digit is the string length": GoSub AssemOut
                    A$ = "MUL": C$ = "D = A * B":: GoSub AssemOut
                End If
                A$ = "ADDD": B$ = "#_ArrayStr_" + StrArrayNameParseNum$(StrArrayParseNum) + "+1": C$ = "D points at the start of the destination string": GoSub AssemOut
                ' Copy String variable That D points at to temp variable  "_StrVar_PF" + Num$
                A$ = "TFR": B$ = "D,U": C$ = "U points at the start of the source string": GoSub AssemOut
                A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AssemOut
                num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the length of the destination string": GoSub AssemOut
                A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AssemOut
                A$ = "BEQ": B$ = "Done@": C$ = "If B=0 then no need to copy the string": GoSub AssemOut
                Z$ = "!"
                A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
                A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AssemOut
                A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
                A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
                Z$ = "Done@": GoSub AssemOut
                Print #1, "" ' Leave a space between sections so Done@ will work for each section
                index(ExpressionCount) = index(ExpressionCount) + 1 ' Skip the close bracket
            Else
                ' To understand this a little better, what if my array is A(2,3,6,5)
                ' where the first dimension is from 0 to 4 (5)
                ' the 2nd is 0 to 7 (8)
                ' the 3rd is 0 to 8 (9)
                ' and 4th is 0 to 11 (12)
                ' How to calculate the offset?
                ' Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
                ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)

                'We have a multidimensional array to deal with
                If Verbose > 3 Then Print "handling a multi dimensional array"
                A$ = "LDX": B$ = "#_ArrayStr_" + StrArrayNameParseNum$(StrArrayParseNum) + "+1": C$ = " X points at the 2nd array Element size": GoSub AssemOut ' X points at the 2nd array Element size
                A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AssemOut
                ' Get d1
                GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse
                Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D
                A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AssemOut ' D = d1
                If StrArrayNameParseNum(StrArrayParseNum) = 2 Then GoTo DoStrArrCloseBracket ' skip ahead if we only have 2 dimension in the array
                'Get NumElements2
                A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AssemOut
                A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut ' LSB of d1
                A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut ' D=d1* NumElements2
                A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AssemOut ' Save it on the stack
                A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
                A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
                A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
                Z$ = "!": GoSub AssemOut ' Num Element Pointer is now pointing at NumElements3
                'Get d2
                GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse
                Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                ' Add d2
                A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
                A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
                If Verbose > 3 Then Print "number of dimensions:"; StrArrayNameParseNum(StrArrayParseNum)
                If StrArrayNameParseNum(StrArrayParseNum) > 3 Then
                    For Temp1 = 3 To StrArrayNameParseNum(StrArrayParseNum) - 1 ' Number of dimensions in the array - 1 since last ont have a comma seperating it
                        ' Get NumElementsX
                        A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
                        A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
                        A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                        Need 16bit muliply
                        A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AssemOut
                        A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
                        A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
                        A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
                        Z$ = "!": GoSub AssemOut
                        ' Add dX
                        Temp(StrArrayParseNum) = Temp1 ' Keep value, just incase we have arrays, inside arrays
                        GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse
                        Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                        ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                        Temp1 = Temp(StrArrayParseNum) ' restore value, just incase we have arrays, inside arrays
                        A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
                        A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
                    Next Temp1
                End If
                DoStrArrCloseBracket:
                ' Last dimension value ends with a close bracket
                ' Get NumElementsX
                A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
                A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
                A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                                 Need 16bit multiply
                ' Add dX
                GoSub GetArrayElementB4Bracket ' Get the value to parse that is before the close bracket ")", Temp$ is the expression to parse
                Expression$ = Temp$ ' New expression to parse (dimension in the array before a close bracket)
                ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
                A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AssemOut
                ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
                If StringArraySize = 255 Then
                    ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
                    A$ = "TFR": B$ = "B,A": C$ = "D = B * 256": GoSub AssemOut
                    A$ = "CLRB": C$ = Chr$(&H22) + Chr$(&H22): GoSub AssemOut
                Else
                    ' A little slower but saves RAM
                    num = StringArraySize: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDA": B$ = "#" + Num$ + "+1": C$ = "String Array size requested by the user +1 because first digit is the string length": GoSub AssemOut
                    A$ = "MUL": C$ = "D = A * B":: GoSub AssemOut
                End If

                ' Copy String variable That D points at to temp variable  "_StrVar_PF" + Num$
                num = StrArrayNameParseNum(StrArrayParseNum): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "ADDD": B$ = "#_ArrayStr_" + StrArrayNameParseNum$(StrArrayParseNum) + "+" + Num$: C$ = "D = D + the the start of the source string": GoSub AssemOut
                A$ = "TFR": B$ = "D,U": C$ = "U points at the start of the source string": GoSub AssemOut
                A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AssemOut
                num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the start of the destination string": GoSub AssemOut
                A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AssemOut
                A$ = "BEQ": B$ = "Done@": C$ = "If B=0 then no need to copy the string": GoSub AssemOut
                Z$ = "!"
                A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AssemOut
                A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AssemOut
                A$ = "DECB": C$ = "Decrement the counter": GoSub AssemOut
                A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AssemOut
                Z$ = "Done@": GoSub AssemOut
                Print #1, "" ' Leave a space between sections so Done@ will work for each section
            End If
            StrArrayParseNum = StrArrayParseNum - 1
        Else
            'Check for String command  - should work similarly to a bracket
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFD Then ' FD = String Command
                ' FD = String Command
                index(ExpressionCount) = index(ExpressionCount) + 1
                v = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))
                index(ExpressionCount) = index(ExpressionCount) + 4 ' Consume the String command and open bracket
                GoSub JumpToStringCommand ' Go do the string command
                If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) <> Chr$(&HF5) + ")" Then
                    Print "Error1: Expected closing parenthesis in";: GoTo FoundError
                End If
                index(ExpressionCount) = index(ExpressionCount) + 2 ' move past the close brackets
            Else
                show$ = Expression$(ExpressionCount): GoSub show
                Print "I can't process part of the string expression on";: GoTo FoundError
            End If
        End If
    End If
End If
'Wend
Parse10_Term$ = resultP10$(PE10Count)
PE10Count = PE10Count - 1
Return

' Get the value of a numeric expression and return with the value in D
' If ExType = 1 then it can be replaced with an actual number that is in variable result
' If ExType = 2 then there are variables used in this expression so have to use it as it is.
'Start of new parsing of an expression, end result is numerical
ParseNumericExpression:
If Verbose > 2 Then Print "Going to parse Numeric Expression: "; Expression$
ExpressionCount = ExpressionCount + 1
' Make sure expression doesn't start with +
If Left$(Expression$, 2) = Chr$(&HFC) + Chr$(&H2B) Then Expression$ = Right$(Expression$, Len(Expression$) - 2) ' If so, ignore the first two bytes ($FC $2B) = +

' Check if Expression has a NOT in it which is &HFC &H14, if so we need to put a 1 in front of it
NewExpression$ = ""
For I = 1 To Len(Expression$) - 1
    If Asc(Mid$(Expression$, I, 1)) = &HFC And Asc(Mid$(Expression$, I + 1, 1)) = &H14 Then
        'We found a NOT
        NewExpression$ = NewExpression$ + "1"
    End If
    NewExpression$ = NewExpression$ + Mid$(Expression$, I, 1)
Next I
NewExpression$ = NewExpression$ + Mid$(Expression$, I, 1) 'copy the last byte
Expression$ = NewExpression$
Expression$(ExpressionCount) = Expression$ + "    "
index(ExpressionCount) = 1
GoSub ParseExpression0
Print #1, "*XX We can delete the line above XX*"
ExpressionCount = ExpressionCount - 1
Return

' Parse Numeric Expression and flag the last line as erasable
ParseExpression0FlagErase:
GoSub ParseExpression0
Print #1, "*XX We can delete the line above XX*"
Return

'                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

ParseExpression0:
' Do logical OR
GoSub ParseExpression02 ' Go check other more priority things first, then do OR
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H11
    ' Found an OR token
    NumParseCount = NumParseCount + 1
    index(ExpressionCount) = index(ExpressionCount) + 2 ' point past the actual operator
    'Do OR
    GoSub ParseExpression02 ' Result in Parse00_Term
    num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
    A$ = "PSHS": B$ = "D": C$ = "Save D on the Stack = The left value": GoSub AssemOut ' Save the FIrst value
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' D = Parse10_Term
    A$ = "ORA": B$ = ",S+": C$ = "ORA": GoSub AssemOut ' A = A OR Parse10_Term
    A$ = "ORB": B$ = ",S+": C$ = "ORB": GoSub AssemOut ' B = B OR Parse10_Term
    NumParseCount = NumParseCount - 1
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut
Wend
Return

' Do logical AND
ParseExpression02:
GoSub ParseExpression03 ' Go check other more priority things first, then do AND
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H10
    ' Found an AND token
    NumParseCount = NumParseCount + 1
    index(ExpressionCount) = index(ExpressionCount) + 2 ' point past the actual operator
    'Do AND
    GoSub ParseExpression03 ' Result in Parse00_Term
    num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
    A$ = "PSHS": B$ = "D": C$ = "Save D on the Stack = The left value": GoSub AssemOut ' Save the FIrst value
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' D = Parse10_Term
    A$ = "ANDA": B$ = ",S+": C$ = "ANDA": GoSub AssemOut ' A = A AND Parse10_Term
    A$ = "ANDB": B$ = ",S+": C$ = "ANDB": GoSub AssemOut ' B = B AND Parse10_Term
    NumParseCount = NumParseCount - 1
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut
Wend
Return

'                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' Do <,=,>
ParseExpression03:
GoSub ParseExpression05 ' Go check other things before doing < = >
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And (Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) > &H3B and Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) < &H3F)
    ' Check for > = <
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then
        'We found the operator token
        index(ExpressionCount) = index(ExpressionCount) + 1 ' point at the actual operator
        ' Figure out if we have two operators and what they are
        F2 = 0
        F1 = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1))
        ' (J<=5) or (J<   =5) end up as 0A FC 09        , (J<5) ends up as 0A 35 29
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &HFC Then
            ' We have two Operators
            F2 = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 2, 1))
            index(ExpressionCount) = index(ExpressionCount) + 2
        Else
            F2 = 0
        End If
        If F2 = 0 Then
            If F1 = &H3E Then BranchType$ = "BGT" '>
            If F1 = &H3D Then BranchType$ = "BEQ" '=
            If F1 = &H3C Then BranchType$ = "BLT" '<
        Else
            If F2 = &H3E Then '>
                If F1 = &H3E Then BranchType$ = "BGT"
                If F1 = &H3D Then BranchType$ = "BGE"
                If F1 = &H3C Then BranchType$ = "BNE"
            End If
            If F2 = &H3D Then '=
                If F1 = &H3E Then BranchType$ = "BGE"
                If F1 = &H3D Then BranchType$ = "BEQ"
                If F1 = &H3C Then BranchType$ = "BLE"
            End If
            If F2 = &H3C Then '<
                If F1 = &H3E Then BranchType$ = "BNE"
                If F1 = &H3D Then BranchType$ = "BLE"
                If F1 = &H3C Then BranchType$ = "BLT"
            End If
        End If
        ' We found the Branch type in BranchType$
        NumParseCount = NumParseCount + 1
        index(ExpressionCount) = index(ExpressionCount) + 1
        GoSub ParseExpression05 ' Result in Parse00_Term
        num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "CMPD": B$ = "_Var_PF" + Num$: GoSub AssemOut
        A$ = BranchType$: B$ = "@IsTrue": C$ = "skip ahead if TRUE": GoSub AssemOut
        A$ = "LDD": B$ = "#$0000": C$ = "False repsonse": GoSub AssemOut
        A$ = "BRA": B$ = ">": C$ = "Skip ahead": GoSub AssemOut
        Z$ = "@IsTrue": GoSub AssemOut
        A$ = "LDD": B$ = "#$FFFF": C$ = "True repsonse": GoSub AssemOut
        NumParseCount = NumParseCount - 1
        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        Z$ = "!": GoSub AssemOut
        Print #1,
        A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut
    End If
Wend
Return
'                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' Do + or -
ParseExpression05:
GoSub ParseExpression09 ' Go check everything else then do + or -
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And (Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2B Or Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2D)
    ' Check for + or -
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then
        'We found the operator token
        index(ExpressionCount) = index(ExpressionCount) + 1 ' point at the actual operator
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H2B Or Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H2D Then
            ' We found a + or -
            NumParseCount = NumParseCount + 1
            index(ExpressionCount) = index(ExpressionCount) + 1
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) - 1, 1)) = &H2B Then
                ' Do addition
                GoSub ParseExpression09 ' Result in Parse00_Term
                num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "ADDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
            Else
                'Do subtraction
                GoSub ParseExpression09 ' Result in Parse00_Term
                num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "SUBD": B$ = "_Var_PF" + Num$: GoSub AssemOut
            End If
            NumParseCount = NumParseCount - 1
            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut
        End If
    End If
Wend
Return
'                         1   2   3   4   5    6    7    8   9  10  11  12  13  14
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' MOD
ParseExpression09:
GoSub ParseExpression10 ' Go check other more priority things first, then do MOD
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H12
    ' Found a MOD token
    NumParseCount = NumParseCount + 1
    index(ExpressionCount) = index(ExpressionCount) + 2 ' point past the actual operator
    'Do MOD
    GoSub ParseExpression10 ' Result in Parse00_Term
    num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
    A$ = "PSHS": B$ = "D": C$ = "Save D on the Stack = The Numerator": GoSub AssemOut ' Save the Numerator
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' D = Parse10_Term
    A$ = "PULS": B$ = "X": C$ = "Get X off the Stack = The Numerator": GoSub AssemOut ' Get the Numerator
    A$ = "JSR": B$ = "DIV16": C$ = "Do 16bit by 16bit division, result in D and Remainder (MOD) in X": GoSub AssemOut
    A$ = "TFR": B$ = "X,D": C$ = "Transfer the Remainder into D": GoSub AssemOut
    NumParseCount = NumParseCount - 1
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut
Wend
Return

'                         1   2   3   4   5    6    7    8   9  10  11  12  13  14
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' Do * or / or DIVR (Divide with auto Rounding)
ParseExpression10:
PE10Count = PE10Count + 1
GoSub ParseExpression20 ' Go check everything other things before doing * or /
resultP10(PE10Count) = Parse20_Term
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC And _
(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2A Or Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2F Or _
 Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H15 Or Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H5C)
    ' Check for * or /
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then
        'We found the operator token
        index(ExpressionCount) = index(ExpressionCount) + 1 ' point at the actual operator
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H2A Or _
         Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H2F Or _
         Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H15 Or _
         Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H5C Then
            ' We found a * or /
            NumParseCount = NumParseCount + 1
            '    Print "PE10Count="; PE10Count, "Doing a "; op$; " ";
            index(ExpressionCount) = index(ExpressionCount) + 1
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) - 1, 1)) = &H2A Then
                ' Do multiplication
                GoSub ParseExpression20 ' Result in Parse20_Term
                num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDX": B$ = "_Var_PF" + Num$: GoSub AssemOut
                A$ = "PSHS": B$ = "D,X": C$ = "Save the two 16 bit WORDS on the stack, to be multiplied": GoSub AssemOut
                A$ = "JSR": B$ = "MUL16": C$ = "Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D": GoSub AssemOut ' D = D * X
                A$ = "LEAS": B$ = "4,S": C$ = "Fix the Stack": GoSub AssemOut
                resultP10(PE10Count) = resultP10(PE10Count) * Parse20_Term
                GoTo DoneMD
            End If
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) - 1, 1)) = &H2F Or _
               Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) - 1, 1)) = &H5C Then
                'Do division
                GoSub ParseExpression20 ' Result in Parse20_Term
                num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDX": B$ = "_Var_PF" + Num$: GoSub AssemOut
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
                ' X = X/D, remainder in D
                A$ = "JSR": B$ = "DIV16": C$ = "Do 16 bit / 16 bit Division, D = X/D No rounding will occur": GoSub AssemOut ' D = D * X
                resultP10(PE10Count) = resultP10(PE10Count) / Parse20_Term
                GoTo DoneMD
            End If
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) - 1, 1)) = &H15 Then
                ' Do DIVR (division that will round the value)
                GoSub ParseExpression20 ' Result in Parse20_Term
                num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDX": B$ = "_Var_PF" + Num$: GoSub AssemOut
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
                ' D = X/D
                A$ = "JSR": B$ = "DIV16Rounding": C$ = "Do 16 bit / 16 bit Division, D = X/D rounds the result": GoSub AssemOut ' D = D * X
                resultP10(PE10Count) = resultP10(PE10Count) / Parse20_Term
                GoTo DoneMD
            End If
            DoneMD:
            NumParseCount = NumParseCount - 1
            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' Save new resultP10(PE10Count)
        End If
    End If
Wend
Parse10_Term = resultP10(PE10Count)
'Print "Parse10_Term="; Parse10_Term, "PE10Count="; PE10Count
PE10Count = PE10Count - 1
Return

'                         1   2   3   4   5    6    7    8   9  10  11  12  13  14
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' Do Exponents
ParseExpression20:
PE20Count = PE20Count + 1
GoSub ParseExpression25 ' Go check everything else first, do exponent
resultP20(PE20Count) = Parse30_Term
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
    And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H5E
    ' Check for ^
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then
        'We found the operator token
        index(ExpressionCount) = index(ExpressionCount) + 1 ' point at the actual operator
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H5E Then
            ' We found a ^
            NumParseCount = NumParseCount + 1
            index(ExpressionCount) = index(ExpressionCount) + 1
            ' Do Exponent
            GoSub ParseExpression25 ' Result in Parse30_Term
            num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "LDD": B$ = "_Var_PF" + Num$: C$ = "D = the Base value": GoSub AssemOut
            A$ = "PSHS": B$ = "D": C$ = "Save the base value": GoSub AssemOut
            A$ = "PSHS": B$ = "D": C$ = "Save the base value": GoSub AssemOut
            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "LDX": B$ = "_Var_PF" + Num$: C$ = "X = the Exponent value": GoSub AssemOut
            A$ = "BNE": B$ = ">": C$ = "If X <> zero then skip ahead": GoSub AssemOut
            A$ = "LDD": B$ = "#1": C$ = "Exponent of zero results with 1": GoSub AssemOut
            A$ = "BRA": B$ = "@GotD": C$ = "Done": GoSub AssemOut
            Z$ = "!"
            A$ = "BPL": B$ = ">": C$ = "If it's a postive number skip ahead": GoSub AssemOut
            A$ = "LDD": B$ = "#$FFFF": C$ = "can't do negative exponents, make value -1": GoSub AssemOut
            A$ = "BRA": B$ = "@GotD": C$ = "Done": GoSub AssemOut
            Z$ = "!"
            A$ = "CMPX": B$ = "#1": C$ = "Is the exponent > 1": GoSub AssemOut
            A$ = "BGT": B$ = "@StartHere": C$ = "If so skip ahead, starting with Decrementing X": GoSub AssemOut
            A$ = "LDD": B$ = "2,S": C$ = "D = the Base value": GoSub AssemOut
            A$ = "BRA": B$ = "@GotD": C$ = "Done": GoSub AssemOut
            Z$ = "!"
            A$ = "JSR": B$ = "MUL16": C$ = "Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D": GoSub AssemOut
            A$ = "STD": B$ = ",S": C$ = "Save the result to be multiplied with the base number again": GoSub AssemOut
            Z$ = "@StartHere": GoSub AssemOut
            A$ = "LEAX": B$ = "-1,X": C$ = "Decremnt the number of times to multiply": GoSub AssemOut
            A$ = "BNE": B$ = "<": C$ = "If X is <> zero keep looping": GoSub AssemOut
            Z$ = "@GotD"
            A$ = "LEAS": B$ = "4,S": C$ = "fix the stack": GoSub AssemOut
            Print #1,
            resultP20(PE20Count) = resultP20(PE20Count) ^ Parse30_Term
            NumParseCount = NumParseCount - 1
            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' Save new resultP20(PE20Count)
        End If
    End If
Wend
Parse20_Term = resultP20(PE20Count)
'Print "Parse20_Term="; Parse20_Term, "PE20Count="; PE20Count
PE20Count = PE20Count - 1
Return
'                         1   2   3   4   5    6    7    8   9  10  11  12  13  14
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' Do loginal XOR
ParseExpression25:
GoSub ParseExpression28 ' Go check other more priority things first, then do XOR
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H13
    ' Found an XOR token
    NumParseCount = NumParseCount + 1
    index(ExpressionCount) = index(ExpressionCount) + 2 ' point past the actual operator
    'Do XOR
    GoSub ParseExpression28 ' Result in Parse00_Term
    num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
    A$ = "PSHS": B$ = "D": C$ = "Save D on the Stack = The left value": GoSub AssemOut ' Save the FIrst value
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' D = Parse10_Term
    A$ = "EORA": B$ = ",S+": C$ = "EORA MSB on the stack, move stack forward": GoSub AssemOut
    A$ = "EORB": B$ = ",S+": C$ = "EORB LSB on the stack, stack is now back to normal": GoSub AssemOut
    NumParseCount = NumParseCount - 1
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut
Wend
Return

' Do logical NOT
ParseExpression28:
GoSub ParseExpression30 ' Go check other more priority things first, then do NOT
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H14
    ' Found a NOT token
    NumParseCount = NumParseCount + 1
    index(ExpressionCount) = index(ExpressionCount) + 2 ' point past the actual operator
    ' Do NOT
    GoSub ParseExpression30 ' Result in Parse00_Term
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AssemOut
    A$ = "COMA": C$ = "Flip the bits": GoSub AssemOut
    A$ = "COMB": C$ = "Flip the bits": GoSub AssemOut
    A$ = "STD": B$ = "_Var_PF" + Num$: C$ = "Save the NOT version": GoSub AssemOut
    NumParseCount = NumParseCount - 1 ' We can now use the left PFxx, place holder
Wend
Return
'                         1   2   3   4   5    6    7    8   9  10  11  12  13  14
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

'Handle unary minus, Parenthesis, numbers and numeric variables
ParseExpression30:
PE30Count = PE30Count + 1
negative(PE30Count) = 0 ' Default state is not negative
If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then ' Check for an operator token
    'We found the operator token
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2D Then
        ' We found a -
        ' Should probably check for double or more negatives (just in case of typos)
        negative(PE30Count) = 1 ' Flag this factor as negative
        index(ExpressionCount) = index(ExpressionCount) + 2 ' Move past the unary minus
    End If
End If
' Now handle whether the factor is a number or a subexpression
If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) = Chr$(&HF5) + "(" Then
    index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume '$F5&('
    GoSub ParseExpression0 ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value
    If negative(PE30Count) = 1 Then resultP30(PE30Count) = -resultP30(PE30Count)
    If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) = Chr$(&HF5) + ")" Then
        index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume '$F5&)'
    Else
        Print "Error2: Expected closing parenthesis in";: GoTo FoundError
    End If
Else
    ' Handle numeric values
    Start = index(ExpressionCount)
    ' Print Start, Hex$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)))
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) >= Asc("0") And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) <= Asc("9") Then
        'Numeric value
        If index(ExpressionCount) = Len(Expression$(ExpressionCount)) Then
            x$(ExpressionCount) = Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)
        Else
            While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) >= Asc("0") And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) <= Asc("9")
                index(ExpressionCount) = index(ExpressionCount) + 1
            Wend
            x$(ExpressionCount) = Mid$(Expression$(ExpressionCount), Start, index(ExpressionCount) - Start)
            If index(ExpressionCount) = Len(Expression$(ExpressionCount)) Then x$(ExpressionCount) = x$(ExpressionCount) + Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)
        End If
        '   Print  x$(ExpressionCount), Expression$(ExpressionCount), Start, index(ExpressionCount), index(ExpressionCount) - Start
        ' Apply negation if flagged
        If negative(PE30Count) = 1 Then
            num = -Val(x$(ExpressionCount)):
            resultP30(PE30Count) = -Val(x$(ExpressionCount))
        Else
            num = Val(x$(ExpressionCount)):
            resultP30(PE30Count) = Val(x$(ExpressionCount))
        End If
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDD": B$ = "#" + Num$: GoSub AssemOut ' D = Val( x$(ExpressionCount))
        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' Save Temp_Var_NumParseCount
    Else
        ' Handle hex values
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = Asc("&") Then
            ' number is in hex
            If index(ExpressionCount) + 1 >= Len(Expression$(ExpressionCount)) Then
                Print "Error: can't process the value of the &, on";: GoTo FoundError
            Else
                index(ExpressionCount) = index(ExpressionCount) + 2
                Start = index(ExpressionCount)
                While index(ExpressionCount) < Len(Expression$(ExpressionCount)) _
                And ((Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) >= Asc("0") _
                And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) <= Asc("9")) _
                Or (Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) >= Asc("A") _
                And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) <= Asc("F")))
                    index(ExpressionCount) = index(ExpressionCount) + 1
                Wend
                x$(ExpressionCount) = Mid$(Expression$(ExpressionCount), Start, index(ExpressionCount) - Start)
                If index(ExpressionCount) = Len(Expression$(ExpressionCount)) Then x$(ExpressionCount) = x$(ExpressionCount) + Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)
            End If
            ' Apply negation if flagged
            If negative(PE30Count) = 1 Then
                num = -Val("&H" + x$(ExpressionCount))
                resultP30(PE30Count) = -Val(x$(ExpressionCount))
            Else
                num = Val("&H" + x$(ExpressionCount))
                resultP30(PE30Count) = Val(x$(ExpressionCount))
            End If
            '     Print "val(x$)="; Val("&H" +  x$(ExpressionCount))
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            A$ = "LDD": B$ = "#" + Num$: C$ = "Converted &H" + x$(ExpressionCount) + " to" + Str$(num): GoSub AssemOut ' D = Val(x$)
            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' Save Temp_Var_NumParseCount
        Else
            'Check for Numeric variable
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HF2 Then ' F2 = Regular Numeric Variable
                ' Regular Numeric Variable
                ExType = 2 'flag we have variables
                index(ExpressionCount) = index(ExpressionCount) + 1
                x$(ExpressionCount) = NumericVariable$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)))
                '    Print "Found a numeric variable: ";  x$(ExpressionCount); " need to deal with this"
                '      resultP30(PE30Count) = GetVariableValue( x$(ExpressionCount)) ' You need to define how to retrieve variable values
                'Deal with a Numeric variable in the expression
                '   Print "Dealling with variable ";  x$(ExpressionCount); " here..."
                ' Apply negation if flagged
                If negative(PE30Count) = 1 Then
                    ' This is a negative
                    A$ = "LDD": B$ = "#$0000": C$ = "Clear D": GoSub AssemOut
                    A$ = "SUBD": B$ = "_Var_" + x$(ExpressionCount): C$ = "Going to use the negative verison of " + x$(ExpressionCount): GoSub AssemOut
                Else
                    A$ = "LDD": B$ = "_Var_" + x$(ExpressionCount): GoSub AssemOut: StoreFlag = 0
                End If
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' Save Temp_Var_NumParseCount
                index(ExpressionCount) = index(ExpressionCount) + 2
            Else
                'Check for Numeric Array variable
                ' Numeric Array token is:
                ' 00  = &HF0 - The Numeric Array identifier
                ' 01  = Pointer to the Numeric Array Name in array NumericArrayVariables$()
                ' 02  = Number of dimensions this array has

                ' Offset = (x * Ny * Nz + y * Nz + z) * E
                ' Where:
                ' Nx = Number of elements in the x dimension (not used directly in calculation)
                ' Ny = Number of elements in the y dimension (10 in your case)
                ' Nz = Number of elements in the z dimension (10 in your case)
                ' E = Size of each element in bytes (2 bytes in your case)

                ' To understand this a little better, what if my array is A(2,3,6,5)
                ' where the first dimension is from 0 to 4 (5)
                ' the 2nd is 0 to 7 (8)
                ' the 3rd is 0 to 8 (9)
                ' and 4th is 0 to 11 (12)
                ' How to calculate the offset?
                ' Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
                ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)

                If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HF0 Then ' F0 = Numeric Array Variable
                    ' Numeric Array variable
                    ExType = 2 'flag we have variables
                    NumArrayParseNum = NumArrayParseNum + 1
                    index(ExpressionCount) = index(ExpressionCount) + 1 ' Point at the numeric array name
                    NumArrayNameParseNum$(NumArrayParseNum) = NumericArrayVariables$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))) ' Numeric Array variable name
                    '  Print "Found a Numeric Array variable: "; NumArrayNameParseNum$(NumArrayParseNum); " need to deal with this"
                    index(ExpressionCount) = index(ExpressionCount) + 2 ' Point at the number of dimensions this array has

                    NumArrayNameParseNum(NumArrayParseNum) = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) ' Number of dimensions this array has
                    index(ExpressionCount) = index(ExpressionCount) + 3 ' consume the # of dimension & the $F5 open bracket "("
                    If NumArrayNameParseNum(NumArrayParseNum) = 1 Then ' does it only have one dimension? if so it's simpler
                        ' Yes just a single dimension array
                        If Verbose > 3 Then Print "handling a one dimensional array"
                        Print #1, "; Started handling the array here:"
                        GoSub ParseExpression0FlagErase ' Recursively check the next value, this will return with the next value in D
                        resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
                        A$ = "LSLB": GoSub AssemOut
                        A$ = "ROLA": C$ = "D=D*2, 16 bit integers in the numeric array": GoSub AssemOut
                        A$ = "ADDD": B$ = "#_ArrayNum_" + NumArrayNameParseNum$(NumArrayParseNum) + "+1": GoSub AssemOut
                        A$ = "TFR": B$ = "D,X": C$ = "X now points at the memory location for the array": GoSub AssemOut
                        ' Apply negation if flagged
                        If negative(PE30Count) = 1 Then
                            ' This is a negative
                            A$ = "LDD": B$ = "#$0000": C$ = "Clear D": GoSub AssemOut
                            A$ = "SUBD": B$ = ",X": C$ = "Going to use the negative verison of " + NumArrayNameParseNum$(NumArrayParseNum): GoSub AssemOut
                        Else
                            A$ = "LDD": B$ = ",X": GoSub AssemOut: StoreFlag = 0
                        End If
                        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        If num < 10 Then Num$ = "0" + Num$
                        A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' Save Temp_Var_NumParseCount
                        index(ExpressionCount) = index(ExpressionCount) + 2 ' Skip the $F5 & close bracket
                    Else
                        ' To understand this a little better, what if my array is A(2,3,6,5)
                        ' where the first dimension is from 0 to 4 (5)
                        ' the 2nd is 0 to 7 (8)
                        ' the 3rd is 0 to 8 (9)
                        ' and 4th is 0 to 11 (12)
                        ' How to calculate the offset?
                        ' Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
                        ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)

                        'We have a multidimensional array to deal with
                        If Verbose > 3 Then Print "handling a multi dimensional array"
                        A$ = "LDX": B$ = "#_ArrayNum_" + NumArrayNameParseNum$(NumArrayParseNum) + "+1": C$ = " X points at the 2nd array Element size  ": GoSub AssemOut ' X points at the 2nd array Element size
                        A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AssemOut
                        ' Get d1
                        GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse, move past it
                        Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                        ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D
                        A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AssemOut ' D = d1
                        If NumArrayNameParseNum(NumArrayParseNum) = 2 Then GoTo DoNumArrCloseBracket ' skip ahead if we only have 2 dimension in the array
                        'Get NumElements2
                        A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AssemOut
                        A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut ' LSB of d1
                        A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut ' D=d1* NumElements2
                        A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AssemOut ' Save it on the stack
                        A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
                        A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
                        A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
                        Z$ = "!": GoSub AssemOut ' Num Element Pointer is now pointing at NumElements3
                        'Get d2
                        GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse
                        Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                        ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                        ' Add d2
                        A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
                        A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
                        If Verbose > 3 Then Print "number of dimensions:"; NumArrayNameParseNum(NumArrayParseNum)
                        If NumArrayNameParseNum(NumArrayParseNum) > 3 Then
                            For Temp1 = 3 To NumArrayNameParseNum(NumArrayParseNum) - 1 ' Number of dimensions in the array - 1 since last ont have a comma seperating it
                                ' Get NumElementsX
                                A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
                                A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
                                A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                        Need 16bit muliply
                                A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AssemOut
                                A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AssemOut
                                A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AssemOut
                                A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AssemOut
                                Z$ = "!": GoSub AssemOut
                                ' Add dX
                                Temp(NumArrayParseNum) = Temp1 ' Keep value, just incase we have arrays, inside arrays
                                GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse
                                Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                                ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                                Temp1 = Temp(NumArrayParseNum) ' restore value, just incase we have arrays, inside arrays
                                A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
                                A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AssemOut
                            Next Temp1
                        End If
                        DoNumArrCloseBracket:
                        ' Last dimension value ends with a close bracket
                        ' Get NumElementsX
                        A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AssemOut
                        A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AssemOut
                        A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AssemOut '                                 Need 16bit multiply
                        ' Add dX
                        GoSub GetArrayElementB4Bracket ' Get the value to parse that is before the close bracket ")", Temp$ is the expression to parse
                        Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                        ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                        A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AssemOut
                        A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AssemOut
                        A$ = "LSLB": GoSub AssemOut
                        A$ = "ROLA": C$ = "D=D*2, 16 bit integers in the numeric array": GoSub AssemOut
                        num = NumArrayNameParseNum(NumArrayParseNum): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "ADDD": B$ = "#_ArrayNum_" + NumArrayNameParseNum$(NumArrayParseNum) + "+" + Num$: C$ = "D points at the start of the destination string": GoSub AssemOut
                        A$ = "TFR": B$ = "D,X": C$ = "X now points at the memory location for the array": GoSub AssemOut
                        ' Apply negation if flagged
                        If negative(PE30Count) = 1 Then
                            ' This is a negative
                            A$ = "LDD": B$ = "#$0000": C$ = "Clear D": GoSub AssemOut
                            A$ = "SUBD": B$ = ",X": C$ = "Going to use the negative verison of " + NumArrayNameParseNum$(NumArrayParseNum): GoSub AssemOut
                        Else
                            A$ = "LDD": B$ = ",X": GoSub AssemOut: StoreFlag = 0
                        End If
                        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        If num < 10 Then Num$ = "0" + Num$
                        A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' Save Temp_Var_NumParseCount
                    End If
                    NumArrayParseNum = NumArrayParseNum - 1
                Else
                    'Check for Numeric command  - should work similarly to a bracket
                    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFE Then ' FE = Numeric Command
                        ' FE = Numeric Command
                        index(ExpressionCount) = index(ExpressionCount) + 1
                        v = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))
                        index(ExpressionCount) = index(ExpressionCount) + 4 ' Consume the Numeric command and open bracket
                        GoSub JumpToNumericCommand
                        If negative(PE30Count) = 1 Then resultP30(PE30Count) = -resultP30(PE30Count)
                        ' Make D a negative
                        If negative(PE30Count) = 1 Then
                            ' This is a negative
                            A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AssemOut
                            A$ = "LDD": B$ = "#$0000": C$ = "Clear D": GoSub AssemOut
                            A$ = "SUBD": B$ = ",S++": C$ = "D is now NEGD, restore the stack": GoSub AssemOut
                        End If
                        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        If num < 10 Then Num$ = "0" + Num$
                        A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' Save Temp_Var_NumParseCount
                        If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) <> Chr$(&HF5) + ")" Then
                            Print "Error3: Expected closing parenthesis in";: GoTo FoundError
                        End If
                        index(ExpressionCount) = index(ExpressionCount) + 2 ' move past the close brackets
                    Else
                        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFB Then ' FB = FN Command
                            ' FB = FN Command
                            index(ExpressionCount) = index(ExpressionCount) + 1
                            v = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))
                            index(ExpressionCount) = index(ExpressionCount) + 4 ' Consume the FN command and open bracket
                            GoSub DoFN ' do the FN command
                            If negative(PE30Count) = 1 Then resultP30(PE30Count) = -resultP30(PE30Count)
                            ' Make D a negative
                            If negative(PE30Count) = 1 Then
                                ' This is a negative
                                A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AssemOut
                                A$ = "LDD": B$ = "#$0000": C$ = "Clear D": GoSub AssemOut
                                A$ = "SUBD": B$ = ",S++": C$ = "D is now NEGD, restore the stack": GoSub AssemOut
                            End If
                            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            If num < 10 Then Num$ = "0" + Num$
                            A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AssemOut ' Save Temp_Var_NumParseCount
                            If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) <> Chr$(&HF5) + ")" Then
                                Print "Error4: Expected closing parenthesis in";: GoTo FoundError
                            End If
                            index(ExpressionCount) = index(ExpressionCount) + 2 ' move past the close brackets
                        Else
                            show$ = Expression$(ExpressionCount): GoSub show
                            Print "I can't process part of the numeric expression on";: GoTo FoundError
                        End If
                    End If
                End If
            End If
        End If
    End If
End If
'Wend
Parse30_Term = resultP30(PE30Count)
'Print "Parse30_Term="; Parse30_Term, "PE30Count="; PE30Count
PE30Count = PE30Count - 1
Return

' Get the value to parse that is before the &H2C = comma,   return with Temp$ = the expression to parse
GetArrayElementB4Comma:
BracketCount = 1
Temp$ = "" 'init new expression (inside array)
CommaLoop:
i$ = Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1) ' get a byte from inside the array
index(ExpressionCount) = index(ExpressionCount) + 1 ' Keep moving it
If i$ = Chr$(&HF5) Then
    Temp$ = Temp$ + i$
    i$ = Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1) ' get a byte from inside the array
    index(ExpressionCount) = index(ExpressionCount) + 1 ' Keep moving it
    If i$ = "(" Then BracketCount = BracketCount + 1 ' if it's an open bracket then there is probably an array or numeric command
    If i$ = ")" Then BracketCount = BracketCount - 1 ' just found a close bracket, maybe the end of another array or numeric command
    If i$ = "," And BracketCount = 1 Then GoTo DoneCommaLoop ' If we find a comma and it's inside our array level then we got everything inside it
End If
Temp$ = Temp$ + i$
GoTo CommaLoop
DoneCommaLoop: ' We got the expression before the comma in the array
Temp$ = Left$(Temp$, Len(Temp$) - 1)
Return

' Get the value to parse that is before the close bracket ")",  return with Temp$ = the expression to parse
GetArrayElementB4Bracket:
BracketCount = 1
Temp$ = "" 'init new expression (inside array)
BracketLoop:
i$ = Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1) ' get a byte from inside the array
index(ExpressionCount) = index(ExpressionCount) + 1 ' Keep moving it
If i$ = Chr$(&HF5) Then
    Temp$ = Temp$ + i$
    i$ = Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1) ' get a byte from inside the array
    index(ExpressionCount) = index(ExpressionCount) + 1 ' Keep moving it
    If i$ = "(" Then BracketCount = BracketCount + 1 ' if it's an open bracket then there is probably an array or numeric command
    If i$ = ")" Then BracketCount = BracketCount - 1 ' just found a close bracket, maybe the end of another array or numeric command
    If i$ = ")" And BracketCount = 0 Then GoTo DoneBracketLoop ' If we find a bracket and it's inside our array level then we got everything inside it
End If
Temp$ = Temp$ + i$
GoTo BracketLoop
DoneBracketLoop: ' We got the expression before the bracket in the array
Temp$ = Left$(Temp$, Len(Temp$) - 1)
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

' Return with decoded command/variable in Temp$
' Tokens for variables type:
' &HF0 = Numeric Arrays           (4 Bytes)
' &HF1 = String Arrays            (3 Bytes)
' &HF2 = Regular Numeric Variable (3 Bytes)
' &HF3 = Regular String Variable  (3 Bytes)
' &HF4 = Floating Point Variable  (3 Bytes)
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets    (2 Bytes)

' &HFB = DEF FN Function
' &HFC = Operator Command (2 Bytes)
' &HFD = String Command  (3 Bytes)
' &HFE = Numeric Command (3 Bytes)
' &HFF = General Command (3 Bytes)

DecodeToken:
Temp$ = ""
If v = &HF0 Then 'Numeric Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = NumericArrayVariables$(v)
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = &HF1 Then 'String Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = StringArrayVariables$(v) + "$" ' add the $ back in to show it's a string
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = &HF2 Then 'Regular Numeric Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = NumericVariable$(v): Return
End If
If v = &HF3 Then 'Regular String Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = StringVariable$(v) + "$" ' add the $ back in to show it's a string
    Return
End If
If v = &HF4 Then 'Floating Point Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = FloatVariable$(v): Return
End If
If v = &HF5 Then ' Special Characters
    v = Array(x): x = x + 1
    If v = &H22 Then
        'We found a quote, copy everything inside the quotes to Temp$
        While v <> &HF5 ' keep copying until we get an end quote
            Temp$ = Temp$ + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        v = Array(x): x = x + 1
    End If
    Temp$ = Temp$ + Chr$(v)
    Return
End If
If v = &HFB Then ' Pointer for the label of a DEF FN command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = DefLabel$(v): Return
    Return
End If
If v = &HFC Then 'Operator Command
    v = Array(x): x = x + 1
    Temp$ = OperatorCommands$(v): Return
End If
If v = &HFD Then 'String Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = StringCommands$(v): Return
End If
If v = &HFE Then 'Numeric Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = NumericCommands$(v): Return
End If
If v = &HFF Then 'General Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = GeneralCommands$(v)
    If Temp$ = "'" Or Temp$ = "REM" Then
        Temp$ = Temp$ + " "
        Do Until v = &H0D And Array(x - 2) = &HF5 ' keep copying until we get an EOL
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
If v = &HF0 Then 'Numeric Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = NumericArrayVariables$(v)
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = &HF1 Then 'String Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = StringArrayVariables$(v) + "$" ' add the $ back in to show it's a string
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = &HF2 Then 'Regular Numeric Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = NumericVariable$(v): Return
End If
If v = &HF3 Then 'Regular String Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = StringVariable$(v) + "$" ' add the $ back in to show it's a string
    Return
End If
If v = &HF4 Then 'Floating Point Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = FloatVariable$(v): Return
End If
If v = &HF5 Then ' Special Characters
    v = Array(x): x = x + 1
    If v = &H22 Then
        'We found a quote, copy everything inside the quotes to Temp$
        While v <> &HF5 ' keep copying until we get an end quote
            Temp1$ = Temp1$ + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        v = Array(x): x = x + 1
    End If
    Temp1$ = Temp1$ + Chr$(v)
    Return
End If
If v = &HFB Then ' Pointer for the label of a DEF FN command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = DefLabel$(v): Return
    Return
End If
If v = &HFC Then 'Operator Command
    v = Array(x): x = x + 1
    Temp1$ = OperatorCommands$(v): Return
End If
If v = &HFD Then 'String Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = StringCommands$(v): Return
End If
If v = &HFE Then 'Numeric Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = NumericCommands$(v): Return
End If
If v = &HFF Then 'General Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = GeneralCommands$(v) + " "
    Return
End If
Temp1$ = Temp1$ + Chr$(v)
Return

'Convert number in Num to a string without spaces as Num$
NumAsString:
If num = 0 Then
    Num$ = "0"
Else
    If num > 0 Then
        'Postive value remove the first space in the string
        Num$ = Right$(Str$(num), Len(Str$(num)) - 1)
    Else
        'Negative value we keep the minus sign
        Num$ = Str$(num)
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
MSB = Int(num / 256)
LSB = num - MSB * 256
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

'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
FindGenCommandInExpression:
Found = 0
If Asc(Mid$(Expression$, I, 1)) = &HFF Then
    For ii = 0 To GeneralCommandsCount
        If GeneralCommands$(ii) = Check$ Then
            Exit For
        End If
    Next ii
    If Asc(Mid$(Expression$, I + 1, 1)) * 256 + Asc(Mid$(Expression$, I + 2, 1)) = ii Then
        Found = 1
    End If
End If
Return

' Evaluate the Expression in NewExpression$ and return with the numerical value in D
EvaluateNewExpression:
Num$ = ""
Expression$ = NewExpression$
GoSub DirectTokenizeExpression
GoSub NewParseExpression
Return

' Tokenize the expression into operators and operands, handling hex values
DirectTokenizeExpression:
operators$ = "+-*/\^"
valueIndex = 0
opIndex = 0
length = Len(Expression$)
I = 1
Do While I <= length
    char$ = Mid$(Expression$, I, 1)

    ' Check for unary minus
    If char$ = "-" Then
        If I = 1 Or InStr(operators$ + "(", Mid$(Expression$, I - 1, 1)) Then
            ' It's a unary minus, so treat the next number as negative
            Num$ = "-"
            I = I + 1
            char$ = Mid$(Expression$, I, 1)
        End If
    End If

    If InStr("0123456789.", char$) Then
        Num$ = Num$ + char$
        Do While I < length And InStr("0123456789.", Mid$(Expression$, I + 1, 1))
            I = I + 1
            Num$ = Num$ + Mid$(Expression$, I, 1)
        Loop
        valueIndex = valueIndex + 1
        values(valueIndex) = Val(Num$)
        Num$ = "" ' Reset for the next number
    ElseIf Mid$(Expression$, I, 2) = "&H" Then
        Num$ = "&H"
        I = I + 2
        Do While I <= length And InStr("0123456789ABCDEFabcdef", Mid$(Expression$, I, 1))
            Num$ = Num$ + Mid$(Expression$, I, 1)
            I = I + 1
        Loop
        valueIndex = valueIndex + 1
        values(valueIndex) = Val(Num$)
        I = I - 1 ' Adjust for the next loop
    ElseIf InStr(operators$, char$) Then
        ' Handle operator precedence as before
        Precedence$ = ops(opIndex)
        GoSub Precedence
        currentPrecedence = Precedence

        Precedence$ = char$
        GoSub Precedence
        nextPrecedence = Precedence

        While opIndex > 0 And currentPrecedence >= nextPrecedence
            GoSub NewApplyOperator
            valueIndex = valueIndex - 1
            values(valueIndex) = result
            opIndex = opIndex - 1

            If opIndex > 0 Then
                Precedence$ = ops(opIndex)
                GoSub Precedence
                currentPrecedence = Precedence
            End If
        Wend
        opIndex = opIndex + 1
        ops(opIndex) = char$
    ElseIf char$ = "(" Then
        opIndex = opIndex + 1
        ops(opIndex) = char$
    ElseIf char$ = ")" Then
        While ops(opIndex) <> "("
            GoSub NewApplyOperator
            valueIndex = valueIndex - 1
            values(valueIndex) = result
            opIndex = opIndex - 1
        Wend
        opIndex = opIndex - 1 ' Remove the "(" from the stack
    End If
    I = I + 1
Loop

' Apply remaining operators after processing the expression
While opIndex > 0
    GoSub NewApplyOperator
    valueIndex = valueIndex - 1
    values(valueIndex) = result
    opIndex = opIndex - 1
Wend
Return

' Parse and evaluate the tokenized expression
NewParseExpression:
' The evaluation is now handled directly in the DirectTokenizeExpression subroutine
D = values(1)
Return

' Apply the operator to two operands
NewApplyOperator:
Select Case ops(opIndex)
    Case "+"
        result = values(valueIndex - 1) + values(valueIndex)
    Case "-"
        result = values(valueIndex - 1) - values(valueIndex)
    Case "*"
        result = values(valueIndex - 1) * values(valueIndex)
    Case "/"
        result = values(valueIndex - 1) / values(valueIndex)
    Case "\"
        result = values(valueIndex - 1) \ values(valueIndex)
    Case "^"
        result = values(valueIndex - 1) ^ values(valueIndex)
End Select
Return

' Determine the precedence of operators using GOSUB
Precedence:
Select Case Precedence$
    Case "+", "-"
        Precedence = 1
    Case "*", "/", "\"
        Precedence = 2
    Case "^"
        Precedence = 3
    Case Else
        Precedence = 0
End Select
Return


' Copies start quote, the text v=&H22 (the end quote) on return
GetInQuotes:
Expression$ = Expression$ + Chr$(v) ' Copy the first quote
v = Array(x): x = x + 1
Do Until v = &H22 ' keep copying until we get an end quote
    If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then
        Print "About to error out"
        Print Hex$(x), Hex$(v)
        Print "Error2: something is wrong getting the charcters in quotes at";: GoTo FoundError
    End If
    Expression$ = Expression$ + Chr$(v)
    v = Array(x): x = x + 1
Loop
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

' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon     (Makes sure to ignore commas inside brackets like a 2 or more dimension array)
GetExB4SemiComQ13D_EOL:
Expression$ = ""
InBracket = 0
GEB4SemiComQ13D_EOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Or Sp = &H3B Or Sp = &H22 Then x = x - 2: Return ' IF EOL/Colon, semicolon, a comma or a quote then point at it again and return
    ' Make sure we are not inside brackets when we get a comma
    If Sp = &H2C And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
If Left$(GenExpression$, 1) = Chr$(&HF1) Then x = x - 4: Return 'Found a string array, point at it again and return
If Left$(GenExpression$, 1) = Chr$(&HF3) Then x = x - 3: Return 'Found a string variable, point at it again and return
If Left$(GenExpression$, 1) = Chr$(&HFD) Then x = x - 3: Return 'Found a string command, point at it again and return
Expression$ = Expression$ + GenExpression$
GoTo GEB4SemiComQ13D_EOL

'Handle an expression that ends with a comma or EOL, skip brackets
GetExpressionB4CommaEOL:
Expression$ = ""
InBracket = 0
GEB4CommaEOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If GenExpression$ = Chr$(&HF5) + Chr$(&H0D) Or GenExpression$ = Chr$(&HF5) + Chr$(&H3A) Then x = x - 2: Return ' IF EOL/Colon point at it again and return
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Then x = x - 2: Return ' IF EOL/Colon, or a quote then point at it again and return
    If Sp = &H2C And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4CommaEOL

'Handle an expression that ends with a colon or End of a Line
GetExpressionB4EOL:
Expression$ = ""
GEB4EOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If GenExpression$ = Chr$(&HF5) + Chr$(&H0D) Or GenExpression$ = Chr$(&HF5) + Chr$(&H3A) Then x = x - 2: Return ' IF EOL/Colon point at it again and return
Expression$ = Expression$ + GenExpression$
GoTo GEB4EOL

'Handle an expression that ends with a comma skip brackets
GetExpressionB4Comma:
Expression$ = ""
InBracket = 0
GEB4Comma:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Asc(Right$(GenExpression$, 1)) = &H2C And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4Comma

'Handle an expression that ends with a close bracket
GetExpressionB4EndBracket:
Expression$ = ""
InBracket = 0
GEB4EndBracket:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = Asc(")") And InBracket < 1 Then x = x - 2: Return ' If last close bracket then point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4EndBracket

'Handle an expression that ends with a colon or End of a Line or a general command like TO or STEP
GetExpressionB4EOLOrCommand:
Expression$ = ""
GEB4EOLOrCommand:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HFF) Then x = x - 3: Return 'point at the command and return
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Then x = x - 2: Return ' IF EOL/Colon then point at it again and return
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4EOLOrCommand

' Get an Expression before a semi colon, a plus, a comma a quote an EOL/Colon
GetExpressionB4SemiPlusComQ_EOL:
Expression$ = ""
GEB4SemiPlusComQ_EOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Or Sp = &H3B Or Sp = &H2C Or Sp = &H22 Then x = x - 2: Return ' IF EOL/Colon, semicolon, a comma or a quote then point at it again and return
End If
If Left$(GenExpression$, 1) = Chr$(&HFC) And Right$(GenExpression$, 1) = Chr$(&H2B) Then x = x - 2: Return 'Found a plus point at it again and return
Expression$ = Expression$ + GenExpression$
GoTo GEB4SemiPlusComQ_EOL

' Get an Expression before a semi colon, a comma or an EOL
GetExpressionB4SemiComEOL:
Expression$ = ""
GEB4SemiComEOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Or Sp = &H3B Or Sp = &H2C Then x = x - 2: Return ' IF EOL/Colon, semicolon, a comma or a quote then point at it again and return
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4SemiComEOL
'Handle an expression that ends with a comma or end bracket skipping extra brackets
GetExpressionB4CommaEndBracket:
Expression$ = ""
InBracket = 0
GEB4CommaEndBracket:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H2C And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc(")") And InBracket = 0 Then x = x - 2: Return ' If last close bracket then point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4CommaEndBracket













' Above have been updated for V2.00

























' Get an Expression before a semi colon, a comma a quote, an &HF0,&HF1,&HF2,&HF3 or &HFD an EOL
GetExB4SemiComQ0123D_EOL:
Expression$ = ""
ExType = 1
InQuote = 0
v = 0
Do Until (v = Asc(";") And Array(x - 2) < &HF0) Or (v = Asc(",") And Array(x - 2) < &HF0) Or (v = &H22 And Array(x - 2) < &HF0) Or (v = &HF1 And Array(x - 2) < &HF0)_
    Or (v = &HF2 And Array(x - 2) < &HF0)  Or (v = &HF0 And Array(x - 2) < &HF0)_
    Or (v = &HF3 And Array(x - 2) < &HF0) Or (v = &HFD And Array(x - 2) < &HF0)_
    Or (v = &HF5 And Array(x) = &H0D) Or (v = &HF5 And Array(x) = &H3A) ' do until a semi colon, a comma a " or an EOL or a Colon
    GEB4SemiComQ0123D_EOL:
    v = Array(x): x = x + 1
    If InBracket = 1 Then
        Bracket = 1
        x = x - 1
        While Bracket > 0
            v = Array(x): x = x + 1
            If v = Asc(" ") And Array(x - 2) < &HF0 Then
            Else
                Expression$ = Expression$ + Chr$(v) ' Don't copy spaces in the Expression
            End If
            If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then
                v = Array(x): x = x + 1
                ExType = 0
                GoTo DoneGetExB4SemiComQ0123D_EOL
            End If
            If v = Asc("(") And Array(x - 2) < &HF0 Then Bracket = Bracket + 1
            If v = Asc(")") And Array(x - 2) < &HF0 Then Bracket = Bracket - 1
        Wend
        InBracket = 0
    Else
        If v = Asc(" ") And Array(x - 2) < &HF0 Then
        Else
            Expression$ = Expression$ + Chr$(v) ' Don't copy spaces in the Expression
        End If
        If v = Asc("(") And Array(x - 2) < &HF0 Then InBracket = 1
    End If
Loop
DoneGetExB4SemiComQ0123D_EOL:
If Len(Expression$) > 2 Then
    If (v = &HF2 And Mid$(Expression$, Len(Expression$) - 2, 1) = Chr$(&HFC)) Then GoTo GEB4SemiComQ0123D_EOL ' We have a numeric variable in the equation, keep going
    If (v = &HF0 And Mid$(Expression$, Len(Expression$) - 2, 1) = Chr$(&HFC)) Then GoTo GEB4SemiComQ0123D_EOL ' We have a numeric array variable in the equation, keep going
End If
If v = &HF5 Then v = Array(x): x = x + 1
If ExType = 0 Then Print "Can't figure out the value here, is the ; or , or quotes in the correct place? At";: GoTo FoundError
Expression$ = Left$(Expression$, Len(Expression$) - 1) ' remove the comma
Return


' Get an Expression before a semi colon, a comma, a quote or an EOL
GetExpressionB4SemiComQ_EOL:
Expression$ = ""
ExType = 1
InQuote = 0
v = 0
Do Until (v = Asc(";") And Array(x - 2) < &HF0) Or (v = Asc(",") And Array(x - 2) < &HF0) Or (v = &H22 And Array(x - 2) < &HF0) Or (v = &HF5 And Array(x) = &H0D) Or (v = &HF5 And Array(x) = &H3A) ' do until a semi colon, a comma a " or an EOL or a Colon
    v = Array(x): x = x + 1
    If InBracket = 1 Then
        Bracket = 1
        x = x - 1
        While Bracket > 0
            v = Array(x): x = x + 1
            If v = Asc(" ") And Array(x - 2) < &HF0 Then
            Else
                Expression$ = Expression$ + Chr$(v) ' Don't copy spaces in the Expression
            End If
            If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then
                v = Array(x): x = x + 1
                ExType = 0
                GoTo DoneGetExpressionB4SemiComQ_EOL
            End If
            If v = Asc("(") And Array(x - 2) < &HF0 Then Bracket = Bracket + 1
            If v = Asc(")") And Array(x - 2) < &HF0 Then Bracket = Bracket - 1
        Wend
        InBracket = 0
    Else
        If v = Asc(" ") And Array(x - 2) < &HF0 Then
        Else
            Expression$ = Expression$ + Chr$(v) ' Don't copy spaces in the Expression
        End If
        If v = Asc("(") And Array(x - 2) < &HF0 Then InBracket = 1
    End If
Loop
If v = &HF5 Then v = Array(x): x = x + 1
DoneGetExpressionB4SemiComQ_EOL:
If ExType = 0 Then Print "Can't figure out the value here, is the ; or , or quotes in the correct place? At "; linelabel$: System
Expression$ = Left$(Expression$, Len(Expression$) - 1) ' remove the comma
Return

' Get an Expression that ends with a close bracket like RIGHT$(....)
GetExpressionWithBrackets:
Expression$ = ""
ExType = 1
InQuote = 0
v = 0
BracketCount = 0
Do Until (v = Asc(")") And Array(x - 2) < &HF0) And BracketCount = 0
    v = Array(x): x = x + 1
    If (v = Asc("(") And Array(x - 2) < &HF0) Then BracketCount = BracketCount + 1
    If (v = Asc(")") And Array(x - 2) < &HF0) Then BracketCount = BracketCount - 1
    If v = Asc("(") And Array(x - 2) < &HF0 Then Bracket = Bracket + 1
    If v = &HF5 And Array(x) = &H0D Then Print "Can't figure out the value here, is there a close bracket on this";: GoTo FoundError
    If v = Asc(" ") And Array(x - 2) < &HF0 Then
    Else
        Expression$ = Expression$ + Chr$(v) ' Don't copy spaces in the Expression
    End If
Loop
Expression$ = Left$(Expression$, Len(Expression$))
Return

' Get an Expression before a semi colon, a Plus, a quote or an EOL
GetExpressionB4SemiPlusQ_EOL:
Expression$ = ""
ExType = 1
InQuote = 0
v = 0
Do Until (v = Asc(";") And Array(x - 2) < &HF0) Or (v = Asc(",") And Array(x - 2) < &HF0) Or (v = &H22 And Array(x - 2) < &HF0) Or (v = &HF5 And Array(x) = &H0D) Or (v = &HF5 And Array(x) = &H3A) ' do until a semi colon, a comma a " or an EOL or a Colon
    v = Array(x): x = x + 1
    If InBracket = 1 Then
        Bracket = 1
        x = x - 1
        While Bracket > 0
            v = Array(x): x = x + 1
            If v = Asc(" ") And Array(x - 2) < &HF0 Then
            Else
                Expression$ = Expression$ + Chr$(v) ' Don't copy spaces in the Expression
            End If
            If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then
                v = Array(x): x = x + 1
                ExType = 0
                GoTo DoneGetExpressionB4SemiPlusQ_EOL
            End If
            If v = Asc("(") And Array(x - 2) < &HF0 Then Bracket = Bracket + 1
            If v = Asc(")") And Array(x - 2) < &HF0 Then Bracket = Bracket - 1
        Wend
        InBracket = 0
    Else
        If v = Asc(" ") And Array(x - 2) < &HF0 Then
        Else
            Expression$ = Expression$ + Chr$(v) ' Don't copy spaces in the Expression
        End If
        If v = Asc("(") And Array(x - 2) < &HF0 Then InBracket = 1
    End If
Loop
If v = &HF5 Then v = Array(x): x = x + 1
DoneGetExpressionB4SemiPlusQ_EOL:
If ExType = 0 Then Print "Can't figure out the value here, is the ; or , or quotes in the correct place? At "; linelabel$: System
' Parse the numeric expression in Epression$
' For ii = 1 To Len(Expression$): Print ii, Hex$(Asc(Mid$(Expression$, ii, 1))): Next ii
Expression$ = Left$(Expression$, Len(Expression$) - 1) ' remove the comma
Return


' Get an Expression before an AND, OR or < or = or > or THEN, return with Expression$ ready and v = the operator value
GetExpressionB4Operator:
Expression$ = ""
ExType = 1
InQuote = 0
v = 0
GetExpressionB4OperatorLoop:
v = Array(x): x = x + 1
If v = &HFC Then
    ' We found an operator
    If Array(x) > 5 And Array(x) < 11 Then
        ' We found an AND, OR or < or = or >
        v = Array(x): x = x + 1 ' should return with the actual operator command
        GoTo DoneGetExpressionB4Operator ' ready to return with the expression the way it is
    End If
End If
If v = &HFF And Array(x) = &H27 Then
    'We found THEN
    v = Array(x): x = x + 1 'consume the Then Command
    v = 0 ' signify we found a then command when we return
    GoTo DoneGetExpressionB4Operator ' ready to return with the expression the way it is
End If
If v = Asc(" ") And Array(x - 2) < &HF0 Then
Else
    Expression$ = Expression$ + Chr$(v) ' Don't copy spaces in the Expression
End If
If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then
    v = Array(x): x = x + 1
    Print "Can't find the value to compare with on";: GoTo FoundError
End If
GoTo GetExpressionB4OperatorLoop
DoneGetExpressionB4Operator:
' Parse the numeric expression in Epression$
' For ii = 1 To Len(Expression$): Print ii, Hex$(Asc(Mid$(Expression$, ii, 1))): Next ii
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



