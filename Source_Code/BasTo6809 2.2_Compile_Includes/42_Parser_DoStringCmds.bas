
' This will pull values off the ProcessRPNStack$(ProcessRPNStackPointer)
DoStringCommand:
Z$ = "; Handling String command here": GoSub AO

cmd16 = Asc(Mid$(i$, 2, 1)) * 256 + Asc(Mid$(i$, 3, 1))
ArgCnt = 1
If Len(i$) >= 4 Then ArgCnt = Asc(Mid$(i$, 4, 1))
Select Case cmd16
    Case SDC_GETCURDIR_CMD
        ' A$=SDC_GETCURDIR$()
        If ArgCnt <> 1 Then
            Print "Error: SDC_GETCURDIR$() expects 1 argument on";: GoTo FoundError
        End If
        ' Pop arg
        FileNumber$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push # so it ends up at ,S
        Temp$ = FileNumber$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        A$ = "LDB": B$ = ",S+": C$ = "Get the #": GoSub AO
        A$ = "BNE": B$ = ">": C$ = "If not zero use PF01": GoSub AO
        A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U points at the address to store the dir info" + Num$: GoSub AO
        A$ = "JSR": B$ = "SDC_GetCurrentDirectory": C$ = "Get Current directory command": GoSub AO
        A$ = "LDX": B$ = "#_StrVar_PF00+32": C$ = "X points at the end of the entry": GoSub AO
        A$ = "BRA": B$ = "@Skip": C$ = "Skip # 1 handling code": GoSub AO
        Z$ = "!": A$ = "LDU": B$ = "#_StrVar_PF01": C$ = "U points at the address to store the dir info" + Num$: GoSub AO
        A$ = "JSR": B$ = "SDC_GetCurrentDirectory": C$ = "Get Current directory command": GoSub AO
        A$ = "LDX": B$ = "#_StrVar_PF01+32": C$ = "X points at the end of the entry": GoSub AO
        Z$ = "@Skip": GoSub AO
        A$ = "LDB": B$ = "#16": C$ = "16 * 2 bytes to copy": GoSub AO
        Z$ = "!": A$ = "LDU": B$ = ",--X": C$ = "Get the source byte": GoSub AO
        A$ = "PSHS": B$ = "U": C$ = "Save the destination byte": GoSub AO
        A$ = "DECB": C$ = "Decrement counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "loop until counter reaches zero": GoSub AO
        A$ = "LDB": B$ = "#32": C$ = "Length of the string is 32 bytes": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save the length of the string": GoSub AO: GoSub AO
        ' Replace consumed token with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case SDC_DIRLIST_CMD
        ' A$ = SDC_DIRLIST$(x) command
        If ArgCnt <> 1 Then
            Print "Error: SDC_DIRLIST$() expects 1 argument on";: GoTo FoundError
        End If
        ' Pop arg
        FileNumber$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push # so it ends up at ,S
        Temp$ = FileNumber$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' Call runtime/stub: consumes (string, len) and pushes string result
        A$ = "PULS": B$ = "B": C$ = "B = Entry #": GoSub AO
        A$ = "LDA": B$ = "#16": C$ = "A = 16": GoSub AO
        A$ = "MUL": C$ = "B = Entry start value": GoSub AO
        A$ = "LDX": B$ = "#_StrVar_PF01+16": C$ = "X points at end of the first entry": GoSub AO
        A$ = "ABX": C$ = "X now points at the end of the requested Entry": GoSub AO
        A$ = "LDB": B$ = "#8": C$ = "# of loops to copy 16 bytes": GoSub AO
        Z$="!":A$ = "LDU": B$ = ",--X": C$ = "Get bytes from the source": GoSub AO
        A$ = "PSHS": B$ = "U": C$ = "Save bytes on the stack as the destination": GoSub AO
        A$ = "DECB": C$ = "decrement our counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "if not zero, keep looping": GoSub AO
        A$ = "LDB": B$ = "#16": C$ = "# of bytes in the string": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save the string length on the stack": GoSub AO
        ' Replace consumed token with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case SDC_DIRLIST_CMD
        ' A$ = SDC_DIRLIST$(x) command
        If ArgCnt <> 1 Then
            Print "Error: SDC_DIRLIST$() expects 1 argument on";: GoTo FoundError
        End If
        ' Pop arg
        FileNumber$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push # so it ends up at ,S
        Temp$ = FileNumber$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' Call runtime/stub: consumes (string, len) and pushes string result
        A$ = "PULS": B$ = "B": C$ = "B = Entry #": GoSub AO
        A$ = "LDA": B$ = "#16": C$ = "A = 16": GoSub AO
        A$ = "MUL": C$ = "B = Entry start value": GoSub AO
        A$ = "LDX": B$ = "#_StrVar_PF01+16": C$ = "X points at end of the first entry": GoSub AO
        A$ = "ABX": C$ = "X now points at the end of the requested Entry": GoSub AO
        A$ = "LDB": B$ = "#8": C$ = "# of loops to copy 16 bytes": GoSub AO
        Z$="!":A$ = "LDU": B$ = ",--X": C$ = "Get bytes from the source": GoSub AO
        A$ = "PSHS": B$ = "U": C$ = "Save bytes on the stack as the destination": GoSub AO
        A$ = "DECB": C$ = "decrement our counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "if not zero, keep looping": GoSub AO
        A$ = "LDB": B$ = "#16": C$ = "# of bytes in the string": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save the string length on the stack": GoSub AO
        ' Replace consumed token with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)




    Case SDC_FILEINFO_CMD
        ' SDC_FILEINFO$() command
        ' Get file info from the SDC A$=SDCFILEINFO$(filenumber)
        If ArgCnt <> 1 Then
            Print "Error: SDC_FILEINFO$() expects 1 argument on";: GoTo FoundError
        End If
        ' Pop arg
        FileNumber$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push # so it ends up at ,S
        Temp$ = FileNumber$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' Call runtime/stub: consumes (string, len) and pushes string result
        A$ = "PULS": B$ = "B": C$ = "B = File number": GoSub AO
        A$ = "ANDB": B$ = "#$01": C$ = "Make sure the value is either a 0 or a 1": GoSub AO
        A$ = "JSR": B$ = "SDC_FileInfo": C$ = "Get the file info for file #B in _STrVar_PF00": GoSub AO
        A$ = "LDB": B$ = "#16": C$ = "# of loops to copy 32 bytes": GoSub AO
        A$ = "LDU": B$ = "#_StrVar_IFRight+32": C$ = "End of the Source file info from the SDC": GoSub AO
        Z$="!":A$ = "LDX": B$ = ",--U": C$ = "Get bytes from the source": GoSub AO
        A$ = "PSHS": B$ = "X": C$ = "Save bytes on the stack as the destination": GoSub AO
        A$ = "DECB": C$ = "decrement our counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "if not zero, keep looping": GoSub AO
        A$ = "LDB": B$ = "#32": C$ = "# of bytes in the string": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save the string length on the stack": GoSub AO
        ' Replace consumed token with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case INKEY_CMD
        If ArgCnt <> 1 Then
            Print "Error: INKEY$ expects 0 argument on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): length, then source string
        '        CharTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push the character # @ ,S
        ' It's not a string, it's an ASCII code
        '        Temp$ = CharTok$: GoSub PushOneValueTokenOnStack
        '        LastType = PushedType
        '        NVT = NT_UByte ' Make sure it's 0 to 255 range
        '        GoSub ConvertLastType2NVT
        ' Call runtime/stub: consumes (string, len) and pushes string result

        A$ = "JSR": B$ = "StrCommandInkey": C$ = "If a key is pressed the string is on the stack, otherwise a zero is on the stack": GoSub AO

        '      JSR     KEYIN     ; This routine Polls the keyboard to see if a key is pressed, returns with value in A, A=0 if no key is pressed
        '      STA     ,-S       ; Save A on the stack
        '      BEQ     @Return   ; if A is zero, then that is the size of the string, return
        '      LDB     #1        ; We have a keypress so set the string length to 1
        '      STB     ,-S       ; Save 1 for the size on the stack

        ' Replace consumed tokens with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case STR_CMD
        If ArgCnt <> 1 Then
            Print "Error: HEX$() expects 1 argument on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): Number
        CharTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push the number @ ,S
        Temp$ = CharTok$: GoSub PushOneValueTokenOnStack ' Number on the stack is type PushedType
        LastType = PushedType
        Select Case PushedType
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
        ' Replace consumed tokens with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case HEX_CMD
        If ArgCnt <> 1 Then
            Print "Error: HEX$() expects 1 argument on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): Number
        CharTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push the number @ ,S
        Temp$ = CharTok$: GoSub PushOneValueTokenOnStack ' Number on the stack is type PushedType
        Select Case PushedType
            Case Is < 5
                A$ = "LDB": B$ = "#$01": C$ = "Single Byte to convert to Hex": GoSub AO
            Case 5, 6
                A$ = "LDB": B$ = "#$02": C$ = "Two bytes to convert to Hex": GoSub AO
            Case 7, 8
                A$ = "LDB": B$ = "#$04": C$ = "Four bytes to convert to Hex": GoSub AO
            Case 9, 10
                A$ = "LDB": B$ = "#$08": C$ = "Eight bytes to convert to Hex": GoSub AO
            Case 11
                A$ = "JSR": B$ = "FFP_TO_U64": C$ = "Convert 3 Byte FFP @ ,S to Unsigned 64-bit Integer @ ,S": GoSub AO
                A$ = "LDB": B$ = "#$08": C$ = "Eight bytes to convert to Hex": GoSub AO
            Case 12
                A$ = "JSR": B$ = "DB_TO_S64": C$ = "Convert 10 byte Double @ ,S to Signed 64-bit Integer @ ,S": GoSub AO
                A$ = "LDB": B$ = "#$08": C$ = "Eight bytes to convert to Hex": GoSub AO
        End Select
        ' Call runtime/stub: consumes (string, len) and pushes string result
        A$ = "JSR": B$ = "HexString": C$ = "Convert number @,S (B bytes long) to a Hex string on the stack": GoSub AO
        ' Replace consumed tokens with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case CHR_CMD
        If ArgCnt <> 1 Then
            Print "Error: CHR$() expects 1 argument on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): length, then source string
        CharTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push the character # @ ,S
        ' It's not a string, it's an ASCII code
        Temp$ = CharTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT
        ' Call runtime/stub: consumes (string, len) and pushes string result
        A$ = "LDA": B$ = "#$01": C$ = "A = 1, the length of this string": GoSub AO
        A$ = "STA": B$ = ",-S": C$ = "Save a 1 on the stack as the length of this CHR$ string": GoSub AO
        ' Replace consumed tokens with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case STRING_CMD
        If ArgCnt <> 2 Then
            Print "Error: STRING$() expects 2 arguments on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): length, then source string
        StrTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        CountTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1

        ' Push source string first, then count so count ends up at ,S
        ' If it's a string the first character will be $F9
        If Asc(Left$(StrTok$, 1)) = &HF9 Then
            ' It's a string
            Temp$ = StrTok$: GoSub PushOneStringTokenOnStack
        Else
            ' It's not a string, it's an ASCII code
            Temp$ = StrTok$: GoSub PushOneValueTokenOnStack
            LastType = PushedType
            NVT = NT_UByte ' Make sure it's 0 to 255 range
            GoSub ConvertLastType2NVT
        End If
        Temp$ = CountTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT
        If Asc(Left$(StrTok$, 1)) = &HF9 Then
            ' It's a string
            ' Call runtime/stub: consumes (string, len) and pushes string result
            A$ = "JSR": B$ = "StrString": C$ = "STRING$(count,string) -> string": GoSub AO
        Else
            ' It's not a string, it's an ASCII code
            ' Call runtime/stub: consumes (string, len) and pushes string result
            A$ = "JSR": B$ = "StrStringASCIIcode": C$ = "STRING$(count,ASCIIcode) -> string": GoSub AO
        End If
        ' Replace consumed tokens with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case LEFT_CMD
        ' LEFT$ command
        If ArgCnt <> 2 Then
            Print "Error: LEFT$() expects 2 arguments on";: GoTo FoundError
        End If
        If ProcessRPNStackPointer < 1 Then
            Print "Error: LEFT$ missing operands on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): length, then source string
        LenTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        StrTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push source string first, then length so length ends up at ,S
        Temp$ = StrTok$: GoSub PushOneStringTokenOnStack
        Temp$ = LenTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT
            ' Call runtime/stub: consumes (string, len) and pushes string result
            A$ = "JSR": B$ = "StrCommandLeft": C$ = "LEFT$ (string,len) -> string": GoSub AO
        ' Replace consumed tokens with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case RIGHT_CMD
        ' RIGHT$ command
        If ArgCnt <> 2 Then
            Print "Error: RIGHT$() expects 2 arguments on";: GoTo FoundError
        End If
        If ProcessRPNStackPointer < 1 Then
            Print "Error: RIGHT$ missing operands on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): length, then source string
        LenTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        StrTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push source string first, then length so length ends up at ,S
        Temp$ = StrTok$: GoSub PushOneStringTokenOnStack
        Temp$ = LenTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT
            ' Call runtime/stub: consumes (string, len) and pushes string result
            A$ = "JSR": B$ = "StrCommandRight": C$ = "RIGHT$ (string,len) -> string": GoSub AO
        ' Replace consumed tokens with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case MID_CMD
        ' -------- MID$ (keep your existing) --------
        If ArgCnt <> 2 And ArgCnt <> 3 Then
            Print "Error: MID$() expects 2 or 3 arguments on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): length,mid then source string
        If ArgCnt = 3 Then
            LenTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        End If
        MidTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        StrTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push source string first, then length so length ends up at ,S
        Temp$ = StrTok$: GoSub PushOneStringTokenOnStack
        Temp$ = MidTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT
        If ArgCnt = 3 Then
            Temp$ = LenTok$: GoSub PushOneValueTokenOnStack
            LastType = PushedType
            NVT = NT_UByte ' Make sure it's 0 to 255 range
            GoSub ConvertLastType2NVT
            ' Call runtime/stub: consumes (string, mid,len) and pushes string result
            A$ = "JSR": B$ = "StrCommandMid": C$ = "MID$ (string,mid,len) -> string": GoSub AO
        Else
            ' Call runtime/stub: consumes (string, mid) and pushes string result
            A$ = "JSR": B$ = "StrCommandMid2Arg": C$ = "MID$ (string,mid) -> string": GoSub AO
        End If
        ' Replace consumed tokens with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
    Case TRIM_CMD, LTRIM_CMD, RTRIM_CMD
        ' TRIM$, LTRIM$ or RTRIM$ command
        If ArgCnt <> 1 Then
            Print "Error: TRIM$ commands require only one argument on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): length, then source string
        StrTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push source string first, then length so length ends up at ,S
        Temp$ = StrTok$: GoSub PushOneStringTokenOnStack
        Select Case cmd16
            Case TRIM_CMD
                ' Call trim (string) and pushes string result
                A$ = "JSR": B$ = "StrCommandTrim": C$ = "TRIM$ (string) -> string": GoSub AO
            Case RTRIM_CMD
                ' Call trim (string) and pushes string result
                A$ = "JSR": B$ = "StrCommandRTrim": C$ = "TRIM$ (string) -> string": GoSub AO
            Case LTRIM_CMD
                ' Call trim (string) and pushes string result
                A$ = "JSR": B$ = "StrCommandLTrim": C$ = "TRIM$ (string) -> string": GoSub AO
        End Select
        ' Replace consumed tokens with one string-result marker
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
End Select
Return
