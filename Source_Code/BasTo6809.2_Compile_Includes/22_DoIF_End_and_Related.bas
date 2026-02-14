
Dim InIFCondition% ' 0 = normal expression, -1 = IF condition mode
Dim IFBranchAlreadyEmitted% ' 0 = no, -1 = yes
Dim IFFalseLabel$ ' label to jump to when condition is FALSE
Dim IFTrueLabel$ ' where to jump when condition is known TRUE (for OR)

Dim SimpleIFCompareMode% ' -1 if we can use simple compare optimization, else 0
Dim LastCompareIndex% ' index in RPNOutput$ of the last comparison op

Dim HasAnd% ' Did this expression contain any AND?
Dim HasOr% ' Did this expression contain any OR?
Dim UsedANDShortCircuit% ' Did we emit an AND short-circuit branch?
Dim UsedORShortCircuit% ' (for completeness, if you later use OR short-circuit)

DoEnd:
' Check for END SELECT command
v = Array(x): x = x + 1
If v = TK_GeneralCommand Then
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    If v = IF_CMD Then
        'We found an END IF
        Num = ElseStack(IFSP): GoSub NumAsString
        If Num < 10 Then Num$ = "0" + Num$
        ' Emit the label `_IFDone_##:` so that any BEQ/BRA jumps land here
        Z$ = "_IFDone_" + Num$: C$ = "Label: END IF": GoSub AO
        ' Now pop the IFstack:
        IFSP = IFSP - 1
        ' (If you have a depth variable like ENDIFCheck, decrement it here:
        ENDIFCheck = ENDIFCheck - 1
        GoTo SkipUntilEOLColon ' Consume any comments and the EOL/colon and Return
    Else
        If v = SELECT_CMD Then
            ' END SELECT
            ' If there was NO CASE ELSE, we must emit the final "no more cases" label
            ' so the last failed CASE has somewhere to land.
            IF CaseElseFlag = 0 THEN
                CaseCount(SELECTStackPointer) = CaseCount(SELECTStackPointer) + 1

                Num = SELECTStack(SELECTStackPointer): GoSub Make2DigitNum
                SelNum$ = Num$

                Num = CaseCount(SELECTStackPointer): GoSub Make2DigitNum
                CaseNumber$ = SelNum$ + "_" + Num$

                Z$ = "_CaseCheck_" + CaseNumber$: C$ = "No more CASEs": GoSub AO
            END IF

            Num = SELECTStack(SELECTStackPointer): GoSub Make2DigitNum
            SelNum$ = Num$

            Z$ = "_EndSelect_" + SelNum$: C$ = "This is the end of Select " + SelNum$: GoSub AO

            ' reset per-select state
            CaseCount(SELECTStackPointer) = 0
            SelHitVar$(SELECTStackPointer) = ""
            SELECTStackPointer = SELECTStackPointer - 1

            GoTo SkipUntilEOLColon
        End If
    End If
Else
    ' no SELECT, just END the program
    A$ = "JMP": B$ = "EXITProgram": C$ = "All done, Exit the program": GoSub AO
    GoTo SkipUntilEOLColon ' Consume any comments and the EOL/colon and Return
End If
Return




DoELSE:
IFProc = IFSP

Num = ElseStack(IFProc): GoSub NumAsString
IFNum$ = Num$
If Num < 10 Then IFNum$ = "0" + IFNum$
A$ = "JMP": B$ = "_IFDone_" + IFNum$: C$ = "Jump to END IF line": GoSub AO
eIdx = ElseIfIndex(IFProc)
If eIdx = 0 Then
    Z$ = "_ELSE_" + IFNum$: C$ = "ELSE entry": GoSub AO
Else
    Num = eIdx: GoSub NumAsString
    EIdx$ = Num$
    If eIdx < 10 Then EIdx$ = "0" + EIdx$
    Z$ = "_ELSEIF_" + IFNum$ + "_" + EIdx$: C$ = "ELSE entry after ELSEIFs": GoSub AO
End If
ElseIfIndex(IFProc) = eIdx + 1
GoTo ConsumeCommentsAndEOL
Return


DoELSEIF:
IFProc = IFSP

' IF number (same ID used for ELSE and END IF labels)
Num = ElseStack(IFProc): GoSub NumAsString
IFNum$ = Num$
If Num < 10 Then IFNum$ = "0" + IFNum$

' If the previous IF/ELSEIF branch was TRUE, skip the rest
A$ = "JMP": B$ = "_IFDone_" + IFNum$: C$ = "Skip remaining ELSEIF/ELSE": GoSub AO

' Emit the entry label where the previous condition's FALSE jumps to
eIdx = ElseIfIndex(IFProc)
If eIdx = 0 Then
    Z$ = "_ELSE_" + IFNum$: C$ = "Entry: first ELSEIF/ELSE": GoSub AO
Else
    Num = eIdx: GoSub NumAsString
    EIdx$ = Num$
    If eIdx < 10 Then EIdx$ = "0" + EIdx$
    Z$ = "_ELSEIF_" + IFNum$ + "_" + EIdx$: C$ = "Entry: ELSEIF #" + EIdx$: GoSub AO
End If

' Advance index for the *next* alternate entry label
ElseIfIndex(IFProc) = eIdx + 1
CurE = ElseIfIndex(IFProc)

' --- Parse ELSEIF condition up to THEN (same as DoIF) ---
CheckIfTrue$ = ""
v = 0
While v <> &HFF
    v = Array(x): x = x + 1
    CheckIfTrue$ = CheckIfTrue$ + Chr$(v)
Wend

v = Array(x) * 256 + Array(x + 1): x = x + 2
If v <> THEN_CMD Then Print "Need a THEN after the ELSEIF statement on";: GoTo FoundError

CheckIfTrue$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HFF
Expression$ = CheckIfTrue$

' --- Look ahead: where should FALSE go next? (next ELSEIF / ELSE / END IF) ---
ScanPos = x
Depth = 1
NextKind = 0 ' 0=end, 1=elseif, 2=else

While ScanPos < Filesize
    vv = Array(ScanPos): ScanPos = ScanPos + 1
    If vv = &HFF Then
        cmd16 = Array(ScanPos) * 256 + Array(ScanPos + 1)

        ' Nested IF increases depth (but ignore the IF in "END IF")
        If cmd16 = IF_CMD Then
            If Not (Array(ScanPos - 4) = &HFF And (Array(ScanPos - 3) * 256 + Array(ScanPos - 2)) = END_CMD) Then
                Depth = Depth + 1
            End If
        End If

        ' END IF decreases depth
        If cmd16 = END_CMD And Array(ScanPos + 2) = &HFF And (Array(ScanPos + 3) * 256 + Array(ScanPos + 4)) = IF_CMD Then
            Depth = Depth - 1
            If Depth = 0 Then Exit While
        End If

        ' Next ELSEIF / ELSE at current IF level decides our FALSE target
        If Depth = 1 Then
            If cmd16 = ELSEIF_CMD Then NextKind = 1: Exit While
            If cmd16 = ELSE_CMD Then NextKind = 2: Exit While
        End If
    End If
Wend

' --- IF condition mode setup (same idea as DoIF) ---
IFFalseLabel$ = ""
IFTrueLabel$ = ""
IFBranchAlreadyEmitted% = 0
InIFCondition% = -1

If NextKind = 0 Then
    IFFalseLabel$ = "_IFDone_" + IFNum$
Else
    eNext = ElseIfIndex(IFProc)
    If eNext = 0 Then
        IFFalseLabel$ = "_ELSE_" + IFNum$
    Else
        Num = eNext: GoSub NumAsString
        ENext$ = Num$
        If eNext < 10 Then ENext$ = "0" + ENext$
        IFFalseLabel$ = "_ELSEIF_" + IFNum$ + "_" + ENext$
    End If
End If

Num = CurE: GoSub NumAsString
CurE$ = Num$
If CurE < 10 Then CurE$ = "0" + CurE$
IFTrueLabel$ = "_IFTrue_" + IFNum$ + "_" + CurE$

GoSub ParseExpression
InIFCondition% = 0

' --- Tail test (same as DoIF) ---
If IFBranchAlreadyEmitted% = 0 Then
    If HasAndOverall% <> 0 And HasOrOverall% = 0 And UsedANDShortCircuit% <> 0 Then
        ' No tail needed
    ElseIf HasOrOverall% <> 0 And UsedORShortCircuit% <> 0 Then
        ' No tail needed
    Else
        A$ = "LDB": B$ = ",S+": C$ = "Get final boolean result": GoSub AO
        A$ = "LBEQ": B$ = IFFalseLabel$: C$ = "If FALSE, go to next branch": GoSub AO
    End If
End If

Z$ = IFTrueLabel$: GoSub AO
GoTo ConsumeCommentsAndEOL
Return


' Found an IF
' ========== Globals (share across all routines) ==========
' IFCount   : an ever-increasing counter for each new IF
' IFSP      : "stack pointer" for nested IFs (starts at 0)
' IFStack() : array storing the IFCount for each nested level
' ElseStack(): same as IFStack(), used to emit labels
' ELSELocation(): 0/1 flag indicating "did we find an ELSE?" for that IF
' Filesize  : length of Array() in bytes
' Array(x)  : the raw token stream of your compiled BASIC (bytes)
' x         : your current byte-pointer into Array()
' IF_CMD, ELSE_CMD, END_CMD, THEN_CMD : numeric op-codes from Array()
'
' You also need these helper subs:
'   NumAsString   : converts numeric IFCount into a two-character string Num$
'   AO            : emits whatever is in A$, B$, C$ as a single line (e.g. "BEQ    _ELSE_03   ; _")
'
' Make sure you never reset IFSP or IFProc inside these routines, except exactly where noted below.

' ==============================
' (1) PROCEDURE to call as soon as you see "IF _ THEN"
' ==============================

DoIF:
LastDataTypeSize = -1
' --- Step 1: Assign a unique ID to this new IF and push it onto the IF-stack ---
IFCount = IFCount + 1 ' e.g. 0→1→2→3_ each time you hit a brand-new IF
IFSP = IFSP + 1 ' "push" a new stack slot
IFProc = IFSP ' index into IFStack/ElseStack arrays
IFSTack(IFProc) = IFCount ' record that ID
ElseStack(IFProc) = IFCount ' we use the same ID for ELSE and END IF labels
ELSELocation(IFProc) = 0 ' default = "no ELSE until we find one"
ElseIfIndex(IFProc) = 0

' --- Step 2: Scan ahead (without changing the real x) to see if this IF has an ELSE BEFORE its matching END IF ---
FirstIFLocation = x ' remember where the condition begins (just after the IF token)
ScanPos = x ' we'll use ScanPos to walk ahead, then restore x
ENDIFCheck = 1 ' we're looking for our own END IF (depth = 1)
FoundELSE = 0

ScanAheadLoop:
If ScanPos + 3 > Filesize Then GoTo DoneScanning ' (malformed BASIC? just bail)
v = Array(ScanPos): ScanPos = ScanPos + 1 ' read one byte of token
' Check if we've hit another "IF" at depth > 0
If v = &HFF And Array(ScanPos) * 256 + Array(ScanPos + 1) = IF_CMD Then
    ' Look ahead to see if this is actually "END IF" or a fresh IF
    If (Array(ScanPos - 4) = &HFF And Array(ScanPos - 3) * 256 + Array(ScanPos - 2) = END_CMD) Then
        ' That was an "END IF," so do NOT treat as a nested IF
    Else
        ENDIFCheck = ENDIFCheck + 1
    End If
End If

' Check if this byte sequence is ELSE or ELSEIF
If v = &HFF Then
    cmd16 = Array(ScanPos) * 256 + Array(ScanPos + 1)
    If (cmd16 = ELSE_CMD) Or (cmd16 = ELSEIF_CMD) Then
        If ENDIFCheck = 1 Then
            FoundELSE = 1
            GoTo DoneScanning
        End If
    End If
End If

' Check if this byte sequence is END IF
    If v = &HFF _
       And Array(ScanPos)*256 + Array(ScanPos+1) = END_CMD _
       And Array(ScanPos+2) = &HFF _
       And Array(ScanPos+3)*256 + Array(ScanPos+4) = IF_CMD Then

    ENDIFCheck = ENDIFCheck - 1
    If ENDIFCheck = 0 Then GoTo DoneScanning
End If

GoTo ScanAheadLoop

DoneScanning:
ELSELocation(IFProc) = FoundELSE ' record whether an ELSE appeared first
x = FirstIFLocation ' restore x so we can actually parse the condition
' (Now x points just after "IF" in the token stream.)
' x points just past the IF        , ' This is the point where the expression starts
CheckIfTrue$ = ""
SaveIFX = x ' Save this position, just in case we have floating point compares to test for
v = 0
While v <> &HFF ' Keep copying until we get the next command which should be a THEN
    v = Array(x): x = x + 1
    CheckIfTrue$ = CheckIfTrue$ + Chr$(v)
Wend
'(x), Hex$(Array(x)), Hex$(Array(x + 1)), Hex$(Array(x + 2)), Hex$(Array(x + 3))
v = Array(x) * 256 + Array(x + 1): x = x + 2
If v <> THEN_CMD Then Print "Need a THEN after the IF statement on";: GoTo FoundError
CheckIfTrue$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HFF on the end

Expression$ = CheckIfTrue$

Z$ = "; Starting if": GoSub AO
' --- IF condition mode setup ---
IFFalseLabel$ = ""
IFTrueLabel$ = ""
IFBranchAlreadyEmitted% = 0
InIFCondition% = -1 ' Tell ProcessRPN / operators we are compiling an IF

Num = IFSTack(IFProc): GoSub NumAsString
If Num < 10 Then Num$ = "0" + Num$

' Decide FALSE label: ELSE or IFDone
If ELSELocation(IFProc) > 0 Then
    IFFalseLabel$ = "_ELSE_" + Num$
Else
    IFFalseLabel$ = "_IFDone_" + Num$
End If

' TRUE label is where THEN body starts; we’ll emit it AFTER expression:
IFTrueLabel$ = "_IFTrue_" + Num$

GoSub ParseExpression ' This calls ExpressionToRPN + ProcessRPN

InIFCondition% = 0 ' back to normal mode
Z$ = "; Expression is parsed": GoSub AO

'GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
'GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN

' CompareType is a number from 0 to 9
' where:  Opposite
'0 = BEQ  1 - BNE
'1 = BNE  0 - BEQ
'2 = BLO  5 - BHS
'3 = BLS  4 - BHI
'4 = BHI  3 - BLS
'5 = BHS  2 - BLO
'6 = BLT  9 - BGE
'7 = BLE  8 - BGT
'8 = BGT  7 - BLE
'9 = BGE  6 - BLT

' --- IF tail: only emit a final boolean test when needed ---
If IFBranchAlreadyEmitted% = 0 Then

    ' 1) Pure-AND IF where AND short-circuit handled the final test:
    If HasAndOverall% <> 0 And HasOrOverall% = 0 And UsedANDShortCircuit% <> 0 Then
        ' No tail code needed.

        ' 2) Any IF that used OR short-circuit:
        '    The last OR already did LDB ,S+ / LBEQ IFFalseLabel$.
    ElseIf HasOrOverall% <> 0 And UsedORShortCircuit% <> 0 Then
        ' No tail code needed (covers pure-OR and mixed AND/OR).

        ' 3) Everything else (single compare, no short-circuit used, etc.)
    Else
        A$ = "LDB": B$ = ",S+": C$ = "Get final boolean result": GoSub AO
        A$ = "LBEQ": B$ = IFFalseLabel$: C$ = "If FALSE, go to ELSE/END IF": GoSub AO
    End If
End If

' OR short-circuits and the final OR fall-through land here on TRUE:
Z$ = IFTrueLabel$: GoSub AO
GoTo ConsumeCommentsAndEOL
