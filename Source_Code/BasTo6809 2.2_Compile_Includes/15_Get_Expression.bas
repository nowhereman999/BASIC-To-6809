' Get General Expression
' Returns with single expression in GenExpression$
GetGenExpression:
v = Array(x): x = x + 1
GenExpression$ = Chr$(v)
If v < &HF0 Then Return ' Copy single byte, as is
'We have a Token
Select Case v
    Case TK_NumericArray ' Found a Numeric array
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of Array ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of Array ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy # of dimensions
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy Var Type of the numeric Array
    Case TK_StrArray ' Found a String array
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of Array ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of Array ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy # of dimensions
    Case TK_NumericVar ' Found a numeric variable
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of variable ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of variable ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy Var Type of numeric variable
    Case TK_StringVar ' Found a string variable
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of variable ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of variable ID
    Case TK_SpecialChar ' Found a special character
        v = Array(x): x = x + 1
        GenExpression$ = GenExpression$ + Chr$(v) ' Copy special character
    Case TK_StringVar: ' Found a DEF FN Function
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of FN ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of FN ID
    Case TK_OperatorCommand: ' Found an Operator
        v = Array(x): x = x + 1
        GenExpression$ = GenExpression$ + Chr$(v) ' Operator character
    Case TK_StringCommand, TK_NumericCommand, TK_GeneralCommand: 'Found String,Numeric or General command
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of command ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of command ID
End Select
Return

' Get an Expression before a semi colon, a comma or an EOL
GetExpressionB4SemiComEOL:
Expression$ = ""
GEB4SemiComEOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(TK_SpecialChar) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = TK_EOL Or Sp = TK_Colon Or Sp = TK_SemiColon Or Sp = TK_Comma Then x = x - 2: Return ' IF EOL/Colon, semicolon, a comma or a quote then point at it again and return
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4SemiComEOL

'Handle an expression that ends with a comma or EOL, skip brackets
GetExpressionB4CommaEOL:
Expression$ = ""
InBracket = 0
GEB4CommaEOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If GenExpression$ = Chr$(&HF5) + Chr$(&H0D) Or GenExpression$ = Chr$(&HF5) + Chr$(&H3A) Then x = x - 2: Return ' IF EOL/Colon point at it again and return
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = TK_EOL Or Sp = TK_Colon Then x = x - 2: Return ' IF EOL/Colon, or a quote then point at it again and return
    If Sp = TK_Comma And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4CommaEOL


'Handle an expression that ends with a comma skip brackets
GetExpressionB4Comma:
Expression$ = ""
InBracket = 0
GEB4Comma:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(TK_SpecialChar) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Asc(Right$(GenExpression$, 1)) = TK_Comma And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4Comma

' Get an Expression before a semi colon, a plus, a comma a quote an EOL/Colon
GetExpressionB4SemiPlusComQ_EOL:
Expression$ = ""
GEB4SemiPlusComQ_EOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(TK_SpecialChar) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = TK_EOL Or Sp = TK_Colon Or Sp = TK_SemiColon Or Sp = TK_Comma Or Sp = TK_Quote Then x = x - 2: Return ' IF EOL/Colon, semicolon, a comma or a quote then point at it again and return
End If
If Left$(GenExpression$, 1) = Chr$(TK_OperatorCommand) And Right$(GenExpression$, 1) = Chr$(&H2B) Then x = x - 2: Return 'Found a plus point at it again and return
Expression$ = Expression$ + GenExpression$
GoTo GEB4SemiPlusComQ_EOL

'Handle an expression that ends with a colon or End of a Line
GetExpressionB4EOL:
Expression$ = ""
GEB4EOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If GenExpression$ = Chr$(TK_SpecialChar) + Chr$(TK_EOL) Or GenExpression$ = Chr$(TK_SpecialChar) + Chr$(TK_Colon) Then x = x - 2: Return ' IF EOL/Colon point at it again and return
Expression$ = Expression$ + GenExpression$
GoTo GEB4EOL

'Handle an expression that ends with a close bracket
GetExpressionMidB4EndBracket:
InBracket = 0
Expression$ = ""
GEB4EndBracket:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = Asc(")") And InBracket = 0 Then x = x - 2: Return ' If last close bracket then point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4EndBracket

' Get Expression before End Bracket
GetExpressionFullB4EndBracket:
InBracket = 0
Expression$ = ""
GEFullB4EndBracket:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(TK_SpecialChar) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
    If Sp = Asc(")") And InBracket = 0 Then x = x - 2: Return ' If last close bracket then point at it again and return
End If
Expression$ = Expression$ + GenExpression$
GoTo GEFullB4EndBracket

'Handle an expression that ends with a colon or End of a Line or a general command like TO or STEP
GetExpressionB4EOLOrCommand:
Expression$ = ""
GEB4EOLOrCommand:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(TK_GeneralCommand) Then x = x - 3: Return 'point at the command and return
If Left$(GenExpression$, 1) = Chr$(TK_SpecialChar) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = TK_EOL Or Sp = TK_Colon Then x = x - 2: Return ' IF EOL/Colon then point at it again and return
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4EOLOrCommand



' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon     (Makes sure to ignore commas inside brackets like a 2 or more dimension array)
GetExB4SemiComQ13D_EOL:
Expression$ = ""
InBracket = 0
GEB4SemiComQ13D_EOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Or Sp = &H3B Or Sp = &H22 Then x = x - 2: Return ' IF EOL/Colon, semicolon, a comma or a quote then point at it again and return
    ' Make sure we are not inside brackets when we get a comma
    If Sp = &H2C And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
If Left$(GenExpression$, 1) = Chr$(&HF1) And InBracket = 0 Then x = x - 4: Return 'Found a string array, point at it again and return
If Left$(GenExpression$, 1) = Chr$(&HF3) And InBracket = 0 Then x = x - 3: Return 'Found a string variable, point at it again and return
If Left$(GenExpression$, 1) = Chr$(&HFD) And InBracket = 0 Then x = x - 3: Return 'Found a string command, point at it again and return
Expression$ = Expression$ + GenExpression$
GoTo GEB4SemiComQ13D_EOL
