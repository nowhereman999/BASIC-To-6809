
' This will pull values off the ProcessRPNStack$(ProcessRPNStackPointer) and lower ProcessRPNStackPointer for each pull off the stack
DoNumericCommand:
' i$ is the current RPN token
cmd16 = Asc(Mid$(i$, 2, 1)) * 256 + Asc(Mid$(i$, 3, 1))
ArgCnt = 1
If Len(i$) >= 4 Then ArgCnt = Asc(Mid$(i$, 4, 1))

Z$ = "; Handle Numeric command here": GoSub AO
Select Case cmd16
    Case LPEEK_CMD
        ' LPEEK(addr) : one numeric arg -> returns UInt16
        If ArgCnt <> 1 Then
            Print "Error: LPEEK() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: LPEEK expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: LPEEK() expects a numeric address";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UInt32 address to be 32 bit value
        NVT = NT_UInt32
        GoSub ConvertLastType2NVT
        ' ------------------------------------------------------------
        ' CODEGEN: runtime stub
        ' Convention: address is at ,S (NT_UInt16). Stub consumes it and pushes value.
        ' ------------------------------------------------------------
        A$ = "JSR": B$ = "LPEEK": C$ = "Get the value in RAM of the long value on the stack and return the 8 bit value on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return

    Case COCOHARDWARE_CMD
        ' V=COCOHARDWARE(0)
        ' Where the bits of variable V will signify the CoCo Hardware as:
        ' Bit 0 is the Computer Type, 	0 = CoCo 1/2, 1 = CoCo 3
        ' Bit 7 is the CPU type,      	0 = 6809, 1 = 6309
        If ArgCnt <> 1 Then
            Print "Error: COCOHARDWARE() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOHARDWARE expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOHARDWARE() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to UInt16 address (matches your array-index convention)
'        NVT = NT_UInt16: GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDB": B$ = ">CoCoHardware": C$ = "Get the CoCo Hardware info byte": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return

    Case LEN_CMD
        ' LEN(x) : one arg
        If ArgCnt <> 1 Then
            Print "Error: LEN() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: LEN requires a string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: LEN() expects a string";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the argument value onto the 6809 stack
        ' This will do the right thing for:
        '   - string var (F3...)
        '   - string literal (F5 22 ... F5 22)
        '   - string result marker (&HF9) => already on 6809 stack
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack
        ' Call runtime: consumes string @,S and leaves length (NT_UByte) @,S
        '        A$ = "JSR": B$ = "StrFunctionLen": C$ = "LEN(string) -> NT_UByte": GoSub AO
        A$ = "PULS": B$ = "B": C$ = "Get the length of this string in B": GoSub AO
        A$ = "CLRA": C$ = "Make D = 16 bit version of B": GoSub AO
        A$ = "LEAS": B$ = "D,S": C$ = "Move S past the string": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Only save the Length of the string on the stack": GoSub AO
        Z$ = "!": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT: replace stack top with numeric-on-6809-stack marker
        ' Net effect: 1 arg popped, 1 result pushed.
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case PEEK_CMD
        ' PEEK(addr) : one numeric arg -> returns UInt8 (or UInt16 if you prefer)
        If ArgCnt <> 1 Then
            Print "Error: PEEK() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: PEEK expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: PEEK() expects a numeric address";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to UInt16 address (matches your array-index convention)
        NVT = NT_UInt16: GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        ' CODEGEN: runtime stub
        ' Convention: address is at ,S (UInt16). Stub consumes it and pushes value.
        ' ------------------------------------------------------------
        A$ = "LDB": B$ = "[,S++]": C$ = "B=PEEK(addr) move the stack two bytes": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Pick the type you want PEEK() to return:
        '   - NT_UByte (0..255) is typical
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return

    Case POS_CMD
        ' POS(addr) : one numeric arg -> returns UInt8 (or UInt16 if you prefer)
        If ArgCnt <> 1 Then
            Print "Error: POS() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: POS expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: POS() expects a numeric device number";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_Byte value (we want a range of -128 to 127)
        NVT = NT_Byte: GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        ' CODEGEN: runtime stub
        ' Convention: address is at ,S (UInt16). Stub consumes it and pushes value.
        ' ------------------------------------------------------------
        A$ = "LDB": B$ = ",S": C$ = "Get B (device #) off the stack": GoSub AO
        A$ = "BEQ": B$ = "@TextScreen": C$ = "If zero then it's the text screen": GOSub AO
        A$ = "CMPB": B$ = "#-3": C$ = "Is it POS from the graphics screen":Gosub AO
        A$ = "BEQ": B$ = "@GraphicScreen": C$ = "Get B (device #)": GOSub AO
        A$ = "LDD": B$ = "#$0000": C$ = "Anything else return with a value of zero": Gosub AO
        A$ = "BEQ": B$ = "@Done": C$ = "Save D on the stack and exit": GOSub AO
        Z$ = "@GraphicScreen:":gosub AO
        A$ = "LDD": B$ = "x0": C$ = "Get the x value in D": Gosub AO
        A$ = "BRA": B$ = "@Done": C$ = "Save D on the stack and exit": GOSub AO
        Z$ = "@TextScreen:":gosub AO
        A$ = "LDB": B$ = "BEGGRP": C$ = "Get the Text Screen start location": Gosub AO
        A$ = "CMPB": B$ = "#$05": C$ = "If it's > than $5FF then it's Width 40 or more Text screen":Gosub AO
        A$ = "BGT": B$ = ">": C$ = "If it's > $5FF skip ahead": GOSub AO
        A$ = "LDB": B$ = "CURPOS+1": C$ = "Get the x value in B (Width 32)": Gosub AO
        A$ = "ANDB": B$ = "#$1F": C$ = "Range 0 to 31": Gosub AO
        A$ = "BRA": B$ = "@DoneTextScreen": C$ = "CLRA then Save D on the stack and exit": GOSub AO
        Z$ = "!": A$ = "LDB": B$ = "CURPOS":C$ = "Get x value in B": GOSub AO
        A$ = "LSRB": C$ = "X value has the attribute byte, divide by 2": Gosub AO
        Z$ = "@DoneTextScreen": GOSUB AO
        A$ = "CLRA": C$ = "MSB is zero": Gosub AO
        Z$ = "@Done": GOSUB AO
        A$ = "STD": B$ = ",-S": C$ = "Move stack for 16 bit value and Save D on the stack": GoSub AO: GOSUB AO
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Pick the type you want POS() to return:
        '   - NT_UInt16 - Just in case it's printing on the CoCo 3 graphics screen
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case Else
        Print "Error: unknown numeric command id:"; cmd16; "";: GoTo FoundError
End Select


VerifyX:
If Val(GModeMaxX$(Gmode)) > 255 Then
    ' x value is a 16 bit number
    A$ = "TSTA": C$ = "Check if D is a negative": GoSub AO
    A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > " + GModeMaxX$(Gmode): GoSub AO
    A$ = "LDD": B$ = "#$0000": C$ = "Make value zero": GoSub AO
    A$ = "BRA": B$ = "@SaveD0": C$ = "Save B on the stack": GoSub AO
    Z$ = "!"
    A$ = "CMPD": B$ = "#" + GModeMaxX$(Gmode): C$ = "Check if D is > than " + GModeMaxX$(Gmode): GoSub AO
    A$ = "BLS": B$ = "@SaveD0": C$ = "If value is " + GModeMaxX$(Gmode) + " or < then skip ahead": GoSub AO
    A$ = "LDD": B$ = "#" + GModeMaxX$(Gmode): C$ = "Make the max size " + GModeMaxX$(Gmode): GoSub AO
    Z$ = "@SaveD0": GoSub AO: GoSub AO
Else
    A$ = "TSTA": C$ = "Check if D is a negative": GoSub AO
    A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > " + GModeMaxX$(Gmode): GoSub AO
    A$ = "CLRB": C$ = "Make value zero": GoSub AO
    A$ = "BRA": B$ = "@SaveB0": C$ = "Save B on the stack": GoSub AO
    Z$ = "!"
    A$ = "CMPD": B$ = "#" + GModeMaxX$(Gmode): C$ = "Check if B is > than " + GModeMaxX$(Gmode): GoSub AO
    A$ = "BLS": B$ = "@SaveB0": C$ = "If value is " + GModeMaxX$(Gmode) + " or < then skip ahead": GoSub AO
    A$ = "LDB": B$ = "#" + GModeMaxX$(Gmode): C$ = "Make the max size " + GModeMaxX$(Gmode): GoSub AO
    Z$ = "@SaveB0:": GoSub AO: GoSub AO
End If
Return

VerifyY:
'A$ = "LDD": B$ = ",S": C$ = "Check if D is too big": GoSub AO
'A$ = "BPL": B$ = ">": C$ = "If value is 0 or more then check if we are > " + GModeMaxX$(Gmode): GoSub AO
'A$ = "CLRB": C$ = "Make value zero": GoSub AO
'A$ = "BRA": B$ = "@SaveB1": C$ = "Save B on the stack": GoSub AO
'Z$ = "!"
A$ = "CMPB": B$ = "#" + GModeMaxY$(Gmode): C$ = "Check if B is > than " + GModeMaxY$(Gmode): GoSub AO
A$ = "BLS": B$ = "@SaveB1": C$ = "If value is " + GModeMaxY$(Gmode) + " or < then skip ahead": GoSub AO
A$ = "LDB": B$ = "#" + GModeMaxY$(Gmode): C$ = "Make the max size " + GModeMaxY$(Gmode): GoSub AO
Z$ = "@SaveB1:": GoSub AO: GoSub AO
Return
