
' This will pull values off the ProcessRPNStack$(ProcessRPNStackPointer) and lower ProcessRPNStackPointer for each pull off the stack
DoNumericCommand:
' i$ is the current RPN token
cmd16 = Asc(Mid$(i$, 2, 1)) * 256 + Asc(Mid$(i$, 3, 1))
ArgCnt = 1
If Len(i$) >= 4 Then ArgCnt = Asc(Mid$(i$, 4, 1))
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
    Case COCOMP3_VOL_UP_CMD
        ' Increases the volume level by 1
        ' I=COCOMP3_VOL_UP(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_VOL_UP() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_VOL_UP requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_VOL_UP() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$14": C$ = "Command for COCOMP3_VOL_UP": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_VOL_MAX_CMD
        ' Sets the volume level to 30
        ' I=COCOMP3_VOL_MAX(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_VOL_MAX() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_VOL_MAX requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_VOL_MAX() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$81": C$ = "Command for COCOMP3_VOL_MAX": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_VOL_FADE_CMD
        ' Fade the volume of the playing track to volume level of zero over a set number of milliseconds then stop playback
        ' I=COCOMP3_VOL_FADE(x)
        ' Where x is the fade time in milliseconds
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_VOL_FADE() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_VOL_FADE requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_VOL_FADE() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UInt16
        NVT = NT_UInt16:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "X": C$ = "X is the primary value for the CoCoMP3": GoSub AO
        A$ = "LDA": B$ = "#$83": C$ = "Command for COCOMP3_VOL_FADE": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_VOL_DOWN_CMD
        ' Decreases the volume level by 1
        ' I=COCOMP3_VOL_DOWN(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_VOL_DOWN() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_VOL_DOWN requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_VOL_DOWN() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$15": C$ = "Command for COCOMP3_VOL_DOWN": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_TEST_CMD
        ' Verify the CoCoMP3 is set up and ready to use
        ' I=COCOMP3_TEST(0)
        ' It will respond with:
        '  0 = All good
        ' -1 = CoCoMP3 is not powered on or plugged in
        ' -2 = microSD card not detected
        ' -3 = no Tracks on microSD
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_TEST() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_TEST requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_TEST() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$80": C$ = "Command for COCOMP3_TEST": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_STOP_CMD
        ' Stop playback of the currently playing track
        ' I=COCOMP3_STOP(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_STOP() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_STOP requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_STOP() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$04": C$ = "Command for COCOMP3_STOP": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_SET_VOL_CMD
        ' Set the volume level from 0 to 30
        ' I=COCOMP3_SET_VOL(x)
        ' Where x is the volume level 0 to 30
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_SET_VOL() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_SET_VOL requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_SET_VOL() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UInt16
        NVT = NT_UInt16:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "X": C$ = "X is the primary value for the CoCoMP3": GoSub AO
        A$ = "LDA": B$ = "#$13": C$ = "Command for COCOMP3_SET_VOL": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_SET_TRACK_INTERLUDE_CMD
        ' This will interrupt the currently playing track and play a specific track number
        ' I=COCOMP3_SET_TRACK_INTERLUDE(x)
        ' Where x is the track number
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_SET_TRACK_INTERLUDE() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_SET_TRACK_INTERLUDE requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_SET_TRACK_INTERLUDE() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UInt16
        NVT = NT_UInt16:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "X": C$ = "X is the primary value for the CoCoMP3": GoSub AO
        A$ = "LDA": B$ = "#$16": C$ = "Command for COCOMP3_SET_TRACK_INTERLUDE": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_SET_PATH_INTERLUDE_CMD
        ' This will interrupt the currently playing track and play a specific folder
        ' I=COCOMP3_SET_PATH_INTERLUDE(O$)
        ' Where O$ is the full path to the folder example /FOLDER02/*MP3
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_SET_PATH_INTERLUDE() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_SET_PATH_INTERLUDE requires a string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: COCOMP3_SET_PATH_INTERLUDE() expects a string";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack
        A$ = "LEAX": B$ = ",S": C$ = "X points at the string to send to the CoCoMP3": GoSub AO
        A$ = "LDB": B$ = ",X+": C$ = "B = the length of the string and X now points at the first byte of the string": GoSub AO
        A$ = "LDA": B$ = "#$17": C$ = "Command for COCOMP3_SET_PATH_INTERLUDE": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3, value of A doesn't matter for RAW codes": GoSub AO
        A$ = "TFR": B$ = "D,U": C$ = "Save the response from the command": GoSub AO
        A$ = "LDB": B$ = ",S+": C$ = "Get the length of the string on the stack, move the stack": GoSub AO
        A$ = "CLRA":Gosub AO
        A$ = "LEAS": B$ = "D,S": C$ = "Move S past the string": GoSub AO
        A$ = "PSHS": B$ = "U": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_SET_EQ_CMD
        ' Set the equaliser setting inside the CoCoMP3 to a specific type
        ' I=COCOMP3_SET_EQ(x)
        ' Where x is the EQ value 0 to 4
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_SET_EQ() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_SET_EQ requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_SET_EQ() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UInt16
        NVT = NT_UInt16:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "X": C$ = "X is the primary value for the CoCoMP3": GoSub AO
        A$ = "LDA": B$ = "#$1A": C$ = "Command for COCOMP3_SET_EQ": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_SET_CYCLE_TIMES_CMD
        ' The number of times a track will be played or a folder of songs will be played over and over
        ' I=COCOMP3_SET_CYCLE_TIMES(x)
        ' Where x is the number of cycles to do
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_SET_CYCLE_TIMES() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_SET_CYCLE_TIMES requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_SET_CYCLE_TIMES() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UInt16
        NVT = NT_UInt16:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "X": C$ = "X is the primary value for the CoCoMP3": GoSub AO
        A$ = "LDA": B$ = "#$19": C$ = "Command for COCOMP3_SET_CYCLE_TIMES": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_SELECT_BUT_NO_PLAY_CMD
        ' Stop playing the current track, queue up a specific track number
        ' I=COCOMP3_SELECT_BUT_NO_PLAY(x)
        ' Where x is the track number to queue up
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_SELECT_BUT_NO_PLAY() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_SELECT_BUT_NO_PLAY requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_SELECT_BUT_NO_PLAY() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UInt16
        NVT = NT_UInt16:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "X": C$ = "X is the primary value for the CoCoMP3": GoSub AO
        A$ = "LDA": B$ = "#$1F": C$ = "Command for COCOMP3_SELECT_BUT_NO_PLAY": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_RAW_CMD
        ' I=COCOMP3_RAW$(O$)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_RAW() expects one argument";: GoTo FoundError
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
            Print "Error: COCOMP3_RAW() expects a string";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack ' String is now on the stack
        A$ = "LEAX": B$ = ",S": C$ = "X points at the string to send to the CoCoMP3": GoSub AO
        A$ = "LDB": B$ = ",X+": C$ = "B = the length of the string and X now points at the first byte of the string": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3, value of A doesn't matter for RAW codes": GoSub AO
        A$ = "TFR": B$ = "D,U": C$ = "Save the response from the command": GoSub AO
        A$ = "LDB": B$ = ",S+": C$ = "Get the length of the string on the stack, move the stack": GoSub AO
        A$ = "CLRA":Gosub AO
        A$ = "LEAS": B$ = "D,S": C$ = "Move S past the string": GoSub AO
        A$ = "PSHS": B$ = "U": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT: replace stack top with numeric-on-6809-stack marker
        ' Net effect: 1 arg popped, 1 result pushed.
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_PREVIOUS_CMD
        ' Play the previous track
        ' I=COCOMP3_PREVIOUS(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_PREVIOUS() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_PREVIOUS requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_PREVIOUS() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$05": C$ = "Command for COCOMP3_PREVIOUS": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_PLAY_TRACK_NUMBER_CMD
        ' Play a specific track number on the microSD
        ' I=COCOMP3_PLAY_TRACK_NUMBER(x)
        ' Where x is the track number on the microSD to play
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_PLAY_TRACK_NUMBER() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_PLAY_TRACK_NUMBER requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_PLAY_TRACK_NUMBER() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UInt16
        NVT = NT_UInt16:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "X": C$ = "X is the primary value for the CoCoMP3": GoSub AO
        A$ = "LDA": B$ = "#$07": C$ = "Command for COCOMP3_PLAY_TRACK_NUMBER": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_PLAY_TRACK_CMD
        ' Play a specific track number on the microSD
        ' I=COCOMP3_PLAY_TRACK(O$)
        ' Where O$ is the full path to the TRACK to PLAY as /FOLDER02/00001.MP3
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_PLAY_TRACK() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_PLAY_TRACK requires a string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: COCOMP3_PLAY_TRACK() expects a string";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack
        A$ = "LEAX": B$ = ",S": C$ = "X points at the string to send to the CoCoMP3": GoSub AO
        A$ = "LDB": B$ = ",X+": C$ = "B = the length of the string and X now points at the first byte of the string": GoSub AO
        A$ = "LDA": B$ = "#$08": C$ = "Command for COCOMP3_PLAY_TRACK": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3, value of A doesn't matter for RAW codes": GoSub AO
        A$ = "TFR": B$ = "D,U": C$ = "Save the response from the command": GoSub AO
        A$ = "LDB": B$ = ",S+": C$ = "Get the length of the string on the stack, move the stack": GoSub AO
        A$ = "CLRA":Gosub AO
        A$ = "LEAS": B$ = "D,S": C$ = "Move S past the string": GoSub AO
        A$ = "PSHS": B$ = "U": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_PLAY_PREVIOUS_FOLDER_CMD
        ' Moves the play pointer to the previous folder
        ' I=COCOMP3_PLAY_PREVIOUS_FOLDER(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_PLAY_PREVIOUS_FOLDER() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_PLAY_PREVIOUS_FOLDER requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_PLAY_PREVIOUS_FOLDER() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$0E": C$ = "Command for COCOMP3_PLAY_PREVIOUS_FOLDER": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_PLAY_NEXT_FOLDER_CMD
        ' Advances to the next folder
        ' I=COCOMP3_PLAY_NEXT_FOLDER(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_PLAY_NEXT_FOLDER() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_PLAY_NEXT_FOLDER requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_PLAY_NEXT_FOLDER() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$0F": C$ = "Command for COCOMP3_PLAY_NEXT_FOLDER": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_PLAY_CMD
        ' Play the current track, or the first track on the microSD after power on.
        ' I=COCOMP3_PLAY(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_PLAY() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_PLAY requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_PLAY() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$02": C$ = "Command for COCOMP3_PLAY": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_PAUSE_CMD
        ' Pauses playback of the track
        ' I=COCOMP3_PAUSE(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_PAUSE() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_PAUSE requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_PAUSE() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$03": C$ = "Command for COCOMP3_PAUSE": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_NEXT_CMD
        ' Play the next track
        ' I=COCOMP3_NEXT(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_NEXT() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_NEXT requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_NEXT() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$06": C$ = "Command for COCOMP3_NEXT": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_GET_TRACKS_IN_FOLDER_CMD
        ' Get the play status of the CoCoMP3
        ' I=COCOMP3_GET_TRACKS_IN_FOLDER(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_GET_TRACKS_IN_FOLDER() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_GET_TRACKS_IN_FOLDER requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_GET_TRACKS_IN_FOLDER() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$12": C$ = "Command for GET_TRACKS_IN_FOLDER": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_GET_PLAY_STATUS_CMD
        ' Get the play status of the CoCoMP3
        ' I=COCOMP3_GET_PLAY_STATUS(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_GET_PLAY_STATUS() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_GET_PLAY_STATUS requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_GET_PLAY_STATUS() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$01": C$ = "Command for GET_PLAY_STATUS": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_GET_NUMBER_OF_TRACKS_CMD
        ' Returns with the total number of tracks on the microSD
        ' I=COCOMP3_GET_NUMBER_OF_TRACKS(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_GET_NUMBER_OF_TRACKS() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_GET_NUMBER_OF_TRACKS requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_GET_NUMBER_OF_TRACKS() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$0C": C$ = "Command for GET_NUMBER_OF_TRACKS": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_GET_FOLDER_DIR_TRACK_CMD
        ' Returns with the first Track number in the current folder
        ' I=COCOMP3_GET_FOLDER_DIR_TRACK(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_GET_FOLDER_DIR_TRACK() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_GET_DRIVE_STATUS requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_GET_FOLDER_DIR_TRACK() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$11": C$ = "Command for GET_FOLDER_DIR_TRACK": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_GET_DRIVE_STATUS_CMD
        ' Get the current drive status
        ' I=COCOMP3_GET_DRIVE_STATUS(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_GET_DRIVE_STATUS() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_GET_DRIVE_STATUS requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_GET_DRIVE_STATUS() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$09": C$ = "Command for GET_DRIVE_STATUS": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_GET_CURRENT_TRACK_CMD
        ' Returns current track number
        ' I=COCOMP3_GET_CURRENT_TRACK(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_GET_CURRENT_TRACK() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_GET_CURRENT_TRACK requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_GET_CURRENT_TRACK() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$0D": C$ = "Command for GET_CURRENT_TRACK": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_END_PLAYING_CMD
        ' End playing the current track and skip to the next track similar to Next
        ' I=COCOMP3_END_PLAYING(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_END_PLAYING() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_END_PLAYING requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_END_PLAYING() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$10": C$ = "Command for END_PLAYING": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_END_COMBINATION_PLAY_CMD
        ' End combination play
        ' I=COCOMP3_END_COMBINATION_PLAY(0)
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_END_COMBINATION_PLAY() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_END_COMBINATION_PLAY requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_END_COMBINATION_PLAY() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
'        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
'        LastType = PushedType
'        ' Force to NT_UByte
'        NVT = NT_UByte:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "LDA": B$ = "#$1C": C$ = "Command for END_COMBINATION_PLAY": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_CYCLE_MODE_SETTING_CMD
        ' Change the playback cycle mode
        ' I=COCOMP3_CYCLE_MODE_SETTING(x)
        ' Where x is a value of 0 to 7
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_CYCLE_MODE_SETTING() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_CYCLE_MODE_SETTING requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_CYCLE_MODE_SETTING() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UByte
        NVT = NT_UInt16:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "X": C$ = "X is the primary value for the CoCoMP3": GoSub AO
        A$ = "LDA": B$ = "#$18": C$ = "Command for CYCLE_MODE_SETTING": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_COMBINATION_PLAY_SETTING_CMD
        ' Set range of tracks to play
        ' I=COCOMP3_COMBINATION_PLAY_SETTING(x,y)
        ' Where x is the first track and y is the last track in the range
        If ArgCnt <> 2 Then
            Print "Error: COCOMP3_COMBINATION_PLAY_SETTING() expects 2 arguments on";: GoTo FoundError
        End If
        If ProcessRPNStackPointer < 1 Then
            Print "Error: COCOMP3_COMBINATION_PLAY_SETTING() missing operands on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first):
        Toky$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Tokx$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push y then x on the stack
        Temp$ = Toky$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UInt16: GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        Temp$ = Tokx$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UInt16: GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "X,U": C$ = "Get the Primary in X and secondary value in U for the CoCoMP3": GoSub AO
        A$ = "LDA": B$ = "#$1B": C$ = "Command for COMBINATION-PLAY-SETTING": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case COCOMP3_AUDIO_MODE_CMD
        ' I=COCOMP3_AUDIO_MODE(x)
        ' Where x is:
        '    0 -     Leave the audio setting unchanged
        '    1 -     (Default) Audio from the CoCoMP3 will come from the
        '            Cassette interface and play through the TV speakers
        ' Result: I = the response bytes from the CoCoMP3
        If ArgCnt <> 1 Then
            Print "Error: COCOMP3_AUDIO_MODE() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COCOMP3_AUDIO_MODE requires a numeric
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COCOMP3_AUDIO_MODE() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to UInt16
        NVT = NT_UInt16:GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "X": C$ = "X is the primary value for the CoCoMP3": GoSub AO
        A$ = "LDA": B$ = "#$84": C$ = "Command for AUDIO_MODE": GoSub AO
        A$ = "JSR": B$ = "SendToCoCoMP3": C$ = "Send the command to the CoCoMP3": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the CoCoMP3 results on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case SDC_DIRPAGE_CMD
        ' SDC_DIRPAGE(addr) : one numeric arg -> returns UInt8 (or UInt16 if you prefer)
        If ArgCnt <> 1 Then
            Print "Error: SDC_DIRPAGE() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: PEEK expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: SDC_DIRPAGE() expects a numeric argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        ' We don't need to use the value given so ignore putting it on the stack
        ' Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        ' LastType = PushedType
        ' ' Force to UInt16 address (matches your array-index convention)
        ' NVT = NT_UByte
        ' GoSub ConvertLastType2NVT
        ' ------------------------------------------------------------
        ' CODEGEN: runtime stub
        ' Convention: address is at ,S (UInt16). Stub consumes it and pushes value.
        ' ------------------------------------------------------------
        A$ = "LDU": B$ = "#_StrVar_PF01": C$ = "U points at scratch buffer for the 256 byte directory listing": GoSub AO
        A$ = "JSR": B$ = "SDC_DirectoryPage": C$ = "Get the directory listing": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B (result of the command) on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Pick the type you want PEEK() to return:
        '   - NT_UByte (0..255) is typical
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case  SDC_GETBYTE_CMD:
' Read a byte from the SDC file, which must already be open x=SDCGETBYTE(filenumber)
        ' SDC_GETBYTE(#) : one numeric arg -> returns UInt8 (or UInt16 if you prefer)
        If ArgCnt <> 1 Then
            Print "Error: SDC_GETBYTE() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: SDC_GETBYTE expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: SDC_GETBYTE() expects a 0 or 1";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to UByte (matches your array-index convention)
        NVT = NT_UByte
        GoSub ConvertLastType2NVT
        ' ------------------------------------------------------------
        ' CODEGEN: runtime stub
        ' Convention: # is at ,S (UByte). Stub consumes it and pushes value.
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "B": C$ = "Get B off the stack": GoSub AO
        A$ = "JSR": B$ = "SDCGetByte": C$ = "Get the next byte in the file B, return with result in B": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B (result of the command) on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case SDC_DELETE_CMD
        ' x=SDC_DELETE("FULL PATH TO DIRECTORY/FILE")
        If ArgCnt <> 1 Then
            Print "Error: SDC_DELETE() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: SDC_DELETE requires a string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: SDC_DELETE() expects a string";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the argument value onto the 6809 stack
        ' This will do the right thing for:
        '   - string var (F3...)
        '   - string literal (F5 22 ... F5 22)
        '   - string result marker (&HF9) => already on 6809 stack
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack
        ' Call runtime: consumes string @,S and leaves result (NT_UByte) @,S
        A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
        A$ = "JSR": B$ = "SDC_Delete": C$ = "Delete empty directory or filename stored _StrVar_PF00 on the SDC": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B (result of the command) on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT: replace stack top with numeric-on-6809-stack marker
        ' Net effect: 1 arg popped, 1 result pushed.
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case SDC_MKDIR_CMD
        ' x=SDC_MKDIR("FULL PATH TO DIRECTORY")
        If ArgCnt <> 1 Then
            Print "Error: SDC_MKDIR() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: SDC_MKDIR requires a string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: SDC_MKDIR() expects a string";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the argument value onto the 6809 stack
        ' This will do the right thing for:
        '   - string var (F3...)
        '   - string literal (F5 22 ... F5 22)
        '   - string result marker (&HF9) => already on 6809 stack
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack
        ' Call runtime: consumes string @,S and leaves result (NT_UByte) @,S
        A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
        A$ = "JSR": B$ = "SDC_CreateDirectory": C$ = "Make a directory from string _StrVar_PF00 on the SDC": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B (result of the command) on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT: replace stack top with numeric-on-6809-stack marker
        ' Net effect: 1 arg popped, 1 result pushed.
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case SDC_SETDIR_CMD
        ' x=SDC_SETDIR("FULL PATH TO DIRECTORY")
        If ArgCnt <> 1 Then
            Print "Error: SDC_SETDIR() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: SDC_SETDIR requires a string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: SDC_SETDIR() expects a string";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the argument value onto the 6809 stack
        ' This will do the right thing for:
        '   - string var (F3...)
        '   - string literal (F5 22 ... F5 22)
        '   - string result marker (&HF9) => already on 6809 stack
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack
        ' Call runtime: consumes string @,S and leaves result (NT_UByte) @,S
        A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
        A$ = "JSR": B$ = "SDC_SetCurrrentDirectory": C$ = "Set the current directory to _StrVar_PF00 on the SDC": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B (result of the command) on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT: replace stack top with numeric-on-6809-stack marker
        ' Net effect: 1 arg popped, 1 result pushed.
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case SDC_INITDIR_CMD
        ' x=SDC_INITDIR("Path/*.TXT")
        If ArgCnt <> 1 Then
            Print "Error: SDC_INITDIR() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: SDC_INITDIR requires a string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: SDC_INITDIR() expects a string";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the argument value onto the 6809 stack
        ' This will do the right thing for:
        '   - string var (F3...)
        '   - string literal (F5 22 ... F5 22)
        '   - string result marker (&HF9) => already on 6809 stack
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack
        ' Call runtime: consumes string @,S and leaves result (NT_UByte) @,S
        A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
        A$ = "JSR": B$ = "SDC_InitDirectory": C$ = "Initiate a directory listing of name stored in _StrVar_PF00 on the SDC": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B (result of the command) on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT: replace stack top with numeric-on-6809-stack marker
        ' Net effect: 1 arg popped, 1 result pushed.
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case TIMER_NumericCMD
        ' TIMER : 0-arg function (your convention often leaves ArgCnt at 1 when no ArgCnt byte exists)
        If ArgCnt <> 1 Then
            Print "Error: TIMER expects 0 arguments";: GoTo FoundError
        End If
        A$ = "LDD": B$ = "_Var_Timer": C$ = "TIMER (VSYNC count 0..65535)": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Push TIMER as UInt16": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case ABS_CMD
        If ArgCnt <> 1 Then
            Print "Error: ABS() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: ABS expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: ABS() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        GoSub DoABS
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
        Return
    Case ASC_CMD
        If ArgCnt <> 1 Then
            Print "Error: ASC() expects 1 argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: ASC requires a string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: ASC() expects a string";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the argument value onto the 6809 stack
        ' This will do the right thing for:
        '   - string var (F3...)
        '   - string literal (F5 22 ... F5 22)
        '   - string result marker (&HF9) => already on 6809 stack
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack ' Make sure it's only one byte on the stack
        ' Call runtime: consumes string @,S and leaves length (NT_UByte) @,S
        ' CODEGEN: runtime stub
        ' Convention: address is at ,S (UInt16). Stub consumes it and pushes value.
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "B": C$ = "B = Length of the string": GoSub AO
        A$ = "LEAX": B$ = ",S": C$ = "X=S": GoSub AO
        A$ = "LDA": B$ = ",S": C$ = "A First byet of the string": GoSub AO
        A$ = "ABX": C$ = "Fix the size of the stack (just in case it's a sting instead of just a byte)": GoSub AO
        A$ = "LEAS": B$ = ",X": C$ = "S=X": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Save A on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Pick the type you want ASC() to return:
        '   - NT_UByte (0..255) is typical
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case ATN_CMD
        If ArgCnt <> 1 Then
            Print "Error: ATN() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: ATN expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: ATN() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        GoSub DoATN
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
        Return
    Case COS_CMD
        If ArgCnt <> 1 Then
            Print "Error: COS() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: COS expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: COS() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        GoSub DoCOS
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
        Return
    Case EXP_CMD
        If ArgCnt <> 1 Then
            Print "Error: EXP() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: EXP expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: EXP() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        GoSub DoEXP
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
        Return
    Case INT_CMD
        If ArgCnt <> 1 Then
            Print "Error: INT() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: INT expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: INT() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        GoSub DoINT
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
        Return
    Case INSTR_CMD
        ' p = INSTR([startPos,] stringToSearch$, thingToFind$)
        ' -------- MID$ (keep your existing) --------
        If ArgCnt <> 2 And ArgCnt <> 3 Then
            Print "Error: INSTR() expects 2 or 3 arguments";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): thingToFind$, stringToSearch$ then startPos (If given)
        thingToFindTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        stringToSearchTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        If ArgCnt = 3 Then
            Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
            ' Type check: INT expects numeric, not string
            Temp$ = Arg1$: GoSub IsStringToken
            If IsStrFlag% Then
                Print "Error: INSTR() If given first value needs to be a numeric value";: GoTo FoundError
            End If
        Else ' No value given, start at position 1
            Arg1$ = "1" + Chr$(&H84) ' Make it a 1 as UByte
        End If
        ' Push stringToSearchTok$ first, then thingToFind$, then startPos$ ,S
        Temp$ = stringToSearchTok$: GoSub PushOneStringTokenOnStack
        Temp$ = thingToFindTok$: GoSub PushOneStringTokenOnStack
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT
        A$ = "JSR": B$ = "StrCommandINSTR": C$ = "Do INSTR command return with value @,S": GoSub AO
        ' Replace consumed tokens with one numeric-result marker
        ' ------------------------------------------------------------
        ' PUSH RESULT: replace stack top with numeric-on-6809-stack marker
        ' Net effect: 1 arg popped, 1 result pushed.
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
    Case VARPTR_CMD
        If ArgCnt <> 1 Then Print "Error: VARPTR() expects 1 argument";: GoTo FoundError
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' If already an address marker (from OP_ARRPTR), accept it
        'show$=Arg1$:gosub show
        If Asc(Left$(Arg1$, 1)) = TK_ADDR_ONSTACK Then
            If Asc(Right$(Arg1$, 1)) <> NT_UInt16 Then
                Print "Error: VARPTR() needs a variable/array element, not a value";: GoTo FoundError
            End If
            ' already have UInt16 address on 6809 stack
            GoTo VarptrReturn
            '            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
            '        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA)+Chr$(0)+Chr$(0)+Chr$(NT_UInt16)
            ''            ProcessRPNStack$(ProcessRPNStackPointer) = Arg1$
            Return
        End If
        ' Scalar numeric var
        If Asc(Left$(Arg1$, 1)) = TK_NumericVar Then
            NumVarNumber = Asc(Mid$(Arg1$, 2, 1)) * 256 + Asc(Mid$(Arg1$, 3, 1))
            ' Emit address of the variable into X and push X
            ' (use your existing variable-name/label mapping)
            A$ = "LDD": B$ = "#_Var_" + NumericVariable$(NumVarNumber): C$ = "Variable Address": GoSub AO
            A$ = "PSHS": B$ = "D": C$ = "Save the value on the stack": GoSub AO
            GoTo VarptrReturn
        End If
        ' Scalar string var
        If Asc(Left$(Arg1$, 1)) = TK_StringVar Then
            StrVarNumber = Asc(Mid$(Arg1$, 2, 1)) * 256 + Asc(Mid$(Arg1$, 3, 1))
            A$ = "LDD": B$ = "#_StrVar_" + StringVariable$(StrVarNumber): C$ = "Variable Address": GoSub AO
            A$ = "PSHS": B$ = "D": C$ = "Save the value on the stack": GoSub AO
            GoTo VarptrReturn
        End If
        Print "Error: VARPTR() expects a variable or array element";: GoTo FoundError
        VarptrReturn:
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case VAL_CMD
        ' VAL(x) : one arg
        If ArgCnt <> 1 Then
            Print "Error: VAL() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: VAL requires a string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: VAL() expects a string";: GoTo FoundError
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
        A$ = "JSR": B$ = "NumericString_To_FFP": C$ = "Convert string @,S to FFP @,S": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT: replace stack top with numeric-on-6809-stack marker
        ' Net effect: 1 arg popped, 1 result pushed.
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_Single)
        Return
    Case SGN_CMD
        If ArgCnt <> 1 Then
            Print "Error: SGN() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: SGN expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: SGN() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        ' Handle SGN based of the numeric type
        Select Case LastType
            Case Is < NT_Int16 ' 8 Bit integer
                A$ = "CLRA": C$ = "A = 0": GoSub AO
                A$ = "LDB": B$ = ",S": C$ = "Load B": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Save Zero on the stack": GoSub AO
                A$ = "SEX": C$ = "Sign extend into A": GoSub AO
                A$ = "BMI": B$ = ">": C$ = "Save -1 on the stack": GoSub AO
                A$ = "INCA": C$ = "Make A = 1": GoSub AO
            Case Is < NT_Int32 ' 16 Bit integer
                A$ = "LDD": B$ = ",S+": C$ = "Load D, move stack": GoSub AO
                A$ = "BEQ": B$ = ">": C$ = "Save Zero on the stack": GoSub AO
                A$ = "TFR": B$ = "A,B": C$ = "B has the sign bit": GoSub AO
                A$ = "SEX": C$ = "Sign extend into A": GoSub AO
                A$ = "BMI": B$ = ">": C$ = "Save -1 on the stack": GoSub AO
                A$ = "INCA": C$ = "Make A = 1": GoSub AO
            Case Is < NT_Int64 ' 32 Bit integer
                A$ = "CLRA": C$ = "A = 0": GoSub AO
                A$ = "LDX": B$ = ",S": C$ = "Load B": GoSub AO
                A$ = "BNE": B$ = "@NotZero": C$ = "Not zero value": GoSub AO
                A$ = "LDX": B$ = "2,S": C$ = "Load B": GoSub AO
                A$ = "BEQ": B$ = "@GotA": C$ = "If it's zero then we FFP is zero": GoSub AO
                Z$ = "@NotZero": GoSub AO
                A$ = "LDB": B$ = ",S": C$ = "B has the sign": GoSub AO
                A$ = "SEX": C$ = "Sign extend into A": GoSub AO
                A$ = "BMI": B$ = "@GotA": C$ = "Save -1 on the stack": GoSub AO
                A$ = "INCA": C$ = "Make A = 1": GoSub AO
                Z$ = "@GotA:": GoSub AO
                A$ = "LEAS": B$ = "3,S": C$ = "move stack": GoSub AO
            Case Is < NT_Single ' 64 Bit integer
                A$ = "CLRA": C$ = "A = 0": GoSub AO
                A$ = "LDB": B$ = "#7": C$ = "7+1 bytes to check for zero": GoSub AO
                Z$ = "!": A$ = "ORA": B$ = "B,S": C$ = "OR bits": GoSub AO
                A$ = "DECB": C$ = "Decrement the counter": GoSub AO
                A$ = "BPL": B$ = "<": GoSub AO
                A$ = "TSTA": C$ = "Check if all bits are zero": GoSub AO
                A$ = "BEQ": B$ = "@GotA": C$ = "If it's zero then we exit with zero": GoSub AO
                A$ = "LDB": B$ = ",S": C$ = "B has the sign": GoSub AO
                A$ = "SEX": C$ = "Sign extend into A": GoSub AO
                A$ = "BMI": B$ = "@GotA": C$ = "Save -1 on the stack": GoSub AO
                A$ = "INCA": C$ = "Make A = 1": GoSub AO
                Z$ = "@GotA:": GoSub AO
                A$ = "LEAS": B$ = "7,S": C$ = "move stack": GoSub AO
            Case Is = NT_Single ' FFP number
                A$ = "LDB": B$ = "1,S": C$ = "Check Mantissa MSB": GoSub AO
                A$ = "BEQ": B$ = "@GotA": C$ = "If it's zero then FFP is zero": GoSub AO
                A$ = "SEX": C$ = "Sign extend into A": GoSub AO
                A$ = "BMI": B$ = "@GotA": C$ = "save -1 on the stack": GoSub AO
                A$ = "INCA": C$ = "Make A = 1": GoSub AO
                Z$ = "@GotA:": GoSub AO
                A$ = "LEAS": B$ = "2,S": C$ = "move stack": GoSub AO
            Case Is = NT_Double ' Double number
                A$ = "LDB": B$ = "3,S": C$ = "Get Mantissa bits, should always have bit 52 set, unless it's zero": GoSub AO
                A$ = "BEQ": B$ = "@GotA": C$ = "If it's zero then Double is zero": GoSub AO
                A$ = "LDB": B$ = ",S": C$ = "get Sign value": GoSub AO
                A$ = "SEX": C$ = "Sign extend into A": GoSub AO
                A$ = "BMI": B$ = "@GotA": C$ = "save -1 on the stack": GoSub AO
                A$ = "INCA": C$ = "Make A = 1": GoSub AO
                Z$ = "@GotA:": GoSub AO
                A$ = "LEAS": B$ = "9,S": C$ = "move stack": GoSub AO
            Case Else
                Print "Error: SGN() unknown value type";: GoTo FoundError
        End Select
        Z$ = "!": A$ = "STA": B$ = ",S": C$ = "Save A on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_Byte)
        Return
    Case FIX_CMD
        If ArgCnt <> 1 Then
            Print "Error: FIX() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: FIX expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: FIX() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        ' Handle SGN based of the numeric type
        Select Case LastType
            Case Is = NT_Single ' FFP number
                A$ = "LDB": B$ = ",S": C$ = "Check Sign": GoSub AO
                A$ = "BMI": B$ = "@DoNEG": C$ = "If it's Negative then do make positive and do INT": GoSub AO
                A$ = "JSR": B$ = "FFP_FLOOR": C$ = "Compute floor(x) for 3 byte FFP number": GoSub AO
                A$ = "BRA": B$ = ">": C$ = "Skip past": GoSub AO
                Z$="@DoNEG:": GOSUB AO
                A$ = "ANDB": B$ = "#%01111111": C$ = "Make it positive": GoSub AO
                A$ = "STB": B$ = ",S": C$ = "Save Positive version": GoSub AO
                A$ = "JSR": B$ = "FFP_FLOOR": C$ = "Compute floor(x) for 3 byte FFP number": GoSub AO
                A$ = "LDB": B$ = ",S": C$ = "Get Sign&Exponent": GoSub AO
                A$ = "ORB": B$ = "#%10000000": C$ = "Make it Negative": GoSub AO
                A$ = "STB": B$ = ",S": C$ = "Save Negative version": GoSub AO
                Z$ = "!":  GoSub AO:gosub AO
            Case Is = NT_Double ' Double number
                A$ = "LDB": B$ = ",S": C$ = "Check Sign": GoSub AO
                A$ = "BMI": B$ = "@DoNEG": C$ = "If it's Negative then do make positive and do INT": GoSub AO
                A$ = "JSR": B$ = "DB_FLOOR": C$ = "Compute floor(x) for 10 byte double-precision number": GoSub AO
                A$ = "BRA": B$ = ">": C$ = "Skip past": GoSub AO
                Z$="@DoNEG:": GOSUB AO
                A$ = "ANDB": B$ = "#%01111111": C$ = "Make it positive": GoSub AO
                A$ = "STB": B$ = ",S": C$ = "Save Positive version": GoSub AO
                A$ = "JSR": B$ = "DB_FLOOR": C$ = "Compute floor(x) for 10 byte double-precision number": GoSub AO
                A$ = "LDB": B$ = "#$80": C$ = "Make it Negative": GoSub AO
                A$ = "STB": B$ = ",S": C$ = "Save Negative version": GoSub AO
                Z$ = "!":  GoSub AO:gosub AO
        End Select
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
        Return
    Case LOG_CMD
        If ArgCnt <> 1 Then
            Print "Error: LOG() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: LOG expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: LOG() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        GoSub DoLOG
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
        Return
    Case BUTTON_CMD
        ' BUTTON(#) : one numeric arg -> returns UInt8 (or UInt16 if you prefer)
        If ArgCnt <> 1 Then
            Print "Error: BUTTON() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: BUTTON expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: BUTTON() expects a numeric address";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UByte #
        NVT = NT_UByte
        GoSub ConvertLastType2NVT
        ' ------------------------------------------------------------
        ' CODEGEN: runtime stub
        ' Convention: address is at ,S (UInt16). Stub consumes it and pushes value.
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "B": C$ = "Get button number": GoSub AO
        A$ = "ANDB": B$ = "#%00000011": C$ = "Make B between zero and 3": GoSub AO
        A$ = "JSR": B$ = "BUTTON": C$ = "Go get a button and return with result in D": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Pick the type you want PEEK() to return:
        '   - NT_UByte (0..255) is typical
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case RND_CMD
        ' RND(addr) : one numeric arg -> returns UInt8 (or UInt16 if you prefer)
        If ArgCnt <> 1 Then
            Print "Error: RND() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: RND expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: RND() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Get a random number depending on the numeric type
        Select Case LastType
            Case Is < NT_Int16
                ' Get an 8 bit random number
                A$ = "PULS": B$ = "B": C$ = "Get the range of random number requested": GoSub AO
                A$ = "JSR": B$ = "RandomB": C$ = "B = RND(B) result will be a random number from 1 to B": GoSub AO
                A$ = "PSHS": B$ = "B": C$ = "Save the result of random number requested": GoSub AO
            Case NT_Int16, NT_UInt16
                ' Get a 16 bit random number
                A$ = "PULS": B$ = "D": C$ = "Get the range of random number requested": GoSub AO
                A$ = "JSR": B$ = "RandomD": C$ = "D = RND(D) result will be a random number from 1 to D": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Save the result of random number requested": GoSub AO
            Case NT_Int32, NT_UInt32
                ' Get a 32 bit random number
                A$ = "JSR": B$ = "Random32": C$ = "Get random number from 1 to value on the stack, result is on the stack": GoSub AO
            Case NT_Int64, NT_UInt64
                ' Get a 64 bit random number
                A$ = "JSR": B$ = "Random64": C$ = "Get random number from 1 to value on the stack, result is on the stack": GoSub AO
            Case NT_Single
                ' Get a FFP random number
                A$ = "LDB": B$ = "1,S": C$ = "Check for Special zero": GoSub AO
                A$ = "BNE": B$ = ">": C$ = "Do normal Random if not zero": GoSub AO
                A$ = "LEAS": B$ = "3,S": C$ = "Fix the stack": GoSub AO
                A$ = "JSR": B$ = "RandomFFP_Zero": C$ = "Get random number >0 and <1, result is on the stack": GoSub AO
                A$ = "BRA": B$ = "@Done": C$ = "Do normal Random if not zero": GoSub AO
                Z$ = "!": A$ = "JSR": B$ = "RandomFFP": C$ = "Get random number from 1 to value on the stack, result is on the stack": GoSub AO
                Z$ = "@Done": GoSub AO: GoSub AO
            Case NT_Double
                ' Get a Double random number
                A$ = "LDB": B$ = "3,S": C$ = "Check for Special zero": GoSub AO
                A$ = "BNE": B$ = ">": C$ = "Do normal Random if not zero": GoSub AO
                A$ = "LEAS": B$ = "10,S": C$ = "Fix the stack": GoSub AO
                A$ = "JSR": B$ = "RandomDB_Zero": C$ = "Get random number >0 and <1, result is on the stack": GoSub AO
                A$ = "BRA": B$ = "@Done": C$ = "Do normal Random if not zero": GoSub AO
                Z$ = "!": A$ = "JSR": B$ = "RandomDB": C$ = "Get random number from 1 to value on the stack, result is on the stack": GoSub AO
                Z$ = "@Done": GoSub AO: GoSub AO
        End Select
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Pick the type you want PEEK() to return:
        '   - NT_UByte (0..255) is typical
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
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
        NVT = NT_UInt16
        GoSub ConvertLastType2NVT
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
    Case JOYSTK_CMD
        ' JOYSTK(#) : one numeric arg -> returns UInt16
        If ArgCnt <> 1 Then
            Print "Error: JOYSTK() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: JOYSTK expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: JOYSTK() expects a numeric #";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to NT_UByte # (matches your array-index convention)
        NVT = NT_UByte
        GoSub ConvertLastType2NVT
        ' ------------------------------------------------------------
        ' CODEGEN: runtime stub
        ' Convention: address is at ,S (NT_UByte). Stub consumes it and pushes value.
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "B": C$ = "B = Joystick value to read, fix the stack": GoSub AO
        A$ = "ANDB": B$ = "#%00000011": C$ = "Make B between zero and 3": GoSub AO
        A$ = "JSR": B$ = "JOYSTK": C$ = "Go handle analog joystick reading return with result in D": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B on the stack": GoSub AO
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case POINT_CMD
        ' POINT(x,y) : one numeric arg -> returns UInt8 (or UInt16 if you prefer)
        If ArgCnt <> 2 Then
            Print "Error: POINT() expects two arguments";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg2$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: POINT expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: POINT() expects a numeric value";: GoTo FoundError
        End If
        Temp$ = Arg2$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: POINT() expects a numeric value";: GoTo FoundError
        End If

        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Save an unsigned 16 bit value on the stack
        NVT = NT_UInt16
        GoSub ConvertLastType2NVT
        GoSub VerifyX ' Add code to make sure X value is in bounds of screen size

        Temp$ = Arg2$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' Force to UInt16 address (matches your array-index convention)
        NVT = NT_UInt16
        GoSub ConvertLastType2NVT

        GoSub VerifyY ' Add code to make sure Y value is in bounds of screen size
        A$ = "TFR": B$ = "B,A": C$ = "Copy the Y co-ordinate to A": GoSub AO
        If Gmode > 99 Then
            ' Handle CoCo 3 graphic command
            If Val(GModeMaxX$(Gmode)) > 255 Then
                A$ = "PULS": B$ = "X": C$ = "Get the loction of the X co-ordinate in X": GoSub AO
                A$ = "LDY": B$ = "#POINT_" + GModeName$(Gmode): C$ = "Y points at the routine to do": GoSub AO
                A$ = "JSR": B$ = "DoCC3GraphicsBigXReturnB": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return B": GoSub AO
            Else
                A$ = "PULS": B$ = "B": C$ = "Get the loction of the X co-ordinate in B": GoSub AO
                A$ = "LDY": B$ = "#POINT_" + GModeName$(Gmode): C$ = "Y points at the routine to do": GoSub AO
                A$ = "JSR": B$ = "DoCC3GraphicsReturnB": C$ = "Prep for CoCo 3 graphics and then JSR ,Y and restore & return B": GoSub AO
            End If
        Else
            A$ = "PULS": B$ = "B": C$ = "Get the loction of the X co-ordinate in B": GoSub AO
            A$ = "JSR": B$ = "POINT_" + GModeName$(Gmode): C$ = "Get the Point on the " + GModeName$(Gmode) + " screen in B": GoSub AO
        End If
        A$ = "PSHS": B$ = "B": C$ = "Save B on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Pick the type you want to return:
        '   - NT_UByte (0..255) is typical
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return

    Case SQR_CMD
        If ArgCnt <> 1 Then
            Print "Error: SQR() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: SQR expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: SQR() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        GoSub DoSQR
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
        Return
    Case SIN_CMD
        If ArgCnt <> 1 Then
            Print "Error: SQR() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: SIN expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: SIN() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        GoSub DoSIN
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
        Return
    Case TAN_CMD
        If ArgCnt <> 1 Then
            Print "Error: TAN() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token from ProcessRPN stack
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: TAB expects numeric, not string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then
            Print "Error: TAN() expects a numeric value";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the numeric arg onto the 6809 stack
        ' (this handles literal/variable/&HFA marker)
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        ' ------------------------------------------------------------
        GoSub DoTAN
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
        ' Set the type you want to return:
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LastType)
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
        NVT = NT_Byte
        GoSub ConvertLastType2NVT
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

DoINT:
' Get the numeric value before a Close bracket
'Expression$ = Mid$(Expression$(ParseLayer), 11, Len(Expression$(ParseLayer)) - 11 - 3)
'GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case 11
        ' Handle 3 byte FFP
        A$ = "JSR": B$ = "FFP_FLOOR": C$ = "Compute floor(x) for 3 byte FFP number": GoSub AO
    Case 12
        ' Handle 10 byte Double
        A$ = "JSR": B$ = "DB_FLOOR": C$ = "Compute floor(x) for 10 byte double-precision number": GoSub AO
    Case Else
        ' The rest are already integers
End Select
Return

DoABS:
' Get the numeric value before a Close bracket
'Expression$ = Mid$(Expression$(ParseLayer), 11, Len(Expression$(ParseLayer)) - 11 - 3)
'GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case 1, 3
        ' Handle an 8 bit signed values
        A$ = "LDB": B$ = ",S": C$ = "Get the Sign of the number": GoSub AO
        A$ = "BPL": B$ = ">": C$ = "If positive simply skip over changing B's value": GoSub AO
        A$ = "LDB": B$ = "#$00": C$ = "B=0": GoSub AO
        A$ = "SUBB": B$ = ",S": C$ = "B=0-B, fix the stack": GoSub AO
        A$ = "STB": B$ = ",S": C$ = "Set Flags, Save new 8 bit right side value": GoSub AO
        Z$ = "!": GoSub AO
    Case 5
        ' Handle a 16 signed bit value
        A$ = "LDD": B$ = ",S": C$ = "Get the Sign of the number": GoSub AO
        A$ = "BPL": B$ = ">": C$ = "If positive simply skip over changing D's value": GoSub AO
        A$ = "LDD": B$ = "#$0000": C$ = "D=0": GoSub AO
        A$ = "SUBD": B$ = ",S": C$ = "D=0-D, fix the stack": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Set Flags, Save new 16 bit right side value": GoSub AO
        Z$ = "!": GoSub AO
    Case 7
        ' Handle 32 bit signed value
        A$ = "LDB": B$ = ",S": C$ = "Get the Sign of the number": GoSub AO
        A$ = "BPL": B$ = ">": C$ = "If positive simply skip ahead": GoSub AO
        A$ = "LEAX": B$ = ",S": C$ = "X points at the location in RAM where the number is stored (currently on the stack)": GoSub AO
        A$ = "JSR": B$ = "Negate_32": C$ = "Negate 32 bit value at X": GoSub AO
        Z$ = "!": GoSub AO
    Case 9
        ' Handle 64 bit signed value
        A$ = "LDB": B$ = ",S": C$ = "Get the Sign of the number": GoSub AO
        A$ = "BPL": B$ = ">": C$ = "If positive simply skip ahead": GoSub AO
        A$ = "LEAX": B$ = ",S": C$ = "X points at the location in RAM where the number is stored (currently on the stack)": GoSub AO
        A$ = "JSR": B$ = "Negate_64": C$ = "Negate 64 bit value at X": GoSub AO
        Z$ = "!": GoSub AO
    Case 11
        ' Handle FFP
        A$ = "LDB": B$ = ",S": C$ = "Get the Sign of the FFP number": GoSub AO
        A$ = "ANDB": B$ = "#$7F": C$ = "clear the sign bit": GoSub AO
        A$ = "STB": B$ = ",S": C$ = "store it back": GoSub AO
    Case 12
        ' Handle 10 byte Double
        A$ = "CLR": B$ = ",S": C$ = "store it back": GoSub AO
    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select
Return

DoSQR:
' Get the numeric value before a Close bracket
'Expression$ = Mid$(Expression$(ParseLayer), 11, Len(Expression$(ParseLayer)) - 11 - 3)
'GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case 1 To 10
        ' Convert int numbers to FFP & do SQR, then convert the result back to LastType
        OrigLastType = LastType
        NVT = NT_Single 'Convert to FFP
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = NT_Single
        A$ = "JSR": B$ = "FFP_SQRT": C$ = "Compute the Square Root of the FFP # @ ,S save result @ ,S": GoSub AO
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        A$ = "JSR": B$ = "FFP_SQRT": C$ = "Compute the Square Root of the FFP # @ ,S save result @ ,S": GoSub AO
    Case 12
        ' Handle Double
        A$ = "JSR": B$ = "DB_SQRT": C$ = "Compute the Square Root of the Double # @ ,S save result @ ,S": GoSub AO
    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select
Return

DoSIN:
' Get the numeric value before a Close bracket
'Expression$ = Mid$(Expression$(ParseLayer), 11, Len(Expression$(ParseLayer)) - 11 - 3)
'GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case 1 To 10
        ' Convert int numbers to FFP & do SIN, then convert the result back to LastType
        OrigLastType = LastType
        NVT = NT_Single 'Convert to FFP
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = NT_Single
        A$ = "JSR": B$ = "FFP_SIN": C$ = "Compute the Sine of the FFP # @ ,S save result @ ,S": GoSub AO
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        A$ = "JSR": B$ = "FFP_SIN": C$ = "Compute the Sine of the FFP # @ ,S save result @ ,S": GoSub AO
    Case 12
        ' Handle Double
        A$ = "JSR": B$ = "DB_SIN": C$ = "Compute the Sine of the Double # @ ,S save result @ ,S": GoSub AO
    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select
Return

DoCOS:
' Get the numeric value before a Close bracket
'Expression$ = Mid$(Expression$(ParseLayer), 11, Len(Expression$(ParseLayer)) - 11 - 3)
'GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case 1 To 10
        ' Convert int numbers to FFP & do COS, then convert the result back to LastType
        OrigLastType = LastType
        NVT = NT_Single 'Convert to FFP
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = NT_Single
        A$ = "JSR": B$ = "FFP_COS": C$ = "Compute the Cosine of the FFP # @ ,S save result @ ,S": GoSub AO
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        A$ = "JSR": B$ = "FFP_COS": C$ = "Compute the Cosine of the FFP # @ ,S save result @ ,S": GoSub AO
    Case 12
        ' Handle Double
        A$ = "JSR": B$ = "DB_COS": C$ = "Compute the Cosine of the Double # @ ,S save result @ ,S": GoSub AO
    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select
Return

DoTAN:
' Get the numeric value before a Close bracket
'Expression$ = Mid$(Expression$(ParseLayer), 11, Len(Expression$(ParseLayer)) - 11 - 3)
'GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case 1 To 10
        ' Convert int numbers to FFP & do TAN, then convert the result back to LastType
        OrigLastType = LastType
        NVT = NT_Single 'Convert to FFP
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = NT_Single
        A$ = "JSR": B$ = "FFP_TAN": C$ = "Compute the Tangent of the FFP # @ ,S save result @ ,S": GoSub AO
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        A$ = "JSR": B$ = "FFP_TAN": C$ = "Compute the Tangent of the FFP # @ ,S save result @ ,S": GoSub AO
    Case 12
        ' Handle Double
        A$ = "JSR": B$ = "DB_TAN": C$ = "Compute the Tangent of the Double # @ ,S save result @ ,S": GoSub AO
    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select
Return

DoATN:
' Get the numeric value before a Close bracket
'Expression$ = Mid$(Expression$(ParseLayer), 11, Len(Expression$(ParseLayer)) - 11 - 3)
'GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case 1 To 10
        ' Convert int numbers to FFP & do ATAN, then convert the result back to LastType
        OrigLastType = LastType
        NVT = NT_Single 'Convert to FFP
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = NT_Single
        A$ = "JSR": B$ = "FFP_ATAN": C$ = "Compute the ArcTangent of the FFP # @ ,S save result @ ,S": GoSub AO
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        A$ = "JSR": B$ = "FFP_ATAN": C$ = "Compute the ArcTangent of the FFP # @ ,S save result @ ,S": GoSub AO
    Case 12
        ' Handle Double
        A$ = "JSR": B$ = "DB_ATAN": C$ = "Compute the ArcTangent of the Double # @ ,S save result @ ,S": GoSub AO
    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select
Return

DoEXP:
' Get the numeric value before a Close bracket
'Expression$ = Mid$(Expression$(ParseLayer), 11, Len(Expression$(ParseLayer)) - 11 - 3)
'GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case 1 To 10
        ' Convert int numbers to FFP & do EXP, then convert the result back to LastType
        OrigLastType = LastType
        NVT = NT_Single 'Convert to FFP
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = NT_Single
        A$ = "JSR": B$ = "FFP_EXP": C$ = "Compute the Exponential number of the FFP # @ ,S save result @ ,S": GoSub AO
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        A$ = "JSR": B$ = "FFP_EXP": C$ = "Compute the Exponential number of the FFP # @ ,S save result @ ,S": GoSub AO
    Case 12
        ' Handle Double
        A$ = "JSR": B$ = "DB_EXP": C$ = "Compute the Exponential number of the Double # @ ,S save result @ ,S": GoSub AO
    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select
Return

DoLOG:
' Get the numeric value before a Close bracket
' Expression$ = Mid$(Expression$(ParseLayer), 11, Len(Expression$(ParseLayer)) - 11 - 3)
' GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case 1 To 10
        ' Convert int numbers to FFP & do LOG, then convert the result back to LastType
        OrigLastType = LastType
        NVT = NT_Single 'Convert to FFP
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = NT_Single
        A$ = "JSR": B$ = "FFP_LOG": C$ = "Compute the Logarithm number of the FFP # @ ,S save result @ ,S": GoSub AO
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        A$ = "JSR": B$ = "FFP_LOG": C$ = "Compute the Logarithm number of the FFP # @ ,S save result @ ,S": GoSub AO
    Case 12
        ' Handle Double
        A$ = "JSR": B$ = "DB_LOG": C$ = "Compute the Logarithm number of the Double # @ ,S save result @ ,S": GoSub AO
    Case Else
        ' Add code to handle sizes larger
        Z$ = "***Type is too large***": GoSub AO
End Select
Return

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
A$ = "CMPB": B$ = "#" + GModeMaxY$(Gmode): C$ = "Check if B is > than " + GModeMaxY$(Gmode): GoSub AO
A$ = "BLS": B$ = "@SaveB1": C$ = "If value is " + GModeMaxY$(Gmode) + " or < then skip ahead": GoSub AO
A$ = "LDB": B$ = "#" + GModeMaxY$(Gmode): C$ = "Make the max size " + GModeMaxY$(Gmode): GoSub AO
Z$ = "@SaveB1:": GoSub AO: GoSub AO
Return
