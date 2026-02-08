
' Jump to the general command pointed at by v
JumpToGeneralCommand:
Select Case GeneralCommands$(v)
    ' New command to add/test


    Case "FOR"
        GoTo DoFOR

    Case "NEXT"
        GoTo DoNEXT



        ' Old standard Commands
    Case "CLS"
        GoTo DoCLS
    Case "CPUSPEED"
        GoTo DoCPUSPEED
    Case "POKE"
        GoTo DoPOKE
    Case "DIM"
        GoTo DoDIM
    Case "GOSUB"
        GoTo DoGOSUB
    Case "GOTO"
        GoTo DoGOTO
    Case "PRINT"
        GoTo DoPRINT
    Case "RETURN"
        GoTo DoRETURN
    Case Else
        Print "Unknown General command??? "; GeneralCommands$(v); " on";: GoTo FoundError
        System
End Select

' New command to test
' ==============================================================================================================

GoSub ParseNumericExpression_UByte ' Parse Number and return with value as Unsigned value in B
GoSub ParseNumericExpression_Int16 ' Parse Number and return with value as Signed value in D
GoSub ParseNumericExpression_UInt16 ' Parse Number and return with value as Unsigned value in D
GoSub ParseNumericExpression ' Parse the Numeric Expression



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

?"TO Value:"
        show$=Expression$: gosub show

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

?"FOUND a STEp command!"

        'We have a STEP command so get the value of in D
        x = x + 3 ' move to the STEP amount
        GoSub GetExpressionB4EOL 'Handle an expression that ends with a colon or End of a Line
        show$=Expression$: gosub show
        ' D now has the value we need to Compare against each time we do a FOR Loop
        ' Self Mod Code where we compare the value of the variable aggainst what is now D
        Z$ = "; STEP Expression$=" + Expression$: GoSub AO
        
        GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
        Z$ = "; Got the TO value at ,S": GoSub AO
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


' Old needed good commands
' ==============================================================================================================

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

DoDIM:
' Nothing to do here, Tokenizer handled this
GoSub SkipToEOLColon ' Skip to the End of the Line or until a Colon
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

DoRETURN:
A$ = "RTS": C$ = "RETURN": GoSub AO
GoTo SkipUntilEOLColon ' Skip until we find an EOL or colon then return

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
        A$ = "LDB": B$ = ",S+": C$ = "B = length of the source string": GoSub AO
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
            A$ = "LDB": B$ = ",S+": C$ = "B = length of the source string": GoSub AO
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
