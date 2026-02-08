V$ = "5.00"
'       - Tons of changes internally
'       - Fully supports all Variable Types, Variable default to Single (Fast floating point format), to maximize speed and size
'         of your program you must assign variable types to their minimum size and accuracy needed.
'       - Added WIDTH 40, WIDTH 64, WIDTH 80

' V 4.43b
'       - Fixed a bug in the cc1sl program

' V 4.43
'       - Added support for the CoCoMP3 hardware (many commands, read the manual for more info)

' V 4.42
'       - Added support for AUDIO ON|OFF and MOTOR ON|OFF

' V 4.41
'       - Added the DRAW command for all graphics modes including the semi-graphics modes
'       - Improved the handling of single line IF commands that have THEN or ELSE with a line number and not a GOTO line number
'       - Fixed POKE command so it can now handle math funxtions directly for both the address and the value to poke
'       - Fixed a bug with LINE command with horizontal lines with two colours, depending on the offset it could draw the line smaller
'         than it should be
'       - Updated SDECB.bas IDE to ignore TIMER, it can now be treated as a variable to be set just as on Extended Color BASIC

' V 4.40
'       - Added -dragon option, which will output a compiled program that will work for the Dragon computers keyboard layout instead of the CoCo keyboard layout
'       - Now if coco1/2 or dragon mode, and no drive the NMI IRQ is set to RTI

' V 4.39
'       - Fixed SCREEN and GMODE commands so that the graphic screen is only shown with the SCREEN 1 command now and pointers for screen
'         locations are set properly
'       - Fixed an issue with IF/THEN/ELSE in certain conditions

' V 4.38
'       - Tweaked the COPYBLOCKS command, if there is a 6309 in the CoCo it will use TFM to do the copy (way faster)
'       - Fixed a bug where the SCREEN command wasn't going back to text mode or graphics mode when sprites are being used

' V 4.37
'       - Added TRIM$,LTRIM$ & RTRIM$ commands that will remove the spaces in a string
'       - Fixed a bug where the IRQ wasn't being set properly if you used PLAY and a CoCo 3 GMODE

' V 4.36
'       - Added command CPUSPEED # where # is 1 for .895 Mhz, 2 for 1.79 Mhz, 3 for 2.8636 MHz and anything else will
'         set the speed to max for that computer's hardware.  Which also will put a 6309 in native mode.
'       - Added command COPYBLOCKS, which copies 8k blocks using stack blasting useful for CoCo3 copying from buffer 0 to buffer 1
'       - Fix a bug with deep IF/THEN/ELSE layers that could exit to the wrong location
'       - Tweaked the DIV16 & DIV16Rounding code so that the resulting value in D will be reflected in the condition codes when exiting the
'         routine

' V 4.35
'       - Fixed a problem with handling DATA statements that had many comma's in a row like (DATA "THIS",,,2,,)

' V 4.34
'       - Can now handle 10000 IF/THEN/ELSE commands per program, was previously set at 100
'       - Fixed a bug detecting string array variables
'       - Made STRING$ function now handle ascii codes instead of only string values for the 2nd value in the command
'       - Fixed a bug with MID$
'       - can now handle 1000 deep expression comparisons, was limited to 10 previously
'       - Fixed a bug with IF/THEN/ELSE where compiler could re-use the same labels
'       - Fixed a bug with numeric arrays with one element (wasn't pointing at the correct RAM location)
'       - Fixed a bug with the SDC_GETCURDIR$ command
'       - Fixed a bug with the PLAY command (IRQ was returning to the wrong location)
'       - PLAY command now automatically plays at normal speed then automatically speeds up the CoCo after playing

' V 4.33
'       - If your CoCo 3 can support 2.8 Mhz high speed the compiled code now runs at triple speed (2.8 Mhz)
'         for most operations (not disk, etc.)

' V 4.32
'       - Added new command SDC_BIGLOADM, for fast loading the CoCo 3 memory banks, useful for loading game backgrounds or
'         Other large amounts for data
'       - Added support for Drive number 0 or 1 for the SDC_Play commands

' V 4.31
'       - Fixed a bug in the SDC_LOADM command that wasn't loading from drive # 0 properly

' V4.30
'       - Fixed a couple bugs with the LOADM command (wasn't finding the last granule properly if the file used granules beyond $40)

' V4.29
'       - Added support for the NTSC composite video out modes (256 colours) for the CoCo3, these are new GMODE values from 160 to 165 - See the updated manual for more info
'       - Added new command NTSC_FONTCOLOURS b,f to set the background and foreground colours of the fonts used with the new NTSC composite output GMODEs

' V4.25
'       - Fixed a bug with with using numeric commands like RNDZ(x) before an close bracket of a graphics command like SET(x,y,RNDZ(3))

' V4.24
'       - Fixed a bug in the compiler when it was assigning the value of an equation to a variable.  If the equation didn't have a
'         variable and it was doing AND, OR, XOR or MOD it was not setting the variable properly.  It also wasn't handling HEX values
'         properly in this same routine.

' V4.23
'       - Made the Tokenizer a little more robust, it now detects array names better if there aren't spaces before the array name and
'         the array is being used in an equation.

' V4.22
'       - Fixed a bug with large BASIC programs especially if it used a large amount of space for the ADDASSEM: section

' V4.21
'       - Fixed a bug where the PROGRAM start was not being setup to the correct address when GMODE was being used.  Thanks to
'         Tazman (Scott Cooper) for finding the bug.

' V4.20
'       - Fixed a bug in GMODE 1 graphic commands (This mode only supprts two colours, not 9 like GMODE 0)
'       - Added printing to the screen using the semi-graphic modes, the sime graphics modes use the built in VDG font except for GMODE 4
'       - which uses SG6 and the built in fonts aren't supported in the this mode.  So the font that is shown is a large 6x6 matrix font.
'       - Now every GMODE can now print text on the screen using LOCATE x,y:PRINT #-3,"Hello World"

' V4.11
'       - Can now handle MID$(String,Start) which will copy the String starting at location Start copying the rest of the string.  It no
'         longer needs to be MID$(String,Start,Length).

' V4.10 - Added text fonts that can be used directly in any graphics mode, use LOCATE x,y and PRINT #-3,"Hello World" to print
'         to the graphics screen.  You must select the font using the -f option.  The font names end with _Bx_Fx where Bx is the Background
'         colour and Fx is the Foreground colour. Example: -fCoCoT1_B0_F2
'       - Can now put compiler options on the first line of the program using ' CompilerOptins:
'         Example first line of your program: ' CompileOptions: -fArcade_B0_F1 -o -s32
'
' V4.03 - Fixed a bug in the GCOPY command
'       - Tweaked the code for the GMODE command

' V4.02 - Numeric array sizes can now be larger than 255, so it will now accept DIM A(1000) or DIM MyArray(300,2,2)
'       - String array sizes can now be larger than 255, so it will now accept DIM A$(1000) or DIM MyArray$(300,2), the default size for strings (which includes array elements)
'         is 255 therefore you must use the compiler option -sxxx where xxx is the size of the string and make it a smaller string size if you are going to use many string arrays
'
' V4.01 - With the GMODE ModeNumber,GraphicsPage the compiler can now handle variables for the GraphicsPage value.  The ModeNumber value will always need to be an actual number
'       - Palette command now will wait for a vsync to change the value (should make sure there's no sparkels)
'
' V4.00 - Added New command GMODE which allows you to easily select every graphic mode the CoCo 1,2 or 3 can produce
'       - Added New command GCOPY which allows you to copy graphic pages to other graphic pages
'       - Tweaked LINE, CIRCLE & PAINT commands to use all the available graphic modes and colours of the CoCo 1,2 or 3
'
' V3.03 - Tweaked the AND, OR, XOR commands as the optimizer was not handling them properly
'
' V3.02 - Fixed a bug with optimiing when it is doing exponents
'       - Fixed a bug with optimiing when it is doing exponents
'
' V3.01 - Fixed a small bug with Printing of double quotes ""
'
' V3.00 - Added SDC file support, you can now read and write files on the SDC filesystem directly
'       - If a 6309 is present it puts it in native mode (should speed up code about 15%)
'       - Added compiler option -a which makes your program autostart
'       - Fixed a bug where if a variable name had AND,OR,MOD,XOR,NOT or DIVR in the name it would create variable names and operators out of it
'       - Fixed a bug with IF command with multiple numeric commands that weren't evaluating properly
'
' V2.22 - Fixed a bug with a comment at the end of a DATA statement, it was sometimes not being ignored
'
' V2.21 - Fixed bug with close brackets
'
' V2.20 - Fixed handling of direct number conversion of a number that starts with a minus sign
'       - Fixed handling of DATA values that start with a minus sign
'       - Matched how BASIC converts a float to an INT (negative numbers always get the integer -1)
'       - Fixed a bug in multidimensional arrays
'
' V2.19 - Fixed LINE-(x,y),PSET command, so it will work properly

' V2.18 - Fixed assignning a variable to numeric commands
'
' V2.17 - Added CMPNE(FP_A,FP_B) - Floating Point Compare if Not Equal
'
' V2.16 - Found a problem with comparing floating point numbers where the exponent was not being compared correctly
'       - Tweaked getting the 2nd value in a floatting point number if it was a typed value
'       - Tweaked getting numeric value in as a floating point number can now handle the value if it starts with a decimal
'       - Tweaked the identification of a label and a variable
'
' V2.15 - Aadding limited Floating point operations
'       - Fixed a bug compiling single lines with IF THEN ELSE
'
' V2.14 - Added more commands for streaming audio directly off the CoCoSDC: SDCPLAYORCS, SDCPLAYORCL & SDCPLAYORCR
'         These commands require either an Orchestra 90 or CocoFLASH (https://www.go4retro.com/products/cocoflash/) cartridge
'         The SDCPLAYORCS command streams stereo 8 bit unsigned audio at 22,375hz to both the left and right channels
'         The SDCPLAYORCL streams mono 8 bit unsigned audio at 44,750hz to the Left channel output
'         The SDCPLAYORCR streams mono 8 bit unsigned audio at 44,750hz to the Right channel output
'       - Added version checking if the user is going to have SDC streaming commands like SDCPLAY as the SDC needs version 127 or higher
'       - Fixed handling of REM's that were commenting out actual code, it now display better in the .asm file
'         It was also causing errors as some of the command values were printing as ASCII LF/BREAK/Carriage return symbols
'
' V2.13 - Added command PLAYSDC"SAMPLE.RAW" which will play the sample stored on the SDC through the CoCo DAC
'
' V2.12 - Added GET and PUT commands, added option for PUT command to use the usual PSET (default), PRESET, AND, OR, NOT but also added XOR
'
' V2.11 - Tweaked PLAY command to handle quoted strings a little better.
'
' V2.10 - Added PLAY command and tweaked DRAW command so it handles ;X with a string if the DRAW command doesn't end with a semi colon
'       - Fixed a NASTY bug where certain bytes in ADDASSEM/ENDASSEM would write over actual program code
'
' V2.09 - Fixed a bug with INKEY$
'
' V2.08 - Broke some regular printing with the printing to graphics screen, this is now been fixed
'       - Fixed a bug with getting the value of an expression before an open bracket if an array was before the open bracket
'
' V2.07 - Fixed problem with REM or ' at the end of a line, was causing that entire line to be ignored especially if it started with a variable
'
' V2.06 - Fixed a bug where the compiler needed a space after the PRINT command and before the # sign as PRINT#-2 or PRINT#-1 would give an error.
'       - Added support of PRINT#-3, which prints text to the PMODE 4 screen
'       - Changed the LOCATE x,y command so it will position the PRINT #-3, cursor location on the PMODE 4 screen where x is from 0 to 31 and y is from 0 to 184
'       - Added a new commandline option -f[fontname] where the user can supply the font name to use for printing to the graphics screen.  The font must be in the folder
'         Basic_Includes/Graphic_Screen_Fonts
'         Arcade & CoCoT1 with Arcade being the default font as it is a bolder font and less likely to artifact.  The CoCoT1 font is a pixel accurate version
'         of the CoCo's 6847 T1 VDG chip.  The fonts are already compiled sprites to make them print as fast as possible.
'
' V2.05 - Added printing to serial port with Print #-2,
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
ProgramStart$ = "E00" ' $2600, PMODE 4 graphics screen will be from $E00 to $25FF

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

Dim FloatVariable$(100000)
Dim FloatVariableCount As Integer

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
    Print "       set the input type with the -coco or -ascii options"
    Print "       -coco     - A regular tokenized Color Computer BASIC program"
    Print "       -ascii    - A plain text BASIC program in regular ASCII, from a text editor or a program like QB64"
    Print "       -dragon   - Destination code is for a Dragon computer (Keyboard layout is different than a CoCo)"
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
    Print "       -a        - Makes the program autostart after it is LOADed on the CoCo"
    Print "       -r        - At the end of the program the compiler will try to return to BASIC, default is to do and endless loop"
    Print "       -h        - Show this help message"
    Print
    Print "See Manual.pdf file for more help"
    System
End If
nt = 0: newp = 0: endp = 0: StringArraySize = 16: KeepTempFiles = 0: AutoStart = 0
Optimize = 2 ' Default to optimize level 2
Font$ = "Arcade_B0_F1" ' Default font to use for graphics screen

For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 5)) = "-coco" Then BASICMode = 1: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 6)) = "-ascii" Then BASICMode = 3: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 7)) = "-dragon" Then Dragon = 1: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-s" Then StringArraySize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-o" Then Optimize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If Left$(N$, 2) = "-V" Then Verbose = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-p" Then ProgramStart$ = Right$(N$, Len(N$) - 2): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-k" Then KeepTempFiles = 1: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-f" Then Font$ = Right$(N$, Len(N$) - 2): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-a" Then AutoStart = 1: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-r" Then Ret2Basic = 1: GoTo CheckNextCMDOption
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

' Check if the first line of the program has commandline options
Open Fname$ For Input As #1
Line Input #1, I$
If InStr(LCase$(I$), "compileoptions") > 0 Then
    ' Found compiler options on first line of the BASIC program
    p = 1
    Do
        s = InStr(p, I$, "-") ' Find the next "-"
        If s = 0 Then Exit Do ' No more options
        e = InStr(s + 1, I$, " ") ' Find the next space
        If e = 0 Then e = Len(I$) + 1 ' If no space found, assume end of line
        N$ = Mid$(I$, s, e - s) ' Extract and print the option
        If LCase$(Left$(N$, 5)) = "-coco" Then BASICMode = 1
        If LCase$(Left$(N$, 6)) = "-ascii" Then BASICMode = 3
        If LCase$(Left$(N$, 2)) = "-s" Then StringArraySize = Val(Right$(N$, Len(N$) - 2))
        If LCase$(Left$(N$, 2)) = "-o" Then Optimize = Val(Right$(N$, Len(N$) - 2))
        If Left$(N$, 2) = "-V" Then Verbose = Val(Right$(N$, Len(N$) - 2))
        If LCase$(Left$(N$, 2)) = "-p" Then ProgramStart$ = Right$(N$, Len(N$) - 2)
        If LCase$(Left$(N$, 2)) = "-k" Then KeepTempFiles = 1
        If LCase$(Left$(N$, 2)) = "-f" Then Font$ = Right$(N$, Len(N$) - 2)
        If LCase$(Left$(N$, 2)) = "-a" Then AutoStart = 1
        If LCase$(Left$(N$, 7)) = "-dragon" Then Dragon = 1
        If Left$(N$, 2) = "-v" Then
            ' Show the Version number and exit
            Print "BasTo6809 - BASIC to 6809 Assembly converter V"; V$
            System
        End If
        p = e + 1 ' Move past the last found option
    Loop
End If
Close #1

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
    Dim i2 As Long
    For i2 = 0 To length - 1
        v = INArray(i2)
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
    Next i2
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
For i2 = 0 To length - 1
    Array(i2) = INArray(i2)
Next i2

' Erase double or more spaces and double or more colons
i2 = 0: N = 0
q = 0
EraseExtraSpacesColons:
While N < length
    y = N
    ' get a line and look for ADDASSEM
    Temp$ = "": c = 0
    While N <= length And c <> &H0D
        c = Array(N): N = N + 1
        Temp$ = Temp$ + Chr$(c)
    Wend
    If InStr(Temp$, "ADDASSEM") > 0 Then
        ' This line is an ADDASSEM line, copy everything as it is until we get to an ENDASSEM line
        'Copy Top line
        N = y
        CopyAssemCodeAsIs:
        Temp$ = "": c = 0
        While N <= length And c <> &H0D
            c = Array(N): N = N + 1
            Temp$ = Temp$ + Chr$(c)
        Wend
        For ii = 1 To Len(Temp$)
            Array(i2) = Asc(Mid$(Temp$, ii, 1)): i2 = i2 + 1
        Next ii
        If InStr(Temp$, "ENDASSEM") > 0 Then GoTo EraseExtraSpacesColons 'Copied the last line
        GoTo CopyAssemCodeAsIs
    Else
        N = y
        c = Array(N)
        While N < length And c <> &H0D
            c = Array(N)
            Array(i2) = c
            If c = &H22 Then q = q + 1 ' Found a quote
            If (q And 1) = 0 Then
                '  Not in a Quote
                If c = Asc(" ") Then
                    ' Found a space and not in a quote
                    N = N + 1
                    While Array(N) = Asc(" ")
                        N = N + 1 ' skip the spaces
                    Wend
                    N = N - 1
                End If
                If c = Asc(":") Then
                    'Found a colon
                    q = 0
                    While Array(N) = Asc(":")
                        N = N + 1 ' skip extra colons
                    Wend
                    N = N - 1
                End If
            End If
            N = N + 1
            i2 = i2 + 1
        Wend
        q = 0
    End If
Wend
length = i2

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
For i2 = 0 To length
    Array(i2) = INArray(i2)
Next i2

If Verbose > 2 Then
    ' Let's print the current program listing:
    For i2 = 0 To length - 1
        If Array(i2) = &H0D Then Print
        If Verbose = 3 Then Print Chr$(Array(i2));
        If Verbose > 3 Then Print Hex$(Array(i2)); " ";
    Next i2
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
num = Verbose: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
Verbose$ = " -v" + Num$ + " "
p$ = " -p" + ProgramStart$ + " "
f$ = "-f" + Font$ + " "

If Dragon = 1 Then Dragon$ = " -dragon " Else Dragon$ = ""
If KeepTempFiles = 1 Then KeepTempFiles$ = " -k " Else KeepTempFiles$ = ""
If AutoStart = 1 Then AutoStart$ = " -a " Else AutoStart$ = ""
If Ret2Basic = 1 Then Ret2Basic$ = " -r " Else Ret2Basic$ = ""

' We now have the BASIC program in a good text format as the file BASIC_Text.bas
' Tokenize the BASIC Program
CompilerVersion$ = _OS$
If InStr(CompilerVersion$, "[MACOSX]") > 0 Or InStr(CompilerVersion$, "[LINUX]") > 0 Then
    PreString$ = "./"
Else
    PreString$ = ".\"
End If
returncode = Shell(PreString$ + "BasTo6809.1.Tokenizer " + c$ + s$ + o$ + b$ + Dragon$ + Verbose$ + p$ + f$ + AutoStart$ + Ret2Basic$ + OutName$)
If returncode = 0 Then System
' We now have the BASIC program in a good tokenized format as the file BasicTokenized.bin
' Call the compiler with a few command line options to pass through to the compiler
returncode = Shell(PreString$ + "BasTo6809.2.Compile " + c$ + s$ + o$ + b$ + Dragon$ + Verbose$ + KeepTempFiles$ + AutoStart$ + Ret2Basic$ + OutName$)
If returncode = 0 Then System
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

