'Print "hex$(Array(x) "; Hex$(Array(x))
'Print "hex$(Array(x+1) "; Hex$(Array(x + 1))
'Print "hex$(Array(x+2) "; Hex$(Array(x + 2))
'System

V$ = "2.11"
'       - tweaked PLAY command to handle quoted strings a little better.
'
' V2.10
'       - Added PLAY command and tweaked DRAW command so it handles ;X with a string if the DRAW command doesn't end with a semi colon
'       - Fixed a NASTY bug where certain bytes in ADDASSEM/ENDASSEM would write over actual program code
'
' V2.09
'       - Fixed a bug with INKEY$
'
' V2.08
'       - Broke some regular printing with the printing to graphics screen, this is now been fixed
'       - Fixed a bug with getting the value of an expression before an open bracket if an array was before the open bracket
'
' V2.07
'       - Fixed problem with REM or ' at the end of a line, was causing that entire line to be ignored especially if it started with a variable
'
' V2.06
'       - Fixed a bug where the compiler needed a space after the PRINT command and before the # sign as PRINT#-2 or PRINT#-1 would give an error.
'       - Added support of PRINT#-3, which prints text to the PMODE 4 screen
'       - Changed the LOCATE x,y command so it will position the PRINT #-3, cursor location on the PMODE 4 screen where x is from 0 to 31 and y is from 0 to 184
'       - Added a new commandline option -f[fontname] where the user can supply the font name to use for printing to the graphics screen.  The font must be in the folder
'         Basic_Includes/Graphic_Screen_Fonts
'         Arcade & CoCoT1 with Arcade being the default font as it is a bolder font and less likely to artifact.  The CoCoT1 font is a pixel accurate version
'         of the CoCo's 6847 T1 VDG chip.  The fonts are already compiled sprites to make them print as fast as possible.
'
' V2.05
'        - Added printing to serial port with Print #-2,
'
' Things to do:
' - Add more commands (look through CoCo Extended basic book)
' - Change variables for graphics programs so they use faster/DP RAM
' - Make the program handle array sizes intellegently, arrays of 254 or less will use the current array method, larger arrays will use 16 bit values like A(1050) or A(700,3)
' - Make draw's destination address the same as the LINE destination address so they can continue where each left off
' - Make PSET take a colour value
' - Add more grpahics resolution handling like PMODE 1,2 & 3

$ScreenHide
$Console
_Dest _Console

' Address in RAM where the compiled program starts
ProgramStart$ = "2600" ' $2600, PMODE 4 graphics screen will be from $E00 to $25FF

'Dim CommandsUsed$(2000)
' Initialize variables for processing
'Dim commands$(100)
Dim numCommands As Integer
numCommands = 0
Dim i As Integer
Dim Start As Integer
'Dim functionName$
Dim Found As Integer

Dim GeneralCommands$(200)
Dim GeneralCommandsCount As Integer
Dim NumericCommands$(200)
Dim NumericCommandsCount As Integer
Dim StringCommands$(200)
Dim StringCommandsCount As Integer
Dim OperatorCommands$(200)
Dim OperatorCommandsCount As Integer

Dim NumericVariable$(2000)
Dim NumericVariableCount As Integer
Dim StringVariable$(2000)
Dim StringVariableCounter As Integer
Dim NumericArrayVariables$(200), NumericArrayDimensions(200) As Integer, NumericArrayDimensionsVal$(200)
'Dim NumericArrayVariablesCount As Integer
Dim StringArrayVariables$(200), StringArrayDimensions(200) As Integer, StringArrayDimensionsVal$(200)
'Dim StringArrayVariablesCount As Integer

Dim GeneralCommandsFound$(200)
Dim GeneralCommandsFoundCount As Integer

Dim NumericCommandsFound$(200)
Dim NumericCommandsFoundCount As Integer
Dim StringCommandsFound$(200)
Dim StringCommandsFoundCount As Integer

Dim IncludeList$(100)
Dim var$(1000) ' variable names
Dim C$(256), C2$(256) ' Commands
Dim Array(2000000) As _Unsigned _Byte
Dim INArray(2000000) As _Unsigned _Byte
Dim DataArray(2000000) As _Unsigned _Byte
Dim DataArrayCount As Integer
Dim c(256) As _Unsigned _Byte
'Dim c2(256) As _Unsigned _Byte
'Dim arrayBackup(270000) As _Unsigned _Byte
Dim LabelName$(100000)

'Dim line$(65000)
'Dim ForCount$(100)
'Dim ForLoopsUsed$(100)
FORCount = 0
FORStackPointer = 0
Dim FORSTack(255) As Integer

'Stuff for Parsing an Expression
'Dim resultPE(300)
'Dim resultPT(300)
'Dim resultPEx(300)
'Dim resultPEx(300)
Dim negative(300)
Dim Expression$(300)
Dim ExpressionCount As Integer
Dim index(300) As Integer

'Stuff needed for strings and string commands
'Dim CMD$(25, 100), Value$(25, 100)
Dim TempName$(25)
'Dim ColDone(25) As Integer

' Need to keep track of FOR LOOPs
Dim ForJump(1000) As Integer
'Dim ForAddAmount(1000) As Integer

' Stuff for IF/THEN/ELSE/ENDIF
Dim IFSTack(100) As Integer 'If Stack
Dim ElseStack(100) As Integer ' Else Stack
Dim ELSELocation(100) As Integer 'Flag if the IF has an ELSE

' Needed to keep track of the proper WHILE/WEND
WhileCount = 0
WhileStackPointer = 0
Dim WHILEStack(255) As Integer
' Neede to keep track of the proper DO/LOOP
DOCount = 0
DOStackPointer = 0
Dim DOStack(255) As Integer

' Stuff needed for Testing values with IF THEN or WHILE WEND
'Dim Shared Token(100) As String
'Dim Shared TokenType(100) As String
'Dim Shared TokenCount As Integer
'Dim Shared CurrentToken As Integer

Dim Shared valueStack(100) As Integer
Dim Shared valueStackTop As Integer
Dim Shared operatorStack(100) As Integer
Dim Shared operatorStackTop As Integer

Dim Shared leftOperand As Integer, rightOperand As Integer, result As Integer
'Dim OperandValue As Integer
Dim Shared operator As Integer
Dim Shared OperatorPrecedence As Integer, TokenPrecedence As Integer
Dim ExpressionFound$(500)
Dim DefLabel$(255)
Dim DefVar(255) As Integer
DefLabelCount = 0
DefVarCount = 0

HighestTemp = 0 ' Counter for how many Temp strings we will need
For x = 1 To 25
    TempName$(x) = "TEMP" + Right$("0" + Right$(Str$(x), Len(Str$(x)) - 1), 2)
Next x

' Handle command line options
FI = 0
count = _CommandCount
If count = 0 Then
    HelpMessage:
    Print "BasTo6809 - BASIC to 6809 Assembly converter V"; V$; " By Glen Hewlett - https://github.com/nowhereman999/BASIC-To-6809"
    Print
    Print "Takes a BASIC program and converts it to 6809 Assembly Language that can be assembled with LWASM"
    Print "The output from LWASM can then be executed on a TRS-80 Color Computer"
    Print
    Print "Usage: BasTo6809 [-coco] [-ascii] [-sxxx] [-ox] [-bx] [-pxxxx] [-v] [-Vx] [-k] [-fxxxx] [-h] program.bas"
    Print "Where: program.bas is the basic program you want to convert to assembly language"
    Print "       outputs program.asm which is ready to be used with LWASM to convert it to a machine language program for the CoCo"
    Print "       It will autodetect a coco program or ASCII file but just in case the detection is not working you can manually"
    Print "       set the input type wit the -coco or -ascii options"
    Print "       -coco     - A regular tokenized Color Computer BASIC program"
    Print "       -ascii    - A plain text BASIC program in regular ASCII, from a text editor or a program like QB64"
    Print "       -sxxx     - Sets the max length to reserve for strings in an array (default and max is 255 bytes)"
    Print "                   If your program needs more space and you aren't using larger strings this option"
    Print "                   can make your program use a lot less RAM"
    Print "       -ox       - Optimize level x (default is 2), 2 is the max value, 0 will turn off optimizing (not suggested)"
    Print "       -bx       - Optimize branch lengths; this affects how fast and efficiently LWASM will assemble your program."
    Print "                   0 means some branches will be longer than they need to be resulting in a larger/slower program (default)"
    Print "                   1 means all branches will be as short as possible making your program smaller and faster, but"
    Print "                   LWASM will take a long time to assemble your program"
    Print "       -pxxxx    - Program starting location in RAM, xxxx = address in hexidecimal"
    Print "       -v        - Show the version number for this compiler"
    Print "       -Vx       - Verbose level x (default is 0 = no output while compiling)"
    Print "       -k        - Keep miscelaneus files generated by the compiler (default is erase files and only leave the .asm file)"
    Print "       -fxxxx    - Where xxxx is the font name used for printing to the PMODE 4 screen (default is Arcade)"
    Print "                   Look in folder Basic_Includes/Graphic_Screen_Fonts to see font names available"
    Print "       -h        - Show this help message"
    Print
    Print "See BasTo6809.txt file for more help"
    System
End If
nt = 0: newp = 0: endp = 0: BranchCheck = 0: StringArraySize = 255: KeepTempFiles = 0
Optimize = 2 ' Default to optimize level 2
Font$ = "Arcade" ' Default font to use for graphics screen
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 5)) = "-coco" Then BASICMode = 1: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 6)) = "-ascii" Then BASICMode = 3: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-s" Then StringArraySize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-o" Then Optimize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-b" Then BranchCheck = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If Left$(N$, 2) = "-V" Then Verbose = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-p" Then ProgramStart$ = Right$(N$, Len(N$) - 2): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-k" Then KeepTempFiles = 1: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-f" Then Font$ = Right$(N$, Len(N$) - 2): GoTo CheckNextCMDOption
    If Left$(N$, 2) = "-v" Then
        ' Show the Version number and exit
        Print "BasTo6809 - BASIC to 6809 Assembly converter V"; V$
        System
    End If
    If LCase$(Left$(N$, 2)) = "-h" Then
        ' Show Help Screen and exit
        GoTo HelpMessage
    End If
    ' check if we got a file name yet if so then the next filename will be output
    If FI > 0 Then Fname$ = N$: GoTo CheckNextCMDOption
    FI = 1
    Fname$ = N$
    Open Fname$ For Append As #1
    length = LOF(1)
    Close #1
    If length < 1 Then Print "Error file: "; Fname$; " is 0 bytes. Or doesn't exist.": Kill Fname$: System
    If Verbose > 0 Then Print "Length of Input file in bytes:"; length
    Open Fname$ For Binary As #1
    Get #1, , INArray()
    Close #1
    CheckNextCMDOption:
Next check
If LCase$(Right$(Font$, 4)) = ".asm" Then Font$ = Left$(Font$, Len(Font$) - 4) ' remove .asm from font name (if the user supplied it)
Open "Basic_Includes/Graphic_Screen_Fonts/" + Font$ + ".asm" For Append As #1
FontLength = LOF(1)
Close #1
If FontLength < 1 Then
    Print "Error font file: "; Font$; " doesn't exist."
    Kill "Basic_Includes/Graphic_Screen_Fonts/" + Font$ + ".asm"
    Print "Fonts available are:"
    Filelist$ = _Files$("Basic_Includes/Graphic_Screen_Fonts/")
    Do While Len(Filelist$) > 0
        If LCase$(Right$(Filelist$, 4)) = ".asm" Then
            Print Left$(Filelist$, Len(Filelist$) - 4)
        End If
        Filelist$ = _Files$
    Loop
    System
End If

If BASICMode = 0 Then
    ' Let's detect the input filetype
    v = INArray(0): If v = &HFF Then BASICMode = 1
End If

OutName$ = Left$(Fname$, Len(Fname$) - 4) + ".asm"
If Verbose > 0 Then
    If BASICMode = 1 Then Print "Processing a CoCo Tokenized BASIC file"
    If BASICMode = 2 Then Print "Processing a CoCo BASIC text file"
    If BASICMode = 3 Then Print "Processing a regular text ASCII formatted file"
    Print "BASIC program: "; Fname$
    Print "Output filename is: "; OutName$
End If

If StringArraySize < 1 Or StringArraySize > 255 Then Print "String Array size option of"; StringArraySize; "is out of range. Must be between 1 and 255": System

PTCount = 0
PExCount = 0
PE30Count = 0
NumParseCount = 0
StrParseCount = 0
ExpressionCount = 0
IfCount = 1

If BASICMode = 1 Then
    Print "DeTokenizing CoCo BASIC program"
    GoSub FillCommandArray ' Get the commands and extended commands in C$() & C2$()
    x = 0
    v = INArray(x): x = x + 1
    If v <> &HFF Then Print "Error, not a tokenized CoCo BASIC program": System
    size = INArray(x) * 256 + INArray(x + 1): x = x + 2
    HighestStringCount = 0
    y = 0
    Array(y) = &H0D: y = y + 1 ' Start with an End Of Line
    While x + 3 < size
        v = INArray(x): x = x + 1 'ignore memory location MSB for new line
        v = INArray(x): x = x + 1 'ignore memory location LSB for new line
        num = INArray(x) * 256: x = x + 1 'get MSB line number for new line
        num = num + INArray(x): x = x + 1 'get LSB line number for new line
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        For i = 1 To Len(Num$)
            Array(y) = Asc(Mid$(Num$, i, 1)): y = y + 1
        Next i
        Array(y) = &H20: y = y + 1 ' Add a space after the line number
        qflag = 0 ' Flag within a quote off, this is because the CoCo's text within quotes isn't exactly ASCII
        GetFirstByte:
        v = INArray(x): x = x + 1
        If v = &H3A Then GoTo GetFirstByte 'skip colons at the beginning of a line
        While v <> 0 ' copy until we get to the end of a line
            GoSub ExpandTokens
        Wend
        Array(y) = &H0D: y = y + 1 ' Add an End Of Line
        q = 0
    Wend
    length = y
    GoTo ProgramIsNowText
    ExpandTokens:
    ParseTokenExpression:
    GoSub ParseTokenCommand
    While v <> 0 And v < &H80 ' while v<>0 or a colon
        If v = &H22 Then
            ' Found a quote
            q = q + 1
            If (q And 1) = 1 Then
                ' Found an odd quote therefore not in a quote
                If Array(y - 1) <> &H20 Then
                    Array(y) = &H20: y = y + 1 ' add a space before the quote
                End If
            End If
        End If
        Array(y) = v: y = y + 1 ' write a byte
        v = INArray(x): x = x + 1 'get next byte
    Wend
    Return
    ParseTokenCommand:
    If v = &HFF Then ' do we have an extended command?
        'Deal with extended Commands
        v = INArray(x): x = x + 1 'get next byte which is the extended command
        Temp$ = C2$(v)
        '      Array(y) = &H20: y = y + 1 ' Add a space
        For i = 1 To Len(Temp$)
            v = Asc(Mid$(Temp$, i, 1))
            Array(y) = v: y = y + 1 ' write a byte
        Next i
        '   If v = &H93 Then GoTo NoOtherValue 'MEM
        v = INArray(x): x = x + 1 'get next byte
        GoSub ParseTokenExpression
    Else
        If v >= &H80 Then
            Temp$ = C$(v)
            If v = &H81 Then
                'We found a GO
                v = INArray(x): x = x + 1
                If v = &HA5 Then Temp$ = " GOTO ": GoTo FoundGo
                If v = &HA6 Then Temp$ = " GOSUB ": GoTo FoundGo
                Print "Error detokenizing, found a GO but no TO or SUB on line:"; num: System
                FoundGo:
            End If
            If v = &HB3 Then
                ' we found an = (check for a dot after the = change it to 0)
                i = x
                While INArray(x) = &H20: x = x + 1: Wend 'skip any spaces
                If INArray(x) = &H2E Then
                    Temp$ = "= 0": x = x + 1 ' change it to zero and move past the dot
                Else
                    x = i
                End If
            End If
            '       Array(y) = &H20: y = y + 1 ' Add a space
            For i = 1 To Len(Temp$)
                v = Asc(Mid$(Temp$, i, 1))
                Array(y) = v: y = y + 1 ' write a byte
            Next i
            v = INArray(x): x = x + 1 'get next byte
            GoSub ParseTokenExpression
        End If
    End If
    Return
Else
    ' BASICMode is <> 1 copy the input INArray to array adding a space after each set of quotes
    x = 0: q = 0
    For i = 0 To length - 1
        v = INArray(i)
        Array(x) = v: x = x + 1
        If v = &H0D Or v = &H0A Then q = 0 ' if at an EOL then reset the quote counter
        If v = &H22 Then
            ' Found a quote
            q = q + 1
            If (q And 1) = 0 Then
                ' Found an end quote add a space after it
                Array(x) = &H20: x = x + 1
            End If
        End If
    Next i
    length = x
End If
ProgramIsNowText:
' Reduce multiple spaces outside of quotes to single spaces
' Add code to ignore lines between ADDASSEM / ENDASSEM

'Strip any extra spaces off the end of every line
c = 0: x = 0
Temp$ = ""
While x <= length - 1
    v = Array(x): x = x + 1
    If v = &H0D Or v = &H0A Then
        ' We've reached the end of the line
        'skip any extra EOL/LineFeeds
        While Array(x) = &H0D Or Array(x) = &H0A
            x = x + 1
        Wend
        ii = Len(Temp$)
        While ii > 0
            If Mid$(Temp$, ii, 1) = " " Then ii = ii - 1 Else Exit While
        Wend
        If ii <> 0 Then
            'Copy line to INArray
            For i = 1 To ii
                INArray(c) = Asc(Mid$(Temp$, i, 1)): c = c + 1
            Next i
            INArray(c) = &H0D: c = c + 1
        End If
        Temp$ = ""
    Else
        Temp$ = Temp$ + Chr$(v)
    End If
Wend
If Temp$ <> "" Then
    Temp$ = Temp$ + Chr$(&H0D)
    For i = 1 To Len(Temp$)
        INArray(c) = Asc(Mid$(Temp$, i, 1)): c = c + 1
    Next i
End If
If INArray(c - 1) <> &H0D Then INArray(c) = &H0D: c = c + 1
length = c

' BASICMode is <> 1 copy the input INArray to array
For i = 0 To length - 1
    Array(i) = INArray(i)
Next i

' Erase double or more spaces and double or more colons
i = 0: n = 0
q = 0
EraseExtraSpacesColons:
While n < length
    y = n
    ' get a line and look for ADDASSEM
    Temp$ = "": c = 0
    While n <= length And c <> &H0D
        c = Array(n): n = n + 1
        Temp$ = Temp$ + Chr$(c)
    Wend
    If InStr(Temp$, "ADDASSEM") > 0 Then
        ' This line is an ADDASSEM line, copy everything as it is until we get to an ENDASSEM line
        'Copy Top line
        n = y
        CopyAssemCodeAsIs:
        Temp$ = "": c = 0
        While n <= length And c <> &H0D
            c = Array(n): n = n + 1
            Temp$ = Temp$ + Chr$(c)
        Wend
        For ii = 1 To Len(Temp$)
            Array(i) = Asc(Mid$(Temp$, ii, 1)): i = i + 1
        Next ii
        If InStr(Temp$, "ENDASSEM") > 0 Then GoTo EraseExtraSpacesColons 'Copied the last line
        GoTo CopyAssemCodeAsIs
    Else
        n = y
        c = Array(n)
        While n < length And c <> &H0D
            c = Array(n)
            Array(i) = c
            If c = &H22 Then q = q + 1 ' Found a quote
            If (q And 1) = 0 Then
                '  Not in a Quote
                If c = Asc(" ") Then
                    ' Found a space and not in a quote
                    n = n + 1
                    While Array(n) = Asc(" ")
                        n = n + 1 ' skip the spaces
                    Wend
                    n = n - 1
                End If
                If c = Asc(":") Then
                    'Found a colon
                    q = 0
                    While Array(n) = Asc(":")
                        n = n + 1 ' skip extra colons
                    Wend
                    n = n - 1
                End If
            End If
            n = n + 1
            i = i + 1
        Wend
        q = 0
    End If
Wend
length = i

' We now have the BASIC program as a text file in array() size is from 0 to length-1
' Format program so it has spaces where it needs them to be:
c = 0: x = 0
InQuote = 0
KeepLooking:
While x <= length - 1
    ' read a full line
    y = x
    Temp$ = ""
    v = Array(x): x = x + 1
    While x <= length - 1 And v <> &H0D
        Temp$ = Temp$ + Chr$(v)
        v = Array(x): x = x + 1
    Wend
    Temp$ = Temp$ + Chr$(&H0D)
    p = InStr(Temp$, "ADDASSEM")
    If p > 0 Then
        ' Found an addassem
        For ii = 1 To Len(Temp$)
            INArray(c) = Asc(Mid$(Temp$, ii, 1)): c = c + 1
        Next ii
        'copy lines unaltered until we get an ENDASSEM
        REM_AddCode:
        Temp$ = ""
        v = Array(x): x = x + 1
        While v <> &H0D
            Temp$ = Temp$ + Chr$(v)
            v = Array(x): x = x + 1
            ' If x > length - 1 Then Print "WHAT!": System
        Wend
        Temp1$ = ""
        For ii = 1 To Len(Temp$)
            T1 = Asc(Mid$(Temp$, ii, 1))
            If T1 <> &H0D Then Temp1$ = Temp1$ + Mid$(Temp$, ii, 1)
        Next ii
        Temp$ = Temp1$ + Chr$(&H0D)
        ' Check if this line is the last
        p = InStr(Temp$, "ENDASSEM")
        If p = 0 Then
            For ii = 1 To Len(Temp$)
                INArray(c) = Asc(Mid$(Temp$, ii, 1)): c = c + 1
            Next ii
            GoTo REM_AddCode
        End If
        Temp$ = "' ENDASSEM:" + Chr$(&H0D)
        For ii = 1 To Len(Temp$)
            INArray(c) = Asc(Mid$(Temp$, ii, 1)): c = c + 1
        Next ii
        GoTo KeepLooking ' check for more ADDASSEMs
    Else
        x = y
    End If

    v = Array(x): x = x + 1
    If v = &H22 Then
        INArray(c) = v: c = c + 1 ' Copy the open quote
        v = Array(x): x = x + 1
        ' Copy all until we find another quote or end of line
        While v <> &H0D And v <> &H0A And v <> &H22
            INArray(c) = v: c = c + 1 ' Copy the open quote
            v = Array(x): x = x + 1
        Wend
        If v <> &H22 Then
            'Not a quote to end this string, add one
            INArray(c) = &H22: c = c + 1 ' add a close quote
        End If
    Else
        For ii = 1 To OperatorCommandsCount
            If Len(OperatorCommands$(ii)) = 1 Then
                T = Asc(Left$(OperatorCommands$(ii), 1))
                If v = T Then
                    'Make sure there is a space before and after the equal sign
                    If INArray(c - 1) <> Asc(" ") Then
                        ' no space before, add a space
                        INArray(c) = Asc(" "): c = c + 1
                    End If
                    'See if there will be a space after the =
                    If Array(x) <> Asc(" ") Then
                        ' No Space after, add one
                        INArray(c) = T: c = c + 1
                        v = Asc(" ")
                    End If
                End If
            End If
        Next ii
        ' Check for a comma and add a space in before and after
        If v = Asc(",") Then
            'Make sure there is a space before and after the comma
            If INArray(c - 1) <> Asc(" ") Then
                ' no space before, add a space
                INArray(c) = Asc(" "): c = c + 1
            End If
            'See if there will be a space after the comma
            If Array(x) <> Asc(" ") Then
                ' No Space after, add one
                INArray(c) = Asc(","): c = c + 1
                v = Asc(" ")
            End If
        End If
        ' Check for a semicolon and add a space in before and after
        If v = Asc(";") Then
            'Make sure there is a space before and after the semicolon
            If INArray(c - 1) <> Asc(" ") Then
                ' no space before, add a space
                INArray(c) = Asc(" "): c = c + 1
            End If
            'See if there will be a space after the semicolon
            If Array(x) <> Asc(" ") Then
                ' No Space after, add one
                INArray(c) = Asc(";"): c = c + 1
                v = Asc(" ")
            End If
        End If
        ' Check for an apostrophe and add a space before and after
        If v = Asc("'") Then
            'Make sure there is a space before and after the apostrophe
            If c > 0 Then
                If INArray(c - 1) <> Asc(" ") Then
                    ' no space before, add a space
                    INArray(c) = Asc(" "): c = c + 1
                End If
            Else
                INArray(c) = Asc(" "): c = c + 1
            End If
            'See if there will be a space after the apostrophe
            If Array(x) <> Asc(" ") Then
                ' No Space after, add one
                INArray(c) = Asc("'"): c = c + 1
                v = Asc(" ")
            End If
        End If
    End If
    INArray(c) = v: c = c + 1
Wend

'Now that it's formatted copy INArray to array
INArray(c) = &H0D ' Make last byte of the file an Enter
length = c
For i = 0 To length
    Array(i) = INArray(i)
Next i

If Verbose > 2 Then
    ' Let's print the current program listing:
    For i = 0 To length - 1
        If Array(i) = &H0D Then Print
        If Verbose = 3 Then Print Chr$(Array(i));
        If Verbose > 3 Then Print Hex$(Array(i)); " ";
    Next i
    Print
End If

filesize = length - 1
ReDim LastOutArray(filesize) As _Unsigned _Byte
c = 0
For Op = 0 To filesize
    LastOutArray(c) = Array(Op): c = c + 1
Next Op
If _FileExists("BASIC_Text.bas") Then Kill "BASIC_Text.bas"
If Verbose > 0 Then Print "Writing to file "; "BASIC_Text.bas"
Open "BASIC_Text.bas" For Binary As #1
Put #1, , LastOutArray()
Close #1

num = BASICMode: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
c$ = " -c" + Num$ + " "
num = StringArraySize: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
s$ = " -s" + Num$ + " "
num = Optimize: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
o$ = " -o" + Num$ + " "
num = BranchCheck: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
b$ = " -b" + Num$ + " "
num = Verbose: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
Verbose$ = " -v" + Num$ + " "
p$ = " -p" + ProgramStart$ + " "
f$ = "-f" + Font$ + " "

If KeepTempFiles = 1 Then KeepTempFiles$ = " -k " Else KeepTempFiles$ = ""
' We now have the BASIC program in a good text format as the file BASIC_Text.bas
' Tokenize the BASIC Program
CompilerVersion$ = _OS$
If InStr(CompilerVersion$, "[MACOSX]") > 0 Or InStr(CompilerVersion$, "[LINUX]") > 0 Then
    Shell "./BasTo6809.1.Tokenizer " + c$ + s$ + o$ + b$ + Verbose$ + p$ + f$ + OutName$
    ' We now have the BASIC program in a good tokenized format as the file BasicTokenized.bin
    ' Call the compiler with a few command line options to pass through to the compiler
    Shell "./BasTo6809.2.Compile " + c$ + s$ + o$ + b$ + Verbose$ + KeepTempFiles$ + OutName$
Else
    Shell ".\BasTo6809.1.Tokenizer.exe " + c$ + s$ + o$ + b$ + Verbose$ + p$ + f$ + OutName$
    ' We now have the BASIC program in a good tokenized format as the file BasicTokenized.bin
    ' Call the compiler with a few command line options to pass through to the compiler
    Shell ".\BasTo6809.2.Compile.exe " + c$ + s$ + o$ + b$ + Verbose$ + KeepTempFiles$ + OutName$
End If
System


FillCommandArray: ' Main Commands
C$(&H80) = "FOR "
C$(&H81) = "GO"
C$(&H82) = "REM "
C$(&H83) = "' "
C$(&H84) = " ELSE "
C$(&H85) = "IF "
C$(&H86) = "DATA "
C$(&H87) = "PRINT "
C$(&H88) = "ON "
C$(&H89) = "INPUT "
C$(&H8A) = "END"
C$(&H8B) = "NEXT "
C$(&H8C) = "DIM "
C$(&H8D) = "READ "
C$(&H8E) = "RUN "
C$(&H8F) = "RESTORE "
C$(&H90) = "RETURN "
C$(&H91) = "STOP "
C$(&H92) = "POKE "
C$(&H93) = "CONT "
C$(&H94) = "LIST "
C$(&H95) = "CLEAR "
C$(&H96) = "NEW "
C$(&H97) = "CLOAD "
C$(&H98) = "CSAVE "
C$(&H99) = "OPEN "
C$(&H9A) = "CLOSE "
C$(&H9B) = "LLIST "
C$(&H9C) = "SET"
C$(&H9D) = "RESET"
C$(&H9E) = "CLS "
C$(&H9F) = "MOTOR "
C$(&HA0) = "SOUND "
C$(&HA1) = "AUDIO "
C$(&HA2) = "EXEC "
C$(&HA3) = "SKIPF "
C$(&HA4) = "TAB("
C$(&HA5) = " TO "
C$(&HA6) = "SUB "
C$(&HA7) = " THEN "
C$(&HA8) = " NOT "
C$(&HA9) = " STEP "
C$(&HAA) = " OFF "
C$(&HAB) = " + "
C$(&HAC) = " - "
C$(&HAD) = " * "
C$(&HAE) = " / "
C$(&HAF) = " ^ "
C$(&HB0) = " AND "
C$(&HB1) = " OR "
C$(&HB2) = " > "
C$(&HB3) = " = "
C$(&HB4) = " < "
C$(&HB5) = "DEL "
C$(&HB6) = "EDIT "
C$(&HB7) = "TRON "
C$(&HB8) = "TROFF "
C$(&HB9) = "DEF "
C$(&HBA) = "LET "
C$(&HBB) = "LINE"
C$(&HBC) = "PCLS "
C$(&HBD) = "PSET"
C$(&HBE) = "PRESET"
C$(&HBF) = "SCREEN"
C$(&HC0) = "PCLEAR"
C$(&HC1) = "COLOR "
C$(&HC2) = "CIRCLE"
C$(&HC3) = "PAINT"
C$(&HC4) = "GET"
C$(&HC5) = "PUT"
C$(&HC6) = "DRAW"
C$(&HC7) = "PCOPY"
C$(&HC8) = "PMODE "
C$(&HC9) = "PLAY"
C$(&HCA) = "DLOAD"
C$(&HCB) = "RENUM"
C$(&HCC) = "FN"
C$(&HCD) = "USING"
C$(&HCE) = "DIR "
C$(&HCF) = "DRIVE "
C$(&HD0) = "FIELD "
C$(&HD1) = "FILES "
C$(&HD2) = "KILL"
C$(&HD3) = "LOAD"
C$(&HD4) = "LSET"
C$(&HD5) = "MERGE"
C$(&HD6) = "RENAME"
C$(&HD7) = "RSET"
C$(&HD8) = "SAVE"
C$(&HD9) = "WRITE "
C$(&HDA) = "VERIFY"
C$(&HDB) = "UNLOAD"
C$(&HDC) = "DSKINI"
C$(&HDD) = "BACKUP"
C$(&HDE) = "COPY"
C$(&HDF) = "DSKI$"
C$(&HE0) = "DSKO$"
' Extended commands after $FF
C2$(&H80) = " SGN"
C2$(&H81) = " INT"
C2$(&H82) = " ABS"
C2$(&H83) = " USR"
C2$(&H84) = " RND"
C2$(&H85) = " SIN"
C2$(&H86) = " PEEK"
C2$(&H87) = " LEN"
C2$(&H88) = " STR$"
C2$(&H89) = " VAL"
C2$(&H8A) = " ASC"
C2$(&H8B) = " CHR$"
C2$(&H8C) = " EOF "
C2$(&H8D) = " JOYSTK"
C2$(&H8E) = " LEFT$"
C2$(&H8F) = " RIGHT$"
C2$(&H90) = " MID$"
C2$(&H91) = " POINT"
C2$(&H92) = " INKEY$"
C2$(&H93) = " MEM"
C2$(&H94) = " ATN"
C2$(&H95) = " COS"
C2$(&H96) = " TAN"
C2$(&H97) = " EXP"
C2$(&H98) = " FIX"
C2$(&H99) = " LOG"
C2$(&H9A) = " POS"
C2$(&H9B) = " SQR"
C2$(&H9C) = " HEX$"
C2$(&H9D) = " VARPTR"
C2$(&H9E) = " INSTR"
C2$(&H9F) = " TIMER"
C2$(&HA0) = " PPOINT"
C2$(&HA1) = " STRING$"
C2$(&HA2) = " CVN"
C2$(&HA3) = " FREE"
C2$(&HA4) = " LOC"
C2$(&HA5) = " LOF"
C2$(&HA6) = " MKN$"
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

