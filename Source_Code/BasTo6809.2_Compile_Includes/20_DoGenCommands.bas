
' Jump to the general command pointed at by v
JumpToGeneralCommand:
Select Case GeneralCommands$(v)
' New commands




' Commands tested good
    Case "ATTR"
        GoTo DoATTR
    Case "AUDIO"
        GoTo DoAUDIO
    Case "CASE"
        GoTo DoCASE
    Case "CIRCLE"
        GoTo DoCIRCLE
    Case "CLEAR"
        GoTo DoCLEAR
    Case "CLS"
        GoTo DoCLS
    Case "CMP"
        GoTo DoCMP
    Case "COLOR"
        GoTo DoColor
    Case "COPYBLOCKS"
        GoTo DoCopyBlocks
    Case "CPUSPEED"
        GoTo DoCPUSPEED
    Case "DATA"
        GoTo DoDATA
    Case "DIM"
        GoTo DoDIM
    Case "DO"
        GoTo DoDO
    Case "DRAW"
        GoTo DoDRAW
    Case "EXEC"
        GoTo DoEXEC
    Case "ELSE"
        GoTo DoELSE
    Case "ELSEIF"
        GoTo DoELSEIF
    Case "END"
        GoTo DoEnd
    Case "EXIT"
        GoTo DoEXIT
    Case "FOR"
        GoTo DoFOR
    Case "GCOPY"
        GoTo DoGCOPY
    Case "GCLS"
        GoTo DoGCLS
    Case "GETJOYD"
        GoTo DoGETJOYD
    Case "GMODE"
        GoTo DoGMODE
    Case "GOSUB"
        GoTo DoGOSUB
    Case "GOTO"
        GoTo DoGOTO
    Case "IF"
        GoTo DoIF
    Case "INPUT"
        GoTo DoInput
    Case "LET"
        GoTo DoLET
    Case "LINE"
        GoTo DoLINE
    Case "LPOKE"
        GoTo DoLPOKE
    Case "LOADM"
        GoTo DoLOADM
    Case "LOCATE"
        GoTo DoLOCATE
    Case "LOOP"
        GoTo DoLOOP
    Case "MOTOR"
        GoTo DoMOTOR
    Case "NEXT"
        GoTo DoNEXT
    Case "NTSC_FONTCOLOURS"
        GoTo DoNTSCFontColours
    Case "ON"
        GoTo DoON
    Case "PAINT"
        GoTo DoPAINT
    Case "PALETTE"
        GoTo DoPalette
    Case "PLAY"
        GoTo DoPLAY
    Case "PLAYFIELD"
        GoTo DoPlayfield
    Case "POKE"
        GoTo DoPOKE
    Case "PRINT"
        GoTo DoPRINT
    Case "READ"
        GoTo DoREAD
    Case "RESTORE"
        GoTo DoRESTORE
    Case "RETURN"
        GoTo DoRETURN
    Case "RGB"
        GoTo DoRGB
    Case "RUN"
        GoTo DoRUN
    Case "SAMPLE_LOAD"
        GoTo DoSAMPLE_LOAD
    Case "SAMPLE"
        GoTo DoSAMPLE
    Case "SCREEN"
        GoTo DoSCREEN
    Case "SDC_BIGLOADM"
        GoTo DoSDC_BIGLOADM
    Case "SDC_CLOSE"
        GoTo DoSDC_CLOSE
    Case "SDC_LOADM"
        GoTo DoSDC_LOADM
    Case "SDC_OPEN"
        GoTo DoSDC_OPEN
    Case "SDC_PLAY"
        GoTo DoSDC_PLAY
    Case "SDC_PLAYORCL"
        GoTo DoSDC_PLAYORCL
    Case "SDC_PLAYORCR"
        GoTo DoSDC_PLAYORCR
    Case "SDC_PLAYORCS"
        GoTo DoSDC_PLAYORCS
    Case "SDC_PUTBYTE0"
        GoTo DoSDC_PUTBYTE0
    Case "SDC_PUTBYTE1"
        GoTo DoSDC_PUTBYTE1
    Case "SDC_SAVEM"
        GoTo DoSDC_SAVEM
    Case "SDC_SETPOS0"
        GoTo DoSDC_SETPOS0
    Case "SDC_SETPOS1"
        GoTo DoSDC_SETPOS1
    Case "SELECT"
        GoTo DoSELECT
    Case "SET"
        GoTo DoSET
    Case "SLEEP"
        GoTo DoSLEEP
    Case "SOUND"
        GoTo DoSOUND
    Case "SPRITE"
        GoTo DoSPRITE
    Case "SPRITE_LOAD"
        GoTo DoSPRITE_LOAD

    Case "STOP"
        GoTo DoSTOP

    Case "TIMER"
        GoTo DoTIMER

    Case "VIEW"
        GoTo DoView

    Case "WAIT"
        GoTo DoWAIT

    Case "WEND"
        GoTo DoWEND
    Case "WHILE"
        GoTo DoWHILE
    Case "WIDTH"
        GoTo DoWIDTH

    Case Else
        Print "Unknown General command "; GeneralCommands$(v); " on";: GoTo FoundError
        System
End Select

DoCMP:
A$ = "JSR": B$ = "CoCo3_CMP": C$ = "Set the palette to Composite montior mode": GoSub AO
Return

DoRGB:
A$ = "JSR": B$ = "CoCo3_RGB": C$ = "Set the palette to RGB montior mode": GoSub AO
Return

DoATTR:
' Get the numeric value before a comma
' Get foreground palette # number in B
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "ANDB": B$ = "#%00000111": C$ = "Make sure value is from 0 to 7": GoSub AO
A$ = "LSLB": B$ = "@POKE+1": C$ = "Save location where to poke in memory below (Self mod)": GoSub AO
A$ = "LSLB": B$ = "@POKE+1": C$ = "Save location where to poke in memory below (Self mod)": GoSub AO
A$ = "LSLB": B$ = "@POKE+1": C$ = "Save location where to poke in memory below (Self mod)": GoSub AO
A$ = "PSHS": B$ = "B": C$ = "Save Forground colour on the stack": GoSub AO
'x in the array will now be pointing just past the ,
' Get background palette # number in B
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "ANDB": B$ = "#%00000111": C$ = "Make sure value is from 0 to 7": GoSub AO
A$ = "ORB": B$ = ",S+": C$ = "B = Forground and Background colour palettes": GoSub AO
' Other options for Attr Command
' ,0,0 - No Blink or Underline
' ,1,0 - Blink
' ,0,1 - Underline
' ,1,1 - Blink & Underline
Blink = Array(x): x = x + 1 ' get the Blink flag
x = x + 2 ' consume the F5 & comma
Underline = Array(x): x = x + 1 ' get the Underline flag
If Blink = Asc("1") and Underline = Asc("1") Then
    ' Blink & Underline
    A$ = "ORB": B$ = "#%11000000": C$ = "Set the blink & Underline attribute bits": GoSub AO
Else
    If Blink = Asc("1") Then
        ' Blink
        A$ = "ORB": B$ = "#%10000000": C$ = "Set the blink attribute bit": GoSub AO
    End If
    If Underline = Asc("1") Then
        ' Underline
        A$ = "ORB": B$ = "#%01000000": C$ = "Set the Underline attribute bit": GoSub AO
    End If
End If
A$ = "STB": B$ = "AttributeByte": C$ = "Save the new attribute value":Gosub AO
Return

DoLPOKE:
' Get the numeric value before a comma
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
NVT = NT_UInt32 ' Convert number to unsigned 32 bit number
GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
'Get value to poke on the stack
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
NVT = NT_UByte ' Convert number to unsigned 8 bit number
GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
A$ = "JSR": B$ = "LPOKE": C$ = "Do Long Poke": GoSub AO
Return

' Close an open file
DoSDC_CLOSE:
x = x + 2 'skip the open bracket
If Array(x - 1) <> &H28 Then Print "Can't find open bracket for Close command on";: GoTo FoundError
' Get the file number
GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "JSR": B$ = "SDC_CloseFileB": C$ = "Close file # in B": GoSub AO
Return ' Return with D = the value in the INT

' SDC_SETPOS0(x) 
' set the position in a open file # at position x
' # is 0 or 1
' x is a Long (32 bit) unsinged integer
DoSDC_SETPOS0:
x = x + 2 'skip the open bracket
If Array(x - 1) <> &H28 Then Print "Can't find open bracket for SDCSETPOS0 command on";: GoTo FoundError
' Get the position value
GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
NVT = NT_UInt32 ' Convert number to unsigned 32 bit number
GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
A$ = "LDX": B$ = "#SDC_LBN0": C$ = "X = pointer to the LBN file number on the stack": GoSub AO
A$ = "PULS": B$ = "B,U": C$ = "Get 3 MS Bytes of the 32 bit value off the stack": GoSub AO
A$ = "STB": B$ = ",X": C$ = "Save B": GoSub AO
A$ = "STU": B$ = "1,X": C$ = "Save U as the Logical Sector number": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LS Byte of the 32 bit value off the stack": GoSub AO
A$ = "STB": B$ = "4,X": C$ = "Save the byte offset in the sector": GoSub AO
A$ = "JSR": B$ = "SDC_ReadBuffer0": C$ = "Fill buffer 0 from the the SDC file 0": GoSub AO
Return

' SDC_SETPOS1(x) 
' set the position in a open file # at position x
' # is 0 or 1
' x is a Long (32 bit) unsinged integer
DoSDC_SETPOS1:
x = x + 2 'skip the open bracket
If Array(x - 1) <> &H28 Then Print "Can't find open bracket for SDCSETPOS1 command on";: GoTo FoundError
' Get the position value
GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
NVT = NT_UInt32 ' Convert number to unsigned 32 bit number
GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
A$ = "LDX": B$ = "#SDC_LBN1": C$ = "X = pointer to the LBN file number on the stack": GoSub AO
A$ = "PULS": B$ = "B,U": C$ = "Get 3 MS Bytes of the 32 bit value off the stack": GoSub AO
A$ = "STB": B$ = ",X": C$ = "Save B": GoSub AO
A$ = "STU": B$ = "1,X": C$ = "Save U as the Logical Sector number": GoSub AO
A$ = "LDB": B$ = ",S+": C$ = "Get LS Byte of the 32 bit value off the stack": GoSub AO
A$ = "STB": B$ = "4,X": C$ = "Save the byte offset in the sector": GoSub AO
A$ = "JSR": B$ = "SDC_ReadBuffer1": C$ = "Fill buffer 1 from the the SDC file 1": GoSub AO
Return

' SDC_LOADM a file directly off the CoCoSDC - SDC_LOADM"FILENAME.BIN",#[,Offset]
DoSDC_LOADM:
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find a comma after the filename for the SDC_LOADM command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "PSHS": B$ = "B": C$ = "Save the disk #": GoSub AO
If Array(x) <> &HF5 Then Print "Problem with the end of the SDC_LOADM command on";: GoTo FoundError
If Array(x + 1) = &H2C Then
    ' Found a comma add the offset
    x = x + 2 ' consume the ,
    GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
    GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
    A$ = "STD": B$ = "_Var_PF10": C$ = "Store D at _Var_PF10 as the SDC_LOADM offset value": GoSub AO
Else
    A$ = "CLR": B$ = "_Var_PF10": C$ = "Set _Var_PF10 to zero as the SDC_LOADM offset value": GoSub AO
    A$ = "CLR": B$ = "_Var_PF10+1": C$ = "Set _Var_PF10 to zero as the SDC_LOADM offset value": GoSub AO
End If
A$ = "LDB": B$ = ",S+": C$ = "Get the disk # and fix the stack": GoSub AO
A$ = "BNE": B$ = ">": C$ = "If not zero then skip ahead to do the JSR SDCLoadM1": GoSub AO
A$ = "JSR": B$ = "SDCLoadM0": C$ = "Do a LOADM from Drive 0 of the SDC": GoSub AO
A$ = "BRA": B$ = "@Done": GoSub AO
Z$ = "!"
A$ = "JSR": B$ = "SDCLoadM1": C$ = "Do a LOADM from Drive 1 of the SDC": GoSub AO
Z$ = "@Done": GoSub AO: GoSub AO ' Leave a blank so the @Done works properly
Return

' SDC_SAVEM a file directly to the CoCoSDC - SDC_SAVEM"FILENAME.BIN",#,Start,End,EXEC
DoSDC_SAVEM:
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find a comma after the filename for the SDC_LOADM command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "PSHS": B$ = "B": C$ = "Save the disk #": GoSub AO
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find the second comma for the SDC_SAVEM command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "PSHS": B$ = "D": C$ = "Save the Start Address": GoSub AO
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find the third comma for the SDC_SAVEM command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "PSHS": B$ = "D": C$ = "Save the End Address": GoSub AO
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find the fourth comma for the SDC_SAVEM command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "PSHS": B$ = "D": C$ = "Save the EXEC Address": GoSub AO
A$ = "LDB": B$ = "6,S": C$ = "Get the disk #": GoSub AO
A$ = "BNE": B$ = ">": C$ = "If not zero then skip ahead to do the JSR SDCLoadM1": GoSub AO
A$ = "JSR": B$ = "SDCSaveM0": C$ = "Do a SAVEM to Drive 0 of the SDC": GoSub AO
A$ = "BRA": B$ = "@Done": GoSub AO
Z$ = "!"
A$ = "JSR": B$ = "SDCSaveM1": C$ = "Do a SAVEM to Drive 1 of the SDC": GoSub AO
Z$ = "@Done"
A$ = "LEAS": B$ = "7,S": C$ = "Fix the stack": GoSub AO: GoSub AO ' Leave a blank so the @Done works properly
Return

' Write a byte to the SDC file 0, which must already be open
DoSDC_PUTBYTE0:
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "JSR": B$ = "SDCPutByteB0": C$ = "Send byte B to file 0": GoSub AO
Return

' Write a byte to the SDC file 1, which must already be open
DoSDC_PUTBYTE1:
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "JSR": B$ = "SDCPutByteB1": C$ = "Send byte B to file 1": GoSub AO
Return

DoSDC_PLAY:
' Copy filename to a tempstring
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find a comma after the filename for the SDC_PLAY command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "SDC_DriveNumber": C$ = "Save the disk #": GoSub AO
A$ = "JSR": B$ = "SDCPLAY": C$ = "Play audio sample where the filename is @ ,S on TV Speaker": GoSub AO
Return

DoSDC_PLAYORCL:
' Copy filename to a tempstring
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find a comma after the filename for the SDC_PLAYORCL command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "SDC_DriveNumber": C$ = "Save the disk #": GoSub AO
A$ = "JSR": B$ = "SDCPLAYOrcL": C$ = "Play audio sample where the filename is @ ,S on Orc 90/CoCo Flash Left Speaker output": GoSub AO
Return

DoSDC_PLAYORCR:
' Copy filename to a tempstring
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find a comma after the filename for the SDC_PLAYORCR command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "SDC_DriveNumber": C$ = "Save the disk #": GoSub AO
A$ = "JSR": B$ = "SDCPLAYOrcR": C$ = "Play audio sample where the filename is @ ,S on Orc 90/CoCo Flash Right Speaker output": GoSub AO
Return

DoSDC_PLAYORCS:
' Copy filename to a tempstring
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find a comma after the filename for the SDC_PLAYORCS command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "SDC_DriveNumber": C$ = "Save the disk #": GoSub AO
A$ = "JSR": B$ = "SDCPLAYOrcS": C$ = "Play audio sample where the filename is @ ,S on Orc 90/CoCo Flash in Stereo": GoSub AO
Return

' SDC_BIGLOADM a file directly off the CoCoSDC - SDC_BIGLOADM"FILENAME.BIN",#
DoSDC_BIGLOADM:
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up at ,S
A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
If Array(x) <> TK_SpecialChar Or Array(x + 1) <> TK_Comma Then Print "Can't find a comma after the filename for the SDC_BIGLOADM command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "SDC_DriveNumber": C$ = "Save the disk #": GoSub AO
A$ = "JSR": B$ = "SDCBigLoadM": C$ = "Do a Special Big LOADM file off the SDC": GoSub AO
Return

' Open's a file for reading or writing directly to the CoCoSDC - SDC_OPEN"FILENAME.EXT","W",0
DoSDC_OPEN:
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find a comma after the filename for the SDCOPEN command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
If Array(x) <> &HF5 Or Array(x + 1) <> &H2C Then Print "Can't find the 2nd comma for the SDCOPEN command on";: GoTo FoundError
x = x + 2 ' consume the ,
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "ANDB": B$ = "#$01": C$ = "Make sure B is either a 0 or a 1": GoSub AO
A$ = "LDA": B$ = "1,S": C$ = "Should be a W or R": GoSub AO
A$ = "SUBA": B$ = "#'R'": C$ = "If A was R it is now zero, anything else is a W": GoSub AO
A$ = "BEQ": B$ = ">": C$ = "Skip if it's zero": GoSub AO
A$ = "LDA": B$ = "#1": C$ = "Make A a 1": GoSub AO
Z$ = "!": A$ = "LEAS": B$ = "2,S": C$ = "Fix the stack": GoSub AO
A$ = "JSR": B$ = "SDCOpenFile": C$ = "Open File, A=0 Read or A=1 Write, file number in B (0 or 1)": GoSub AO
Return

DoEXEC:
GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "TFR": B$ = "D,PC": C$ = "JMP to D": GoSub AO
Return

' Will never get here
DoLET:
v = Array(x): x = x + 1 ' Consume the space
v = Asc(":")
Return

' Command that only supports command "VBL" after it
DoWAIT:
v = Array(x): x = x + 1
If v = &HFF Then
    ' Getting a command word after the WAIT command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Select Case v
        Case VBL_CMD
            ' Wait for a Vertical blank then update the sprites
            A$ = "JSR": B$ = "DoWaitVBL": C$ = "Wait for Vertical Blank then update the sprites": GoSub AO
            Return
    End Select
Else
    Print "Can't find the VBL command after WAIT on";: GoTo FoundError
End If

DoView:
' Using a scrollable viewport
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "STD": B$ = "ViewPortX": C$ = "Set the x viewport value": GoSub AO
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression, now in D
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "STD": B$ = "ViewPortY": C$ = "Set the y viewport value": GoSub AO
A$ = "JSR": B$ = ViewPlayfield$(Playfield): C$ = "Scroll the screen": GoSub AO
Return

DoSTOP:
A$ = "BRA": B$ = "*": C$ = "Endless Loop": GoSub AO
GoTo SkipUntilEOLColon ' Skip until we find an EOL or colon then return

DoPLAY:
' Copy strings and quotes to a tempstring
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
A$ = "JSR": B$ = "Play": C$ = "Play command, will play the commands in the string @ ,S": GoSub AO
Return

DoTIMER: ' &H62
v = Array(x): x = x + 2 ' Get the command byte in v, consume the &HFC3D "="
If v <> &HFC Or Array(x - 1) <> &H3D Then Print "Error, TIMER needs an Equal sign after it on";: GoTo FoundError
' Get the numeric value after the equal sign
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "STD": B$ = "_Var_Timer": C$ = "Store D as the new Timer Value": GoSub AO
Return

DoSOUND:
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "SoundTone": C$ = "Save the Tone Value": GoSub AO
GoSub GetExpressionB4EOL: x = x + 2 ' Get the expression before an End of Line in Expression$
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
' B has the duration value
A$ = "LDA": B$ = "#$04": C$ = "Match timing of Color BASIC": GoSub AO
A$ = "MUL": C$ = "D now has the proper length": GoSub AO
A$ = "STD": B$ = "SoundDuration": C$ = "Save the length of the sound": GoSub AO
A$ = "JSR": B$ = "PlaySound": C$ = "Go play the SOUND": GoSub AO
Return

DoSLEEP:
' Wait x number of milliseconds, based on the HSYNC interrupt
' Get the numeric value before a colon or End of Line in D
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "CMPD": B$ = "#21": C$ = "Is the value at least 21?": GoSub AO
A$ = "BLO": B$ = "@Skip": C$ = "If not then skip delay": GoSub AO
A$ = "PSHS": B$ = "CC": C$ = "Save the CC": GoSub AO
A$ = "ORCC": B$ = "#$50": C$ = "Disable the interrupts": GoSub AO
A$ = "LDX": B$ = "#10": C$ = "X = 10": GoSub AO
'A$ = "EXG": B$ = "D,X": C$ = "D now = 10, X is the number given by the user": GoSub AO
A$ = "PSHS": B$= "D,X": C$="Push values on the stack": GoSub AO
A$ = "JSR": B$ = "DIV_U16": C$ = "Do 2,S / ,S Unisgned 16 bit Division": GoSub AO
A$ = "PULS": B$ = "D": C$ = "Get result in D": GoSub AO
A$ = "SUBD": B$ = "#1": C$ = "D=D-1, the overhead of the Divide could be around 10 ms, so make up for it": GoSub AO
A$ = "TFR": B$ = "D,Y": C$ = "Y = user ms Value Divided by 10": GoSub AO
Z$ = "@Loop1": A$ = "LDB": B$ = "#157": C$ = "157 HSyncs = 10 milliseconds": GoSub AO
Z$ = "@Loop2": A$ = "LDA": B$ = "$FF00": C$ = "Reset Hsync flag": GoSub AO
Z$ = "!": A$ = "LDA": B$ = "$FF01": C$ = "See if HSync has occurred yet": GoSub AO
A$ = "BPL": B$ = "<": C$ = "If not then keep looping, until the Hsync occurs": GoSub AO
A$ = "DECB": C$ = "Decrement the counter": GoSub AO
A$ = "BNE": B$ = "@Loop2": C$ = "If not zero then, keep looping": GoSub AO
A$ = "LEAY": B$ = "-1,Y": C$ = "Y=Y-1": GoSub AO
A$ = "BNE": B$ = "@Loop1": C$ = "If not zero then, keep looping": GoSub AO
A$ = "PULS": B$ = "CC": C$ = "Restore the CC": GoSub AO
Z$ = "@Skip": C$ = "Done": GoSub AO
Print #1,
Return

DoMOTOR:
v = Array(x): x = x + 1
If v <> &HFF Then Print "Error getting value of MOTOR command (ON/OFF) on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2
If v = ON_CMD Or v = OFF_CMD Then
    If v = ON_CMD Then
        ' MOTOR ON
        A$ = "LDA": B$ = "$FF21": C$ = "READ CRA OF U4": GoSub AO
        A$ = "ORA": B$ = "#%00001000": C$ = "TURN ON BIT 3 WHICH ENABLES MOTOR DELAY": GoSub AO
        A$ = "STA": B$ = "$FF21": C$ = "PUT IT BACK": GoSub AO
    Else
        ' MOTOR OFF
        A$ = "LDA": B$ = "$FF21": C$ = "READ CRA OF U4": GoSub AO
        A$ = "ANDA": B$ = "#%11110111": C$ = "TURN OFF BIT 3": GoSub AO
        A$ = "STA": B$ = "$FF21": C$ = "PUT IT BACK": GoSub AO
    End If
Else
    Print "Can't find ON or OFF for MOTOR command on";: GoTo FoundError
End If
Return

DoLOADM:
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
v = Array(x): x = x + 1
'Print #1, "; GetSectionToLOADM, v=$"; Hex$(v)
If v = &HF5 Then
    ' Found a special character
    v = Array(x): x = x + 1
    If v = &H2C Then ' Handle a comma on the LOADM line
        GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
        GoSub ParseNumericExpression_Int16 ' Parse Number and return with value as Signed value in D
        A$ = "STD": B$ = "_Var_PF10": C$ = "Store D at _Var_PF10 as the LOADM offset value": GoSub AO
    Else
        A$ = "CLR": B$ = "_Var_PF10": C$ = "Set _Var_PF10 to zero as the LOADM offset value": GoSub AO
        A$ = "CLR": B$ = "_Var_PF10+1": C$ = "Set _Var_PF10 to zero as the LOADM offset value": GoSub AO
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
A$ = "JSR": B$ = "FixFileName": C$ = "Format _StrVar_PF00 to proper disk filename format in memory at DNAMBF": GoSub AO
A$ = "LDU": B$ = "#DNAMBF": C$ = "U points at the filename to open": GoSub AO
' Open the the File pointed at by U
' Enter with U pointing at the properly formatted filename (8 character filename padded with spaces) and a 3 character extension
' Exits with X pointing at the filename entry in the disk directory
' Carry flag will be set if it couldn't find the filename, cleared otherwise
A$ = "JSR": B$ = "OpenFileU": C$ = "Go open file": GoSub AO
A$ = "LBCS": B$ = "DiskError": C$ = "Error Openning the File": GoSub AO
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
A$ = "JSR": B$ = "InitFile": C$ = "Prep open file for reading": GoSub AO
' Do a LOADM command
' File must already be Initialized
' *** Enter with: Y pointing at the FATBLx associated with the drive DCDRV
' * Loads a  Machine Language file from the disk
' Adds the 16 bit value stored in _Var_PF10 to the Load Address and the EXEC address
A$ = "JSR": B$ = "DiskLOADM": C$ = "Load the ML program": GoSub AO
Return ' we have reached the end of the line return

DoColor:
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "FORCOL": C$ = "Store Foreground colour value": GoSub AO
'x in the array will now be pointing just past the ,
'Get value to poke in D (we only use B)
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "BAKCOL": C$ = "Store Background colour value": GoSub AO
Return

DoCLEAR:
' We can ignore the clear commands since the addresses will be different from BASIC
' But the CLEAR command does also clear all the variables so we should do that here
' Get the numeric value before a comma In BASIC this would reserve RAM space for strings
' Get first number in D
GoSub GetExpressionB4SemiComEOL ' Get an Expression before a semi colon, a comma or an EOL
'GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
If v = &H2C Then
    x = x + 2 ' consume the &HF5 & comma
    'we have a comma so we should get the next value after the comma
    ' In BASIC this value would be where an ML program would be located
    GoSub GetExpressionB4EOL 'Get an expression that ends with a colon or End of a Line in Expression$
'GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
End If
A$ = "JSR": B$ = "ClearVariables": C$ = "Go clear the variables": GoSub AO
GoTo SkipUntilEOLColon ' Skip until we find an EOL or colon then return

DoAUDIO:
v = Array(x): x = x + 1
If v <> &HFF Then Print "Error getting value of AUDIO command (ON/OFF) on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2
If v = ON_CMD Or v = OFF_CMD Then
    If v = ON_CMD Then
        ' Audio ON
        A$ = "LDB": B$ = "#$01": C$ = "Multiplexer setting for cassette input": GoSub AO
        A$ = "JSR": B$ = "Select_AnalogMuxer": C$ = "ROUTE CASSETTE TO SOUND MULTIPLEXER": GoSub AO
        A$ = "JSR": B$ = "AnalogMuxOn": C$ = "ENABLE SOUND MULTIPLEXER": GoSub AO
    Else
        ' Audio OFF
        A$ = "CLRB": C$ = "Multiplexer setting for DAC - so sound and PLAY will work": GoSub AO
        A$ = "JSR": B$ = "Select_AnalogMuxer": C$ = "ROUTE CASSETTE TO SOUND MULTIPLEXER": GoSub AO
        A$ = "JSR": B$ = "AnalogMuxOff": C$ = "TURN OFF ANALOG MUX": GoSub AO
    End If
Else
    Print "Can't find ON or OFF for AUDIO command on";: GoTo FoundError
End If
Return

DoPAINT:
x = x + 2 'skip the open bracket
If Array(x - 1) <> &H28 Then Print "Can't find open bracket for PAINT command on";: GoTo FoundError
' Get the x co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
GoSub ParseNumericExpression_Int16 ' Parse Number and return with value as Signed value in D
GoSub VerifyX ' Add code to make sure X value is in bounds of screen size
If Val(GModeMaxX$(Gmode)) > 255 Then
    A$ = "PSHS": B$ = "D": C$ = "Save the loction of the X co-ordinate": GoSub AO
Else
    A$ = "PSHS": B$ = "B": C$ = "Save the loction of the X co-ordinate": GoSub AO
End If
' Get the y co-ordinate
GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
GoSub VerifyY ' Add code to make sure Y value is in bounds of screen size
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AO
Print #1, ' Need a space for @ in assembly
x = x + 2 'move past the &HF5 & comma
If Array(x - 1) <> &H2C Then Print "Can't find comma after PAINT command on";: GoTo FoundError
GoSub GetExpressionB4SemiComEOL: x = x + 2 ' Get an Expression before a semi colon, a comma or an EOL
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "PSHS": B$ = "B": C$ = "Save the Fill Colour on the stack": GoSub AO 'Source Colour
GoSub GetExpressionB4SemiComEOL: x = x + 2 ' Get an Expression before a semi colon, a comma or an EOL
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "PSHS": B$ = "B": C$ = "Save the Destination Colour on the stack": GoSub AO
If Gmode > 99 Then
    ' Handle CoCo 3 graphic command
    A$ = "LDY": B$ = "#PAINT_" + GModeName$(Gmode): C$ = "Y points at the routine to do": GoSub AO
    A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
Else
    A$ = "JSR": B$ = "PAINT_" + GModeName$(Gmode): C$ = "Go do the PAINT/Flood Fill": GoSub AO
End If
Print #1,
Return

DoDRAW:
' Copy strings and quotes to a tempstring
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
A$ = "JSR": B$ = "Draw" + GModeName$(Gmode): C$ = "Draw command, will draw the commands in the string _StrVar_PF00": GoSub AO
Return

' LOCATE x,y - Sets the cursor at Column x, Row y
DoLOCATE:
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "STD": B$ = "x0": C$ = "Save the x location": GoSub AO
'x in the array will now be pointing just past the ,
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "STD": B$ = "y0": C$ = "Save the y location": GoSub AO
A$ = "JSR": B$ = "LOCATE_" + GModeName$(Gmode): C$ = "Setup the location to print text on the graphics screen": GoSub AO
Return

'Found a PLAYFIELD command
DoPlayfield:
'Signify we will be scrolling the background and setup which Viewplayfield$(Playfield) to use
ScollBackground = 1 ' Using scrolling
' get the Playfield number
N$ = ""
While Array(x) < &HF0
    N$ = N$ + Chr$(Array(x)): x = x + 1
Wend
' Got the Playfield needed
Playfield = Val(N$)
Return

DoCopyBlocks:
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "<_Var_PF00+1": C$ = "Save Source Block Number": GoSub AO
' Get the numeric value before a comma
' Get 2nd number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "<_Var_PF01+1":: C$ = "Save Destination Block Number": GoSub AO
' Get the numeric value before a Colon or EOL
' Get 2nd number in D
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "<_Var_PF02+1":: C$ = "Save Number of 8k blocks to copy": GoSub AO
A$ = "JSR": B$ = "Copy8kBlocks": C$ = "Go copy the 8k blocks": GoSub AO
Return

' GModeName$(16) = "FG6R": GModeMaxX$(16) = "255": GModeMaxY$(16) = "191": GModeStartAddress$(16) = "E00": GModeScreenSize$(16) = "1800"
DoSPRITE:
v = Array(x): x = x + 1
If v = &HFF Then
    ' Getting a command word after the SPRITE command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Select Case v
        Case ON_CMD ' Enable all sprite handling
            ' SPRITE ON
            ' Ignored
            Return
        Case OFF_CMD ' Turns off one or all sprites
            ' SPRITE OFF
            If Array(x) = &HFF And (Array(x + 1) = &H0D Or Array(x + 1) = &H3A) Then
                ' no value given after the SPRITE OFF command, turn them all off
                A$ = "LDB": B$ = "#31": C$ = "32 sprites to process": GoSub AO
                Z$ = "!": A$ = "PSHS": B$ = "B": C$ = "Save B": GoSub AO
                A$ = "JSR": B$ = "SpriteBOff": C$ = "Jump to code to turn off sprite B": GoSub AO
                A$ = "PULS": B$ = "B": C$ = "Restore B": GoSub AO
                A$ = "DECB": C$ = "Decrement the sprite number": GoSub AO
                A$ = "BPL": B$ = "<": C$ = "Keep looping until we get to -1": GoSub AO
                Return
            Else
                ' Turn off just Sprite # given
                ' Get the sprite #
                ' Get the numeric value before a colon or End of Line in D
                GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
                A$ = "JSR": B$ = "SpriteBOff": C$ = "Jump to code to turn off sprite B": GoSub AO
            End If
            Return
        Case LOCATE_CMD
            ' Change the sprite location on screen "SPRITE LOCATE 0,8,10" - set sprite 0 to screen co-ordinates 8,10
            ' Get the Sprite #
            ' Get the numeric value before comma in D
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
            A$ = "PSHS": B$ = "B": C$ = "Save the sprite #": GoSub AO
            ' Get the x co-ordinate
            ' Get the numeric value before comma in D
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
            A$ = "PSHS": B$ = "D": C$ = "Save the x co-ordinate": GoSub AO
            ' Get the y co-ordinate
            ' Get the numeric value before a colon or End of Line in D
            GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
            A$ = "PSHS": B$ = "D": C$ = "Save the y co-ordinate": GoSub AO
            A$ = "JSR": B$ = "SpriteLocate": C$ = "Change the screen location of the sprite": GoSub AO
            A$ = "LEAS": B$ = "5,S": C$ = "Fix the Stack": GoSub AO
            Return
        Case SHOW_CMD
            ' Show the image of the sprite to an anim # frame  ie. SPRITE SHOW s[,f]   ' Show sprite s, anim frame f
            ' Get the numeric value before a comma or EOL or Colon
            ' Get the Sprite #
            ' Get the numeric value before comma or EOL in D
            GoSub GetExpressionB4SemiComEOL ' Get an Expression before a semi colon, a comma or an EOL, don't move past them
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
            A$ = "PSHS": B$ = "B": C$ = "Save the Sprite #": GoSub AO
            ' Check if we just found at comma
            If Array(x) = &HF5 And Array(x + 1) = Asc(",") Then
                ' We have an animated sprite
                x = x + 2 'move past the comma
                ' Get the frame #
                ' Get the numeric value before a colon or End of Line in D
                GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
            Else
                ' Move past the EOL
                x = x + 2
                A$ = "CLRB": C$ = "Use frame zero": GoSub AO
            End If
            A$ = "PSHS": B$ = "B": C$ = "Save the frame #": GoSub AO
            A$ = "JSR": B$ = "ShowSpriteFrame": C$ = "Jump to code to change the sprite frame #": GoSub AO
            If Gmode > 99 Then
                A$ = "LEAS": B$ = "6,S": C$ = "Fix the Stack": GoSub AO
            Else
                A$ = "LEAS": B$ = "2,S": C$ = "Fix the Stack": GoSub AO
            End If
            Return
        Case BACKUP_CMD
            ' Save the background behind the sprite # given
            ' Get the numeric value before a colon or End of Line in D
            GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
            A$ = "JSR": B$ = "BackupSpriteB": C$ = "Jump to code to Backup Sprite B": GoSub AO
            Return
        Case ERASE_CMD
            ' Ersae the sprite # given and restore what was behind it
            ' Get the numeric value before a colon or End of Line in D
            GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
            A$ = "JSR": B$ = "EraseSpriteB": C$ = "Jump to code to Erase SpriteB and restore it's background": GoSub AO
            Return
        Case Else
            Print "Can't handle command after SPRITE on";: GoTo FoundError
    End Select
Else
    ' Not a command fix x
    x = x - 1
End If

' Get the Sprite #
' Get the numeric value before comma in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "PSHS": B$ = "B": C$ = "Save the sprite #": GoSub AO
' Get the x co-ordinate
' Get the numeric value before comma in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "PSHS": B$ = "D": C$ = "Save the x co-ordinate": GoSub AO
' Get the y co-ordinate
' Get the numeric value before comma or EOL in D
GoSub GetExpressionB4SemiComEOL ' Get an Expression before a semi colon, a comma or an EOL, don't move past them
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "PSHS": B$ = "D": C$ = "Save the y co-ordinate": GoSub AO
' Get the frame #, if found
' Check if we just found at comma
If Array(x) = &HF5 And Array(x + 1) = Asc(",") Then
    ' We have an animated sprite
    x = x + 2 'move past the comma
    ' Get the frame #
    ' Get the numeric value before a colon or End of Line in D
    GoSub GetExpressionB4EOL: x = x + 2 'Handle an expression that ends with an End of a Line, & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
Else
    ' Move past the EOL
    x = x + 2
    A$ = "CLRB": C$ = "Use frame zero": GoSub AO
End If
A$ = "PSHS": B$ = "B": C$ = "Save the frame #": GoSub AO
A$ = "JSR": B$ = "AddSpriteToProcess": C$ = "Jump to code to add sprite to draw the sprite cache list": GoSub AO
A$ = "LEAS": B$ = "6,S": C$ = "Fix the Stack": GoSub AO
Return

' Skip over the SPRITE_LOAD command, this is handled in the tokenizer
DoSPRITE_LOAD:
If FirstSpriteLoad = 0 And CoCo3 = 1 Then
    FirstSpriteLoad = 1
    ' Load the CoCo3 Palette from the CoCo3_Palette.asm file
    ' Wait for vsync
    A$ = "LDA": B$ = "$FF02": C$ = "Reset Vsync flag": GoSub AO
    Z$ = "!": A$ = "LDA": B$ = "$FF03": C$ = "See if Vsync has occurred yet": GoSub AO
    A$ = "BPL": B$ = "<": C$ = "If not then keep looping, until the Vsync occurs": GoSub AO
    A$ = "LDU": B$ = "#CoCo3_Palette": C$ = "U points at the start or the users palette info": GoSub AO
    A$ = "LDX": B$ = "#$FFB0": C$ = "Point at the start of the palette memory": GoSub AO
    Z$ = "!": A$ = "LDD": B$ = ",U++": C$ = "Get the palette values, move pointer": GoSub AO
    A$ = "STD": B$ = ",X++": C$ = "Save the palette values in the palette registers, move pointer": GoSub AO
    A$ = "CMPX": B$ = "#$FFC0": C$ = "See if we've copied them all": GoSub AO
    A$ = "BNE": B$ = "<": C$ = "Keep looping if not": GoSub AO
End If
While Array(x) <> &HF5
    x = x + 1
Wend
x = x + 1
If Array(x) = &H0D Or Array(x) = &H3A Then x = x + 1: Return
GoTo DoSPRITE_LOAD

' Skip over the SAMPLE_LOAD command, this is handled in the tokenizer
DoSAMPLE_LOAD:
While Array(x) <> &HF5
    x = x + 1
Wend
x = x + 1
If Array(x) = &H0D Or Array(x) = &H3A Then x = x + 1: Return
GoTo DoSAMPLE_LOAD

' Handle SAMPLE command
' SAMPLE SINGLE 2 ' Play audio sample #2 one single time
' SAMPLE LOOP 4 ' Play audio sample #4 continously looping
' SAMPLE OFF ' turns off any sample playing
DoSAMPLE:
v = Array(x): x = x + 1
If v = &HFF Then
    ' Getting a command word after the SAMPLE command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Select Case v
        Case LOOP_CMD ' Loop the sample
            GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
            A$ = "LDX": B$ = "#CC3SamplesStartBLKTable": C$ = "X points at the start of the table": GoSub AO
            A$ = "LSLB": C$ = "* 2": GoSub AO
            A$ = "LSLB": C$ = "* 4 (four bytes per entry)": GoSub AO
            A$ = "ABX": C$ = "X now points at our entry in the table": GoSub AO
            A$ = "LDD": B$ = ",X": C$ = "get 1st and 2nd block": GoSub AO
            A$ = "STD": B$ = "$FFA9": C$ = "save Audio sample's 1st and 2nd block": GoSub AO
            A$ = "INCB": C$ = "point at the next 8k blocks": GoSub AO
            A$ = "STB": B$ = "$FFAB": C$ = "save Audio sample's 3rd and 4th block": GoSub AO
            A$ = "LDU": B$ = "2,X": C$ = "Get the starting address of the audio sample": GoSub AO
            A$ = "LDX": B$ = "#FIRQ_Sound": C$ = "X points at the play audio sample code": GoSub AO
            A$ = "PSHS": B$ = "CC": C$ = "save FIRQ/IRQ settings": GoSub AO
            A$ = "ORCC": B$ = "#$50": C$ = "Disable the FIRQ": GoSub AO
            A$ = "LDA": B$ = "#$01": C$ = "Signify we want this sample to loop": GoSub AO
            A$ = "STA": B$ = ">DoSoundLoop": C$ = "Save the loop value 0 = no loop, <> 0 means loop": GoSub AO
            A$ = "STU": B$ = ">SampleStart": C$ = "Save the loop address (If needed)": GoSub AO
            A$ = "STU": B$ = ">GetSample+1": C$ = "Point at the start of the sample": GoSub AO
            A$ = "STX": B$ = "FIRQ_Jump_position_FEF4+1": C$ = "Set the FIRQ jump to play sample code": GoSub AO
            A$ = "PULS": B$ = "CC": C$ = "Restore the FIRQ, which will now play the sample": GoSub AO
            Return
        Case SINGLE_CMD ' Play the audio sample without looping
            GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
            A$ = "LDX": B$ = "#CC3SamplesStartBLKTable": C$ = "X points at the start of the table": GoSub AO
            A$ = "LSLB": C$ = "* 2": GoSub AO
            A$ = "LSLB": C$ = "* 4 (four bytes per entry)": GoSub AO
            A$ = "ABX": C$ = "X now points at our entry in the table": GoSub AO
            A$ = "LDD": B$ = ",X": C$ = "get 1st and 2nd block": GoSub AO
            A$ = "STD": B$ = "$FFA9": C$ = "save Audio sample's 1st and 2nd block": GoSub AO
            A$ = "INCB": C$ = "point at the next 8k blocks": GoSub AO
            A$ = "STB": B$ = "$FFAB": C$ = "save Audio sample's 3rd and 4th block": GoSub AO
            A$ = "LDU": B$ = "2,X": C$ = "Get the starting address of the audio sample": GoSub AO
            A$ = "LDX": B$ = "#FIRQ_Sound": C$ = "X points at the play audio sample code": GoSub AO
            A$ = "PSHS": B$ = "CC": C$ = "save FIRQ/IRQ settings": GoSub AO
            A$ = "ORCC": B$ = "#$50": C$ = "Disable the FIRQ": GoSub AO
            A$ = "CLR": B$ = ">DoSoundLoop": C$ = "Save the loop value 0 = no loop, <> 0 means loop": GoSub AO
            '            A$ = "STU": B$ = ">SampleStart": C$ = "Save the loop address (If needed)": GoSub AO
            A$ = "STU": B$ = ">GetSample+1": C$ = "Point at the start of the sample": GoSub AO
            A$ = "STX": B$ = "FIRQ_Jump_position_FEF4+1": C$ = "Set the FIRQ jump to play sample code": GoSub AO
            A$ = "PULS": B$ = "CC": C$ = "Restore the FIRQ, which will now play the sample": GoSub AO
        Case OFF_CMD
            A$ = "CLR": B$ = ">DoSoundLoop": C$ = "Save the loop value 0 = no loop, <> 0 means loop": GoSub AO
            A$ = "LDD": B$ = "#$7FFF": C$ = "Set last playback value for sample length": GoSub AO
            A$ = "STD": B$ = ">SampleStart": C$ = "Save it as the last value of the sample": GoSub AO
            Return
        Case Else
            Print "error: SAMPLE must have either SINGLE, LOOP or OFF as the action on";: GoTo FoundError
    End Select
    Return
Else
    Print "error: SAMPLE must have either SINGLE, LOOP or OFF as the action on";: GoTo FoundError
End If

DoLINE:
v = Array(x): x = x + 1
ContinueLine = 0
' Add code to handle LINE-(x,y),Colour[,BF] instead of normal LINE(x,y)-(x1,y1),Colour[,BF]
If v = &HFC And Array(x) = &H2D Then
    ' Found a hyphen, this is a LINE-(x,y),Colour[,BF]
    ContinueLine = 1
    x = x - 1 ' Make it point to the same place it needs below
End If
If ContinueLine = 0 And Array(x) <> &H28 Then Print "Can't find open bracket for LINE command on";: GoTo FoundError

' Get the start x co-ordinate
If ContinueLine = 1 Then
    ' Use the old X location from the previous LINE command
    A$ = "LDD": B$ = "endX": C$ = "Use the old X location from the previous LINE command": GoSub AO
Else
    x = x + 1 'move past the open bracket
    GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
    GoSub ParseNumericExpression_Int16 ' Parse Number and return with value as Signed value in D
End If
GoSub VerifyX ' Add code to make sure X value is in bounds of screen size
If Val(GModeMaxX$(Gmode)) > 255 Then
    A$ = "PSHS": B$ = "D": C$ = "Save the loction of the X co-ordinate": GoSub AO
Else
    A$ = "PSHS": B$ = "B": C$ = "Save the loction of the X co-ordinate": GoSub AO
End If
' Get the start y co-ordinate
If ContinueLine = 1 Then
    ' Use the old Y location from the previous LINE command
    A$ = "LDD": B$ = "endY": C$ = "Use the old Y location from the previous LINE command": GoSub AO
Else
    GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    GoSub ParseNumericExpression_Int16 ' Parse Number and return with value as Signed value in D
End If
GoSub VerifyY ' Add code to make sure Y value is in bounds of screen size
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AO
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
GoSub ParseNumericExpression_Int16 ' Parse Number and return with value as Signed value in D
GoSub VerifyX ' Add code to make sure X value is in bounds of screen size
If Val(GModeMaxX$(Gmode)) > 255 Then
    A$ = "PSHS": B$ = "D": C$ = "Save the loction of the X co-ordinate": GoSub AO
Else
    A$ = "PSHS": B$ = "B": C$ = "Save the loction of the X co-ordinate": GoSub AO
End If
' Get the destination y co-ordinate
GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
GoSub ParseNumericExpression_Int16 ' Parse Number and return with value as Signed value in D
GoSub VerifyY ' Add code to make sure Y value is in bounds of screen size
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AO
Print #1, ' Need a space for @ in assembly
x = x + 1 ' Skip &HF5
v = Array(x): x = x + 1 ' Get comma
If v <> &H2C Then Print "Can't find comma after the destination x & y co-ordinates on";: GoTo FoundError
' Get the Color of the LINE
GoSub GetExpressionB4CommaEOL: x = x + 2 'Handle an expression that ends with a comma or EOL, skip brackets , move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "LineColour": C$ = "Save the Colour value": GoSub AO
' Other options for Line Command
' after PSET or RESET we will have
' ,0,0 - No Box or Box Fill
' ,1,0 - Draw a Box
' ,1,1 - Draw a box and fill it
Box = Array(x): x = x + 1 ' get the Box flag
x = x + 2 ' consume the F5 & comma
Fill = Array(x): x = x + 1 ' get the Fill flag
If Box = Asc("0") Then
    ' No Box or Fill, just draw a line
    If Gmode > 99 Then
        ' Handle CoCo 3 graphic command
        A$ = "LDY": B$ = "#LINE_" + GModeName$(Gmode): C$ = "Y points at the routine to do": GoSub AO
        A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
    Else
        A$ = "JSR": B$ = "LINE_" + GModeName$(Gmode): C$ = "Go draw foreground colour line": GoSub AO
    End If
Else
    'We have a box to draw
    If Fill = Asc("0") Then
        ' Don't fill the box
        If Gmode > 99 Then
            ' Handle CoCo 3 graphic command
            A$ = "LDY": B$ = "#BOX_" + GModeName$(Gmode): C$ = "Y points at the routine to do": GoSub AO
            A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
        Else
            A$ = "JSR": B$ = "BOX_" + GModeName$(Gmode): C$ = "Go draw foreground colour box": GoSub AO
        End If
    Else
        ' Fill the box
        If Gmode > 99 Then
            ' Handle CoCo 3 graphic command
            A$ = "LDY": B$ = "#BoxFill_" + GModeName$(Gmode): C$ = "Y points at the routine to do": GoSub AO
            A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
        Else
            A$ = "JSR": B$ = "BoxFill_" + GModeName$(Gmode): C$ = "Go draw foreground colour box": GoSub AO
        End If
    End If
End If
GoSub AO
Return

DoCIRCLE:
x = x + 2 'skip the open bracket
If Array(x - 1) <> &H28 Then Print "Can't find open bracket for CIRCLE command on";: GoTo FoundError
' Get the x co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
GoSub ParseNumericExpression_Int16 ' Parse Number and return with value as Signed value in D
GoSub VerifyX ' Add code to make sure X value is in bounds of screen size
If Val(GModeMaxX$(Gmode)) > 255 Then
    A$ = "PSHS": B$ = "D": C$ = "Save the loction of the X co-ordinate": GoSub AO
Else
    A$ = "PSHS": B$ = "B": C$ = "Save the loction of the X co-ordinate": GoSub AO
End If
' Get the y co-ordinate
GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
GoSub ParseNumericExpression_Int16 ' Parse Number and return with value as Signed value in D
GoSub VerifyY ' Add code to make sure Y value is in bounds of screen size
A$ = "PSHS": B$ = "B": C$ = "Save the y coordinate on the stack": GoSub AO
x = x + 2 'move past the &HF5 & comma
If Array(x - 1) <> &H2C Then Print "Can't find comma after CIRCLE command on";: GoTo FoundError
GoSub GetExpressionB4CommaEOL 'Handle an expression that ends with a comma or EOL, skip brackets , move past it
GoSub ParseNumericExpression_Int16 ' Parse Number and return with value as Signed value in D
If Val(GModeMaxX$(Gmode)) > 255 Then
    A$ = "PSHS": B$ = "D": C$ = "Save the radius on the stack": GoSub AO
Else
    A$ = "PSHS": B$ = "B": C$ = "Save the radius on the stack": GoSub AO
End If
x = x + 2 'move past the &HF5 & comma
If Array(x - 1) <> &H2C Then Print "Can't find comma after radius value of the CIRCLE command on";: GoTo FoundError
GoSub GetExpressionB4CommaEOL: x = x + 2 'Handle an expression that ends with a comma or EOL, skip brackets , move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "LineColour": C$ = "Save the Colour value": GoSub AO
Print #1, ' Need a space for @ in assembly
v = Array(x - 1)
If Gmode > 99 Then
    ' Handle CoCo 3 graphic command
    A$ = "LDY": B$ = "#CIRCLE_" + GModeName$(Gmode): C$ = "Y points at the routine to do": GoSub AO
    A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
Else
    A$ = "JSR": B$ = "CIRCLE_" + GModeName$(Gmode): C$ = "Go draw a circle in " + GModeName$(Gmode) + " Screen mode": GoSub AO
End If
If Val(GModeMaxX$(Gmode)) > 255 Then
    A$ = "LEAS": B$ = "5,S": C$ = "Fix the stack": GoSub AO
Else
    A$ = "LEAS": B$ = "3,S": C$ = "Fix the stack": GoSub AO
End If
Print #1, ' Need a space for @ in assembly
Return

' Pallette ColourSlot, ColourValue
DoPalette:
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "ANDB": B$ = "#%00001111": C$ = "Make sure B is a range of 0 to 15": GoSub AO
A$ = "PSHS": B$ = "B": C$ = "Save the palette # to set on the stack": GoSub AO
'Get colour value in D (we only use B)
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
' Wait for vsync
A$ = "LDA": B$ = "$FF02": C$ = "Reset Vsync flag": GoSub AO
Z$ = "!": A$ = "LDA": B$ = "$FF03": C$ = "See if Vsync has occurred yet": GoSub AO
A$ = "BPL": B$ = "<": C$ = "If not then keep looping, until the Vsync occurs": GoSub AO
A$ = "LDX": B$ = "#$FFB0": C$ = "Point at the start of the palette memory": GoSub AO
A$ = "PULS": B$ = "A": C$ = "Get the palette # to set, fix the stack": GoSub AO
A$ = "STB": B$ = "A,X": C$ = "Update the palette # to B": GoSub AO
Return

' Quickly get the joystick values of 0,31,63 of both joysticks both horizontally and vertically
' Results are stored same place BASIC normally has the Joystick readings:
' LEFT  LEFT   RIGHT RIGHT
' VERT  HORIZ  VERT  HORIZ
' $15A  $15B   $15C  $15D
DoGETJOYD:
A$ = "JSR": B$ = "GetJoyD": C$ = "Read Joystick values and update the memory $15A-$15D": GoSub AO
Return

' Set the speed of the CoCo's CPU
' 1 = Normal speed is 28.63636 divided by 32 = 0.89488625 Mhz
' 2 = Double speed is 28.63636 divided by 16 = 1.7897725 Mhz
' 3 = High speed is   28.63636 divided by 10 = 2.863636 Mhz
' Anything else then the CPU will be set in Native mode and run at it's max speed
DoCPUSPEED:
If Array(x) = &HF5 And (Array(x + 1) = &H0D Or Array(x + 1) = &H3A) Then
    A$ = "CLRB": C$ = "Make B=0 so it will act like Max speed for this hardware": GoSub AO
    GoTo SkipGettingSpeed ' skip ahead
End If
'Get the speed value in B
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
SkipGettingSpeed:
A$ = "JSR": B$ = "SetCPUSpeedB": C$ = "Go set the speed of the CPU to B": GoSub AO
Return

' WIDTH 32, 40, 64 or 80
DoWIDTH:
' Get the numeric value before a comma or EOL or Colon
' Get first number in D
' Get the number that is stored as ASCII into a value QB64 can use, so it can keep track of the Graphics mode it is using
v = Array(x): x = x + 1: v$ = Chr$(v)
While Array(x) <> TK_SpecialChar
    v = Array(x): x = x + 1: v$ = v$ + Chr$(v)
Wend
SELECT CASE v$
    CASE "32" ' Switch from graphics mode to regular 32 character screen
            ' Use the regular 32 char text screen
            A$ = "LDX": B$ = "#$0400": C$ = "Text screen starts here": GoSub AO
            A$ = "STX": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
            A$ = "LDA": B$ = "#$0F": C$ = "$0F Back to Text Mode for the CoCo 3": GoSub AO
            A$ = "STA": B$ = "$FF9C": C$ = "Neccesary for CoCo 3 GIME to use this mode": GoSub AO
            ' Go to CoCo 3 Text mode
            A$ = "LDA": B$ = "#$CC": GoSub AO
            A$ = "STA": B$ = "$FF90": GoSub AO
            A$ = "LDD": B$ = "#$0000": GoSub AO
            A$ = "STD": B$ = "$FF98": GoSub AO
            A$ = "STD": B$ = "$FF9A": GoSub AO
            A$ = "STD": B$ = "$FF9E": GoSub AO
            A$ = "LDD": B$ = "#$0FE0": GoSub AO
            A$ = "STD": B$ = "$FF9C": GoSub AO
            A$ = "LDA": B$ = "#Internal_Alphanumeric": C$ = "A = Text mode requested": GoSub AO
            ' Update the Graphic mode and the screen viewer location
            A$ = "JSR": B$ = "SetGraphicModeA": C$ = "Go setup the mode": GoSub AO
            A$ = "LDA": B$ = "BEGGRP": C$ = "Get the MSB of the Screen starting location": GoSub AO
            A$ = "LSRA": C$ = "Divide by 2 - 512 bytes per start location": GoSub AO
            A$ = "JSR": B$ = "SetGraphicsStartA": C$ = "Go set the address of the screen": GoSub AO
        Case "40"
            ' Use the CoCo 3 40 column text screen
'            A$ = "LDX": B$ = "#$0E00": C$ = "Text screen starts here": GoSub AO
'            A$ = "STX": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
            Z$ = "; $FF98 = 0x00100011 - Text Mode,Extra Descenders,Colour,60 Hz,8 lines per character": GoSub AO
            Z$ = "; $FF99 = 0x01100101 - 40 Column mode": GoSub AO
            ' A$ = "LDA": B$ = "#%00100011": GoSub AO
            ' A$ = "LDB": B$ = "#%01100101": GoSub AO
            A$ = "LDD": B$ = "#$2365": GoSub AO
            A$ = "STD": B$ = "$FF98": GoSub AO
            A$ = "LDD": B$ = "#$0000": GoSub AO
            A$ = "STD": B$ = "$FF9A": C$ = "Border color register - BRDR & 2 Meg Vertual 512k Bank": GoSub AO
            A$ = "STA": B$ = "$FF9C": C$ = "Vertical scroll register - VSC": GoSub AO
            A$ = "STA": B$ = "$FF9F": C$ = "Clear the Horizontal register": GoSub AO
            '$FF9D-$FF9E Vertical offset register
            A$ = "LDD": B$ = "#$" + Hex$((&H38 * &H2000 + &HE00) / 8): GoSub AO
            A$ = "STD": B$ = "$FF9D": C$ = "Vertical offset register": GoSub AO
        Case "64"
            ' Use the CoCo 3 64 column text screen
'            A$ = "LDX": B$ = "#$0E00": C$ = "Text screen starts here": GoSub AO
'            A$ = "STX": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
            Z$ = "; $FF98 = 0x00100011 - Text Mode,Extra Descenders,Colour,60 Hz,8 lines per character": GoSub AO
            Z$ = "; $FF99 = 0x01111001 - 64 Column mode": GoSub AO
            ' A$ = "LDA": B$ = "#%00100011": GoSub AO
            ' A$ = "LDB": B$ = "#%01100101": GoSub AO
            A$ = "LDD": B$ = "#$2371": GoSub AO
            A$ = "STD": B$ = "$FF98": GoSub AO
            A$ = "LDD": B$ = "#$0000": GoSub AO
            A$ = "STD": B$ = "$FF9A": C$ = "Border color register - BRDR & 2 Meg Vertual 512k Bank": GoSub AO
            A$ = "STA": B$ = "$FF9C": C$ = "Vertical scroll register - VSC": GoSub AO
            A$ = "STA": B$ = "$FF9F": C$ = "Clear the Horizontal register": GoSub AO
            '$FF9D-$FF9E Vertical offset register
            A$ = "LDD": B$ = "#$" + Hex$((&H38 * &H2000 + &HE00) / 8): GoSub AO
            A$ = "STD": B$ = "$FF9D": C$ = "Vertical offset register": GoSub AO
        Case "80"
            ' Use the CoCo 3 80 column text screen
'            A$ = "LDX": B$ = "#$0E00": C$ = "Text screen starts here": GoSub AO
'            A$ = "STX": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
            Z$ = "; $FF98 = 0x00100011 - Text Mode,Extra Descenders,Colour,60 Hz,8 lines per character": GoSub AO
            Z$ = "; $FF99 = 0x01110101 - 80 Column mode": GoSub AO
            ' A$ = "LDA": B$ = "#%00100011": GoSub AO
            ' A$ = "LDB": B$ = "#%01100101": GoSub AO
            A$ = "LDD": B$ = "#$2375": GoSub AO
            A$ = "STD": B$ = "$FF98": GoSub AO
            A$ = "LDD": B$ = "#$0000": GoSub AO
            A$ = "STD": B$ = "$FF9A": C$ = "Border color register - BRDR & 2 Meg Vertual 512k Bank": GoSub AO
            A$ = "STA": B$ = "$FF9C": C$ = "Vertical scroll register - VSC": GoSub AO
            A$ = "STA": B$ = "$FF9F": C$ = "Clear the Horizontal register": GoSub AO
            '$FF9D-$FF9E Vertical offset register
            A$ = "LDD": B$ = "#$" + Hex$((&H38 * &H2000 + &HE00) / 8): GoSub AO
            A$ = "STD": B$ = "$FF9D": C$ = "Vertical offset register": GoSub AO
END SELECT
Return

DoCLS:
GoSub GetExpressionB4EOL: x = x + 2 ' Get the expression before an End of Line in Expression$ & move past it
If Expression$ = "" Then
    'No value given, do a standard CLS
    A$ = "JSR": B$ = "CLS_Default": C$ = "Fill text screen with value of B": GoSub AO
Else
    ' Get the numeric expression off the stack
    GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
    A$ = "JSR": B$ = "CLS_FixB": C$ = "Fill text screen with value of B": GoSub AO
End If
Return




DoON:
GoSub GetExpressionB4EOLOrCommand 'Handle an expression that ends with a colon or End of a Line or another command like TO or STEP
    GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
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
A$ = "TSTB": C$ = "Check if B is zero": gosub ao
A$ = "BEQ": B$ = DoneOn$: C$ = "If B = 0 then skip to the next line": GoSub AO
A$ = "DECB": C$ = "Jump list starts at zero": gosub ao
A$ = "BRA": B$ = ">": C$ = "Skip past the address list": GoSub AO
Print #1, "@"; ONType$; "List"
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
A$ = "FDB": B$ = Temp$: C$ = "Location for the " + ONType$ + " " + Temp$: GoSub AO
If v = &H2C Then GoTo ONLoop1
' We have the ON value in D, All we need is the value in B as it can't be larger than a 127
Num = c: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
Z$ = "!"
A$ = "CMPB": B$ = "#" + Num$: C$ = "See if the value is larger than the number of entries in the list": GoSub AO
A$ = "BHI": B$ = DoneOn$: C$ = "If the value is higher then simply skip to the next line": GoSub AO
A$ = "LSLB": C$ = "B = B*2 Jump Table entries are two bytes each": GoSub AO
A$ = "LDX": B$ = "#@" + ONType$ + "List": C$ = "X points at the begining of the table": GoSub AO
A$ = "ABX": C$ = "X = X+B, X now points at the correct entry": GoSub AO
If ONType$ = "JSR" Then
    A$ = ONType$: B$ = "[,X]": C$ = "GOSUB to the address in the table": GoSub AO
Else
    A$ = ONType$: B$ = "[,X]": C$ = "GOTO to the address in the table": GoSub AO
End If
Z$ = DoneOn$: GoSub AO
Print #1,
Return

DoDATA:
' Add the data on this line to the DataArray, keeping track of the location/size with DataArrayCount
' DATA lines are special lines that may conatin spaces
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Or v = &H27
    v = Array(x): x = x + 1
    If v = &H2C Then
        ' Found a comma, check for another comma in a row
        v = Array(x): x = x + 1
        If v = &H2C Then
            ' Got two commas in a row, insert a value of zero
            DataArray(DataArrayCount) = Asc("0"): DataArrayCount = DataArrayCount + 1
            DataArray(DataArrayCount) = v: DataArrayCount = DataArrayCount + 1
            GoTo DoDATA
        End If
        If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Or v = &H27 Then
            ' Ending after a comma, add a value of zero and a comma
            DataArray(DataArrayCount) = Asc("0"): DataArrayCount = DataArrayCount + 1
            DataArray(DataArrayCount) = Asc(","): DataArrayCount = DataArrayCount + 1
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
    If (v >= Asc("0") And v <= Asc("9")) Or v = Asc("-") Or v = Asc(".") Or v = Asc("+") Then
        'We have a number to copy
        Z$ = "; found some numeric data": GoSub AO
        Temp$ = ""
        Do Until (v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)) Or v = &H2C Or v = &H27 ' copy until we reach an EOL or comma or '
            Temp$ = Temp$ + Chr$(v)
            DataArray(DataArrayCount) = v: DataArrayCount = DataArrayCount + 1
            v = Array(x): x = x + 1
        Loop
        If v = &H2C Then x = x - 1 ' if a comma then point at it again
        DataArray(DataArrayCount) = Asc(","): DataArrayCount = DataArrayCount + 1
        GoTo DoDATA
    Else
        'Otherwise copy a string until we reach a comma or EOL/Colon
        StartPos = x - 1 ' Got the start pos of the string
        Do Until (v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)) Or v = &H2C Or v = &H27 ' copy until we reach an EOL or comma or '
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
If v = &H27 Then
    ' We found an apostrophe, so ignore the rest of the line
    Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)
        v = Array(x): x = x + 1
    Loop
End If
v = Array(x): x = x + 1 ' move past the &0D or &H3A
Return

DoREAD:
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)
    v = Array(x): x = x + 1
    If v = &HF0 Then
        ' We are reading a numeric array
        Print #1, "; Getting the numeric array memory location in X"
        v = Array(x) * 256 + Array(x + 1): x = x + 2
        NumBits = NumericArrayBits(v)
        Z$ = "; NumBits=" + Str$(NumBits): GoSub AO
        InsideArrayType = NumericArrayBits(v)
        If NumBits = 8 Then
            InsideArrayType = NT_UByte ' use 8-bit unsigned indices
        Else
            InsideArrayType = NT_UInt16 ' use 16-bit unsigned indices
        End If
        NV$ = NumericArrayVariables$(v)
        If Verbose > 3 Then Print "Numeric array variable is: "; NV$
        NumDims = Array(x): x = x + 1
        NVTArrayType = Array(x): x = x + 1 ' NVT1=Numeric Array Variable Type
        x = x + 2 ' Consume the $F5 & open bracket
        If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
        ' Get all the dimensions
        DimCounter = NumDims
        Z$ = "; Before dims - InsideArrayType=" + Str$(InsideArrayType): GoSub AO
        While DimCounter > 1
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
            GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
            NVT = InsideArrayType
            Z$ = "; InsideArrayType(NVT)=" + Str$(InsideArrayType): GoSub AO
            Z$ = "; LastType=" + Str$(LastType): GoSub AO
            GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
            DimCounter = DimCounter - 1
        Wend
        GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
        GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
        NVT = InsideArrayType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' We now have:
        ' NV$=NumArrayName
        ' Value in brackets is on the stack
        ' NumBits = number of bits (8 or 16)
        ' NumDims = Number of dimensions
        If NumDims = 1 And NVTArrayType < 5 Then
            ' This is a quick and easy location to calc and store
            A$ = "PULS": B$ = "B": C$ = "Array pointer, Fix the stack": GoSub AO
            A$ = "LDX": B$ = "#_ArrayNum_" + NV$ + "+1": C$ = "The array starts here": GoSub AO
            A$ = "ABX": C$ = "Make X point at the array location": GoSub AO
            A$ = "PSHS": B$ = "X": C$ = "Save the location to store the value": GoSub AO
        Else
            ' A = BytesPerEntry
            ' B = Number of Array Dimensions
            ' X = Array starts here (points at the sizes of each dimension)
            Select Case NVTArrayType
                Case Is < 5
                    Num = 1
                Case 5, 6
                    Num = 2
                Case 7, 8
                    Num = 4
                Case 9, 10
                    Num = 8
                Case 11
                    Num = 3
                Case 12
                    Num = 10
            End Select
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            Temp$ = Num$
            If NumDims = 1 Then
                If NumBits = 8 Then
                    ' Handle an array with 8 bit indices
                    Z$ = "; Only 8 bit indices": GoSub AO
                    A$ = "LDA": B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
                    A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
                    A$ = "MUL": C$ = "Multiply them": GoSub AO
                    Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                    A$ = "PSHS": B$ = "D": C$ = "Save the location the array is pointing at on the stack": GoSub AO
                Else
                    ' Handle an array with 16 bit indices
                    Z$ = "; Only 1 16 bit element array": GoSub AO
                    Z$ = "; d1 is already on the stack": GoSub AO
                    A$ = "LDD": B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
                    A$ = "PSHS": B$ = "D": C$ = "Save BytesPerEntry as 16 bit on the stack": GoSub AO
                    A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
                    A$ = "LDD": B$ = ",S": C$ = "Get the low 16 bit result in D": GoSub AO
                    Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                    A$ = "STD": B$ = ",S": C$ = "Save the location the array is pointing at": GoSub AO
                End If
            Else
                Num = NumDims - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A = BytesPerEntry, B = Dim count-1": GoSub AO
                If NumBits = 8 Then
                    ' Handle an array with 8 bit indices
                    Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDU": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                    A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                Else
                    ' Handle an array with 16 bit indices
                    Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDU": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                    A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                End If
            End If
        End If
        Select Case NVTArrayType:
            Case 1, 2, 3, 4 ' 8 bit integer
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_S8_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                A$ = "PULS": B$ = "B": C$ = "Number to store in array, fix the stack": GoSub AO
                A$ = "STB": B$ = "[,S++]": C$ = "Save the byte and fix the stack": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
            Case 5, 6 ' 16 bit integer
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_S16_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "Number to store in array, fix the stack": GoSub AO
                A$ = "STD": B$ = "[,S++]": C$ = "Save the word and fix the stack": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
            Case 7, 8 ' 32 bit integer
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_S32_Stack": C$ = "Convert ASCII text @X to a 32 bit number @,S": GoSub AO
                A$ = "PULS": B$ = "D,X,U": C$ = "pull 4 bytes off the stack and U = address where to store the result, fixed stack": GoSub AO
                A$ = "STD": B$ = ",U": C$ = "Save the MSWord": GoSub AO
                A$ = "STX": B$ = "2,U": C$ = "Save the LSWord": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
            Case 9, 10 ' 64 bit integer
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_S64_Stack": C$ = "Convert ASCII text @X to a 64 bit number @,S": GoSub AO
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "pull 4 bytes off the stack and U = address where to store the result, fixed stack": GoSub AO
                A$ = "STD": B$ = "[,S]": C$ = "Save the word and fix the stack": GoSub AO
                A$ = "LDD": B$ = ",S++": C$ = "D = address to Save the 64 bit value, fix the stack": GoSub AO
                A$ = "EXG": B$ = "D,Y": C$ = "D= value of Y & Y now points at memory location to store the rest of the 64 bit number": GoSub AO
                A$ = "STX": B$ = "2,Y": C$ = "Store 2nd Word": GoSub AO
                A$ = "STD": B$ = "4,Y": C$ = "Store 3rd Word": GoSub AO
                A$ = "STU": B$ = "6,Y": C$ = "Store 4th Word": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
            Case 11 ' FFP format
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                A$ = "PULS": B$ = "B,X,U": C$ = "pull 3 bytes off the stack and U = address where to store the result, fixed stack": GoSub AO
                A$ = "STB": B$ = ",U": C$ = "Save the MSWord": GoSub AO
                A$ = "STX": B$ = "1,U": C$ = "Save the LSWord": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
            Case 12 ' Double format
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                A$ = "JSR": B$ = "FFP_To_Double": C$ = "Convert FFP at ,S to 10 byte Double at ,S": GoSub AO
                A$ = "LDU": B$ = "10,S": C$ = "U = Address where to store the 10 byte Double number": GoSub AO
                A$ = "PULS": B$ = "D,X,Y": C$ = "pull 3 words off the stack, move stack": GoSub AO
                A$ = "STD": B$ = ",U": C$ = "Save the 1st Word": GoSub AO
                A$ = "STX": B$ = "2,U": C$ = "Save the 2nd Word": GoSub AO
                A$ = "STY": B$ = "4,U": C$ = "Save the 3rd Word": GoSub AO
                A$ = "PULS": B$ = "D,X,Y": C$ = "pull 2 words off the stack, fix stack": GoSub AO
                A$ = "STD": B$ = "6,U": C$ = "Save the 4th Word": GoSub AO
                A$ = "STX": B$ = "8,U": C$ = "Save the 5th Word": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
        End Select
        GoTo DoREAD
    End If
    If v = &HF2 Then
        ' We are reading a numeric value
        v = Array(x) * 256 + Array(x + 1): x = x + 2
        NumType = Array(x): x = x + 1 ' Get the numeric Type
        Select Case NumType:
            Case 1, 2, 3, 4 ' 8 bit integer
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_S8_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                A$ = "PULS": B$ = "B": C$ = "pull 1 byte off the stack": GoSub AO
                A$ = "STB": B$ = "_Var_" + NumericVariable$(v): C$ = "Store B to Variable": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
            Case 5, 6 ' 16 bit integer
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_S16_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                A$ = "PULS": B$ = "D": C$ = "pull 2 bytes off the stack": GoSub AO
                A$ = "STD": B$ = "_Var_" + NumericVariable$(v): C$ = "Store D to Variable": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
            Case 7, 8 ' 32 bit integer
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_S32_Stack": C$ = "Convert ASCII text @X to a 32 bit number @,S": GoSub AO
                A$ = "PULS": B$ = "D,X": C$ = "pull 4 bytes off the stack": GoSub AO
                A$ = "LDU": B$ = "#_Var_" + NumericVariable$(v) + "+4": C$ = "U points to Variable +4": GoSub AO
                A$ = "PSHU": B$ = "D,X": C$ = "Store D,X": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
            Case 9, 10 ' 64 bit integer
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_S64_Stack": C$ = "Convert ASCII text @X to a 64 bit number @,S": GoSub AO
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "pull 8 bytes off the stack": GoSub AO
                A$ = "STU": B$ = "_Var_" + NumericVariable$(v) + "+6": C$ = "Store U in variable +6": GoSub AO
                A$ = "LDU": B$ = "#_Var_" + NumericVariable$(v) + "+6": C$ = "U points to Variable +6": GoSub AO
                A$ = "PSHU": B$ = "D,X,Y": C$ = "store D,X,Y into the variable space": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
            Case 11 ' FFP format
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                A$ = "PULS": B$ = "B,X": C$ = "pull 3 bytes off the stack": GoSub AO
                A$ = "LDU": B$ = "#_Var_" + NumericVariable$(v) + "+3": C$ = "U points to Variable +3": GoSub AO
                A$ = "PSHU": B$ = "B,X": C$ = "store B,X": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
            Case 12 ' Double format
                A$ = "LDX": B$ = "DATAPointer": C$ = "Get the DATA pointer current value": GoSub AO
                A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                A$ = "JSR": B$ = "FFP_To_Double": C$ = "Convert FFP at ,S to 10 byte Double at ,S": GoSub AO
                A$ = "PULL_DBL": B$ = " _Var_" + NumericVariable$(v): C$ = "Save Doouble on the stack to the variable": GoSub AO
                A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # ended, after a comma": GoSub AO
                A$ = "STD": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
        End Select
        GoTo DoREAD
    End If
    If v = &HF1 Or v = &HF3 Then ' We are getting a string value
        ' B = length of the string
        ' #KeyBuff = start of the keyboard input buffer
        If v = &HF3 Then
            ' We are inputting a string variable
            v = Array(x) * 256 + Array(x + 1): x = x + 2
            Print #1, ""
            A$ = "LDX": B$ = "#_StrVar_" + StringVariable$(v): C$ = "X = destination address": GoSub AO
            A$ = "PSHS": B$ = "X": C$ = "Save the location the array is pointing at on the stack": GoSub AO
        Else
            ' We are inputting a string array
            Print #1, "; Getting the String array memory location in X"
            If Verbose > 3 Then Print "Going to deal with String array"
            v = Array(x) * 256 + Array(x + 1): x = x + 2
            NumBits = StringArrayBits(v)
            Z$ = "; NumBits =" + Str$(NumBits): GoSub AO
            If NumBits = 8 Then
                InsideArrayType = NT_UByte ' use 8-bit unsigned indices
            Else
                InsideArrayType = NT_UInt16 ' use 16-bit unsigned indices
            End If
            NV$ = StringArrayVariables$(v)
            If Verbose > 3 Then Print "String array variable is: "; NV$
            NumDims = Array(x): x = x + 1
            x = x + 2 ' Consume the $F5 & open bracket
            If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
            ' Get all the dimensions
            DimCounter = NumDims
            Z$ = "; InsideArrayType =" + Str$(InsideArrayType): GoSub AO
            Z$ = "; DimCounter =" + Str$(DimCounter): GoSub AO
            While DimCounter > 1
                GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
                GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
                NVT = InsideArrayType
                GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
                DimCounter = DimCounter - 1
            Wend
            GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
            GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
            NVT = InsideArrayType
            GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
            ' We now have:
            ' NV$=NumArrayName
            ' Value in brackets is on the stack
            ' NumBits = number of bits (8 or 16)
            ' NumDims = Number of dimensions
            Num = StringArraySize + 1 ' Length of each string +1 for the first byte which is the length of the particular string, when stored
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            Temp$ = Num$
            If NumDims = 1 Then
                If NumBits = 8 Then
                    ' Handle an array with 8 bit indices
                    Z$ = "; Only 8 bit indices": GoSub AO
                    A$ = "LDA": B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
                    A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
                    A$ = "MUL": C$ = "Multiply them": GoSub AO
                    Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "ADDD": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                    A$ = "PSHS": B$ = "D": C$ = "Save the location the array is pointing at on the stack": GoSub AO
                Else
                    ' Handle an array with 16 bit indices
                    Z$ = "; Only 1 16 bit element array": GoSub AO
                    Z$ = "; d1 is already on the stack": GoSub AO
                    A$ = "LDD": B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
                    A$ = "PSHS": B$ = "D": C$ = "Save BytesPerEntry as 16 bit on the stack": GoSub AO
                    A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
                    A$ = "LDD": B$ = ",S": C$ = "Get the low 16 bit result in D": GoSub AO
                    Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "ADDD": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                    A$ = "STD": B$ = ",S": C$ = "Save the location the array is pointing at": GoSub AO
                End If
            Else
                Num = NumDims - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A = BytesPerEntry, B = Dim count-1": GoSub AO
                If NumBits = 8 Then
                    ' Handle an array with 8 bit values
                    Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDU": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                    A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                Else
                    ' Handle an array with 16 bit values
                    Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDU": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                    A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                End If
            End If
        End If
        A$ = "PULS": B$ = "X": C$ = "Get destination address from the stack": GoSub AO
        A$ = "LDU": B$ = "DATAPointer": C$ = "U = source starts address": GoSub AO
        A$ = "LDB": B$ = ",U": C$ = "Get the string length": GoSub AO
        A$ = "INCB": C$ = "Include the string length byte": GoSub AO
        Z$ = "!"
        A$ = "LDA": B$ = ",U+": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Save into variable space": GoSub AO
        A$ = "DECB": C$ = "Decrement the counter": GoSub AO
        A$ = "BNE": B$ = "<": GoSub AO
        A$ = "STU": B$ = "DATAPointer": C$ = "Save the updated pointer": GoSub AO
        GoTo DoREAD
    End If
Loop
v = Array(x): x = x + 1
Return

DoRUN:
A$ = "JMP": B$ = "START": C$ = "Start the program again": GoSub AO
GoTo SkipUntilEOLColon ' Skip until we find an EOL or colon then return

DoRESTORE:
A$ = "LDD": B$ = "#DataStart": C$ = "Get the Address where DATA starts": GoSub AO
A$ = "STD": B$ = "DATAPointer": C$ = "Save it in the DATAPointer variable": GoSub AO
GoTo SkipUntilEOLColon ' Skip until we find an EOL or colon then return

DoInput:
PrintD$ = "PRINT_D": PrintA$ = "PrintA_On_Screen": PrintDev$ = " on screen" ' Make sure we are printing on the text screen
PrintCC3 = 0
v = Array(x): x = x + 1
ShowInputCount = ShowInputCount + 1
Num = ShowInputCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
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
Num = count: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
A$ = "LDA": B$ = "#" + Num$: C$ = "Save the number of commas needed": GoSub AO
A$ = "STA": B$ = "CommaCount": C$ = "Save the number of commas to look for": GoSub AO
x = Start

' Fill the KeyBuff from user input, it will be terminated with a comma
A$ = "JSR": B$ = "GetInput": C$ = "Show ? and get user input in _StrVar_PF00, U points to the end of the buffer, B has # of characters that were input": GoSub AO
If count = 0 Then
    ' No commas, just one entry for this INPUT command
    v = Array(x): x = x + 1 ' Get the type of variable
    If v < &HF0 And v > &HF3 Then Print "Error1, can't figure out the INPUT variable in";: GoTo FoundError
    ' We got the Enter Key, figure out how to copy the number or string to the variable
    If v = &HF0 Or v = &HF2 Then ' We are getting a numeric value
        '        A$ = "CLR": B$ = ",U": C$ = "Terminate with a zero": GoSub AO
        ' Make sure buffer is a numeric value between 0 and 65536
        ' Get our numeric variable location
        ' Convert buffer to a number
        If v = &HF2 Then
            ' We are inputting a numeric value
            v = Array(x) * 256 + Array(x + 1): x = x + 2
            NumType = Array(x): x = x + 1 ' Get the numeric Type
            Select Case NumType:
                Case 1, 2, 3, 4 ' 8 bit integer
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S8_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "B": C$ = "pull 1 byte off the stack": GoSub AO
                    A$ = "STB": B$ = "_Var_" + NumericVariable$(v): C$ = "Store B to Variable": GoSub AO
                Case 5, 6 ' 16 bit integer
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S16_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D": C$ = "pull 2 bytes off the stack": GoSub AO
                    A$ = "STD": B$ = "_Var_" + NumericVariable$(v): C$ = "Store D to Variable": GoSub AO
                Case 7, 8 ' 32 bit integer
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S32_Stack": C$ = "Convert ASCII text @X to a 32 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D,X": C$ = "pull 4 bytes off the stack": GoSub AO
                    A$ = "LDU": B$ = "#_Var_" + NumericVariable$(v) + "+4": C$ = "U points to Variable +4": GoSub AO
                    A$ = "PSHU": B$ = "D,X": C$ = "Store D,X": GoSub AO
                Case 9, 10 ' 64 bit integer
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S64_Stack": C$ = "Convert ASCII text @X to a 64 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D,X,Y,U": C$ = "pull 8 bytes off the stack": GoSub AO
                    A$ = "STU": B$ = "_Var_" + NumericVariable$(v) + "+6": C$ = "Store U in variable +6": GoSub AO
                    A$ = "LDU": B$ = "#_Var_" + NumericVariable$(v) + "+6": C$ = "U points to Variable +6": GoSub AO
                    A$ = "PSHU": B$ = "D,X,Y": C$ = "store D,X,Y into the variable space": GoSub AO
                Case 11 ' FFP format
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                    A$ = "PULS": B$ = "B,X": C$ = "pull 3 bytes off the stack": GoSub AO
                    A$ = "LDU": B$ = "#_Var_" + NumericVariable$(v) + "+3": C$ = "U points to Variable +3": GoSub AO
                    A$ = "PSHU": B$ = "B,X": C$ = "store B,X": GoSub AO
                Case 12 ' Double format
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                    A$ = "JSR": B$ = "FFP_To_Double": C$ = "Convert FFP at ,S to 10 byte Double at ,S": GoSub AO
                    A$ = "PULL_DBL": B$ = " _Var_" + NumericVariable$(v): C$ = "Save Doouble on the stack to the variable": GoSub AO
            End Select
        Else
            ' We are inputting a numeric array
            Print #1, "; Getting the numeric array memory location in X"
            A$ = "STX": B$ = "Temp1": C$ = "Save the start location": GoSub AO
            v = Array(x) * 256 + Array(x + 1): x = x + 2
            NumBits = NumericArrayBits(v)
            Z$ = "; NumBits=" + Str$(NumBits): GoSub AO
            InsideArrayType = NumericArrayBits(v)
            If NumBits = 8 Then
                InsideArrayType = NT_UByte ' use 8-bit unsigned indices
            Else
                InsideArrayType = NT_UInt16 ' use 16-bit unsigned indices
            End If
            NV$ = NumericArrayVariables$(v)
            If Verbose > 3 Then Print "Numeric array variable is: "; NV$
            NumDims = Array(x): x = x + 1
            NVTArrayType = Array(x): x = x + 1 ' NVT1=Numeric Array Variable Type
            x = x + 2 ' Consume the $F5 & open bracket
            If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
            ' Get all the dimensions
            DimCounter = NumDims
            Z$ = "; Before dims - InsideArrayType=" + Str$(InsideArrayType): GoSub AO
            While DimCounter > 1
                GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
                GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
                NVT = InsideArrayType
                Z$ = "; InsideArrayType(NVT)=" + Str$(InsideArrayType): GoSub AO
                Z$ = "; LastType=" + Str$(LastType): GoSub AO
                GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
                DimCounter = DimCounter - 1
            Wend
            GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
            GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
            NVT = InsideArrayType
            GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
            ' We now have:
            ' NV$=NumArrayName
            ' Value in brackets is on the stack
            ' NumBits = number of bits (8 or 16)
            ' NumDims = Number of dimensions
            If NumDims = 1 And NVTArrayType < 5 Then
                ' This is a quick and easy location to calc and store
                A$ = "PULS": B$ = "B": C$ = "Array pointer, Fix the stack": GoSub AO
                A$ = "LDX": B$ = "#_ArrayNum_" + NV$ + "+1": C$ = "The array starts here": GoSub AO
                A$ = "ABX": C$ = "Make X point at the array location": GoSub AO
                A$ = "PSHS": B$ = "X": C$ = "Save the location to store the value": GoSub AO
            Else
                ' A = BytesPerEntry
                ' B = Number of Array Dimensions
                ' X = Array starts here (points at the sizes of each dimension)
                Select Case NVTArrayType
                    Case Is < 5
                        Num = 1
                    Case 5, 6
                        Num = 2
                    Case 7, 8
                        Num = 4
                    Case 9, 10
                        Num = 8
                    Case 11
                        Num = 3
                    Case 12
                        Num = 10
                End Select
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                Temp$ = Num$
                If NumDims = 1 Then
                    If NumBits = 8 Then
                        ' Handle an array with 8 bit indices
                        Z$ = "; Only 8 bit indices": GoSub AO
                        A$ = "LDA": B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
                        A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
                        A$ = "MUL": C$ = "Multiply them": GoSub AO
                        Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                        A$ = "PSHS": B$ = "D": C$ = "Save the location the array is pointing at on the stack": GoSub AO
                    Else
                        ' Handle an array with 16 bit indices
                        Z$ = "; Only 1 16 bit element array": GoSub AO
                        Z$ = "; d1 is already on the stack": GoSub AO
                        A$ = "LDD": B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
                        A$ = "PSHS": B$ = "D": C$ = "Save BytesPerEntry as 16 bit on the stack": GoSub AO
                        A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
                        A$ = "LDD": B$ = ",S": C$ = "Get the low 16 bit result in D": GoSub AO
                        Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                        A$ = "STD": B$ = ",S": C$ = "Save the location the array is pointing at": GoSub AO
                    End If
                Else
                    Num = NumDims - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A = BytesPerEntry, B = Dim count-1": GoSub AO
                    If NumBits = 8 Then
                        ' Handle an array with 8 bit indices
                        Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "LDU": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                        A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                    Else
                        ' Handle an array with 16 bit indices
                        Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "LDU": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                        A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                    End If
                End If
            End If
            Select Case NVTArrayType:
                Case 1, 2, 3, 4 ' 8 bit integer
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S8_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "B": C$ = "Number to store in array, fix the stack": GoSub AO
                    A$ = "STB": B$ = "[,S++]": C$ = "Save the byte and fix the stack": GoSub AO
                Case 5, 6 ' 16 bit integer
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S16_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D": C$ = "Number to store in array, fix the stack": GoSub AO
                    A$ = "STD": B$ = "[,S++]": C$ = "Save the word and fix the stack": GoSub AO
                Case 7, 8 ' 32 bit integer
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S32_Stack": C$ = "Convert ASCII text @X to a 32 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D,X,U": C$ = "pull 4 bytes off the stack and U = address where to store the result, fixed stack": GoSub AO
                    A$ = "STD": B$ = ",U": C$ = "Save the MSWord": GoSub AO
                    A$ = "STX": B$ = "2,U": C$ = "Save the LSWord": GoSub AO
                Case 9, 10 ' 64 bit integer
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S64_Stack": C$ = "Convert ASCII text @X to a 64 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D,X,Y,U": C$ = "pull 4 bytes off the stack and U = address where to store the result, fixed stack": GoSub AO
                    A$ = "STD": B$ = "[,S]": C$ = "Save the word and fix the stack": GoSub AO
                    A$ = "LDD": B$ = ",S++": C$ = "D = address to Save the 64 bit value, fix the stack": GoSub AO
                    A$ = "EXG": B$ = "D,Y": C$ = "D= value of Y & Y now points at memory location to store the rest of the 64 bit number": GoSub AO
                    A$ = "STX": B$ = "2,Y": C$ = "Store 2nd Word": GoSub AO
                    A$ = "STD": B$ = "4,Y": C$ = "Store 3rd Word": GoSub AO
                    A$ = "STU": B$ = "6,Y": C$ = "Store 4th Word": GoSub AO
                Case 11 ' FFP format
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                    A$ = "PULS": B$ = "B,X,U": C$ = "pull 3 bytes off the stack and U = address where to store the result, fixed stack": GoSub AO
                    A$ = "STB": B$ = ",U": C$ = "Save the MSWord": GoSub AO
                    A$ = "STX": B$ = "1,U": C$ = "Save the LSWord": GoSub AO
                Case 12 ' Double format
                    A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                    A$ = "JSR": B$ = "FFP_To_Double": C$ = "Convert FFP at ,S to 10 byte Double at ,S": GoSub AO
                    A$ = "LDU": B$ = "10,S": C$ = "U = Address where to store the 10 byte Double number": GoSub AO
                    A$ = "PULS": B$ = "D,X,Y": C$ = "pull 3 words off the stack, move stack": GoSub AO
                    A$ = "STD": B$ = ",U": C$ = "Save the 1st Word": GoSub AO
                    A$ = "STX": B$ = "2,U": C$ = "Save the 2nd Word": GoSub AO
                    A$ = "STY": B$ = "4,U": C$ = "Save the 3rd Word": GoSub AO
                    A$ = "PULS": B$ = "D,X,Y": C$ = "pull 2 words off the stack, fix stack": GoSub AO
                    A$ = "STD": B$ = "6,U": C$ = "Save the 4th Word": GoSub AO
                    A$ = "STX": B$ = "8,U": C$ = "Save the 5th Word": GoSub AO
            End Select
        End If
    Else
        If v = &HF1 Or v = &HF3 Then ' We are getting a string value
            ' B = length of the string
            ' #KeyBuff = start of the keyboard input buffer
            If v = &HF3 Then
                ' We are inputting a string variable
                v = Array(x) * 256 + Array(x + 1): x = x + 2
                Print #1, ""
                A$ = "LDX": B$ = "#_StrVar_" + StringVariable$(v): C$ = "X = destination address": GoSub AO
                A$ = "PSHS": B$ = "X": C$ = "Save the location the array is pointing at on the stack": GoSub AO
            Else
                ' We are inputting a string array
                Print #1, "; Getting the String array memory location in X"
                If Verbose > 3 Then Print "Going to deal with String array"
                v = Array(x) * 256 + Array(x + 1): x = x + 2
                NumBits = StringArrayBits(v)
                Z$ = "; NumBits =" + Str$(NumBits): GoSub AO
                If NumBits = 8 Then
                    InsideArrayType = NT_UByte ' use 8-bit unsigned indices
                Else
                    InsideArrayType = NT_UInt16 ' use 16-bit unsigned indices
                End If
                NV$ = StringArrayVariables$(v)
                If Verbose > 3 Then Print "String array variable is: "; NV$
                NumDims = Array(x): x = x + 1
                x = x + 2 ' Consume the $F5 & open bracket
                If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
                ' Get all the dimensions
                DimCounter = NumDims
                Z$ = "; InsideArrayType =" + Str$(InsideArrayType): GoSub AO
                Z$ = "; DimCounter =" + Str$(DimCounter): GoSub AO
                While DimCounter > 1
                    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
                    GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
                    NVT = InsideArrayType
                    GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
                    DimCounter = DimCounter - 1
                Wend
                GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
                GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
                NVT = InsideArrayType
                GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
                ' We now have:
                ' NV$=NumArrayName
                ' Value in brackets is on the stack
                ' NumBits = number of bits (8 or 16)
                ' NumDims = Number of dimensions

                Num = StringArraySize + 1 ' Length of each string +1 for the first byte which is the length of the particular string, when stored
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                Temp$ = Num$
                If NumDims = 1 Then
                    If NumBits = 8 Then
                        ' Handle an array with 8 bit indices
                        Z$ = "; Only 8 bit indices": GoSub AO
                        A$ = "LDA": B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
                        A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
                        A$ = "MUL": C$ = "Multiply them": GoSub AO
                        Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "ADDD": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                        A$ = "TFR": B$ = "D,X": C$ = "X = save location location": GoSub AO
                        A$ = "PSHS": B$ = "X": C$ = "Save the location the array is pointing at on the stack": GoSub AO
                    Else
                        ' Handle an array with 16 bit indices
                        Z$ = "; Only 1 16 bit element array": GoSub AO
                        Z$ = "; d1 is already on the stack": GoSub AO
                        A$ = "LDD": B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
                        A$ = "PSHS": B$ = "D": C$ = "Save BytesPerEntry as 16 bit on the stack": GoSub AO
                        A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
                        A$ = "LDD": B$ = ",S": C$ = "Get the low 16 bit result in D": GoSub AO
                        Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "ADDD": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                        A$ = "STD": B$ = ",S": C$ = "Save the location the array is pointing at": GoSub AO
                        A$ = "TFR": B$ = "D,X": C$ = "X = save location location": GoSub AO
                    End If
                Else
                    Num = NumDims - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A = BytesPerEntry, B = Dim count-1": GoSub AO
                    If NumBits = 8 Then
                        ' Handle an array with 8 bit values
                        Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "LDU": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                        A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                        A$ = "LDX": B$ = ",S": C$ = "Get X from the stack": GoSub AO
                    Else
                        ' Handle an array with 16 bit values
                        Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "LDU": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                        A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                        A$ = "LDX": B$ = ",S": C$ = "Get X from the stack": GoSub AO
                    End If
                End If

            End If
            A$ = "LEAX": B$ = "1,X": C$ = "Move X so it starts at the correct location": GoSub AO
            A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U = source starts address": GoSub AO
            A$ = "CLRB": C$ = "Clear the counter": GoSub AO
            Z$ = "!"
            A$ = "INCB": C$ = "Increment the counter": GoSub AO
            A$ = "LDA": B$ = ",U+": GoSub AO
            A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AO
            A$ = "CMPA": B$ = "#','": C$ = "Did we find a comma?": GoSub AO
            A$ = "BNE": B$ = "<": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "STB": B$ = "[,S++]": C$ = "Save the length of the string and fix the stack": GoSub AO
        Else
            Print "Error2, can't figure out the INPUT variable in";: GoTo FoundError
        End If
    End If
    ' Check for a comma or end of line $0D
    v = Array(x): x = x + 1
    If v <> &HF5 And Array(x) <> &H0D And Array(x) <> &H3A Then Print "Error, with the INPUT command, it didn't end properly in";: GoTo FoundError
    v = Array(x): x = x + 1
    Return 'Done with the INPUT command
End If

' There are commas on the INPUT line handle it a little differently
A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X = source starts address": GoSub AO
A$ = "STX": B$ = "Temp1": C$ = "Temp1 = source starts address": GoSub AO
v = Array(x)
Z$ = "; v =" + Str$(v): GoSub AO
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)
    v = Array(x): x = x + 1 ' Get the type of variable
    If v < &HF0 And v > &HF3 Then Print "Error3, can't figure out the INPUT variable in";: GoTo FoundError
    ' We got the Enter Key, figure out how to copy the number or string to the variable
    If v = &HF0 Or v = &HF2 Then ' We are getting a numeric value
        '        A$ = "CLR": B$ = ",U": C$ = "Terminate with a zero": GoSub AO
        ' Make sure buffer is a numeric value between 0 and 65536
        ' Get our numeric variable location
        ' Convert buffer to a number
        If v = &HF2 Then
            ' We are inputting a numeric value
            v = Array(x) * 256 + Array(x + 1): x = x + 2
            NumType = Array(x): x = x + 1 ' Get the numeric Type
            Select Case NumType:
                Case 1, 2, 3, 4 ' 8 bit integer
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S8_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "B": C$ = "pull 1 byte off the stack": GoSub AO
                    A$ = "STB": B$ = "_Var_" + NumericVariable$(v): C$ = "Store B to Variable": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
                Case 5, 6 ' 16 bit integer
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S16_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D": C$ = "pull 2 bytes off the stack": GoSub AO
                    A$ = "STD": B$ = "_Var_" + NumericVariable$(v): C$ = "Store D to Variable": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
                Case 7, 8 ' 32 bit integer
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S32_Stack": C$ = "Convert ASCII text @X to a 32 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D,X": C$ = "pull 4 bytes off the stack": GoSub AO
                    A$ = "LDU": B$ = "#_Var_" + NumericVariable$(v) + "+4": C$ = "U points to Variable +4": GoSub AO
                    A$ = "PSHU": B$ = "D,X": C$ = "Store D,X": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
                Case 9, 10 ' 64 bit integer
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S64_Stack": C$ = "Convert ASCII text @X to a 64 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D,X,Y,U": C$ = "pull 8 bytes off the stack": GoSub AO
                    A$ = "STU": B$ = "_Var_" + NumericVariable$(v) + "+6": C$ = "Store U in variable +6": GoSub AO
                    A$ = "LDU": B$ = "#_Var_" + NumericVariable$(v) + "+6": C$ = "U points to Variable +6": GoSub AO
                    A$ = "PSHU": B$ = "D,X,Y": C$ = "store D,X,Y into the variable space": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
                Case 11 ' FFP format
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                    A$ = "PULS": B$ = "B,X": C$ = "pull 3 bytes off the stack": GoSub AO
                    A$ = "LDU": B$ = "#_Var_" + NumericVariable$(v) + "+3": C$ = "U points to Variable +3": GoSub AO
                    A$ = "PSHU": B$ = "B,X": C$ = "store B,X": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
                Case 12 ' Double format
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                    A$ = "JSR": B$ = "FFP_To_Double": C$ = "Convert FFP at ,S to 10 byte Double at ,S": GoSub AO
                    A$ = "PULL_DBL": B$ = " _Var_" + NumericVariable$(v): C$ = "Save Doouble on the stack to the variable": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
            End Select
        Else
            ' We are inputting a numeric array
            Print #1, "; Getting the numeric array memory location in X"
            v = Array(x) * 256 + Array(x + 1): x = x + 2
            NumBits = NumericArrayBits(v)
            Z$ = "; NumBits=" + Str$(NumBits): GoSub AO
            InsideArrayType = NumericArrayBits(v)
            If NumBits = 8 Then
                InsideArrayType = NT_UByte ' use 8-bit unsigned indices
            Else
                InsideArrayType = NT_UInt16 ' use 16-bit unsigned indices
            End If
            NV$ = NumericArrayVariables$(v)
            If Verbose > 3 Then Print "Numeric array variable is: "; NV$
            NumDims = Array(x): x = x + 1
            NVTArrayType = Array(x): x = x + 1 ' NVT1=Numeric Array Variable Type
            x = x + 2 ' Consume the $F5 & open bracket
            If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
            ' Get all the dimensions
            DimCounter = NumDims
            Z$ = "; Before dims - InsideArrayType=" + Str$(InsideArrayType): GoSub AO
            While DimCounter > 1
                GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
                GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
                NVT = InsideArrayType
                Z$ = "; InsideArrayType(NVT)=" + Str$(InsideArrayType): GoSub AO
                Z$ = "; LastType=" + Str$(LastType): GoSub AO
                GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
                DimCounter = DimCounter - 1
            Wend
            GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
            GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
            NVT = InsideArrayType
            GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
            ' We now have:
            ' NV$=NumArrayName
            ' Value in brackets is on the stack
            ' NumBits = number of bits (8 or 16)
            ' NumDims = Number of dimensions
            If NumDims = 1 And NVTArrayType < 5 Then
                ' This is a quick and easy location to calc and store
                A$ = "PULS": B$ = "B": C$ = "Array pointer, Fix the stack": GoSub AO
                A$ = "LDX": B$ = "#_ArrayNum_" + NV$ + "+1": C$ = "The array starts here": GoSub AO
                A$ = "ABX": C$ = "Make X point at the array location": GoSub AO
                A$ = "PSHS": B$ = "X": C$ = "Save the location to store the value": GoSub AO
            Else
                ' A = BytesPerEntry
                ' B = Number of Array Dimensions
                ' X = Array starts here (points at the sizes of each dimension)
                Select Case NVTArrayType
                    Case Is < 5
                        Num = 1
                    Case 5, 6
                        Num = 2
                    Case 7, 8
                        Num = 4
                    Case 9, 10
                        Num = 8
                    Case 11
                        Num = 3
                    Case 12
                        Num = 10
                End Select
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                Temp$ = Num$
                If NumDims = 1 Then
                    If NumBits = 8 Then
                        ' Handle an array with 8 bit indices
                        Z$ = "; Only 8 bit indices": GoSub AO
                        A$ = "LDA": B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
                        A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
                        A$ = "MUL": C$ = "Multiply them": GoSub AO
                        Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                        A$ = "PSHS": B$ = "D": C$ = "Save the location the array is pointing at on the stack": GoSub AO
                    Else
                        ' Handle an array with 16 bit indices
                        Z$ = "; Only 1 16 bit element array": GoSub AO
                        Z$ = "; d1 is already on the stack": GoSub AO
                        A$ = "LDD": B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
                        A$ = "PSHS": B$ = "D": C$ = "Save BytesPerEntry as 16 bit on the stack": GoSub AO
                        A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
                        A$ = "LDD": B$ = ",S": C$ = "Get the low 16 bit result in D": GoSub AO
                        Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                        A$ = "STD": B$ = ",S": C$ = "Save the location the array is pointing at": GoSub AO
                    End If
                Else
                    Num = NumDims - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A = BytesPerEntry, B = Dim count-1": GoSub AO
                    If NumBits = 8 Then
                        ' Handle an array with 8 bit indices
                        Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "LDU": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                        A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                    Else
                        ' Handle an array with 16 bit indices
                        Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "LDU": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                        A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                    End If
                End If
            End If
            Select Case NVTArrayType:
                Case 1, 2, 3, 4 ' 8 bit integer
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S8_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "B": C$ = "Number to store in array, fix the stack": GoSub AO
                    A$ = "STB": B$ = "[,S++]": C$ = "Save the byte and fix the stack": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
                Case 5, 6 ' 16 bit integer
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S16_Stack": C$ = "Convert ASCII text @X to a 16 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D": C$ = "Number to store in array, fix the stack": GoSub AO
                    A$ = "STD": B$ = "[,S++]": C$ = "Save the word and fix the stack": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
                Case 7, 8 ' 32 bit integer
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S32_Stack": C$ = "Convert ASCII text @X to a 32 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D,X,U": C$ = "pull 4 bytes off the stack and U = address where to store the result, fixed stack": GoSub AO
                    A$ = "STD": B$ = ",U": C$ = "Save the MSWord": GoSub AO
                    A$ = "STX": B$ = "2,U": C$ = "Save the LSWord": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
                Case 9, 10 ' 64 bit integer
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_S64_Stack": C$ = "Convert ASCII text @X to a 64 bit number @,S": GoSub AO
                    A$ = "PULS": B$ = "D,X,Y,U": C$ = "pull 4 bytes off the stack and U = address where to store the result, fixed stack": GoSub AO
                    A$ = "STD": B$ = "[,S]": C$ = "Save the word and fix the stack": GoSub AO
                    A$ = "LDD": B$ = ",S++": C$ = "D = address to Save the 64 bit value, fix the stack": GoSub AO
                    A$ = "EXG": B$ = "D,Y": C$ = "D= value of Y & Y now points at memory location to store the rest of the 64 bit number": GoSub AO
                    A$ = "STX": B$ = "2,Y": C$ = "Store 2nd Word": GoSub AO
                    A$ = "STD": B$ = "4,Y": C$ = "Store 3rd Word": GoSub AO
                    A$ = "STU": B$ = "6,Y": C$ = "Store 4th Word": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
                Case 11 ' FFP format
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                    A$ = "PULS": B$ = "B,X,U": C$ = "pull 3 bytes off the stack and U = address where to store the result, fixed stack": GoSub AO
                    A$ = "STB": B$ = ",U": C$ = "Save the MSWord": GoSub AO
                    A$ = "STX": B$ = "1,U": C$ = "Save the LSWord": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
                Case 12 ' Double format
                    A$ = "LDX": B$ = "Temp1": C$ = "X = current start address of the input text": GoSub AO
                    A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                    A$ = "JSR": B$ = "FFP_To_Double": C$ = "Convert FFP at ,S to 10 byte Double at ,S": GoSub AO
                    A$ = "LDU": B$ = "10,S": C$ = "U = Address where to store the 10 byte Double number": GoSub AO
                    A$ = "PULS": B$ = "D,X,Y": C$ = "pull 3 words off the stack, move stack": GoSub AO
                    A$ = "STD": B$ = ",U": C$ = "Save the 1st Word": GoSub AO
                    A$ = "STX": B$ = "2,U": C$ = "Save the 2nd Word": GoSub AO
                    A$ = "STY": B$ = "4,U": C$ = "Save the 3rd Word": GoSub AO
                    A$ = "PULS": B$ = "D,X,Y": C$ = "pull 2 words off the stack, fix stack": GoSub AO
                    A$ = "STD": B$ = "6,U": C$ = "Save the 4th Word": GoSub AO
                    A$ = "STX": B$ = "8,U": C$ = "Save the 5th Word": GoSub AO
                    A$ = "LDD": B$ = "Temp3": C$ = "D = location the ASCII # started": GoSub AO
                    A$ = "STD": B$ = "Temp1": C$ = "Update where to start looking for the next entry (after the last comma)": GoSub AO
            End Select
        End If
    Else
        If v = &HF1 Or v = &HF3 Then ' We are getting a string value
            ' B = length of the string
            ' #KeyBuff = start of the keyboard input buffer
            If v = &HF3 Then
                ' We are inputting a string variable
                v = Array(x) * 256 + Array(x + 1): x = x + 2
                Print #1, ""
                A$ = "LDX": B$ = "#_StrVar_" + StringVariable$(v): C$ = "X = destination address": GoSub AO
                A$ = "PSHS": B$ = "X": C$ = "Save the location the array is pointing at on the stack": GoSub AO
            Else
                ' We are inputting a string array
                Print #1, "; Getting the String array memory location in X"
                If Verbose > 3 Then Print "Going to deal with String array"
                v = Array(x) * 256 + Array(x + 1): x = x + 2
                NumBits = StringArrayBits(v)
                Z$ = "; NumBits =" + Str$(NumBits): GoSub AO
                If NumBits = 8 Then
                    InsideArrayType = NT_UByte ' use 8-bit unsigned indices
                Else
                    InsideArrayType = NT_UInt16 ' use 16-bit unsigned indices
                End If
                NV$ = StringArrayVariables$(v)
                If Verbose > 3 Then Print "String array variable is: "; NV$
                NumDims = Array(x): x = x + 1
                x = x + 2 ' Consume the $F5 & open bracket
                If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
                ' Get all the dimensions
                DimCounter = NumDims
                Z$ = "; InsideArrayType =" + Str$(InsideArrayType): GoSub AO
                Z$ = "; DimCounter =" + Str$(DimCounter): GoSub AO
                While DimCounter > 1
                    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
                    GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
                    NVT = InsideArrayType
                    GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
                    DimCounter = DimCounter - 1
                Wend
                GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
                GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
                NVT = InsideArrayType
                GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
                ' We now have:
                ' NV$=NumArrayName
                ' Value in brackets is on the stack
                ' NumBits = number of bits (8 or 16)
                ' NumDims = Number of dimensions
                Num = StringArraySize + 1 ' Length of each string +1 for the first byte which is the length of the particular string, when stored
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                Temp$ = Num$
                If NumDims = 1 Then
                    If NumBits = 8 Then
                        ' Handle an array with 8 bit indices
                        Z$ = "; Only 8 bit indices": GoSub AO
                        A$ = "LDA": B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
                        A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
                        A$ = "MUL": C$ = "Multiply them": GoSub AO
                        Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "ADDD": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                        A$ = "TFR": B$ = "D,X": C$ = "X = save location location": GoSub AO
                        A$ = "PSHS": B$ = "X": C$ = "Save the location the array is pointing at on the stack": GoSub AO
                    Else
                        ' Handle an array with 16 bit indices
                        Z$ = "; Only 1 16 bit element array": GoSub AO
                        Z$ = "; d1 is already on the stack": GoSub AO
                        A$ = "LDD": B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
                        A$ = "PSHS": B$ = "D": C$ = "Save BytesPerEntry as 16 bit on the stack": GoSub AO
                        A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
                        A$ = "LDD": B$ = ",S": C$ = "Get the low 16 bit result in D": GoSub AO
                        Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "ADDD": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                        A$ = "STD": B$ = ",S": C$ = "Save the location the array is pointing at": GoSub AO
                        A$ = "TFR": B$ = "D,X": C$ = "X = save location location": GoSub AO
                    End If
                Else
                    Num = NumDims - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A = BytesPerEntry, B = Dim count-1": GoSub AO
                    If NumBits = 8 Then
                        ' Handle an array with 8 bit values
                        Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "LDU": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                        A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                        A$ = "LDX": B$ = ",S": C$ = "Get X from the stack": GoSub AO
                    Else
                        ' Handle an array with 16 bit values
                        Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "LDU": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
                        A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
                        A$ = "LDX": B$ = ",S": C$ = "Get X from the stack": GoSub AO
                    End If
                End If
            End If
            A$ = "LEAX": B$ = "1,X": C$ = "Move X so it starts at the correct location": GoSub AO
            A$ = "LDU": B$ = "Temp1": C$ = "U = source starts address": GoSub AO
            A$ = "CLRB": C$ = "Clear the counter": GoSub AO
            Z$ = "!"
            A$ = "INCB": C$ = "Increment the counter": GoSub AO
            A$ = "LDA": B$ = ",U+": GoSub AO
            A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AO
            A$ = "CMPA": B$ = "#','": C$ = "Did we find a comma?": GoSub AO
            A$ = "BNE": B$ = "<": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "STB": B$ = "[,S++]": C$ = "Save the length of the string and fix the stack": GoSub AO
            A$ = "STU": B$ = "Temp1": C$ = "Update the start of the next input after the last comma": GoSub AO
        Else
            Print "Error2, can't figure out the INPUT variable in";: GoTo FoundError
        End If
    End If
    ' Check for a comma or end of line $0D
    v = Array(x): x = x + 1 ' get the &HF5
    If Array(x) = &H2C Then v = Array(x): x = x + 1 ' if found then consume the comma
Loop
v = Array(x): x = x + 1
Return


' NTSC_FONTCOLOURS RND(256)-1,RND(256)-1  - Sets the background and forground colour values
DoNTSCFontColours:
If Gmode > 159 Then
    ' Get the numeric value before a comma
    ' Get first number in D
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
    GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
    A$ = "STB": B$ = "G_Background": C$ = "Save the background colour for the CoCo 3 NTSC composite font": GoSub AO
    'x in the array will now be pointing just past the ,
    GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
    GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
    A$ = "STB": B$ = "G_Foreground": C$ = "Save the foreground colour for the CoCo 3 NTSC composite font": GoSub AO
    Return
Else
    Print "ERROR - Can only use the NTSC_FONTCOLOURS command with GMODE screens that are 160 or higher on";: GoTo FoundError
End If

DoREM:
DoREMApostrophe:
' Check for special commands in a REM or ' line
Temp$ = ""
v = Array(x): x = x + 1
Do Until v = TK_SpecialChar And Array(x) = TK_EOL
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
    While v <> TK_EOL
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

' GCopy SourcePage, DestPage
DoGCOPY:
' Get the numeric value before a comma
' Get source Page in B
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
If Gmode = 0 Or Gmode = 1 Or Gmode = 2 Or Gmode = 4 Then
    ' For the Text screen we move past the Disk variable area
    A$ = "TSTB": C$ = "Check if B = 0": GoSub AO
    A$ = "BNE": B$ = ">": C$ = "Skip ahead if it's 0": GoSub AO
    A$ = "ADDB": B$ = "#$04": C$ = "Add 4": GoSub AO
    Z$ = "!"
End If
A$ = "PSHS": B$ = "B": C$ = "Save the Source Graphics Page # on the stack": GoSub AO
'Get Destination page value inB
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
If Gmode = 0 Or Gmode = 1 Or Gmode = 2 Or Gmode = 4 Then
    ' For the Text screen we move past the Disk variable area
    A$ = "TSTB": C$ = "Check if B = 0": GoSub AO
    A$ = "BNE": B$ = ">": C$ = "Skip ahead if it's 0": GoSub AO
    A$ = "ADDB": B$ = "#$04": C$ = "Add 4": GoSub AO
    Z$ = "!"
End If
' Figure out the start of the source page
If Gmode < 100 Then
    ' Copy CoCo 1 & 2 graphic screens
    A$ = "CLRA": C$ = "Clear MSB": GoSub AO
    A$ = "LDX": B$ = "#$" + GModeScreenSize$(Gmode): C$ = "Get the Size of a graphics screen": GoSub AO
    A$ = "PSHS": B$ = "D,X": C$ = "Save the two 16 bit WORDS on the stack, to be multiplied": GoSub AO
    A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
    A$ = "LEAU": B$ = "$" + GModeStartAddress$(Gmode)+",X": C$ = "U = Destination screen location": GoSub AO

    A$ = "CLRA": C$ = "Clear MSB": GoSub AO
    A$ = "LDB": B$ = "2,S": C$ = "Get the Source Graphics Page #": GoSub AO
    A$ = "LDX": B$ = "#$" + GModeScreenSize$(Gmode): C$ = "Get the Size of a graphics screen": GoSub AO
    A$ = "PSHS": B$ = "D,X": C$ = "Save the two 16 bit WORDS on the stack, to be multiplied": GoSub AO
    A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
    A$ = "LEAX": B$ = "$" + GModeStartAddress$(Gmode)+",X": C$ = "X = Source screen location": GoSub AO
     
    A$ = "LEAS": B$ = "5,S": C$ = "Fix the stack": GoSub AO
    A$ = "LDD": B$ = "#$" + GModeScreenSize$(Gmode): C$ = "Get the Size of a graphics screen": GoSub AO
    A$ = "LSRA": C$ = "Logical Shift Right": GoSub AO
    A$ = "RORB": C$ = "D=D/2, two bytes copied at a time": GoSub AO
    A$ = "TFR": B$ = "D,Y": C$ = "Save the # of words to copy in Y": GoSub AO

    Z$ = "!": A$ = "LDD": B$ = ",X++": C$ = "Get a word from the source graphics screen": GoSub AO
    A$ = "STD": B$ = ",U++": C$ = "Save the word to the destination graphics screen": GoSub AO
    A$ = "LEAY": B$ = "-1,Y": C$ = "Decrement the word counter": GoSub AO
    A$ = "BNE": B$ = "<": C$ = "If not zero yet then keep copying": GoSub AO
Else
    ' Copy CoCo 3 graphic screens
    ' Figure out the Source $2000 byte block and the destination $2000 byte block and how many blocks to copy
    A$ = "PSHS": B$ = "B": C$ = "Save the Destination Graphics Page # on the stack": GoSub AO
    A$ = "LDD": B$ = "#$" + GModeScreenSize$(Gmode): C$ = "Get the Size of a graphics screen": GoSub AO
    A$ = "SUBD": B$ = "#$0001": C$ = "Just in case we have a value like $6000 make it $5FFF": GoSub AO
    A$ = "LSLA": C$ = "Logical Shift Left": GoSub AO
    A$ = "ROLB": C$ = "Copy into B": GoSub AO
    A$ = "LSLA": C$ = "Logical Shift Left": GoSub AO
    A$ = "ROLB": C$ = "Copy into B": GoSub AO
    A$ = "LSLA": C$ = "Logical Shift Left": GoSub AO
    A$ = "ROLB": C$ = "Copy into B": GoSub AO
    A$ = "ANDB": B$ = "#%00000111": C$ = "Value is 0 to 3": GoSub AO
    A$ = "INCB": C$ = "B now has the number of $2000 byte blocks to copy": GoSub AO
    A$ = "PSHS": B$ = "B": C$ = "Save the # of $2000 byte blocks to copy on the stack": GoSub AO

    A$ = "LDA": B$ = "2,S": C$ = "Get the Source Graphics Page #": GoSub AO
    A$ = "MUL": C$ = "B now has the Block # to start copying from": GoSub AO
    A$ = "STB": B$ = "2,S": C$ = "Save the Source $2000 byte block #": GoSub AO

    A$ = "LDA": B$ = "1,S": C$ = "Get the Destination Graphics Page #": GoSub AO
    A$ = "LDB": B$ = ",S": C$ = "B = # of blocks to copy per screen": GoSub AO
    A$ = "MUL": C$ = "B now has the Block # to start copying from": GoSub AO
    A$ = "STB": B$ = "1,S": C$ = "Save the Destination 2k Block #": GoSub AO
    A$ = "JSR": B$ = "GCopy_CoCo3": C$ = "Go copy the CoCo 3 graphic screens": GoSub AO
    A$ = "LEAS": B$ = "3,S": C$ = "Fix the Stack": GoSub AO
End If
Return

' GMODE ScreenMode, ScreenPage
DoGMODE:
If Array(x) = TK_SpecialChar And Array(x + 1) = TK_Comma Then x = x + 2: GoTo GModePage ' No GMODE # just the screen Page
' Get the numeric value before a comma or EOL or Colon
' Get first number in D
' Get the number that is stored as ASCII into a value QB64 can use, so it can keep track of the Graphics mode it is using
v = Array(x): x = x + 1: v$ = Chr$(v)
While Array(x) <> TK_SpecialChar
    v = Array(x): x = x + 1: v$ = v$ + Chr$(v)
Wend
Gmode = Val(v$) ' Set the Gmode # as we need this in order to use all the correct graphics routines for this mode
x = x + 1 ' Skip the TK_SpecialChar
v = Array(x): x = x + 1 ' Get the next byte in v
If v = TK_EOL Or v = TK_Colon Then
    ' No Comma, then use the Start Address for the first page
    A$ = "CLR": B$ = "GModePage": C$ = "Set page # to zero": GoSub AO
    GoTo GModeSkipScreen
End If
If v <> TK_Comma Then Print "Should have a Comma in the GMODE command on";: GoTo FoundError
GModePage:
' Get the numeric value before an EOL or Colon
'Get Page value in D (we only use B)
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
A$ = "STB": B$ = "GModePage": C$ = "Save the screen Page #": GoSub AO
GModeSkipScreen:
If Gmode > 99 Then
    ' We are using a CoCo 3 graphics mode
    If Gmode > 159 And FirstGmode = 0 Then
        ' Set the Palette to the special NTSC 256 colour versions
        Z$ = "; First GMODE, Set the special Palette for the composite 256 colour mode": GoSub AO
        A$ = "LDD": B$ = "#$0010": C$ = "Palette values for index 0 & 1": GoSub AO
        A$ = "STD": B$ = "$FFB0": C$ = "Update Palette 0 & 1": GoSub AO
        A$ = "LDD": B$ = "#$2030": C$ = "Palette values for index 2 & 3": GoSub AO
        A$ = "STD": B$ = "$FFB2": C$ = "Update Palette 2 & 3": GoSub AO
    End If
    A$ = "LDD": B$ = "#$" + GModeStartAddress$(Gmode): C$ = "A = the location in RAM to start the graphics screen": GoSub AO
    A$ = "STD": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO

    v1 = Val("&H" + GModeScreenSize$(Gmode))
    TempVal = 0
    While (TempVal < v1): TempVal = TempVal + &H2000: Wend ' Get the number of bytes needed per screen at this resolution
    TempVal = TempVal / &H2000 ' Get the block numbers required
    A$ = "LDA": B$ = "#$" + Right$("00" + Hex$(TempVal), 2): C$ = "A = # of $2000 blocks required per screen": GoSub AO
    A$ = "LDB": B$ = "GModePage": C$ = "Get the screen Page #": GoSub AO
    A$ = "MUL": C$ = "B = Blocks required per screen * the Screen requested": GoSub AO
    A$ = "STB": B$ = "CC3ScreenStart": C$ = "Save the screen block location": GoSub AO
Else
    ' We are using a CoCo 1 or CoCo 2 graphics mode
    GScreenStart = Val("&H" + GModeStartAddress$(Gmode)) ' Get screen start location
    v1 = Val("&H" + GModeScreenSize$(Gmode)) ' v1 = The screen size
    ' We are starting from the normal Text screen location
    
    A$ = "CLRA": C$ = "Get the screen Page #": GoSub AO
    A$ = "LDB": B$ = "GModePage": C$ = "Get the screen Page #": GoSub AO
    A$ = "BEQ": B$ = ">": C$ = "If first page then skip calc where to set the graphics page viewer": GoSub AO
    If Gmode = 0 Or Gmode = 1 Or Gmode = 2 Or Gmode = 4 Then
        ' For the Text screen we move past the Disk variable area
        TempVal = GScreenStart + &HE00 - &H400 - &H200 '2nd page start here
    Else
        TempVal = GScreenStart '1st Page starts here
    End If
    '    A$ = "CLRA": C$ = "Clear MSB of D": GoSub AO
    '    A$ = "LDB": B$ = "GModePage": C$ = "D = the screen Page #": GoSub AO
    '    A$ = "DECB": C$ = "D = the screen Page # - 1": GoSub AO
    '    A$ = "BEQ": B$ = ">": C$ = "If D = 0 then the result of the multiply will be zero so skip it": GoSub AO
    A$ = "LDX": B$ = "#$" + Right$("0000" + Hex$(v1), 4): C$ = "X = the screen size": GoSub AO
    A$ = "PSHS": B$ = "D,X": C$ = "Save the two 16 bit WORDS on the stack, to be multiplied": GoSub AO
    A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
    A$ = "PULS": B$ = "D": C$ = "Get the low 16 bit result in D, fix the stack": GoSub AO
    Z$ = "!": A$ = "ADDD": B$ = "#$" + Right$("0000" + Hex$(TempVal), 4): C$ = "D = Screen Page + Screen start location": GoSub AO
    Z$ = "@UpdateScreenStart": GoSub AO
    A$ = "STD": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
    Print #1,
    ' Skip actually going into graphics mode, that should be done with the screen command
    '    A$ = "LSRA": C$ = "A = the location in RAM to start the graphics screen / 2 as it must start in a 512 byte block": GoSub AO
    '    ' Wait for vsync
    '    A$ = "LDB": B$ = "$FF02": C$ = "Reset Vsync flag": GoSub AO
    '    Z$ = "!": A$ = "LDB": B$ = "$FF03": C$ = "See if Vsync has occurred yet": GoSub AO
    '    A$ = "BPL": B$ = "<": C$ = "If not then keep looping, until the Vsync occurs": GoSub AO
    '    A$ = "JSR": B$ = "SetGraphicsStartA": C$ = "Go setup the screen start location": GoSub AO
End If
If FirstGmode = 0 Then
    FirstGmode = 1
End If
Return

' Colour a new graphics screen mode GCLS variable, variable is the colour #
DoGCLS:
If Array(x) = &HF5 And (Array(x + 1) = &H0D Or Array(x + 1) = &H3A) Then
    ' no Value given for the GCLS colour, use the default forground colour
    A$ = "LDB": B$ = "BAKCOL": C$ = "Make B the current background colour": GoSub AO
    GoTo SkipGettingColour ' skip ahead
End If
'Get the colour value in D
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
SkipGettingColour:
If Gmode > 99 Then
    ' Handle CoCo 3 graphic command
    A$ = "LDY": B$ = "#GCLS_" + GModeName$(Gmode): C$ = "Y points at the routine to do": GoSub AO
    A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
Else
    A$ = "JSR": B$ = "GCLS_" + GModeName$(Gmode): C$ = "Go colour the screen with the colour in B": GoSub AO
End If
Return

DoSCREEN:
' Wait for vsync
A$ = "LDB": B$ = "$FF02": C$ = "Reset Vsync flag": GoSub AO
Z$ = "!": A$ = "LDB": B$ = "$FF03": C$ = "See if Vsync has occurred yet": GoSub AO
A$ = "BPL": B$ = "<": C$ = "If not then keep looping, until the Vsync occurs": GoSub AO
If Array(x) = TK_SpecialChar And Array(x + 1) = TK_Comma Then x = x + 2: GoTo ColourSet ' No Screen Mode # just the colour mode#
' Get the numeric value before a comma or EOL or Colon
' Get first number in D
GoSub GetExpressionB4SemiComEOL: x = x + 2 ' Get an Expression before a semi colon, a comma or an EOL, move past them
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
' B = Screen mode (0=text else show graphics screen)
If Sp = TK_EOL Or Sp = TK_Colon Then
    ' No Comma then we only do a screen mode change
    GoTo ScreenSkipColourSet
Else
    A$ = "PSHS": B$ = "B": C$ = "Save Screen Mode # on the stack": GoSub AO
End If
If Sp <> TK_Comma Then Print "Should have a Comma in the SCREEN command on";: GoTo FoundError
ColourSet:
'Get the Colour set number in D (we only use B)
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
' B = Color Set
' Change the Color mode to value in B (0 or 1)
A$ = "TSTB": C$ = "Test B": GoSub AO
A$ = "BEQ": B$ = ">": C$ = "IF B = 0, use B as is": GoSub AO
A$ = "LDB": B$ = "#%00001000": C$ = "ELSE make B = 8": GoSub AO
Z$ = "!"
A$ = "STB": B$ = "CSSVAL": C$ = "Save the CSSVAL for setting the VDG CSS settings": GoSub AO
A$ = "PULS": B$ = "B": C$ = "Get the Screen Mode off the stack": GoSub AO
ScreenSkipColourSet:
' B = Screen mode 0 = Text, anything else is graphics screen mode
A$ = "TSTB": C$ = "Test B": GoSub AO
A$ = "BNE": B$ = "@DoGraphicMode": C$ = "Skip ahead if graphics mode requested": GoSub AO
A$ = "LDX": B$ = "#$0400": C$ = "Text screen starts here": GoSub AO
A$ = "STX": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
A$ = "LDA": B$ = "#$0F": C$ = "$0F Back to Text Mode for the CoCo 3": GoSub AO
A$ = "STA": B$ = "$FF9C": C$ = "Neccesary for CoCo 3 GIME to use this mode": GoSub AO
If Gmode > 99 Then
    ' We are using a CoCo 3 graphics mode, Go to CoCo 3 Text mode
    A$ = "LDA": B$ = "#$CC": GoSub AO
    A$ = "STA": B$ = "$FF90": GoSub AO
    A$ = "LDD": B$ = "#$0000": GoSub AO
    A$ = "STD": B$ = "$FF98": GoSub AO
    A$ = "STD": B$ = "$FF9A": GoSub AO
    A$ = "STD": B$ = "$FF9E": GoSub AO
    A$ = "LDD": B$ = "#$0FE0": GoSub AO
    A$ = "STD": B$ = "$FF9C": GoSub AO
End If
A$ = "LDA": B$ = "#Internal_Alphanumeric": C$ = "A = Text mode requested": GoSub AO
A$ = "BRA": B$ = ">": GoSub AO
Z$ = "@DoGraphicMode:": GoSub AO
If Gmode > 99 Then
    ' We are using a CoCo 3 graphics mode
    A$ = "LDA": B$ = "#%01111100": C$ = "CoCo 3 Mode, MMU Enabled, GIME IRQ Enabled, GIME FIRQ Enabled, Vector RAM at FEXX enabled, Standard SCS Normal, ROM Map 16k Int, 16k Ext": GoSub AO
    A$ = "STA": B$ = "$FF90": C$ = "Make the changes": GoSub AO
    A$ = "LDD": B$ = "#$" + GModeStartAddress$(Gmode): C$ = "A = the location in RAM to start the graphics screen": GoSub AO
    A$ = "STD": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
    A$ = "LDA": B$ = "#" + GMode$(Gmode): C$ = "A = Graphic mode requested": GoSub AO
    A$ = "STA": B$ = "$FF99": C$ = "Vid_Res_Reg": GoSub AO
    A$ = "LDA": B$ = "#%10000000": GoSub AO
    A$ = "STA": B$ = "$FF98": C$ = "Video_Mode_Register, Graphics mode, Colour output, 60 hz, max vertical res": GoSub AO
    A$ = "LDA": B$ = "CC3ScreenStart": C$ = "A = $2000 screen block location": GoSub AO
    A$ = "CLRB": C$ = "CLEAR B": GoSub AO
    A$ = "LSLA": C$ = "A=A*2": GoSub AO
    A$ = "LSLA": C$ = "A=A*4": GoSub AO
    A$ = "STD": B$ = "$FF9D": C$ = "Update the VidStart": GoSub AO
    A$ = "CLR": B$ = "$FF9F": C$ = "Hor_Offset_Reg, Don't use a Horizontal offset": GoSub AO
    A$ = "BRA": B$ = "@Done": C$ = "Skip ahead": GoSub AO
    '    Print #1, ' Need a space for @ in assembly
    '    Return
Else
    If Gmode = 4 Or Gmode = 7 Then
        A$ = "LDA": B$ = "#9": C$ = "9 for Semigrpahics 6 or 12": GoSub AO
        A$ = "STA": B$ = "$FF9C": C$ = "Neccesary for CoCo 3 GIME to use this mode": GoSub AO
    End If
    If Gmode = 8 Then
        A$ = "LDA": B$ = "#10": C$ = "10 for Semigrpahics 24": GoSub AO
        A$ = "STA": B$ = "$FF9C": C$ = "Neccesary for CoCo 3 GIME to use this mode": GoSub AO
    End If
    A$ = "CLRA": C$ = "D=B": GoSub AO
    A$ = "LDB": B$ = "GModePage": C$ = "Get the screen Page #": GoSub AO
    A$ = "BEQ": B$ = "@Skip1": C$ = "If first page skip ahead, else calc where to set the graphics page viewer": GoSub AO
'    A$ = "LDD": B$ = "#$" + GModeStartAddress$(Gmode): C$ = "A = the location in RAM to start the graphics screen": GoSub AO
'    A$ = "BRA": B$ = "@UpdateScreenStart": C$ = "Go update the screen start location"
    A$ = "LDX": B$ = "#$" + GModeScreenSize$(Gmode): C$ = "X = the screen size": GoSub AO
    A$ = "PSHS": B$ = "D,X": C$ = "Save the two 16 bit WORDS on the stack, to be multiplied": GoSub AO
    A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
    A$ = "PULS": B$ = "D": C$ = "Get the low 16 bit result in D, fix the stack": GoSub AO
    Z$ = "@Skip1"
    A$ = "ADDD": B$ = "#$0E00": C$ = "D = Screen Page + Screen start location": GoSub AO
    Z$ = "@UpdateScreenStart": GoSub AO
    A$ = "STD": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
    A$ = "LDA": B$ = "#" + GMode$(Gmode): C$ = "A = Graphic mode requested": GoSub AO
End If
Z$ = "!"
A$ = "ORA": B$ = "CSSVAL": C$ = "Add in the colour select value into A": GoSub AO
' Update the Graphic mode and the screen viewer location
A$ = "JSR": B$ = "SetGraphicModeA": C$ = "Go setup the mode": GoSub AO
A$ = "LDA": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
A$ = "LSRA": C$ = "Divide by 2 - 512 bytes per start location": GoSub AO
A$ = "JSR": B$ = "SetGraphicsStartA": C$ = "Go set the address of the screen": GoSub AO
Z$ = "@Done": GoSub AO
Print #1, ' Need a space for @ in assembly
Return

DoGOSUB:
Temp$ = ""
v = Array(x): x = x + 1
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' could be EOL or a colon if it's part of an IF/THEN/ELSE or REMark
    Temp$ = Temp$ + Chr$(v)
    v = Array(x): x = x + 1
Loop
x = x + 1
A$ = "JSR": B$ = "_L" + Temp$: C$ = "GOSUB " + Temp$: GoSub AO
Return

DoGOTO:
Temp$ = ""
v = Array(x): x = x + 1
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' could be EOL or a colon if it's part of an IF/THEN/ELSE or REMark
    Temp$ = Temp$ + Chr$(v)
    v = Array(x): x = x + 1
Loop
x = x + 1
A$ = "JMP": B$ = "_L" + Temp$: C$ = "GOTO " + Temp$: GoSub AO
Return

DoRETURN:
A$ = "RTS": C$ = "RETURN": GoSub AO
GoTo SkipUntilEOLColon ' Skip until we find an EOL or colon then return

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
A$ = "LDD": B$ = "EveryCasePointer": C$ = "Get the Flag pointer in D": GoSub AO
A$ = "ADDD": B$ = "#2": C$ = "D=D+2, move the pointer to the next flag": GoSub AO
A$ = "STD": B$ = "EveryCasePointer": C$ = "Save the new pointer in EveryCasePointer": GoSub AO
Num = EvCase(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
A$ = "LDD": B$ = "#" + Num$ + "*$100": C$ = "A = The flag if this is an EveryCase=1 or a CASE=0 and clear B": GoSub AO
A$ = "STD": B$ = "[EveryCasePointer]": C$ = "Save the value pointer in the EveryCaseStack": GoSub AO
Return




DoSET:
If Array(x) <> &HF5 Or Array(x + 1) <> &H28 Then Print "Can't find open bracket for SET command on";: GoTo FoundError
' Get the x co-ordinate
x = x + 2 'move past the open bracket
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma & move past it
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
GoSub VerifyX ' Add code to make sure X value is in bounds of screen size
If Val(GModeMaxX$(Gmode)) > 255 Then
    A$ = "PSHS": B$ = "D": C$ = "Save the loction of the X co-ordinate": GoSub AO
Else
    A$ = "PSHS": B$ = "B": C$ = "Save the loction of the X co-ordinate": GoSub AO
End If
' Get the y co-ordinate
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
GoSub VerifyY ' Add code to make sure Y value is in bounds of screen size
A$ = "PSHS": B$ = "B": C$ = "Save the loction of the Y co-ordinate": GoSub AO
Print #1, ' Need a space for @ in assembly
' Get the colour to set on screen
GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
If Val(GModeColours$(Gmode)) = 16 Then
    ' Handle CoCo 3 with 16 colours, copy colour to the high nibble
    A$ = "ANDB": B$ = "#%00001111": C$ = "Keep the right nibble value": GoSub AO
    A$ = "PSHS": B$ = "B": C$ = "Save it on the stack": GoSub AO
    A$ = "LSLB": C$ = "Move the bits left": GoSub AO
    A$ = "LSLB": C$ = "Move the bits left": GoSub AO
    A$ = "LSLB": C$ = "Move the bits left": GoSub AO
    A$ = "LSLB": C$ = "Move the bits left, now they are in the high nibble": GoSub AO
    A$ = "ORB": B$ = ",S+": C$ = "B now has the value in the high nibble and the low nibble": GoSub AO
End If
A$ = "STB": B$ = "LineColour": C$ = "Save the colour to set the pixel": GoSub AO
If Gmode > 99 Then
    ' Handle CoCo 3 graphic command
    A$ = "LDY": B$ = "#DoSet_" + GModeName$(Gmode): C$ = "Y points at the routine to do": GoSub AO
    If Val(GModeMaxX$(Gmode)) > 255 Then
        ' Using a screen of 320 pixels wide or larger
        A$ = "PULS": B$ = "A": C$ = "Get the Y co-ordinates in A": GoSub AO
        A$ = "PULS": B$ = "X": C$ = "Get the X co-ordinates in X": GoSub AO
        A$ = "JSR": B$ = "DoCC3GraphicsBigX": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
    Else
        A$ = "PULS": B$ = "D": C$ = "Get the Y & X co-ordinates in A & B": GoSub AO
        A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
    End If
Else
    A$ = "PULS": B$ = "D": C$ = "Get the Y & X co-ordinates in A & B": GoSub AO
    A$ = "JSR": B$ = "DoSet_" + GModeName$(Gmode): C$ = "Go set the pixel on the " + GModeName$(Gmode) + " screen": GoSub AO
End If
GoTo SkipUntilEOLColon ' Skip until we find an EOL or a Colon and return

DoCASE:
' Noraml CASE
CaseCount(SELECTStackPointer) = CaseCount(SELECTStackPointer) + 1
Num = SELECTSTack(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
If CaseCount(SELECTStackPointer) > 1 Then
    If EvCase(SELECTStackPointer) = 0 Then
        ' Not an EVERYCASE
        A$ = "JMP": B$ = "_EndSelect_" + Num$: C$ = "Last Case code is complete so ignore the other CASEs": GoSub AO
    End If
End If
CaseNumber$ = Num$
Num = CaseCount(SELECTStackPointer) + 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
NextCaseNumber$ = CaseNumber$ + "_" + Num$
Num = CaseCount(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
CaseNumber$ = CaseNumber$ + "_" + Num$
Z$ = "_CaseCheck_" + CaseNumber$: C$ = "Start of the next CASE": GoSub AO

' Check for CASE ELSE
If Array(x) = &HFF And Array(x + 1) * 256 + Array(x + 2) = ELSE_CMD Then
    ' CASE ELSE
    CaseElseFlag = 1
    Num = SELECTSTack(SELECTStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    Z$ = "; CASE ELSE Code for SELECT " + Num$: GoSub AO
    GoSub SkipUntilEOLColon ' Skip until we find an EOL or a Colon and return
    A$ = "LDD": B$ = "[EveryCasePointer]": C$ = "A = flag pointer for everycase": GoSub AO
    '    A$ = "TSTA": C$ = "Get the CASE/EVERYCASE Flag": GoSub AO
    '    A$ = "BNE": B$ = "_EndSelect_" + Num$: C$ = "Skip if this is a CASE (EVERYCASE flag = 1)": GoSub AO
    A$ = "TSTB": C$ = "If we are doing an EVERYCASE, Check if we've done at least one CASE": GoSub AO
    A$ = "LBNE": B$ = "_EndSelect_" + Num$: C$ = "If we've done more than zero then Skip to the END SELECT": GoSub AO
Else
    ' Check for IS,    DoIS = &H60
    If Array(x) = &HFF And Array(x + 1) * 256 + Array(x + 2) = IS_CMD Then
        ' Found an IS to deal with
        CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(Array(x + 3)) + Chr$(Array(x + 4)) ' Get the <,=,> after IS
        x = x + 5 ' move forward
        GoSub GetExpressionB4EOL: x = x + 2 ' Get the expression before an End of Line or Colon in Expression$ & move past it
        Expression$ = CheckIfTrue$ + Expression$ ' CheckIfTrue$ = CheckIfTrue$ + Expression$
        '        GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
        '        GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
        GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
        A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO

        A$ = "LBEQ": B$ = "_CaseCheck_" + NextCaseNumber$: C$ = "If result is zero = False then jump to the next case/ELSE Case or END Select": GoSub AO
        If EvCase(SELECTStackPointer) = 1 Then
            ' We are in an EVERYCASE
            A$ = "LDD": B$ = "#$0101": C$ = "flag that we've done at least one CASE": GoSub AO
            A$ = "STD": B$ = "[EveryCasePointer]": C$ = " = flag pointer for everycase": GoSub AO
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
            Expression$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3E) + Chr$(&HFC) + Chr$(&H3D) + Expression$ ' MainCase >= Expression$        ' CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3E) + Chr$(&HFC) + Chr$(&H3D) + Expression$ ' MainCase >= Expression$
            '   GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
            '   GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
            GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
            A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO

            A$ = "LBEQ": B$ = "_CaseCheck_" + NextCaseNumber$: C$ = "If result is zero = False then jump to the next case/ELSE Case or END Select": GoSub AO
            x = PointAtTO + 3 ' Now point at the value just after the TO command
            GoSub GetExpressionB4EOL: x = x + 2 ' Get the expression before an End of Line or COLON in Expression$  & move past EOL/Colon
            Expression$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3C) + Chr$(&HFC) + Chr$(&H3D) + Expression$ ' MainCase <= Expression$ '    CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3C) + Chr$(&HFC) + Chr$(&H3D) + Expression$ ' MainCase <= Expression$
            '    GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
            '    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
            GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
            A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO

            A$ = "LBEQ": B$ = "_CaseCheck_" + NextCaseNumber$: C$ = "If result is zero = False then jump to the next case/ELSE Case or END Select": GoSub AO
            If EvCase(SELECTStackPointer) = 1 Then
                ' We are in an EVERYCASE
                A$ = "LDD": B$ = "#$0101": C$ = "flag that we've done at least one CASE": GoSub AO
                A$ = "STD": B$ = "[EveryCasePointer]": C$ = " = flag pointer for everycase": GoSub AO
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
                    Expression$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3D) + Left$(CaseTemp$, CommaPos - 2) 'Maincase$=CaseTemp before the comma '       CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3D) + Left$(CaseTemp$, CommaPos - 2) 'Maincase$=CaseTemp before the comma
                    CaseTemp$ = Right$(CaseTemp$, Len(CaseTemp$) - CommaPos)
                    CommaPos = InStr(CaseTemp$, ",")
                    '    GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
                    '    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
                    GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
                    A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO

                    A$ = "LBNE": B$ = "_DOCase_" + CaseNumber$: C$ = "If result is not zero = True so jump to the code after this case": GoSub AO
                Wend
                Expression$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3D) + CaseTemp$ 'Maincase$=CaseTemp     ' CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3D) + CaseTemp$ 'Maincase$=CaseTemp
                '   GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
                '   GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
                GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
                A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO

                A$ = "LBEQ": B$ = "_CaseCheck_" + NextCaseNumber$: C$ = "If result is zero = False then jump to the next case/ELSE Case or END Select": GoSub AO
                Z$ = "_DOCase_" + CaseNumber$: C$ = "Case match, do the code for this CASE": GoSub AO
                If EvCase(SELECTStackPointer) = 1 Then
                    ' We are in an EVERYCASE
                    A$ = "LDD": B$ = "#$0101": C$ = "flag that we've done at least one CASE": GoSub AO
                    A$ = "STD": B$ = "[EveryCasePointer]": C$ = " = flag pointer for everycase": GoSub AO
                End If
            Else
                ' No commas to deal with
                ' No TO, just a regular CASE to compare with
                Expression$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3D) + CaseTemp$ 'Maincase$=CaseTemp ' CheckIfTrue$ = MainCase$(SELECTStackPointer) + Chr$(&HFC) + Chr$(&H3D) + CaseTemp$ 'Maincase$=CaseTemp
                '    GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
                '    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
                GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
                A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO

                A$ = "LBEQ": B$ = "_CaseCheck_" + NextCaseNumber$: C$ = "If result is zero = False then jump to the next case/ELSE Case or END Select": GoSub AO
                If EvCase(SELECTStackPointer) = 1 Then
                    ' We are in an EVERYCASE
                    A$ = "LDD": B$ = "#$0101": C$ = "flag that we've done at least one CASE": GoSub AO
                    A$ = "STD": B$ = "[EveryCasePointer]": C$ = " = flag pointer for everycase": GoSub AO
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

DoEXIT:
v = Array(x): x = x + 1 ' get the EXIT command/Type
If v <> &HFF Then Print "Don't know what kind of EXIT to do on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2
If v = WHILE_CMD Then
    'Do an EXIT WHILE
    Num = WHILEStack(WhileStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    A$ = "JMP": B$ = "Wend_" + Num$: C$ = "End of WHILE/WEND loop": GoSub AO
    Return
End If
If v = FOR_CMD Then
    'Do an EXIT FOR
    Num = FORSTack(FORStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    A$ = "JMP": B$ = "NEXTDone_" + Num$: C$ = "End of FOR/NEXT loop": GoSub AO
    Return
End If
If v = DO_CMD Then
    'Do an EXIT DO
    Num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    A$ = "JMP": B$ = "DoneLoop_" + Num$: C$ = "End of DO/Loop": GoSub AO
    Return
End If
Print "Don't know what kind of EXIT to do on";: GoTo FoundError

DoDO:
DOCount = DOCount + 1
DOStackPointer = DOStackPointer + 1
DOStack(DOStackPointer) = DOCount
Num = DOCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
Z$ = "DOStart_" + Num$: C$ = "Start of WHILE/UNTIL loop": GoSub AO
v = Array(x): x = x + 1
If v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then
    ' Just a DO command without WHILE or UNTIL
    v = Array(x): x = x + 1
    Return
End If
If v <> &HFF Then Print "Don't know what to do after the DO command on";: GoTo FoundError
v = Array(x) * 256 + Array(x + 1): x = x + 2 ' The actual type to DO
Select Case v
    Case WHILE_CMD
        'DO WHILE - WHILE checks if the condition is true each time before running code.
        CheckIfTrue$ = ""
        v = 0
        Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' Keep copying until we get EOL or Colon
            v = Array(x): x = x + 1
            If v <> Asc(" ") Then CheckIfTrue$ = CheckIfTrue$ + Chr$(v) 'skip spaces
        Loop
        v = Array(x): x = x + 1
        Expression$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HF5 on the end
        '    GoSub GoCheckIfTrue ' This parses CheckIfTrue$ get's it ready to be evaluated in the string NewString$
        '    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN

        GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable

        Num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If Num < 10 Then Num$ = "0" + Num$
        A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO
        A$ = "LBEQ": B$ = "DoneLoop_" + Num$: C$ = "If the result is false then exit the DO/Loop": GoSub AO
        Return
    Case UNTIL_CMD
        'Do a DO UNTIL - UNTIL checks if the condition is false each time before running code.
        CheckIfTrue$ = ""
        v = 0
        Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' Keep copying until we get EOL or Colon
            v = Array(x): x = x + 1
            If v <> Asc(" ") Then CheckIfTrue$ = CheckIfTrue$ + Chr$(v) 'skip spaces
        Loop
        v = Array(x): x = x + 1
        Expression$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HF5 on the end
        '    GoSub GoCheckIfTrue ' This parses CheckIfTrue$ get's it ready to be evaluated in the string NewString$
        '    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN

        GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable

        Num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If Num < 10 Then Num$ = "0" + Num$
        A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO
        A$ = "LBNE": B$ = "DoneLoop_" + Num$: C$ = "If the result is true exit the DO/Loop": GoSub AO
        Return
End Select
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
    Num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    A$ = "JMP": B$ = "DOStart_" + Num$: C$ = "Go to the start of the DO loop": GoSub AO
    Z$ = "DoneLoop_" + Num$: C$ = "End of DO Loop": GoSub AO
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
    Expression$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HF5 on the end
    '    GoSub GoCheckIfTrue ' This parses CheckIfTrue$ get's it ready to be evaluated in the string NewString$
    '    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN

    GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable

    Num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO
    A$ = "LBNE": B$ = "DOStart_" + Num$: C$ = "If the result is a true then goto the start of the DO/Loop again": GoSub AO
    Z$ = "DoneLoop_" + Num$: C$ = "End of DO Loop": GoSub AO
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
    Expression$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HF5 on the end
    '    GoSub GoCheckIfTrue ' This parses CheckIfTrue$ get's it ready to be evaluated in the string NewString$
    '    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN

    GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable

    Num = DOStack(DOStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO
    A$ = "LBEQ": B$ = "DOStart_" + Num$: C$ = "If the result is a false then goto the start of the DO/Loop": GoSub AO
    Z$ = "DoneLoop_" + Num$: C$ = "End of DO Loop": GoSub AO
    DOStackPointer = DOStackPointer - 1
    Return
End If
Print "Don't know what kind of DO command to do on";: GoTo FoundError

DoWHILE:
WhileCount = WhileCount + 1
WhileStackPointer = WhileStackPointer + 1
WHILEStack(WhileStackPointer) = WhileCount
Num = WhileCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
WhileLoopNum$ = Num$
Z$ = "WhileLoop_" + WhileLoopNum$: C$ = "Start of WHILE/WEND loop": GoSub AO
CheckIfTrue$ = ""
v = 0
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' Keep copying until we get EOL or Colon
    v = Array(x): x = x + 1
    If v <> Asc(" ") Then CheckIfTrue$ = CheckIfTrue$ + Chr$(v) 'skip spaces
Loop
v = Array(x): x = x + 1
Expression$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HF5 on the end
'    GoSub GoCheckIfTrue ' This parses CheckIfTrue$ get's it ready to be evaluated in the string NewString$
'    GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
GoSub ParseExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
A$ = "LDA": B$ = ",S+": C$ = "Get the result and fix the stack": GoSub AO
A$ = "LBEQ": B$ = "Wend_" + WhileLoopNum$: C$ = "If the result is a false then goto the end of the WHILE/WEND loop": GoSub AO
Return

DoWEND:
If WhileStackPointer = 0 Then Print "Error: WEND without WHILE on";: GoTo FoundError
Num = WHILEStack(WhileStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
A$ = "JMP": B$ = "WhileLoop_" + Num$: C$ = "Goto the start of this WHILE/WEND loop": GoSub AO
Z$ = "Wend_" + Num$: C$ = "End of WHILE/WEND loop": GoSub AO
WhileStackPointer = WhileStackPointer - 1
Return


DoDIM:
' Nothing to do here, Tokenizer handled this
GoSub SkipToEOLColon ' Skip to the End of the Line or until a Colon
Return



DoFOR:
FORCount = FORCount + 1
FORStackPointer = FORStackPointer + 1
FORSTack(FORStackPointer) = FORCount
v = Array(x): x = x + 1
If v <> TK_NumericVar Then Print "Error getting variable needed in the FOR command on";: GoTo FoundError
'ForJump(Array(x) * 256 + Array(x + 1)) = FORCount ' Set the numeric variable name/number to this ForJump #
CompVar = Array(x) * 256 + Array(x + 1) ' Comparison Variable
' Change the bytes of the "TO" command to a $F50D so we can use the HandleNumericVariable routine to setup the FOR X=Y  part
Start = x ' Point to the variable before the = sign
Do Until (v = TK_GeneralCommand And Array(x) * 256 + Array(x + 1) = TO_CMD) Or (v = TK_SpecialChar And Array(x) = TK_EOL)
    v = Array(x): x = x + 1
Loop
If v = TK_SpecialChar Then v = Array(x): x = x + 1
If v = TK_EOL Then Print "Error assigning a value to variable in the FOR command on";: GoTo FoundError
' Found the TO command
PointAtTO = x - 1 ' Remember where the TO command is
Array(PointAtTO) = TK_SpecialChar
Array(PointAtTO + 1) = TK_EOL ' temporarily change the space before the TO command to a $F50D
x = Start ' Point at the variable before the =
GoSub HandleNumericVariable ' Handle code such as X=Y*3 and returns with value of Y*3 in _Var_X, NV$ has the variable name, NVT = Numeric Variable Type
NV_Main$ = NV$ ' Save the main variable name
NVT_Main = NVT ' Save the main variable type, the TO and Step will be changed to this same format
' *** At this point the variable is loaded with the starting value

x = PointAtTO + 3 ' x now points past the TO command
GoSub GetExpressionB4EOLOrCommand 'Handle an expression that ends with a colon or End of a Line or a general command like TO or STEP
'ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression value is now in D, x now points after the EOL/Colon/$FF
' D now has the value we need to Compare against each time we do a FOR Loop
' Self Mod Code where we compare the value of the variable aggainst what is now D
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Z$ = "; Got the TO value at ,S": GoSub AO
Z$ = "; LastType=" + Str$(LastType): GoSub AO
GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ

Num = FORCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$

' The TO value is now on the stack
Select Case NVT_Main
    Case 1, 2, 3, 4 ' un/signed 8 bit integer
        A$ = "PULS": B$ = "B": C$ = "Get the TO value off the stack": GoSub AO
        A$ = "STB": B$ = "FOR_Check_" + Num$ + "+1": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STB": B$ = "FOR_CheckB_" + Num$ + "+1": C$ = "Save the value to compare with (self mod below)": GoSub AO
    Case 5, 6 ' un/signed 16 bit integer
        A$ = "PULS": B$ = "D": C$ = "Get the TO value off the stack": GoSub AO
        A$ = "STD": B$ = "FOR_Check_" + Num$ + "+2": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STD": B$ = "FOR_CheckB_" + Num$ + "+2": C$ = "Save the value to compare with (self mod below)": GoSub AO
    Case 7, 8 ' un/signed 32 bit integer
        A$ = "PULS": B$ = "D,X": C$ = "Get the TO value off the stack": GoSub AO
        A$ = "STD": B$ = "FOR_Check_" + Num$ + "+2": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STX": B$ = "FOR_Check_" + Num$ + "+11": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STD": B$ = "FOR_CheckB_" + Num$ + "+2": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STX": B$ = "FOR_CheckB_" + Num$ + "+11": C$ = "Save the value to compare with (self mod below)": GoSub AO
    Case 9, 10 ' un/signed 64 bit integer
        A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the TO value off the stack": GoSub AO
        A$ = "STD": B$ = "FOR_Check_" + Num$ + "+2": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STX": B$ = "FOR_Check_" + Num$ + "+11": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STY": B$ = "FOR_Check_" + Num$ + "+20": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STU": B$ = "FOR_Check_" + Num$ + "+29": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STD": B$ = "FOR_CheckB_" + Num$ + "+2": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STX": B$ = "FOR_CheckB_" + Num$ + "+11": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STY": B$ = "FOR_CheckB_" + Num$ + "+20": C$ = "Save the value to compare with (self mod below)": GoSub AO
        A$ = "STU": B$ = "FOR_CheckB_" + Num$ + "+29": C$ = "Save the value to compare with (self mod below)": GoSub AO
    Case 11 ' FFP
        A$ = "PULS": B$ = "B,X": C$ = "Get the 3 byte FFP TO value off the stack": GoSub AO
        A$ = "STB": B$ = "FOR_Check_" + Num$ + "+1": C$ = "Self mod B value": GoSub AO
        A$ = "STX": B$ = "FOR_Check_" + Num$ + "+3": C$ = "Self mod X value": GoSub AO
    Case 12 ' Double
        A$ = "PULS": B$ = "D,X,U": C$ = "Get the Double TO value off the stack": GoSub AO
        A$ = "STD": B$ = "FOR_Check_" + Num$ + "+9": C$ = "Self mod Sign and EXP MSbits": GoSub AO
        A$ = "STX": B$ = "FOR_Check_" + Num$ + "+12": C$ = "Self mod EXP LSbits & Mantissa MSbits": GoSub AO
        A$ = "STU": B$ = "FOR_Check_" + Num$ + "+15": C$ = "Self mod Mantissa midbits": GoSub AO
        '        A$ = "STD": B$ = "FOR_CheckB_" + Num$ + "+9": C$ = "Self mod Sign and EXP MSbits": GoSub AO
        '        A$ = "STX": B$ = "FOR_CheckB_" + Num$ + "+12": C$ = "Self mod EXP LSbits & Mantissa MSbits": GoSub AO
        '        A$ = "STU": B$ = "FOR_CheckB_" + Num$ + "+15": C$ = "Self mod Mantissa midbits": GoSub AO
        A$ = "PULS": B$ = "D,X": C$ = "Get the Double TO value off the stack": GoSub AO
        A$ = "STD": B$ = "FOR_Check_" + Num$ + "+1": C$ = "Self mod Mantissa midbits": GoSub AO
        A$ = "STX": B$ = "FOR_Check_" + Num$ + "+4": C$ = "Self mod Mantissa LSbits": GoSub AO
        '        A$ = "STD": B$ = "FOR_CheckB_" + Num$ + "+1": C$ = "Self mod Mantissa midbits": GoSub AO
        '        A$ = "STX": B$ = "FOR_CheckB_" + Num$ + "+4": C$ = "Self mod Mantissa LSbits": GoSub AO
    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select

' Check for a STEP command
If Array(x) = TK_GeneralCommand Then
    If Array(x + 1) * 256 + Array(x + 2) = STEP_CMD Then
        'We have a STEP command so get the value of in D
        x = x + 3 ' move to the STEP amount
        GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
        ' D now has the value we need to Compare against each time we do a FOR Loop
        ' Self Mod Code where we compare the value of the variable aggainst what is now D
        GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
        Z$ = "; LastType=" + Str$(LastType): GoSub AO
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        Select Case NVT_Main
            Case 1, 2, 3, 4 ' un/signed 8 bit integer
                A$ = "PULS": B$ = "B": C$ = "Get the STEP for this FOR off the stack": GoSub AO
            Case 5, 6 ' un/signed 16 bit integer
                A$ = "PULS": B$ = "D": C$ = "Get the STEP for this FOR off the stack": GoSub AO
            Case 7, 8 ' un/signed 32 bit integer
                A$ = "PULS": B$ = "D,X": C$ = "Get the STEP for this FOR off the stack": GoSub AO
            Case 9, 10 ' un/signed 64 bit integer
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the STEP for this FOR off the stack": GoSub AO
            Case 11 ' FFP
                A$ = "PULS": B$ = "B,X": C$ = "Get the 3 byte FFP STEP value off the stack": GoSub AO
            Case 12 ' Double
                A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the 10 byte STEP value off the stack, Leave LSWord on the stack": GoSub AO
            Case Else
                ' Add code to handle sizes larger
                Z$ = "***Type is too large***": GoSub AO
        End Select
    Else
        Print "Error FOR command has another command instead of a STEP command on";: GoTo FoundError
    End If
Else
    ' No STEP command, default to a STEP value of 1
    Select Case NVT_Main
        Case 1, 2, 3, 4 ' un/signed 8 bit integer
            A$ = "LDB": B$ = "#$01": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
        Case 5, 6 ' un/signed 16 bit integer
            A$ = "LDD": B$ = "#$0001": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
        Case 7, 8 ' un/signed 32 bit integer
            A$ = "LDD": B$ = "#$0000": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
            A$ = "LDX": B$ = "#$0001": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
        Case 9, 10 ' un/signed 64 bit integer
            A$ = "LDD": B$ = "#$0000": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
            A$ = "LDX": B$ = "#$0000": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
            A$ = "LEAY": B$ = ",X": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
            A$ = "LEAU": B$ = "1,X": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
        Case 11 ' FFP
            A$ = "LDB": B$ = "#$00": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
            A$ = "LDX": B$ = "#$8000": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
        Case 12 ' Double
            A$ = "LDD": B$ = "#$0000": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
            A$ = "PSHS": B$ = "D": C$ = "Save LSWord of the mantissa of step value 1 on the stack": GoSub AO
            A$ = "LDX": B$ = "#$0010": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
            A$ = "LDU": B$ = "#$0000": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
            A$ = "LEAY": B$ = ",U": C$ = "No STEP for this FOR so set default step value to 1": GoSub AO
        Case Else
            ' Add code to handle sizes larger
            Z$ = "***Type is too large***": GoSub AO
    End Select
End If

Num = FORCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$

' Setup how much to add/subtract (STEP value) for the different numberic variable types
Select Case NVT_Main
    Case 1, 2, 3, 4 ' un/signed 8 bit integer
        A$ = "STB": B$ = "FOR_ADB_" + Num$ + "+1": C$ = "Save the value to ADDB for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "ROLB": C$ = "Move sign bit of FFP to the carry": GoSub AO
    Case 5, 6 ' un/signed 16 bit integer
        A$ = "STD": B$ = "FOR_ADD_" + Num$ + "+1": C$ = "Save the value to ADDD for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "ROLA": C$ = "Move sign bit to the carry": GoSub AO
    Case 7, 8 ' un/signed 32 bit integer
        A$ = "STX": B$ = "FOR_ADD_" + Num$ + "+1": C$ = "Save the LSWord value to ADDD for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "STD": B$ = "FOR_ADD_" + Num$ + "+16": C$ = "Save the MSWord value to ADDD for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "ROLA": C$ = "Move sign bit to the carry": GoSub AO
    Case 9, 10 ' un/signed 64 bit integer
        A$ = "STB": B$ = "@DoAdd1+1": C$ = "Save value to ADCB for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "STA": B$ = "@DoAdd0+1": C$ = "Save value to ADCA for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "ROLA": C$ = "Move sign bit to the carry": GoSub AO
        A$ = "TFR": B$ = "X,D": GoSub AO
        A$ = "STB": B$ = "@DoAdd3+1": C$ = "Save value to ADCB for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "STA": B$ = "@DoAdd2+1": C$ = "Save value to ADCA for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "TFR": B$ = "Y,D": GoSub AO
        A$ = "STB": B$ = "@DoAdd5+1": C$ = "Save value to ADCB for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "STA": B$ = "@DoAdd4+1": C$ = "Save value to ADCA for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "STU": B$ = "@DoAdd6+1": C$ = "Save value to ADCA for each FOR/NEXT loop (self mod below)": GoSub AO
    Case 11 ' FFP
        ' Amount to add for each step is already in B & X
        A$ = "STB": B$ = "FOR_ADD_" + Num$ + "+1": C$ = "Save the STEP value to ADD for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "ROLB": C$ = "Move sign bit of FFP to the carry": GoSub AO
        A$ = "STX": B$ = "FOR_ADD_" + Num$ + "+3": C$ = "Save the STEP value to ADD for each FOR/NEXT loop (self mod below)": GoSub AO
    Case 12 ' Double
        Z$ = "; Save the STEP value to ADD for each FOR/NEXT loop (self mod below)": GoSub AO
        A$ = "STD": B$ = "FOR_ADD_" + Num$ + "+9": C$ = "Self mod Sign and EXP MSbits": GoSub AO
        A$ = "ROLA": C$ = "Move sign bit of Double to the carry": GoSub AO
        A$ = "STX": B$ = "FOR_ADD_" + Num$ + "+12": C$ = "Self mod EXP LSbits & Mantissa MSbits": GoSub AO
        A$ = "STY": B$ = "FOR_ADD_" + Num$ + "+15": C$ = "Self mod Mantissa midbits": GoSub AO
        A$ = "STU": B$ = "FOR_ADD_" + Num$ + "+1": C$ = "Self mod Mantissa midbits": GoSub AO
        A$ = "PULS": B$ = "X": C$ = "Get the LSWord off the stack": GoSub AO
        A$ = "STX": B$ = "FOR_ADD_" + Num$ + "+4": C$ = "Self mod Mantissa LSbits": GoSub AO
    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select

' Branch is based on the STEP sign
Select Case NVT_Main
    Case 1, 3, 5, 7, 9 ' For signed numbers
        A$ = "LDD": B$ = "#$2E2D": C$ = "opcodes for BGT/BLT opcode": GoSub AO
        A$ = "BCS": B$ = ">": C$ = "Skip if carry is set (STEP is a negative)": GoSub AO
        A$ = "LDD": B$ = "#$2D2E": C$ = "opcodes for BLT/BGT": GoSub AO
    Case 2, 4, 6, 8, 10 ' For unsigned numbers
        A$ = "LDD": B$ = "#$2225": C$ = "opcodes for BHI/BLO": GoSub AO
        A$ = "BCS": B$ = ">": C$ = "Skip if carry is set (STEP is a negative)": GoSub AO
        A$ = "LDD": B$ = "#$2522": C$ = "opcodes for BLO/BHI": GoSub AO
    Case 11, 12 ' For FFP, Double  (Reversed)
        A$ = "LDD": B$ = "#$2D2E": C$ = "opcodes for BLT/BGT": GoSub AO
        A$ = "BCS": B$ = ">": C$ = "Skip if carry is set (STEP is a negative)": GoSub AO
        A$ = "LDD": B$ = "#$2E2D": C$ = "opcodes for BGT/BLT opcode": GoSub AO
End Select
Num = FORCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
Z$ = "@ForSelfMod": GoSub AO
Z$ = "!"
A$ = "STA": B$ = "FOR_Branch_" + Num$: C$ = "Save the BRANCH opcode (self mod below) either LBGT or LBLT or LBHI": GoSub AO
A$ = "LDA": B$ = "#$10": C$ = "Do a Long branch": GoSub AO
A$ = "STD": B$ = "FOR_BranchB_" + Num$: C$ = "Save the BRANCH opcode (self mod below) either LBGT or LBLT or LBHI": GoSub AO
Select Case NVT_Main
    Case 9, 10, 12
        A$ = "JMP": B$ = "@SkipFirst": C$ = "Skip past the check, the first time": GoSub AO
    Case Else
        A$ = "BRA": B$ = "@SkipFirst": C$ = "Skip past the check, the first time": GoSub AO
End Select
' FOR loop starts here
Z$ = "ForLoop_" + Num$: C$ = "Start of FOR Loop": GoSub AO
' Handle all the different variable types for each loop
Select Case NVT_Main
    Case 1, 2, 3, 4 ' un/signed 8 bit integer
        A$ = "LDB": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Get the variable needed for this NEXT command": GoSub AO
        Z$ = "FOR_Check_" + Num$: GoSub AO
        A$ = "CMPB": B$ = "#$FF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        Z$ = "FOR_Branch_" + Num$: GoSub AO
        A$ = "BLT": B$ = ">": C$ = "Branch type (Self modified) will be changed depending on a add or subtract signed/unsigned": GoSub AO

        ' Do last one then jump past NEXT
        A$ = "LBNE": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO
        A$ = "ADDB": B$ = "FOR_ADB_" + Num$ + "+1": GoSub AO
        A$ = "STB": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "JMP": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO

        Z$ = "!": GoSub AO
        Z$ = "FOR_ADB_" + Num$: GoSub AO
        A$ = "ADDB": B$ = "#$FF": C$ = "Add this amount each iteration of the FOR loop (self modded when the FOR is setup)": GoSub AO
        A$ = "STB": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO

        Z$ = "FOR_CheckB_" + Num$: GoSub AO
        A$ = "CMPB": B$ = "#$FF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        Z$ = "FOR_BranchB_" + Num$: GoSub AO
        A$ = "LBGT": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO
    Case 5, 6 'un/signed 16 bit integer
        A$ = "LDD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Get the variable needed for this NEXT command": GoSub AO
        Z$ = "FOR_Check_" + Num$: GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        Z$ = "FOR_Branch_" + Num$: GoSub AO
        A$ = "BLT": B$ = ">": C$ = "Branch type (Self modified) will be changed depending on a add or subtract signed/unsigned": GoSub AO

        ' Do last one then jump past NEXT
        A$ = "LBNE": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO
        A$ = "ADDD": B$ = "FOR_ADD_" + Num$ + "+1": GoSub AO
        A$ = "STD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "JMP": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO

        Z$ = "!": GoSub AO
        Z$ = "FOR_ADD_" + Num$: GoSub AO
        A$ = "ADDD": B$ = "#$FFFF": C$ = "Add this amount each iteration of the FOR loop (self modded when the FOR is setup)": GoSub AO
        A$ = "STD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        Z$ = "FOR_CheckB_" + Num$: GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        Z$ = "FOR_BranchB_" + Num$: GoSub AO
        A$ = "LBGT": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO
    Case 7, 8 ' un/signed 32 bit integer
        A$ = "LDD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Get the LSWord of the variable needed for this NEXT command": GoSub AO
        Z$ = "FOR_Check_" + Num$: GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "Branch if not equal, flags Z, N, and C are set": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+2": C$ = "IF MSWord is Equal then get the LSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        Z$ = "!": GoSub AO
        Z$ = "FOR_Branch_" + Num$: GoSub AO
        A$ = "BLT": B$ = "@DoAdd": C$ = "Branch type (Self modified) will be changed depending on a add or subtract signed/unsigned": GoSub AO

        ' Do last one then jump past NEXT
        A$ = "LBNE": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO
        A$ = "LDD": B$ = "_Var_" + NumericVariable$(CompVar) + "+2": C$ = "Get the LSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "ADDD": B$ = "FOR_ADD_" + Num$ + "+1": GoSub AO
        A$ = "STD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+2": C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar): C$ = "Get the MSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "BCC": B$ = ">": C$ = "Skip if the carry isn't set": GoSub AO
        A$ = "INCB": C$ = "Skip if the carry isn't set": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "Skip if the carry isn't set": GoSub AO
        A$ = "INCA": C$ = "Skip if the carry isn't set": GoSub AO
        Z$ = "!"
        A$ = "ADDD": B$ = "FOR_ADD_" + Num$ + "+16": GoSub AO
        A$ = "STD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "JMP": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO

        Z$ = "@DoAdd": GoSub AO
        A$ = "LDD": B$ = "_Var_" + NumericVariable$(CompVar) + "+2": C$ = "Get the LSWord of the variable needed for this NEXT command": GoSub AO
        Z$ = "FOR_ADD_" + Num$: GoSub AO
        A$ = "ADDD": B$ = "#$FFFF": C$ = "Add this LSWord amount each iteration of the FOR loop (self modded when the FOR is setup)": GoSub AO
        A$ = "STD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+2": C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar): C$ = "Get the MSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "BCC": B$ = ">": C$ = "Skip if the carry isn't set": GoSub AO
        A$ = "INCB": C$ = "Skip if the carry isn't set": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "Skip if the carry isn't set": GoSub AO
        A$ = "INCA": C$ = "Skip if the carry isn't set": GoSub AO
        Z$ = "!"
        A$ = "ADDD": B$ = "#$FFFF": C$ = "Add this MSWord amount each iteration of the FOR loop (self modded when the FOR is setup)": GoSub AO
        A$ = "STD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        Z$ = "FOR_CheckB_" + Num$: GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "Branch if not equal, flags Z, N, and C are set": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+2": C$ = "IF MSWord is Equal then get the LSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        Z$ = "!": GoSub AO
        Z$ = "FOR_BranchB_" + Num$: GoSub AO
        A$ = "LBGT": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO

    Case 9, 10 ' un/signed 64 bit integer
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar): C$ = "Get the MSWord of the variable needed for this NEXT command": GoSub AO
        Z$ = "FOR_Check_" + Num$: GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "Branch if not equal, flags Z, N, and C are set": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+2": C$ = "IF MSWord is Equal then get the LSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "Branch if not equal, flags Z, N, and C are set": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+4": C$ = "IF MSWord is Equal then get the LSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "Branch if not equal, flags Z, N, and C are set": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+6": C$ = "IF MSWord is Equal then get the LSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        Z$ = "!": GoSub AO
        Z$ = "FOR_Branch_" + Num$: GoSub AO
        A$ = "BLT": B$ = "@DoAdd": C$ = "Branch type (Self modified) will be changed depending on a add or subtract signed/unsigned": GoSub AO

        ' Do last one then jump past NEXT
        A$ = "LBNE": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO
        A$ = "LDD": B$ = "_Var_" + NumericVariable$(CompVar) + "+6": C$ = "Get the LSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "ADDD": B$ = "@DoAdd6+1": GoSub AO
        A$ = "STD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+6": C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+4": C$ = "Get the MSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "ADCB": B$ = "@DoAdd5+1": GoSub AO
        A$ = "ADCA": B$ = "@DoAdd4+1": GoSub AO
        A$ = "STD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+4": C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+2": C$ = "Get the MSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "ADCB": B$ = "@DoAdd3+1": GoSub AO
        A$ = "ADCA": B$ = "@DoAdd2+1": GoSub AO
        A$ = "STD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+2": C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar): C$ = "Get the MSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "ADCB": B$ = "@DoAdd1+1": GoSub AO
        A$ = "ADCA": B$ = "@DoAdd0+1": GoSub AO
        A$ = "STD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "JMP": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO

        Z$ = "@DoAdd": GoSub AO
        A$ = "LDD": B$ = "_Var_" + NumericVariable$(CompVar) + "+6": C$ = "Get the LSWord of the variable needed for this NEXT command": GoSub AO
        Z$ = "@DoAdd6": GoSub AO
        A$ = "ADDD": B$ = "#$FFFF": C$ = "Add this LSWord amount each iteration of the FOR loop (self modded when the FOR is setup)": GoSub AO
        A$ = "STD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+6": C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+4": C$ = "Get the MSWord of the variable needed for this NEXT command": GoSub AO
        Z$ = "@DoAdd5": GoSub AO
        A$ = "ADCB": B$ = "#$FF": GoSub AO
        Z$ = "@DoAdd4": GoSub AO
        A$ = "ADCA": B$ = "#$FF": GoSub AO
        A$ = "STD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+4": C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+2": C$ = "Get the MSWord of the variable needed for this NEXT command": GoSub AO
        Z$ = "@DoAdd3": GoSub AO
        A$ = "ADCB": B$ = "#$FF": GoSub AO
        Z$ = "@DoAdd2": GoSub AO
        A$ = "ADCA": B$ = "#$FF": GoSub AO
        A$ = "STD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+2": C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar): C$ = "Get the MSWord of the variable needed for this NEXT command": GoSub AO
        Z$ = "@DoAdd1": GoSub AO
        A$ = "ADCB": B$ = "#$FF": GoSub AO
        Z$ = "@DoAdd0": GoSub AO
        A$ = "ADCA": B$ = "#$FF": GoSub AO
        A$ = "STD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Save the updated value of the numeric variable needed for this NEXT command": GoSub AO

        Z$ = "FOR_CheckB_" + Num$: GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "Branch if not equal, flags Z, N, and C are set": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+2": C$ = "IF MSWord is Equal then get the LSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "Branch if not equal, flags Z, N, and C are set": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+4": C$ = "IF MSWord is Equal then get the LSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "Branch if not equal, flags Z, N, and C are set": GoSub AO
        A$ = "LDD": B$ = ">_Var_" + NumericVariable$(CompVar) + "+6": C$ = "IF MSWord is Equal then get the LSWord of the variable needed for this NEXT command": GoSub AO
        A$ = "CMPD": B$ = "#$FFFF": C$ = "This value will be self modded to compare with when the FOR is setup": GoSub AO
        Z$ = "!": GoSub AO
        Z$ = "FOR_BranchB_" + Num$: GoSub AO
        A$ = "LBGT": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO

    Case 11 ' FFP
        'Push the compare (TO) value on the stack (self modified above)
        Z$ = "FOR_Check_" + Num$: GoSub AO
        A$ = "LDB": B$ = "#$AA": C$ = "Self mod TO value above": GoSub AO
        A$ = "LDX": B$ = "#$BBCC": C$ = "Self mod TO value above": GoSub AO
        A$ = "PSHS": B$ = "B,X": C$ = "Put number to compare on the stack": GoSub AO

        A$ = "LDU": B$ = "#_Var_" + NumericVariable$(CompVar): C$ = "Get the variable needed for this NEXT command": GoSub AO
        A$ = "PULU": B$ = "B,X": C$ = "Get variable amount": GoSub AO
        A$ = "PSHS": B$ = "B,X": C$ = "Put number to add on the stack": GoSub AO
        ' Compare them
        A$ = "JSR": B$ = "FFP_CMP_Stack": C$ = "Compare FFP Value1 @ ,S with Value 2 @ 3,S sets the 6809 flags Z, N, and C": GoSub AO
        Z$ = "FOR_Branch_" + Num$: GoSub AO
        A$ = "BGT": B$ = "@FOR_KeepGoing": C$ = "Branch type (Self modified) will be changed depending on a add or subtract signed/unsigned": GoSub AO

        'Do the last ADD then jump past NEXT
        A$ = "BNE": B$ = ">": GoSub AO
        A$ = "LEAS": B$ = "6,S": C$ = "Fix the Stack": GoSub AO
        A$ = "JMP": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO
        Z$ = "!": A$ = "LDB": B$ = "FOR_ADD_" + Num$ + "+1": GoSub AO
        A$ = "LDX": B$ = "FOR_ADD_" + Num$ + "+3": GoSub AO
        A$ = "PSHS": B$ = "B,X": C$ = "Put number to add on the stack": GoSub AO
        A$ = "JSR": B$ = "FFP_ADD": C$ = "Add this amount each iteration of the FOR loop (self modded when the FOR is setup)": GoSub AO
        A$ = "PULS": B$ = "B,X": C$ = "Get result of add, move the stack": GoSub AO
        A$ = "LDU": B$ = "#_Var_" + NumericVariable$(CompVar) + "+3": C$ = "Get the variable used for this NEXT command": GoSub AO
        A$ = "PSHU": B$ = "B,X": C$ = "Save the updated variable": GoSub AO
        A$ = "LEAS": B$ = "3,S": C$ = "Fix the Stack": GoSub AO
        A$ = "JMP": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO

        ' Do another NEXT Loop
        Z$ = "@FOR_KeepGoing": GoSub AO
        Z$ = "FOR_ADD_" + Num$: GoSub AO
        A$ = "LDB": B$ = "#$DD": C$ = "Self mod STEP amount above": GoSub AO
        A$ = "LDX": B$ = "#$EEFF": C$ = "Self mod STEP amount above": GoSub AO
        A$ = "PSHS": B$ = "B,X": C$ = "Put STEP amount on the stack": GoSub AO
        A$ = "JSR": B$ = "FFP_ADD": C$ = "Add this amount each iteration of the FOR loop (self modded when the FOR is setup)": GoSub AO
        A$ = "LEAU": B$ = ",S": C$ = "U points at the Stack": GoSub AO
        A$ = "PULU": B$ = "B,X": C$ = "Get result of add": GoSub AO
        A$ = "LDU": B$ = "#_Var_" + NumericVariable$(CompVar) + "+3": C$ = "Get the variable used for this NEXT command": GoSub AO
        A$ = "PSHU": B$ = "B,X": C$ = "Save the updated variable": GoSub AO

        ' Make sure we are not passed the TO value, if we are then exit FOR loop
        A$ = "JSR": B$ = "FFP_CMP_Stack": C$ = "Compare FFP Value1 @ ,S with Value 2 @ 3,S sets the 6809 flags Z, N, and C": GoSub AO
        A$ = "LEAS": B$ = "6,S": C$ = "Fix the Stack": GoSub AO
        Z$ = "FOR_BranchB_" + Num$: GoSub AO
        A$ = "LBLT": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO
    Case 12 ' Double
        'Push the compare on the stack
        Z$ = "FOR_Check_" + Num$: GoSub AO
        A$ = "LDD": B$ = "#$0607": C$ = "Mantissa Midbits, Self mod above": GoSub AO
        A$ = "LDX": B$ = "#$0809": C$ = "Mantissa LSbits, Self mod above": GoSub AO
        A$ = "PSHS": B$ = "D,X": C$ = "Put Step amount on the stack": GoSub AO
        A$ = "LDD": B$ = "#$0001": C$ = "Sign, EXP bits, Self mod above": GoSub AO
        A$ = "LDX": B$ = "#$0203": C$ = "EXP & Mantissa MSbits, Self mod above": GoSub AO
        A$ = "LDU": B$ = "#$0405": C$ = "Mantissa Midbits, Self mod above": GoSub AO
        A$ = "PSHS": B$ = "D,X,U": C$ = "Put Step amount on the stack": GoSub AO

        A$ = "LDU": B$ = "#_Var_" + NumericVariable$(CompVar) + "+2": C$ = "Point at manitissa": GoSub AO
        A$ = "PULU": B$ = "D,X,Y": GoSub AO
        A$ = "LDU": B$ = ",U": C$ = "Copy 7 mantissa bytes": GoSub AO
        A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Push them on the stack": GoSub AO
        A$ = "LDD": B$ = "_Var_" + NumericVariable$(CompVar): C$ = "Get the SIGN & Exponent MSB": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the Sign & MSB of the Exponent on the stack ": GoSub AO

        ' Compare them
        A$ = "JSR": B$ = "Double_CMP_Stack": C$ = "Compare Double Value1 @ ,S with Value 2 @ 10,S sets the 6809 flags Z, N, and C": GoSub AO
        Z$ = "FOR_Branch_" + Num$: GoSub AO
        A$ = "BLT": B$ = "@FOR_KeepGoing": C$ = "Branch type (Self modified) will be changed depending on a add or subtract signed/unsigned": GoSub AO

        'Do the last ADD then jump past NEXT
        A$ = "BNE": B$ = ">": GoSub AO
        A$ = "LEAS": B$ = "20,S": C$ = "Fix the Stack": GoSub AO
        A$ = "JMP": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO
        Z$ = "!":
        A$ = "LDD": B$ = "FOR_ADD_" + Num$ + "+1": GoSub AO
        A$ = "LDX": B$ = "FOR_ADD_" + Num$ + "+4": GoSub AO
        A$ = "LDY": B$ = "FOR_ADD_" + Num$ + "+9": GoSub AO
        A$ = "LDU": B$ = "FOR_ADD_" + Num$ + "+12": GoSub AO
        A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Push them on the stack": GoSub AO
        A$ = "LDD": B$ = "FOR_ADD_" + Num$ + "+15": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the Sign & MSB of the Exponent on the stack ": GoSub AO
        A$ = "JSR": B$ = "DB_ADD": C$ = "Add this amount each iteration of the FOR loop (self modded when the FOR is setup)": GoSub AO
        A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get result of add": GoSub AO
        A$ = "STU": B$ = "_Var_" + NumericVariable$(CompVar) + "+6": C$ = "Save U at destination address + 6": GoSub AO
        A$ = "LDU": B$ = "#_Var_" + NumericVariable$(CompVar) + "+6": C$ = "U points at the start of the destination location": GoSub AO
        A$ = "PSHU": B$ = "D,X,Y": C$ = "Save the 6 bytes of data at the start of destination": GoSub AO
        A$ = "PULS": B$ = "D": C$ = "Get the last 2 bytes from the stack": GoSub AO
        A$ = "STD": B$ = "8,U": C$ = "Save the updated variable": GoSub AO
        A$ = "LEAS": B$ = "10,S": C$ = "Fix the Stack": GoSub AO
        A$ = "JMP": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO

        ' Do another NEXT Loop
        Z$ = "@FOR_KeepGoing": GoSub AO
        Z$ = "FOR_ADD_" + Num$: GoSub AO
        A$ = "LDD": B$ = "#$0607": C$ = "Mantissa Midbits, Self mod above": GoSub AO
        A$ = "LDX": B$ = "#$0809": C$ = "Mantissa LSbits, Self mod above": GoSub AO
        A$ = "PSHS": B$ = "D,X": C$ = "Put Step amount on the stack": GoSub AO
        A$ = "LDD": B$ = "#$0001": C$ = "Sign, EXP bits, Self mod above": GoSub AO
        A$ = "LDX": B$ = "#$0203": C$ = "EXP & Mantissa MSbits, Self mod above": GoSub AO
        A$ = "LDU": B$ = "#$0405": C$ = "Mantissa Midbits, Self mod above": GoSub AO
        A$ = "PSHS": B$ = "D,X,U": C$ = "Put Step amount on the stack": GoSub AO
        A$ = "JSR": B$ = "DB_ADD": C$ = "Add this amount each iteration of the FOR loop (self modded when the FOR is setup)": GoSub AO
        A$ = "LEAU": B$ = ",S": C$ = "U points at the Stack": GoSub AO
        A$ = "PULU": B$ = "D,X,Y": C$ = "Get result of add": GoSub AO
        A$ = "LDU": B$ = ",U": C$ = "Load U with the last two bytes of data": GoSub AO
        A$ = "STU": B$ = "_Var_" + NumericVariable$(CompVar) + "+6": C$ = "Save U at destination address + 6": GoSub AO
        A$ = "LDU": B$ = "#_Var_" + NumericVariable$(CompVar) + "+6": C$ = "U points at the start of the destination location": GoSub AO
        A$ = "PSHU": B$ = "D,X,Y": C$ = "Save the 6 bytes of data at the start of destination": GoSub AO
        A$ = "LDD": B$ = "8,S": C$ = "Get the last 2 bytes from the stack": GoSub AO
        A$ = "STD": B$ = "8,U": C$ = "Save the updated variable": GoSub AO

        A$ = "JSR": B$ = "Double_CMP_Stack": C$ = "Compare Double Value1 @ ,S with Value 2 @ 10,S sets the 6809 flags Z, N, and C": GoSub AO
        A$ = "LEAS": B$ = "20,S": C$ = "Fix the Stack": GoSub AO
        Z$ = "FOR_BranchB_" + Num$: GoSub AO
        A$ = "LBGT": B$ = "NEXTDone_" + Num$: C$ = "Jump past NEXT": GoSub AO

    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select

Z$ = "@SkipFirst": GoSub AO
Print #1, ""
Return

DoNEXT:
v = Array(x): x = x + 1
If v = TK_SpecialChar And (Array(x) = TK_EOL Or Array(x) = TK_Colon) Then
    'No variable for this next given
    v = TK_NumericVar: x = x - 1 'Point at the TK_SpecialChar again so we can exit cleanly
End If
If v <> TK_NumericVar Then Print "Error getting numeric variable needed in the NEXT command on";: GoTo FoundError
If FORStackPointer = 0 Then Print "Error: Next without FOR in line"; linelabel$: System
Num = FORSTack(FORStackPointer): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
A$ = "JMP": B$ = "ForLoop_" + Num$: C$ = "Goto the FOR loop": GoSub AO
Z$ = "NEXTDone_" + Num$: C$ = "End of FOR/NEXT loop": GoSub AO
FORStackPointer = FORStackPointer - 1
' Check for a Comma or EOL/Colon
Do Until v = TK_SpecialChar And (Array(x) = TK_EOL Or Array(x) = TK_Colon Or Array(x) = TK_Comma) ' EOL, Colon or Comma
    v = Array(x): x = x + 1
Loop
v = Array(x): x = x + 1 'return with EOL or Colon, now pointing after the EOL or colon
If v = TK_Comma Then GoTo DoNEXT ' Check for a comma
Return

DoPOKE:
' Get the numeric value before a comma
' Get first number in D
GoSub GetExpressionB4Comma: x = x + 2 ' Get the expression before a Comma, & move past it
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
A$ = "STD": B$ = "@POKE+1": C$ = "Save location where to poke in memory below (Self mod)": GoSub AO
'x in the array will now be pointing just past the ,
'Get value to poke in D (we only use B)
GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
Z$ = "@POKE": A$ = "STB": B$ = ">$FFFF": C$ = "Store B in memory location (Self modded above)": GoSub AO
Print #1,
Return


DoPRINT:
Z$ = "; Starting PRINT": GoSub AO
PrintD$ = "PRINT_D": PrintA$ = "PrintA_On_Screen": PrintDev$ = " on screen"
PrintCC3 = 0
GetSectionToPrint:
v = Array(x): x = x + 1
' Chek if we are printing numbers
If v >= Asc("0") And v <= Asc("9") Or (v = Asc("&") And Array(x) = Asc("H")) Then
    ' Printing a number, PRINT 10*20
    x = x - 1 ' make sure to inlcude the first Numeric variable
    GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
    GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
    If Left$(PrintD$, 16) = "PRINT_D_Graphics" Then
        ' Printing to a graphics screen
        Select Case LastType
            Case 1, 3, 5
                NVT = NT_Int16 ' Set the sign value as 16 bits
                GoSub ConvertLastType2NVT
                A$ = "JSR": B$ = "S16_TO_DECSTR": C$ = "Convert signed 16 bit number @,S to a numeric string on the stack": GoSub AO
            Case 2, 4, 6
                NVT = NT_UInt16 ' Set the unsigned value as 16 bits
                GoSub ConvertLastType2NVT
                A$ = "JSR": B$ = "U16_TO_DECSTR": C$ = "Convert unsigned 16 bit number @,S to a numeric string on the stack": GoSub AO
            Case 7
                NVT = NT_Int32 ' Set the sign value as 32 bits
                GoSub ConvertLastType2NVT
                A$ = "JSR": B$ = "S32_TO_DECSTR": C$ = "Convert signed 32 bit number @,S to a numeric string on the stack": GoSub AO
            Case 8
                NVT = NT_UInt32 ' Set the sign value as 32 bits
                GoSub ConvertLastType2NVT
                A$ = "JSR": B$ = "U32_TO_DECSTR": C$ = "Convert unsigned 32 bit number @,S to a numeric string on the stack": GoSub AO
            Case 9
                NVT = NT_Int64 ' Set the sign value as 64 bits
                GoSub ConvertLastType2NVT
                A$ = "JSR": B$ = "S64_TO_DECSTR": C$ = "Convert signed 64 bit number @,S to a numeric string on the stack": GoSub AO
            Case 10
                NVT = NT_UInt64 ' Set the sign value as 64 bits
                GoSub ConvertLastType2NVT
                A$ = "JSR": B$ = "U64_TO_DECSTR": C$ = "Convert unsigned 64 bit number @,S to a numeric string on the stack": GoSub AO
            Case 11
                NVT = NT_Single ' Set the sign value as FFP
                GoSub ConvertLastType2NVT
                A$ = "JSR": B$ = "FFP_TO_DECSTR": C$ = "Convert 3 Byte FFP number @,S to a numeric string on the stack": GoSub AO
            Case 12
                NVT = NT_Double ' Set the sign value as Double
                GoSub ConvertLastType2NVT
                A$ = "JSR": B$ = "DB_TO_DECSTR": C$ = "Convert 10 byte Double number @,S to a numeric string on the stack": GoSub AO
        End Select
        Z$ = "; String is on the stack, deal with it here:": GoSub AO
        A$ = "LDB": B$ = ",S+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AO
        A$ = "BEQ": B$ = "@Done": C$ = "If the length of the string is zero then don't copy it (Skip ahead)": GoSub AO
        Z$ = "!"
        A$ = "LDA": B$ = ",S+": C$ = "Get a source byte": GoSub AO
        If PrintCC3 = 1 Then
            A$ = "LDY": B$ = "#" + PrintA$: C$ = "Y points at the routine to do, Go print A" + PrintDev$: GoSub AO
            A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
        Else
            ' Print to the CoCo 2 graphic screen
            A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AO
        End If
        A$ = "DECB": C$ = "Decrement the counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
            Z$ = "@Done": GoSub AO: GoSub AO
    Else
        ' Printing to a normal Text screen
        Select Case LastType
            Case 1, 3
                A$ = "JSR": B$ = "PRINT_8Bit": C$ = "Print 8 bit signed, number is on the stack": GoSub AO
            Case 2, 4
                A$ = "JSR": B$ = "PRINT_Un8Bit": C$ = "Print 8 bit UnSigned, number is on the stack": GoSub AO
            Case 5
                A$ = "JSR": B$ = "PRINT_16Bit": C$ = "Print 16 bit signed, number is on the stack": GoSub AO
            Case 6
                A$ = "JSR": B$ = "PRINT_Un16Bit": C$ = "Print 16 bit UnSigned, number is on the stack": GoSub AO
            Case 7
                A$ = "JSR": B$ = "PRINT_32Bit": C$ = "Print 32 bit signed, number is on the stack": GoSub AO
            Case 8
                A$ = "JSR": B$ = "PRINT_Un32Bit": C$ = "Print 32 bit UnSigned, number is on the stack": GoSub AO
            Case 9
                A$ = "JSR": B$ = "PRINT_64Bit": C$ = "Print 64 bit signed, number is on the stack": GoSub AO
            Case 10
                A$ = "JSR": B$ = "PRINT_Un64Bit": C$ = "Print 64 bit UnSigned, number is on the stack": GoSub AO
            Case 11
                A$ = "JSR": B$ = "Print_FFP": C$ = "Print 3 byte FFP, number is on the stack": GoSub AO
            Case 12
                A$ = "JSR": B$ = "PRINT_DOUBLE": C$ = "Print 10 byte double, number is on the stack": GoSub AO
        End Select
    End If
    GoTo GetSectionToPrint
End If
Select Case v
    Case TK_NumericArray, TK_NumericVar, TK_NumericCommand
        Select Case v
            Case TK_NumericArray ' Printing a Numeric Array variable, PRINT A(5)
                x = x - 1 ' make sure to inlcude the token for numeric Array variable
                GoSub GetExpressionFullB4EndBracket: x = x + 2 ' Get an Expression before a close bracket, skip past $F5 and close bracket
                Expression$ = Expression$ + Chr$(&HF5) + Chr$(&H29) 'add the close bracket for parsing
            Case TK_NumericVar ' Printing a Regular Numeric Variable, PRINT A
                x = x - 1 ' make sure to inlcude the token for Numeric variable
                GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
            Case TK_NumericCommand ' Printing a Numeric command FE,MSB,LSB (16 bit numer identify which Numeric command
                x = x - 1 ' make sure to inlcude the the token for Numeric Command
                GoSub GetExpressionFullB4EndBracket: x = x + 2 ' Get an Expression before a close bracket, skip past $F5 and close bracket
                Expression$ = Expression$ + Chr$(&HF5) + Chr$(&H29) 'add the close bracket for parsing
        End Select
        GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
        If Left$(PrintD$, 16) = "PRINT_D_Graphics" Then
            ' Printing to a graphics screen
            Select Case LastType
                Case 1, 3, 5
                    NVT = NT_Int16 ' Set the sign value as 16 bits
                    GoSub ConvertLastType2NVT
                    A$ = "JSR": B$ = "S16_TO_DECSTR": C$ = "Convert signed 16 bit number @,S to a numeric string on the stack": GoSub AO
                Case 2, 4, 6
                    NVT = NT_UInt16 ' Set the unsigned value as 16 bits
                    GoSub ConvertLastType2NVT
                    A$ = "JSR": B$ = "U16_TO_DECSTR": C$ = "Convert unsigned 16 bit number @,S to a numeric string on the stack": GoSub AO
                Case 7
                    NVT = NT_Int32 ' Set the sign value as 32 bits
                    GoSub ConvertLastType2NVT
                    A$ = "JSR": B$ = "S32_TO_DECSTR": C$ = "Convert signed 32 bit number @,S to a numeric string on the stack": GoSub AO
                Case 8
                    NVT = NT_UInt32 ' Set the sign value as 32 bits
                    GoSub ConvertLastType2NVT
                    A$ = "JSR": B$ = "U32_TO_DECSTR": C$ = "Convert unsigned 32 bit number @,S to a numeric string on the stack": GoSub AO
                Case 9
                    NVT = NT_Int64 ' Set the sign value as 64 bits
                    GoSub ConvertLastType2NVT
                    A$ = "JSR": B$ = "S64_TO_DECSTR": C$ = "Convert signed 64 bit number @,S to a numeric string on the stack": GoSub AO
                Case 10
                    NVT = NT_UInt64 ' Set the sign value as 64 bits
                    GoSub ConvertLastType2NVT
                    A$ = "JSR": B$ = "U64_TO_DECSTR": C$ = "Convert unsigned 64 bit number @,S to a numeric string on the stack": GoSub AO
                Case 11
                    NVT = NT_Single ' Set the sign value as FFP
                    GoSub ConvertLastType2NVT
                    A$ = "JSR": B$ = "FFP_TO_DECSTR": C$ = "Convert 3 Byte FFP number @,S to a numeric string on the stack": GoSub AO
                Case 12
                    NVT = NT_Double ' Set the sign value as Double
                    GoSub ConvertLastType2NVT
                    A$ = "JSR": B$ = "DB_TO_DECSTR": C$ = "Convert 10 byte Double number @,S to a numeric string on the stack": GoSub AO
            End Select
            Z$ = "; String is on the stack, deal with it here:": GoSub AO
            A$ = "LDB": B$ = ",S+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AO
            A$ = "BEQ": B$ = "@Done": C$ = "If the length of the string is zero then don't copy it (Skip ahead)": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",S+": C$ = "Get a source byte": GoSub AO
            If PrintCC3 = 1 Then
                A$ = "LDY": B$ = "#" + PrintA$: C$ = "Y points at the routine to do, Go print A" + PrintDev$: GoSub AO
                A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
            Else
                ' Print to the CoCo 2 graphic screen
                A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AO
            End If
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
            Z$ = "@Done": GoSub AO: GoSub AO
        Else
            ' Printing to a normal Text screen
            Select Case LastType
                Case 1, 3
                    A$ = "JSR": B$ = "PRINT_8Bit": C$ = "Print 8 bit signed, number is on the stack": GoSub AO
                Case 2, 4
                    A$ = "JSR": B$ = "PRINT_Un8Bit": C$ = "Print 8 bit UnSigned, number is on the stack": GoSub AO
                Case 5
                    A$ = "JSR": B$ = "PRINT_16Bit": C$ = "Print 16 bit signed, number is on the stack": GoSub AO
                Case 6
                    A$ = "JSR": B$ = "PRINT_Un16Bit": C$ = "Print 16 bit UnSigned, number is on the stack": GoSub AO
                Case 7
                    A$ = "JSR": B$ = "PRINT_32Bit": C$ = "Print 32 bit signed, number is on the stack": GoSub AO
                Case 8
                    A$ = "JSR": B$ = "PRINT_Un32Bit": C$ = "Print 32 bit UnSigned, number is on the stack": GoSub AO
                Case 9
                    A$ = "JSR": B$ = "PRINT_64Bit": C$ = "Print 64 bit signed, number is on the stack": GoSub AO
                Case 10
                    A$ = "JSR": B$ = "PRINT_Un64Bit": C$ = "Print 64 bit UnSigned, number is on the stack": GoSub AO
                Case 11
                    A$ = "JSR": B$ = "Print_FFP": C$ = "Print 3 byte FFP, number is on the stack": GoSub AO
                Case 12
                    A$ = "JSR": B$ = "PRINT_DOUBLE": C$ = "Print 10 byte double, number is on the stack": GoSub AO
            End Select
        End If
        GoTo GetSectionToPrint
    Case TK_StrArray, TK_StringVar, TK_StringCommand
        Select Case v
            Case TK_StrArray ' Printing a String Array
                x = x - 1 ' make sure to inlcude the first String Array variable
                GoSub GetExpressionFullB4EndBracket: x = x + 2 ' Get an Expression before a close bracket, skip past $F5 and close bracket
                Expression$ = Expression$ + Chr$(&HF5) + Chr$(&H29) 'add the close bracket for parsing
            Case TK_StringVar ' Printing a String Variable
                x = x - 1 ' make sure to inlcude the first String variable
                GoSub GetExpressionB4SemiPlusComQ_EOL ' Get an Expression before a semi colon, a Plus, a comma, a quote or an EOL
            Case TK_StringCommand ' String Command
                x = x - 1 ' make sure to inlcude the the token for String command
                GoSub GetExpressionFullB4EndBracket: x = x + 2 ' Get an Expression before a close bracket, skip past $F5 and close bracket
                Expression$ = Expression$ + Chr$(&HF5) + Chr$(&H29) 'add the close bracket for parsing
        End Select
        GoSub ParseStringExpression ' Parse the String Expression, value will end up on the stack @ ,S
        GoSub AO
        Z$ = "; String is on the stack, deal with it here:": GoSub AO
        A$ = "LDB": B$ = ",S+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AO
        A$ = "BEQ": B$ = "@Done": C$ = "If the length of the string is zero then don't copy it (Skip ahead)": GoSub AO
        Z$ = "!"
        A$ = "LDA": B$ = ",S+": C$ = "Get a source byte": GoSub AO
        If PrintCC3 = 1 Then
            A$ = "LDY": B$ = "#" + PrintA$: C$ = "Y points at the routine to do, Go print A" + PrintDev$: GoSub AO
            A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
        Else
            ' Print to the CoCo 2 graphic screen
            A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AO
        End If
        A$ = "DECB": C$ = "Decrement the counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
        Z$ = "@Done": GoSub AO
        Print #1, "" ' Leave a space between sections so @Done will work for each section
        GoTo GetSectionToPrint

    Case &HF5 ' Found a special character
        v = Array(x): x = x + 1
        Select Case v
            Case TK_EOL, TK_Colon ' Do a carriage return/Line feed
                If Array(x - 4) = &HF5 And (Array(x - 3) = &H2C Or Array(x - 3) = &H3B) Then
                    Return 'if we previously did a comma or semicolon then Return
                Else
                    A$ = "LDA": B$ = "#$0D": C$ = "Do a Line Feed/Carriage Return": GoSub AO
                    If PrintCC3 = 1 Then
                        A$ = "LDY": B$ = "#" + PrintA$: C$ = "Y points at the routine to do, Go print A" + PrintDev$: GoSub AO
                        A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
                    Else
                        ' Print to the CoCo 2 graphic screen
                        A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AO
                    End If
                    Return ' we have reached the end of the line return
                End If

            Case TK_Quote ' Printing characters in quotes, PRINT "HELLO"
                GoSub PrintInQuotes ' Prints in quotes, x points after the end quote
                GoTo GetSectionToPrint





    Case &H23 ' Printing # somewhere other than the text screen , PRINT #-3,"Hello, World!"
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
                            If Gmode > 99 Then
                                ' Print to the CoCo 3 graphic screen
                                PrintCC3 = 1
                            Else
                                ' Print to the CoCo 2 graphic screen
                                PrintCC3 = 0
                            End If
                            PrintD$ = "PRINT_D_Graphics_Screen_" + GModeName$(Gmode): PrintA$ = "AtoGraphics_Screen_" + GModeName$(Gmode): PrintDev$ = " to graphic screen"
                            GoTo GetSectionToPrint
                        End If
                    End If
                End If
            End If
        End If
        Print "Can't handle printing to other devices on";: GoTo FoundError
    









            Case TK_Comma ' Handle a comma on the print line
                A$ = "LDD": B$ = "CURPOS": C$ = "Handling the comma": GoSub AO
                A$ = "ADDD": B$ = "#16": GoSub AO
                A$ = "ANDB": B$ = "#%11110000": C$ = "force it to be position 0 or 16": GoSub AO
                A$ = "TFR": B$ = "D,X": C$ = "Handle the comma in the PRINT command": GoSub AO
                A$ = "JSR": B$ = "UpdateCursor": GoSub AO
                GoTo GetSectionToPrint 'continue printing on the same line

            Case TK_SemiColon ' Handle a semi-colon
                GoTo GetSectionToPrint
        End Select

    Case TK_OperatorCommand ' Printing an operator
        If Array(x) = &H2D Then ' Printing a negative number like PRINT -1
            x = x - 1 ' make sure to inlcude the first Numeric variable
            GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
            GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
            If PrintCC3 = 1 Then
                A$ = "LDY": B$ = "#" + PrintD$: C$ = "Y points at the routine to do, Go print D" + PrintDev$: GoSub AO
                A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
                GoTo GetSectionToPrint
            Else
                ' Print to the CoCo 2 graphic screen
                A$ = "JSR": B$ = PrintD$: C$ = "Go print D" + PrintDev$: GoSub AO
                GoTo GetSectionToPrint
            End If
        Else
            If Array(x) = &H2B Then
                ' Found a Plus, Make sure it's not a number to print
                If Array(x + 1) >= Asc("0") And Array(x + 1) <= Asc("9") Then
                    'It is printing a number
                    x = x - 1 ' make it start at the +
                    GoSub GetExB4SemiComQ13D_EOL ' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon
                    GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
                    If PrintCC3 = 1 Then
                        A$ = "LDY": B$ = "#" + PrintD$: C$ = "Y points at the routine to do, Go print D" + PrintDev$: GoSub AO
                        A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
                        GoTo GetSectionToPrint
                    Else
                        ' Print to the CoCo 2 graphic screen
                        A$ = "JSR": B$ = PrintD$: C$ = "Go print D" + PrintDev$: GoSub AO
                        GoTo GetSectionToPrint
                    End If
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
    Case &HFF 'it could be printing inside an IF/ELSE line, so return
        x = x - 1
        v = Array(x)
        A$ = "LDA": B$ = "#$0D": C$ = "Do a Line Feed/Carriage Return": GoSub AO
        If PrintCC3 = 1 Then
            A$ = "LDY": B$ = "#" + PrintA$: C$ = "Y points at the routine to do, Go print A" + PrintDev$: GoSub AO
            A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
        Else
            ' Print to the CoCo 2 graphic screen
            A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AO
        End If
        Return
    Case &H40 'Found a PRINT @
        GoSub GetExpressionB4Comma: x = x + 2 ' Handle an expression that ends with a comma , move past the comma
        GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
        A$ = "JSR": B$ = "DoPrintAt": C$ = "Handle Print @ command": GoSub AO
        GoTo GetSectionToPrint
    Case &HFB ' Printing a FN - function
    Case Else
        Print "Error, Not sure how to print the end of line "; linelabel$; " v = $"; Hex$(v), Chr$(v)
        Print "x-2 = $"; Hex$(Array(x - 2))
        Print "x-1 = $"; Hex$(Array(x - 1))
        Print "x   = $"; Hex$(Array(x))
        Print "x+1 = $"; Hex$(Array(x + 1))
        Print "x+2 = $"; Hex$(Array(x + 2))
        Print "x+3 = $"; Hex$(Array(x + 3))
        System
End Select
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
If c = 0 Then x = x + 1: GoTo PrintQDone 'an empty string, skip the &H22 and "move along, nothing to see here"
' string has a value
x = Y
If c > 5 Then
    A$ = "BSR": B$ = ">": C$ = "Skip over string value": GoSub AO
    PrintQGetChars:
    v = Array(x): x = x + 1: 'Get next byte
    If v = &HF5 Then GoTo PrintQGotQuote ' end quote
    A$ = "FCB": B$ = "$" + Hex$(v): C$ = Chr$(v): GoSub AO
    GoTo PrintQGetChars
    PrintQGotQuote:
    x = x + 1 ' Point past the quote
    Z$ = "!"
    A$ = "LDB": B$ = "#" + Right$(Str$(c), Len(Str$(c)) - 1): C$ = "Length of this string": GoSub AO
    A$ = "LDU": B$ = ",S++": C$ = "Load U with the string start location off the stack and fix the stack": GoSub AO
    Z$ = "!"
    A$ = "LDA": B$ = ",U+": C$ = "Get the string data": GoSub AO
    If PrintCC3 = 1 Then
        A$ = "LDY": B$ = "#" + PrintA$: C$ = "Y points at the routine to do, Go print A" + PrintDev$: GoSub AO
        A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
    Else
        ' Print to the CoCo 2 graphic screen
        A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AO
    End If
    A$ = "DECB": C$ = "decrement the string length counter": GoSub AO
    A$ = "BNE": B$ = "<": C$ = "If not counted down to zero then loop": GoSub AO
Else
    'LDA and print A directly - it's faster if it's a short bit of text
    For c = 1 To c
        v = Array(x): x = x + 1: 'Get next byte
        A$ = "LDA": B$ = "#$" + Hex$(v): C$ = "A = Byte to print, " + Chr$(v): GoSub AO
        If PrintCC3 = 1 Then
            A$ = "LDY": B$ = "#" + PrintA$: C$ = "Y points at the routine to do, Go print A" + PrintDev$: GoSub AO
            A$ = "JSR": B$ = "DoCC3Graphics": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return": GoSub AO
        Else
            ' Print to the CoCo 2 graphic screen
            A$ = "JSR": B$ = PrintA$: C$ = "Go print A" + PrintDev$: GoSub AO
        End If
    Next c
    x = x + 2 ' skip past the end quote
End If
PrintQDone:
Return
