
' This will pull values off the ProcessRPNStack$(ProcessRPNStackPointer) and lower ProcessRPNStackPointer for each pull off the stack
DoNumericCommand:
' i$ is the current RPN token
cmd16 = Asc(Mid$(i$, 2, 1)) * 256 + Asc(Mid$(i$, 3, 1))
ArgCnt = 1
If Len(i$) >= 4 Then ArgCnt = Asc(Mid$(i$, 4, 1))
Select Case cmd16
    Case FNINIT_CMD
        ' FNINIT() : zero-argument function returning a FujiNet status byte.
        If Len(i$) < 4 Then Print "Error: FNINIT must be used as FNINIT()";: GoTo FoundError
        If ArgCnt <> 0 Then Print "Error: FNINIT() expects 0 arguments";: GoTo FoundError
        A$ = "JSR": B$ = "FN_Init": C$ = "Initialize FujiNet; A=0 on success or an error code": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push the FujiNet initialization status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNERROR_CMD
        If Len(i$) < 4 Then Print "Error: FNERROR must be used as FNERROR()";: GoTo FoundError
        If ArgCnt <> 0 Then Print "Error: FNERROR() expects 0 arguments";: GoTo FoundError
        A$ = "JSR": B$ = "FN_Error": C$ = "Return the last FujiNet library error": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push the FujiNet error code": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNWIFISTATUS_CMD
        If Len(i$) < 4 Then Print "Error: FNWIFISTATUS must be used as FNWIFISTATUS()";: GoTo FoundError
        If ArgCnt <> 0 Then Print "Error: FNWIFISTATUS() expects 0 arguments";: GoTo FoundError
        A$ = "JSR": B$ = "FN_WifiStatus": C$ = "Return FujiNet Wi-Fi status; 3=connected, 6=disconnected": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push the FujiNet Wi-Fi status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNOPEN_CMD
        If ArgCnt <> 4 Then Print "Error: FNOPEN() expects channel, device string, access mode, and translation mode";: GoTo FoundError

        ' RPN arguments are removed from right to left.
        TranslationTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        AccessTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        DeviceTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1

        Temp$ = TranslationTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNOPEN() translation mode must be numeric";: GoTo FoundError
        Temp$ = AccessTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNOPEN() access mode must be numeric";: GoTo FoundError
        Temp$ = DeviceTok$: GoSub IsStringToken
        If IsStrFlag% = 0 Then Print "Error: FNOPEN() device specification must be a string";: GoTo FoundError
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNOPEN() channel must be numeric";: GoTo FoundError

        ' Consume values in reverse runtime-stack order so nested expressions work.
        Temp$ = TranslationTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNOPEN translation mode": GoSub AO
        A$ = "STB": B$ = "FN_OpenTranslation": C$ = "Save FNOPEN translation mode": GoSub AO

        Temp$ = AccessTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNOPEN access mode": GoSub AO
        A$ = "STB": B$ = "FN_OpenAccess": C$ = "Save FNOPEN access mode": GoSub AO

        Temp$ = DeviceTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy FNOPEN device specification into compiler scratch string": GoSub AO

        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNOPEN network channel": GoSub AO
        A$ = "STB": B$ = "FN_OpenChannel": C$ = "Save FNOPEN network channel": GoSub AO

        A$ = "JSR": B$ = "FN_Open": C$ = "Open the FujiNet network channel": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNOPEN result; zero means success": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNCLOSE_CMD
        If Len(i$) < 4 Then Print "Error: FNCLOSE must be used as FNCLOSE(channel)";: GoTo FoundError
        If ArgCnt <> 1 Then Print "Error: FNCLOSE() expects one channel argument";: GoTo FoundError

        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNCLOSE() channel must be numeric";: GoTo FoundError

        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNCLOSE network channel": GoSub AO
        A$ = "JSR": B$ = "FN_Close": C$ = "Close the FujiNet network channel": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNCLOSE result; zero means success": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNBYTESWAITING_CMD
        If Len(i$) < 4 Then Print "Error: FNBYTESWAITING must be used as FNBYTESWAITING(channel)";: GoTo FoundError
        If ArgCnt <> 1 Then Print "Error: FNBYTESWAITING() expects one channel argument";: GoTo FoundError

        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNBYTESWAITING() channel must be numeric";: GoTo FoundError

        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNBYTESWAITING network channel": GoSub AO
        A$ = "JSR": B$ = "FN_BytesWaiting": C$ = "Return available bytes in D": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Push FNBYTESWAITING result": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
        Return
    Case FNCHANNELERROR_CMD
        If Len(i$) < 4 Then Print "Error: FNCHANNELERROR must be used as FNCHANNELERROR(channel)";: GoTo FoundError
        If ArgCnt <> 1 Then Print "Error: FNCHANNELERROR() expects one channel argument";: GoTo FoundError

        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNCHANNELERROR() channel must be numeric";: GoTo FoundError

        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNCHANNELERROR network channel": GoSub AO
        A$ = "JSR": B$ = "FN_ChannelError": C$ = "Return zero or the channel's FujiNet error": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNCHANNELERROR result": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNCONNECTED_CMD
        If Len(i$) < 4 Then Print "Error: FNCONNECTED must be used as FNCONNECTED(channel)";: GoTo FoundError
        If ArgCnt <> 1 Then Print "Error: FNCONNECTED() expects one channel argument";: GoTo FoundError

        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNCONNECTED() channel must be numeric";: GoTo FoundError

        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNCONNECTED network channel": GoSub AO
        A$ = "JSR": B$ = "FN_Connected": C$ = "Return the channel's connected flag": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNCONNECTED result": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNWRITE_CMD
        If ArgCnt <> 2 Then Print "Error: FNWRITE() expects channel and data string";: GoTo FoundError

        DataTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1

        Temp$ = DataTok$: GoSub IsStringToken
        If IsStrFlag% = 0 Then Print "Error: FNWRITE() data must be a string";: GoTo FoundError
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNWRITE() channel must be numeric";: GoTo FoundError

        Temp$ = DataTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy FNWRITE data into compiler scratch string": GoSub AO

        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNWRITE network channel": GoSub AO
        A$ = "JSR": B$ = "FN_Write": C$ = "Write string to the FujiNet network channel": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNWRITE result; zero means success": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNJSONPARSE_CMD
        If Len(i$) < 4 Then Print "Error: FNJSONPARSE must be used as FNJSONPARSE(channel)";: GoTo FoundError
        If ArgCnt <> 1 Then Print "Error: FNJSONPARSE() expects one channel argument";: GoTo FoundError

        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNJSONPARSE() channel must be numeric";: GoTo FoundError

        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNJSONPARSE network channel": GoSub AO
        A$ = "JSR": B$ = "FN_JSONParse": C$ = "Parse the open response as JSON inside FujiNet": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNJSONPARSE result; zero means success": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNHTTPMODE_CMD
        If ArgCnt <> 2 Then Print "Error: FNHTTPMODE() expects channel and mode";: GoTo FoundError
        ModeTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = ModeTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNHTTPMODE() mode must be numeric";: GoTo FoundError
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNHTTPMODE() channel must be numeric";: GoTo FoundError

        Temp$ = ModeTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNHTTPMODE mode": GoSub AO
        A$ = "STB": B$ = "FN_ChannelModeValue": C$ = "Save FujiNet channel mode": GoSub AO
        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FNHTTPMODE channel": GoSub AO
        A$ = "LDA": B$ = "FN_ChannelModeValue": C$ = "Get FujiNet channel mode": GoSub AO
        A$ = "JSR": B$ = "FN_SetChannelMode": C$ = "Set FujiNet channel mode": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNHTTPMODE status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNHTTPHEADER_CMD, FNHTTPPOST_CMD, FNHTTPPUT_CMD
        If ArgCnt <> 2 Then Print "Error: HTTP header/body function expects channel and string data";: GoTo FoundError
        DataTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = DataTok$: GoSub IsStringToken
        If IsStrFlag% = 0 Then Print "Error: HTTP header/body data must be a string";: GoTo FoundError
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: HTTP channel must be numeric";: GoTo FoundError

        Temp$ = DataTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy HTTP text into compiler scratch string": GoSub AO
        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get HTTP network channel": GoSub AO
        If cmd16 = FNHTTPHEADER_CMD Then HTTPEntry$ = "FN_HTTPHeader"
        If cmd16 = FNHTTPPOST_CMD Then HTTPEntry$ = "FN_HTTPPost"
        If cmd16 = FNHTTPPUT_CMD Then HTTPEntry$ = "FN_HTTPPut"
        A$ = "JSR": B$ = HTTPEntry$: C$ = "Send FujiNet HTTP header or request body": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push HTTP operation status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNHTTPDELETE_CMD
        If ArgCnt <> 3 Then Print "Error: FNHTTPDELETE() expects channel, URL string, and translation mode";: GoTo FoundError
        TranslationTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        DeviceTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = TranslationTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNHTTPDELETE() translation mode must be numeric";: GoTo FoundError
        Temp$ = DeviceTok$: GoSub IsStringToken
        If IsStrFlag% = 0 Then Print "Error: FNHTTPDELETE() URL must be a string";: GoTo FoundError
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNHTTPDELETE() channel must be numeric";: GoTo FoundError

        Temp$ = TranslationTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get DELETE translation mode": GoSub AO
        A$ = "STB": B$ = "FN_HTTPDeleteTranslation": C$ = "Save DELETE translation mode": GoSub AO
        Temp$ = DeviceTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy DELETE URL into compiler scratch string": GoSub AO
        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get DELETE network channel": GoSub AO
        A$ = "STB": B$ = "FN_HTTPDeleteChannel": C$ = "Save DELETE network channel": GoSub AO
        A$ = "JSR": B$ = "FN_HTTPDelete": C$ = "Open and execute the HTTP DELETE": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNHTTPDELETE status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNREADMEM_CMD, FNWRITEMEM_CMD
        If ArgCnt <> 3 Then Print "Error: memory transfer expects channel, address, and count";: GoTo FoundError
        CountTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        AddressTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = CountTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: memory transfer count must be numeric";: GoTo FoundError
        Temp$ = AddressTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: memory transfer address must be numeric";: GoTo FoundError
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: memory transfer channel must be numeric";: GoTo FoundError

        Temp$ = CountTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UInt16: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "D": C$ = "Get binary transfer count": GoSub AO
        A$ = "STD": B$ = "FN_MemoryCount": C$ = "Save binary transfer count": GoSub AO
        Temp$ = AddressTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UInt16: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "D": C$ = "Get binary transfer address": GoSub AO
        A$ = "STD": B$ = "FN_MemoryAddress": C$ = "Save binary transfer address": GoSub AO
        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get binary transfer channel": GoSub AO
        A$ = "STB": B$ = "FN_MemoryChannel": C$ = "Save binary transfer channel": GoSub AO
        If cmd16 = FNREADMEM_CMD Then
            A$ = "JSR": B$ = "FN_ReadMemory": C$ = "Read available channel bytes directly into memory": GoSub AO
            A$ = "PSHS": B$ = "D": C$ = "Push actual FNREADMEM byte count": GoSub AO
            ResultType = NT_UInt16
        Else
            A$ = "JSR": B$ = "FN_WriteMemory": C$ = "Write memory directly to the network channel": GoSub AO
            A$ = "PSHS": B$ = "A": C$ = "Push FNWRITEMEM status": GoSub AO
            ResultType = NT_UByte
        End If
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(ResultType)
        Return
    Case FNDELETE_CMD, FNRENAME_CMD, FNLOCK_CMD, FNUNLOCK_CMD, FNMKDIR_CMD, FNRMDIR_CMD, FNCHDIR_CMD, FNUSERNAME_CMD, FNPASSWORD_CMD
        If ArgCnt <> 2 Then Print "Error: FujiNet network control function expects channel and specification string";: GoTo FoundError
        DeviceTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = DeviceTok$: GoSub IsStringToken
        If IsStrFlag% = 0 Then Print "Error: FujiNet network specification must be a string";: GoTo FoundError
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FujiNet network channel must be numeric";: GoTo FoundError

        Temp$ = DeviceTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy network specification into compiler scratch string": GoSub AO
        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get network control channel": GoSub AO
        A$ = "STB": B$ = "FN_IOChannel": C$ = "Save network control channel": GoSub AO
        If cmd16 = FNDELETE_CMD Then FujiCommand$ = "FN_NC_CMD_DELETE"
        If cmd16 = FNRENAME_CMD Then FujiCommand$ = "FN_NC_CMD_RENAME"
        If cmd16 = FNLOCK_CMD Then FujiCommand$ = "FN_NC_CMD_LOCK"
        If cmd16 = FNUNLOCK_CMD Then FujiCommand$ = "FN_NC_CMD_UNLOCK"
        If cmd16 = FNMKDIR_CMD Then FujiCommand$ = "FN_NC_CMD_MKDIR"
        If cmd16 = FNRMDIR_CMD Then FujiCommand$ = "FN_NC_CMD_RMDIR"
        If cmd16 = FNCHDIR_CMD Then FujiCommand$ = "FN_NC_CMD_CHDIR"
        If cmd16 = FNUSERNAME_CMD Then FujiCommand$ = "FN_NC_CMD_USERNAME"
        If cmd16 = FNPASSWORD_CMD Then FujiCommand$ = "FN_NC_CMD_PASSWORD"
        A$ = "LDA": B$ = "#" + FujiCommand$: C$ = "Select FujiNet network control operation": GoSub AO
        A$ = "STA": B$ = "FN_IOCommand": C$ = "Save network control operation": GoSub AO
        A$ = "CLR": B$ = "FN_IOAux1": C$ = "Clear network control aux1": GoSub AO
        A$ = "CLR": B$ = "FN_IOAux2": C$ = "Clear network control aux2": GoSub AO
        A$ = "JSR": B$ = "FN_NetworkIOCtl": C$ = "Perform FujiNet network control operation": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push network control status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNDIROPEN_CMD
        If ArgCnt <> 3 Then Print "Error: FNDIROPEN() expects channel, directory specification, and format";: GoTo FoundError
        FormatTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        DeviceTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ChannelTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = FormatTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNDIROPEN() format must be numeric";: GoTo FoundError
        Temp$ = DeviceTok$: GoSub IsStringToken
        If IsStrFlag% = 0 Then Print "Error: FNDIROPEN() directory specification must be a string";: GoTo FoundError
        Temp$ = ChannelTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FNDIROPEN() channel must be numeric";: GoTo FoundError

        Temp$ = FormatTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get directory response format": GoSub AO
        A$ = "STB": B$ = "FN_OpenTranslation": C$ = "Save directory response format": GoSub AO
        Temp$ = DeviceTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy directory specification into compiler scratch string": GoSub AO
        Temp$ = ChannelTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get directory channel": GoSub AO
        A$ = "STB": B$ = "FN_OpenChannel": C$ = "Save directory channel": GoSub AO
        A$ = "LDA": B$ = "#6": C$ = "Select FujiNet directory-open access": GoSub AO
        A$ = "STA": B$ = "FN_OpenAccess": C$ = "Save directory-open access": GoSub AO
        A$ = "JSR": B$ = "FN_Open": C$ = "Open FujiNet directory stream": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNDIROPEN status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNWIFIENABLED_CMD, FNWIFISCAN_CMD, FNMOUNTALL_CMD, FNCLOSEDIR_CMD, FNDIRPOS_CMD
        If Len(i$) < 4 Or ArgCnt <> 0 Then Print "Error: this FujiNet function expects empty parentheses";: GoTo FoundError
        If cmd16 = FNWIFIENABLED_CMD Then
            A$ = "JSR": B$ = "FN_WifiEnabled": C$ = "Return whether the FujiNet Wi-Fi adapter is enabled": GoSub AO
            A$ = "PSHS": B$ = "A": C$ = "Push FNWIFIENABLED result": GoSub AO
            ResultType = NT_UByte
        ElseIf cmd16 = FNWIFISCAN_CMD Then
            A$ = "JSR": B$ = "FN_WifiScan": C$ = "Scan Wi-Fi and return the result count": GoSub AO
            A$ = "PSHS": B$ = "A": C$ = "Push FNWIFISCAN result": GoSub AO
            ResultType = NT_UByte
        ElseIf cmd16 = FNMOUNTALL_CMD Then
            A$ = "JSR": B$ = "FN_MountAll": C$ = "Mount every configured FujiNet disk": GoSub AO
            A$ = "PSHS": B$ = "A": C$ = "Push FNMOUNTALL status": GoSub AO
            ResultType = NT_UByte
        ElseIf cmd16 = FNCLOSEDIR_CMD Then
            A$ = "JSR": B$ = "FN_CloseDirectory": C$ = "Close the active FujiNet directory": GoSub AO
            A$ = "PSHS": B$ = "A": C$ = "Push FNCLOSEDIR status": GoSub AO
            ResultType = NT_UByte
        Else
            A$ = "JSR": B$ = "FN_GetDirectoryPosition": C$ = "Return the active FujiNet directory position": GoSub AO
            A$ = "PSHS": B$ = "D": C$ = "Push FNDIRPOS result": GoSub AO
            ResultType = NT_UInt16
        End If
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(ResultType)
        Return
    Case FNWIFIRSSI_CMD, FNMOUNTHOST_CMD, FNUNMOUNTHOST_CMD, FNDEVICEHOST_CMD, FNDEVICEMODE_CMD, FNUNMOUNTIMAGE_CMD, FNSETDIRPOS_CMD
        If ArgCnt <> 1 Then Print "Error: this FujiNet function expects one numeric argument";: GoTo FoundError
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: this FujiNet argument must be numeric";: GoTo FoundError
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        If cmd16 = FNSETDIRPOS_CMD Then
            LastType = PushedType: NVT = NT_UInt16: GoSub ConvertLastType2NVT
            A$ = "PULS": B$ = "D": C$ = "Get FujiNet directory position": GoSub AO
            A$ = "JSR": B$ = "FN_SetDirectoryPosition": C$ = "Set active directory position": GoSub AO
            A$ = "PSHS": B$ = "A": C$ = "Push FNSETDIRPOS status": GoSub AO
            ResultType = NT_UByte
        Else
            LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
            A$ = "PULS": B$ = "B": C$ = "Get FujiNet slot or scan index": GoSub AO
            If cmd16 = FNWIFIRSSI_CMD Then
                A$ = "JSR": B$ = "FN_WifiScanRSSI": C$ = "Return signed scan-result RSSI": GoSub AO
                A$ = "PSHS": B$ = "D": C$ = "Push FNWIFIRSSI result": GoSub AO
                ResultType = NT_Int16
            ElseIf cmd16 = FNDEVICEHOST_CMD Or cmd16 = FNDEVICEMODE_CMD Then
                If cmd16 = FNDEVICEHOST_CMD Then FieldValue$ = "0" Else FieldValue$ = "1"
                A$ = "LDA": B$ = "#" + FieldValue$: C$ = "Select device-slot field": GoSub AO
                A$ = "STA": B$ = "FN_MountField": C$ = "Save device-slot field": GoSub AO
                A$ = "JSR": B$ = "FN_DeviceSlotField": C$ = "Read FujiNet device-slot field": GoSub AO
                A$ = "PSHS": B$ = "A": C$ = "Push device-slot field": GoSub AO
                ResultType = NT_UByte
            Else
                If cmd16 = FNMOUNTHOST_CMD Then FujiCommand$ = "FN_MOUNT_CMD_MOUNT_HOST"
                If cmd16 = FNUNMOUNTHOST_CMD Then FujiCommand$ = "FN_MOUNT_CMD_UNMOUNT_HOST"
                If cmd16 = FNUNMOUNTIMAGE_CMD Then FujiCommand$ = "FN_MOUNT_CMD_UNMOUNT_IMAGE"
                A$ = "LDA": B$ = "#" + FujiCommand$: C$ = "Select FujiNet mount operation": GoSub AO
                A$ = "JSR": B$ = "FN_MountOneParameter": C$ = "Run one-slot mount operation": GoSub AO
                A$ = "PSHS": B$ = "A": C$ = "Push mount-operation status": GoSub AO
                ResultType = NT_UByte
            End If
        End If
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(ResultType)
        Return
    Case FNSETWIFI_CMD
        If ArgCnt <> 2 Then Print "Error: FNSETWIFI() expects SSID and password strings";: GoTo FoundError
        PasswordTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        SSIDTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = PasswordTok$: GoSub IsStringToken
        If IsStrFlag% = 0 Then Print "Error: FNSETWIFI() password must be a string";: GoTo FoundError
        Temp$ = SSIDTok$: GoSub IsStringToken
        If IsStrFlag% = 0 Then Print "Error: FNSETWIFI() SSID must be a string";: GoTo FoundError
        Temp$ = PasswordTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackStringPF01": C$ = "Copy Wi-Fi password to PF01": GoSub AO
        Temp$ = SSIDTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy Wi-Fi SSID to PF00": GoSub AO
        A$ = "JSR": B$ = "FN_SetWifi": C$ = "Configure FujiNet Wi-Fi credentials": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNSETWIFI status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNSETHOST_CMD, FNSETHOSTPREFIX_CMD
        If ArgCnt <> 2 Then Print "Error: this FujiNet function expects slot and string";: GoTo FoundError
        TextTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        SlotTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = TextTok$: GoSub IsStringToken
        If IsStrFlag% = 0 Then Print "Error: FujiNet host text must be a string";: GoTo FoundError
        Temp$ = SlotTok$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: FujiNet host slot must be numeric";: GoTo FoundError
        Temp$ = TextTok$: GoSub PushOneStringTokenOnStack
        If cmd16 = FNSETHOST_CMD Then
            A$ = "JSR": B$ = "FN_CopyStackStringPF01": C$ = "Copy hostname to PF01": GoSub AO
        Else
            A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy host prefix to PF00": GoSub AO
        End If
        Temp$ = SlotTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get FujiNet host slot": GoSub AO
        If cmd16 = FNSETHOST_CMD Then
            A$ = "JSR": B$ = "FN_SetHostSlot": C$ = "Set FujiNet hostname": GoSub AO
        Else
            A$ = "JSR": B$ = "FN_SetHostPrefix": C$ = "Set FujiNet host prefix": GoSub AO
        End If
        A$ = "PSHS": B$ = "A": C$ = "Push host-setting status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNMOUNTIMAGE_CMD
        If ArgCnt <> 2 Then Print "Error: FNMOUNTIMAGE() expects device and mode";: GoTo FoundError
        ModeTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        DeviceTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = ModeTok$: GoSub IsStringToken: If IsStrFlag% Then Print "Error: FNMOUNTIMAGE() mode must be numeric";: GoTo FoundError
        Temp$ = DeviceTok$: GoSub IsStringToken: If IsStrFlag% Then Print "Error: FNMOUNTIMAGE() device must be numeric";: GoTo FoundError
        Temp$ = ModeTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get mount mode (1=read, 2=write)": GoSub AO
        A$ = "STB": B$ = "FN_MountMode": C$ = "Save mount mode": GoSub AO
        Temp$ = DeviceTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get device slot": GoSub AO
        A$ = "STB": B$ = "FN_MountSlot": C$ = "Save device slot": GoSub AO
        A$ = "JSR": B$ = "FN_MountDisk": C$ = "Mount configured disk image": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNMOUNTIMAGE status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNSETDEVICE_CMD
        If ArgCnt <> 4 Then Print "Error: FNSETDEVICE() expects device, host, mode, and path$";: GoTo FoundError
        PathTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ModeTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        HostTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        DeviceTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = PathTok$: GoSub IsStringToken: If IsStrFlag% = 0 Then Print "Error: FNSETDEVICE() path must be a string";: GoTo FoundError
        Temp$ = ModeTok$: GoSub IsStringToken: If IsStrFlag% Then Print "Error: FNSETDEVICE() mode must be numeric";: GoTo FoundError
        Temp$ = HostTok$: GoSub IsStringToken: If IsStrFlag% Then Print "Error: FNSETDEVICE() host must be numeric";: GoTo FoundError
        Temp$ = DeviceTok$: GoSub IsStringToken: If IsStrFlag% Then Print "Error: FNSETDEVICE() device must be numeric";: GoTo FoundError
        Temp$ = PathTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy device path to PF00": GoSub AO
        Temp$ = ModeTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get device mode": GoSub AO
        A$ = "STB": B$ = "FN_MountMode": C$ = "Save device mode": GoSub AO
        Temp$ = HostTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get host slot": GoSub AO
        A$ = "STB": B$ = "FN_MountHost": C$ = "Save host slot": GoSub AO
        Temp$ = DeviceTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get device slot": GoSub AO
        A$ = "STB": B$ = "FN_MountSlot": C$ = "Save device slot": GoSub AO
        A$ = "JSR": B$ = "FN_SetDeviceFile": C$ = "Configure FujiNet disk slot": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNSETDEVICE status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNOPENDIR_CMD
        If ArgCnt <> 3 Then Print "Error: FNOPENDIR() expects host, path$, and filter$";: GoTo FoundError
        FilterTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        PathTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        HostTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = FilterTok$: GoSub IsStringToken: If IsStrFlag% = 0 Then Print "Error: FNOPENDIR() filter must be a string";: GoTo FoundError
        Temp$ = PathTok$: GoSub IsStringToken: If IsStrFlag% = 0 Then Print "Error: FNOPENDIR() path must be a string";: GoTo FoundError
        Temp$ = HostTok$: GoSub IsStringToken: If IsStrFlag% Then Print "Error: FNOPENDIR() host must be numeric";: GoTo FoundError
        Temp$ = FilterTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackStringPF01": C$ = "Copy directory filter to PF01": GoSub AO
        Temp$ = PathTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy directory path to PF00": GoSub AO
        Temp$ = HostTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get directory host slot": GoSub AO
        A$ = "JSR": B$ = "FN_OpenDirectory": C$ = "Open FujiNet host directory": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNOPENDIR status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNAPPKEYSET_CMD
        If ArgCnt <> 2 Then Print "Error: FNAPPKEYSET() expects creator ID and application ID";: GoTo FoundError
        AppTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        CreatorTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = AppTok$: GoSub IsStringToken: If IsStrFlag% Then Print "Error: FNAPPKEYSET() application ID must be numeric";: GoTo FoundError
        Temp$ = CreatorTok$: GoSub IsStringToken: If IsStrFlag% Then Print "Error: FNAPPKEYSET() creator ID must be numeric";: GoTo FoundError
        Temp$ = CreatorTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UInt16: GoSub ConvertLastType2NVT
        Temp$ = AppTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get AppKey application ID": GoSub AO
        A$ = "STB": B$ = "FN_AppKeyApp": C$ = "Save AppKey application ID": GoSub AO
        A$ = "PULS": B$ = "D": C$ = "Get AppKey creator ID": GoSub AO
        A$ = "JSR": B$ = "FN_AppKeySet": C$ = "Set AppKey creator/application IDs": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNAPPKEYSET status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNAPPKEYWRITE_CMD
        If ArgCnt <> 2 Then Print "Error: FNAPPKEYWRITE() expects key ID and data string";: GoTo FoundError
        DataTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        KeyTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = DataTok$: GoSub IsStringToken: If IsStrFlag% = 0 Then Print "Error: FNAPPKEYWRITE() data must be a string";: GoTo FoundError
        Temp$ = KeyTok$: GoSub IsStringToken: If IsStrFlag% Then Print "Error: FNAPPKEYWRITE() key ID must be numeric";: GoTo FoundError
        Temp$ = KeyTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        Temp$ = DataTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy AppKey data to PF00": GoSub AO
        A$ = "PULS": B$ = "B": C$ = "Get AppKey key ID": GoSub AO
        A$ = "JSR": B$ = "FN_AppKeyWrite": C$ = "Write the persistent FujiNet AppKey": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNAPPKEYWRITE status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNAPPKEYCLOSE_CMD, FNHASHCLEAR_CMD
        If Len(i$) < 4 Or ArgCnt <> 0 Then Print "Error: this FujiNet function expects empty parentheses";: GoTo FoundError
        If cmd16 = FNAPPKEYCLOSE_CMD Then
            A$ = "JSR": B$ = "FN_AppKeyClose": C$ = "Close the current AppKey context": GoSub AO
        Else
            A$ = "JSR": B$ = "FN_HashClear": C$ = "Clear FujiNet's accumulated hash data": GoSub AO
        End If
        A$ = "PSHS": B$ = "A": C$ = "Push FujiNet data-service status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FNHASHADD_CMD
        If ArgCnt <> 1 Then Print "Error: FNHASHADD() expects one data string";: GoTo FoundError
        DataTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = DataTok$: GoSub IsStringToken: If IsStrFlag% = 0 Then Print "Error: FNHASHADD() data must be a string";: GoTo FoundError
        Temp$ = DataTok$: GoSub PushOneStringTokenOnStack
        A$ = "JSR": B$ = "FN_CopyStackString": C$ = "Copy hash input to PF00": GoSub AO
        A$ = "JSR": B$ = "FN_HashAdd": C$ = "Add data to FujiNet's hash accumulator": GoSub AO
        A$ = "PSHS": B$ = "A": C$ = "Push FNHASHADD status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case LOF_CMD, SDC_LOF_CMD
        If ArgCnt <> 1 Then Print "Error: LOF()/SDC_LOF() expects one file number";: GoTo FoundError
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: LOF()/SDC_LOF() expects file number 0 or 1";: GoTo FoundError
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get the file handle": GoSub AO
        If cmd16 = LOF_CMD Then
            A$ = "ANDB": B$ = "#$01": C$ = "Limit DECB handle to 0 or 1": GoSub AO
            A$ = "JSR": B$ = "DiskLOFB": C$ = "Return the DECB file length in D:X": GoSub AO
        Else
            A$ = "ANDB": B$ = "#$01": C$ = "Limit SDC handle to 0 or 1": GoSub AO
            A$ = "JSR": B$ = "SDC_LOF": C$ = "Return the SDC file length in D:X": GoSub AO
        End If
        A$ = "PSHS": B$ = "D,X": C$ = "Push the unsigned 32-bit file length": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UInt32)
        Return
    Case GETBYTE_CMD
        If ArgCnt <> 1 Then Print "Error: GETBYTE() expects one file number";: GoTo FoundError
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% Then Print "Error: GETBYTE() expects file number 0 or 1";: GoTo FoundError
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "PULS": B$ = "B": C$ = "Get the DECB stream handle": GoSub AO
        A$ = "ANDB": B$ = "#$01": C$ = "Limit handle to 0 or 1": GoSub AO
        A$ = "JSR": B$ = "DiskGetByteB": C$ = "Read the next DECB file byte into B; zero at EOF": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Push the byte result": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case DELETE_CMD, INITDIR_CMD
        If ArgCnt <> 1 Then Print "Error: DELETE()/INITDIR() expects one string";: GoTo FoundError
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then Print "Error: DELETE()/INITDIR() expects a string";: GoTo FoundError
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack
        If cmd16 = DELETE_CMD Then
            A$ = "JSR": B$ = "FixFileName": C$ = "Format the DECB filename to delete": GoSub AO
            A$ = "JSR": B$ = "DiskDeleteFile": C$ = "Delete the DECB file and return status in B": GoSub AO
        Else
            A$ = "JSR": B$ = "FixFileName": C$ = "Format the flat DECB wildcard and optional drive": GoSub AO
            A$ = "JSR": B$ = "DiskInitDirectory": C$ = "Initialize the flat DECB directory listing": GoSub AO
        End If
        A$ = "PSHS": B$ = "B": C$ = "Push the status result": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case DIRPAGE_CMD
        If ArgCnt <> 1 Then Print "Error: DIRPAGE() expects one argument";: GoTo FoundError
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        Temp$ = Arg1$: GoSub PushOneValueTokenOnStack
        LastType = PushedType: NVT = NT_UByte: GoSub ConvertLastType2NVT
        A$ = "LEAS": B$ = "1,S": C$ = "DIRPAGE uses the initialized DECB listing": GoSub AO
        A$ = "JSR": B$ = "DiskDirectoryPage": C$ = "Build the next 16-entry page in _StrVar_PF01": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Push the directory status": GoSub AO
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_UByte)
        Return
    Case FILEEXISTS_CMD
        ' _FILEEXISTS(fileName$) : one numeric arg -> returns NT_Byte
        If ArgCnt <> 1 Then
            Print "Error: _FILEEXISTS() expects one argument";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' POP: pull the argument token off the ProcessRPN stack
        ' (it should be on the top because RPN puts args before the func)
        ' ------------------------------------------------------------
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Type check: _FILEEXISTS requires a string
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: _FILEEXISTS() expects a string";: GoTo FoundError
        End If
        ' ------------------------------------------------------------
        ' PUSH: put the argument value onto the 6809 stack
        ' This will do the right thing for:
        '   - string var (F3...)
        '   - string literal (F5 22 ... F5 22)
        '   - string result marker (TK_STR_ONSTACK) => already on 6809 stack
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack
        ' Call runtime: consumes string @,S and leaves length (NT_UByte) @,S
        A$ = "JSR": B$ = "DiskRequireNoStreams": C$ = "File existence checks cannot disturb an open stream": GoSub AO
        A$ = "JSR": B$ = "FixFileName": C$ = "Format _StrVar_PF00 to proper disk filename format in memory at DNAMBF": GoSub AO
        A$ = "LDU": B$ = "#DNAMBF": C$ = "U points at the filename to open": GoSub AO
        ' Open the the File pointed at by U
        ' Enter with U pointing at the properly formatted filename (8 character filename padded with spaces) and a 3 character extension
        ' Exits with X pointing at the filename entry in the disk directory
        ' Carry flag will be set if it couldn't find the filename, cleared otherwise
        A$ = "JSR": B$ = "OpenFileU": C$ = "Go open file": GoSub AO
        A$ = "PSHS": B$ = "CC": C$ = "Preserve the file-found result while restoring CPU speed": GoSub AO
        A$ = "JSR": B$ = "SetCPUSpeed": C$ = "Restore the requested CPU speed after disk access": GoSub AO
        A$ = "PULS": B$ = "CC": C$ = "Restore the file-found carry flag": GoSub AO
        A$ = "LDB": B$ = "#$FF": C$ = "B = -1, Default file exists": GoSub AO
        A$ = "BCC": B$ = ">": C$ = "Carry is clear, file exists, all good": GoSub AO
        A$ = "CLRB": C$ = "B = 0, Flag file doesn't exist": GoSub AO
        Z$ = "!": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "save value on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT: replace stack top with numeric-on-6809-stack marker
        ' Net effect: 1 arg popped, 1 result pushed.
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_Byte)
        Return
    Case SDC_FILEEXISTS_CMD
        ' _SDC_FILEEXISTS(fileName$,#) -> returns NT_Byte
        If ArgCnt <> 2 Then
            Print "Error: _SDC_FILEEXISTS() expects 2 arguments on";: GoTo FoundError
        End If
        ' Pop args (RIGHTMOST first): SDC Number, then source string
        LenTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        StrTok$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
        ' Push String first
        Temp$ = StrTok$: GoSub PushOneStringTokenOnStack
        
        A$ = "NOP": C$ = "Nop 1": GoSub AO

        A$ = "JSR": B$ = "SDC_FilenameToStrVar_PF00": C$ = "Copy filename off the stack into _StrVar_PF00": GoSub AO
        A$ = "JSR": B$ = "SDC_AddDefaultBinExtension": C$ = "Add .BIN to SDC_LOADM filename if no extension was provided": GoSub AO

        A$ = "NOP": C$ = "Nop 2": GoSub AO

        ' Push SDC Number on the stack 
        Temp$ = LenTok$: GoSub PushOneValueTokenOnStack
        LastType = PushedType
        NVT = NT_UByte ' Make sure it's 0 to 255 range
        GoSub ConvertLastType2NVT

        A$ = "NOP": C$ = "Nop 3": GoSub AO

        A$ = "PULS": B$ = "B": C$ = "B = SDC file number": GoSub AO
        A$ = "JSR": B$ = "SDCFileExists": C$ = "Test if file is found on the SDC": GoSub AO
        A$ = "RORA": C$ = "Move result of exists flag to carry": GoSub AO
        A$ = "LDB": B$ = "#$FF": C$ = "B = -1, Default file exists": GoSub AO
        A$ = "BCC": B$ = ">": C$ = "Carry is clear, file exists, all good": GoSub AO
        A$ = "CLRB": C$ = "B = 0, Flag file doesn't exist": GoSub AO
        Z$ = "!": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "save value on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT: replace stack top with numeric-on-6809-stack marker
        ' Net effect: 1 arg popped, 1 result pushed.
        ' ------------------------------------------------------------
        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(NT_Byte)
        Return
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
        A$ = "LEAS": B$ = "1,S": C$ = "Fix the stack, this command doesn't really need a value in the brackets": GoSub AO
        A$ = "LDU": B$ = "#_StrVar_PF01": C$ = "U points at scratch buffer for the 256 byte directory listing": GoSub AO
        A$ = "JSR": B$ = "SDC_DirectoryPage": C$ = "Get the directory listing": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B (result of the command) on the stack": GoSub AO
        ' ------------------------------------------------------------
        ' PUSH RESULT MARKER: one result replaces the popped arg
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
        '   - string result marker (TK_STR_ONSTACK) => already on 6809 stack
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
        '   - string result marker (TK_STR_ONSTACK) => already on 6809 stack
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
        '   - string result marker (TK_STR_ONSTACK) => already on 6809 stack
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
        '   - string result marker (TK_STR_ONSTACK) => already on 6809 stack
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
        '   - string result marker (TK_STR_ONSTACK) => already on 6809 stack
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack ' Make sure it's only one byte on the stack
        ' Call runtime: consumes string @,S and leaves length (NT_UByte) @,S
        ' CODEGEN: runtime stub
        ' Convention: address is at ,S (UInt16). Stub consumes it and pushes value.
        ' ------------------------------------------------------------
        A$ = "PULS": B$ = "B": C$ = "B = Length of the string": GoSub AO
        A$ = "LEAX": B$ = ",S": C$ = "X=S": GoSub AO
        A$ = "LDA": B$ = ",S": C$ = "A First byte of the string": GoSub AO
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
        '   - string result marker (TK_STR_ONSTACK) => already on 6809 stack
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

Case VAL_CMD
        ' ------------------------------------------------------------
        ' VAL(x) : one argument, expects string
        '
        ' Phase 2:
        '   1) Fold direct string literals at compile time
        '   2) For non-literals, choose the best runtime numeric type
        '      from current compiler context
        ' ------------------------------------------------------------
        If ArgCnt <> 1 Then
            Print "Error: VAL() expects one argument";: GoTo FoundError
        End If

        ' Pop argument token from ProcessRPN stack
        Arg1$ = ProcessRPNStack$(ProcessRPNStackPointer)
        ProcessRPNStackPointer = ProcessRPNStackPointer - 1

        ' VAL requires a string argument
        Temp$ = Arg1$: GoSub IsStringToken
        If IsStrFlag% = 0 Then
            Print "Error: VAL() expects a string";: GoTo FoundError
        End If

        ' Choose preferred type FIRST so compile-time folding can match
        ' the same type the runtime conversion would have used.
        GoSub ChooseVALPreferredType

        ' ------------------------------------------------------------
        ' FAST PATH: compile-time fold direct string literal
        ' ------------------------------------------------------------
        Temp$ = Arg1$: GoSub TryFoldVALStringLiteral
        If VALFolded <> 0 Then
            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
            ProcessRPNStack$(ProcessRPNStackPointer) = VALFoldToken$
            Return
        End If

        ' ------------------------------------------------------------
        ' RUNTIME PATH
        ' ------------------------------------------------------------

        Temp$ = Arg1$: GoSub PushOneStringTokenOnStack
        GoSub EmitVALRuntimeConversion

        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(VALPreferredType)
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
                A$ = "BEQ": B$ = "@GotA": C$ = "If it's zero then we exit with zero": GoSub AO
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
                A$ = "CLRA": C$ = "A = 0": GoSub AO
                A$ = "LDB": B$ = "1,S": C$ = "Check Mantissa MSB": GoSub AO
                A$ = "BEQ": B$ = "@GotA": C$ = "If it's zero then FFP is zero": GoSub AO
                A$ = "SEX": C$ = "Sign extend into A": GoSub AO
                A$ = "BMI": B$ = "@GotA": C$ = "save -1 on the stack": GoSub AO
                A$ = "INCA": C$ = "Make A = 1": GoSub AO
                Z$ = "@GotA:": GoSub AO
                A$ = "LEAS": B$ = "4,S": C$ = "move stack": GoSub AO
            Case Is = NT_Double ' Double number
                A$ = "CLRA": C$ = "A = 0": GoSub AO
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
                Select Case FloatType
                    Case 0:
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
                    Case 1:
                        A$ = "LDB": B$ = ",S": C$ = "Check Sign": GoSub AO
                        A$ = "BMI": B$ = "@DoNEG": C$ = "If it's Negative then do make positive and do INT": GoSub AO
                        A$ = "JSR": B$ = "FP5_FLOOR": C$ = "Compute floor(x) for 5 byte FP5 number": GoSub AO
                        A$ = "BRA": B$ = ">": C$ = "Skip past": GoSub AO
                        Z$="@DoNEG:": GOSUB AO
                        A$ = "ANDB": B$ = "#%01111111": C$ = "Make it positive": GoSub AO
                        A$ = "STB": B$ = ",S": C$ = "Save Positive version": GoSub AO
                        A$ = "JSR": B$ = "FP5_FLOOR": C$ = "Compute floor(x) for 5 byte FP5 number": GoSub AO
                        A$ = "LDB": B$ = ",S": C$ = "Get Sign&Exponent": GoSub AO
                        A$ = "ORB": B$ = "#%10000000": C$ = "Make it Negative": GoSub AO
                        A$ = "STB": B$ = ",S": C$ = "Save Negative version": GoSub AO
                        Z$ = "!":  GoSub AO:gosub AO
                End Select
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
                Select Case FloatType
                    Case 0:
                        A$ = "LDB": B$ = "1,S": C$ = "Check for Special zero": GoSub AO
                        A$ = "BNE": B$ = ">": C$ = "Do normal Random if not zero": GoSub AO
                        A$ = "LEAS": B$ = "3,S": C$ = "Fix the stack": GoSub AO
                        A$ = "JSR": B$ = "RandomFFP_Zero": C$ = "Get random number >0 and <1, result is on the stack": GoSub AO
                        A$ = "BRA": B$ = "@Done": C$ = "Do normal Random if not zero": GoSub AO
                        Z$ = "!": A$ = "JSR": B$ = "RandomFFP": C$ = "Get random number from 1 to value on the stack, result is on the stack": GoSub AO
                        Z$ = "@Done": GoSub AO: GoSub AO
                    Case 1:
                        A$ = "LDB": B$ = "1,S": C$ = "Check for Special zero": GoSub AO
                        A$ = "BNE": B$ = ">": C$ = "Do normal Random if not zero": GoSub AO
                        A$ = "LEAS": B$ = "5,S": C$ = "Fix the stack": GoSub AO
                        A$ = "JSR": B$ = "RandomFP5_Zero": C$ = "Get random number >0 and <1, result is on the stack": GoSub AO
                        A$ = "BRA": B$ = "@Done": C$ = "Do normal Random if not zero": GoSub AO
                        Z$ = "!": A$ = "JSR": B$ = "RandomFP5": C$ = "Get random number from 1 to value on the stack, result is on the stack": GoSub AO
                        Z$ = "@Done": GoSub AO: GoSub AO
                End Select
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
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_FLOOR": C$ = "Compute floor(x) for 3 byte FFP number": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_FLOOR": C$ = "Compute floor(x) for 5 byte FFP number": GoSub AO
        End Select        
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
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "LDB": B$ = ",S": C$ = "Get the Sign of the FFP number": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "LDB": B$ = ",S": C$ = "Get the Sign of the FP5 number": GoSub AO
        End Select
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
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_SQRT": C$ = "Compute the Square Root of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_SQRT": C$ = "Compute the Square Root of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_SQRT": C$ = "Compute the Square Root of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_SQRT": C$ = "Compute the Square Root of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
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
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_SIN": C$ = "Compute the Sine of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_SIN": C$ = "Compute the Sine of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_SIN": C$ = "Compute the Sine of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_SIN": C$ = "Compute the Sine of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
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
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_COS": C$ = "Compute the Cosine of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_COS": C$ = "Compute the Cosine of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_COS": C$ = "Compute the Cosine of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_COS": C$ = "Compute the Cosine of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
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
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_TAN": C$ = "Compute the Tangent of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_TAN": C$ = "Compute the Tangent of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_TAN": C$ = "Compute the Tangent of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_TAN": C$ = "Compute the Tangent of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
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
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_ATAN": C$ = "Compute the ArcTangent of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_ATAN": C$ = "Compute the ArcTangent of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_ATAN": C$ = "Compute the ArcTangent of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_ATAN": C$ = "Compute the ArcTangent of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
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
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_EXP": C$ = "Compute the Exponential number of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_EXP": C$ = "Compute the Exponential number of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_EXP": C$ = "Compute the Exponential number of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_EXP": C$ = "Compute the Exponential number of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
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
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_LOG": C$ = "Compute the Logarithm number of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_LOG": C$ = "Compute the Logarithm number of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
        NVT = OrigLastType
        GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        LastType = OrigLastType
    Case 11
        ' Handle FFP
        Select Case FloatType
            Case 0:
                ' Handle 3 byte FFP
                A$ = "JSR": B$ = "FFP_LOG": C$ = "Compute the Logarithm number of the FFP # @ ,S save result @ ,S": GoSub AO
            Case 1:
                ' Handle 5 byte FP5
                A$ = "JSR": B$ = "FP5_LOG": C$ = "Compute the Logarithm number of the FP5 # @ ,S save result @ ,S": GoSub AO
        End Select
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
