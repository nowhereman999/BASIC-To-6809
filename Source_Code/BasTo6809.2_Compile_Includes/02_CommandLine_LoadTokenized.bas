' Handle command line options
FI = 0
count = _CommandCount
If count = 0 Then
    Print "Compiler has no options given to it"
    System
End If
nt = 0: newp = 0: endp = 0: StringArraySize = 255: KeepTempFiles = 0: AutoStart = 0
Optimize = 2 ' Default to optimize level 2
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 2)) = "-c" Then BASICMode = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-s" Then StringArraySize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-o" Then Optimize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-v" Then Verbose = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-k" Then KeepTempFiles = 1: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-a" Then AutoStart = 1: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-r" Then Ret2Basic = 1: GoTo CheckNextCMDOption
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
Open FName$ For Binary As #1
Get #1, , Array()
Close #1


DoingSprites = 0
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
    Input #1, NumericArrayBits(NumericArrayVarsUsedCounter)
    NumericArrayVarsUsedCounter = NumericArrayVarsUsedCounter + 1
Wend
Close #1
StringArrayVarsUsedCounter = 0
Open "StringArrayVarsUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, StringArrayVariables$(StringArrayVarsUsedCounter)
    Input #1, StringArrayDimensions(StringArrayVarsUsedCounter)
    Input #1, StringArrayBits(StringArrayVarsUsedCounter)
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
'Get info from this file about the CoCo3 and if sprites are used
Open "SpritesUsed.txt" For Input As #1
Input #1, CoCo3
Input #1, Sprites
If Sprites = 1 Then
    For I = 0 To 31
        Input #1, Sprite$(I)
        Input #1, SpriteNumberOfFrames(I)
        Input #1, SpriteHeight(I) ' Record the sprite height
    Next I
End If
Close #1
'Get info from this file about the CoCo3 and if samples are used
Open "SamplesUsed.txt" For Input As #1
Input #1, CoCo3
Input #1, Samples
If Samples = 1 Then
    For I = 0 To 31
        Input #1, Sample$(I)
        Input #1, SampleStart(I)
        Input #1, SampleStartBlock(I)
        Input #1, SampleNumberOfBLKs(I)
        Input #1, SampleLength(I)
    Next I
End If
Close #1
