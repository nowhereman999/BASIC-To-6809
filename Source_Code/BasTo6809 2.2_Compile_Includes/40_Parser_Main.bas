' Main Entrance Expression Parsing
' It can now handle string and numeric parsing
' Enter with expresion to parse in Expression$
' GoSub ParseNumericExpression

' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
ParseExpression:
ParseStringExpression:
ParseNumericExpression:
GoSub ExpressionToRPN
GoSub ProcessRPN
Return

ExpressionToRPN:
Dim ParenSP As Integer
Dim ParenIsArray(0 To 255) As Integer ' 1 if this '(' belongs to an array index list
Dim ParenArgCount(0 To 255) As Integer ' how many args separated by commas
Dim ParenInnerDepth(0 To 255) As Integer
Dim ParenFuncTok$(0 To 255) ' stores the function token (ex: LEN) for this paren level
ParenSP = -1

Dim FuncTok$

Const PAREN_NUMFUNC = 3
Const PAREN_STRFUNC = 4

RPNStackPointer = -1
RPNLast = -1

' ------------------------------------------------------------
' ExpectValue rules:
'   -1 (true)  = we are expecting a VALUE next
'    0 (false) = we are expecting an OPERATOR next
'
' At start of expression we expect a value.
' After an operator or '(' we expect a value.
' After an operand, literal, or ')' we expect an operator.
' ------------------------------------------------------------
Dim ExpectValue As Integer
ExpectValue = -1
p = 1
While p <= Len(Expression$)
    ' Debug
    '    ' Print "RPNLast"; RPNLast
    v = Asc(Mid$(Expression$, p, 1))
    Select Case v
        ' ====================================================
        ' OPERANDS: Copy to output as-is
        ' ====================================================
        Case TK_NumericArray
            ' Copy the 5-byte array descriptor token (F0,MSB,LSB,Type,#Elems) into RPN as ONE entry
            Emit$ = Mid$(Expression$, p, 5): GoSub RPN_Emit
            p = p + 5

            ' Must be followed by: F5 28  ( "(" )
            If p + 1 > Len(Expression$) Then Print "Error: array token not followed by ( on";: GoTo FoundError
            If Asc(Mid$(Expression$, p, 1)) <> TK_SpecialChar Then Print "Error: array token not followed by ( on";: GoTo FoundError
            If Asc(Mid$(Expression$, p + 1, 1)) <> &H28 Then Print "Error: array token not followed by ( on";: GoTo FoundError

            ' Push '(' onto operator stack
            RPNStackPointer = RPNStackPointer + 1
            RPNStack(RPNStackPointer) = &H28

            ' Track this paren as a numeric-array subscript list
            ParenSP = ParenSP + 1
            ParenIsArray(ParenSP) = 1
            ParenArgCount(ParenSP) = 1
            ParenInnerDepth(ParenSP) = 0

            ' If nested inside another array's () list, count nested parens there
            If ParenSP > 0 Then
                If ParenIsArray(ParenSP - 1) <> 0 Then
                    ParenInnerDepth(ParenSP - 1) = ParenInnerDepth(ParenSP - 1) + 1
                End If
            End If

            p = p + 2 ' Skip the F5 28
            ExpectValue = -1
        Case TK_StrArray 'String Array Variable
            ' Copy the 4-byte string-array descriptor token (F1,MSB,LSB,#Elems) into RPN as ONE entry
            Emit$ = Mid$(Expression$, p, 4): GoSub RPN_Emit
            p = p + 4

            ' Must be followed by: F5 28  ( "(" )
            If p + 1 > Len(Expression$) Then Print "Error: string array token not followed by ( on";: GoTo FoundError
            If Asc(Mid$(Expression$, p, 1)) <> TK_SpecialChar Then Print "Error: string array token not followed by ( on";: GoTo FoundError
            If Asc(Mid$(Expression$, p + 1, 1)) <> &H28 Then Print "Error: string array token not followed by ( on";: GoTo FoundError

            ' Push '(' onto operator stack
            RPNStackPointer = RPNStackPointer + 1
            RPNStack(RPNStackPointer) = &H28

            ' Track this paren as a string-array subscript list (ParenIsArray=2)
            ParenSP = ParenSP + 1
            ParenIsArray(ParenSP) = 2
            ParenArgCount(ParenSP) = 1
            ParenInnerDepth(ParenSP) = 0

            ' If nested inside another array's () list, count nested parens there
            If ParenSP > 0 Then
                If ParenIsArray(ParenSP - 1) <> 0 Then
                    ParenInnerDepth(ParenSP - 1) = ParenInnerDepth(ParenSP - 1) + 1
                End If
            End If

            p = p + 2 ' Skip the F5 28
            ExpectValue = -1
        Case TK_NumericVar 'Regular Numeric Variable
            TempTok$ = Chr$(v): p = p + 1
            For ii = 1 To 3
                TempTok$ = TempTok$ + Mid$(Expression$, p, 1): p = p + 1
            Next ii
            GoSub CheckForSpecialChar
            TempTok$ = TempTok$ + Chr$(ManualType)

            Emit$ = TempTok$: GoSub RPN_Emit
            ExpectValue = 0
        Case TK_StringVar 'Regular String Variable
            TempTok$ = Chr$(v): p = p + 1
            For ii = 1 To 2
                TempTok$ = TempTok$ + Mid$(Expression$, p, 1): p = p + 1
            Next ii

            Emit$ = TempTok$: GoSub RPN_Emit
            ExpectValue = 0
            ' ====================================================
            ' SPECIAL CHAR TOKEN
            ' ====================================================
        Case TK_SpecialChar
            If p + 1 > Len(Expression$) Then Print "Error: truncated special char token on";: GoTo FoundError
            v = Asc(Mid$(Expression$, p + 1, 1))
            Select Case v
                Case &H28 ' "("   (token is F5 28)
                    ' normal grouping paren
                    RPNStackPointer = RPNStackPointer + 1
                    RPNStack(RPNStackPointer) = &H28
                    ParenSP = ParenSP + 1
                    ParenIsArray(ParenSP) = 0
                    ParenArgCount(ParenSP) = 0
                    ParenInnerDepth(ParenSP) = 0
                    ' If parent paren is an array-arg list, this creates nesting inside it
                    If ParenSP > 0 Then
                        If ParenIsArray(ParenSP - 1) <> 0 Then
                            ParenInnerDepth(ParenSP - 1) = ParenInnerDepth(ParenSP - 1) + 1
                        End If
                    End If
                    p = p + 2
                    ExpectValue = -1
                Case &H29 ' ")"   (token is F5 29)
                    ' Pop ops until '('
                    While RPNStackPointer >= 0 And RPNStack(RPNStackPointer) <> &H28
                        Emit$ = Chr$(TK_OperatorCommand) + Chr$(RPNStack(RPNStackPointer)): GoSub RPN_Emit
                        RPNStackPointer = RPNStackPointer - 1
                    Wend
                    If RPNStackPointer < 0 Then Print "Error: missing ( on";: GoTo FoundError
                    ' Pop '('
                    RPNStackPointer = RPNStackPointer - 1
                    ' Pop paren metadata
                    If ParenSP < 0 Then Print "Error: paren stack underflow on";: GoTo FoundError
                    If ParenIsArray(ParenSP) = 1 Then
                        ' Numeric array indexing: either load the VALUE or (inside VARPTR) produce an ADDRESS.
                        If VarptrDepth>0 Then
                            Emit$ = Chr$(TK_OperatorCommand) + Chr$(OP_ARRPTR) + Chr$(ParenArgCount(ParenSP)): GoSub RPN_Emit
                        Else
                            Emit$ = Chr$(TK_OperatorCommand) + Chr$(OP_ARRLOAD) + Chr$(ParenArgCount(ParenSP)): GoSub RPN_Emit
                        End If
                    ElseIf ParenIsArray(ParenSP) = 2 Then
                        ' String array indexing: either load the VALUE (string) or (inside VARPTR) produce an ADDRESS.
                        If VarptrDepth>0 Then
                            Emit$ = Chr$(TK_OperatorCommand) + Chr$(OP_STRARRPTR) + Chr$(ParenArgCount(ParenSP)): GoSub RPN_Emit
                        Else
                            Emit$ = Chr$(TK_OperatorCommand) + Chr$(OP_STRARRLOAD) + Chr$(ParenArgCount(ParenSP)): GoSub RPN_Emit
                        End If
                    ElseIf ParenIsArray(ParenSP) = PAREN_NUMFUNC Then
                        ' Emit function token + argCount
                        Emit$ = ParenFuncTok$(ParenSP) + Chr$(ParenArgCount(ParenSP)): GoSub RPN_Emit
                        ' If this was VARPTR(), turn off address-mode AFTER closing it
                        cmd16 = Asc(Mid$(ParenFuncTok$(ParenSP), 2, 1)) * 256 + Asc(Mid$(ParenFuncTok$(ParenSP), 3, 1))
                        If cmd16 = VARPTR_CMD Then VarptrDepth% = VarptrDepth% - 1':WantAddress% = 0
                        If VarptrDepth% < 0 Then VarptrDepth% = 0
                    ElseIf ParenIsArray(ParenSP) = PAREN_STRFUNC Then
                        ' Emit string func token AFTER its argument expression(s)
                        ' Append argcount so ProcessRPN can pop the right number of args
                        Emit$ = ParenFuncTok$(ParenSP) + Chr$(ParenArgCount(ParenSP)): GoSub RPN_Emit
                    End If
                    ParenSP = ParenSP - 1
                    ' If we just closed something nested inside a parent array arg list, reduce that depth
                    If ParenSP >= 0 Then
                        If ParenIsArray(ParenSP) <> 0 And ParenInnerDepth(ParenSP) > 0 Then
                            ParenInnerDepth(ParenSP) = ParenInnerDepth(ParenSP) - 1
                        End If
                    End If
                    p = p + 2
                    ExpectValue = 0
                Case TK_Comma ' "," (token is F5 2C)
                    ' Only treat comma as "next dimension" when it's a top-level comma in THIS array paren
                    If ParenSP >= 0 And ParenIsArray(ParenSP) <> 0 And ParenInnerDepth(ParenSP) = 0 Then
                        ' flush ops up to '('
                        While RPNStackPointer >= 0 And RPNStack(RPNStackPointer) <> &H28
                            Emit$ = Chr$(TK_OperatorCommand) + Chr$(RPNStack(RPNStackPointer)): GoSub RPN_Emit
                            RPNStackPointer = RPNStackPointer - 1
                        Wend

                        ParenArgCount(ParenSP) = ParenArgCount(ParenSP) + 1
                        p = p + 2
                        ExpectValue = -1
                    Else
                        ' otherwise treat as normal special char
                        RPNOutput$(RPNLast) = RPNOutput$(RPNLast) + Chr$(TK_SpecialChar) + Chr$(v)
                        p = p + 2
                    End If
                Case TK_Quote ' string literal
                    TempTok$ = Chr$(TK_SpecialChar) + Chr$(TK_Quote)
                    p = p + 2

                    While p + 1 <= Len(Expression$)
                        If Asc(Mid$(Expression$, p, 1)) = TK_SpecialChar Then
                            If Asc(Mid$(Expression$, p + 1, 1)) = TK_Quote Then Exit While
                        End If
                        TempTok$ = TempTok$ + Mid$(Expression$, p, 1)
                        p = p + 1
                    Wend

                    If p + 1 > Len(Expression$) Then Print "Error: missing closing quote on";: GoTo FoundError
                    If Asc(Mid$(Expression$, p, 1)) <> TK_SpecialChar Then Print "Error: missing closing quote on";: GoTo FoundError
                    If Asc(Mid$(Expression$, p + 1, 1)) <> TK_Quote Then Print "Error: missing closing quote on";: GoTo FoundError

                    TempTok$ = TempTok$ + Chr$(TK_SpecialChar) + Chr$(TK_Quote)
                    p = p + 2

                    Emit$ = TempTok$: GoSub RPN_Emit
                    ExpectValue = 0
                Case Else
                    ' Everything else goes to output as special-char token
                    Emit$ = Chr$(TK_SpecialChar) + Chr$(v): GoSub RPN_Emit
                    p = p + 2
                    ' Depending on what this char is, you might want
                    ' to adjust ExpectValue later (e.g., comma if you add functions).
            End Select
            ' ====================================================
            ' DEF FN pointer token
            ' ====================================================
        Case TK_DEFFunction
            TempTok$ = Chr$(v): p = p + 1
            For ii = 1 To 2
                TempTok$ = TempTok$ + Mid$(Expression$, p, 1): p = p + 1
            Next ii
            GoSub CheckForSpecialChar
            TempTok$ = TempTok$ + Chr$(ManualType)
            Emit$ = TempTok$: GoSub RPN_Emit
            ExpectValue = 0
            ' ====================================================
            ' OPERATOR COMMAND TOKEN (FC)
            ' Includes:
            '   AND, OR, MOD, XOR, NOT, DIVR, *, +, -, /, <, =, >, \, ^
            '   plus your extended relational codes:
            '     60 "<>"  61 "<="  62 ">="
            '
            ' Your tokenizer emits relational pairs separately:
            '   FC "<" FC "="   OR   FC "=" FC "<"
            '   FC ">" FC "="   OR   FC "=" FC ">"
            '   FC "<" FC ">"
            '
            ' We merge those pairs into 60/61/62 here.
            ' We also detect unary '-' and convert to TK_NEG (16).
            ' ====================================================
        Case TK_OperatorCommand
            ' We are sitting on FC
            p = p + 1
            v = Asc(Mid$(Expression$, p, 1)) ' first operator byte
            ' ------------------------------------------------------------
            ' MERGE TWO-TOKEN RELATIONAL OPS INTO EXTENDED CODES
            ' Stream pattern:  FC op1 FC op2
            ' ------------------------------------------------------------
            If p + 2 <= Len(Expression$) Then
                Dim nextTok As Integer
                Dim nextOp As Integer
                nextTok = Asc(Mid$(Expression$, p + 1, 1))
                nextOp = Asc(Mid$(Expression$, p + 2, 1))
                If nextTok = TK_OperatorCommand Then
                    If (v = Asc("<") And nextOp = Asc(">")) Then
                        v = &H60 ' "<>"
                        p = p + 2
                        ElseIf (v = Asc("<") And nextOp = Asc("=")) Or _
                               (v = Asc("=") And nextOp = Asc("<")) Then
                        v = &H61 ' "<="
                        p = p + 2
                        ElseIf (v = Asc(">") And nextOp = Asc("=")) Or _
                               (v = Asc("=") And nextOp = Asc(">")) Then
                        v = &H62 ' ">="
                        p = p + 2
                    End If
                End If
            End If
            ' ------------------------------------------------------------
            ' UNARY MINUS DETECTION
            ' If we are expecting a value, '-' is unary => TK_NEG
            ' ------------------------------------------------------------
            If v = &H2D And ExpectValue Then ' &H2D = "-"
                v = TK_NEG
            End If
            PrecNew = GetPrecedence%(v)
            ' Pop while top outranks new op
            While RPNStackPointer >= 0
                topOp = RPNStack(RPNStackPointer)
                If topOp = &H28 Then Exit While ' stop at '('
                PrecTop = GetPrecedence%(topOp)
                If PrecTop > PrecNew Then
                    Emit$ = Chr$(TK_OperatorCommand) + Chr$(topOp): GoSub RPN_Emit
                    RPNStackPointer = RPNStackPointer - 1
                ElseIf PrecTop = PrecNew Then
                    If IsLeftAssociative%(v) Then
                        Emit$ = Chr$(TK_OperatorCommand) + Chr$(topOp): GoSub RPN_Emit
                        RPNStackPointer = RPNStackPointer - 1
                    Else
                        Exit While
                    End If
                Else
                    Exit While
                End If
            Wend
            ' Push new operator
            RPNStackPointer = RPNStackPointer + 1
            RPNStack(RPNStackPointer) = v
            ' Move past the operator byte we are currently on
            p = p + 1
            ' After any operator, next token should be a value
            ExpectValue = -1
            ' ====================================================
            ' STRING / NUMERIC COMMANDS
            ' If these are true functions, you may later want to
            ' move them onto the operator stack like shunting-yard.
            ' For now you keep them as direct output tokens.
            ' ====================================================
        Case TK_StringCommand
            ' Read: [TK_StringCommand][cmdHi][cmdLo]
            FuncTok$ = Chr$(TK_StringCommand)
            p = p + 1
            If p + 1 > Len(Expression$) Then Print "Error: string command truncated on";: GoTo FoundError
            FuncTok$ = FuncTok$ + Mid$(Expression$, p, 2)
            p = p + 2 ' now p points to the next token after cmdHi/cmdLo

            ' If followed by "(" then this is a function call: emit at ")"
            If p + 1 <= Len(Expression$) Then
                If Asc(Mid$(Expression$, p, 1)) = TK_SpecialChar And Asc(Mid$(Expression$, p + 1, 1)) = &H28 Then
                    ' Push '(' onto operator stack
                    RPNStackPointer = RPNStackPointer + 1
                    RPNStack(RPNStackPointer) = &H28

                    ' Paren metadata: mark as STRING-function call
                    ParenSP = ParenSP + 1
                    ParenIsArray(ParenSP) = PAREN_STRFUNC
                    ParenArgCount(ParenSP) = 1
                    ParenInnerDepth(ParenSP) = 0
                    ParenFuncTok$(ParenSP) = FuncTok$

                    ' If nested inside another arg-list (array or function):
                    If ParenSP > 0 Then
                        If ParenIsArray(ParenSP - 1) <> 0 Then
                            ParenInnerDepth(ParenSP - 1) = ParenInnerDepth(ParenSP - 1) + 1
                        End If
                    End If

                    p = p + 2 ' skip F5 28
                    ExpectValue = -1
                Else
                    ' Not followed by "(": emit immediately (ex: INKEY$)
                    Emit$ = FuncTok$: GoSub RPN_Emit
                    ExpectValue = 0
                End If
            Else
                ' End of expression right after the command token (ex: INKEY$)
                Emit$ = FuncTok$: GoSub RPN_Emit
                ExpectValue = 0
            End If
        Case TK_NumericCommand
            ' Read: [TK_NumericCommand][cmdHi][cmdLo]
            FuncTok$ = Chr$(TK_NumericCommand)
            p = p + 1
            If p + 1 > Len(Expression$) Then Print "Error: numeric command truncated": System
            FuncTok$ = FuncTok$ + Mid$(Expression$, p, 2)
            p = p + 2 ' now p points to the next token after cmdHi/cmdLo

            ' Decode cmd16 so we can special-case VARPTR()
            cmd16 = Asc(Mid$(FuncTok$, 2, 1)) * 256 + Asc(Mid$(FuncTok$, 3, 1))

            ' If followed by "(" then this is a function call: emit at ")"
            If p + 1 <= Len(Expression$) Then
                If Asc(Mid$(Expression$, p, 1)) = TK_SpecialChar And Asc(Mid$(Expression$, p + 1, 1)) = &H28 Then

                    ' ---- VARPTR() wants ADDRESS of its argument (array elem addr, var addr) ----
                    If cmd16 = VARPTR_CMD Then VarptrDepth% = VarptrDepth% + 1' :WantAddress% = -1:
                    ' Push '(' onto operator stack
                    RPNStackPointer = RPNStackPointer + 1
                    RPNStack(RPNStackPointer) = &H28

                    ' Paren metadata: mark as NUMERIC-function call
                    ParenSP = ParenSP + 1
                    ParenIsArray(ParenSP) = PAREN_NUMFUNC
                    ParenArgCount(ParenSP) = 1
                    ParenInnerDepth(ParenSP) = 0
                    ParenFuncTok$(ParenSP) = FuncTok$

                    ' If nested inside another arg-list (array or function):
                    If ParenSP > 0 Then
                        If ParenIsArray(ParenSP - 1) <> 0 Then
                            ParenInnerDepth(ParenSP - 1) = ParenInnerDepth(ParenSP - 1) + 1
                        End If
                    End If

                    p = p + 2 ' skip F5 28
                    ExpectValue = -1 ' expecting first argument expression

                Else
                    ' Not followed by "(": keep old behavior (emit immediately)
                    Emit$ = FuncTok$: GoSub RPN_Emit
                    ExpectValue = 0
                End If
            Else
                ' End of expression: emit immediately
                Emit$ = FuncTok$: GoSub RPN_Emit
                ExpectValue = 0
            End If

        Case TK_GeneralCommand
            Print "Error: General command in expression on";: GoTo FoundError
            ' ====================================================
            ' LITERAL NUMBERS (ASCII digits/decimal point)
            ' ====================================================
        Case Else
            Lit$ = ""
            While p <= Len(Expression$)
                v = Asc(Mid$(Expression$, p, 1))
                If (v > &H2F And v < &H3A) Or v = &H2E Then
                    Lit$ = Lit$ + Chr$(v)
                    p = p + 1
                Else
                    Exit While
                End If
            Wend

            If Lit$ = "" Then
                Print "Error: unexpected token in expression at position"; p
                System
            End If

            ConvertVal$ = Lit$
            GoSub ConvertLitNumber
            Emit$ = ConvertedNum$ + Chr$(ManualType): GoSub RPN_Emit
            ExpectValue = 0
    End Select
Wend

If RPNLast < 0 Then
    Print "Error: empty expression"
    System
End If

DoneRPN:
' Now pop remaining operators off the stack
While RPNStackPointer >= 0
    topOp = RPNStack(RPNStackPointer)
    If topOp = &H28 Then
        Print "Error: missing a close bracket in the expression on";: GoTo FoundError
    End If
    Emit$ = Chr$(TK_OperatorCommand) + Chr$(topOp): GoSub RPN_Emit
    RPNStackPointer = RPNStackPointer - 1
Wend
Return


' To process the RPN:
' Variables get pushed on the stack
' Literal numbers are pushed on the stack
' When we come across an operator we normally pull right then left (might change this since my code handles (Value 1 + Value 2 as Value2 @ ,S & Value1 @ 2,S
' Push the result on the stack
' If we get a comparison (=, <=,<>) then we pull left then right and compare them
' Push the boolean (0=false, $ff (-1)=true) on the stack
' When we get a NEG, we pull the last value and make it negative
' Push the negative value on the stack

ProcessRPN:
Dim ArgCnt As Integer
Dim cmd16 As Integer
Dim DimI As Integer
Dim ArrTok As String
Dim ArrNum As Integer
Dim ElemType As Integer
Dim IndexTok$(1 To 8) ' adjust if you want more than 8 dims

' NEW: logic counters
Dim TotalANDs As Integer, TotalORs As Integer
Dim RemainingANDs As Integer, RemainingORs As Integer

RPNEntry = 0
ProcessRPNStackPointer = -1

' --- Track logical structure for the current expression ---
' --- Track logical structure for the current expression ---
HasAnd% = 0
HasOr% = 0
UsedANDShortCircuit% = 0
UsedORShortCircuit% = 0

HasAndOverall% = 0
HasOrOverall% = 0

' --- Detect simple "one comparison only" and global AND/OR presence ---
SimpleIFCompareMode% = 0
LastCompareIndex% = -1

If InIFCondition% <> 0 Then
    Dim CompareCount As Integer
    Dim LogicCount As Integer
    Dim op As Integer

    CompareCount = 0
    LogicCount = 0

    For iScan = 0 To RPNLast
        i$ = RPNOutput$(iScan)
        If Len(i$) >= 2 Then
            If Asc(i$) = TK_OperatorCommand Then
                op = Asc(Mid$(i$, 2, 1))
                Select Case op
                    Case OP_EQ, OP_NE, OP_LT, OP_GT, OP_LE, OP_GE
                        CompareCount = CompareCount + 1
                        LastCompareIndex% = iScan

                    Case OP_AND
                        LogicCount = LogicCount + 1
                        HasAndOverall% = -1

                    Case OP_OR
                        LogicCount = LogicCount + 1
                        HasOrOverall% = -1

                    Case OP_XOR, OP_NOT
                        LogicCount = LogicCount + 1
                End Select
            End If
        End If
    Next iScan

    ' Simple IF we can optimize:
    '   - exactly one comparison operator
    '   - no AND/OR/NOT/XOR
    If CompareCount = 1 And LogicCount = 0 Then
        SimpleIFCompareMode% = -1
    End If
End If

' Remaining counts start as totals
RemainingANDs = TotalANDs
RemainingORs = TotalORs

While RPNEntry <= RPNLast
    i$ = RPNOutput$(RPNEntry)
    p = 1
    check = Asc(Mid$(i$, p, 1))
    p = p + 1
    Select Case check
        Case TK_NumericArray
            'Different variables will go directly on the new stack
            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
            ProcessRPNStack$(ProcessRPNStackPointer) = i$
        Case TK_StrArray
            'Different variables will go directly on the new stack
            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
            ProcessRPNStack$(ProcessRPNStackPointer) = i$
        Case TK_NumericVar
            'Different variables will go directly on the new stack
            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
            ProcessRPNStack$(ProcessRPNStackPointer) = i$
        Case TK_StringVar
            'Different variables will go directly on the new stack
            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
            ProcessRPNStack$(ProcessRPNStackPointer) = i$
        Case TK_DEFFunction
            'Different variables will go directly on the new stack
            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
            ProcessRPNStack$(ProcessRPNStackPointer) = i$
        Case TK_SpecialChar
            ' If this special-char token is a QUOTED STRING literal:  F5 22 ... F5 22
            If Len(i$) >= 4 Then
                If Asc(Mid$(i$, 2, 1)) = TK_Quote Then
                    ' Strip the leading F5 22 and trailing F5 22
                    Temp$ = Mid$(i$, 3, Len(i$) - 4) ' raw string contents (can be "")

                    ' Code to push this literal string onto the 6809 string stack
                    ' Stack will have the first byte = string length then the string
                    A$ = "BSR": B$ = "@CopyToStack": C$ = "Skip ahead": GoSub AO
                    For ii = Len(Temp$) To 1 Step -1
                        A$ = "FCB": B$ = "$" + Right$("0" + Hex$(Asc(Mid$(Temp$, ii, 1))), 2): C$ = Mid$(Temp$, ii, 1): GoSub AO
                    Next ii
                    A$ = "FCB": B$ = "$" + Right$("0" + Hex$(Len(Temp$)), 2): C$ = "Length of the string": GoSub AO
                    Z$ = "@CopyToStack": GoSub AO
                    A$ = "LDB": B$ = "#$" + Right$("0" + Hex$(Len(Temp$) + 1), 2): C$ = "Length of the string": GoSub AO
                    A$ = "PULS": B$ = "U": GoSub AO
                    Z$ = "!": A$ = "LDA": B$ = ",U+": GoSub AO
                    A$ = "STA": B$ = ",-S": GoSub AO
                    A$ = "DECB": GoSub AO
                    A$ = "BNE": B$ = "<": GoSub AO
                    Print #1, ""

                    ' Push "string already on 6809 stack" marker (so + concat and final result work)
                    ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                    ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)

                    GoTo SpecialCharDone
                End If
            End If

            ' Normal special char: keep old behavior
            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
            ProcessRPNStack$(ProcessRPNStackPointer) = i$
            SpecialCharDone:
        Case TK_OperatorCommand
            ' Deal with operators
            v = Asc(Mid$(i$, p, 1))
            Select Case v
                Case OP_PLUS ' +
                    If ProcessRPNStackPointer < 1 Then
                        Print "Error: '+' missing operands on";: GoTo FoundError
                    End If

                    Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                    Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)

                    ' Detect if either operand is string-ish
                    Temp$ = Value1$: GoSub IsStringToken: IsStrLeft% = IsStrFlag%
                    Temp$ = Value2$: GoSub IsStringToken: IsStrRight% = IsStrFlag%

                    If (IsStrLeft% Or IsStrRight%) Then
                        ' --- STRING CONCAT PATH ---
                        ' Pop two -> push one
                        ProcessRPNStackPointer = ProcessRPNStackPointer - 1

                        ' Push left then right (so right ends up at ,S)
                        Temp$ = Value1$: GoSub PushOneAnyTokenAsStringOnStack
                        Temp$ = Value2$: GoSub PushOneAnyTokenAsStringOnStack

                        ' Concat stub: consumes 2 strings, pushes result string
                        A$ = "JSR": B$ = "StrConcat2": C$ = "Stub: string concat; pushes string result": GoSub AO

                        ' Mark result as "string already on 6809 stack"
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)
                        GoTo PLUS_Done
                    End If

                    ' --- NUMERIC PATH (your original OP_PLUS code) ---
                    ' (leave everything you already had here exactly as-is)
                    If ProcessRPNStackPointer > 0 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)
                        LeftType = Asc(Right$(Value1$, 1))
                        RightType = Asc(Right$(Value2$, 1))
                        If RightType + LeftType > 255 Then
                            Num = Val(Left$(Value1$, Len(Value1$) - 1)) + Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString
                            If RightType > LeftType Then
                                resultType = RightType
                            Else
                                resultType = LeftType
                            End If
                            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(resultType)
                        Else
                            GoSub PutValuesOnStack
                            GoSub NumFunctionAdd
                            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                        End If
                    Else
                        GoSub PutValuesOnStack
                        GoSub NumFunctionAdd
                        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                    End If
                    PLUS_Done:
                Case OP_MINUS ' - (binary minus)
                    If ProcessRPNStackPointer > 0 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)
                        LeftType = Asc(Right$(Value1$, 1))
                        RightType = Asc(Right$(Value2$, 1))
                        If RightType + LeftType > 255 Then
                            ' Both are literal, Subtract the literal values and push the result to the stack
                            Num = Val(Left$(Value1$, Len(Value1$) - 1)) - Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            If RightType > LeftType Then
                                resultType = RightType
                            Else
                                resultType = LeftType
                            End If
                            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(resultType)
                        Else
                            GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                            GoSub NumFunctionSubtract
                            ' Result is on the 6809 stack, flag it here
                            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                        End If
                    Else
                        GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                        GoSub NumFunctionSubtract
                        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                    End If
                Case OP_MULTIPLY ' *
                    If ProcessRPNStackPointer > 0 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)
                        LeftType = Asc(Right$(Value1$, 1))
                        RightType = Asc(Right$(Value2$, 1))
                        If RightType + LeftType > 255 Then
                            ' Both are literal, Multiply the literal values and push the result to the stack
                            Num = Val(Left$(Value1$, Len(Value1$) - 1)) * Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            If RightType > LeftType Then
                                resultType = RightType
                            Else
                                resultType = LeftType
                            End If
                            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(resultType)
                        Else
                            GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value2 Type & RightType=Value1 Type, Setup LargestType
                            GoSub NumFunctionMultiply
                            ' Result is on the 6809 stack, flag it here
                            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                        End If
                    Else
                        GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                        GoSub NumFunctionMultiply
                        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                    End If
                Case OP_DIVIDE ' /
                    If ProcessRPNStackPointer > 0 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)
                        LeftType = Asc(Right$(Value1$, 1))
                        RightType = Asc(Right$(Value2$, 1))
                        If RightType + LeftType > 255 Then
                            ' Both are literal, Divide the literal values and push the result to the stack
                            Num = Val(Left$(Value1$, Len(Value1$) - 1)) / Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            If RightType > LeftType Then
                                resultType = RightType
                            Else
                                resultType = LeftType
                            End If
                            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(resultType)
                        Else
                            GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                            GoSub NumFunctionDivide
                            ' Result is on the 6809 stack, flag it here
                            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                        End If
                    Else
                        GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                        GoSub NumFunctionDivide
                        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                    End If

                    ' Comparisons
                Case OP_EQ, OP_NE, OP_LT, OP_GT, OP_LE, OP_GE
                    CompareOp = v
                    GoSub DoCompareDispatch
                Case OP_NEG ' NEG
                    If ProcessRPNStackPointer > -1 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        LeftType = Asc(Right$(Value2$, 1))
                        If LeftType > 127 Then
                            ' Negate the literal, and push the result to the stack
                            Num = -Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            If Num < 0 And (LeftType And 1) = 0 Then
                                ' Make it a signed value type
                                LeftType = LeftType - 1 ' make it the signed version
                            End If
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(LeftType)
                        Else
                            GoSub PutValue2OnStack ' Put Value2 on the stack LeftType=Value2 Type
                            GoSub NumFunctionNEG
                            ' Result is on the 6809 stack, flag it here
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LeftType)
                        End If
                    Else
                        GoSub PutValue2OnStack ' Put Value2 on the stack LeftType=Value2 Type
                        GoSub NumFunctionNEG
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LeftType)
                    End If
                Case OP_BACKSLASH ' \
                    If ProcessRPNStackPointer > 0 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)
                        LeftType = Asc(Right$(Value1$, 1))
                        RightType = Asc(Right$(Value2$, 1))
                        If RightType + LeftType > 255 Then
                            ' Both are literal, Divide the literal values and push the result to the stack
                            Num = Val(Left$(Value1$, Len(Value1$) - 1)) / Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            If RightType > LeftType Then
                                resultType = RightType
                            Else
                                resultType = LeftType
                            End If
                            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(resultType)
                        Else
                            GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                            GoSub NumFunctionIntDiv
                            ' Result is on the 6809 stack, flag it here
                            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                        End If
                    Else
                        GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                        GoSub NumFunctionIntDiv
                        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                    End If
                Case OP_MOD ' MOD
                    If ProcessRPNStackPointer > 0 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)
                        LeftType = Asc(Right$(Value1$, 1))
                        RightType = Asc(Right$(Value2$, 1))
                        If RightType + LeftType > 255 Then
                            ' Both are literal, Divide the literal values and push the result to the stack
                            Num = Val(Left$(Value1$, Len(Value1$) - 1)) MOD Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            If RightType > LeftType Then
                                resultType = RightType
                            Else
                                resultType = LeftType
                            End If
                            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(resultType)
                        Else
                            GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                            GoSub NumFunctionMod
                            ' Result is on the 6809 stack, flag it here
                            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                        End If
                    Else
                        GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                        GoSub NumFunctionMod
                        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                    End If
                Case OP_DIVR ' Div with rounding
                    GoSub NumFunctionDivr
                Case OP_EXPONENT ' ^
                    If ProcessRPNStackPointer > 0 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)
                        LeftType = Asc(Right$(Value1$, 1))
                        RightType = Asc(Right$(Value2$, 1))
                        If RightType + LeftType > 255 Then
                            ' Both are literal, Do Exponent function on the literal values and push the result to the stack
                            Num = Val(Left$(Value1$, Len(Value1$) - 1)) ^ Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            If RightType > LeftType Then
                                resultType = RightType
                            Else
                                resultType = LeftType
                            End If
                            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(resultType)
                        Else
                            GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                            GoSub NumFunctionExponent
                            ' Result is on the 6809 stack, flag it here
                            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                        End If
                    Else
                        GoSub PutValuesOnStack ' Put Value1 & Value2 on the stack LeftType=Value1 Type & RightType=Value2 Type, Set LargestType
                        GoSub NumFunctionExponent
                        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                    End If

                    ' bitwise functions AND/OR
                Case OP_AND ' AND
                    HasAnd% = -1
                    If InIFCondition% <> 0 Then
                        RemainingANDs = RemainingANDs - 1
                    End If

                    If ProcessRPNStackPointer > 0 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)
                        LeftType = Asc(Right$(Value1$, 1))
                        RightType = Asc(Right$(Value2$, 1))
                        If RightType + LeftType > 255 Then
                            ' Both are literal, AND the literal values and push the result to the stack
                            Num = Val(Left$(Value1$, Len(Value1$) - 1)) And Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString
                            If RightType > LeftType Then
                                resultType = RightType
                            Else
                                resultType = LeftType
                            End If
                            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(resultType)
                        Else
                            GoSub PutValuesOnStack
                            GoSub NumFunctionAnd
                            ' Result is on the 6809 stack, flag it here

                            If InIFCondition% <> 0 Then
                                ' Only short-circuit AND if the *whole* IF has no OR at all.
                                If HasOrOverall% = 0 Then
                                    UsedANDShortCircuit% = -1

                                    If IsLastANDInIF%(RPNEntry) = 0 Then
                                        ' --- MIDDLE AND in pure-AND IF ---
                                        A$ = "LDB": B$ = ",S+": C$ = "Pop boolean result for AND": GoSub AO
                                        A$ = "LBEQ": B$ = IFFalseLabel$: C$ = "Short-circuit AND: if FALSE jump to ELSE/END IF": GoSub AO
                                        A$ = "PSHS": B$ = "B": C$ = "Re-push boolean when TRUE so stack is unchanged": GoSub AO
                                    Else
                                        ' --- LAST AND in a pure-AND IF ---
                                        ' Final IF test: FALSE → ELSE/END IF, TRUE → fall through to THEN.
                                        A$ = "LDB": B$ = ",S+": C$ = "Pop final boolean result for AND-only IF": GoSub AO
                                        A$ = "LBEQ": B$ = IFFalseLabel$: C$ = "Final AND test: if FALSE jump to ELSE/END IF": GoSub AO
                                        ' Do NOT re-push; stack is back to its pre-condition height.
                                    End If
                                End If
                            End If

                            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                        End If
                    Else
                        GoSub PutValuesOnStack
                        GoSub NumFunctionAnd

                        If InIFCondition% <> 0 Then
                            ' Only short-circuit AND if the *whole* IF has no OR at all.
                            If HasOrOverall% = 0 Then
                                UsedANDShortCircuit% = -1

                                If IsLastANDInIF%(RPNEntry) = 0 Then
                                    ' --- MIDDLE AND in pure-AND IF ---
                                    A$ = "LDB": B$ = ",S+": C$ = "Pop boolean result for AND": GoSub AO
                                    A$ = "LBEQ": B$ = IFFalseLabel$: C$ = "Short-circuit AND: if FALSE jump to ELSE/END IF": GoSub AO
                                    A$ = "PSHS": B$ = "B": C$ = "Re-push boolean when TRUE so stack is unchanged": GoSub AO
                                Else
                                    ' --- LAST AND in a pure-AND IF ---
                                    ' Final IF test: FALSE → ELSE/END IF, TRUE → fall through to THEN.
                                    A$ = "LDB": B$ = ",S+": C$ = "Pop final boolean result for AND-only IF": GoSub AO
                                    A$ = "LBEQ": B$ = IFFalseLabel$: C$ = "Final AND test: if FALSE jump to ELSE/END IF": GoSub AO
                                    ' Do NOT re-push; stack is back to its pre-condition height.
                                End If
                            End If
                        End If

                        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                    End If

                Case OP_OR ' OR
                    HasOr% = -1
                    If InIFCondition% <> 0 Then
                        RemainingORs = RemainingORs - 1
                    End If

                    If ProcessRPNStackPointer > 0 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)
                        LeftType = Asc(Right$(Value1$, 1))
                        RightType = Asc(Right$(Value2$, 1))
                        If RightType + LeftType > 255 Then
                            ' Both are literal, OR the literal values and push the result to the stack
                            Num = Val(Left$(Value1$, Len(Value1$) - 1)) Or Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString
                            If RightType > LeftType Then
                                resultType = RightType
                            Else
                                resultType = LeftType
                            End If
                            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(resultType)
                        Else
                            GoSub PutValuesOnStack
                            GoSub NumFunctionOr
                            ' Result is on the 6809 stack, flag it here

                            ' --- NEW: short-circuit OR for IF conditions (no LEAS) ---
                            If InIFCondition% <> 0 Then
                                UsedORShortCircuit% = -1

                                If IsLastORInIF%(RPNEntry) = 0 Then
                                    ' --- MIDDLE OR (another OR still to come) ---
                                    A$ = "LDB": B$ = ",S+": C$ = "Pop boolean result for OR": GoSub AO
                                    A$ = "LBNE": B$ = IFTrueLabel$: C$ = "Short-circuit OR: if TRUE jump to THEN": GoSub AO
                                    A$ = "PSHS": B$ = "B": C$ = "Re-push boolean when FALSE so stack is unchanged": GoSub AO
                                Else
                                    ' --- LAST OR in the whole IF expression ---
                                    ' This OR does the final IF test for any expression with OR.
                                    A$ = "LDB": B$ = ",S+": C$ = "Pop final boolean result for OR in IF": GoSub AO
                                    A$ = "LBEQ": B$ = IFFalseLabel$: C$ = "Final OR test: FALSE → ELSE/END IF": GoSub AO
                                    ' If TRUE (non-zero) we just fall through to _IFTrue_xx
                                End If
                            End If

                            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                        End If
                    Else
                        GoSub PutValuesOnStack
                        GoSub NumFunctionOr
                        ' --- NEW: short-circuit OR for IF conditions (no LEAS) ---
                        If InIFCondition% <> 0 Then
                            UsedORShortCircuit% = -1

                            If IsLastORInIF%(RPNEntry) = 0 Then
                                ' --- MIDDLE OR (another OR still to come) ---
                                A$ = "LDB": B$ = ",S+": C$ = "Pop boolean result for OR": GoSub AO
                                A$ = "LBNE": B$ = IFTrueLabel$: C$ = "Short-circuit OR: if TRUE jump to THEN": GoSub AO
                                A$ = "PSHS": B$ = "B": C$ = "Re-push boolean when FALSE so stack is unchanged": GoSub AO
                            Else
                                ' --- LAST OR in the whole IF expression ---
                                ' This OR does the final IF test for any expression with OR.
                                A$ = "LDB": B$ = ",S+": C$ = "Pop final boolean result for OR in IF": GoSub AO
                                A$ = "LBEQ": B$ = IFFalseLabel$: C$ = "Final OR test: FALSE → ELSE/END IF": GoSub AO
                                ' If TRUE (non-zero) we just fall through to _IFTrue_xx
                            End If
                        End If

                        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                    End If
                Case OP_XOR ' XOR
                    If ProcessRPNStackPointer > 0 Then
                        Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
                        Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1)
                        LeftType = Asc(Right$(Value1$, 1))
                        RightType = Asc(Right$(Value2$, 1))
                        If RightType + LeftType > 255 Then
                            ' Both are literal, XOR the literal values and push the result to the stack
                            Num = Val(Left$(Value1$, Len(Value1$) - 1)) XOR Val(Left$(Value2$, Len(Value2$) - 1))
                            GoSub NumAsString
                            If RightType > LeftType Then
                                resultType = RightType
                            Else
                                resultType = LeftType
                            End If
                            ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(resultType)
                        Else
                            GoSub PutValuesOnStack
                            GoSub NumFunctionXor
                            ' Result is on the 6809 stack, flag it here
                            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                            ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                        End If
                    Else
                        GoSub PutValuesOnStack
                        GoSub NumFunctionXor
                        ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                        ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(Largesttype)
                    End If


                                        Case OP_NOT ' NOT (bitwise)
    If ProcessRPNStackPointer < 0 Then
        Print "Error: NOT missing operand on";: GoTo FoundError
    End If

    Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)

    ' Resolve operand type
    Tok$ = Value2$: GoSub GetTokenTypeOnly
    LeftType = TokType

    ' ---- Compile-time fold if literal ----
    t = Asc(Right$(Value2$, 1))
    If t > 128 Then
        baseT = t - 128
        Num = Val(Left$(Value2$, Len(Value2$) - 1))

        Select Case baseT
            Case 1  ' _Bit  (treat as boolean 0/-1)
                If Num = 0 Then Num = -1 Else Num = 0
                GoSub NumAsString
                ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(baseT + 128)
                Largesttype = baseT
                GoTo DoneNOT

            Case 2  ' _Unsigned _Bit (0/1)
                If Num = 0 Then Num = 1 Else Num = 0
                GoSub NumAsString
                ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(baseT + 128)
                Largesttype = baseT
                GoTo DoneNOT

            Case 3, 4 ' 8-bit
                u = (Not (CLng(Num) And &HFF)) And &HFF
                If baseT = 3 And u >= 128 Then u = u - 256
                Num = u
                GoSub NumAsString
                ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(baseT + 128)
                Largesttype = baseT
                GoTo DoneNOT

            Case 5, 6 ' 16-bit
                u = (Not (CLng(Num) And &HFFFF)) And &HFFFF
                If baseT = 5 And u >= 32768 Then u = u - 65536
                Num = u
                GoSub NumAsString
                ProcessRPNStack$(ProcessRPNStackPointer) = Num$ + Chr$(baseT + 128)
                Largesttype = baseT
                GoTo DoneNOT
        End Select
        ' For larger literal widths, fall through to runtime to stay safe.
    End If

    ' ---- Runtime NOT ----
    Tok$ = Value2$: GoSub PushTokenNumeric
    LeftType = TokType

    If LeftType >= 11 Then
        Print "Error: NOT not supported for floating point on";: GoTo FoundError
    End If

    GoSub NumFunctionNot

    ' Replace operand token with "already on 6809 stack" marker
    ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(LeftType)
    Largesttype = LeftType

DoneNOT:







                Case OP_ARRLOAD
                    ' Operator token is: FC 70 argCount
                    ArgCnt = 1
                    If Len(i$) >= 3 Then ArgCnt = Asc(Mid$(i$, 3, 1))
                    If ArgCnt < 1 Then ArgCnt = 1
                    If ArgCnt > 8 Then Print "Error: too many array dims"; ArgCnt: GoTo FoundError

                    ' Stack shape BEFORE:
                    '   [..., ArrayToken, index1, index2, ... indexN]
                    ' where indexN is on top
                    If ProcessRPNStackPointer < ArgCnt Then
                        Print "Error: ARRLOAD missing indices on";: GoTo FoundError
                    End If

                    ' Pop indices (rightmost first)
                    For DimI = ArgCnt To 1 Step -1
                        IndexTok$(DimI) = ProcessRPNStack$(ProcessRPNStackPointer)
                        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                    Next DimI

                    ' Pop array token
                    ArrTok = ProcessRPNStack$(ProcessRPNStackPointer)
                    ProcessRPNStackPointer = ProcessRPNStackPointer - 1

                    If Asc(Left$(ArrTok, 1)) <> TK_NumericArray Then
                        Print "Error: ARRLOAD expected TK_NumericArray on stack on";: GoTo FoundError
                    End If

                    ArrNum = Asc(Mid$(ArrTok, 2, 1)) * 256 + Asc(Mid$(ArrTok, 3, 1))
                    ElemType = Asc(Mid$(ArrTok, 5, 1)) ' F0,MSB,LSB,#Dimensions,Type
                    ' Push indices onto the 6809 stack.
                    ' Convention here: push indices left-to-right (IndexTok(1) then (2) ...).
                    ' Your ArrayLoadElem stub can assume that order.
                    ' Decide index width required for THIS array
                    IdxBits = NumericArrayBits(ArrNum)
                    If IdxBits = 8 Then
                        IdxNVT = NT_UByte ' use 8-bit unsigned indices
                    Else
                        IdxBits = 16
                        IdxNVT = NT_UInt16 ' use 16-bit unsigned indices
                    End If

                    For DimI = 1 To ArgCnt
                        ' Optional compile-time range check for literal indices when using 8-bit
                        If IdxBits = 8 Then
                            tType = Asc(Right$(IndexTok$(DimI), 1))
                            If tType > 128 Then
                                idxVal = Val(Left$(IndexTok$(DimI), Len(IndexTok$(DimI)) - 1))
                                If idxVal < 0 Or idxVal > 255 Then
                                    Print "Error: array index out of range for 8-bit index:"; idxVal
                                    System
                                End If
                            End If
                        End If

                        Temp$ = IndexTok$(DimI)
                        GoSub PushOneValueTokenOnStack
                        LastType = PushedType

                        ' Convert the pushed value to the required index type
                        NVT = IdxNVT
                        GoSub ConvertLastType2NVT
                    Next DimI

                    ' ArrNum = Asc(Mid$(ArrTok, 2, 1)) * 256 + Asc(Mid$(ArrTok, 3, 1))
                    ' ElemType = Asc(Mid$(ArrTok, 5, 1)) ' F0,MSB,LSB,#Dimensions,Type
                    '
                    ' Dim NumericArrayBits(ArrNum) As Integer
                    ' Dim NumericArrayVariables$(ArrNum)
                    ' NumericArrayDimensions(ArrNum) As Integer
                    If NumericArrayDimensions(ArrNum) = 1 And IdxBits = 8 And ElemType < 5 Then
                        ' index is a byte at ,S
                        A$ = "LDB": B$ = ",S": C$ = "Index (8-bit)": GoSub AO
                        A$ = "LDX": B$ = "#_ArrayNum_" + NumericArrayVariables$(ArrNum) + "+1": C$ = "Array data starts here": GoSub AO
                        A$ = "ABX": C$ = "X = base + index": GoSub AO
                        A$ = "LDB": B$ = ",X": C$ = "Load 1-byte element": GoSub AO
                        A$ = "STB": B$ = ",S": C$ = "Replace index with value": GoSub AO
                        LastType = ElemType
                    Else
                        ' A = BytesPerEntry
                        ' B = Number of Array Dimensions
                        ' X = Array starts here (points at the sizes of each dimension)
                        Select Case ElemType
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
                        If NumericArrayDimensions(ArrNum) = 1 Then
                            If NumericArrayBits(ArrNum) = 8 Then
                                ' Handle an array with 8 bit indices
                                Z$ = "; Only 8 bit indices": GoSub AO
                                A$ = "LDA": B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
                                A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
                                A$ = "MUL": C$ = "Multiply them": GoSub AO
                                Num = NumericArrayDimensions(ArrNum): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                                A$ = "ADDD": B$ = "#_ArrayNum_" + NumericArrayVariables$(ArrNum) + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                                A$ = "PSHS": B$ = "D": C$ = "Save the location the array is pointing at on the stack": GoSub AO
                            Else
                                ' Handle an array with 16 bit indices
                                Z$ = "; Only 1 16 bit element array": GoSub AO
                                Z$ = "; d1 is already on the stack": GoSub AO
                                A$ = "LDD": B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
                                A$ = "PSHS": B$ = "D": C$ = "Save BytesPerEntry as 16 bit on the stack": GoSub AO
                                A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
                                A$ = "LDD": B$ = ",S": C$ = "Get the low 16 bit result in D": GoSub AO
                                Num = NumericArrayDimensions(ArrNum) * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                                A$ = "ADDD": B$ = "#_ArrayNum_" + NumericArrayVariables$(ArrNum) + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                                A$ = "STD": B$ = ",S": C$ = "Save the location the array is pointing at": GoSub AO
                            End If
                        Else
                            Num = NumericArrayDimensions(ArrNum) - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A = BytesPerEntry, B = Dim count-1": GoSub AO
                            If NumericArrayBits(ArrNum) = 8 Then
                                ' Handle an array with 8 bit indices
                                Num = NumericArrayDimensions(ArrNum): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                                A$ = "LDU": B$ = "#_ArrayNum_" + NumericArrayVariables$(ArrNum) + "+" + Num$: C$ = "This array data starts here": GoSub AO
                                A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Get the address to load the value and save it on the stack": GoSub AO
                            Else
                                ' Handle an array with 16 bit indices
                                Num = NumericArrayDimensions(ArrNum) * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                                A$ = "LDU": B$ = "#_ArrayNum_" + NumericArrayVariables$(ArrNum) + "+" + Num$: C$ = "This array data starts here": GoSub AO
                                A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Get the address to load the value and save it on the stack": GoSub AO
                            End If
                        End If
                    End If
                    ' Stack now has the memory location of the value
                    If NumericArrayDimensions(ArrNum) = 1 And IdxBits = 8 And ElemType < 5 Then
                        ' This is a quick and easy location to calc and store
                        A$ = "LDB": B$ = "[,S++]": C$ = "Get the byte and fix the stack": GoSub AO
                        A$ = "PSHS": B$ = "B": C$ = "Push array element byte onto the stack": GoSub AO
                    Else
                        ' Calculate Number of bytes needed for this type of number on the stack
                        Select Case ElemType
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
                        A$ = "LDB": B$ = "#" + Num$ + "-1": C$ = "B = Number of bytes to copy to the stack - 1": GoSub AO ' X points at the 2nd array Element size
                        A$ = "PULS": B$ = "U": C$ = "Get address of the array data off the stack, fix the stack": GoSub AO
                        Z$ = "!": A$ = "LDA": B$ = "B,U": C$ = "A = Source byte": GoSub AO
                        A$ = "PSHS": B$ = "A": C$ = "Save byte onto the stack": GoSub AO
                        A$ = "DECB": C$ = "Decrement the counter": GoSub AO
                        A$ = "BPL": B$ = "<": C$ = "Loop": GoSub AO
                    End If

                    ' Mark result as "already on 6809 stack"
                    ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                    ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(ElemType)
                Case OP_ARRPTR
                    ' Operator token is: FC 72 argCount
                    ArgCnt = 1
                    If Len(i$) >= 3 Then ArgCnt = Asc(Mid$(i$, 3, 1))
                    If ArgCnt < 1 Then ArgCnt = 1
                    If ArgCnt > 8 Then Print "Error: too many array dims"; ArgCnt: System

                    If ProcessRPNStackPointer < ArgCnt Then
                        Print "Error: ARRPTR missing indices": System
                    End If

                    ' Pop indices (rightmost first)
                    For DimI = ArgCnt To 1 Step -1
                        IndexTok$(DimI) = ProcessRPNStack$(ProcessRPNStackPointer)
                        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                    Next DimI

                    ' Pop array token
                    ArrTok = ProcessRPNStack$(ProcessRPNStackPointer)
                    ProcessRPNStackPointer = ProcessRPNStackPointer - 1

                    If Asc(Left$(ArrTok, 1)) <> TK_NumericArray Then
                        Print "Error: ARRPTR expected TK_NumericArray on stack": System
                    End If

                    ArrNum = Asc(Mid$(ArrTok, 2, 1)) * 256 + Asc(Mid$(ArrTok, 3, 1))
                    ElemType = Asc(Mid$(ArrTok, 5, 1)) ' F0,MSB,LSB,#Dimensions,Type

                    ' Decide index width
                    IdxBits = NumericArrayBits(ArrNum)
                    If IdxBits = 8 Then
                        IdxNVT = NT_UByte
                    Else
                        IdxBits = 16
                        IdxNVT = NT_UInt16
                    End If

                    ' Push indices left-to-right onto 6809 stack (same as ARRLOAD)
                    For DimI = 1 To ArgCnt
                        Temp$ = IndexTok$(DimI)
                        GoSub PushOneValueTokenOnStack
                        LastType = PushedType
                        NVT = IdxNVT
                        GoSub ConvertLastType2NVT
                    Next DimI

                    ' ---- Compute address of element and leave it as UInt16 on 6809 stack ----

                    If NumericArrayDimensions(ArrNum) = 1 And IdxBits = 8 Then
                        ' index is a byte at ,S -> convert to address and replace index with address
                        A$ = "LDB":  B$ = ",S+": C$ = "B = index (pop it)": GoSub AO
                        A$ = "LDX":  B$ = "#_ArrayNum_" + NumericArrayVariables$(ArrNum) + "+1": C$ = "Base data": GoSub AO
                        A$ = "ABX":  C$ = "X = base + index": GoSub AO
                        A$ = "PSHS": B$ = "X": C$ = "Push element address": GoSub AO
                    Else
                        ' Use your existing address builders (exactly like ARRLOAD does)
                        Select Case ElemType
                            Case Is < 5: Num = 1
                            Case 5, 6:   Num = 2
                            Case 7, 8:   Num = 4
                            Case 9, 10:  Num = 8
                            Case 11:     Num = 3
                            Case 12:     Num = 10
                        End Select
                        GoSub NumAsString: Temp$ = Num$

                        If NumericArrayDimensions(ArrNum) = 1 Then
                            If NumericArrayBits(ArrNum) = 8 Then
                                Z$ = "; Only 8 bit indices": GoSub AO
                                A$ = "LDA":  B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
                                A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
                                A$ = "MUL":  C$ = "D = index*BytesPerEntry": GoSub AO
                                Num = NumericArrayDimensions(ArrNum): GoSub NumAsString
                                A$ = "ADDD": B$ = "#_ArrayNum_" + NumericArrayVariables$(ArrNum) + "+" + Num$: C$ = "Add data start": GoSub AO
                                A$ = "PSHS": B$ = "D": C$ = "Push element address": GoSub AO
                            Else
                                Z$ = "; Only 1 16 bit element array": GoSub AO
                                A$ = "LDD":  B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
                                A$ = "PSHS": B$ = "D": C$ = "Push BytesPerEntry": GoSub AO
                                A$ = "JSR":  B$ = "MUL16": C$ = "index*BytesPerEntry": GoSub AO
                                A$ = "LDD":  B$ = ",S": C$ = "low 16-bit product": GoSub AO
                                Num = NumericArrayDimensions(ArrNum) * 2: GoSub NumAsString
                                A$ = "ADDD": B$ = "#_ArrayNum_" + NumericArrayVariables$(ArrNum) + "+" + Num$: C$ = "Add data start": GoSub AO
                                A$ = "STD": B$ = ",S": C$ = "Save element address": GoSub AO
                            End If
                        Else
                            Num = NumericArrayDimensions(ArrNum) - 1: GoSub NumAsString
                            A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A=BytesPerEntry, B=DimCount-1": GoSub AO
                            If NumericArrayBits(ArrNum) = 8 Then
                                Num = NumericArrayDimensions(ArrNum): GoSub NumAsString
                                A$ = "LDU": B$ = "#_ArrayNum_" + NumericArrayVariables$(ArrNum) + "+" + Num$: C$ = "Data starts": GoSub AO
                                A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Push element address": GoSub AO
                            Else
                                Num = NumericArrayDimensions(ArrNum) * 2: GoSub NumAsString
                                A$ = "LDU": B$ = "#_ArrayNum_" + NumericArrayVariables$(ArrNum) + "+" + Num$: C$ = "Data starts": GoSub AO
                                A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Push element address": GoSub AO
                            End If
                        End If
                    End If
                    ' FB 00 00 NT_UInt16   (meaning: address is already on 6809 stack)
                    ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                    ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(TK_ADDR_ONSTACK) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)
                Case OP_STRARRLOAD
                    ' Token is: FC 71 argCount
                    ArgCnt = 1
                    If Len(i$) >= 3 Then ArgCnt = Asc(Mid$(i$, 3, 1))
                    If ArgCnt < 1 Then ArgCnt = 1
                    If ArgCnt > 8 Then Print "Error: too many string array dims"; ArgCnt: System

                    ' Pop indices (rightmost first)
                    If ProcessRPNStackPointer < ArgCnt Then
                        Print "Error: STRARRLOAD missing indices on";: GoTo FoundError
                    End If

                    For DimI = ArgCnt To 1 Step -1
                        IndexTok$(DimI) = ProcessRPNStack$(ProcessRPNStackPointer)
                        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                    Next DimI

                    ' Pop array token
                    ArrTok = ProcessRPNStack$(ProcessRPNStackPointer)
                    ProcessRPNStackPointer = ProcessRPNStackPointer - 1

                    If Asc(Left$(ArrTok, 1)) <> TK_StrArray Then
                        Print "Error: STRARRLOAD expected TK_StrArray on stack on";: GoTo FoundError
                    End If
                    ArrNum = Asc(Mid$(ArrTok, 2, 1)) * 256 + Asc(Mid$(ArrTok, 3, 1))
                    ' Push indices onto the 6809 stack.
                    ' Convention here: push indices left-to-right (IndexTok(1) then (2) ...).
                    ' Your ArrayLoadElem stub can assume that order.
                    ' Decide index width required for THIS array
                    z$="; ArrayNum=$"+hex$(ArrNum):gosub ao
                    IdxBits = StringArrayBits(ArrNum)
                    If IdxBits = 8 Then
                        IdxNVT = NT_UByte ' use 8-bit unsigned indices
                    Else
                        IdxBits = 16
                        IdxNVT = NT_UInt16 ' use 16-bit unsigned indices
                    End If
                    For DimI = 1 To ArgCnt
                        ' Optional compile-time range check for literal indices when using 8-bit
                        If IdxBits = 8 Then
                            tType = Asc(Right$(IndexTok$(DimI), 1))
                            If tType > 128 Then
                                idxVal = Val(Left$(IndexTok$(DimI), Len(IndexTok$(DimI)) - 1))
                                If idxVal < 0 Or idxVal > 255 Then
                                    Print "Error: array index out of range for 8-bit index:"; idxVal
                                    System
                                End If
                            End If
                        End If
                        Temp$ = IndexTok$(DimI)
                        GoSub PushOneValueTokenOnStack
                        LastType = PushedType

                        ' Convert the pushed value to the required index type
                        NVT = IdxNVT
                        GoSub ConvertLastType2NVT
                    Next DimI
                    ' Call stub that consumes indices and pushes a STRING result
                    Num = StringArraySize + 1 ' Length of each string +1 for the first byte which is the length of the particular string, when stored
                    GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    Temp$ = Num$
                    If StringArrayDimensions(ArrNum) = 1 Then
                        If StringArrayBits(ArrNum) = 8 Then
                            ' Handle an array with 8 bit indices
                            Z$ = "; Only 8 bit indices": GoSub AO
                            A$ = "LDA": B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
                            A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
                            A$ = "MUL": C$ = "Multiply them": GoSub AO
                            Num = StringArrayDimensions(ArrNum): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        Else
                            ' Handle an array with 16 bit indices
                            Z$ = "; Only 1 16 bit element array": GoSub AO
                            Z$ = "; d1 is already on the stack": GoSub AO
                            A$ = "LDD": B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
                            A$ = "PSHS": B$ = "D": C$ = "Save BytesPerEntry as 16 bit on the stack": GoSub AO
                            A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
                            A$ = "PULS": B$ = "D": C$ = "Get the low 16 bit result in D, fix the stack": GoSub AO
                            Num = StringArrayDimensions(ArrNum) * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        End If
                        A$ = "ADDD": B$ = "#_ArrayStr_" + StringArrayVariables$(ArrNum) + "+" + Num$: C$ = "Add the array data start location": GoSub AO
                        A$ = "TFR": B$ = "D,X": C$ = "X = The location the array is pointing at on the stack": GoSub AO
                        A$ = "LDB": B$ = ",X+": C$ = "Get the size of the source string, X now points at the beginning of the source string": GoSub AO
                        A$ = "ABX": C$ = "Point at the end of the string": GoSub AO
                        A$ = "INCB": C$ = "Add one to the length so we copy the actual length byte": GoSub AO
                        Z$ = "!": A$ = "LDA": B$ = ",-X": C$ = "Get a source byte": GoSub AO
                        A$ = "PSHS": B$ = "A": C$ = "Write the destination byte": GoSub AO
                        A$ = "DECB": C$ = "Decrement the counter": GoSub AO
                        A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
                        Z$ = "Done@": GoSub AO
                        Print #1, "" ' Leave a space between sections so Done@ will work for each section
                    Else
                        Num = StringArrayDimensions(ArrNum) - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A = BytesPerEntry, B = Dim count-1": GoSub AO
                        If StringArrayBits(ArrNum) = 8 Then
                            ' Handle an array with 8 bit values
                            Num = StringArrayDimensions(ArrNum): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            A$ = "LDU": B$ = "#_ArrayStr_" + StringArrayVariables$(ArrNum) + "+" + Num$: C$ = "This array data starts here": GoSub AO
                            A$ = "JSR": B$ = "StrArrayLoadElem8bit": C$ = "Store the string on the stack": GoSub AO
                        Else
                            ' Handle an array with 16 bit values
                            Num = StringArrayDimensions(ArrNum) * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            A$ = "LDU": B$ = "#_ArrayStr_" + StringArrayVariables$(ArrNum) + "+" + Num$: C$ = "This array data starts here": GoSub AO
                            A$ = "JSR": B$ = "StrArrayLoadElem16bit": C$ = "Store the string on the stack": GoSub AO
                        End If
                    End If
                    ' Mark result on ProcessRPN stack.
                    ' IMPORTANT: your numeric code uses &HFA marker. For strings you should use a different marker.
                    ' We'll use &HF9 as "string result already on stack" (pick any free byte you like).
                    ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                    ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HF9)

                Case OP_STRARRPTR
                    ' Token is: FC 73 argCount
                    ArgCnt = 1
                    If Len(i$) >= 3 Then ArgCnt = Asc(Mid$(i$, 3, 1))
                    If ArgCnt < 1 Then ArgCnt = 1
                    If ArgCnt > 8 Then Print "Error: too many string array dims"; ArgCnt: System

                    If ProcessRPNStackPointer < ArgCnt Then
                        Print "Error: STRARRPTR missing indices": System
                    End If

                    For DimI = ArgCnt To 1 Step -1
                        IndexTok$(DimI) = ProcessRPNStack$(ProcessRPNStackPointer)
                        ProcessRPNStackPointer = ProcessRPNStackPointer - 1
                    Next DimI

                    ArrTok = ProcessRPNStack$(ProcessRPNStackPointer)
                    ProcessRPNStackPointer = ProcessRPNStackPointer - 1

                    If Asc(Left$(ArrTok, 1)) <> TK_StrArray Then
                        Print "Error: STRARRPTR expected TK_StrArray on stack": System
                    End If

                    ArrNum = Asc(Mid$(ArrTok, 2, 1)) * 256 + Asc(Mid$(ArrTok, 3, 1))

                    IdxBits = StringArrayBits(ArrNum)
                    If IdxBits = 8 Then
                        IdxNVT = NT_UByte
                    Else
                        IdxBits = 16
                        IdxNVT = NT_UInt16
                    End If

                    For DimI = 1 To ArgCnt
                        Temp$ = IndexTok$(DimI)
                        GoSub PushOneValueTokenOnStack
                        LastType = PushedType
                        NVT = IdxNVT
                        GoSub ConvertLastType2NVT
                    Next DimI

                    ' BytesPerEntry for string storage
                    Num = StringArraySize + 1
                    GoSub NumAsString: Temp$ = Num$

                    If StringArrayDimensions(ArrNum) = 1 Then
                        If StringArrayBits(ArrNum) = 8 Then
                            A$ = "LDA":  B$ = "#" + Temp$: C$ = "A=BytesPerEntry": GoSub AO
                            A$ = "PULS": B$ = "B": C$ = "index (8-bit)": GoSub AO
                            A$ = "MUL":  C$ = "D=index*BytesPerEntry": GoSub AO
                            Num = StringArrayDimensions(ArrNum): GoSub NumAsString
                        Else
                            A$ = "LDD":  B$ = "#" + Temp$: C$ = "D=BytesPerEntry": GoSub AO
                            A$ = "PSHS": B$ = "D": C$ = "Push BytesPerEntry": GoSub AO
                            A$ = "JSR":  B$ = "MUL16": C$ = "index*BytesPerEntry": GoSub AO
                            A$ = "PULS":  B$ = "D": C$ = "low 16-bit product, fix the stack": GoSub AO
                            Num = StringArrayDimensions(ArrNum) * 2: GoSub NumAsString
                        End If
                        A$ = "ADDD": B$ = "#_ArrayStr_" + StringArrayVariables$(ArrNum) + "+" + Num$: C$ = "Add data start": GoSub AO
                        A$ = "PSHS": B$ = "D": C$ = "Push element address": GoSub AO
                    Else
                        Num = StringArrayDimensions(ArrNum) - 1: GoSub NumAsString
                        A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A=BytesPerEntry, B=DimCount-1": GoSub AO
                        If StringArrayBits(ArrNum) = 8 Then
                            Num = StringArrayDimensions(ArrNum): GoSub NumAsString
                            A$ = "LDU": B$ = "#_ArrayStr_" + StringArrayVariables$(ArrNum) + "+" + Num$: C$ = "Data starts": GoSub AO
                            A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Push element address": GoSub AO
                        Else
                            Num = StringArrayDimensions(ArrNum) * 2: GoSub NumAsString
                            A$ = "LDU": B$ = "#_ArrayStr_" + StringArrayVariables$(ArrNum) + "+" + Num$: C$ = "Data starts": GoSub AO
                            A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Push element address": GoSub AO
                        End If
                    End If
                    ' FB 00 00 NT_UInt16   (meaning: address is already on 6809 stack)
                    ProcessRPNStackPointer = ProcessRPNStackPointer + 1
                    ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(TK_ADDR_ONSTACK) + Chr$(0) + Chr$(0) + Chr$(NT_UInt16)

                Case Else
                    Print "Unhandled op in debug evaluator: "; Hex$(v)
                    System
            End Select
        Case TK_StringCommand
            GoSub DoStringCommand ' This will pull values off the ProcessRPNStack$(ProcessRPNStackPointer) and lower ProcessRPNStackPointer for each pull off the stack
        Case TK_NumericCommand
            GoSub DoNumericCommand ' This will pull values off the ProcessRPNStack$(ProcessRPNStackPointer) and lower ProcessRPNStackPointer for each pull off the stack
            ' ====================================================
            ' LITERAL NUMBERS (ASCII digits/decimal point)
            ' ====================================================
        Case Else
            ProcessRPNStackPointer = ProcessRPNStackPointer + 1
            ProcessRPNStack$(ProcessRPNStackPointer) = i$
    End Select
    RPNEntry = RPNEntry + 1
Wend
' Final result might be on the stack
If ProcessRPNStackPointer > -1 Then
    ' value on the RPN stack needs to go on the 6809 stack
    Value1$ = ProcessRPNStack$(ProcessRPNStackPointer)
    If Left$(Value1$, 1) = Chr$(&HFA) Then
        ' value is already on the stack
        LastType = Asc(Right$(Value1$, 1))
        Return
    End If
    If Left$(Value1$, 1) = Chr$(&HF9) Then
        ' string result already produced by StrArrayLoadElem
        LastType = 13 ' or whatever you use to mean "string"
        Return
    End If

    ' --- NEW: handle string tokens (A$, string arrays, quoted literals, etc.) ---
    Temp$ = Value1$: GoSub IsStringToken
    If IsStrFlag% Then
        Temp$ = Value1$: GoSub PushOneAnyTokenAsStringOnStack
        LastType = 13
        Return
    End If

    RightType = Asc(Right$(Value1$, 1))
    If RightType = 0 Then RightType = Asc(Mid$(Value1$, 4, 1))
    If RightType = 0 Then
        If Len(Value1$) >= 4 Then RightType = Asc(Mid$(Value1$, 4, 1)) ' use the assigned value
    End If

    'v = Asc(Mid$(Value1$, 2, 1)) * 256 + Asc(Mid$(Value1$, 3, 1))
    'NV$ = "_Var_" + NumericVariable$(v)
    'NVT = RightType ' NVT=Numeric Variable Type

    ' Value1
    If RightType > 128 Then
        ' We have a literal type to put on the stack
        NumberType = RightType - 128
        Num = Val(Left$(Value1$, Len(Value1$) - 1))
        GoSub LiteralOnStack ' Copy a literal number on the stack, NumberType=Numerical Type (Format), Num = the number value
        RightType = RightType - 128
    Else ' Regular number variable
        NumVarNumber = Asc(Mid$(Value1$, 2, 1)) * 256 + Asc(Mid$(Value1$, 3, 1))
        NumberType = Asc(Mid$(Value1$, Len(Value1$) - 1, 1))
        GoSub PutVarOnStack 'Put NumVarNumber on the stack where NumVarNumber = Numeric Variable Number with NumberType = Type of number
        If Asc(Mid$(Value1$, Len(Value1$), 1)) <> 0 Then
            LastType = Asc(Mid$(Value1$, Len(Value1$) - 1, 1))
            NVT = Asc(Right$(Value1$, 1))
            ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
            GoSub ConvertLastType2NVT
        End If
    End If
    LastType = RightType
End If
Return

GenCompareAndBranchFalse:
' Uses (already set by DoCompareDispatch):
'   Value1$ = left operand token
'   Value2$ = right operand token
'   LeftType, RightType = resolved numeric types (for signed/unsigned choice)
'   CompareOp           = OP_EQ / OP_NE / OP_LT / OP_GT / OP_LE / OP_GE
'
' IMPORTANT:
'   - Do NOT read ProcessRPNStack$ here.
'   - Do NOT change ProcessRPNStackPointer here.
'   - Do NOT push operands on the 6809 stack here.
'     DoCompareDispatch must have already put the operands on the 6809 stack
'     in the format your compare logic expects.
'
Z$ = "; *** Doing CompareOp": GoSub AO
Select Case CompareOp
    Case OP_EQ ' true on BEQ, so FALSE is BNE
        GoSub NumFunctionNotEqual
        A$ = "LDA": B$ = ",S+": C$ = "get result off stack, fix stack": GoSub AO
        A$ = "LBNE": B$ = IFFalseLabel$: C$ = "IF Not Equal then jump": GoSub AO
    Case OP_NE ' true on BNE, so FALSE is BEQ
        GoSub NumFunctionEqual
        A$ = "LDA": B$ = ",S+": C$ = "get result off stack, fix stack": GoSub AO
        A$ = "LBNE": B$ = IFFalseLabel$: C$ = "IF Not Equal then jump": GoSub AO
    Case OP_LT ' true on BLT, FALSE on BGE
        GoSub NumFunctionGreaterOrEqual
        A$ = "LDA": B$ = ",S+": C$ = "get result off stack, fix stack": GoSub AO
        A$ = "LBNE": B$ = IFFalseLabel$: C$ = "IF Not Equal then jump": GoSub AO
    Case OP_GT ' true on BGT, FALSE on BLE
        GoSub NumFunctionLessOrEqual
        A$ = "LDA": B$ = ",S+": C$ = "get result off stack, fix stack": GoSub AO
        A$ = "LBNE": B$ = IFFalseLabel$: C$ = "IF Not Equal then jump": GoSub AO
    Case OP_LE ' true on BLE, FALSE on BGT
        GoSub NumFunctionGreaterThan
        A$ = "LDA": B$ = ",S+": C$ = "get result off stack, fix stack": GoSub AO
        A$ = "LBNE": B$ = IFFalseLabel$: C$ = "IF Not Equal then jump": GoSub AO
    Case OP_GE ' true on BGE, FALSE on BLT
        GoSub NumFunctionLessThan
        A$ = "LDA": B$ = ",S+": C$ = "get result off stack, fix stack": GoSub AO
        A$ = "LBNE": B$ = IFFalseLabel$: C$ = "IF Not Equal then jump": GoSub AO
End Select

' Pop 2 operands from ProcessRPNStack and DO NOT push a result
ProcessRPNStackPointer = ProcessRPNStackPointer - 2

' We did not leave a result on the expression stack; LastDataTypeSize is irrelevant here.
LastDataTypeSize = 0

Return
' ------------------------------------------------------------
' DoCompareDispatch
' Enter:
'   CompareOp = one of OP_EQ, OP_NE, OP_LT, OP_GT, OP_LE, OP_GE
' Uses:
'   top two tokens on ProcessRPNStack$
' Exit:
'   - Normal expression, or IF with AND/OR:
'       consumes 2 tokens from ProcessRPNStack$
'       pushes 1 boolean marker: Chr$(&HFA)+0+0+3
'       leaves boolean (0 or $FF) on 6809 stack
'   - Simple IF optimisation (one compare, no AND/OR):
'       consumes 2 tokens from ProcessRPNStack$
'       emits compare + branch via GenCompareAndBranchFalse
'       does NOT push a boolean marker/result
'       sets IFBranchAlreadyEmitted% = -1
' ------------------------------------------------------------
DoCompareDispatch:

' Need at least 2 operands on the RPN stack
If ProcessRPNStackPointer < 1 Then
    Print "Error: compare op missing operands"
    System
End If

' Peek operands (do NOT pop yet – we want the same pattern as +,-,*,/)
Value2$ = ProcessRPNStack$(ProcessRPNStackPointer) ' RHS
Value1$ = ProcessRPNStack$(ProcessRPNStackPointer - 1) ' LHS

' ========================================================
' 1) STRING COMPARE PATH
' ========================================================
Temp$ = Value1$: GoSub IsStringToken: IsStrLeft% = IsStrFlag%
Temp$ = Value2$: GoSub IsStringToken: IsStrRight% = IsStrFlag%

If (IsStrLeft% Or IsStrRight%) Then
    ' Mixed string / numeric is not allowed
    If (IsStrLeft% = 0) Or (IsStrRight% = 0) Then
        Print "Error: Type mismatch in compare (string vs numeric)"
        System
    End If

    ' Push RHS then LHS as strings so LHS ends up at ,S
    Temp$ = Value2$: GoSub PushOneStringTokenOnStack
    Temp$ = Value1$: GoSub PushOneStringTokenOnStack

    ' String compare on the 6809 stack:
    '   JSR StrCompare
    '   A = -1, 0, +1   (result)
    '   B = $FF (always)
    A$ = "JSR": B$ = "StrCompare": C$ = "Compare strings on stack, A = -1/0/+1, B=$FF": GoSub AO

    ' Convert A to 0 / $FF in B depending on CompareOp
    Select Case CompareOp
        Case OP_EQ
            A$ = "BEQ": B$ = ">": C$ = "If zero then equal": GoSub AO
            A$ = "CLRB": C$ = "Flag as false": GoSub AO
            Z$ = "!": GoSub AO

        Case OP_NE
            A$ = "BNE": B$ = ">": C$ = "If non-zero then not equal": GoSub AO
            A$ = "CLRB": C$ = "Flag as false": GoSub AO
            Z$ = "!": GoSub AO

        Case OP_LT
            A$ = "BMI": B$ = ">": C$ = "If negative then <": GoSub AO
            A$ = "CLRB": C$ = "Flag as false": GoSub AO
            Z$ = "!": GoSub AO

        Case OP_GT
            A$ = "DECA": C$ = "A=A-1": GoSub AO
            A$ = "BEQ": B$ = ">": C$ = "If zero now then >": GoSub AO
            A$ = "CLRB": C$ = "Flag as false": GoSub AO
            Z$ = "!": GoSub AO

        Case OP_LE
            A$ = "DECA": C$ = "A=A-1": GoSub AO
            A$ = "BMI": B$ = ">": C$ = "If negative now then <=": GoSub AO
            A$ = "CLRB": C$ = "Flag as false": GoSub AO
            Z$ = "!": GoSub AO

        Case OP_GE
            A$ = "BPL": B$ = ">": C$ = "If positive/zero then >=": GoSub AO
            A$ = "CLRB": C$ = "Flag as false": GoSub AO
            Z$ = "!": GoSub AO

        Case Else
            Print "Error: unsupported string compare op"; Hex$(CompareOp)
            System
    End Select

    ' B now is $FF for TRUE, 0 for FALSE
    A$ = "PSHS": B$ = "B": C$ = "Push True/False (byte) on stack": GoSub AO

    ' Collapse 2 RPN tokens -> 1 boolean marker
    ProcessRPNStackPointer = ProcessRPNStackPointer - 1
    ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(3)
    Return
End If

' ========================================================
' 2) NUMERIC COMPARE PATH
' ========================================================

' Resolve types exactly like your arithmetic ops do
LeftType = Asc(Right$(Value1$, 1))
If LeftType = 0 Then
    If Len(Value1$) >= 4 Then LeftType = Asc(Mid$(Value1$, 4, 1))
End If

RightType = Asc(Right$(Value2$, 1))
If RightType = 0 Then
    If Len(Value2$) >= 4 Then RightType = Asc(Mid$(Value2$, 4, 1))
End If

' --------------------------------------------------------
' 2a) Constant-fold literal comparisons (both operands literal)
' --------------------------------------------------------
If RightType + LeftType > 255 Then
    Dim bTrue As Integer
    bTrue = 0

    Select Case CompareOp
        Case OP_EQ
            If Val(Left$(Value1$, Len(Value1$) - 1)) = Val(Left$(Value2$, Len(Value2$) - 1)) Then bTrue = -1
        Case OP_NE
            If Val(Left$(Value1$, Len(Value1$) - 1)) <> Val(Left$(Value2$, Len(Value2$) - 1)) Then bTrue = -1
        Case OP_LT
            If Val(Left$(Value1$, Len(Value1$) - 1)) < Val(Left$(Value2$, Len(Value2$) - 1)) Then bTrue = -1
        Case OP_GT
            If Val(Left$(Value1$, Len(Value1$) - 1)) > Val(Left$(Value2$, Len(Value2$) - 1)) Then bTrue = -1
        Case OP_LE
            If Val(Left$(Value1$, Len(Value1$) - 1)) <= Val(Left$(Value2$, Len(Value2$) - 1)) Then bTrue = -1
        Case OP_GE
            If Val(Left$(Value1$, Len(Value1$) - 1)) >= Val(Left$(Value2$, Len(Value2$) - 1)) Then bTrue = -1
        Case Else
            Print "Error: unsupported numeric compare op"; Hex$(CompareOp)
            System
    End Select

    ' Push compile-time boolean onto 6809 stack
    If bTrue Then
        A$ = "LDA": B$ = "#$FF": C$ = "True": GoSub AO
        A$ = "STA": B$ = ",-S": C$ = "push $FF": GoSub AO
    Else
        A$ = "CLR": B$ = ",-S": C$ = "push 0": GoSub AO
    End If

    ' 2 tokens consumed -> 1 boolean marker
    ProcessRPNStackPointer = ProcessRPNStackPointer - 1
    ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(3)
    Return
End If

' --------------------------------------------------------
' 2b) Simple IF optimisation (numeric only)
'     Only when:
'       - InIFCondition% <> 0
'       - SimpleIFCompareMode% <> 0 (exactly 1 compare, no AND/OR)
'       - this compare is that one (RPNEntry = LastCompareIndex%)
'     In that case we:
'       - push the 2 operands to the 6809 stack (PutValuesOnStack)
'       - emit compare+branch with GenCompareAndBranchFalse
'       - do NOT push a boolean marker back on RPN stack
' --------------------------------------------------------
If InIFCondition% <> 0 And SimpleIFCompareMode% <> 0 Then
    If RPNEntry = LastCompareIndex% Then
        ' Put both operands on the 6809 stack using your normal helper
        GoSub PutValuesOnStack
        ' Now ProcessRPNStackPointer has been adjusted (2 -> 0 for this op)
        ' and the numeric values are on the 6809 stack in the expected format.

        ' GenCompareAndBranchFalse MUST NOT touch ProcessRPNStack$.
        ' It only uses Value1$, Value2$, LeftType, RightType, CompareOp
        ' and the values already on the 6809 stack.
        GoSub GenCompareAndBranchFalse
        IFBranchAlreadyEmitted% = -1

        ' No boolean marker is pushed: the IF code already has its branch.
        Return
    End If
End If

' --------------------------------------------------------
' 2c) General numeric compare:
'     - Used for:
'         * plain expressions (InIFCondition% = 0), e.g. y = x < 11
'         * IF conditions that ALSO have AND/OR
'     - PutValuesOnStack:
'         * consumes 2 tokens and pushes numeric values on 6809 stack
'         * sets LargestType, etc.
'     - NumFunctionXxx leaves 0 / $FF on the 6809 stack.
' --------------------------------------------------------
GoSub PutValuesOnStack

Select Case CompareOp
    Case OP_EQ: GoSub NumFunctionEqual
    Case OP_NE: GoSub NumFunctionNotEqual
    Case OP_LT: GoSub NumFunctionLessThan
    Case OP_GT: GoSub NumFunctionGreaterThan
    Case OP_LE: GoSub NumFunctionLessOrEqual
    Case OP_GE: GoSub NumFunctionGreaterOrEqual
    Case Else
        Print "Error: unsupported numeric compare op"; Hex$(CompareOp)
        System
End Select

' Binary operator: 2 inputs, 1 boolean result.
' PutValuesOnStack already consumed the 2 operand tokens,
' so we just push a single result marker.
ProcessRPNStackPointer = ProcessRPNStackPointer + 1
ProcessRPNStack$(ProcessRPNStackPointer) = Chr$(&HFA) + Chr$(0) + Chr$(0) + Chr$(3)
Return

' ------------------------------------------------------------
' ResolveOneCompareOperand
' Temp$ = token
' Sets:
'   ResolvedType% = numeric type of this operand
'
' Handles:
'   - &HFA "already on 6809 stack" marker (result of numeric ops)
'   - Literal numbers (last byte = 128+type)
'   - Regular numeric variables (TK_NumericVar)
'
' NOTE: This does NOT push anything onto the 6809 stack; it just
'       decodes the type so GenCompareAndBranchFalse and
'       PutValuesOnStack can choose signed/unsigned correctly.
' ------------------------------------------------------------
ResolveOneCompareOperand:
ResolvedType% = 0
tLen% = Len(Temp$)
If tLen% = 0 Then
    Print "Internal error: empty token in ResolveOneCompareOperand"
    System
End If

first% = Asc(Left$(Temp$, 1))

' Case 1: already-on-stack numeric marker (&HFA)
If first% = &HFA Then
    ResolvedType% = Asc(Right$(Temp$, 1))
    Return
End If

' Case 2: literal numeric (type >= 128 in last byte)
tType% = Asc(Right$(Temp$, 1))
If tType% >= 128 Then
    ResolvedType% = tType% - 128
    Return
End If

' Case 3: regular numeric variable token (F2, MSB, LSB, Type?)
If first% = TK_NumericVar Then
    VarNum% = Asc(Mid$(Temp$, 2, 1)) * 256 + Asc(Mid$(Temp$, 3, 1))
    tType% = 0
    If tLen% >= 4 Then tType% = Asc(Mid$(Temp$, 4, 1))

    ' If type byte is missing/zero, fall back to your var-type table
    If tType% = 0 Then
        ' Use the actual name of your type array here:
        ' NumericVarType(), NumericVariableType(), etc.
        tType% = NumericVarType(VarNum%)
    End If

    ResolvedType% = tType%
    Return
End If

' Anything else is unexpected here (arrays should already
' have been resolved to elements, etc.), so leave 0.
Return


' ============================================================
' String token detector (unchanged in behaviour)
' ============================================================
' IsStringToken
' Enter: Temp$ = token
' Exit : IsStrFlag% = -1 if string value, 0 otherwise
' Recognizes:
'   TK_StringVar (F3 ...)
'   &HF9 marker (your "string already on 6809 stack")
'   String literal token (F5 22 ... F5 22)
' ------------------------------------------------------------
IsStringToken:
IsStrFlag% = 0
If Len(Temp$) = 0 Then Return

t% = Asc(Left$(Temp$, 1))

' Regular string variable token
If t% = TK_StringVar Then
    IsStrFlag% = -1
    Return
End If

' Marker for "string already on stack"
If t% = &HF9 Then
    IsStrFlag% = -1
    Return
End If

' String literal: F5 22 ... F5 22
If t% = TK_SpecialChar Then
    If Len(Temp$) >= 2 Then
        If Asc(Mid$(Temp$, 2, 1)) = TK_Quote Then
            IsStrFlag% = -1
        End If
    End If
End If
Return

' ------------------------------------------------------------
' PushOneAnyTokenAsStringOnStack
' Enter: Temp$ = token
' Effect: pushes a STRING value onto 6809 stack
'         - if Temp$ is string => uses PushOneStringTokenOnStack
'         - else numeric => PushOneValueTokenOnStack + JSR NumToString_Top
' ------------------------------------------------------------
PushOneAnyTokenAsStringOnStack:
GoSub IsStringToken
If IsStrFlag% Then
    GoSub PushOneStringTokenOnStack
Else
    GoSub PushOneValueTokenOnStack
    ' Convert numeric value currently at ,S into a string object (STUB)
    A$ = "JSR": B$ = "NumToString_Top": C$ = "Stub: converts numeric @,S to string @,S": GoSub AO
End If
Return

' ------------------------------------------------------------
' PushOneStringTokenOnStack
' Enter: Temp$ = token (string var / string literal / HF9 marker)
' Effect: emits codegen to push string value onto the 6809 stack
' NOTE: This is a STUB. You’ll wire it to your real string runtime later.
' ------------------------------------------------------------
PushOneStringTokenOnStack:
If Len(Temp$) = 0 Then Print "Error: empty string token on";: GoTo FoundError
t% = Asc(Left$(Temp$, 1))
If t% = &HF9 Then
    ' Already on 6809 stack (your string result marker)
    Return
End If

If t% = TK_StringVar Then
    StringVar$ = "_StrVar_" + StringVariable$(Asc(Mid$(Temp$, 2, 1)) * 256 + Asc(Mid$(Temp$, 3, 1)))
    Z$ = "; Copy string to the stack:": GoSub AO
    A$ = "LDX": B$ = "#" + StringVar$: C$ = "X points at source string": GoSub AO
    A$ = "LDB": B$ = ",X+": C$ = "B = length of the source string": GoSub AO
    A$ = "BNE": B$ = ">": C$ = "Loop": GoSub AO
    A$ = "CLR": B$ = ",-S": C$ = "Save a zero on the stack": GoSub AO
    A$ = "BRA": B$ = "@Done": C$ = "Skip ahead": GoSub AO
    Z$ = "!": A$ = "ABX": C$ = "Move X to the end of the string": GoSub AO
    A$ = "INCB": C$ = "Increment the counter": GoSub AO
    Z$ = "!": A$ = "LDA": B$ = ",-X": C$ = "Decrement X and get the value in memory": GoSub AO
    A$ = "PSHS": B$ = "A": C$ = "Put it on the stack": GoSub AO
    A$ = "DECB": C$ = "Decrement the counter": GoSub AO
    A$ = "BNE": B$ = "<": C$ = "Loop": GoSub AO
    Z$ = "@Done:": GoSub AO
    Print #1, ""
    Return
End If

If t% = TK_SpecialChar Then
    If Len(Temp$) >= 2 Then
        If Asc(Mid$(Temp$, 2, 1)) = TK_Quote Then
            Lit$ = Mid$(Temp$, 3, Len(Temp$) - 4) ' inside quotes
            A$ = "JSR": B$ = "PushStringLiteral": C$ = "Stub: " + Lit$ + "": GoSub AO
            Return
        End If
    End If
End If
Print "Error: PushOneStringTokenOnStack got non-string token: "; Hex$(t%)
System

' ------------------------------------------------------------
' PushOneValueTokenOnStack
' Enter: Temp$ = token (literal / numeric var / already-on-6809-stack marker)
' Exit : pushes that value onto the 6809 stack
'        PushedType = numeric type (1..15 etc)
' ------------------------------------------------------------
PushOneValueTokenOnStack:
If Len(Temp$) = 0 Then Print "Error: empty token in PushOneValueTokenOnStack on";: GoTo FoundError

If Asc(Left$(Temp$, 1)) = &HFA Then
    ' already on 6809 stack
    PushedType = Asc(Right$(Temp$, 1))
    Return
End If

If Asc(Left$(Temp$, 1)) = TK_ADDR_ONSTACK Then
    ' address already on 6809 stack, don't push anything
    PushedType = NT_UInt16
    Return
End If

PushedType = Asc(Right$(Temp$, 1))
If PushedType = 0 Then PushedType = Asc(Mid$(Temp$, 4, 1)) ' assigned type (var tokens)
If PushedType = 0 Then PushedType = NT_UInt16 ' default numeric type for undeclared vars

If PushedType > 128 Then
    ' literal
    NumberType = PushedType - 128
    Num = Val(Left$(Temp$, Len(Temp$) - 1))
    GoSub LiteralOnStack
    PushedType = PushedType - 128
Else
    ' numeric variable token (F2...)
    NumVarNumber = Asc(Mid$(Temp$, 2, 1)) * 256 + Asc(Mid$(Temp$, 3, 1))
    NumberType = Asc(Mid$(Temp$, Len(Temp$) - 1, 1)) ' actual var type byte
    PushedType = NumberType
    GoSub PutVarOnStack
End If
Return

' Convert the literal number to a specific type based on the value of the number
' Enter with ConvertVal$ = the numeric string to convert
' Will return with the number in ConvertedNum$ and the ManualtType will be set as $80+actual numeric type
ConvertLitNumber:
Num = Val(ConvertVal$)
GoSub CheckForSpecialChar ' Check for special character after the number return with special character number in ManualType, or if not found then ManualType=0
If ManualType = 0 Then
    ' assign a format to the number based on the size and if it has a decimal
    ' Check for decimal
    For ii = 1 To Len(ConvertVal$)
        If Mid$(ConvertVal$, ii, 1) = "." Then
            ' Convert number to a FFP format
            ManualType = NT_Single
            GoTo GotType1
        End If
    Next ii
    ' Make an an integer of some kind, based on size
    ' Number will never be negative as any - will be treated as an unary before the literal number
    If Num < 128 Then
        ManualType = NT_UByte
        GoTo GotType1
    End If
    If Num < 32768 Then
        ManualType = NT_UInt16
        GoTo GotType1
    End If
    If Num < 2147483648 Then
        ManualType = NT_UInt32
        GoTo GotType1
    End If
    ManualType = NT_UInt64
End If
GotType1:
ConvertedNum$ = ConvertVal$
ManualType = ManualType + &H80
Return

' Copy a literal number on the stack
' Enter with:
' NumberType=Numerical Type (Format)
' Num = the number value
LiteralOnStack:
Select Case NumberType
    Case NT_Bit
        Num = Num And 1
        Num = -Num: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDB": B$ = "#" + Num$: C$ = "B is an 8 bit integer either -1 or 0 (_Bit) ` format": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B on the stack": GoSub AO
        Return
    Case NT_UBit
        Num = Num And 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDB": B$ = "#" + Num$: C$ = "B is an 8 bit integer either 0 or 1 (_Unsigned _Bit) ~` format_": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B on the stack": GoSub AO
        Return
    Case NT_Byte
        Num = Num And 255
        If (Num And &H80) <> 0 Then
            Num = Num - &H100 ' bring 0x80-0xFF into -128..-1
        End If
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDB": B$ = "#" + Num$: C$ = "B is an 8 bit integer from -128 to 127 (_Byte) %% format": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B on the stack": GoSub AO
        Return
    Case NT_UByte
        Num = Num And 255: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDB": B$ = "#" + Num$: C$ = "B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save B on the stack": GoSub AO
        Return
    Case NT_Int16
        check1:
        Num = Num And &HFFFF ' keep only bits 0-15
        If (Num And &H8000) <> 0 Then
            Num = Num - &H10000
        End If
        '  GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDD": B$ = "#$" + Right$("0000" + Hex$(Num), 4): C$ = "D is a 16 bit integer from -32768 to 32767 (signed Integer) % format": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AO
        Return
    Case NT_UInt16
        Num = Num And &HFFFF ' keep only bits 0-15
        '  GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDD": B$ = "#$" + Right$("0000" + Hex$(Num), 4): C$ = "D is a 16 bit integer from 0 to 65535 (Unsigned Integer) % format": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AO
        Return
    Case NT_Int32
        VarInt32 = Num
        addr = VarPtr(VarInt32)
        A$ = "LDD": B$ = "#$" + Right$("0" + Hex$(Peek(addr + 3)), 2) + Right$("0" + Hex$(Peek(addr + 2)), 2): C$ = "D is a 16 bit MSW (32 bit signed Long)": GoSub AO
        A$ = "LDX": B$ = "#$" + Right$("0" + Hex$(Peek(addr + 1)), 2) + Right$("0" + Hex$(Peek(addr)), 2): C$ = "X is a 16 bit LSW": GoSub AO
        A$ = "PSHS": B$ = "D,X": C$ = "Save D,X on the stack (Long)": GoSub AO
        Return
    Case NT_UInt32
        VarUInt32 = Num
        addr = VarPtr(VarUInt32)
        A$ = "LDD": B$ = "#$" + Right$("0" + Hex$(Peek(addr + 3)), 2) + Right$("0" + Hex$(Peek(addr + 2)), 2): C$ = "D is a 16 bit MSW (32 bit Unsigned Long)": GoSub AO
        A$ = "LDX": B$ = "#$" + Right$("0" + Hex$(Peek(addr + 1)), 2) + Right$("0" + Hex$(Peek(addr)), 2): C$ = "X is a 16 bit LSW": GoSub AO
        A$ = "PSHS": B$ = "D,X": C$ = "Save D,X on the stack (_Unsigned Long)": GoSub AO
        Return
    Case NT_Int64
        VarInt64 = Num
        addr = VarPtr(VarInt64)
        A$ = "LDD": B$ = "#$" + Right$("0" + Hex$(Peek(addr + 7)), 2) + Right$("0" + Hex$(Peek(addr + 6)), 2): C$ = "D is a 16 bit MSW (64 bit signed Integer64)": GoSub AO
        A$ = "LDX": B$ = "#$" + Right$("0" + Hex$(Peek(addr + 5)), 2) + Right$("0" + Hex$(Peek(addr + 4)), 2): C$ = "X is a 16 bit MIDW": GoSub AO
        A$ = "LDY": B$ = "#$" + Right$("0" + Hex$(Peek(addr + 3)), 2) + Right$("0" + Hex$(Peek(addr + 2)), 2): C$ = "Y is a 16 bit MIDW": GoSub AO
        A$ = "LDU": B$ = "#$" + Right$("0" + Hex$(Peek(addr + 1)), 2) + Right$("0" + Hex$(Peek(addr)), 2): C$ = "U is a 16 bit LSW": GoSub AO
        A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Save D,X,Y,U on the stack, (_Integer64)": GoSub AO
        Return
    Case NT_UInt64
        Dim B(7) As _Unsigned _Byte
        Dim R1 As Integer
        Dim i As Integer
        i$ = NodeValue$(ParseLayer, CurrentASTNodeIdx(ParseLayer))
        ' Convert decimal string to 8 hex bytes
        For i = 7 To 0 Step -1
            ' Divide I$ by 256 to get quotient and remainder
            q$ = ""
            R1 = 0
            For j = 1 To Len(i$)
                R1 = R1 * 10 + Val(Mid$(i$, j, 1))
                If Len(q$) > 0 Or R1 \ 256 > 0 Then
                    q$ = q$ + LTrim$(Str$(R1 \ 256))
                End If
                R1 = R1 Mod 256
            Next
            If q$ = "" Then q$ = "0"
            B(i) = R1
            i$ = q$
        Next
        A$ = "LDD": B$ = "#$" + Right$("0" + Hex$(B(0)), 2) + Right$("0" + Hex$(B(1)), 2): C$ = "D is a 16 bit MSW (64 bit Unsigned Integer64)": GoSub AO
        A$ = "LDX": B$ = "#$" + Right$("0" + Hex$(B(2)), 2) + Right$("0" + Hex$(B(3)), 2): C$ = "X is a 16 bit MIDW": GoSub AO
        A$ = "LDY": B$ = "#$" + Right$("0" + Hex$(B(4)), 2) + Right$("0" + Hex$(B(5)), 2): C$ = "Y is a 16 bit MIDW": GoSub AO
        A$ = "LDU": B$ = "#$" + Right$("0" + Hex$(B(6)), 2) + Right$("0" + Hex$(B(7)), 2): C$ = "U is a 16 bit LSW": GoSub AO
        A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Save D,X,Y,U on the stack, (_UnSigned _Integer64)": GoSub AO
        Return
    Case NT_Single
        Num$ = Str$(Num): Z$ = "; " + Num$ + " Is a 3 Byte floating point number from E-19 to E+19 (Single) ! or none format": GoSub AO
        DoubleToCustomFloat Num ' convert the num to New 3 byte float foramt as Byte1,Byte2,Byte3
        A$ = "LDB": B$ = "#$" + Right$("0" + Hex$(Byte1), 2): C$ = "A is byte 1 of the fast floating point number": GoSub AO
        A$ = "LDX": B$ = "#$" + Right$("0" + Hex$(Byte2), 2) + Right$("0" + Hex$(Byte3), 2): C$ = "X is a Byte 2 & Byte 3 of the fast floating point number": GoSub AO
        A$ = "PSHS": B$ = "B,X": C$ = "Save A,X on the stack, (Fast Floating Point format)": GoSub AO
        Return
    Case NT_Double
        NumDouble = Num ' convert the _Float to Double
        ' Get 8-byte little-endian representation
        Temp$ = MKD$(NumDouble)
        ' Reverse bytes to big-endian
        For i = 1 To 8
            Mid$(big_endian, i, 1) = Mid$(Temp$, 9 - i, 1)
        Next i
        ' First get the MSB of the mantissa

        Num = Asc(Mid$(big_endian, 1, 1))
        Num = (Num And 127) * 256 + Asc(Mid$(big_endian, 2, 1))
        Num = Int(Num / 16)
        If Num <> 0 Then
            Num = Asc(Mid$(big_endian, 2, 1))
            Num = (Num And 15) + 16
        End If
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDB": B$ = "#" + Num$: C$ = "B is the mantissa MSB": GoSub AO
        Num = Asc(Mid$(big_endian, 3, 1)) * 256 + Asc(Mid$(big_endian, 4, 1))
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDX": B$ = "#" + Num$: C$ = "X is a 16 bit 2ndW": GoSub AO
        Num = Asc(Mid$(big_endian, 5, 1)) * 256 + Asc(Mid$(big_endian, 6, 1))
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDY": B$ = "#" + Num$: C$ = "Y is a 16 bit 3rdW": GoSub AO
        Num = Asc(Mid$(big_endian, 7, 1)) * 256 + Asc(Mid$(big_endian, 8, 1))
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDU": B$ = "#" + Num$: C$ = "U is a 16 bit LSW": GoSub AO
        A$ = "PSHS": B$ = "B,X,Y,U": C$ = "Mantissa on the stack": GoSub AO
        Num = Asc(Mid$(big_endian, 1, 1))
        Num = (Num And 128)
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDB": B$ = "#" + Num$: C$ = "B is the SIGN byte": GoSub AO
        Num = Asc(Mid$(big_endian, 1, 1))
        Num = (Num And 127) * 256 + Asc(Mid$(big_endian, 2, 1))
        Num = Int(Num / 16)
        If Num <> 0 Then Num = Num - 1023 ' Normalize the value
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDX": B$ = "#" + Num$: C$ = "X is a 16 bit Normalized Exponent": GoSub AO
        A$ = "PSHS": B$ = "B,X": C$ = "Save B & X on the stack, (Double)": GoSub AO
        Return
    Case NT_Extended
        Print String$(IndentLvl(ParseLayer) * 2, " "); "JSR HandleLiteral"; "   ' "; Num; " (_Float)"
        C$ = Str$(Num) + " Is a floating point number from E-4932 to E+4932 (_Float) ## format": GoSub AO
    Case NT_ShortFloat
        Print String$(IndentLvl(ParseLayer) * 2, " "); "JSR HandleLiteral"; "   ' "; Num; " (_Short)"
        C$ = "Is a 16 bit, fast float format, MSB is left of the decimal LSB is right of the decimal (_Short) ~ format"
        A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AO
    Case NT_UShortFloat
        Print String$(IndentLvl(ParseLayer) * 2, " "); "JSR HandleLiteral"; "   ' "; Num; " (_Unsigned _Short)"
        C$ = "Is a 16 bit, fast float format, MSB is left of the decimal LSB is right of the decimal (_Unsigned _Short) -~ format"
        A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AO
End Select
Return

PutValue2OnStack:
If ProcessRPNStackPointer < 1 Then Return
Value2$ = ProcessRPNStack$(ProcessRPNStackPointer)
ProcessRPNStackPointer = ProcessRPNStackPointer - 1
' Value2
LeftType = Asc(Right$(Value2$, 1))
If LeftType = 0 Then LeftType = Asc(Mid$(Value2$, 4, 1)) ' use the assigned value
If LeftType > 128 Then
    ' We have a literal type to put on the stack
    NumberType = LeftType - 128
    Num = Val(Left$(Value2$, Len(Value2$) - 1))
    GoSub LiteralOnStack ' Copy a literal number on the stack, NumberType=Numerical Type (Format), Num = the number value
    LeftType = LeftType - 128
Else ' Regular number variable
    NumVarNumber = Asc(Mid$(Value2$, 2, 1)) * 256 + Asc(Mid$(Value2$, 3, 1))
    NumberType = Asc(Mid$(Value2$, Len(Value2$) - 1, 1))
    GoSub PutVarOnStack 'Put NumVarNumber on the stack where NumVarNumber = Numeric Variable Number with NumberType = Type of number
    If Asc(Mid$(Value2$, Len(Value2$), 1)) <> 0 Then
        LastType = Asc(Mid$(Value2$, Len(Value2$) - 1, 1))
        NVT = Asc(Right$(Value2$, 1))
        ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
        GoSub ConvertLastType2NVT
    End If
End If
Largesttype = LeftType
Return

' Put Value1 & Value2 on the 6809 stack so that:
'   Value2 (left)  ends up at ,S   (lowest address)
'   Value1 (right) ends up at 3,S  (higher address)
' Also sets LeftType, RightType, and Largesttype
PutValuesOnStack:
If ProcessRPNStackPointer < 1 Then Return
' Pop right then left from the RPN stack (normal RPN order)
Value2$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
Value1$ = ProcessRPNStack$(ProcessRPNStackPointer): ProcessRPNStackPointer = ProcessRPNStackPointer - 1
V1OnStack% = 0
V2OnStack% = 0
If Asc(Left$(Value1$, 1)) = &HFA Or Asc(Left$(Value1$, 1)) = TK_ADDR_ONSTACK Then V1OnStack% = -1
If Asc(Left$(Value2$, 1)) = &HFA Or Asc(Left$(Value2$, 1)) = TK_ADDR_ONSTACK Then V2OnStack% = -1

' ------------------------------------------------------------
' Determine numeric types even if already on stack
' ------------------------------------------------------------
If V1OnStack% Then
    RightType = Asc(Right$(Value1$, 1))
Else
    Tok$ = Value1$: GoSub GetTokenTypeOnly
    RightType = TokType
End If
If V2OnStack% Then
    LeftType = Asc(Right$(Value2$, 1))
Else
    Tok$ = Value2$: GoSub GetTokenTypeOnly
    LeftType = TokType
End If

' ------------------------------------------------------------
' Now enforce 6809 order: [ ... Value2(left) ][ Value1(right) ]
' ------------------------------------------------------------

' Case 1: both already on 6809 stack -> nothing to push
If V1OnStack% And V2OnStack% Then GoTo SetLargest
' Case 1b: left already on 6809 stack, right not -> push the missing right operand
If V1OnStack% And (Not V2OnStack%) Then
    Tok$ = Value2$: GoSub PushTokenNumeric
    LeftType = TokType
    GoTo SetLargest
End If
' Case 2: left already on 6809 stack, right not -> push right second
If V2OnStack% And (Not V1OnStack%) Then
    Tok$ = Value1$: GoSub PushTokenNumeric
    RightType = LeftType
    LeftType = TokType
    GoTo SetLargest
End If
' Case 3: neither on 6809 stack -> push right first, then left second
'   (so Value1 @3,S, Value2 @,S)
If (Not V1OnStack%) And (Not V2OnStack%) Then
    Tok$ = Value1$: GoSub PushTokenNumeric
    RightType = TokType
    Tok$ = Value2$: GoSub PushTokenNumeric
    LeftType = TokType
    GoTo SetLargest
End If
SetLargest:
If RightType > LeftType Then
    Largesttype = RightType
Else
    Largesttype = LeftType
End If
Return

' ------------------------------------------------------------
' Helper: get token type without pushing
' ------------------------------------------------------------
'GetTokenTypeOnly:
'If Len(Tok$) = 0 Then TokType = 0: Return
'If Asc(Left$(Tok$, 1)) = TK_ADDR_ONSTACK Then TokType = NT_UInt16: Return
'If Asc(Left$(Tok$, 1)) = &HFA Then TokType = Asc(Right$(Tok$, 1)): Return
'TokType = Asc(Right$(Tok$, 1))
'If TokType = 0 Then
'    If Len(Tok$) >= 4 Then TokType = Asc(Mid$(Tok$, 4, 1))
'End If
'If TokType > 128 Then TokType = TokType - 128
'Return

GetTokenTypeOnly:
If Len(Tok$) = 0 Then TokType = 0: Return
TokType = Asc(Right$(Tok$, 1))

' Literal numbers are stored as: "123" + Chr$(Type+128)
If TokType > 128 Then
    TokType = TokType - 128
    Return
End If
t0 = Asc(Left$(Tok$, 1))

' Numeric variable token produced by ExpressionToRPN is usually:
'   F2, MSB, LSB, BaseTypeFromTokenizer(0 in pass1), ManualType(0 if none)
If t0 = TK_NumericVar Then
    VarNum = Asc(Mid$(Tok$, 2, 1)) * 256 + Asc(Mid$(Tok$, 3, 1))
    baseType = 0
    If Len(Tok$) >= 4 Then baseType = Asc(Mid$(Tok$, 4, 1))
    nvtType = 0
    If Len(Tok$) >= 5 Then nvtType = Asc(Right$(Tok$, 1))
    ' Prefer explicit manual type, otherwise base type
    TokType = nvtType
    If TokType = 0 Then TokType = baseType
    ' If still unknown, fall back to var table
    If TokType = 0 Then TokType = NumericVarType(VarNum)
    Return
End If

' Numeric array token: F0, MSB, LSB, ElemType, #Elems
If t0 = TK_NumericArray Then
    ArrNum = Asc(Mid$(Tok$, 2, 1)) * 256 + Asc(Mid$(Tok$, 3, 1))
    TokType = 0
    If Len(Tok$) >= 4 Then TokType = Asc(Mid$(Tok$, 4, 1))
    If TokType = 0 Then TokType = NumericArrayBits(ArrNum)
    Return
End If

' Default: if last byte is 0, try byte 4 (old behavior)
If TokType = 0 Then
    If Len(Tok$) >= 4 Then TokType = Asc(Mid$(Tok$, 4, 1))
End If
Return

' ------------------------------------------------------------
' Helper: push numeric token Tok$ onto 6809 stack
' ------------------------------------------------------------
PushTokenNumeric:
If Len(Tok$) = 0 Then TokType = 0: Return
If Asc(Left$(Tok$, 1)) = &HFA Or Asc(Left$(Tok$, 1)) = TK_ADDR_ONSTACK Then
    TokType = Asc(Right$(Tok$, 1))
    Return
End If
TokType = Asc(Right$(Tok$, 1))
If TokType = 0 Then
    If Len(Tok$) >= 4 Then TokType = Asc(Mid$(Tok$, 4, 1))
End If
If TokType > 128 Then
    NumberType = TokType - 128
    Num = Val(Left$(Tok$, Len(Tok$) - 1))
    GoSub LiteralOnStack
    TokType = NumberType
    Return
End If
'NumVarNumber = Asc(Mid$(Tok$, 2, 1)) * 256 + Asc(Mid$(Tok$, 3, 1))
'NumberType = Asc(Mid$(Tok$, Len(Tok$) - 1, 1))
'GoSub PutVarOnStack
'If Asc(Mid$(Tok$, Len(Tok$), 1)) <> 0 Then
'    LastType = Asc(Mid$(Tok$, Len(Tok$) - 1, 1))
'    NVT = Asc(Right$(Tok$, 1))
'    GoSub ConvertLastType2NVT
'    TokType = NVT
'Else
'    TokType = NumberType
'End If
'Return


' ... inside PushTokenNumeric, when handling TK_NumericVar ...
NumVarNumber = Asc(Mid$(Tok$, 2, 1)) * 256 + Asc(Mid$(Tok$, 3, 1))
' Base type is the 2nd-last byte for your 5-byte var tokens
NumberType = Asc(Mid$(Tok$, Len(Tok$) - 1, 1))
If NumberType = 0 Then NumberType = NumericVarType(NumVarNumber)
GoSub PutVarOnStack ' pushes the variable value using NumberType
' If manual type requested (last byte), convert
NVT_Save = NVT
NVT = Asc(Right$(Tok$, 1))
If NVT <> 0 Then
    LastType = NumberType
    GoSub ConvertLastType2NVT
    TokType = NVT
Else
    TokType = NumberType
End If
NVT = NVT_Save
Return


' Save the value of a numeric variable on the stack
' &HF0 = Numeric Array Variable (5 bytes)    F0,MSB,LSB,# Of Elements,Type
' &HF2 = Regular Numeric Variable (4 Bytes)  F2,MSB,LSB,Type
'
' NumVarNumber = Asc(Mid$(Var$, 2, 1)) * 256 + Asc(Mid$(Var$, 3, 1))
' NumberType = Asc(Mid$(Var$, Len(Var$) - 1, 1))
PutVarOnStack:
Num = NumVarNumber: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
Select Case NumberType
    Case Is < 5 ' One byte variable
        A$ = "LDB": B$ = "_Var_" + NumericVariable$(Num): C$ = "Get the value of the variable": GoSub AO
        A$ = "PSHS": B$ = "B": C$ = "Save the value on the stack": GoSub AO
    Case 5, 6 ' Two byte variable
        A$ = "LDD": B$ = "_Var_" + NumericVariable$(Num): C$ = "Get the value of the variable": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the value on the stack": GoSub AO
    Case 7, 8 ' 4 byte variable
        A$ = "LDU": B$ = "#_Var_" + NumericVariable$(Num): GoSub AO
        A$ = "PULU": B$ = "D,X": C$ = "Get the 4 byte value of the variable": GoSub AO
        A$ = "PSHS": B$ = "D,X": C$ = "Save the 4 byte value on the stack": GoSub AO
    Case 9, 10 ' 8 byte variable
        A$ = "LDU": B$ = "#_Var_" + NumericVariable$(Num): GoSub AO
        A$ = "PULU": B$ = "D,X,Y": C$ = "Get the 6 of the 8 byte value of the variable": GoSub AO
        A$ = "LDU": B$ = ",U": C$ = "Get the 7th & 8th byte value on the stack": GoSub AO
        A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Save the 8 byte value on the stack": GoSub AO
    Case 11 ' 3 byte variable
        A$ = "LDU": B$ = "#_Var_" + NumericVariable$(Num): GoSub AO
        A$ = "PULU": B$ = "B,X": C$ = "Get the 3 byte value of the variable": GoSub AO
        A$ = "PSHS": B$ = "B,X": C$ = "Save the 3 byte value on the stack": GoSub AO
    Case 12 ' 10 byte variable
        A$ = "LDU": B$ = "#_Var_" + NumericVariable$(Num) + "+2": GoSub AO
        A$ = "PULU": B$ = "D,X,Y": C$ = "Get the first 6 bytes of data, move U past the data": GoSub AO
        A$ = "LDU": B$ = ",U": C$ = "Load U with the last two bytes of data": GoSub AO
        A$ = "PSHS": B$ = "D,X,Y,U": C$ = "Push them on the stack": GoSub AO
        A$ = "LDD": B$ = "_Var_" + NumericVariable$(Num): C$ = "; Get the first 2 bytes of data": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Push them on the stack": GoSub AO
End Select
Return

' Emit one complete RPN entry (operand / operator / literal / function token)
' Uses global Emit$
RPN_Emit:
RPNLast = RPNLast + 1
RPNOutput$(RPNLast) = Emit$
Return
