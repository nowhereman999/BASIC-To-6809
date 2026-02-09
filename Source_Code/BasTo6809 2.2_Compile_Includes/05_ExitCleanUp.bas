ExitProgram:
Print #1, "EXITProgram:"
A$ = "ORCC": B$ = "#$50": C$ = "Turn off the interrupts": GoSub AO
A$ = "STA": B$ = "$FFD8": C$ = "Put Coco back in normal speed": GoSub AO
A$ = "LDB": B$ = "#1": C$ = "B=1, make the CPU run at normal speed"
A$ = "JSR": B$ = "SetCPUSpeedB": C$ = "Set the speed according to B"
If Ret2Basic <> 1 Then A$ = "BRA": B$ = "*": C$ = "Endless loop, do not return to BASIC": GoSub AO
' Restore the IRQ jump address
A$ = "LDX": B$ = "$FFFE": C$ = "Get the RESET location": GoSub AO
A$ = "CMPX": B$ = "#$8C1B": C$ = "Check if it's a CoCo 3": GoSub AO
A$ = "BNE": B$ = "RestoreCoCo1": C$ = "Setup IRQ, using CoCo 1 IRQ Jump location": GoSub AO
A$ = "LDX": B$ = "#$FEF7": C$ = "X = Address for the COCO 3 IRQ JMP": GoSub AO
A$ = "BRA": B$ = ">": C$ = "Skip ahead": GoSub AO
Z$ = "RestoreCoCo1": GoSub AO
A$ = "LDX": B$ = "#$010C": C$ = "X = Address for the COCO 1 IRQ JMP": GoSub AO
Z$ = "!"
' Restore it
A$ = "LDU": B$ = "#OriginalIRQ": C$ = "U = Address of the original IRQ": GoSub AO
A$ = "LDA": B$ = ",U": C$ = "A = Branch Instruction": GoSub AO
A$ = "STA": B$ = ",X": C$ = "Save Branch Instruction": GoSub AO
A$ = "LDD": B$ = "1,U": C$ = "D = address": GoSub AO
A$ = "STD": B$ = "1,X": C$ = "Restore the Address of the IRQ": GoSub AO
Print #1, "RestoreStack:"
A$ = "LDS": B$ = "#$0000": C$ = "Selfmodified when this programs starts - this restores S just how BASIC had it": GoSub AO
A$ = "PULS": B$ = "CC,D,DP,X,Y,U,PC": C$ = "Restore the original BASIC Register values and return to BASIC, if it can": GoSub AO

' Add data Table if needed
Print #1, "DataStart:"
If DataArrayCount > 0 Then
    For x = 0 To DataArrayCount - 1 Step 4
        Print #1, "        FQB     $";
        q1$ = Right$("00" + Hex$(DataArray(x)), 2) + Right$("00" + Hex$(DataArray(x + 1)), 2)
        q2$ = Right$("00" + Hex$(DataArray(x + 2)), 2) + Right$("00" + Hex$(DataArray(x + 3)), 2)
        Print #1, q1$; q2$; "   ;";
        Print #1, Right$("0000" + Hex$(x + a), 4); ": ";
        If DataArray(x) >= 32 And DataArray(x) <= 126 Then
            Print #1, Chr$(DataArray(x));
        Else
            Print #1, ".";
        End If
        If DataArray(x + 1) >= 32 And DataArray(x + 1) <= 126 Then
            Print #1, Chr$(DataArray(x + 1));
        Else
            Print #1, ".";
        End If
        If DataArray(x + 2) >= 32 And DataArray(x + 2) <= 126 Then
            Print #1, Chr$(DataArray(x + 2));
        Else
            Print #1, ".";
        End If
        If DataArray(x + 3) >= 32 And DataArray(x + 3) <= 126 Then
            Print #1, Chr$(DataArray(x + 3)); "  ";
        Else
            Print #1, ".  ";
        End If
        Print #1, Right$("00" + Hex$(DataArray(x)), 2); " "; Right$("00" + Hex$(DataArray(x + 1)), 2); " ";
        Print #1, Right$("00" + Hex$(DataArray(x + 2)), 2); " "; Right$("00" + Hex$(DataArray(x + 3)), 2)
    Next x
End If
If AutoStart = 1 Then
    ' Make the program autostart (takes over the IRQ JMP routine)
    A$ = "ORG": B$ = "$0176": C$ = "Make the program autostart by changing the CLOSE ONE FILE jump to jump to ours instead": GoSub AO
    A$ = "JMP": B$ = "START": C$ = "Make it point to the start of this program": GoSub AO
End If
A$ = "END": B$ = "START": GoSub AO
Close #1

' ------------------------------------------------------------
' Peephole optimization: comment out redundant PSHS/PULS pairs
'   PSHS B  ...comments/blank...  PULS B
'   PSHS D  ...comments/blank...  PULS D
' ------------------------------------------------------------
If Optimize > 0 Then
    fileName$ = OutName$

    Open fileName$ For Input As #1
    Open "temp.asm" For Output As #2

    pendingReg$ = ""       ' "B" or "D" when we have a pending PSHS
    pendingPush$ = ""      ' the PSHS line we are holding
    between$ = ""          ' buffered blank/comment lines between PSHS and PULS

    Do While Not EOF(1)
        Line Input #1, line$

        ' Helper classification
        t$ = LTrim$(line$)
        isBlankOrComment = (t$ = "") Or (Left$(t$, 1) = ";") Or (Left$(t$, 1) = "*")

        ' Detect "PSHS B" or "PSHS D" (single-register only)
        regPush$ = ""
        If t$ <> "" Then
            If UCase$(Left$(t$, 4)) = "PSHS" Then
                p% = 5
                While p% <= Len(t$) And Mid$(t$, p%, 1) = " ": p% = p% + 1: Wend
                If p% <= Len(t$) Then
                    ' read operand token up to space/comma/;/*
                    q% = p%
                    While q% <= Len(t$)
                        ch$ = Mid$(t$, q%, 1)
                        If ch$ = " " Or ch$ = "," Or ch$ = ";" Or ch$ = "*" Then Exit While
                        q% = q% + 1
                    Wend
                    tok$ = Mid$(t$, p%, q% - p%)
                    ' ensure it's only B or D, and not PSHS B,X etc.
                    If (tok$ = "B" Or tok$ = "D") Then
                        ' verify next non-space is comment or end (no extra operands)
                        r% = q%
                        While r% <= Len(t$) And Mid$(t$, r%, 1) = " ": r% = r% + 1: Wend
                        If r% > Len(t$) Or Mid$(t$, r%, 1) = ";" Or Mid$(t$, r%, 1) = "*" Then
                            regPush$ = tok$
                        End If
                    End If
                End If
            End If
        End If

        ' Detect "PULS B" or "PULS D" (single-register only)
        regPull$ = ""
        If t$ <> "" Then
            If UCase$(Left$(t$, 4)) = "PULS" Then
                p% = 5
                While p% <= Len(t$) And Mid$(t$, p%, 1) = " ": p% = p% + 1: Wend
                If p% <= Len(t$) Then
                    q% = p%
                    While q% <= Len(t$)
                        ch$ = Mid$(t$, q%, 1)
                        If ch$ = " " Or ch$ = "," Or ch$ = ";" Or ch$ = "*" Then Exit While
                        q% = q% + 1
                    Wend
                    tok$ = Mid$(t$, p%, q% - p%)
                    If (tok$ = "B" Or tok$ = "D") Then
                        r% = q%
                        While r% <= Len(t$) And Mid$(t$, r%, 1) = " ": r% = r% + 1: Wend
                        If r% > Len(t$) Or Mid$(t$, r%, 1) = ";" Or Mid$(t$, r%, 1) = "*" Then
                            regPull$ = tok$
                        End If
                    End If
                End If
            End If
        End If

        ' ----------------------------
        ' State machine
        ' ----------------------------
        If pendingReg$ = "" Then
            ' No pending PSHS
            If regPush$ <> "" Then
                pendingReg$ = regPush$
                pendingPush$ = line$
                between$ = ""
            Else
                Print #2, line$
            End If
        Else
            ' We have a pending PSHS (B or D)
            If isBlankOrComment Then
                between$ = between$ + line$ + Chr$(10)
            ElseIf regPull$ = pendingReg$ And regPull$ <> "" Then
                ' Matched: comment out both PSHS and PULS (semicolon in column 1)
                If Left$(pendingPush$, 1) <> ";" Then pendingPush$ = ";" + pendingPush$
                outPull$ = line$
                If Left$(outPull$, 1) <> ";" Then outPull$ = ";" + outPull$

                Print #2, pendingPush$

                ' emit buffered lines
                tmp$ = between$
                Do While Len(tmp$) > 0
                    k% = InStr(tmp$, Chr$(10))
                    If k% = 0 Then Exit Do
                    one$ = Left$(tmp$, k% - 1)
                    Print #2, one$
                    tmp$ = Mid$(tmp$, k% + 1)
                Loop

                Print #2, outPull$

                ' clear pending
                pendingReg$ = ""
                pendingPush$ = ""
                between$ = ""
            Else
                ' Not a match: flush pending PSHS and buffered lines unchanged
                Print #2, pendingPush$

                tmp$ = between$
                Do While Len(tmp$) > 0
                    k% = InStr(tmp$, Chr$(10))
                    If k% = 0 Then Exit Do
                    one$ = Left$(tmp$, k% - 1)
                    Print #2, one$
                    tmp$ = Mid$(tmp$, k% + 1)
                Loop

                pendingReg$ = ""
                pendingPush$ = ""
                between$ = ""

                ' Now process current line again (could be a new PSHS)
                If regPush$ <> "" Then
                    pendingReg$ = regPush$
                    pendingPush$ = line$
                    between$ = ""
                Else
                    Print #2, line$
                End If
            End If
        End If
    Loop

    ' EOF: flush any pending PSHS + buffered lines
    If pendingReg$ <> "" Then
        Print #2, pendingPush$
        tmp$ = between$
        Do While Len(tmp$) > 0
            k% = InStr(tmp$, Chr$(10))
            If k% = 0 Then Exit Do
            one$ = Left$(tmp$, k% - 1)
            Print #2, one$
            tmp$ = Mid$(tmp$, k% + 1)
        Loop
    End If

    Close #1
    Close #2

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
    Kill "SpritesUsed.txt"
    Kill "SamplesUsed.txt"
    Kill "BASIC_Text.bas"
    Kill "BasicTokenized.bin"
    Kill "BasicTokenizedB4Pass2.bin"
    Kill "BasicTokenizedB4Pass3.bin"
End If
If Verbose > 0 Then Print "All Done :)"
System 1 ' 1 signifies exit with no errors :)

